#!/usr/bin/env python3
import hashlib, json, sys
from pathlib import Path
from PIL import Image

out = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/collection-search-controls")
report = json.loads((out / "report.json").read_text())
states = {e["label"]: e for e in report["log"] if e["event"] == "state"}
checks = {}
def check(name, ok): checks[name] = bool(ok)

check("source_hash_locked", states["launch-results"]["layout_reference_sha256"] == "e51cbb294653573b43432f623df7277a86adbeddb0d2f0d7c31b36928592075d")
check("popup_opened_by_pointer", states["sort-popup-open"]["sort_popup"]["visible"])
check("sort_changed_by_pointer", states["sort-changed"]["draft"]["sort"] == 1)
check("category_changed_by_pointer", states["category-popup-open"]["category_popup"]["visible"] and states["category-changed"]["draft"]["category"] == 1)
check("checkbox_changed_by_pointer", states["checkbox-changed"]["draft"]["has_image"] is True)
check("alphabet_numerals_and_caret", states["alphabet-numerals-caret"]["draft"]["query"] == "Monet 42" and states["alphabet-numerals-caret"]["query_focused"])
check("all_draft_controls_restored", states["all-controls-restored"]["draft"] == states["all-controls-restored"]["applied"] == {"query":"", "sort":0, "category":0, "has_image":False})
check("typed_draft_by_keys", states["draft-none"]["draft"]["query"] == "none" and states["draft-none"]["applied"]["query"] == "")
check("escape_restored_applied", states["escape-restored-applied"]["draft"]["query"] == "")
check("loading_kept_prior_results", states["loading-keeps-prior-count"]["phase"] == "loading" and states["loading-keeps-prior-count"]["visible_count"] == 3)
check("empty_success", states["empty-results"]["phase"] == "results" and states["empty-results"]["visible_count"] == 0)
check("failure_and_retry", states["failed-search"]["phase"] == states["retry-failed-fixture"]["phase"] == "error" and states["retry-failed-fixture"]["requests"] > states["failed-search"]["requests"])
check("cancel_restored_applied", states["cancel-restored-fail"]["draft"]["query"] == states["cancel-restored-fail"]["applied"]["query"] == "fail")
check("monet_filter", states["monet-results-1440x900"]["visible_count"] == 2)
check("selection_details", states["selected-details"]["selected"] == 0)
check("save_and_error_presentations", states["saved-presentation"]["save_state"] == "saved" and states["save-error-presentation"]["save_state"] == "error")
for filename, size in [("01-after-1920x1080.png", (1920,1080)), ("06-after-1440x900.png", (1440,900))]:
    im = Image.open(out / filename).convert("RGB")
    check(filename + "_size", im.size == size)
    check(filename + "_no_black_bars", min(im.getpixel((2, im.height//2))) > 220 and min(im.getpixel((im.width-3, im.height//2))) > 220)
for filename in ["02-sort-popup.png", "02b-controls-draft.png", "03-loading.png", "04-empty.png", "05-error-retry.png", "07-selected-details.png", "08-save-error.png"]:
    check(filename + "_captured", (out/filename).exists() and (out/filename).stat().st_size > 10_000)

result = {"ok": all(checks.values()), "checks": checks, "screenshots": {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.glob("*.png"))}}
(out / "verification.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
raise SystemExit(0 if result["ok"] else 1)
