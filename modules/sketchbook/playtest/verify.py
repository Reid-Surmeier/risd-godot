#!/usr/bin/env python3
"""Independent verifier for a sketchbook playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels, and checks the logged states against the Tenant contract
and the prototype's numbers (d2faa30): created on first show, the fill rule of ticket #63 at three page
sizes (uniform art scale, the desktop's bounding box spanning the page within the native margin, by
state and by pixels), a well loads pigment, two pigments mixed on the tray give a third colour in the
tray's pixels, the page is painted with the carried pigment, the idle brush goes back to the cat rest
with its tip in that pigment, the paper turn to a blank spread and back, a title-bar drag, frozen while
hidden, resumed intact, resize.
usage: verify.py OUT_DIR"""
import colorsys, hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

BAR_RATIO = 161 / 4180.0              # the strip's height per pixel of width
DESKTOP = (1330, 860)                 # desktop.gd DESKTOP_SIZE with saved references above the tools
MARGIN = (60, 52)                     # desktop.gd NATIVE_MARGIN
PAINTBOX = (550, 575)                 # desktop.gd PAINTBOX_SLOT size (the prototype's variant A)
BOOK = (630, 555)                     # desktop.gd BOOK_SLOT size
DEFAULT_PIGMENT = "00458f"            # paintbox.gd brush_color at launch
TURN_SECONDS = 0.52                   # sketchbook_window.gd TURN_SECONDS

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {}
for e in log:
    if e["event"] == "state":
        states.setdefault(e["label"], e)
book = {e["label"]: e for e in log if e["event"] == "book"}
gestures = {e["what"]: e for e in log if e["event"] in ("drag", "click")}
results = {}


def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}


def near(a, b, tol):
    return abs(a - b) <= tol


def inside(x, y, r):
    return r["x"] <= x <= r["x"] + r["w"] and r["y"] <= y <= r["y"] + r["h"]


def same_rect(a, b, tol=0.5):
    return all(near(a[k], b[k], tol) for k in "xywh")


def same_book(a, b):
    return (a["spread"] == b["spread"] and a["strokes"] == b["strokes"] and a["turning"] == b["turning"]
            and a["last_stroke_points"] == b["last_stroke_points"] and same_rect(a["window_rect"], b["window_rect"])
            and same_rect(a["page_rect"], b["page_rect"]) and a["window_visible"] == b["window_visible"]
            and a["brush_color"] == b["brush_color"] and a["paint_pixels"] == b["paint_pixels"])


def region(img, r, pad=2):
    return img[int(r["y"]) + pad:int(r["y"] + r["h"]) - pad, int(r["x"]) + pad:int(r["x"] + r["w"]) - pad]


def rgb(h):
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)])


def hue(c):
    return colorsys.rgb_to_hsv(*(np.asarray(c, float) / 255.0))[0] * 360


def hue_gap(a, b):
    d = abs(a - b) % 360
    return min(d, 360 - d)


def chromatic(px, s_min=0.3, v_min=0.12):
    """The saturated pixels of an (n, 3) array, and their circular mean hue (None when there are none)."""
    f = px.reshape(-1, 3) / 255.0
    hi, lo = f.max(axis=1), f.min(axis=1)
    sat = np.where(hi > 0, (hi - lo) / np.maximum(hi, 1e-6), 0)
    keep = f[(sat >= s_min) & (hi >= v_min)]
    if len(keep) == 0:
        return 0, None
    hues = np.array([colorsys.rgb_to_hsv(*p)[0] for p in keep]) * 2 * np.pi
    return len(keep), float(np.degrees(np.angle(np.exp(1j * hues).mean())) % 360)


shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 15, str(sorted(shots)))
check("desktop_screenshot_is_1920x1080", imgs["01-desktop.png"].shape[:2] == (1080, 1920), str(imgs["01-desktop.png"].shape))

# created lazily on first show, through the Shell
la = states["launch"]
check("no_book_tenant_at_launch", la["active"] == 4 and la["tabs"][1]["tenant"] is None and la["tabs"][1]["frozen"]
      and book["launch"]["code"] == "shell.tenant_missing")
sh = states["book"]; b = book["book-shown"]
check("click_sketchbook_tab_creates_and_shows_desktop", sh["active"] == 1 and sh["tabs"][1]["tenant"] == "ok" and sh["tabs"][1]["page_visible"]
      and not sh["tabs"][1]["frozen"] and b["ok"] and "sketchbook tab" in gestures, str(sh["tabs"][1]))
check("tenant_fills_page_area", near(b["size"][0], 1920, 1) and near(b["size"][1], 1080 - 1920 * BAR_RATIO, 1.5), str(b["size"]))
check("paintbox_is_the_prototypes_variant_a", b["smear_variant"] == "A" and b["mixbox"].startswith("2.0") and len(b["wells"]) == 32
      and len(b["trays"]) == 4 and b["brush_color"] == DEFAULT_PIGMENT, f"{b['smear_variant']} {b['mixbox']} {b['brush_color']}")
check("book_opens_on_blank_spread_1", b["spread"] == 1 and b["strokes"] == 0 and b["previous_disabled"] and b["turning"] == ""
      and b["window_visible"] and not b["drawing"], str({k: b[k] for k in ("spread", "strokes", "turning")}))


# the fill rule (#63): s = min(S / D), paintbox art at s, the book taking the leftover, the bounding box
# of both windows spanning the page within the native margin — by the logged rects and by the pixels
def fill(label, shot, page):
    e = book[label]; S = e["size"]
    s = min(S[0] / DESKTOP[0], S[1] / DESKTOP[1])
    pb, wr, rr = e["paintbox_rect"], e["window_rect"], e["reference_rect"]
    x0, y0 = min(pb["x"], wr["x"], rr["x"]), min(pb["y"], wr["y"], rr["y"])
    x1 = max(pb["x"] + pb["w"], wr["x"] + wr["w"], rr["x"] + rr["w"])
    y1 = max(pb["y"] + pb["h"], wr["y"] + wr["h"], rr["y"] + rr["h"])
    mx, my = MARGIN[0] * s + 1.5, MARGIN[1] * s + 1.5
    margins = (x0, S[0] - x1, y0, S[1] - y1)
    by_state = (all(-0.5 <= m for m in margins) and margins[0] <= mx and margins[1] <= mx and margins[2] <= my and margins[3] <= my)
    art = (near(e["desktop_scale"], s, 1e-3) and near(pb["w"], PAINTBOX[0] * s, 1) and near(pb["h"], PAINTBOX[1] * s, 1)
           and wr["w"] >= BOOK[0] * s - 1 and wr["h"] >= BOOK[1] * s - 1)
    img = imgs[shot][:int(S[1]), :int(S[0])]
    ys, xs = np.where((img < 235).any(axis=2))
    px = (xs.min(), S[0] - 1 - xs.max(), ys.min(), S[1] - 1 - ys.max())
    by_pixels = px[0] <= mx + 2 and px[1] <= mx + 2 and px[2] <= my + 2 and px[3] <= my + 2
    check(f"fill_rule_{label}", (page is None or (near(S[0], page[0], 1) and near(S[1], page[1], 1))) and art and by_state and by_pixels,
          f"page {S[0]:.0f}x{S[1]:.1f} s {s:.4f} paintbox {pb['w']:.0f}x{pb['h']:.0f} book {wr['w']:.0f}x{wr['h']:.0f} "
          f"margins l/r/t/b state {[round(m, 1) for m in margins]} pixels {[int(m) for m in px]} allowed {mx:.1f},{my:.1f}")
    return e


fill("book-shown", "01-desktop.png", None)
fill("fill-1920x1000", "02-fill-1920x1000.png", (1920, 1000))
f2 = fill("fill-1440x820", "03-fill-1440x820.png", (1440, 820))
check("fill_1440x820_book_takes_the_leftover_width", f2["desktop_logical"][0] > DESKTOP[0] + 50
      and near(f2["window_rect"]["w"], (BOOK[0] + f2["desktop_logical"][0] - DESKTOP[0]) * f2["desktop_scale"], 1.5),
      f"logical {f2['desktop_logical']} book w {f2['window_rect']['w']:.1f}")
check("fill_restored_matches_first_show", same_rect(book["fill-restored"]["window_rect"], b["window_rect"])
      and same_rect(book["fill-restored"]["paintbox_rect"], b["paintbox_rect"]))

# the brush rests at launch, tip in the default pigment, on the cat rest below the palette
rest0 = b["parked_brush_rect"]; tip0 = dict(rest0, w=rest0["w"] * 0.4, h=rest0["h"] * 0.4)
n0, h0 = chromatic(region(imgs["01-desktop.png"], tip0, 0))
check("brush_rests_below_palette_at_launch", b["brush_parked"] and not b["palette_cursor_visible"] and not b["brush_cursor_visible"]
      and b["rest_rect"]["y"] > b["palette_rect"]["y"] + b["palette_rect"]["h"] and inside(*[b["rest_rect"]["x"] + b["rest_rect"]["w"] / 2,
      b["rest_rect"]["y"] + b["rest_rect"]["h"] / 2], b["paintbox_rect"]) and n0 >= 200 and hue_gap(h0, hue(rgb(DEFAULT_PIGMENT))) < 25,
      f"parked {b['brush_parked']}, tip saturated px {n0} hue {h0} vs pigment {hue(rgb(DEFAULT_PIGMENT)):.0f}")

# a well loads pigment
wa = book["well-a"]; wb = book["well-b"]; ca, cb = rgb(wa["brush_color"]), rgb(wb["brush_color"])
check("well_clicks_land_on_wells", inside(gestures["well A"]["x"], gestures["well A"]["y"], b["wells"][9])
      and inside(gestures["well B"]["x"], gestures["well B"]["y"], b["wells"][21]))
check("well_loads_pigment", wa["brush_color"] != DEFAULT_PIGMENT and wb["brush_color"] not in (DEFAULT_PIGMENT, wa["brush_color"])
      and np.ptp(ca) > 45 and np.ptp(cb) > 45 and wa["palette_hovering"] and not wa["brush_parked"] and wa["palette_cursor_visible"],
      f"A {wa['brush_color']} B {wb['brush_color']}, brush off the rest {not wa['brush_parked']}")

# mixing: A smeared into the tray, B dragged down through it; the brush carries a Mixbox mix of both
ta = book["tray-a"]; mx_ = book["mixed"]; cm = rgb(mx_["brush_color"])
tray = b["trays"][1]; ga = gestures["smear A across the tray"]; gb = gestures["drag B through A"]
check("tray_drags_stay_in_tray", all(inside(p[0], p[1], tray) for p in (ga["from"], ga["to"], gb["from"], gb["to"])))
check("smear_deposits_paint", ta["paint_pixels"] > 0 and ta["brush_color"] == wa["brush_color"] and hashes["04-tray-a.png"] != hashes["01-desktop.png"],
      f"paint px {ta['paint_pixels']}")
check("carried_pigment_is_a_mix_of_both", mx_["paint_pixels"] > ta["paint_pixels"] and mx_["mix_count"] > ta["mix_count"]
      and np.abs(cm - ca).max() > 40 and np.abs(cm - cb).max() > 40, f"A {wa['brush_color']} B {wb['brush_color']} carried {mx_['brush_color']}")
# pixels: in 05, the horizontal A band away from the crossing, the vertical band above it (B) and below it (the mix)
img5 = imgs["05-mixed.png"]; cx = int(gb["from"][0]); cy = int(ga["from"][1]); band = 5


def mean_paint(x0, x1, y0, y1):
    px = img5[y0:y1, x0:x1].reshape(-1, 3)
    f = px / 255.0
    sat = (f.max(axis=1) - f.min(axis=1)) / np.maximum(f.max(axis=1), 1e-6)
    keep = px[sat > 0.3]
    return (keep.mean(axis=0) if len(keep) else np.array([255, 255, 255])), len(keep)


pa, na = mean_paint(int(ga["from"][0]) + 6, cx - 20, cy - band, cy + band)
pbb, nb = mean_paint(cx - band, cx + band, int(gb["from"][1]) + 6, cy - 20)
pm, nm = mean_paint(cx - band, cx + band, cy + 20, int(gb["to"][1]) - 14)
check("tray_pixels_show_a_third_colour", min(na, nb, nm) >= 30 and np.abs(pm - pa).max() > 30 and np.abs(pm - pbb).max() > 30
      and hue_gap(hue(pm), hue(pbb)) > 60,
      f"A band {pa.round()} ({na}px), B band {pbb.round()} ({nb}px), mixed band {pm.round()} ({nm}px)")

# painting on the page with the carried pigment
pg = b["page_rect"]; dp = gestures["paint on the page"]; dr = book["painted"]
check("paint_drag_lands_inside_page", inside(dp["from"][0], dp["from"][1], pg) and inside(dp["to"][0], dp["to"][1], pg))
check("paint_drag_draws_one_stroke_in_the_carried_pigment", dr["strokes"] == 1 and dr["last_stroke_points"] == dp["steps"] + 1
      and dr["last_stroke_color"] == mx_["brush_color"] and dr["ink_color"] == mx_["brush_color"] and not dr["drawing"],
      f"strokes {dr['strokes']} points {dr['last_stroke_points']} stroke {dr['last_stroke_color']} carried {mx_['brush_color']}")
rs = book["rested"]
page0 = region(imgs["01-desktop.png"], pg); page7 = region(imgs["07-rested.png"], pg)
changed = np.abs(page7 - page0).max(axis=2) > 40
n_paint, h_paint = chromatic(page7[changed])
check("page_pixels_painted_in_the_carried_pigment", 150 <= n_paint and hue_gap(h_paint, hue(cm)) < 25 and hue_gap(h_paint, hue(cb)) > 60
      and int((np.abs(region(imgs["05-mixed.png"], pg) - page0).max(axis=2) > 40).sum()) < 5,
      f"changed saturated px {n_paint}, hue {h_paint} vs carried {hue(cm):.0f} (B {hue(cb):.0f})")

# idle: the brush back on the rest, its tip in the carried pigment; while painting it was off the rest
n6, _ = chromatic(region(imgs["06-painted.png"], tip0, 0))
n7, h7 = chromatic(region(imgs["07-rested.png"], rs["parked_brush_rect"] | {"w": rs["parked_brush_rect"]["w"] * 0.4, "h": rs["parked_brush_rect"]["h"] * 0.4}, 0))
check("brush_leaves_the_rest_while_painting", not dr["brush_parked"] and dr["hovering"] and dr["brush_cursor_visible"] and n6 < 40,
      f"parked {dr['brush_parked']} page hover {dr['hovering']}, tip px on the rest {n6}")
check("idle_brush_returns_to_rest_with_pigment_tip", rs["brush_parked"] and not rs["hovering"] and not rs["palette_hovering"]
      and not rs["brush_cursor_visible"] and not rs["palette_cursor_visible"] and same_rect(rs["parked_brush_rect"], rest0)
      and n7 >= 200 and hue_gap(h7, hue(cm)) < 25 and hue_gap(h7, h0) > 60,
      f"tip saturated px {n7} hue {h7} vs carried {hue(cm):.0f}, launch tip hue {h0}")

# the next arrow: the perspective turn in flight, then spread 2 with no paint; previous brings the paint back
def paint_px(shot):
    return int((np.abs(region(imgs[shot], pg) - page0).max(axis=2) > 40).sum())


kn = gestures["next-page button"]; tg = book["turning"]; t = book["turned"]
check("next_click_lands_on_arrow", inside(kn["x"], kn["y"], dr["controls"]["next"]))
check("next_starts_the_paper_turn", tg["turning"] == "forward" and 0 < tg["turn_progress"] < 1 and tg["face_update_mode"] == 4 and tg["spread"] == 2,
      f"turning {tg['turning']} progress {tg['turn_progress']:.3f} face mode {tg['face_update_mode']}")
check("turn_lands_on_blank_spread_2", t["turning"] == "" and t["spread"] == 2 and t["strokes"] == 0 and t["last_turn_ms"] >= TURN_SECONDS * 1000 - 70
      and not t["previous_disabled"] and t["face_update_mode"] == 0 and paint_px("09-turned.png") < 5,
      f"spread {t['spread']} strokes {t['strokes']} turn {t['last_turn_ms']} ms, changed px {paint_px('09-turned.png')}")
check("turn_in_flight_looks_different", hashes["08-turning.png"] != hashes["07-rested.png"] and hashes["08-turning.png"] != hashes["09-turned.png"])
kp = gestures["previous-page button"]; tb = book["turned-back"]
check("previous_click_lands_on_arrow", inside(kp["x"], kp["y"], t["controls"]["previous"]))
check("previous_turns_back_to_the_paint", tb["turning"] == "" and tb["spread"] == 1 and tb["strokes"] == 1 and tb["last_stroke_points"] == dr["last_stroke_points"]
      and tb["previous_disabled"] and tb["last_turn_ms"] >= TURN_SECONDS * 1000 - 70 and paint_px("10-turned-back.png") >= 150,
      f"spread {tb['spread']} strokes {tb['strokes']}, changed px {paint_px('10-turned-back.png')}")

# title-bar drag: the window, its page and its paint move by the drag
tt = gestures["drag the window by its title bar"]; e = book["before-hidden"]
check("title_drag_starts_on_title_bar", inside(tt["from"][0], tt["from"][1], tb["title_rect"]), f"from {tt['from']} title {tb['title_rect']}")
check("title_drag_moves_window_and_page", near(e["window_rect"]["x"], tb["window_rect"]["x"] + tt["relative_total"][0], 0.5)
      and near(e["window_rect"]["y"], tb["window_rect"]["y"] + tt["relative_total"][1], 0.5)
      and near(e["page_rect"]["x"], tb["page_rect"]["x"] + tt["relative_total"][0], 0.5)
      and near(e["page_rect"]["y"], tb["page_rect"]["y"] + tt["relative_total"][1], 0.5)
      and e["strokes"] == 1 and e["spread"] == 1 and not e["dragging"], f"{tb['window_rect']} -> {e['window_rect']} by {tt['relative_total']}")
def crop(img, x, y, w, h):
    return img[int(round(y)):int(round(y)) + h, int(round(x)):int(round(x)) + w]


W, H = int(pg["w"]) - 4, int(pg["h"]) - 4
before = crop(imgs["10-turned-back.png"], tb["page_rect"]["x"] + 2, tb["page_rect"]["y"] + 2, W, H)
moved = crop(imgs["11-before-hidden.png"], e["page_rect"]["x"] + 2, e["page_rect"]["y"] + 2, W, H)
def stroke_mask(page):
    return ((page[:, :, 0] < 180) & (page[:, :, 1] < 140) & (page[:, :, 2] < 140)
            & (page[:, :, 0] > page[:, :, 1]))


before_stroke, moved_stroke = stroke_mask(before), stroke_mask(moved)
by, bx = np.where(before_stroke); my, mx = np.where(moved_stroke)
centres_match = (len(bx) > 0 and len(mx) > 0 and abs(bx.mean() - mx.mean()) < 1 and abs(by.mean() - my.mean()) < 1)
check("paint_moves_with_the_window", min(before_stroke.sum(), moved_stroke.sum()) >= 150
      and abs(int(before_stroke.sum()) - int(moved_stroke.sum())) <= 5 and centres_match
      and hashes["11-before-hidden.png"] != hashes["10-turned-back.png"],
      f"stroke px {before_stroke.sum()} -> {moved_stroke.sum()}, aligned centre {centres_match}")

# hidden: frozen page, no frames, no input, SubViewports quiet, nothing rendered, events change nothing
mp = states["map"]; h0b = book["book-hidden"]; h1 = book["book-hidden-after-events"]
check("hidden_book_page_frozen", mp["active"] == 0 and mp["tabs"][1]["frozen"] and not mp["tabs"][1]["page_visible"])
check("hidden_tenant_process_stops", h1["ticks"] == h0b["ticks"], f"ticks {h0b['ticks']} -> {h1['ticks']} over 20 frames")
check("hidden_tenant_gets_no_input", h1["inputs"] == h0b["inputs"] and "drag inside the page while hidden" in gestures
      and "next-page button while hidden" in gestures, f"inputs {h0b['inputs']} -> {h1['inputs']}")
check("hidden_events_draw_and_turn_nothing", same_book(h1, e) and h1["strokes"] == 1 and h1["spread"] == 1 and h1["turning"] == "",
      f"strokes {h1['strokes']} spread {h1['spread']} turning '{h1['turning']}'")
check("hidden_subviewports_quiet", all(x["static_update_mode"] in (0, 1) and x["face_update_mode"] == 0 for x in (h0b, h1)),
      f"static {h0b['static_update_mode']},{h1['static_update_mode']} face {h0b['face_update_mode']},{h1['face_update_mode']}")
d0 = la["draw_calls"]; d1 = states["before-hidden"]["draw_calls"]; d2 = states["map-after-20-frames"]["draw_calls"]
check("hidden_page_renders_nothing", d1 >= d0 + 8 and abs(d2 - d0) <= 2, f"draw calls: white page {d0}, desktop shown {d1}, hidden {d2}")
page_h = int(1080 - 1920 * BAR_RATIO)
hidden_page = imgs["12-hidden.png"][:page_h - 2, :]
check("hidden_page_shows_plain_white_map", float(hidden_page.mean()) > 254, f"mean {float(hidden_page.mean()):.2f}")

# resumed: same desktop, frames run again, the same pixels
r0 = book["book-resumed"]; r1 = book["book-resumed-after-20-frames"]
check("book_resumes_with_state_intact", states["book-again"]["active"] == 1 and same_book(r0, e) and same_book(r1, e)
      and 0 <= r0["ticks"] - h1["ticks"] <= 6 and r1["ticks"] - r0["ticks"] >= 15, f"ticks frozen {h1['ticks']}, resumed {r0['ticks']} -> {r1['ticks']}")
diff = float(np.abs(imgs["13-resumed.png"] - imgs["11-before-hidden.png"]).mean())
check("resumed_pixels_identical_to_before_hiding", diff < 0.5, f"mean abs diff {diff:.3f}")

# resize to the 1440x900 minimum: the desktop re-fits by the same rule, the moved book keeps its move; restore returns
rz = book["resized"]; S = rz["size"]; s2 = min(S[0] / DESKTOP[0], S[1] / DESKTOP[1])
check("resize_refits_desktop", states["resized"]["window"] == [1440, 900] and near(S[0], 1440, 1) and near(S[1], 900 - 1440 * BAR_RATIO, 1.5)
      and near(rz["desktop_scale"], s2, 1e-3) and near(rz["paintbox_rect"]["w"], PAINTBOX[0] * s2, 1) and rz["strokes"] == 1
      and rz["window_rect"]["x"] + rz["window_rect"]["w"] <= 1440.5 and rz["window_rect"]["y"] + rz["window_rect"]["h"] <= S[1] + 0.5,
      f"tenant {S}, scale {rz['desktop_scale']:.4f}, window {rz['window_rect']}")
check("resized_screenshot_is_1440x900", imgs["14-resized.png"].shape[:2] == (900, 1440), str(imgs["14-resized.png"].shape))
check("restore_refits_back", states["restored"]["window"] == [1920, 1080] and near(book["restored"]["desktop_scale"], b["desktop_scale"], 1e-6)
      and same_rect(book["restored"]["window_rect"], e["window_rect"]) and same_rect(book["restored"]["paintbox_rect"], b["paintbox_rect"])
      and hashes["15-restored.png"] != hashes["14-resized.png"])

# pixels: the book's page and the palette are drawn (not white)
for name, r in (("book_page_drawn", pg), ("palette_drawn", b["palette_rect"])):
    px = region(imgs["01-desktop.png"], r)
    check(name, float(px.mean()) < 250 and float(px.std()) > 3, f"mean {float(px.mean()):.1f} std {float(px.std()):.1f}")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print(f"{sum(r['pass'] for r in results.values())}/{len(results)} checks")
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
