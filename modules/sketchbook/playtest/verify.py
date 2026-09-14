#!/usr/bin/env python3
"""Independent verifier for a sketchbook playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels (tldraw's ink blue on the page), and checks the logged
states against the Tenant contract and the prototype's numbers (created on first show, fills the
page, the desktop 1:1 and centred with the book where the prototype put it, a real drag draws one
stroke, the paper turn to a blank spread and back to the ink, a title-bar drag, frozen while hidden
with the SubViewports quiet and every gesture ignored, resumed intact, resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

BAR_H = 161 * 1920 / 4180.0
DESKTOP = (1440, 972)                 # desktop.gd DESKTOP_SIZE (the prototype's canvas)
BOOK_ORIGIN, BOOK_SIZE = (740, 460), (620, 500)   # desktop.gd, as the prototype's desktop.gd placed it
INK = (0x44, 0x65, 0xE9)              # drawing_surface.gd DEFAULT_INK, tldraw blue
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
            and same_rect(a["page_rect"], b["page_rect"]) and a["window_visible"] == b["window_visible"])

def region(img, r):
    return img[int(r["y"]) + 2:int(r["y"] + r["h"]) - 2, int(r["x"]) + 2:int(r["x"] + r["w"]) - 2]

def ink(img, r, tol=40):
    return int((np.abs(region(img, r) - np.array(INK)).max(axis=2) <= tol).sum())

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 10, str(sorted(shots)))
check("book_screenshot_is_1920x1080", imgs["01-book.png"].shape[:2] == (1080, 1920), str(imgs["01-book.png"].shape))

# created lazily on first show, through the Shell
la = states["launch"]
check("no_book_tenant_at_launch", la["active"] == 4 and la["tabs"][1]["tenant"] is None and la["tabs"][1]["frozen"]
      and book["launch"]["code"] == "shell.tenant_missing")
sh = states["book"]; b = book["book-shown"]
check("click_sketchbook_tab_creates_and_shows_desktop", sh["active"] == 1 and sh["tabs"][1]["tenant"] == "ok" and sh["tabs"][1]["page_visible"]
      and not sh["tabs"][1]["frozen"] and b["ok"] and "sketchbook tab" in gestures, str(sh["tabs"][1]))
sz = b["size"]
check("tenant_fills_page_area", near(sz[0], 1920, 1) and near(sz[1], 1080 - BAR_H, 1.5), str(sz))

# the desktop: the prototype's 1440x972 canvas 1:1, centred; the book at (740, 460) 620x500 with its 20 px title bar
ox = (sz[0] - DESKTOP[0]) / 2; oy = BAR_H + (sz[1] - DESKTOP[1]) / 2
wr = b["window_rect"]; pg = b["page_rect"]; tr = b["title_rect"]
check("desktop_is_1to1_and_centred", near(b["desktop_scale"], 1.0, 1e-6) and near(wr["x"], ox + BOOK_ORIGIN[0], 1) and near(wr["y"], oy + BOOK_ORIGIN[1], 1.5)
      and near(wr["w"], BOOK_SIZE[0], 0.5) and near(wr["h"], BOOK_SIZE[1], 0.5), f"window {wr}")
check("page_inside_window_below_title", inside(pg["x"], pg["y"], wr) and inside(pg["x"] + pg["w"], pg["y"] + pg["h"], wr)
      and near(tr["h"], 20, 0.5) and near(tr["y"], wr["y"], 0.5) and pg["y"] > tr["y"] + tr["h"], f"page {pg} title {tr}")
check("book_opens_on_blank_spread_1", b["spread"] == 1 and b["strokes"] == 0 and b["previous_disabled"] and b["turning"] == ""
      and b["ink_color"] == "4465e9" and b["window_visible"] and not b["drawing"], str({k: b[k] for k in ("spread", "strokes", "turning")}))

# a real drag across the page draws one stroke, every sample in it, ink on screen
d = gestures["drag inside the page"]; dr = book["drawn"]
check("drag_lands_inside_page", inside(d["from"][0], d["from"][1], pg) and inside(d["to"][0], d["to"][1], pg), f"{d['from']} -> {d['to']} page {pg}")
check("drag_draws_one_stroke", dr["strokes"] == 1 and dr["last_stroke_points"] == d["steps"] + 1 and not dr["drawing"] and dr["spread"] == 1,
      f"strokes {dr['strokes']}, points {dr['last_stroke_points']} of {d['steps'] + 1}")
ink0 = ink(imgs["01-book.png"], pg); ink1 = ink(imgs["02-drawn.png"], pg)
check("ink_pixels_appear_on_page", ink0 < 5 and ink1 >= 100 and hashes["02-drawn.png"] != hashes["01-book.png"], f"ink px {ink0} -> {ink1}")

# the next arrow: the perspective turn in flight, then spread 2 with nothing on it; previous brings the ink back
kn = gestures["next-page button"]; tg = book["turning"]; t = book["turned"]
check("next_click_lands_on_arrow", inside(kn["x"], kn["y"], dr["controls"]["next"]))
check("next_starts_the_paper_turn", tg["turning"] == "forward" and 0 < tg["turn_progress"] < 1 and tg["face_update_mode"] == 4 and tg["spread"] == 2,
      f"turning {tg['turning']} progress {tg['turn_progress']:.3f} face mode {tg['face_update_mode']}")
check("turn_lands_on_blank_spread_2", t["turning"] == "" and t["spread"] == 2 and t["strokes"] == 0 and t["last_turn_ms"] >= TURN_SECONDS * 1000 - 70
      and not t["previous_disabled"] and t["face_update_mode"] == 0 and ink(imgs["04-turned.png"], pg) < 5,
      f"spread {t['spread']} strokes {t['strokes']} turn {t['last_turn_ms']} ms, ink px {ink(imgs['04-turned.png'], pg)}")
check("turn_in_flight_looks_different", hashes["03-turning.png"] != hashes["02-drawn.png"] and hashes["03-turning.png"] != hashes["04-turned.png"])
kp = gestures["previous-page button"]; tb = book["turned-back"]
check("previous_click_lands_on_arrow", inside(kp["x"], kp["y"], t["controls"]["previous"]))
check("previous_turns_back_to_the_ink", tb["turning"] == "" and tb["spread"] == 1 and tb["strokes"] == 1 and tb["last_stroke_points"] == dr["last_stroke_points"]
      and tb["previous_disabled"] and tb["last_turn_ms"] >= TURN_SECONDS * 1000 - 70 and ink(imgs["05-turned-back.png"], pg) >= 100,
      f"spread {tb['spread']} strokes {tb['strokes']}, ink px {ink(imgs['05-turned-back.png'], pg)}")

# title-bar drag: the window, its page and its ink move by the drag
tt = gestures["drag the window by its title bar"]; e = book["before-hidden"]
check("title_drag_starts_on_title_bar", inside(tt["from"][0], tt["from"][1], tb["title_rect"]), f"from {tt['from']} title {tb['title_rect']}")
check("title_drag_moves_window_and_page", near(e["window_rect"]["x"], tb["window_rect"]["x"] + tt["relative_total"][0], 0.5)
      and near(e["window_rect"]["y"], tb["window_rect"]["y"] + tt["relative_total"][1], 0.5)
      and near(e["page_rect"]["x"], tb["page_rect"]["x"] + tt["relative_total"][0], 0.5)
      and near(e["page_rect"]["y"], tb["page_rect"]["y"] + tt["relative_total"][1], 0.5)
      and e["strokes"] == 1 and e["spread"] == 1 and not e["dragging"], f"{tb['window_rect']} -> {e['window_rect']} by {tt['relative_total']}")
check("ink_moves_with_the_window", ink(imgs["06-before-hidden.png"], e["page_rect"]) >= 100 and hashes["06-before-hidden.png"] != hashes["05-turned-back.png"],
      f"ink px {ink(imgs['06-before-hidden.png'], e['page_rect'])}")

# hidden: frozen page, no frames, no input, SubViewports quiet, nothing rendered, events change nothing
mp = states["map"]; h0 = book["book-hidden"]; h1 = book["book-hidden-after-events"]
check("hidden_book_page_frozen", mp["active"] == 0 and mp["tabs"][1]["frozen"] and not mp["tabs"][1]["page_visible"])
check("hidden_tenant_process_stops", h1["ticks"] == h0["ticks"], f"ticks {h0['ticks']} -> {h1['ticks']} over 20 frames")
check("hidden_tenant_gets_no_input", h1["inputs"] == h0["inputs"] and "drag inside the page while hidden" in gestures
      and "next-page button while hidden" in gestures, f"inputs {h0['inputs']} -> {h1['inputs']}")
check("hidden_events_draw_and_turn_nothing", same_book(h1, e) and h1["strokes"] == 1 and h1["spread"] == 1 and h1["turning"] == "",
      f"strokes {h1['strokes']} spread {h1['spread']} turning '{h1['turning']}'")
check("hidden_subviewports_quiet", all(x["static_update_mode"] in (0, 1) and x["face_update_mode"] == 0 for x in (h0, h1)),
      f"static {h0['static_update_mode']},{h1['static_update_mode']} face {h0['face_update_mode']},{h1['face_update_mode']}")
d0 = la["draw_calls"]; d1 = states["before-hidden"]["draw_calls"]; d2 = states["map-after-20-frames"]["draw_calls"]
check("hidden_page_renders_nothing", d1 >= d0 + 8 and abs(d2 - d0) <= 2, f"draw calls: white page {d0}, book shown {d1}, hidden {d2}")
hidden_page = imgs["07-hidden.png"][int(BAR_H) + 2:, :]
check("hidden_page_shows_plain_white_map", float(hidden_page.mean()) > 254, f"mean {float(hidden_page.mean()):.2f}")

# resumed: same book, frames run again, the same pixels
r0 = book["book-resumed"]; r1 = book["book-resumed-after-20-frames"]
check("book_resumes_with_state_intact", states["book-again"]["active"] == 1 and same_book(r0, e) and same_book(r1, e)
      and 0 <= r0["ticks"] - h1["ticks"] <= 6 and r1["ticks"] - r0["ticks"] >= 15, f"ticks frozen {h1['ticks']}, resumed {r0['ticks']} -> {r1['ticks']}")
check("resumed_pixels_identical_to_before_hiding", float(np.abs(imgs["08-resumed.png"] - imgs["06-before-hidden.png"]).mean()) < 0.5,
      f"mean abs diff {float(np.abs(imgs['08-resumed.png'] - imgs['06-before-hidden.png']).mean()):.3f}")

# resize: the desktop shrinks to fit the smaller page, the book inside it, the ink kept; restore brings the launch scale back
rs = states["resized"]; rt = book["resized"]; sz2 = rt["size"]
scale2 = min(1.0, sz2[0] / DESKTOP[0], sz2[1] / DESKTOP[1])
check("resize_shrinks_desktop_to_fit", rs["window"] == [1440, 900] and near(sz2[0], 1440, 1) and near(sz2[1], 900 - 161 * 1440 / 4180.0, 1.5)
      and near(rt["desktop_scale"], scale2, 1e-3) and rt["desktop_scale"] < 1 and rt["strokes"] == 1
      and rt["window_rect"]["x"] + rt["window_rect"]["w"] <= 1440.5 and rt["window_rect"]["y"] + rt["window_rect"]["h"] <= 900.5,
      f"tenant {sz2}, scale {rt['desktop_scale']}, window {rt['window_rect']}")
check("resized_screenshot_is_1440x900", imgs["09-resized.png"].shape[:2] == (900, 1440), str(imgs["09-resized.png"].shape))
check("restore_refits_back", states["restored"]["window"] == [1920, 1080] and near(book["restored"]["desktop_scale"], 1.0, 1e-6)
      and same_rect(book["restored"]["window_rect"], e["window_rect"]) and hashes["10-restored.png"] != hashes["09-resized.png"])

# pixels: the book's page is drawn (not white), white outside the window
page = region(imgs["01-book.png"], pg)
check("book_page_drawn", float(page.mean()) < 250 and float(page.std()) > 3, f"mean {float(page.mean()):.1f} std {float(page.std()):.1f}")
above = imgs["01-book.png"][int(BAR_H) + 2:int(wr["y"]) - 2, :]
check("page_outside_window_is_white", above.size > 0 and float(above.mean()) > 254, f"mean {float(above.mean()):.2f}")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
