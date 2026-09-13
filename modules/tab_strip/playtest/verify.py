#!/usr/bin/env python3
"""Independent verifier for a tab_strip playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels, and checks the logged states against the
interface contract (timings, counts, labels, page visibility). usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

out = Path(sys.argv[1])
rep = json.loads((out / "report.json").read_text())
log = rep["log"]
states = {e["label"]: e for e in log if e["event"] == "state"}
signals = [e for e in log if e["event"] == "signal"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

# screenshots exist, are distinct where they must be, and are re-hashed here
shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 8, str(sorted(shots)))
check("mid_grow_differs_from_initial", hashes["01-initial.png"] != hashes["02-mid-grow.png"])
check("connecting_differs_from_mid_grow", hashes["02-mid-grow.png"] != hashes["03-connecting.png"])
check("blank_page_differs_from_connecting", hashes["03-connecting.png"] != hashes["04-blank-page.png"])

# tab counts and labels
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

# signal timing against the interface constants (press 0.1, grow 0.4, connecting 0.95)
def t(sig, idx=1):
    return next((e["t_ms"] for e in signals if e["signal"] == sig and e["index"] == idx), None)
grow = (t("tab_settled") or 0) - (t("tab_opened") or 0); title = (t("tab_titled") or 0) - (t("tab_settled") or 0)
check("grow_took_about_500ms", 430 <= grow <= 650, f"{grow} ms")
check("title_swap_after_about_950ms", 880 <= title <= 1100, f"{title} ms")

# page switching by clicking tabs
check("click_tab0_shows_page0", states["selected-0"]["active"] == 0 and states["selected-0"]["tabs"][0]["page_visible"]
      and not states["selected-0"]["tabs"][1]["page_visible"])
check("click_tab1_shows_page1", states["selected-1"]["active"] == 1 and states["selected-1"]["tabs"][1]["page_visible"])
check("third_tab_opened_from_moved_stub", states["third-tab"]["count"] == 3 and states["third-tab"]["tabs"][2]["label"] == "blank_page")
full = states["full-row"]; fill = next(e for e in log if e["event"] == "fill")
check("row_fills_then_refuses", full["count"] >= 4 and "refused" in fill["result"], fill["result"])
check("full_row_tabs_shrunk_not_overflowed", all(tb["x"] + tb["w"] <= 1631 + 1 for tb in full["tabs"]) and full["tabs"][-1]["w"] < 560,
      f"last w={full['tabs'][-1]['w']:.0f}")

# pixels: the first tab's region is identical between initial and blank-page (it never moves)
sc = 1680 / 3135
def region(img, x0, y0, x1, y1):
    return img[int(y0 * sc):int(y1 * sc), int(x0 * sc):int(x1 * sc)]
a = region(imgs["01-initial.png"], 261, 27, 700, 161); b = region(imgs["04-blank-page.png"], 261, 27, 700, 161)
check("first_tab_pixels_identical", float(np.abs(a - b).mean()) < 0.5, f"mean abs diff {float(np.abs(a-b).mean()):.2f}")
c = region(imgs["01-initial.png"], 780, 27, 1330, 161); d = region(imgs["04-blank-page.png"], 780, 27, 1330, 161)
check("new_tab_pixels_changed", float(np.abs(c - d).mean()) > 5, f"mean abs diff {float(np.abs(c-d).mean()):.2f}")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
