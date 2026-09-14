#!/usr/bin/env python3
"""Independent verifier for a sculpture_viewer playtest run. Never trusts the harness's own
summary: re-hashes every screenshot, re-reads pixels, and checks the logged states against the
Tenant contract and the prototype's numbers (created on first show, fills the page, the desktop
1:1 and centred with both windows, autoplay, pause, drag-orbit, wheel zoom, next, window drag,
catalogue drag and raise, frozen while hidden with the SubViewport quiet and every gesture
ignored, resumed intact, resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

BAR_H = 161 * 1920 / 4180.0
DESKTOP = (1440, 972)                 # desktop.gd DESKTOP_SIZE (the prototype's canvas)
CATALOGUE = (400, 400 * 5101 / 2276.0)
VIEWER = (800, 680)
VIEWER_SCALE = 0.985
VIEWPORT = (529, 486)                 # viewer.gd _build_3d_viewport
ZOOM_STEP = 0.45                      # viewer.gd _zoom_by per wheel notch
ORBIT_X, ORBIT_Y = 0.35, 0.25         # viewer.gd _on_viewport_input degrees per viewer pixel

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {}
for e in log:
    if e["event"] == "state":
        states.setdefault(e["label"], e)
viewer = {e["label"]: e for e in log if e["event"] == "viewer"}
gestures = {e["what"]: e for e in log if e["event"] in ("wheel", "drag", "click")}
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def near(a, b, tol):
    return abs(a - b) <= tol

def wrap(a):
    return (a + 180.0) % 360.0 - 180.0

def inside(x, y, r):
    return r["x"] <= x <= r["x"] + r["w"] and r["y"] <= y <= r["y"] + r["h"]

def same_rect(a, b, tol=0.5):
    return all(near(a[k], b[k], tol) for k in "xywh")

def same_view(a, b):
    return (near(a["yaw"], b["yaw"], 1e-3) and near(a["pitch"], b["pitch"], 1e-3) and near(a["distance"], b["distance"], 1e-3)
            and a["active_view"] == b["active_view"] and a["playing"] == b["playing"] and same_rect(a["viewer_rect"], b["viewer_rect"])
            and same_rect(a["catalogue_rect"], b["catalogue_rect"]) and a["front_window"] == b["front_window"])

def region(img, r):
    return img[int(r["y"]) + 2:int(r["y"] + r["h"]) - 2, int(r["x"]) + 2:int(r["x"] + r["w"]) - 2]

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 12, str(sorted(shots)))
check("viewer_screenshot_is_1920x1080", imgs["01-viewer.png"].shape[:2] == (1080, 1920), str(imgs["01-viewer.png"].shape))

# created lazily on first show, through the Shell
la = states["launch"]
check("no_viewer_tenant_at_launch", la["active"] == 4 and la["tabs"][2]["tenant"] is None and la["tabs"][2]["frozen"]
      and viewer["launch"]["code"] == "shell.tenant_missing")
sh = states["viewer"]; v = viewer["viewer-shown"]
check("click_viewer_tab_creates_and_shows_desktop", sh["active"] == 2 and sh["tabs"][2]["tenant"] == "ok" and sh["tabs"][2]["page_visible"]
      and not sh["tabs"][2]["frozen"] and v["ok"] and v["model_loaded"] and "3d viewer tab" in gestures, str(sh["tabs"][2]))
sz = v["size"]
check("tenant_fills_page_area", near(sz[0], 1920, 1) and near(sz[1], 1080 - BAR_H, 1.5), str(sz))

# the desktop: the prototype's 1440x972 canvas 1:1, centred; the catalogue at (72, 34), the viewer at (600, 34) x0.985
ox = (sz[0] - DESKTOP[0]) / 2; oy = BAR_H + (sz[1] - DESKTOP[1]) / 2
cr = v["catalogue_rect"]; vr = v["viewer_rect"]; pr = v["viewport_rect"]
check("desktop_is_1to1_and_centred", near(v["desktop_scale"], 1.0, 1e-6) and near(v["pointer_scale"], VIEWER_SCALE, 1e-3)
      and near(cr["x"], ox + 72, 1) and near(cr["y"], oy + 34, 1.5) and near(cr["w"], CATALOGUE[0], 0.5) and near(cr["h"], CATALOGUE[1], 0.5)
      and near(vr["x"], ox + 600, 1) and near(vr["y"], oy + 34, 1.5) and near(vr["w"], VIEWER[0] * VIEWER_SCALE, 0.5)
      and near(vr["h"], VIEWER[1] * VIEWER_SCALE, 0.5), f"catalogue {cr} viewer {vr}")
check("viewport_inside_viewer_window", inside(pr["x"], pr["y"], vr) and inside(pr["x"] + pr["w"], pr["y"] + pr["h"], vr)
      and near(pr["w"], VIEWPORT[0] * VIEWER_SCALE, 1) and near(pr["h"], VIEWPORT[1] * VIEWER_SCALE, 1), str(pr))
check("viewer_in_front_at_launch", v["front_window"] == "viewer-window" and not v["dragging"])

# autoplay: the orbit runs while shown (8 deg/s); the play/pause button stops it and the render stands still
p = viewer["paused"]; pl = viewer["paused-later"]; kp = gestures["play-pause button"]
check("autoplay_orbits_while_shown", v["playing"] and 0 < wrap(p["yaw"] - v["yaw"]) < 20 and p["ticks"] > v["ticks"],
      f"yaw {v['yaw']} -> {p['yaw']} over {p['ticks'] - v['ticks']} ticks")
check("pause_click_lands_on_button", inside(kp["x"], kp["y"], v["controls"]["play-pause"]))
check("pause_stops_orbit", not p["playing"] and p["last_animated_control"] == "play-pause" and near(pl["yaw"], p["yaw"], 1e-6)
      and near(pl["progress"], p["progress"], 1e-6) and pl["ticks"] > p["ticks"], f"yaw {p['yaw']} -> {pl['yaw']}")
check("paused_render_stands_still", float(np.abs(region(imgs["03-paused-later.png"], pr) - region(imgs["02-paused.png"], pr)).mean()) < 0.05,
      f"mean abs diff {float(np.abs(region(imgs['03-paused-later.png'], pr) - region(imgs['02-paused.png'], pr)).mean()):.3f}")

# drag-orbit: yaw by -dx * 0.35 and pitch by -dy * 0.25 in the viewer's own pixels (the global drag over pointer_scale)
d = gestures["drag-orbit inside the viewport"]; o = viewer["orbited"]; ps = p["pointer_scale"]
check("orbit_drag_lands_inside_viewport", inside(d["from"][0], d["from"][1], pr) and inside(d["to"][0], d["to"][1], pr))
exp_yaw = wrap(p["yaw"] - d["relative_total"][0] / ps * ORBIT_X)
exp_pitch = max(-55.0, min(45.0, p["pitch"] - d["relative_total"][1] / ps * ORBIT_Y))
check("drag_orbits_camera", near(wrap(o["yaw"] - exp_yaw), 0, 0.05) and near(o["pitch"], exp_pitch, 0.05) and near(o["distance"], p["distance"], 1e-6)
      and o["interaction_count"] > p["interaction_count"] and not o["playing"],
      f"yaw {p['yaw']} -> {o['yaw']} (expected {exp_yaw:.2f}), pitch {p['pitch']} -> {o['pitch']} (expected {exp_pitch:.2f})")
check("orbit_changes_render", float(np.abs(region(imgs["04-orbited.png"], pr) - region(imgs["03-paused-later.png"], pr)).mean()) > 3)

# wheel: 0.45 closer per notch up
w = gestures["wheel up x2 inside the viewport"]; z = viewer["zoomed"]
check("wheel_lands_inside_viewport", inside(w["x"], w["y"], pr) and w["up"])
check("wheel_zooms_camera_in", near(z["distance"], max(4.7, o["distance"] - ZOOM_STEP * w["count"]), 1e-3) and near(z["yaw"], o["yaw"], 1e-6)
      and near(z["pitch"], o["pitch"], 1e-6), f"distance {o['distance']} -> {z['distance']}")
check("zoom_changes_render", float(np.abs(region(imgs["05-zoomed.png"], pr) - region(imgs["04-orbited.png"], pr)).mean()) > 3)

# next: 30 degrees, the next view, its motion played
kn = gestures["next button"]; n = viewer["next"]
check("next_click_lands_on_button", inside(kn["x"], kn["y"], z["controls"]["next"]))
check("next_steps_30_degrees", near(wrap(n["yaw"] - z["yaw"] - 30.0), 0, 0.05) and n["active_view"] == (z["active_view"] + 1) % 12
      and n["last_animated_control"] == "next" and n["animation_count"] > z["animation_count"] and near(n["distance"], z["distance"], 1e-6),
      f"yaw {z['yaw']} -> {n['yaw']}, view {z['active_view']} -> {n['active_view']}")

# window drag by the viewer's top strip: the window and its viewport move by the drag; the view and the catalogue do not
t = gestures["drag the viewer window by its top strip"]; m = viewer["window-moved"]
check("top_strip_drag_starts_on_strip", inside(t["from"][0], t["from"][1], n["viewer_rect"])
      and n["viewer_rect"]["y"] + 4 * ps <= t["from"][1] <= n["viewer_rect"]["y"] + 36 * ps, f"from {t['from']} viewer {n['viewer_rect']}")
check("top_strip_drag_moves_viewer_window", near(m["viewer_rect"]["x"], n["viewer_rect"]["x"] + t["relative_total"][0], 0.5)
      and near(m["viewer_rect"]["y"], n["viewer_rect"]["y"] + t["relative_total"][1], 0.5)
      and near(m["viewport_rect"]["x"], n["viewport_rect"]["x"] + t["relative_total"][0], 0.5)
      and near(m["viewport_rect"]["y"], n["viewport_rect"]["y"] + t["relative_total"][1], 0.5)
      and near(m["yaw"], n["yaw"], 1e-6) and same_rect(m["catalogue_rect"], n["catalogue_rect"]) and not m["dragging"],
      f"{n['viewer_rect']} -> {m['viewer_rect']} by {t['relative_total']}")
check("window_drag_changes_page_pixels", hashes["06-window-moved.png"] != hashes["05-zoomed.png"])

# the catalogue: a drag on its picture raises it and moves it; a click on the viewer's strip raises the viewer again
t2 = gestures["drag the catalogue by its picture"]; c = viewer["catalogue-moved"]; e = viewer["before-hidden"]
check("catalogue_drag_starts_on_picture", inside(t2["from"][0], t2["from"][1], m["catalogue_rect"]))
check("catalogue_drag_raises_and_moves_it", c["front_window"] == "catalogue-window"
      and near(c["catalogue_rect"]["x"], m["catalogue_rect"]["x"] + t2["relative_total"][0], 0.5)
      and near(c["catalogue_rect"]["y"], m["catalogue_rect"]["y"] + t2["relative_total"][1], 0.5)
      and same_rect(c["viewer_rect"], m["viewer_rect"]) and near(c["yaw"], m["yaw"], 1e-6),
      f"{m['catalogue_rect']} -> {c['catalogue_rect']} by {t2['relative_total']}, front {c['front_window']}")
kv = gestures["viewer top strip"]
check("viewer_click_raises_it_without_moving", inside(kv["x"], kv["y"], c["viewer_rect"]) and e["front_window"] == "viewer-window"
      and same_rect(e["viewer_rect"], c["viewer_rect"]) and same_rect(e["catalogue_rect"], c["catalogue_rect"]))

# hidden: frozen page, no frames, no input, no rendering, events change nothing
sk = states["sketchbook"]; h0 = viewer["viewer-hidden"]; h1 = viewer["viewer-hidden-after-events"]
check("hidden_viewer_page_frozen", sk["active"] == 1 and sk["tabs"][2]["frozen"] and not sk["tabs"][2]["page_visible"])
check("hidden_tenant_process_stops", h1["ticks"] == h0["ticks"], f"ticks {h0['ticks']} -> {h1['ticks']} over 20 frames")
check("hidden_tenant_gets_no_input", h1["inputs"] == h0["inputs"] and "wheel up x2 inside the viewport while hidden" in gestures
      and "drag-orbit inside the viewport while hidden" in gestures and "next button while hidden" in gestures,
      f"inputs {h0['inputs']} -> {h1['inputs']}")
check("hidden_events_change_nothing", same_view(h1, e) and h1["animation_count"] == e["animation_count"]
      and h1["interaction_count"] == e["interaction_count"], f"{h1['yaw']} {h1['distance']} {h1['viewer_rect']}")
check("hidden_subviewport_update_disabled", h0["viewport_update_mode"] == 0 and h1["viewport_update_mode"] == 0,
      f"modes hidden {h0['viewport_update_mode']}, {h1['viewport_update_mode']}")
d0 = la["draw_calls"]; d1 = states["before-hidden"]["draw_calls"]; d2 = states["sketchbook-after-20-frames"]["draw_calls"]
check("hidden_subviewport_renders_nothing", d1 >= d0 + 10 and abs(d2 - d0) <= 2, f"draw calls: white page {d0}, viewer shown {d1}, hidden {d2}")

# resumed: same view and windows, frames run again, the SubViewport updates again
r0 = viewer["viewer-resumed"]; r1 = viewer["viewer-resumed-after-20-frames"]
check("viewer_resumes_with_state_intact", states["viewer-again"]["active"] == 2 and same_view(r0, e) and same_view(r1, e)
      and 0 <= r0["ticks"] - h1["ticks"] <= 6 and r1["ticks"] - r0["ticks"] >= 15,
      f"ticks frozen {h1['ticks']}, resumed {r0['ticks']} -> {r1['ticks']}")
check("resumed_subviewport_updates_again", r0["viewport_update_mode"] in (1, 4) and r1["viewport_update_mode"] in (1, 4),
      f"modes {r0['viewport_update_mode']}, {r1['viewport_update_mode']}")
check("resumed_pixels_identical_to_before_hiding", float(np.abs(imgs["10-resumed.png"] - imgs["08-before-hidden.png"]).mean()) < 0.5,
      f"mean abs diff {float(np.abs(imgs['10-resumed.png'] - imgs['08-before-hidden.png']).mean()):.3f}")

# resize: the desktop shrinks to fit the smaller page, both windows inside it; restore brings the launch scale back
rs = states["resized"]; rt = viewer["resized"]; sz2 = rt["size"]
scale2 = min(1.0, sz2[0] / DESKTOP[0], sz2[1] / DESKTOP[1])
check("resize_shrinks_desktop_to_fit", rs["window"] == [1440, 900] and near(sz2[0], 1440, 1) and near(sz2[1], 900 - 161 * 1440 / 4180.0, 1.5)
      and near(rt["desktop_scale"], scale2, 1e-3) and rt["desktop_scale"] < 1
      and rt["viewer_rect"]["x"] + rt["viewer_rect"]["w"] <= 1440.5 and rt["viewer_rect"]["y"] + rt["viewer_rect"]["h"] <= 900.5
      and rt["catalogue_rect"]["x"] + rt["catalogue_rect"]["w"] <= 1440.5 and rt["catalogue_rect"]["y"] + rt["catalogue_rect"]["h"] <= 900.5
      and near(rt["yaw"], r1["yaw"], 1e-6), f"tenant {sz2}, scale {rt['desktop_scale']}, viewer {rt['viewer_rect']}")
check("resized_screenshot_is_1440x900", imgs["11-resized.png"].shape[:2] == (900, 1440), str(imgs["11-resized.png"].shape))
check("restore_refits_back", states["restored"]["window"] == [1920, 1080] and near(viewer["restored"]["desktop_scale"], 1.0, 1e-6)
      and same_rect(viewer["restored"]["viewer_rect"], e["viewer_rect"]) and hashes["12-restored.png"] != hashes["11-resized.png"])

# pixels: the sculpture in the viewport, the catalogue picture, white outside the windows, white while hidden
first = imgs["01-viewer.png"]
vp = region(first, pr)
check("viewport_shows_sculpture", float(vp.std()) > 10 and float(vp.mean()) < 250, f"std {float(vp.std()):.1f} mean {float(vp.mean()):.1f}")
cat = region(first, cr)
check("catalogue_picture_drawn", float(cat.std()) > 10 and float(cat.mean()) < 250, f"std {float(cat.std()):.1f}")
above = first[int(BAR_H) + 2:int(cr["y"]) - 2, :]
right = first[int(BAR_H) + 2:, int(vr["x"] + vr["w"]) + 2:]
check("page_outside_windows_is_white", above.size > 0 and float(above.mean()) > 254 and right.size > 0 and float(right.mean()) > 254,
      f"above {float(above.mean()):.2f} right {float(right.mean()):.2f}")
hidden_page = imgs["09-hidden.png"][int(BAR_H) + 2:, :]
check("hidden_page_shows_plain_white_sketchbook", float(hidden_page.mean()) > 254, f"mean {float(hidden_page.mean()):.2f}")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
