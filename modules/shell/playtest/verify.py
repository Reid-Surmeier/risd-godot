#!/usr/bin/env python3
"""Independent verifier for a shell playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels (the films included), and checks the logged states
against the interface contract (six fixed tabs along the bottom — seven until the owner folded the
Phone Tab into the Playground desktop on 2026-09-14, ticket #62 — launch tab grown in then faded
in, the click dip and the page cross-fade with their timings, lazy tenants, freeze/resume after the
fade, no close on fixed tabs, the stub's blank page, resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

FIXED = ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground"]
SCALE = 1920 / 4180.0
BAR_H = 161 * SCALE
STUB_W = 180 * SCALE
PRESSED = (228, 218, 226)   # tab_strip's STUB_PRESSED tint on a white face
ACTIVE = (240, 252, 254)  # the active tab's white face under tab_strip's 12 % sea-blue tint (#45)
GREY = (160, 160, 160)      # the harness's grey tenant in playground

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {}
for e in log:
    if e["event"] == "state":
        states.setdefault(e["label"], e)
tenants = [e for e in log if e["event"] == "tenant"]
clicks = [e for e in log if e["event"] == "click"]
signals = [e for e in log if e["event"] == "signal"]
frames = {}
for e in log:
    if e["event"] == "frame":
        frames.setdefault(e["film"], []).append(e)
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def tenant(label, key):
    return next(e for e in tenants if e["label"] == label and e["key"] == key)

def face_spot(img, r):
    """The tab's white face just under the label row (source rows ~95..112 of 123): pressed tint shows here."""
    x0, x1 = int(r["x"] + r["w"] * 0.45), int(r["x"] + r["w"] * 0.6)
    y0, y1 = int(r["y"] + r["h"] * 0.78), int(r["y"] + r["h"] * 0.9)
    return img[y0:y1, x0:x1].reshape(-1, 3).mean(axis=0)

def near_rgb(v, rgb, tol=6):
    return all(abs(float(v[i]) - rgb[i]) <= tol for i in range(3))

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 10, str(sorted(shots)))
check("launch_screenshot_is_1920x1080", imgs["01-launch.png"].shape[:2] == (1080, 1920), str(imgs["01-launch.png"].shape))

# 1. launch state: six fixed tabs along the bottom, Collection active, its tenant alone created
la = states["launch"]
check("six_fixed_tabs_in_order", la["count"] == 6 and la["fixed_count"] == 6 and [t["key"] for t in la["tabs"]] == FIXED
      and all(t["fixed"] for t in la["tabs"]), str([t["key"] for t in la["tabs"]]))
check("labels_are_the_keys", [t["label"] for t in la["tabs"]] == FIXED)
check("bar_sits_at_the_bottom", abs(la["bar_rect"]["y"] - (1080 - BAR_H)) < 1 and abs(la["bar_rect"]["h"] - BAR_H) < 1
      and all(t["rect"]["y"] > 1080 - BAR_H for t in la["tabs"]) and all(t["rect"]["y"] + t["rect"]["h"] <= 1080 for t in la["tabs"]),
      f"bar {la['bar_rect']}")
check("collection_active_at_launch", la["active"] == 4 and la["tabs"][4]["page_visible"]
      and sum(t["page_visible"] for t in la["tabs"]) == 1 and not la["switching"] and not la["opening"])
check("no_close_rect_on_fixed_tabs", all(t["close_rect"]["w"] == 0 for t in la["tabs"]))
check("hidden_pages_frozen_at_launch", all(t["frozen"] != t["page_visible"] for t in la["tabs"]),
      str([(t["key"], t["frozen"]) for t in la["tabs"]]))
check("only_the_launch_tenant_is_created", la["tabs"][4]["tenant"] == "ok"
      and all(t["tenant"] is None for i, t in enumerate(la["tabs"]) if i != 4), str([t["tenant"] for t in la["tabs"]]))
check("tenant_state_missing_before_first_show", tenant("launch", "map")["code"] == "shell.tenant_missing"
      and tenant("launch", "collection")["ok"])
check("tabs_left_to_right_within_window", all(la["tabs"][i]["rect"]["x"] < la["tabs"][i + 1]["rect"]["x"] for i in range(5))
      and la["stub_rect"]["x"] + la["stub_rect"]["w"] < 1920 and la["stub_rect"]["x"] > la["tabs"][5]["rect"]["x"])
check("launch_page_area_white", float(imgs["01-launch.png"][:int(1080 - BAR_H) - 2].mean()) > 254)

# 2. the launch film: the Collection tab starts stub-sized with its page hidden and no tenant, grows to
#    its fitted width while `opening`, then the page shows and the tenant exists; the fade settles ~0.7 s in
lf = frames["launch"]; final_w = la["tabs"][4]["rect"]["w"]
widths = [f["tab_rect"]["w"] for f in lf]
check("launch_tab_starts_stub_sized", lf[0]["opening"] and abs(widths[0] - STUB_W) < 3 and not lf[0]["page_visible"]
      and lf[0]["tenant"] is None, f"w {widths[0]:.0f} (stub {STUB_W:.0f})")
check("launch_tab_grows_to_its_width", all(b >= a - 0.5 for a, b in zip(widths, widths[1:])) and abs(widths[-1] - final_w) < 0.5
      and any(STUB_W + 10 < w < final_w - 10 for w in widths), f"{[round(w) for w in widths]}")
first_shown = next((f for f in lf if f["page_visible"]), None)
check("page_shows_only_after_the_grow_settles", first_shown is not None and not first_shown["opening"]
      and all(not f["page_visible"] and f["tenant"] is None for f in lf if f["opening"]),
      f"first shown at frame {first_shown['n'] if first_shown else None}")
grow_frame = next(f for f in lf if STUB_W + 10 < f["tab_rect"]["w"] < final_w - 10)
gi = np.array(Image.open(out / grow_frame["file"]).convert("RGB")).astype(int)
r5 = la["tabs"][5]["rect"]; gr = grow_frame["tab_rect"]
gap = gi[int(gr["y"] + gr["h"] * 0.5):int(gr["y"] + gr["h"] * 0.6), int(gr["x"] + gr["w"] + 6):int(r5["x"] - 2)]
check("grow_frame_shows_the_bar_in_the_gap_left_of_playground", gap.size > 0 and float(gap.std()) > 3 and float(gap.mean()) > 200,
      f"gap {gap.shape} std {float(gap.std()):.1f}")
ls = next((s for s in signals if s["signal"] == "switch_settled" and s["index"] == 4), None)
check("launch_settles_after_press_grow_and_fade", ls is not None and 550 <= ls["t_ms"] <= 1000, f"{ls['t_ms'] if ls else None} ms")
tc = next((s for s in signals if s["signal"] == "tenant_created" and s["key"] == "collection"), None)
check("launch_tenant_created_at_settle", tc is not None and ls is not None and 350 <= tc["t_ms"] <= ls["t_ms"], f"{tc['t_ms'] if tc else None} ms")

# 3. click Map: the dip (pressed tint on the clicked tab within PRESS_SECONDS, gone after), the page cross-fade
#    (switching for ~FADE_SECONDS, settled within 0.45 s), the tenant created and running after
mp = states["map"]
check("click_map_shows_map_page", mp["active"] == 0 and mp["tabs"][0]["page_visible"] and mp["tabs"][0]["tenant"] == "ok"
      and not mp["tabs"][4]["page_visible"] and mp["tabs"][4]["frozen"] and not mp["tabs"][0]["frozen"] and not mp["switching"])
t_map = next(e["t_ms"] for e in clicks if e["what"] == "map tab")
mf = frames["map"]; r0 = states["pre-map"]["tabs"][0]["rect"]
early = [f for f in mf if f["t_ms"] - t_map <= 100]
late = [f for f in mf if f["t_ms"] - t_map >= 220]
spots = {f["n"]: face_spot(np.array(Image.open(out / f["file"]).convert("RGB")).astype(int), r0) for f in mf}
check("clicked_tab_shows_pressed_tint_within_100ms", len(early) > 0 and any(near_rgb(spots[f["n"]], PRESSED, 10) for f in early),
      f"early frames {[(f['t_ms'] - t_map, [round(v) for v in spots[f['n']]]) for f in early]}")
check("clicked_tab_white_again_after_the_dip", len(late) > 0 and all(near_rgb(spots[f["n"]], ACTIVE, 3) for f in late),
      f"late frames {[(f['t_ms'] - t_map, [round(v) for v in spots[f['n']]]) for f in late]}")
check("dip_reported_then_released", any(f["pressed"] == 0 for f in early) and all(f["pressed"] == -1 for f in late))
sw = next((s for s in signals if s["signal"] == "switch_settled" and s["index"] == 0 and s["t_ms"] > t_map), None)
check("page_switch_settles_in_about_200ms", sw is not None and 150 <= sw["t_ms"] - t_map <= 450 and any(f["switching"] for f in mf)
      and all(not f["switching"] for f in mf if f["t_ms"] > sw["t_ms"]), f"{sw['t_ms'] - t_map if sw else None} ms")
a, b = tenant("map-shown", "map"), tenant("map-after-20-frames", "map")
check("shown_tenant_process_runs", a["ok"] and b["ticks"] - a["ticks"] >= 15, f"{a['ticks']} -> {b['ticks']}")
sz = a["size"]
check("tenant_fills_page_area", abs(sz[0] - 1920) < 1 and abs(sz[1] - (1080 - BAR_H)) < 1.5, str(sz))

# 4. Sketchbook: after the fade the Map page is frozen; the shown page runs and hears the key
sk = states["sketchbook"]
c, d = tenant("map-hidden", "map"), tenant("map-hidden-after-20-frames", "map")
check("hidden_map_page_frozen_after_fade", sk["active"] == 1 and sk["tabs"][0]["frozen"] and not sk["tabs"][0]["page_visible"]
      and not sk["switching"])
check("hidden_tenant_process_stops", d["ticks"] == c["ticks"], f"{c['ticks']} -> {d['ticks']} over 20 frames")
check("hidden_tenant_gets_no_input", d["inputs"] == c["inputs"] and any(e["event"] == "key" for e in log),
      f"inputs {c['inputs']} -> {d['inputs']}")
s0, s1 = tenant("sketchbook-shown", "sketchbook"), tenant("sketchbook-after-20-frames", "sketchbook")
check("shown_sketchbook_runs_and_hears_the_key", s1["ticks"] - s0["ticks"] >= 15 and s1["inputs"] - s0["inputs"] >= 1,
      f"ticks {s0['ticks']}->{s1['ticks']}, inputs {s0['inputs']}->{s1['inputs']}")
e, f = tenant("map-resumed", "map"), tenant("map-resumed-after-20-frames", "map")
check("map_resumes_with_state_intact", 0 <= e["ticks"] - d["ticks"] <= 8 and f["ticks"] - e["ticks"] >= 15 and states["map-again"]["active"] == 0,
      f"frozen at {d['ticks']}, resumed {e['ticks']} -> {f['ticks']}")

# 5. a fixed tab does not close
cf = next(e for e in log if e["event"] == "close_fixed"); fk = states["fixed-kept"]
check("fixed_close_refused_by_interface", not cf["ok"] and cf["code"] == "shell.tab_fixed", cf["code"])
check("fixed_close_click_did_nothing", fk["count"] == 6 and fk["active"] == 0
      and any(e["what"].startswith("where the close button") for e in clicks))

# 6. the stub's blank page (seventh tab), its close, landing on Playground with the Callable-built grey tenant
sb = states["stub-blank"]
check("stub_opens_blank_page_with_close", sb["count"] == 7 and sb["tabs"][6]["label"] == "blank_page"
      and not sb["tabs"][6]["fixed"] and sb["tabs"][6]["close_rect"]["w"] > 0 and sb["active"] == 6
      and sb["tabs"][6]["page_visible"], f"count {sb['count']}")
ph = states["grey"]
check("closing_blank_lands_on_playground", ph["count"] == 6 and ph["active"] == 5 and ph["tabs"][5]["page_visible"])
check("playground_callable_tenant_created_on_first_show", tenant("grey-shown", "playground")["ok"] and ph["tabs"][5]["tenant"] == "ok")
page = imgs["06-grey.png"][:int(1080 - BAR_H) - 2, :]
check("playground_page_is_the_grey_tenant", near_rgb(page.reshape(-1, 3).mean(axis=0), GREY, 2) and float(page.std()) < 1,
      f"mean {[round(v) for v in page.reshape(-1, 3).mean(axis=0)]}")

# 7. Playground (grey) -> Collection: the cross-fade in pixels (grey to white through in-between greys), the dip on Collection
t_col = next(e["t_ms"] for e in clicks if e["what"] == "collection tab")
sf = frames["switch"]; r4 = la["tabs"][4]["rect"]
centre = {}
for fr in sf:
    im = np.array(Image.open(out / fr["file"]).convert("RGB")).astype(int)
    centre[fr["n"]] = float(im[int((1080 - BAR_H) / 2) - 20:int((1080 - BAR_H) / 2) + 20, 940:980].mean())
    spots[("switch", fr["n"])] = face_spot(im, r4)
vals = [centre[fr["n"]] for fr in sf]
check("page_cross_fades_through_in_between_greys", any(GREY[0] + 8 < v < 247 for v in vals) and vals[-1] > 254
      and all(b >= a - 0.5 for a, b in zip(vals, vals[1:])), f"{[round(v) for v in vals]}")
early = [fr for fr in sf if fr["t_ms"] - t_col <= 100]; late = [fr for fr in sf if fr["t_ms"] - t_col >= 220]
check("collection_tab_dips_on_click", len(early) > 0 and any(near_rgb(spots[("switch", fr["n"])], PRESSED, 10) for fr in early)
      and all(near_rgb(spots[("switch", fr["n"])], ACTIVE, 3) for fr in late),
      f"{[(fr['t_ms'] - t_col, [round(v) for v in spots[('switch', fr['n'])]]) for fr in sf]}")
sw2 = next((s for s in signals if s["signal"] == "switch_settled" and s["index"] == 4 and s["t_ms"] > t_col), None)
check("grey_to_collection_settles_in_about_200ms", sw2 is not None and 150 <= sw2["t_ms"] - t_col <= 450, f"{sw2['t_ms'] - t_col if sw2 else None} ms")
co = states["collection"]
check("grey_page_frozen_after_the_fade", co["active"] == 4 and co["tabs"][5]["frozen"] and not co["tabs"][5]["page_visible"] and not co["switching"])

# 8. Video Player: no tenant in this harness, a plain white page
pg = states["untenanted"]
check("untenanted_tab_has_no_tenant", pg["active"] == 3 and pg["tabs"][3]["page_visible"] and pg["tabs"][3]["tenant"] is None
      and tenant("untenanted-shown", "video_player")["code"] == "shell.tenant_missing")
check("untenanted_page_is_plain_white", float(imgs["08-untenanted.png"][:int(1080 - BAR_H) - 2].mean()) > 254)

# 9. resize: the bar re-fits along the bottom, the visible tenant fills the page above it
rs = states["resized"]; rt = tenant("resized", "collection"); bar_h2 = 161 * 1440 / 4180.0
check("resize_refits_bar_and_tenant", rs["window"] == [1440, 900] and rs["stub_rect"]["x"] + rs["stub_rect"]["w"] < 1440
      and abs(rs["bar_rect"]["y"] - (900 - bar_h2)) < 1 and abs(rt["size"][0] - 1440) < 1 and abs(rt["size"][1] - (900 - bar_h2)) < 1.5,
      f"window {rs['window']}, bar {rs['bar_rect']}, tenant {rt['size']}")
check("resized_screenshot_is_1440x900", imgs["09-resized.png"].shape[:2] == (900, 1440), str(imgs["09-resized.png"].shape))
check("restore_refits_back", states["restored"]["window"] == [1920, 1080] and hashes["10-restored.png"] != hashes["09-resized.png"])

# pixels: the bar band at the bottom spans the full width (the right cluster's dark glyphs at the right edge),
# the page area above it is white at launch, no close "x" on the active fixed tab
bar = imgs["01-launch.png"][int(1080 - BAR_H):]
check("bar_spans_full_width_at_bottom", (bar[:, 1880:].max(axis=2) < 150).sum() > 5 and float(imgs["01-launch.png"][int(1080 - BAR_H) - 40:int(1080 - BAR_H) - 2].mean()) > 254)
t4 = la["tabs"][4]["rect"]; sc = t4["h"] / 123.0
cx, cy = t4["x"] + t4["w"] - (80 + 22) * sc, t4["y"] + (24 + 22) * sc
spot = imgs["01-launch.png"][int(cy - 4):int(cy + 26), int(cx - 4):int(cx + 26)]
chan = max(float(spot[..., i].std()) for i in range(3))  # per channel: a flat tinted patch is not grey
check("active_fixed_tab_draws_no_close_button", chan < 3, f"std {chan:.1f}")
check("stub_blank_shot_differs_from_launch", hashes["05-stub-blank.png"] != hashes["01-launch.png"])

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
