#!/usr/bin/env python3
"""Independent verifier for a collection_page playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels against the prototype's own files (the eight window
screenshots, the reference sheet's footer with "number of works: 12" and its seven artworks) and
checks the logged states against the interface contract: every window at the reference's place,
a title drag moves and raises a window, a body drag does not, only the topmost window under the
pointer takes a drag, the wheel scrolls the artworks, the corner resizes the viewer, a drag stops
at the page's edge, frozen while hidden with every gesture ignored, resumed intact, re-fitted on
a resize.
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
MODULE = HERE.parent
# desktop.gd PANELS and viewer.gd's frame, in the reference's 1944x1280 review coordinates
PANELS = {"equipment": (12, 20, 482, 254, 30), "options": (12, 291, 493, 213, 30), "filters": (12, 522, 508, 231, 32),
          "status": (0, 762, 499, 63, 31), "trade": (12, 828, 492, 213, 31), "chat": (6, 1050, 505, 230, 29),
          "party": (530, 709, 319, 312, 38), "bottom": (519, 1221, 1403, 54, 54)}
VIEWER = (529, 20, 1393, 658)
MINIMUM = (531, 250)
WORKS = [(125, 200, 1215, 1240), (1374, 200, 763, 1118), (2174, 198, 833, 1126), (3030, 250, 1350, 1022),
         (125, 1493, 1215, 805), (2174, 1384, 1165, 932), (3475, 1276, 905, 1075)]
FOOTER = (44, 2580, 900, 190)   # the source rect holding "number of works: 12"
KEYED = 32                       # remove-pink.gdshader keys the outer 32 source pixels
DESKTOP = (1944, 1280)
VIEWER_FAR_GAP = (22, 602)       # viewer.gd: the viewer's right and bottom edges from the desktop's
MARGINS = (0, 20, 22, 0)         # the reference desktop's left, top, right, bottom margins

def place(n, f, sz):
    """A HUD window's rect under the fill rule (#63, desktop.gd arrange): scaled, anchored to its nearest page edges."""
    x, y, w, h = PANELS[n][:4]
    px, py = x * f, y * f
    if x + w / 2 > DESKTOP[0] / 2:
        px = sz[0] - (DESKTOP[0] - x) * f
    if y + h / 2 > DESKTOP[1] / 2:
        py = sz[1] - (DESKTOP[1] - y) * f
    return px, py, w * f, h * f

def viewer_place(f, sz):
    """The viewer under the fill rule (#63, viewer.gd _fit): its top and right run to the page edge minus the native margin."""
    w = max(sz[0] - VIEWER_FAR_GAP[0] * f - VIEWER[0] * f, MINIMUM[0]); h = max(sz[1] - VIEWER_FAR_GAP[1] * f - VIEWER[1] * f, MINIMUM[1])
    return min(VIEWER[0] * f, sz[0] - w), min(VIEWER[1] * f, sz[1] - h), w, h

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
pages = {}
for e in log:
    if e["event"] == "page":
        pages.setdefault(e["label"], e)
shells = {}
for e in log:
    if e["event"] == "shell":
        shells.setdefault(e["label"], e)
gestures = {e["what"]: e for e in log if e["event"] in ("wheel", "drag", "click")}
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def near(a, b, tol=1.0):
    return abs(a - b) <= tol

def rect_near(r, x, y, w, h, tol=1.0):
    return near(r["x"], x, tol) and near(r["y"], y, tol) and near(r["w"], w, tol) and near(r["h"], h, tol)

def win(p, name):
    return next(w for w in p["windows"] if w["name"] == name)

def order(p):
    return [w["name"] for w in p["windows"]]

def same_rects(p, q, skip=()):
    return all(win(p, n)["rect"] == win(q, n)["rect"] for n in PANELS if n not in skip) and \
        (("viewer" in skip) or win(p, "viewer")["rect"] == win(q, "viewer")["rect"])

def region(img, p, r):
    g = p["page_global"]
    x0, y0 = int(round(g["x"] + r["x"])), int(round(g["y"] + r["y"]))
    return img[y0:y0 + int(round(r["h"])), x0:x0 + int(round(r["w"]))]

def looks_like(shot, source, shrink=4):
    """Mean absolute difference of a screenshot region and its source pixels, both box-shrunk so the
    filter each was scaled with does not matter."""
    h, w = shot.shape[:2]
    if h < shrink or w < shrink:
        return 255.0
    a = np.array(Image.fromarray(shot.astype(np.uint8)).resize((w // shrink, h // shrink), Image.BOX)).astype(int)
    b = np.array(source.convert("RGB").resize((w // shrink, h // shrink), Image.BOX)).astype(int)
    return float(np.abs(a - b).mean())

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 12, str(sorted(shots)))
check("launch_screenshot_is_1920x1080", imgs["01-launch.png"].shape[:2] == (1080, 1920), str(imgs["01-launch.png"].shape))
check("gesture_screenshots_all_differ", len(set(hashes[f] for f in shots if f != "09-resumed.png")) == len(shots) - 1)

# 1. launch: the desktop is the Collection Tenant and fills the page
ls, la = shells["launch"], pages["launch"]
check("collection_active_with_this_tenant", ls["active"] == 4 and ls["tabs"][4]["tenant"] == "ok" and ls["tabs"][4]["page_visible"] and la["ok"])
bar_h = 161 * 1920 / 4180.0
sz = la["size"]
check("tenant_fills_page_area", near(sz[0], 1920) and near(sz[1], 1080 - bar_h, 1.5) and near(la["page_global"]["h"], sz[1]), str(sz))
f = min(sz[0] / 1944.0, sz[1] / 1280.0)
check("factor_fits_reference_to_page", near(la["factor"], f, 1e-6), f"{la['factor']} vs {f}")
check("nine_windows_in_reference_order", order(la) == list(PANELS) + ["viewer"], str(order(la)))
check("every_window_at_its_fill_place", all(rect_near(win(la, n)["rect"], *place(n, f, sz)) for n in PANELS)
      and all(near(win(la, n)["drag_height"], PANELS[n][4] * f) for n in PANELS),
      str({n: win(la, n)["rect"] for n in PANELS}))
vw = win(la, "viewer")["rect"]
check("viewer_at_its_fill_place", rect_near(vw, *viewer_place(f, sz)), str(vw))
check("windows_inside_the_page", all(w["rect"]["x"] >= -0.5 and w["rect"]["y"] >= -0.5 and w["rect"]["x"] + w["rect"]["w"] <= sz[0] + 0.5
      and w["rect"]["y"] + w["rect"]["h"] <= sz[1] + 0.5 for w in la["windows"]))
check("viewer_on_top_at_launch", win(la, "viewer")["order"] == max(w["order"] for w in la["windows"]))

# the seven artworks at one uniform scale fitted to whole rows (#63), flowing left to right, top down, inside the viewer's body
cards = la["viewer"]["cards"]
art_scale = cards[0]["w"] / WORKS[0][2] if cards else 0
check("seven_artworks_at_one_uniform_scale", len(cards) == 7 and all(near(c["w"], r[2] * art_scale, 1.5) and near(c["h"], r[3] * art_scale, 1.5)
      for c, r in zip(cards, WORKS)), f"scale {art_scale:.4f}: {[(c['w'], c['h']) for c in cards]}")

def whole_works(p):
    """#63: at scroll 0 no artwork crosses the body's clip — each is wholly inside it or wholly below it — and one is inside."""
    b = p["viewer"]["body"]; cs = p["viewer"]["cards"]
    inside_ = [c for c in cs if c["y"] >= b["y"] - 0.5 and c["y"] + c["h"] <= b["y"] + b["h"] + 0.5]
    below = [c for c in cs if c["y"] >= b["y"] + b["h"] - 0.5]
    return p["viewer"]["scroll"] == 0 and len(inside_) >= 1 and len(inside_) + len(below) == len(cs), \
        f"{len(inside_)} whole, {len(below)} below, {len(cs) - len(inside_) - len(below)} crossing the clip (body {b})"

ok_, detail_ = whole_works(la)
check("launch_shows_whole_works_only", ok_, detail_)
check("artworks_do_not_overlap", all(a["x"] + a["w"] <= b["x"] + 0.5 or b["x"] + b["w"] <= a["x"] + 0.5 or a["y"] + a["h"] <= b["y"] + 0.5
      or b["y"] + b["h"] <= a["y"] + 0.5 for i, a in enumerate(cards) for b in cards[i + 1:]))
check("artworks_flow_left_to_right_top_down", all(cards[i + 1]["y"] > cards[i]["y"] or (cards[i + 1]["y"] == cards[i]["y"]
      and cards[i + 1]["x"] > cards[i]["x"]) for i in range(6)))
body = la["viewer"]["body"]
check("first_artwork_at_the_body's_top_left", near(cards[0]["x"], body["x"]) and near(cards[0]["y"], body["y"]) and la["viewer"]["scroll"] == 0)
check("artworks_within_the_body's_width", all(c["x"] >= body["x"] - 0.5 and c["x"] + c["w"] <= body["x"] + body["w"] + 0.5 for c in cards))
check("body_inside_viewer", body["x"] >= vw["x"] and body["y"] >= vw["y"] and body["x"] + body["w"] <= vw["x"] + vw["w"]
      and body["y"] + body["h"] <= vw["y"] + vw["h"] + 0.5)
check("more_artwork_than_the_body_shows", la["viewer"]["scroll_max"] > 0 and max(c["y"] + c["h"] for c in cards) > body["y"] + body["h"])

# pixels: every window is its own screenshot (interior, the keyed border left out); the footer is the
# reference's "number of works: 12"; the visible artworks are the reference's cuts; white elsewhere
launch = imgs["01-launch.png"]
sheet = Image.open(MODULE / "reference.png")
diffs = {}
for n in PANELS:
    src = Image.open(MODULE / "assets" / f"{n}.png") if n != "filters" else \
        Image.open(MODULE / "assets" / "layout-reference.png").crop((13, 550, 13 + 535, 550 + 245))
    keyed = 3 if n == "filters" else KEYED
    r = win(la, n)["rect"]
    kx, ky = keyed * r["w"] / src.width, keyed * r["h"] / src.height
    inner = {"x": r["x"] + kx, "y": r["y"] + ky, "w": r["w"] - 2 * kx, "h": r["h"] - 2 * ky}
    sx, sy = src.width / r["w"], src.height / r["h"]
    crop = src.crop((int(kx * sx), int(ky * sy), int((r["w"] - kx) * sx), int((r["h"] - ky) * sy)))
    diffs[n] = looks_like(region(launch, la, inner), crop)
check("every_window_shows_its_own_screenshot", all(d < 24 for d in diffs.values()), str({n: round(d, 1) for n, d in diffs.items()}))
s = la["viewer"]["scale"]
footer = {"x": vw["x"] + 5, "y": vw["y"] + vw["h"] - 5 - FOOTER[3] * s, "w": FOOTER[2] * s, "h": FOOTER[3] * s}
fd = looks_like(region(launch, la, footer), sheet.crop((FOOTER[0], FOOTER[1], FOOTER[0] + FOOTER[2], FOOTER[1] + FOOTER[3])), 2)
check("footer_reads_number_of_works_12", fd < 24 and float(region(launch, la, footer).std()) > 20, f"diff {fd:.1f}")
art = {}
for i, (c, r) in enumerate(zip(cards, WORKS)):
    vis_h = min(c["y"] + c["h"], body["y"] + body["h"]) - c["y"]
    if vis_h < 40:
        continue
    crop = sheet.crop((r[0], r[1], r[0] + r[2], r[1] + int(r[3] * vis_h / c["h"])))
    art[i] = looks_like(region(launch, la, {"x": c["x"], "y": c["y"], "w": c["w"], "h": vis_h}), crop)
check("visible_artworks_are_the_reference's_cuts", len(art) >= 2 and all(d < 24 for d in art.values()), str({i: round(d, 1) for i, d in art.items()}))
g = la["page_global"]
white = launch[int(g["y"] + 1):int(g["y"] + sz[1]), int(sz[0] - MARGINS[2] * f + 2):int(sz[0])]
check("page_white_in_the_right_margin", float(white.min()) > 250, str(float(white.min())))

# 2. a title drag moves the window by the drag and raises it; its size holds
d = gestures["drag equipment by its title bar"]; eq = pages["equipment-moved"]
e0, e1 = win(la, "equipment")["rect"], win(eq, "equipment")["rect"]
check("title_drag_moves_equipment_by_the_drag", near(e1["x"], e0["x"] + d["relative_total"][0]) and near(e1["y"], e0["y"] + d["relative_total"][1])
      and e1["w"] == e0["w"] and e1["h"] == e0["h"], f"{e0} -> {e1} by {d['relative_total']}")
check("title_drag_raises_equipment", order(eq)[-1] == "equipment" and order(eq)[-2] == "viewer")
check("title_drag_moves_nothing_else", same_rects(la, eq, skip=("equipment",)) and eq["action"] == "")
check("drag_started_inside_the_title_bar", e0["y"] <= d["from"][1] - la["page_global"]["y"] < e0["y"] + win(la, "equipment")["drag_height"])

# 3. a body drag moves nothing and raises the window it pressed
ob = pages["options-body-drag"]; d = gestures["drag options by its body"]
check("body_drag_moves_nothing", same_rects(eq, ob) and ob["action"] == "")
check("body_press_still_raises_options", order(ob)[-1] == "options" and order(ob)[-2] == "equipment")
check("body_drag_started_below_the_title_bar", d["from"][1] - eq["page_global"]["y"] >= win(eq, "options")["rect"]["y"] + win(eq, "options")["drag_height"])

# 4. party dragged over the viewer lies on top of it
ov = pages["party-over-viewer"]; d = gestures["drag party by its title bar over the viewer"]
p0, p1, v1 = win(ob, "party")["rect"], win(ov, "party")["rect"], win(ov, "viewer")["rect"]
check("party_moved_by_the_drag", near(p1["x"], p0["x"] + d["relative_total"][0]) and near(p1["y"], p0["y"] + d["relative_total"][1]), f"{p0} -> {p1}")
check("party_overlaps_the_viewer", p1["y"] < v1["y"] + v1["h"] and p1["x"] < v1["x"] + v1["w"] and p1["x"] + p1["w"] > v1["x"])
check("party_on_top_of_the_viewer", order(ov)[-1] == "party" and order(ov).index("viewer") < order(ov).index("party"))
ovimg = imgs["03-party-over-viewer.png"]
overlap = {"x": max(p1["x"], v1["x"]), "y": max(p1["y"], v1["y"]), "w": min(p1["x"] + p1["w"], v1["x"] + v1["w"]) - max(p1["x"], v1["x"]),
           "h": min(p1["y"] + p1["h"], v1["y"] + v1["h"]) - max(p1["y"], v1["y"])}
src = Image.open(MODULE / "assets" / "party.png")
sx, sy = src.width / p1["w"], src.height / p1["h"]
pcrop = src.crop((int((overlap["x"] - p1["x"]) * sx), int((overlap["y"] - p1["y"]) * sy),
                  int((overlap["x"] - p1["x"] + overlap["w"]) * sx), int((overlap["y"] - p1["y"] + overlap["h"]) * sy)))
pd = looks_like(region(ovimg, ov, overlap), pcrop)
check("party_pixels_drawn_over_the_viewer", overlap["w"] > 40 and overlap["h"] > 40 and pd < 24, f"diff {pd:.1f} over {overlap}")

# 5. a press on the viewer's uncovered title raises it above party and drags it; party stays
vm = pages["viewer-moved"]; d = gestures["drag the viewer by its title bar"]
v2 = win(vm, "viewer")["rect"]
check("viewer_moved_by_the_drag", near(v2["x"], v1["x"] + d["relative_total"][0]) and near(v2["y"], v1["y"] + d["relative_total"][1])
      and v2["w"] == v1["w"] and v2["h"] == v1["h"], f"{v1} -> {v2}")
check("viewer_raised_above_party", order(vm)[-1] == "viewer" and order(vm)[-2] == "party")
check("party_stays_put_under_the_viewer_drag", win(vm, "party")["rect"] == p1)
px, py = d["from"][0] - ov["page_global"]["x"], d["from"][1] - ov["page_global"]["y"]
check("viewer_press_was_outside_party", not (p1["x"] <= px < p1["x"] + p1["w"] and p1["y"] <= py < p1["y"] + p1["h"]))
check("viewer_press_inside_its_title_bar", v1["y"] <= py < v1["y"] + win(ov, "viewer")["drag_height"])

# 6. the wheel over the artworks scrolls them; the artworks keep their sizes
sc = pages["scrolled"]; w = gestures["wheel down x3 over the artworks"]
b2 = vm["viewer"]["body"]
check("wheel_landed_on_the_artworks", not w["up"] and b2["x"] < w["x"] - vm["page_global"]["x"] < b2["x"] + b2["w"]
      and b2["y"] < w["y"] - vm["page_global"]["y"] < b2["y"] + b2["h"])
check("wheel_scrolls_the_artworks", 0 < sc["viewer"]["scroll"] <= sc["viewer"]["scroll_max"] + 0.5
      and all(near(c["y"], d0["y"] - sc["viewer"]["scroll"]) and c["x"] == d0["x"] for c, d0 in zip(sc["viewer"]["cards"], vm["viewer"]["cards"]))
      and [(c["w"], c["h"]) for c in sc["viewer"]["cards"]] == [(c["w"], c["h"]) for c in cards], f"scroll {sc['viewer']['scroll']} of {sc['viewer']['scroll_max']}")
check("wheel_moves_no_window", same_rects(vm, sc))

# 7. the corner drag shrinks the viewer in place; the artworks keep their sizes
rz = pages["viewer-resized"]; d = gestures["drag the viewer's corner inward"]
v3 = win(rz, "viewer")["rect"]
check("corner_drag_shrinks_the_viewer_in_place", v3["x"] == v2["x"] and v3["y"] == v2["y"]
      and near(v3["w"], max(v2["w"] + d["relative_total"][0], MINIMUM[0])) and near(v3["h"], max(v2["h"] + d["relative_total"][1], MINIMUM[1])), f"{v2} -> {v3}")
check("resized_body_follows_the_frame", near(rz["viewer"]["body"]["w"], v3["w"] - 24) and rz["viewer"]["body"]["x"] + rz["viewer"]["body"]["w"] <= v3["x"] + v3["w"]
      and [(c["w"], c["h"]) for c in rz["viewer"]["cards"]] == [(c["w"], c["h"]) for c in cards])
rzimg = imgs["06-viewer-resized.png"]
below = region(rzimg, rz, {"x": v3["x"] + v3["w"] - 110, "y": v3["y"] + v3["h"] + 2, "w": 100, "h": max(1, min(20, v2["y"] + v2["h"] - v3["y"] - v3["h"] - 3))})
check("white_where_the_viewer_was", float(below.min()) > 250, str(float(below.min())))

# 8. a drag past the page's corner stops at the edge
cl = pages["chat-clamped"]; d = gestures["drag chat past the page's bottom-left corner"]
c0, c1 = win(rz, "chat")["rect"], win(cl, "chat")["rect"]
check("chat_clamped_to_the_page_edge", c1["x"] == 0 and near(c1["y"], cl["size"][1] - c1["h"]) and c0["x"] + d["relative_total"][0] < 0
      and c0["y"] + d["relative_total"][1] + c1["h"] > cl["size"][1], f"{c0} -> {c1} by {d['relative_total']}")

# 9. frozen while hidden: no frames, no input, the hidden gestures change nothing
mp = shells["map"]; hd = pages["hidden"]; ha = pages["hidden-after-events"]; ma = shells["map-after-20-frames"]
check("map_tab_hides_and_freezes_the_page", mp["active"] == 0 and not mp["tabs"][4]["page_visible"] and mp["tabs"][4]["frozen"] and hd["ok"])
check("frozen_counters_stand_still", ha["ticks"] == hd["ticks"] and ha["inputs"] == hd["inputs"] and ma["tabs"][4]["frozen"],
      f"ticks {hd['ticks']}->{ha['ticks']} inputs {hd['inputs']}->{ha['inputs']}")
check("hidden_gestures_change_nothing", same_rects(cl, ha) and order(ha) == order(cl) and ha["viewer"]["scroll"] == cl["viewer"]["scroll"]
      and "drag trade by its title bar while hidden" in gestures and "wheel down x3 over the artworks while hidden" in gestures)
mapimg = imgs["08-map.png"]
check("map_page_is_white", float(mapimg[int(g["y"] + 2):int(g["y"] + sz[1] - 2)].min()) > 250)

# 10. resumed intact
ca = shells["collection-again"]; rs = pages["resumed"]; ra = pages["resumed-after-20-frames"]
check("collection_tab_resumes_the_page", ca["active"] == 4 and ca["tabs"][4]["page_visible"] and not ca["tabs"][4]["frozen"])
check("resumed_windows_exactly_as_left", same_rects(cl, rs) and order(rs) == order(cl) and rs["viewer"]["scroll"] == cl["viewer"]["scroll"]
      and win(rs, "viewer")["rect"] == v3)
check("resumed_counters_advance", ra["ticks"] > rs["ticks"] >= ha["ticks"], f"{ha['ticks']} -> {rs['ticks']} -> {ra['ticks']}")
check("resumed_pixels_match_before_hiding", hashes["09-resumed.png"] == hashes["07-chat-clamped.png"]
      or float(np.abs(imgs["09-resumed.png"] - imgs["07-chat-clamped.png"]).mean()) < 0.5)

# 11. resize to the minimum: every window re-fitted to the smaller page
rr = pages["resized"]; sr = shells["resized"]
sz2 = rr["size"]; f2 = min(sz2[0] / 1944.0, sz2[1] / 1280.0)
check("resized_page_is_the_minimum", near(sz2[0], 1440) and near(sz2[1], 900 - 161 * 1440 / 4180.0, 1.5) and sr["window"] == [1440, 900], str(sz2))
check("resize_refits_every_window", near(rr["factor"], f2, 1e-6) and all(rect_near(win(rr, n)["rect"], *place(n, f2, sz2)) for n in PANELS)
      and rect_near(win(rr, "viewer")["rect"], *viewer_place(f2, sz2)), str(win(rr, "viewer")["rect"]))
check("resized_screenshot_is_1440x900", imgs["10-resized.png"].shape[:2] == (900, 1440), str(imgs["10-resized.png"].shape))
ok_, detail_ = whole_works(rr)
check("resized_page_shows_whole_works_only", ok_, detail_)

# 12. #63: at pages of 1920x1000 and 1440x820 the desktop's bounding box spans the page on both axes within the
# native margins and the viewer is at least its native size times the uniform scale
for label in ("fill-1920x1000", "fill-1440x820"):
    fp = pages[label]; fs = fp["size"]; want = [int(v) for v in label[5:].split("x")]
    ff = min(fs[0] / DESKTOP[0], fs[1] / DESKTOP[1])
    boxes = [w["rect"] for w in fp["windows"]]
    gaps = (min(b["x"] for b in boxes), min(b["y"] for b in boxes),
            fs[0] - max(b["x"] + b["w"] for b in boxes), fs[1] - max(b["y"] + b["h"] for b in boxes))
    check(f"{label}_page_size", near(fs[0], want[0]) and near(fs[1], want[1]), str(fs))
    check(f"{label}_desktop_spans_page_both_axes", all(-0.5 <= gp <= m * ff + 1.5 for gp, m in zip(gaps, MARGINS)),
          f"gaps l/t/r/b {[round(gp, 1) for gp in gaps]}, native margins x s {[round(m * ff, 1) for m in MARGINS]}")
    fv = win(fp, "viewer")["rect"]
    check(f"{label}_viewer_at_least_native_times_scale", fv["w"] >= VIEWER[2] * ff - 1 and fv["h"] >= VIEWER[3] * ff - 1,
          f"viewer {fv} native x s {VIEWER[2] * ff:.0f}x{VIEWER[3] * ff:.0f}")
    check(f"{label}_layout_is_the_fill_rule", all(rect_near(win(fp, n)["rect"], *place(n, ff, fs)) for n in PANELS)
          and rect_near(fv, *viewer_place(ff, fs)), str(fv))
    ok_, detail_ = whole_works(fp)
    check(f"{label}_shows_whole_works_only", ok_ and all(c["x"] + c["w"] <= fp["viewer"]["body"]["x"] + fp["viewer"]["body"]["w"] + 0.5 for c in fp["viewer"]["cards"]), detail_)

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL", f"({sum(r['pass'] for r in results.values())}/{len(results)})")
sys.exit(0 if ok else 1)
