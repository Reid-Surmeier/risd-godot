#!/usr/bin/env python3
"""Independent verifier for a tab_strip playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels, and checks the logged states against the
interface contract (timings, counts, labels, page visibility, truncation, close).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

SCALE = 0.55            # demo.gd SCALE
RIGHT_CLUSTER_W = 1920  # layout.json
ICONS_OFFSET = 456
FULL_TAB_W = 680

out = Path(sys.argv[1])
rep = json.loads((out / "report.json").read_text())
log = rep["log"]
states = {e["label"]: e for e in log if e["event"] == "state"}
signals = [e for e in log if e["event"] == "signal"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 12, str(sorted(shots)))
check("mid_grow_differs_from_initial", hashes["01-initial.png"] != hashes["02-mid-grow.png"])
check("connecting_differs_from_mid_grow", hashes["02-mid-grow.png"] != hashes["03-connecting.png"])
check("blank_page_differs_from_connecting", hashes["03-connecting.png"] != hashes["04-blank-page.png"])

check("initial_one_tab", states["initial"]["count"] == 1 and states["initial"]["tabs"][0]["label"] == "windows_live")
check("click_opened_second_tab", states["mid-grow"]["count"] == 2 and states["mid-grow"]["opening"] is True)
mg = states["mid-grow"]["tabs"][1]; full_w = states["connecting"]["tabs"][1]["w"]
check("mid_grow_width_between_stub_and_full", 180 < mg["w"] < full_w, f"w={mg['w']:.0f} full={full_w:.0f}")
check("connecting_label_then_blank_page", states["connecting"]["tabs"][1]["label"] == "connecting"
      and states["blank-page"]["tabs"][1]["label"] == "blank_page")
check("new_tab_becomes_active_with_page", states["connecting"]["active"] == 1 and states["connecting"]["tabs"][1]["page_visible"]
      and not states["connecting"]["tabs"][0]["page_visible"])
check("first_tab_unchanged", states["initial"]["tabs"][0]["x"] == states["blank-page"]["tabs"][0]["x"]
      and states["initial"]["tabs"][0]["w"] == states["blank-page"]["tabs"][0]["w"])
check("full_size_tabs_not_truncated", not states["blank-page"]["tabs"][0]["truncated"] and not states["blank-page"]["tabs"][1]["truncated"])

def t(sig, idx=1):
    return next((e["t_ms"] for e in signals if e["signal"] == sig and e["index"] == idx), None)
grow = (t("tab_settled") or 0) - (t("tab_opened") or 0); title = (t("tab_titled") or 0) - (t("tab_settled") or 0)
check("grow_took_about_500ms", 430 <= grow <= 650, f"{grow} ms")
check("title_swap_after_about_950ms", 880 <= title <= 1100, f"{title} ms")

check("click_tab0_shows_page0", states["selected-0"]["active"] == 0 and states["selected-0"]["tabs"][0]["page_visible"]
      and not states["selected-0"]["tabs"][1]["page_visible"])
check("click_tab1_shows_page1", states["selected-1"]["active"] == 1 and states["selected-1"]["tabs"][1]["page_visible"])
check("close_button_on_every_tab", all(tb["close_rect"]["size"]["x"] > 0 for tb in states["selected-1"]["tabs"]))
check("third_tab_opened_from_moved_stub", states["third-tab"]["count"] == 3 and states["third-tab"]["tabs"][2]["label"] == "blank_page")

full = states["full-row"]; fill = next(e for e in log if e["event"] == "fill")
max_right = full["bar_width"] - RIGHT_CLUSTER_W + ICONS_OFFSET - 40
check("row_fills_then_refuses", full["count"] >= 4 and "refused" in fill["result"], fill["result"])
check("full_row_tabs_shrunk_not_overflowed", all(tb["x"] + tb["w"] <= max_right + 1 for tb in full["tabs"]) and full["tabs"][-1]["w"] < FULL_TAB_W,
      f"{full['count']} tabs, last w={full['tabs'][-1]['w']:.0f}, max_right={max_right:.0f}")
check("shrunk_labels_truncated_with_dots", all(tb["truncated"] for tb in full["tabs"] if tb["label"] == "blank_page"),
      f"{sum(tb['truncated'] for tb in full['tabs'])}/{full['count']} truncated")

cl = states["closed-last"]
check("close_button_removed_active_tab", cl["count"] == full["count"] - 1 and cl["active"] == cl["count"] - 1
      and sum(tb["page_visible"] for tb in cl["tabs"]) == 1, f"{full['count']} -> {cl['count']}, active {cl['active']}")
clicks = [e for e in log if e["event"] == "click"]
t_click = next(e["t_ms"] for e in clicks if e["what"] == "close button of active tab")
t_closed = next((e["t_ms"] for e in signals if e["signal"] == "tab_closed"), None)
check("close_animates_before_removal", t_closed is not None and 250 <= t_closed - t_click <= 600,
      f"{(t_closed or 0) - t_click} ms from click to tab_closed (fold is 300 ms)")
cs = states["closed-second"]
check("close_second_tab_selects_left_neighbour", cs["count"] == cl["count"] - 1 and cs["active"] == 0
      and cs["tabs"][0]["page_visible"], f"count {cs['count']}, active {cs['active']}")
check("closed_row_regrew", cs["tabs"][-1]["w"] > cl["tabs"][-1]["w"] or cs["tabs"][-1]["w"] == FULL_TAB_W,
      f"{cl['tabs'][-1]['w']:.0f} -> {cs['tabs'][-1]['w']:.0f}")

ac = states["all-closed"]; ro = states["reopened"]
check("every_tab_can_close", ac["count"] == 0 and ac["active"] == -1, f"count {ac['count']}")
check("stub_reopens_after_empty", ro["count"] == 1 and ro["tabs"][0]["label"] == "blank_page" and ro["tabs"][0]["page_visible"], f"count {ro['count']}")

def region(img, x0, y0, x1, y1):
    return img[int(y0 * SCALE):int(y1 * SCALE), int(x0 * SCALE):int(x1 * SCALE)]
a = region(imgs["01-initial.png"], 261, 27, 700, 150); b = region(imgs["04-blank-page.png"], 261, 27, 700, 150)  # above the bottom line, which appears once the tab is inactive
check("first_tab_pixels_identical", float(np.abs(a - b).mean()) < 0.5, f"mean abs diff {float(np.abs(a-b).mean()):.2f}")
c = region(imgs["01-initial.png"], 900, 27, 1500, 161); d = region(imgs["04-blank-page.png"], 900, 27, 1500, 161)
check("new_tab_pixels_changed", float(np.abs(c - d).mean()) > 5, f"mean abs diff {float(np.abs(c-d).mean()):.2f}")
# the bar spans the whole window: right cluster pinned at the right edge (its » chevron is dark)
w = imgs["01-initial.png"].shape[1]; edge = imgs["01-initial.png"][:int(161 * SCALE), w - 40:w]
check("bar_spans_full_width", (edge.max(axis=2) < 150).sum() > 5, f"dark px in last 40 columns: {(edge.max(axis=2) < 150).sum()}")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
