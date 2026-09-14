#!/usr/bin/env python3
"""Independent verifier for an atlas playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels, and checks the logged states against the Tenant
contract (created on first show, fills the page, the prototype's desktop composition — four raster
panels around the map window — a panel drag moves and raises it, a wheel over a panel leaves the
map alone, wheel zoom, drag-pan, title drag, the frame clamped to the page, edge resize, collapse,
lock, the keys with Map active, frozen while hidden with state and rendering quiet and every
gesture and key ignored, resumed intact, resize re-fitting the whole desktop).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

BAR_H = 161 * 1920 / 4180.0
DESKTOP = (1950, 1280)                  # atlas_window.gd DESKTOP_SIZE: the prototype's desktop
FRAME_RECT = (450, 58, 1158, 954)       # atlas_window.gd FRAME_RECT, in the desktop's pixels
PANELS = {"minimap": (10, 72, 413, 371), "itinerary": (18, 445, 397, 553),   # atlas_window.gd PANEL_RECTS
          "chat": (10, 1028, 540, 251), "notification": (1674, 1200, 272, 79)}
WHEEL_STEP = 1.18       # atlas.gd: one wheel notch
CYAN, PINK = (131, 229, 247), (255, 220, 233)   # the atlas's sea and land

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {}
for e in log:
    if e["event"] == "state":
        states.setdefault(e["label"], e)
atlas = {e["label"]: e for e in log if e["event"] == "atlas"}
gestures = {e["what"]: e for e in log if e["event"] in ("wheel", "drag", "click", "key")}
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def near(a, b, tol):
    return abs(a - b) <= tol

def same_view(x, y):
    return (near(x["zoom"], y["zoom"], 1e-6) and near(x["position"][0], y["position"][0], 1e-3)
            and near(x["position"][1], y["position"][1], 1e-3) and x["frame"] == y["frame"] and x["mode"] == y["mode"])

def colour_count(img, rgb, tol=6):
    return int((np.abs(img - np.array(rgb)).max(axis=2) <= tol).sum())

def fit(sz):
    """The desktop composition scaled to fit a page of size sz and centred (atlas_window.gd _fit_window)."""
    scale = min(sz[0] / DESKTOP[0], sz[1] / DESKTOP[1])
    origin = (round((sz[0] - DESKTOP[0] * scale) / 2), round((sz[1] - DESKTOP[1] * scale) / 2))
    def rect(r):
        return {"x": round(origin[0] + r[0] * scale), "y": round(origin[1] + r[1] * scale), "w": round(r[2] * scale), "h": round(r[3] * scale)}
    return scale, rect

def rect_near(a, b, tol=1):
    return all(near(a[k], b[k], tol) for k in "xywh")

def overlaps(a, b):
    return a["x"] < b["x"] + b["w"] and b["x"] < a["x"] + a["w"] and a["y"] < b["y"] + b["h"] and b["y"] < a["y"] + a["h"]

def inside(p, r):
    return r["x"] < p[0] < r["x"] + r["w"] and r["y"] < p[1] < r["y"] + r["h"]

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 14, str(sorted(shots)))
check("map_screenshot_is_1920x1080", imgs["01-map.png"].shape[:2] == (1080, 1920), str(imgs["01-map.png"].shape))

# created lazily on first show, through the Shell
la = states["launch"]
check("no_map_tenant_at_launch", la["active"] == 4 and la["tabs"][0]["tenant"] is None and la["tabs"][0]["frozen"]
      and atlas["launch"]["code"] == "shell.tenant_missing")
mp = states["map"]; a = atlas["map-shown"]
check("click_map_creates_and_shows_atlas", mp["active"] == 0 and mp["tabs"][0]["tenant"] == "ok" and mp["tabs"][0]["page_visible"]
      and not mp["tabs"][0]["frozen"] and a["ok"] and "map tab" in gestures, str(mp["tabs"][0]))
sz = a["size"]
check("tenant_fills_page_area", near(sz[0], 1920, 1) and near(sz[1], 1080 - BAR_H, 1.5), str(sz))
ORIGIN = (a["frame_global"]["x"] - a["frame"]["x"], a["frame_global"]["y"] - a["frame"]["y"])   # the tenant's pixels on the root

def to_global(r):
    return {"x": ORIGIN[0] + r["x"], "y": ORIGIN[1] + r["y"], "w": r["w"], "h": r["h"]}

# the desktop composition: the map window and the four panels at the prototype's reference rects, scaled to fit and centred
fr = a["frame"]; scale, ref = fit(sz)
check("window_at_reference_rect", rect_near(fr, ref(FRAME_RECT)) and fr["x"] >= 0 and fr["y"] >= 0
      and fr["x"] + fr["w"] <= sz[0] and fr["y"] + fr["h"] <= sz[1], f"frame {fr} expected {ref(FRAME_RECT)}")
cs = a["chrome_scale"]
check("chrome_scale_from_desktop_scale", near(cs, min(1.0, FRAME_RECT[2] / 1724.0 * scale), 1e-6), str(cs))
pa = a["panels"]
check("four_panels_at_reference_composition", set(pa) == set(PANELS) and all(rect_near(pa[i], ref(PANELS[i])) for i in PANELS)
      and all(pa[i]["x"] >= 0 and pa[i]["y"] >= 0 and pa[i]["x"] + pa[i]["w"] <= sz[0] and pa[i]["y"] + pa[i]["h"] <= sz[1] for i in PANELS),
      str(pa))
check("minimap_over_itinerary_over_chat_at_left_map_at_centre_notification_bottom_right",
      pa["minimap"]["y"] + pa["minimap"]["h"] <= pa["itinerary"]["y"] and pa["itinerary"]["y"] + pa["itinerary"]["h"] <= pa["chat"]["y"]
      and max(pa[i]["x"] + pa[i]["w"] for i in ("minimap", "itinerary")) <= fr["x"] and pa["chat"]["y"] >= fr["y"] + fr["h"]
      and pa["notification"]["x"] >= fr["x"] + fr["w"] and pa["notification"]["y"] >= fr["y"] + fr["h"])
windows = dict(pa, map=fr)
check("nothing_overlaps_at_launch", not any(overlaps(windows[i], windows[j]) for i in windows for j in windows if i < j))
check("stack_opens_with_map_on_top", a["stack"][-1] == "map" and set(a["stack"]) == set(PANELS) | {"map"} and a["moving_window"] == "", str(a["stack"]))
mr = a["map_rect"]; fg = a["frame_global"]
check("map_body_inside_frame_below_bar", fg["y"] >= BAR_H - 0.5 and mr["x"] >= fg["x"] and mr["y"] >= fg["y"]
      and mr["x"] + mr["w"] <= fg["x"] + fg["w"] and mr["y"] + mr["h"] <= fg["y"] + fg["h"]
      and near(a["viewport"][0], mr["w"], 1) and near(a["viewport"][1], mr["h"], 1), f"map {mr} frame {fg} viewport {a['viewport']}")
check("atlas_opens_on_world_view", a["mode"] == "atlas" and near(a["zoom_ratio"], 1.0, 1e-3) and near(a["zoom"], a["zoom_min"], 1e-6),
      f"zoom {a['zoom']} min {a['zoom_min']}")

# a panel drag: the notification moves by the drag onto the map body and comes to the top of the stack; nothing else moves
pd = gestures["drag the notification panel onto the map"]; pn = atlas["panel-moved"]
check("panel_drag_starts_on_the_panel", inside(pd["from"], to_global(pa["notification"])), f"from {pd['from']} panel {to_global(pa['notification'])}")
check("panel_drag_moves_it_by_the_drag", near(pn["panels"]["notification"]["x"], pa["notification"]["x"] + pd["relative_total"][0], 0.5)
      and near(pn["panels"]["notification"]["y"], pa["notification"]["y"] + pd["relative_total"][1], 0.5)
      and pn["panels"]["notification"]["w"] == pa["notification"]["w"] and pn["panels"]["notification"]["h"] == pa["notification"]["h"]
      and pn["action"] == "" and pn["moving_window"] == "", f"{pa['notification']} -> {pn['panels']['notification']} by {pd['relative_total']}")
check("panel_drag_moves_nothing_else", all(pn["panels"][i] == pa[i] for i in ("minimap", "itinerary", "chat")) and same_view(pn, a)
      and pn["map_rect"] == mr and not pn["collapsed"] and not pn["locked"])
check("pressed_panel_comes_to_the_top", pn["stack"][-1] == "notification" and pn["stack"][-2] == "map" and len(pn["stack"]) == 5, str(pn["stack"]))
moved = to_global(pn["panels"]["notification"])
check("moved_panel_lies_over_the_map_body", moved["x"] >= mr["x"] and moved["y"] >= mr["y"] and moved["x"] + moved["w"] <= mr["x"] + mr["w"]
      and moved["y"] + moved["h"] <= mr["y"] + mr["h"], f"panel {moved} map {mr}")

# a wheel over the panel: swallowed, the map beneath does not zoom
wp = gestures["wheel up x3 over the notification panel"]; wpa = atlas["wheel-over-panel"]
check("wheel_over_panel_lands_on_it", inside((wp["x"], wp["y"]), moved) and wp["up"] and wp["count"] == 3)
check("wheel_over_panel_does_not_zoom_map", same_view(wpa, pn) and wpa["panels"] == pn["panels"], f"zoom {pn['zoom']} -> {wpa['zoom']}")

# wheel zoom at the map's centre: zoom x 1.18 per notch, camera stays put
w = gestures["wheel up x3 at map centre"]; b = atlas["zoomed"]
check("wheel_lands_inside_map", inside((w["x"], w["y"]), mr) and not inside((w["x"], w["y"]), moved))
check("wheel_zooms_in_at_centre", w["up"] and near(b["zoom"] / a["zoom"], WHEEL_STEP ** w["count"], 0.01)
      and near(b["position"][0], a["position"][0], 1) and near(b["position"][1], a["position"][1], 1),
      f"zoom {a['zoom']:.4f} -> {b['zoom']:.4f} (x{b['zoom'] / a['zoom']:.3f}), position {a['position']} -> {b['position']}")
check("zoom_unlocks_vertical_pan", a["vertical_pan_locked"] and not b["vertical_pan_locked"])

# drag-pan: the camera moves against the drag, divided by the zoom
d = gestures["drag-pan inside the map"]; c = atlas["panned"]
exp = [b["position"][i] - d["relative_total"][i] / b["zoom"] for i in range(2)]
check("drag_pans_camera_by_drag_over_zoom", near(c["position"][0], exp[0], 1.5) and near(c["position"][1], exp[1], 1.5)
      and near(c["zoom"], b["zoom"], 1e-6) and c["frame"] == b["frame"] and c["panels"] == pn["panels"],
      f"expected {[round(v, 1) for v in exp]}, got {[round(v, 1) for v in c['position']]}")

# title-bar drag: the frame moves by the drag and comes to the top, the map view and the panels do not move
t = gestures["drag the map window by its title bar"]; e = atlas["window-moved"]
check("title_drag_starts_on_title_bar", fg["x"] + 90 * cs < t["from"][0] < fg["x"] + fg["w"] - 100 * cs
      and fg["y"] + 30 * cs <= t["from"][1] < fg["y"] + 94 * cs, f"from {t['from']} frame {fg}")
check("title_drag_moves_window", near(e["frame"]["x"], c["frame"]["x"] + t["relative_total"][0], 0.5)
      and near(e["frame"]["y"], c["frame"]["y"] + t["relative_total"][1], 0.5) and e["frame"]["w"] == c["frame"]["w"]
      and near(e["zoom"], c["zoom"], 1e-6) and e["position"] == c["position"] and e["action"] == "" and e["panels"] == c["panels"]
      and e["stack"][-1] == "map",
      f"{c['frame']} -> {e['frame']} by {t['relative_total']}, stack {e['stack']}")
check("still_on_map_tab_after_window_drag", states["window-moved"]["active"] == 0)

# the frame stops at the page's edge: a drag far past the bottom-right corner lands it flush with both edges
t2 = gestures["drag the title bar past the page's bottom-right corner"]; cl = atlas["window-clamped"]
check("window_drag_clamps_to_page_edge", t2["to"][0] > sz[0] and t2["to"][1] > BAR_H + sz[1]
      and near(cl["frame"]["x"], sz[0] - cl["frame"]["w"], 0.5) and near(cl["frame"]["y"], sz[1] - cl["frame"]["h"], 0.5)
      and cl["frame"]["w"] == e["frame"]["w"] and cl["frame"]["h"] == e["frame"]["h"] and cl["frame"] != e["frame"] and cl["action"] == "",
      f"page {sz}, frame {cl['frame']}")

# edge resize: dragging the bottom-right corner inward shrinks the frame in place; the map body and its SubViewport follow
t3 = gestures["drag the frame's bottom-right corner inward"]; rz = atlas["window-resized"]
check("corner_drag_resizes_frame_in_place", rz["frame"]["x"] == cl["frame"]["x"] and rz["frame"]["y"] == cl["frame"]["y"]
      and near(rz["frame"]["w"], cl["frame"]["w"] + t3["relative_total"][0], 0.5) and near(rz["frame"]["h"], cl["frame"]["h"] + t3["relative_total"][1], 0.5)
      and near(rz["chrome_scale"], cs, 1e-6) and rz["action"] == "", f"{cl['frame']} -> {rz['frame']} by {t3['relative_total']}")
check("map_body_follows_the_resize", near(rz["map_rect"]["w"], rz["frame"]["w"] - round(72 * cs), 1) and near(rz["map_rect"]["h"], rz["frame"]["h"] - round(136 * cs), 1)
      and near(rz["viewport"][0], rz["map_rect"]["w"], 1) and near(rz["viewport"][1], rz["map_rect"]["h"], 1)
      and near(rz["zoom"], cl["zoom"], 1e-6) and rz["position"] == cl["position"], f"map {rz['map_rect']} viewport {rz['viewport']}")

# collapse: the left button folds the frame to its title bar and hides the map; again expands it to the size it had
co = atlas["collapsed"]; ex = atlas["expanded"]; k_c = gestures["collapse button"]
check("collapse_click_lands_on_left_button", rz["frame_global"]["x"] + 44 * cs <= k_c["x"] <= rz["frame_global"]["x"] + 88 * cs
      and rz["frame_global"]["y"] + 42 * cs <= k_c["y"] <= rz["frame_global"]["y"] + 86 * cs)
check("collapse_folds_window_to_title_bar", co["collapsed"] and near(co["frame"]["h"], round(136 * cs), 0.5) and co["frame"]["w"] == rz["frame"]["w"]
      and co["frame"]["x"] == rz["frame"]["x"] and co["frame"]["y"] == rz["frame"]["y"], str(co["frame"]))
check("collapse_again_expands_to_former_size", not ex["collapsed"] and ex["frame"] == rz["frame"] and same_view(ex, rz))

# lock: the right button locks the frame; a title-bar drag moves nothing; again unlocks
lk = atlas["locked"]; ld = atlas["locked-drag"]; ul = atlas["unlocked"]; k_l = gestures["lock button"]
check("lock_click_lands_on_right_button", ex["frame_global"]["x"] + ex["frame"]["w"] - 86 * cs <= k_l["x"] <= ex["frame_global"]["x"] + ex["frame"]["w"] - 42 * cs)
check("lock_holds_window_under_title_drag", lk["locked"] and "drag the title bar while locked" in gestures and ld["locked"]
      and ld["frame"] == lk["frame"] and ld["action"] == "" and same_view(ld, lk), str(ld["frame"]))
check("lock_again_unlocks", not ul["locked"] and ul["frame"] == lk["frame"])

# the keys with Map active (ticket #30 acceptance 4): + zooms x1.3 at the centre, Right pans 100 world px over the zoom,
# F shows the region's full sheet and F again restores the view, Home resets to the fitted world view
k0, k1, k2, k3, k4, k5 = (atlas[l] for l in ("pre-keys", "key-plus", "key-right", "key-f-sheet", "key-f-atlas", "key-home"))
check("keys_sent_with_map_active", all(k in gestures for k in ("+ key", "right arrow", "F key", "F key (again)", "Home key")))
check("plus_key_zooms_in", near(k1["zoom"] / k0["zoom"], 1.3, 0.01) and near(k1["position"][0], k0["position"][0], 1)
      and near(k1["position"][1], k0["position"][1], 1), f"zoom {k0['zoom']:.4f} -> {k1['zoom']:.4f}")
check("right_key_pans_east", near(k2["position"][0] - k1["position"][0], 100 / k1["zoom"], 0.5) and near(k2["position"][1], k1["position"][1], 1e-3)
      and near(k2["zoom"], k1["zoom"], 1e-6), f"dx {k2['position'][0] - k1['position'][0]:.2f} expected {100 / k1['zoom']:.2f}")
check("f_key_shows_sheet_and_again_returns", k3["mode"] == "sheet" and k4["mode"] == "atlas" and near(k4["zoom"], k2["zoom"], 1e-6)
      and near(k4["position"][0], k2["position"][0], 1e-3) and near(k4["position"][1], k2["position"][1], 1e-3), f"{k3['mode']} -> {k4['mode']}")
check("home_key_resets_to_world_view", k5["mode"] == "atlas" and near(k5["zoom_ratio"], 1.0, 1e-3) and near(k5["zoom"], k5["zoom_min"], 1e-6)
      and near(k5["position"][0], 2240, 1e-3) and near(k5["position"][1], 1350, 1e-3), f"zoom {k5['zoom']} min {k5['zoom_min']} position {k5['position']}")
e = atlas["before-hidden"]
check("wheel_after_home_leaves_a_zoomed_view", near(e["zoom"] / k5["zoom"], WHEEL_STEP ** 2, 0.01) and hashes["10-before-hidden.png"] != hashes["09-key-home.png"])

# hidden: frozen page, no frames, no input, no rendering, events change nothing
sk = states["sketchbook"]; h0 = atlas["map-hidden"]; h1 = atlas["map-hidden-after-events"]
check("hidden_map_page_frozen", sk["active"] == 1 and sk["tabs"][0]["frozen"] and not sk["tabs"][0]["page_visible"])
check("hidden_tenant_process_stops", h1["ticks"] == h0["ticks"], f"ticks {h0['ticks']} -> {h1['ticks']} over 20 frames")
hidden_keys = [atlas[l + " while hidden"] for l in ("key-plus", "key-right", "key-f-sheet", "key-f-atlas", "key-home")]
check("hidden_tenant_gets_no_input", h1["inputs"] == h0["inputs"]
      and "wheel up x3 at the map's centre while hidden" in gestures and "drag where the map was while hidden" in gestures
      and all(k + " while hidden" in gestures for k in ("+ key", "right arrow", "F key", "F key (again)", "Home key")),
      f"inputs {h0['inputs']} -> {h1['inputs']}")
check("hidden_events_change_nothing", same_view(h1, e) and h1["collapsed"] == e["collapsed"] and h1["locked"] == e["locked"]
      and h1["panels"] == e["panels"] and h1["stack"] == e["stack"], f"{h1['zoom']} {h1['position']} {h1['frame']}")
check("hidden_keys_change_nothing", all(same_view(k, e) and k["inputs"] == h0["inputs"] for k in hidden_keys),
      str([(k["mode"], round(k["zoom"], 4)) for k in hidden_keys]))
check("hidden_subviewport_update_disabled", h0["viewport_update_mode"] == 0 and h1["viewport_update_mode"] == 0
      and e["viewport_update_mode"] == 4, f"modes shown {e['viewport_update_mode']} hidden {h0['viewport_update_mode']}")
d0 = la["draw_calls"]; d1 = states["before-hidden"]["draw_calls"]; d2 = states["sketchbook-after-20-frames"]["draw_calls"]
check("hidden_subviewport_renders_nothing", d1 >= d0 + 10 and abs(d2 - d0) <= 2,
      f"draw calls: white page {d0}, map shown {d1}, map hidden {d2}")

# resumed: same view, frames run again
r0 = atlas["map-resumed"]; r1 = atlas["map-resumed-after-20-frames"]
check("map_resumes_with_state_intact", states["map-again"]["active"] == 0 and same_view(r0, e) and same_view(r1, e)
      and r0["panels"] == e["panels"] and r1["panels"] == e["panels"]
      and 0 <= r0["ticks"] - h1["ticks"] <= 6 and r1["ticks"] - r0["ticks"] >= 15,
      f"ticks frozen {h1['ticks']}, resumed {r0['ticks']} -> {r1['ticks']}")
check("resumed_subviewport_updates_again", r0["viewport_update_mode"] == 4 and r1["viewport_update_mode"] == 4)

# resize: the tenant fills the smaller page and re-fits the whole desktop — window and panels back at the reference composition
rs = states["resized"]; rt = atlas["resized"]
sz2 = rt["size"]; fr2 = rt["frame"]; scale2, ref2 = fit(sz2)
check("resize_refits_tenant_and_window", rs["window"] == [1440, 900] and near(sz2[0], 1440, 1)
      and near(sz2[1], 900 - 161 * 1440 / 4180.0, 1.5) and rect_near(fr2, ref2(FRAME_RECT))
      and fr2["x"] + fr2["w"] <= sz2[0] and fr2["y"] + fr2["h"] <= sz2[1] and near(rt["zoom"], r1["zoom"], 1e-6),
      f"tenant {sz2}, frame {fr2} expected {ref2(FRAME_RECT)}")
check("resize_refits_panels_to_reference_composition", all(rect_near(rt["panels"][i], ref2(PANELS[i])) for i in PANELS)
      and rt["panels"]["notification"] != r1["panels"]["notification"], str(rt["panels"]))
check("resized_screenshot_is_1440x900", imgs["13-resized.png"].shape[:2] == (900, 1440), str(imgs["13-resized.png"].shape))
check("restore_refits_back", states["restored"]["window"] == [1920, 1080] and atlas["restored"]["frame"] == a["frame"]
      and atlas["restored"]["panels"] == pa and hashes["14-restored.png"] != hashes["13-resized.png"])

# pixels: the map's sea and land inside the map body, the frame's dark lettering above it, the panels' raster art,
# white where nothing lies, changes per gesture
def region(img, r):
    return img[int(r["y"]) + 2:int(r["y"] + r["h"]) - 2, int(r["x"]) + 2:int(r["x"] + r["w"]) - 2]
body = region(imgs["01-map.png"], mr)
check("map_body_shows_sea_and_land", colour_count(body, CYAN) > body.shape[0] * body.shape[1] * 0.2
      and colour_count(body, PINK) > body.shape[0] * body.shape[1] * 0.02,
      f"cyan {colour_count(body, CYAN)} pink {colour_count(body, PINK)} of {body.shape[0] * body.shape[1]}")
title_band = imgs["01-map.png"][int(fg["y"] + 30 * cs):int(fg["y"] + 94 * cs), int(fg["x"] + 90 * cs):int(fg["x"] + fg["w"] - 100 * cs)]
check("frame_title_bar_drawn", (title_band.max(axis=2) < 100).sum() > 50, f"dark px {(title_band.max(axis=2) < 100).sum()}")
panel_ink = {i: int((region(imgs["01-map.png"], to_global(pa[i])).max(axis=2) < 100).sum()) for i in PANELS}
panel_colour = {i: float((region(imgs["01-map.png"], to_global(pa[i])).min(axis=2) < 240).mean()) for i in PANELS}
check("panels_drawn_with_their_raster_art", all(panel_ink[i] > 200 for i in PANELS) and all(panel_colour[i] > 0.1 for i in PANELS),
      f"dark px {panel_ink}, non-white fraction { {i: round(v, 3) for i, v in panel_colour.items()} }")
outside = imgs["01-map.png"][int(BAR_H) + 2:int(fg["y"]) - 2, int(fg["x"]):int(fg["x"] + fg["w"])]
check("page_above_window_is_white", outside.size > 0 and float(outside.mean()) > 254, f"mean {float(outside.mean()):.2f}")
before_move = region(imgs["01-map.png"], moved); after_move = region(imgs["02-panel-moved.png"], moved)
check("moved_panel_draws_over_the_map", (before_move.max(axis=2) < 100).sum() < 20 and (after_move.max(axis=2) < 100).sum() > 200
      and hashes["02-panel-moved.png"] != hashes["01-map.png"],
      f"dark px where it landed: before {(before_move.max(axis=2) < 100).sum()}, after {(after_move.max(axis=2) < 100).sum()}")
check("zoom_changes_map_pixels", float(np.abs(region(imgs["03-zoomed.png"], mr) - region(imgs["02-panel-moved.png"], mr)).mean()) > 3)
check("pan_changes_map_pixels", float(np.abs(region(imgs["04-panned.png"], mr) - region(imgs["03-zoomed.png"], mr)).mean()) > 3)
check("window_drag_changes_page_pixels", hashes["05-window-moved.png"] != hashes["04-panned.png"])
cg = cl["frame_global"]
check("clamped_window_touches_page_corner", near(cg["x"] + cg["w"], 1920, 0.5) and near(cg["y"] + cg["h"], 1080, 0.5)
      and hashes["06-window-clamped.png"] != hashes["05-window-moved.png"], f"frame ends at {cg['x'] + cg['w']}, {cg['y'] + cg['h']}")
rg = rz["frame_global"]
freed = imgs["07-window-resized.png"][int(rg["y"] + rg["h"]) + 2:int(cg["y"] + cg["h"]) - 2, int(rg["x"]) + 2:int(rg["x"] + rg["w"]) - 2]
check("resize_frees_white_page_below_window", freed.size > 0 and float(freed.mean()) > 254, f"mean {float(freed.mean()):.2f}")
cog = co["frame_global"]
under = imgs["08-collapsed.png"][int(cog["y"] + cog["h"]) + 2:int(rg["y"] + rg["h"]) - 2, int(cog["x"]) + 2:int(cog["x"] + cog["w"]) - 2]
check("collapsed_window_leaves_white_below_its_bar", under.size > 0 and float(under.mean()) > 254
      and hashes["08-collapsed.png"] != hashes["07-window-resized.png"], f"mean {float(under.mean()):.2f}")
hidden_page = imgs["11-hidden.png"][int(BAR_H) + 2:, :]
check("hidden_page_shows_plain_white_sketchbook", float(hidden_page.mean()) > 254, f"mean {float(hidden_page.mean()):.2f}")
check("resumed_pixels_identical_to_before_hiding", float(np.abs(imgs["12-resumed.png"] - imgs["10-before-hidden.png"]).mean()) < 0.5,
      f"mean abs diff {float(np.abs(imgs['12-resumed.png'] - imgs['10-before-hidden.png']).mean()):.3f}")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL", f"({len(results)} checks)")
sys.exit(0 if ok else 1)
