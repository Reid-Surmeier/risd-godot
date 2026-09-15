#!/usr/bin/env python3
"""Independent exact-state and screenshot verifier for the production Collection search playtest."""
import hashlib
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

out = Path(sys.argv[1])
report = json.loads((out / "report.json").read_text())
states = {event["label"]: event for event in report["log"] if event["event"] == "search"}
shots = {event["file"] for event in report["log"] if event["event"] == "screenshot"}
fixture = next(event for event in report["log"] if event["event"] == "fixture")
checks = {}


def check(name, condition, detail=""):
    checks[name] = {"pass": bool(condition), "detail": str(detail)}


def win(state, name):
    return next(window for window in state["windows"] if window["name"] == name)


def edge_dark_fraction(image):
    dark = np.max(image, axis=2) < 24
    return [float(dark[0].mean()), float(dark[-1].mean()), float(dark[:, 0].mean()), float(dark[:, -1].mean())]


images = {name: np.array(Image.open(out / name).convert("RGB")) for name in shots}
hashes = {name: hashlib.sha256((out / name).read_bytes()).hexdigest() for name in shots}
check("nine_screenshots", len(shots) == 9, sorted(shots))
check("screenshots_are_distinct", len(set(hashes.values())) == 9)
check("native_sizes", images["01-default-results.png"].shape[:2] == (1080, 1920)
      and images["09-compact-720x486.png"].shape[:2] == (486, 720))
check("screenshots_have_visible_content", all(float(image.std()) > 12 for image in images.values()))
compact_edges = edge_dark_fraction(images["09-compact-720x486.png"])
check("compact_has_no_black_bars", all(value < 0.30 for value in compact_edges), compact_edges)

launch = states["default-images"]
check("default_search_once", launch["phase"] == "results" and launch["requests"] == launch["completions"] == 1)
check("contract_defaults", launch["applied"] ==
      {"q": "", "category": "All", "sort": "date_asc", "has_image": True, "page": 1})
check("verified_default_corpus", launch["response"]["total"] == 2 and launch["images_loaded"] == 2
      and "Partial RISD corpus" in launch["response"]["coverage"], launch["response"])
check("verified_paintings_loaded", {item["id"] for item in launch["items"] if item["has_texture"]}
      == {"risd:1377691", "risd:1584511"}, launch["items"])
check("all_native_controls_present", set(launch["controls"]) ==
      {"Query", "Sort", "Category", "HasImage", "OK", "Cancel", "Retry", "Previous", "Next", "Details"})
check("four_sort_orders", launch["sort_items"] == ["Title (A→Z)", "Title (Z→A)", "Date (old→new)", "Date (new→old)"])
check("categories_from_response", launch["category_items"] == ["All", "Painting", "Photographs", "Drawings and Watercolors"])

typed, canceled = states["unicode-draft-no-request"], states["unicode-canceled"]
check("unicode_input_without_request", typed["draft"]["q"] == "雪" and typed["requests"] == launch["requests"])
check("escape_restores_last_success", canceled["draft"] == canceled["last_successful"] == launch["last_successful"]
      and canceled["requests"] == typed["requests"])
check("keyboard_focus_order", [states[name]["focus_owner"] for name in
      ["focus-sort", "focus-category", "focus-checkbox", "focus-ok"]] == ["Sort", "Category", "HasImage", "OK"])
popup_open, popup_closed = states["sort-popup-open"], states["sort-popup-dismissed"]
check("escape_only_dismisses_popup", popup_open["sort_popup_visible"] and not popup_closed["sort_popup_visible"]
      and popup_closed["draft"]["q"] == "Monet" and popup_closed["requests"] == popup_open["requests"])
check("checkbox_can_toggle_without_request", not states["checkbox-off"]["draft"]["has_image"]
      and states["checkbox-off"]["requests"] == launch["requests"])

a = states["A-images"]
check("keyboard_apply_one_request", a["requests"] == launch["requests"] + 1 and a["response"]["query"] == a["applied"])
check("dropdown_and_space_values_apply", a["applied"] ==
      {"q": "Monet", "category": "Painting", "sort": "date_desc", "has_image": True, "page": 1})
check("filtered_real_paintings", a["response"]["total"] == 2 and a["images_loaded"] == 2
      and all(item["has_texture"] for item in a["items"]), a["items"])

failed, restored = states["B-failed"], states["B-canceled-restores-A"]
check("failed_B_keeps_A", failed["phase"] == "error" and failed["response"] == a["response"] and failed["requests"] == a["requests"] + 1)
check("cancel_B_restores_A_without_request", restored["draft"] == restored["applied"] == a["applied"]
      and restored["requests"] == failed["requests"] and restored["focus_owner"].startswith("Card_"))
stale = states["older-reply-ignored"]
check("late_reply_ignored", stale["response"]["query"]["q"] == "Monet" and stale["ignored_completions"] == 1)

page_one, page_two = states["page-one-with-draft"], states["page-two"]
check("draft_survives_pagination", page_one["draft"]["q"] == page_two["draft"]["q"] == "unsent"
      and page_two["applied"]["q"] == "pages")
check("pagination_pins_snapshot", page_two["response"]["page"] == 2 and page_two["applied"]["page"] == 2
      and page_two["applied"]["snapshot"] == page_one["response"]["snapshot"])
check("pagination_is_one_request", page_two["requests"] == page_one["requests"] + 1)

empty, missing, broken, expired = states["empty-results"], states["missing-image"], states["broken-image"], states["snapshot-expired"]
check("empty_state", empty["phase"] == "results" and empty["response"]["total"] == 0 and empty["items"] == [])
check("missing_image_state", missing["response"]["total"] == 1 and len(missing["items"]) == 1
      and not missing["items"][0]["has_texture"] and missing["items"][0]["image_unavailable"])
check("broken_image_state", broken["response"]["total"] == 1 and broken["image_failures"] == 1
      and not broken["items"][0]["has_texture"] and broken["items"][0]["image_unavailable"])
check("snapshot_expired_state", expired["phase"] == "snapshot_expired" and expired["response"] == broken["response"])
retried = states["snapshot-retry"]
check("snapshot_retry_becomes_last_success", retried["phase"] == "results" and retried["applied"]["q"] == "expire"
      and retried["applied"]["page"] == 1 and "snapshot" not in retried["applied"]
      and retried["last_successful"] == retried["applied"] and retried["requests"] == expired["requests"] + 1)

focused, before, selected = states["result-focused"], states["before-selection"], states["selected"]
check("result_card_is_keyboard_focusable", focused["focus_owner"].startswith("Card_"))
check("selection_does_not_request_or_save", selected["selected"] in {item["id"] for item in before["items"]}
      and selected["requests"] == before["requests"] and "saved" not in selected)
moved = states["filters-moved"]
f0, f1 = win(selected, "filters")["rect"], win(moved, "filters")["rect"]
check("filter_window_drags_and_raises", abs(f1["x"] - f0["x"] - 24) < 1 and abs(f1["y"] - f0["y"] - 12) < 1
      and win(moved, "filters")["order"] == max(window["order"] for window in moved["windows"]))
resized = states["viewer-resized"]
v0, v1 = win(moved, "viewer")["rect"], win(resized, "viewer")["rect"]
check("viewer_resizes_in_place", v1["x"] == v0["x"] and v1["y"] == v0["y"]
      and abs(v1["w"] - (v0["w"] - 80)) < 1 and abs(v1["h"] - (v0["h"] - 50)) < 1)

hidden_before, hidden_after, resumed = states["hidden-before-reply"], states["hidden-after-reply"], states["resumed-applies-reply"]
check("hidden_page_is_frozen", hidden_before["phase"] == hidden_after["phase"] == "loading"
      and hidden_before["ticks"] == hidden_after["ticks"], (hidden_before["ticks"], hidden_after["ticks"]))
check("hidden_reply_applies_on_resume", resumed["phase"] == "results" and resumed["response"]["query"]["q"] == "slow")

compact = states["compact-720x486"]
filter_rect = win(compact, "filters")["rect"]
filter_right, filter_bottom = filter_rect["x"] + filter_rect["w"], filter_rect["y"] + filter_rect["h"]
filter_controls = [compact["controls"][name] for name in ["Query", "Sort", "Category", "HasImage", "OK", "Cancel"]]
check("compact_controls_stay_in_filter_window", all(rect["x"] >= filter_rect["x"] - 1 and rect["y"] >= filter_rect["y"] - 1
      and rect["x"] + rect["w"] <= filter_right + 1 and rect["y"] + rect["h"] <= filter_bottom + 1 for rect in filter_controls),
      {name: compact["controls"][name] for name in ["Query", "Sort", "Category", "HasImage", "OK", "Cancel"]})
check("compact_windows_stay_in_page", all(window["rect"]["x"] >= -1 and window["rect"]["y"] >= -1
      and window["rect"]["x"] + window["rect"]["w"] <= compact["size"][0] + 1
      and window["rect"]["y"] + window["rect"]["h"] <= compact["size"][1] + 1 for window in compact["windows"]))
check("adapter_received_exact_requests", len(fixture["calls"]) == compact["requests"] == 14
      and fixture["calls"][6]["q"] == "pages" and fixture["calls"][6]["page"] == 2
      and "snapshot" in fixture["calls"][6])

passed = all(value["pass"] for value in checks.values())
(out / "verify.json").write_text(json.dumps({"pass": passed, "checks": checks, "sha256": hashes}, indent=2) + "\n")
for name, result in checks.items():
    print("PASS" if result["pass"] else "FAIL", name, result["detail"])
print("VERDICT", "PASS" if passed else "FAIL", f"({sum(value['pass'] for value in checks.values())}/{len(checks)})")
sys.exit(0 if passed else 1)
