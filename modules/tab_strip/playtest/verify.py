#!/usr/bin/env python3
"""Independent verifier for a tab_strip playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels, and checks the logged states against the
interface contract (timings, counts, labels, page visibility, truncation, close).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

SCALE = 1920 / 4180.0   # demo.gd: bar fitted to the 1920 px playtest window
RIGHT_CLUSTER_W = 1920  # layout.json
ICONS_OFFSET = 456
FULL_TAB_W = 640

out = Path(sys.argv[1])
rep = json.loads((out / "report.json").read_text())
log = rep["log"]
states = {e["label"]: e for e in log if e["event"] == "state"}
signals = [e for e in log if e["event"] == "signal"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 15, str(sorted(shots)))
check("mid_grow_differs_from_initial", hashes["01-initial.png"] != hashes["02-mid-grow.png"])
check("connecting_differs_from_mid_grow", hashes["02-mid-grow.png"] != hashes["03-connecting.png"])
check("blank_page_differs_from_connecting", hashes["03-connecting.png"] != hashes["04-blank-page.png"])

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
check("full_size_tabs_not_truncated", not states["blank-page"]["tabs"][0]["truncated"] and not states["blank-page"]["tabs"][1]["truncated"])

def t(sig, idx=1):
    return next((e["t_ms"] for e in signals if e["signal"] == sig and e["index"] == idx), None)
grow = (t("tab_settled") or 0) - (t("tab_opened") or 0); title = (t("tab_titled") or 0) - (t("tab_settled") or 0)
check("grow_took_about_500ms", 430 <= grow <= 650, f"{grow} ms")
check("title_swap_after_about_950ms", 880 <= title <= 1100, f"{title} ms")

check("click_tab0_shows_page0", states["selected-0"]["active"] == 0 and states["selected-0"]["tabs"][0]["page_visible"]
      and not states["selected-0"]["tabs"][1]["page_visible"])
check("click_tab1_shows_page1", states["selected-1"]["active"] == 1 and states["selected-1"]["tabs"][1]["page_visible"])
check("close_button_on_every_tab", all(tb["close_rect"]["size"]["x"] > 0 for tb in states["selected-1"]["tabs"]))
check("third_tab_opened_from_moved_stub", states["third-tab"]["count"] == 3 and states["third-tab"]["tabs"][2]["label"] == "blank_page")

full = states["full-row"]; fill = next(e for e in log if e["event"] == "fill")
max_right = full["bar_width"] - RIGHT_CLUSTER_W + ICONS_OFFSET - 40  # bar_width is 3135 now
check("row_fills_then_refuses", full["count"] >= 3 and "refused" in fill["result"], fill["result"])
check("full_row_tabs_shrunk_not_overflowed", all(tb["x"] + tb["w"] <= max_right + 1 for tb in full["tabs"]) and full["tabs"][-1]["w"] < FULL_TAB_W,
      f"{full['count']} tabs, last w={full['tabs'][-1]['w']:.0f}, max_right={max_right:.0f}")
check("shrunk_labels_truncated_with_dots", all(tb["truncated"] for tb in full["tabs"] if tb["label"] == "blank_page"),
      f"{sum(tb['truncated'] for tb in full['tabs'])}/{full['count']} truncated")

cl = states["closed-last"]
check("close_button_removed_active_tab", cl["count"] == full["count"] - 1 and cl["active"] == cl["count"] - 1
      and sum(tb["page_visible"] for tb in cl["tabs"]) == 1, f"{full['count']} -> {cl['count']}, active {cl['active']}")
clicks = [e for e in log if e["event"] == "click"]
t_click = next(e["t_ms"] for e in clicks if e["what"] == "close button of active tab")
t_closed = next((e["t_ms"] for e in signals if e["signal"] == "tab_closed"), None)
check("close_animates_before_removal", t_closed is not None and 250 <= t_closed - t_click <= 600,
      f"{(t_closed or 0) - t_click} ms from click to tab_closed (fold is 300 ms)")
cs = states["closed-second"]
check("close_second_tab_selects_left_neighbour", cs["count"] == cl["count"] - 1 and cs["active"] == 0
      and cs["tabs"][0]["page_visible"], f"count {cs['count']}, active {cs['active']}")
check("closed_row_regrew", cs["tabs"][-1]["w"] > cl["tabs"][-1]["w"] or cs["tabs"][-1]["w"] == FULL_TAB_W,
      f"{cl['tabs'][-1]['w']:.0f} -> {cs['tabs'][-1]['w']:.0f}")

ac = states["all-closed"]; ro = states["reopened"]
check("every_tab_can_close", ac["count"] == 0 and ac["active"] == -1, f"count {ac['count']}")
check("stub_reopens_after_empty", ro["count"] == 1 and ro["tabs"][0]["label"] == "blank_page" and ro["tabs"][0]["page_visible"], f"count {ro['count']}")

fo = states["fixed-open"]; fx = next(e for e in log if e["event"] == "fixed_open"); ft = fo["tabs"][fx["index"]]
check("fixed_tab_opened_on_callers_page", fx["ok"] and fx["page_in_stack"] and fo["count"] == 2 and ft["label"] == "map"
      and ft["fixed"] and ft["page_visible"] and not fo["tabs"][0]["fixed"], f"count {fo['count']}, label {ft['label']}")
check("fixed_tab_has_no_close_rect", ft["close_rect"]["size"]["x"] == 0 and ft["close_rect"]["size"]["y"] == 0)
fc = next(e for e in log if e["event"] == "fixed_close"); fk = states["fixed-kept"]
check("fixed_close_refused_by_interface", not fc["ok"] and fc["code"] == "tab_strip.tab_fixed", fc["code"])
check("fixed_close_click_did_nothing", fk["count"] == 2 and fk["tabs"][1]["fixed"] and fk["active"] == 1
      and any(e["what"].startswith("where the close button") for e in clicks), f"count {fk['count']}")
afs = states["after-fixed-stub"]
check("phone_key_without_label_opens_icon_only", afs["tabs"][2]["label"] == "phone" and afs["tabs"][2]["fixed"]
      and not afs["tabs"][2]["truncated"])
check("stub_still_opens_blank_after_fixed", afs["count"] == 4 and afs["tabs"][3]["label"] == "blank_page"
      and not afs["tabs"][3]["fixed"] and afs["tabs"][3]["close_rect"]["size"]["x"] > 0 and afs["tabs"][3]["page_visible"],
      f"count {afs['count']}, last {afs['tabs'][-1]['label']}")

def region(img, x0, y0, x1, y1):
    return img[int(y0 * SCALE):int(y1 * SCALE), int(x0 * SCALE):int(x1 * SCALE)]
# the first tab active in both (the tint is the active state, #45), above the bottom line, which appears once the tab is inactive
a = region(imgs["01-initial.png"], 261, 27, 700, 150); b = region(imgs["05-selected-0.png"], 261, 27, 700, 150)
check("first_tab_pixels_identical", float(np.abs(a - b).mean()) < 0.5, f"mean abs diff {float(np.abs(a-b).mean()):.2f}")
c = region(imgs["01-initial.png"], 900, 27, 1500, 161); d = region(imgs["04-blank-page.png"], 900, 27, 1500, 161)
check("new_tab_pixels_changed", float(np.abs(c - d).mean()) > 5, f"mean abs diff {float(np.abs(c-d).mean()):.2f}")
# the bar spans the whole window: right cluster pinned at the right edge (its » chevron is dark)
w = imgs["01-initial.png"].shape[1]; edge = imgs["01-initial.png"][:int(161 * SCALE), w - 40:w]
check("bar_spans_full_width", (edge.max(axis=2) < 150).sum() > 5, f"dark px in last 40 columns: {(edge.max(axis=2) < 150).sum()}")

# the fixed tab's face where a close button would sit is flat white: no "x" drawn on it
cx = ft["x"] + ft["w"] - 80 - 22; cy = ft["y"] + 24 + 22
fr = region(imgs["13-fixed-open.png"], cx - 6, cy - 6, cx + 28, cy + 28)
bx = afs["tabs"][3]["close_rect"]["position"]["x"]; by = afs["tabs"][3]["close_rect"]["position"]["y"]
br = region(imgs["15-after-fixed-stub.png"], bx - 6, by - 6, bx + 28, by + 28)
fstd = float(fr.std(axis=(0, 1)).max())  # per channel: the tinted face is flat but not grey (#45)
check("fixed_tab_draws_no_close_button", fstd < 3 and float(br.std()) > 10,
      f"fixed face std {fstd:.1f}, blank tab close std {float(br.std()):.1f}")

# --- the active tint (Issue #45): the atlas sea blue #83e5f7 at 12 percent on the active tab's face
SEA = np.array([131, 229, 247]); TINT = 0.12
TINTED = 255 * (1 - TINT * (1 - SEA / 255.0))  # white face multiplied by the tint: about (240, 252, 254)
def face(img, tb):  # median colour of a patch of plain face below the label, mid-tab
    cx = tb["x"] + tb["w"] / 2
    return np.median(region(img, cx - 12, tb["y"] + 95, cx + 12, tb["y"] + 108).reshape(-1, 3), axis=0)
settled = ["initial", "blank-page", "selected-0", "selected-1", "third-tab", "full-row", "closed-last",
           "closed-second", "reopened", "fixed-open", "fixed-kept", "after-fixed-stub"]
bad = [f"{k}: active {states[k]['active']} tints {[round(tb['tint'], 2) for tb in states[k]['tabs']]}" for k in settled
       if any(tb["tint"] != (1.0 if i == states[k]["active"] else 0.0) for i, tb in enumerate(states[k]["tabs"]))]
check("active_tab_tinted_others_white_in_state", not bad, "; ".join(bad) or f"{len(settled)} settled states")
px = []
for shot, lab in [("05-selected-0.png", "selected-0"), ("06-selected-1.png", "selected-1"), ("09-closed-last.png", "closed-last"),
                  ("10-closed-second.png", "closed-second"), ("13-fixed-open.png", "fixed-open"), ("15-after-fixed-stub.png", "after-fixed-stub")]:
    for i, tb in enumerate(states[lab]["tabs"]):
        c = face(imgs[shot], tb); want = TINTED if i == states[lab]["active"] else np.array([255, 255, 255])
        px.append((shot, i, i == states[lab]["active"], c, float(np.abs(c - want).max())))
worst = max(px, key=lambda p: p[4])
check("active_face_pixels_sea_blue_inactive_white", worst[4] <= 3,
      f"{len(px)} tab faces, want active {np.round(TINTED).astype(int).tolist()}; worst {worst[0]} tab {worst[1]} "
      f"{'active' if worst[2] else 'inactive'} {worst[3].astype(int).tolist()}")

tint_log = [e for e in log if e["event"] == "tint"]
def fade(film, since_ms):
    """The fade of the tab selected (tab_selected) after `since_ms`, from the tints of every frame of `film`.
    Tweens run on process time, and a film's PNG saves stall wall time, so the fade is timed in process
    time: the tint read after a frame is the tween step of the frame before, so the tint gained between two
    consecutive probes against the earlier probe's delta gives the time a whole fade takes.
    Returns (implied ms per 0..1 fades, mid-fade tints, the tab it left reached 0, index)."""
    s_ = next(e for e in signals if e["signal"] == "tab_selected" and e["t_ms"] >= since_ms)
    i = s_["index"]
    fr_ = [e for e in tint_log if e["film"] == film and e["t_ms"] >= s_["t_ms"] and len(e["tints"]) > i]
    implied = [1000 * a["dt"] / (b["tints"][i] - a["tints"][i]) for a, b in zip(fr_, fr_[1:])
               if 0 < a["tints"][i] < b["tints"][i] < 1]  # both frames mid-fade: no clamp at either end
    mid = [e["tints"][i] for e in fr_ if 0 < e["tints"][i] < 1]
    done = any(e["tints"][i] == 1.0 for e in fr_)
    left = done and all(v == 0.0 for j, v in enumerate(fr_[-1]["tints"]) if j != i)
    return implied, mid, left, i
clicks_at = {e["what"]: e["t_ms"] for e in clicks}
def before_film(film):  # the selection that starts a selection film: the last tab_selected before its first frame
    first = next(e["t_ms"] for e in tint_log if e["film"] == film)
    return [e for e in signals if e["signal"] == "tab_selected" and e["t_ms"] <= first][-1]["t_ms"]
closed_at = next(e["t_ms"] for e in signals if e["signal"] == "tab_closed")
opened_at = next(e["t_ms"] for e in signals if e["signal"] == "tab_opened")
for film, what, since in [("frames", "new tab settling", opened_at + 1), ("select-0-frames", "click tab 0", before_film("select-0-frames")),
                          ("select-1-frames", "click tab 1", before_film("select-1-frames")),
                          ("close-frames", "neighbour after a close", closed_at), ("select-fixed-frames", "fixed tab by select_tab", before_film("select-fixed-frames"))]:
    implied, mid, left, i = fade(film, since)
    med = float(np.median(implied)) if implied else None
    check(f"tint_fades_over_200ms_{film.replace('-frames', '').replace('frames', 'open')}",
          med is not None and 170 <= med <= 230 and left,
          f"{what}: tab {i}, mid-fade tints {[round(v, 2) for v in mid]}, implied fade "
          f"{[round(v) for v in implied]} ms (median {med and round(med)}), the tab it left back to white: {left}")
# a mid-fade frame of select_tab on the fixed tab (from code: no dip over it) shows the face part-way from white to
# the tinted colour, as far as its logged tint says
m = [e for e in tint_log if e["film"] == "select-fixed-frames" and 0.25 < e["tints"][1] < 0.75]
if m:
    fe = next(e for e in log if e["event"] == "frame" and e.get("film") == "select-fixed-frames" and e["t_ms"] == m[0]["t_ms"])
    mc = face(np.array(Image.open(out / "select-fixed-frames" / f"f{fe['n']:04d}.png").convert("RGB")).astype(int), states["fixed-open"]["tabs"][1])
    want = 255 - (255 - TINTED) * m[0]["tints"][1]
    check("mid_fade_frame_face_between_white_and_tint", TINTED[0] + 2 < mc[0] < 253 and float(np.abs(mc - want).max()) <= 3,
          f"frame {fe['n']} tint {m[0]['tints'][1]:.2f}: face {mc.astype(int).tolist()}, want {np.round(want).astype(int).tolist()}")
else:
    check("mid_fade_frame_face_between_white_and_tint", False, "no frame caught the fixed tab mid-fade")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
