#!/usr/bin/env python3
"""Independent verifier for a phone_page playtest run. Never trusts the harness's own summary:
re-reads the module's reference picture itself, re-hashes every screenshot, re-reads pixels, and
checks the logged states against the interface contract (created on first show, the picture at its
native size centred in the Page and drawn pixel for pixel, frozen while hidden, resumed intact,
re-centred on resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
REF = Image.open(HERE.parent / "assets" / "reference.png").convert("RGBA")
BAR_H = 161 * 1920 / 4180.0
INDEX = 6

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
pages, shells = {}, {}
for e in log:
    if e["event"] == "page":
        pages.setdefault(e["label"], e)
    if e["event"] == "shell":
        shells.setdefault(e["label"], e)
clicks = [e for e in log if e["event"] == "click"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def near(a, b, tol):
    return abs(a - b) <= tol

def over_white(ref):
    a = np.array(ref).astype(float)
    return (a[:, :, :3] * (a[:, :, 3:4] / 255.0) + 255.0 * (1 - a[:, :, 3:4] / 255.0)).round().astype(int)

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 6, str(sorted(shots)))
check("reference_is_the_owners_picture", REF.size == (269, 537), str(REF.size))

la, ls = pages["launch"], shells["launch"]
check("no_tenant_at_launch", ls["active"] == 4 and ls["tabs"][INDEX]["tenant"] is None and ls["tabs"][INDEX]["frozen"]
      and la["code"] == "shell.tenant_missing")
sh, a, b = shells["shown"], pages["shown"], pages["shown-after-20-frames"]
check("click_creates_and_shows_the_tenant", sh["active"] == INDEX and sh["tabs"][INDEX]["tenant"] == "ok" and sh["tabs"][INDEX]["page_visible"]
      and not sh["tabs"][INDEX]["frozen"] and not sh["switching"] and a["ok"], str(sh["tabs"][INDEX]))
sz = a["size"]
check("tenant_fills_page_area_above_the_bar", near(sz[0], 1920, 1) and near(sz[1], 1080 - BAR_H, 1.5), str(sz))
ir = a["image_rect"]
check("picture_at_native_size", a["image_size"] == list(REF.size) and ir["w"] == REF.size[0] and ir["h"] == REF.size[1], str(ir))
check("picture_centred_in_page", near(ir["x"], (sz[0] - ir["w"]) // 2, 1) and near(ir["y"], (sz[1] - ir["h"]) // 2, 1)
      and ir["x"] >= 0 and ir["y"] >= 0 and ir["x"] + ir["w"] <= sz[0] and ir["y"] + ir["h"] <= sz[1], f"{ir} in {sz}")
check("shown_tenant_process_runs", b["ticks"] - a["ticks"] >= 15, f"{a['ticks']} -> {b['ticks']}")

# pixels: the screenshot holds the reference, composited over white, pixel for pixel at its rect; white elsewhere
shot = imgs["02-phone.png"]
drawn = shot[int(ir["y"]):int(ir["y"] + ir["h"]), int(ir["x"]):int(ir["x"] + ir["w"])]
exp = over_white(REF)
diff = float(np.abs(drawn - exp).mean()) if drawn.shape == exp.shape else 999
check("picture_drawn_pixel_for_pixel", drawn.shape == exp.shape and diff < 0.5, f"mean abs diff {diff:.3f}")
check("picture_is_not_blank", float(exp.std()) > 20 and float(drawn.std()) > 20, f"std {float(drawn.std()):.1f}")
mask = np.ones(shot.shape[:2], bool); mask[int(ir["y"]):int(ir["y"] + ir["h"]), int(ir["x"]):int(ir["x"] + ir["w"])] = False
mask[int(1080 - BAR_H) - 2:] = False
check("page_white_around_the_picture", float(shot[mask].mean()) > 254, f"mean {float(shot[mask].mean()):.2f}")

hd, c, d = shells["hidden"], pages["hidden"], pages["hidden-after-20-frames"]
check("hidden_page_frozen", hd["active"] == 5 and hd["tabs"][INDEX]["frozen"] and not hd["tabs"][INDEX]["page_visible"] and not hd["switching"])
check("frozen_tenant_process_stops", d["ticks"] == c["ticks"], f"{c['ticks']} -> {d['ticks']} over 20 frames")
check("frozen_tenant_gets_no_input", d["inputs"] == c["inputs"] and any(e["event"] == "key" for e in log)
      and any(e["what"].startswith("click on the page area") for e in clicks), f"inputs {c['inputs']} -> {d['inputs']}")
check("hidden_page_shows_the_white_other_tab", float(imgs["03-hidden.png"][:int(1080 - BAR_H) - 2].mean()) > 254)

rs0, e, f = shells["resumed"], pages["resumed"], pages["resumed-after-20-frames"]
check("resumes_with_state_intact", rs0["active"] == INDEX and 0 <= e["ticks"] - d["ticks"] <= 8 and f["ticks"] - e["ticks"] >= 15
      and e["image_rect"] == ir, f"frozen at {d['ticks']}, resumed {e['ticks']} -> {f['ticks']}")
check("resumed_pixels_identical", float(np.abs(imgs["04-resumed.png"] - imgs["02-phone.png"]).mean()) < 0.5)

rz, rt = shells["resized"], pages["resized"]
sz2, ir2 = rt["size"], rt["image_rect"]; bar2 = 161 * 1440 / 4180.0
check("resize_recentres_the_picture", rz["window"] == [1440, 900] and near(sz2[0], 1440, 1) and near(sz2[1], 900 - bar2, 1.5)
      and ir2["w"] == REF.size[0] and ir2["h"] == REF.size[1] and near(ir2["x"], (sz2[0] - ir2["w"]) // 2, 1)
      and near(ir2["y"], (sz2[1] - ir2["h"]) // 2, 1) and ir2["y"] + ir2["h"] <= sz2[1], f"{ir2} in {sz2}")
check("resized_screenshot_is_1440x900", imgs["05-resized.png"].shape[:2] == (900, 1440), str(imgs["05-resized.png"].shape))
rshot = imgs["05-resized.png"]
rdrawn = rshot[int(ir2["y"]):int(ir2["y"] + ir2["h"]), int(ir2["x"]):int(ir2["x"] + ir2["w"])]
check("resized_picture_still_pixel_for_pixel", rdrawn.shape == exp.shape and float(np.abs(rdrawn - exp).mean()) < 0.5)
check("restore_refits_back", shells["restored"]["window"] == [1920, 1080] and pages["restored"]["image_rect"] == ir
      and hashes["06-restored.png"] != hashes["05-resized.png"])

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
