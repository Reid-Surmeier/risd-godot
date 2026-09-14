#!/usr/bin/env python3
"""Independent verifier for a video_player playtest run. Never trusts the harness's own summary:
re-hashes the five preview videos against media/manifest.json, re-hashes every screenshot,
re-reads pixels (the video body changes while playing and holds still while paused, fullscreen
covers the page, the hidden page is white) and checks the logged states against the Tenant
contract and ticket #31 (created on first show, fills the page, the viewer fitted to it, eight
tiles with five linked, a tile click autoplays its mapped video at 0:00, pause, seek by a real
drag on the knob, mute, the volume knob, fullscreen filling the Page, the keys, Save, the title
drag and its clamp, paused and frozen while hidden with every event ignored, resumed on show,
re-fitted on resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
MANIFEST = json.loads((HERE.parent / "media" / "manifest.json").read_text())
BAR_H = 161 * 1920 / 4180.0
CANVAS = (1536, 1632)      # video_player.gd CANVAS_SIZE
MARGIN = 24
VIDEO_RECT = (82, 106, 1366, 732)
TILE0, TILE_STEP, TILE = 306, 111, 110
IDS = [v["id"] for v in MANIFEST["videos"]]   # tile order 1..5
LENGTHS = {v["id"]: v["preview"]["duration_seconds"] for v in MANIFEST["videos"]}

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {}
for e in log:
    if e["event"] == "state":
        states.setdefault(e["label"], e)
vp = {e["label"]: e for e in log if e["event"] == "player"}
gestures = {e["what"]: e for e in log if e["event"] in ("drag", "click", "key")}
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def near(a, b, tol):
    return abs(a - b) <= tol

def inside(pt, r):
    return r["x"] <= pt[0] <= r["x"] + r["w"] and r["y"] <= pt[1] <= r["y"] + r["h"]

def same_rect(a, b, tol=0.5):
    return all(near(a[k], b[k], tol) for k in "xywh")

def crop(img, r):
    return img[int(r["y"]):int(r["y"] + r["h"]), int(r["x"]):int(r["x"] + r["w"])]

# the media are what the manifest says
media_ok = True
for v in MANIFEST["videos"]:
    p = HERE.parent / "media" / v["preview"]["file"]
    media_ok = media_ok and p.exists() and hashlib.sha256(p.read_bytes()).hexdigest() == v["preview"]["sha256"] and p.stat().st_size == v["preview"]["bytes"]
check("five_preview_videos_match_manifest", media_ok and len(MANIFEST["videos"]) == 5)

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 13, str(sorted(shots)))
check("shown_screenshot_is_1920x1080", imgs["01-shown.png"].shape[:2] == (1080, 1920), str(imgs["01-shown.png"].shape))

# created lazily on first show, through the Shell
la = states["launch"]
check("no_video_tenant_at_launch", la["active"] == 4 and la["tabs"][3]["tenant"] is None and la["tabs"][3]["frozen"]
      and vp["launch"]["code"] == "shell.tenant_missing")
vs = states["video"]; a = vp["shown"]
check("click_video_tab_creates_and_shows_player", vs["active"] == 3 and vs["tabs"][3]["tenant"] == "ok" and vs["tabs"][3]["page_visible"]
      and not vs["tabs"][3]["frozen"] and a["ok"] and "video player tab" in gestures, str(vs["tabs"][3]))
sz = a["size"]
check("tenant_fills_page_area", near(sz[0], 1920, 1) and near(sz[1], 1080 - BAR_H, 1.5), str(sz))

# the viewer: the whole 1536x1632 canvas fitted to the page with a margin, centred
scale = min(1.0, (sz[0] - 2 * MARGIN) / CANVAS[0], (sz[1] - 2 * MARGIN) / CANVAS[1])
vr = a["viewer"]["rect"]
check("viewer_fits_page_centred", near(a["viewer"]["scale"], scale, 1e-6) and near(vr["w"], CANVAS[0] * scale, 1) and near(vr["h"], CANVAS[1] * scale, 1)
      and near(vr["x"], (sz[0] - vr["w"]) / 2, 1) and near(vr["y"], BAR_H + (sz[1] - vr["h"]) / 2, 1.5) and vr["y"] >= BAR_H - 0.5
      and vr["y"] + vr["h"] <= BAR_H + sz[1] + 0.5, f"scale {a['viewer']['scale']:.4f} rect {vr}")
vid = a["video_rect"]
check("video_body_at_its_source_rect_in_the_viewer", near(vid["x"], vr["x"] + VIDEO_RECT[0] * scale, 1) and near(vid["y"], vr["y"] + VIDEO_RECT[1] * scale, 1)
      and near(vid["w"], VIDEO_RECT[2] * scale, 1) and near(vid["h"], VIDEO_RECT[3] * scale, 1), str(vid))
tiles = a["tiles"]
check("eight_tiles_five_enabled_in_a_row", a["thumbnail_count"] == 8 and a["linked_video_count"] == 5 and len(tiles) == 8
      and [t["enabled"] for t in tiles] == [True] * 5 + [False] * 3
      and all(near(t["rect"]["x"], vr["x"] + (TILE0 + i * TILE_STEP) * scale, 1) and near(t["rect"]["w"], TILE * scale, 1)
              and near(t["rect"]["y"], vr["y"] + 1381 * scale, 1) for i, t in enumerate(tiles)), str([t["enabled"] for t in tiles]))
check("controls_have_rects_inside_the_viewer", all(a["controls"][k]["w"] > 0 and a["controls"][k]["h"] > 0
      and a["controls"][k]["x"] >= vr["x"] - 0.5 and a["controls"][k]["x"] + a["controls"][k]["w"] <= vr["x"] + vr["w"] + 0.5
      for k in ("play", "seek", "seek_knob", "timer", "mute", "volume", "volume_knob", "fullscreen", "save", "minimize", "title_bar")))

# the first video autoplays from 0:00 and its position moves
check("first_video_autoplays_from_start", a["selected_video"] == 0 and a["video_id"] == IDS[0] and a["playing"] and not a["paused"]
      and a["stream_position"] < 1.0 and near(a["stream_length"], LENGTHS[IDS[0]], 1), f"{a['video_id']} at {a['stream_position']:.2f}/{a['stream_length']:.1f}")
p30 = vp["playing-30"]
check("position_advances_while_playing", p30["stream_position"] > a["stream_position"] + 0.2 and p30["ticks"] > a["ticks"] + 25,
      f"{a['stream_position']:.2f} -> {p30['stream_position']:.2f} over {p30['ticks'] - a['ticks']} ticks")

# a tile click loads the mapped video at 0:00 and autoplays
k = gestures["tile 3"]; t3 = vp["tile-3"]; t30 = vp["tile-3-30"]
check("tile_click_lands_on_tile_3", inside((k["x"], k["y"]), tiles[2]["rect"]))
check("tile_3_plays_its_mapped_video_from_start", t3["selected_video"] == 2 and t3["video_id"] == IDS[2] and t3["playing"] and t3["stream_position"] < 0.5
      and near(t3["stream_length"], LENGTHS[IDS[2]], 1) and t30["stream_position"] > t3["stream_position"] + 0.2 and t30["video_id"] == IDS[2],
      f"{t3['video_id']} {t3['stream_position']:.2f} -> {t30['stream_position']:.2f}")
body_a, body_b = crop(imgs["03-tile-3.png"], t30["video_rect"]), crop(imgs["06-seeked.png"], t30["video_rect"])
check("video_body_pixels_change_between_positions", float(np.abs(body_a - body_b).mean()) > 5 and float(body_a.mean()) < 250,
      f"mean abs diff {float(np.abs(body_a - body_b).mean()):.1f}")

# pause holds the position and the pixels; again resumes
kp = gestures["play/pause"]; pz = vp["paused"]; pz20 = vp["paused-20"]; rs = vp["resumed"]
check("pause_click_lands_on_play_control", inside((kp["x"], kp["y"]), t30["controls"]["play"]))
check("pause_holds_position", pz["paused"] and not pz["playing"] and pz20["paused"] and near(pz20["stream_position"], pz["stream_position"], 1e-3)
      and pz20["ticks"] > pz["ticks"] + 15, f"{pz['stream_position']:.3f} -> {pz20['stream_position']:.3f} over {pz20['ticks'] - pz['ticks']} ticks")
body_p, body_q = crop(imgs["04-paused.png"], pz["video_rect"]), crop(imgs["05-paused-20.png"], pz["video_rect"])
check("video_body_pixels_hold_while_paused", float(np.abs(body_p - body_q).mean()) < 0.5, f"mean abs diff {float(np.abs(body_p - body_q).mean()):.3f}")
check("pause_again_resumes", rs["playing"] and not rs["paused"] and rs["stream_position"] >= pz20["stream_position"])

# seek by a real drag on the knob: the position lands where the knob was dropped
d = gestures["drag the seek knob right"]; sk = vp["seeked"]
track, knob = rs["controls"]["seek"], rs["controls"]["seek_knob"]
ratio0 = (knob["x"] - track["x"]) / (track["w"] - knob["w"])
expect = min(1.0, max(0.0, ratio0 + d["relative_total"][0] / (track["w"] - knob["w"])))
check("seek_drag_starts_on_the_knob", inside(d["from"], knob) and d["relative_total"][0] > 30, f"from {d['from']} knob {knob}")
check("seek_drag_moves_position_to_the_knob", near(sk["stream_position"] / sk["stream_length"], expect, 0.02) and sk["stream_position"] > rs["stream_position"] + 10
      and sk["playing"] and sk["last_action"].startswith("seek"), f"expected {expect:.3f}, got {sk['stream_position'] / sk['stream_length']:.3f} ({sk['stream_position']:.1f} s)")

# mute by its control; the volume knob sets the gain and unmutes
km = gestures["mute"]; mu = vp["muted"]
check("mute_click_lands_on_mute_control", inside((km["x"], km["y"]), sk["controls"]["mute"]))
check("mute_silences", mu["muted"] and near(mu["volume"], 0.0, 1e-6) and mu["playing"])
dv = gestures["drag the volume knob left"]; vo = vp["volume"]
vtrack, vknob = mu["controls"]["volume"], mu["controls"]["volume_knob"]
vratio0 = (vknob["x"] - vtrack["x"]) / (vtrack["w"] - vknob["w"])
vexpect = min(1.0, max(0.0, vratio0 + dv["relative_total"][0] / (vtrack["w"] - vknob["w"])))
check("volume_drag_starts_on_the_knob", inside(dv["from"], vknob) and dv["relative_total"][0] < -15)
check("volume_drag_sets_gain_and_unmutes", near(vo["volume"], vexpect, 0.03) and not vo["muted"] and 0.1 < vo["volume"] < 0.9,
      f"expected {vexpect:.3f}, got {vo['volume']:.3f}")

# fullscreen fills the Page (not the OS window), keeps playing; F restores the viewer
kf = gestures["fullscreen"]; fs = vp["fullscreen"]; fs20 = vp["fullscreen-20"]; wd = vp["windowed"]
check("fullscreen_click_lands_on_its_control", inside((kf["x"], kf["y"]), vo["controls"]["fullscreen"]))
check("fullscreen_fills_the_page", fs["fullscreen"] and same_rect(fs["video_rect"], {"x": 0, "y": BAR_H, "w": sz[0], "h": sz[1]}, 1.5)
      and states["video"]["window"] == [1920, 1080], str(fs["video_rect"]))
check("fullscreen_keeps_playing", fs["playing"] and fs20["playing"] and fs20["stream_position"] > fs["stream_position"] + 0.2 and fs["video_id"] == vo["video_id"],
      f"{fs['stream_position']:.2f} -> {fs20['stream_position']:.2f}")
page_fs = imgs["07-fullscreen.png"][int(BAR_H) + 2:, :]
strip_fs, strip_w = imgs["07-fullscreen.png"][:int(BAR_H) - 2, :], imgs["08-windowed.png"][:int(BAR_H) - 2, :]
check("fullscreen_pixels_cover_the_page_under_the_strip", float((page_fs.min(axis=2) > 250).mean()) < 0.5 and float(np.abs(strip_fs - strip_w).mean()) < 0.5,
      f"white fraction {float((page_fs.min(axis=2) > 250).mean()):.3f}, strip diff {float(np.abs(strip_fs - strip_w).mean()):.3f}")
check("f_key_restores_the_viewer", "F key" in gestures and not wd["fullscreen"] and same_rect(wd["video_rect"], vo["video_rect"]) and wd["playing"]
      and same_rect(wd["viewer"]["rect"], vo["viewer"]["rect"]), str(wd["video_rect"]))
outside = np.concatenate([imgs["08-windowed.png"][int(BAR_H) + 2:, :int(vr["x"]) - 2].reshape(-1, 3), imgs["08-windowed.png"][int(BAR_H) + 2:, int(vr["x"] + vr["w"]) + 2:].reshape(-1, 3)])
check("white_desktop_outside_the_viewer", float(outside.mean()) > 254 and float(crop(imgs["08-windowed.png"], vr).mean()) < 245, f"outside mean {float(outside.mean()):.2f}")

# the keys with the page shown
ks = vp["key-space"]; ks2 = vp["key-space-again"]; kr = vp["key-right"]; k2 = vp["key-2"]
check("space_pauses_and_resumes", ks["paused"] and not ks["playing"] and ks2["playing"] and not ks2["paused"])
check("right_seeks_five_seconds", near(kr["stream_position"], ks2["stream_position"] + 5.0, 0.3) and kr["last_action"] == "seek +5s",
      f"{ks2['stream_position']:.2f} -> {kr['stream_position']:.2f}")
check("key_2_picks_the_second_tile", k2["selected_video"] == 1 and k2["video_id"] == IDS[1] and k2["playing"] and k2["stream_position"] < 0.5
      and near(k2["stream_length"], LENGTHS[IDS[1]], 1), f"{k2['video_id']} {k2['stream_position']:.2f}/{k2['stream_length']:.0f}")
ksv = gestures["save"]; sv = vp["saved"]
check("save_click_toggles_session_state", inside((ksv["x"], ksv["y"]), k2["controls"]["save"]) and sv["saved"] and not k2["saved"])

# the viewer drags by its title bar and stops at the page's edge with 200 px of the bar inside
td = gestures["drag the viewer by its title bar"]; mv = vp["viewer-moved"]
check("title_drag_starts_on_title_bar", inside(td["from"], sv["controls"]["title_bar"]))
check("title_drag_moves_viewer_by_the_drag", near(mv["viewer"]["position"][0], sv["viewer"]["position"][0] + td["relative_total"][0], 0.5)
      and near(mv["viewer"]["position"][1], sv["viewer"]["position"][1] + td["relative_total"][1], 0.5) and mv["drag_intent_count"] == sv["drag_intent_count"] + 1
      and near(mv["video_rect"]["x"], sv["video_rect"]["x"] + td["relative_total"][0], 0.5) and mv["video_id"] == sv["video_id"] and mv["playing"] and not mv["dragging_viewer"],
      f"{sv['viewer']['position']} -> {mv['viewer']['position']} by {td['relative_total']}")
td2 = gestures["drag the title bar past the page's bottom-right corner"]; cl = vp["viewer-clamped"]
s = cl["viewer"]["scale"]
check("viewer_drag_clamps_to_keep_title_bar_reachable", td2["to"][0] > sz[0] and td2["to"][1] > BAR_H + sz[1]
      and near(cl["viewer"]["position"][0], sz[0] - 82 * s - 200, 0.5) and near(cl["viewer"]["position"][1], sz[1] - 105 * s, 0.5)
      and cl["controls"]["title_bar"]["x"] < sz[0] - 150, f"position {cl['viewer']['position']} page {sz}")

# hidden: frozen and paused, every event ignored; shown again: resumed from the same position
bh = vp["before-hidden"]; mp = states["map"]; hd = vp["hidden"]; hd2 = vp["hidden-after-events"]
check("map_tab_hides_and_freezes_video_page", mp["active"] == 0 and not mp["tabs"][3]["page_visible"] and mp["tabs"][3]["frozen"] and mp["tabs"][3]["tenant"] == "ok")
check("hidden_page_pauses_video", hd["hidden_paused"] and hd["paused"] and not hd["playing"] and bh["playing"] and hd["last_action"] == "paused by hide")
check("hidden_page_ignores_keys_and_click", all(g in gestures for g in ("Space key while hidden", "Right key while hidden", "3 key while hidden", "where tile 4 was, while hidden"))
      and hd2["ticks"] == hd["ticks"] and near(hd2["stream_position"], hd["stream_position"], 1e-3) and hd2["selected_video"] == hd["selected_video"]
      and hd2["interaction_count"] == hd["interaction_count"] and hd2["paused"] and hd2["viewer"]["position"] == hd["viewer"]["position"]
      and states["map-after-30-frames"]["active"] == 0, f"ticks {hd['ticks']} -> {hd2['ticks']}, position {hd['stream_position']:.3f} -> {hd2['stream_position']:.3f}")
hidden_page = imgs["11-hidden.png"][int(BAR_H) + 2:, :]
check("hidden_page_shows_plain_white_map", float(hidden_page.mean()) > 254, f"mean {float(hidden_page.mean()):.2f}")
va = states["video-again"]; ro = vp["resumed-on-show"]; r30 = vp["resumed-30"]
check("video_tab_again_resumes_playing", va["active"] == 3 and not va["tabs"][3]["frozen"] and ro["playing"] and not ro["hidden_paused"] and not ro["paused"]
      and ro["last_action"] == "resumed on show" and ro["stream_position"] >= hd2["stream_position"] - 1e-3 and ro["stream_position"] < hd2["stream_position"] + 1.0
      and r30["stream_position"] > ro["stream_position"] + 0.2 and r30["ticks"] > ro["ticks"] + 25 and ro["selected_video"] == hd["selected_video"]
      and ro["viewer"]["position"] == bh["viewer"]["position"] and ro["saved"] == bh["saved"], f"{hd2['stream_position']:.2f} -> {ro['stream_position']:.2f} -> {r30['stream_position']:.2f}")

# resize: the tenant fills the smaller page, the viewer re-fits and stays reachable
rz = vp["resized"]; rst = vp["restored"]
bar_small = BAR_H * 1440 / 1920
scale_small = min(1.0, (1440 - 2 * MARGIN) / CANVAS[0], (900 - bar_small - 2 * MARGIN) / CANVAS[1])
check("resize_refits_viewer_to_smaller_page", states["resized"]["window"] == [1440, 900] and near(rz["size"][0], 1440, 1) and near(rz["size"][1], 900 - bar_small, 1.5)
      and near(rz["viewer"]["scale"], scale_small, 1e-4) and rz["viewer"]["position"][0] <= rz["size"][0] - 82 * scale_small - 200 + 0.5
      and rz["viewer"]["position"][1] <= rz["size"][1] - 105 * scale_small + 0.5 and rz["playing"] and imgs["13-resized.png"].shape[:2] == (900, 1440),
      f"scale {rz['viewer']['scale']:.4f} (expected {scale_small:.4f}) position {rz['viewer']['position']}")
check("restore_refits_viewer_to_launch_scale", near(rst["viewer"]["scale"], scale, 1e-6) and near(rst["size"][0], 1920, 1) and rst["playing"])

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL", f"{sum(r['pass'] for r in results.values())}/{len(results)}")
sys.exit(0 if ok else 1)
