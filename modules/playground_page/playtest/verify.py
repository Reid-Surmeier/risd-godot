#!/usr/bin/env python3
"""Independent verifier for a playground_page playtest run (tickets #62 and #63). Never trusts the
harness's own summary: re-reads the owner's layout picture (docs/evidence/playground/layout-reference.png)
itself, recomputes where every window must sit from the window rects measured in that picture and the
fill rule, compares the screenshots' pixels with the picture at those places, and checks the logged
states against the interface contract (lazy creation, the title drag and raise, body drag ignored,
frozen while hidden, resumed intact, the fill rule at 1920x1000 and 1440x820 page sizes).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
REF = Image.open(HERE.parents[2] / "docs/evidence/playground/layout-reference.png").convert("RGB")
INDEX = 5
# Window rects in the owner's picture (2186x1362), found by template-matching each asset into it.
PICTURE = {"postpet": (48, 74, 1216, 1137), "options": (1277, 74, 499, 215), "filters": (1277, 288, 489, 224),
           "trade": (1271, 558, 495, 215), "chat": (1290, 948, 563, 261), "phone": (1791, 75, 380, 759)}
ORDER = ["postpet", "options", "filters", "trade", "chat", "phone"]
M = 24  # the desktop's native margin, in picture px
X0 = min(r[0] for r in PICTURE.values()); Y0 = min(r[1] for r in PICTURE.values())
X1 = max(r[0] + r[2] for r in PICTURE.values()); Y1 = max(r[1] + r[3] for r in PICTURE.values())
D = (X1 - X0 + 2 * M, Y1 - Y0 + 2 * M)
PP_K = 1216 / 859.0  # postpet.png's scale in the picture
KEYED = {"options", "filters", "trade", "chat"}  # magenta border keyed out on the page, kept in the picture

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
pages, shells = {}, {}
for e in log:
    if e["event"] == "page":
        pages.setdefault(e["label"], e)
    if e["event"] == "shell":
        shells.setdefault(e["label"], e)
drags = [e for e in log if e["event"] == "drag"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def expected(S):
    """Every window's rect on a page of size S by the fill rule, and the art scale."""
    s = min(S[0] / D[0], S[1] / D[1]); rects = {}
    for n, (x, y, w, h) in PICTURE.items():
        dx, dy = x - X0 + M, y - Y0 + M
        if n == "postpet":
            right = S[0] - (D[0] - (dx + w)) * s
            rects[n] = (dx * s, dy * s, right - dx * s, S[1] - M * s - dy * s)
        elif n == "chat":
            rects[n] = (S[0] - (D[0] - dx) * s, S[1] - (D[1] - dy) * s, w * s, h * s)
        else:
            rects[n] = (S[0] - (D[0] - dx) * s, dy * s, w * s, h * s)
    return s, rects

def win(p, n):
    return next(w for w in p["windows"] if w["name"] == n)

def close(r, e, tol=2.0):
    return all(abs(a - b) <= tol for a, b in zip((r["x"], r["y"], r["w"], r["h"]), e))

def patch_diff(shot, page_y0, screen, picture):
    """Mean abs difference between the screenshot at `screen` (x, y, w, h in page px) and the picture's `picture` region."""
    x, y, w, h = [int(round(v)) for v in screen]
    crop = shot[page_y0 + y:page_y0 + y + h, x:x + w]
    px, py, pw, ph = picture
    ref = np.array(REF.crop((int(px), int(py), int(px + pw), int(py + ph))).resize((crop.shape[1], crop.shape[0]), Image.LANCZOS)).astype(int)
    return float(np.abs(crop - ref).mean()) if crop.shape == ref.shape and crop.size else 999.0

def window_diffs(shot, p, rects=None, offset=(0, 0)):
    """Pixel difference of every window against the picture, at the logged rects (or `rects`)."""
    y0 = int(round(p["page_global"]["y"])); s = p["factor"]; out_ = {}
    for n in ORDER:
        r = rects[n] if rects else (lambda w: (w["x"], w["y"], w["w"], w["h"]))(win(p, n)["rect"])
        r = (r[0] + offset[0], r[1] + offset[1], r[2], r[3])
        px, py, pw, ph = PICTURE[n]
        if n == "postpet":  # rows 204..660 of postpet.png: the side columns and the stickers (the header and info box are the RISD version, not the picture's)
            k = PP_K * s; extra_x = r[2] - 859 * k; extra_y = r[3] - 803 * k
            left = (r[0], r[1] + 204 * k + extra_y, 730 * k, 456 * k)
            right = (r[0] + 731 * k + extra_x, r[1] + 204 * k + extra_y, 128 * k, 456 * k)
            out_[n] = max(patch_diff(shot, y0, left, (px, py + 204 * PP_K, 730 * PP_K, 456 * PP_K)),
                          patch_diff(shot, y0, right, (px + 731 * PP_K, py + 204 * PP_K, 128 * PP_K, 456 * PP_K)))
        else:
            i = 8 if n in KEYED else 2  # inset past the keyed magenta border (picture px)
            out_[n] = patch_diff(shot, y0, (r[0] + i * s, r[1] + i * s, r[2] - 2 * i * s, r[3] - 2 * i * s),
                                 (px + i, py + i, pw - 2 * i, ph - 2 * i))
    return out_

def cleared_body(shot, p, n):
    """The retained frame's former decorative body is now a mostly-white saved-work surface."""
    w = win(p, n); r = w["rect"]; y0 = int(round(p["page_global"]["y"])); title = max(2, int(round(w["drag_height"])))
    crop = shot[y0 + int(r["y"]) + title:y0 + int(r["y"] + r["h"]) - 3,
                int(r["x"]) + 3:int(r["x"] + r["w"]) - 3]
    return float((crop.min(axis=2) > 245).mean()) if crop.size else 0.0

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 8, str(sorted(shots)))
check("picture_is_the_owners_layout", REF.size == (2186, 1362) and D == (2171, 1185), f"{REF.size}, desktop {D}")

la, ls = pages["launch"], shells["launch"]
check("six_fixed_tabs_no_phone", ls["count"] == 6 and [t["key"] for t in ls["tabs"]][-1] == "playground"
      and all(t["key"] != "phone" for t in ls["tabs"]), str([t["key"] for t in ls["tabs"]]))
check("no_tenant_at_launch", ls["active"] == 4 and ls["tabs"][INDEX]["tenant"] is None and la["code"] == "shell.tenant_missing")

sh, a, b = shells["shown"], pages["shown"], pages["shown-after-20-frames"]
check("click_creates_and_shows_the_desktop", sh["active"] == INDEX and sh["tabs"][INDEX]["tenant"] == "ok"
      and not sh["tabs"][INDEX]["frozen"] and a["ok"], str(sh["tabs"][INDEX]))
check("shown_desktop_process_runs", b["ticks"] - a["ticks"] >= 15, f"{a['ticks']} -> {b['ticks']}")
check("six_windows_in_stacking_order", [w["name"] for w in a["windows"]] == ORDER, str([w["name"] for w in a["windows"]]))
check("empty_saved_collection_is_ready", a["storage_status"] == "ready" and a["saved_ids"] == [], str(a["saved_ids"]))

# every window at its reference place (fill rule at the launch page size) and matching the picture there
s, exp = expected(a["size"])
check("factor_is_min_of_both_axes", abs(a["factor"] - s) < 1e-4, f"{a['factor']:.4f} vs {s:.4f}")
for n in ORDER:
    check(f"{n}_at_reference_place", close(win(a, n)["rect"], exp[n]), f"{win(a, n)['rect']} vs {tuple(round(v, 1) for v in exp[n])}")
d0 = window_diffs(imgs["01-desktop.png"], a)
for n in ORDER[:-1]:
    white = cleared_body(imgs["01-desktop.png"], a, n)
    check(f"{n}_decorations_cleared_inside_frame", white > 0.78, f"white body fraction {white:.3f}")
check("phone_pixels_match_the_picture", d0["phone"] < 16, f"mean abs diff {d0['phone']:.1f}")

# the trade window's title drag moves it by the drag and raises it; the options body drag moves nothing
mv = pages["trade-moved"]; t0, t1 = win(a, "trade")["rect"], win(mv, "trade")["rect"]
dr = next(e for e in drags if e["what"] == "drag trade by its title bar")
check("title_drag_moves_trade", abs(t1["x"] - t0["x"] - dr["relative_total"][0]) < 1 and abs(t1["y"] - t0["y"] - dr["relative_total"][1]) < 1
      and t1["w"] == t0["w"], f"{t0} -> {t1}")
check("dragged_window_raised", mv["windows"][-1]["name"] == "trade", str([w["name"] for w in mv["windows"]]))
check("others_stay_put", all(win(mv, n)["rect"] == win(a, n)["rect"] for n in ORDER if n != "trade"))
check("moved_trade_keeps_cleared_body", cleared_body(imgs["02-trade-moved.png"], mv, "trade") > 0.78)
ob = pages["options-body-drag"]
check("body_drag_moves_nothing", all(win(ob, n)["rect"] == win(mv, n)["rect"] for n in ORDER) and ob["action"] == "")

hd, c, d = shells["hidden"], pages["hidden"], pages["hidden-after-events"]
check("hidden_page_frozen", hd["active"] == 0 and hd["tabs"][INDEX]["frozen"] and not hd["tabs"][INDEX]["page_visible"])
check("frozen_process_stops", d["ticks"] == c["ticks"], f"{c['ticks']} -> {d['ticks']}")
check("frozen_gets_no_input", d["inputs"] == c["inputs"] and any(e["event"] == "key" for e in log), f"{c['inputs']} -> {d['inputs']}")
check("hidden_drag_changed_nothing", d["windows"] == ob["windows"])
check("hidden_shows_white_map_page", float(imgs["03-hidden.png"][:int(round(a["size"][1])) - 2].mean()) > 254)

rs, e, f = shells["resumed"], pages["resumed"], pages["resumed-after-20-frames"]
g = pages["resuming"]
check("resumes_with_state_intact", rs["active"] == INDEX and e["windows"] == ob["windows"] and f["ticks"] - e["ticks"] >= 15
      and 0 <= g["ticks"] - d["ticks"] <= 8, f"frozen {d['ticks']}, at the click {g['ticks']}, settled {e['ticks']} -> {f['ticks']}")
page_h = int(round(a["size"][1]))
check("resumed_pixels_identical", float(np.abs(imgs["04-resumed.png"][:page_h] - imgs["02-trade-moved.png"][:page_h]).mean()) < 0.5)

# the fill rule: at each page size every window re-lays out from the page's own size, the desktop's box
# spans the page on both axes within the native margin, the art is uniform, pixels still match
for label, shot, want in [("page-1920x1000", "05-page-1920x1000.png", (1920, 1000)), ("page-1440x820", "06-page-1440x820.png", (1440, 820)),
                          ("window-1440x900", "07-window-1440x900.png", None), ("restored", "08-restored.png", None)]:
    p = pages[label]; S = p["size"]; s, exp = expected(S); tag = label.replace("-", "_")
    if want:
        check(f"{tag}_page_size", abs(S[0] - want[0]) <= 1 and abs(S[1] - want[1]) <= 1, str(S))
    check(f"{tag}_windows_at_rule_places", abs(p["factor"] - s) < 1e-4 and all(close(win(p, n)["rect"], exp[n]) for n in ORDER),
          str({n: win(p, n)["rect"] for n in ORDER}))
    rects = [win(p, n)["rect"] for n in ORDER]; m = M * s + 1.5
    bx0 = min(r["x"] for r in rects); by0 = min(r["y"] for r in rects)
    bx1 = max(r["x"] + r["w"] for r in rects); by1 = max(r["y"] + r["h"] for r in rects)
    check(f"{tag}_desktop_spans_the_page", bx0 <= m and by0 <= m and S[0] - bx1 <= m and S[1] - by1 <= m,
          f"box ({bx0:.0f},{by0:.0f})-({bx1:.0f},{by1:.0f}) in {S}, margin {m:.1f}")
    pp = win(p, "postpet")["rect"]
    check(f"{tag}_main_window_never_below_native", pp["w"] >= 1216 * s - 1 and pp["h"] >= 1137 * s - 1.5, f"{pp} vs {1216 * s:.0f}x{1137 * s:.0f}")
    dd = window_diffs(imgs[shot], p)
    cleared = {n: cleared_body(imgs[shot], p, n) for n in ORDER[:-1]}
    check(f"{tag}_retains_frames_with_cleared_bodies", all(v > 0.78 for v in cleared.values()) and dd["phone"] < 16,
          str({n: round(v, 3) for n, v in cleared.items()}))
check("both_axes_exercised", pages["page-1920x1000"]["size"][0] / D[0] > pages["page-1920x1000"]["size"][1] / D[1]
      and pages["page-1440x820"]["size"][0] / D[0] < pages["page-1440x820"]["size"][1] / D[1],
      "1920x1000 is height-limited (leftover width), 1440x820 width-limited (leftover height)")

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL", f"({sum(r['pass'] for r in results.values())}/{len(results)})")
sys.exit(0 if ok else 1)
