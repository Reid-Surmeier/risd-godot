#!/usr/bin/env python3
"""Independent verifier for a shell playtest run. Never trusts the harness's own summary:
re-hashes every screenshot, re-reads pixels, and checks the logged states against the
interface contract (six fixed tabs, launch tab, lazy tenants, freeze/resume, no close on
fixed tabs, the stub's blank page, resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

FIXED = ["map", "sketchbook", "3d_viewer", "video_player", "collection", "phone"]
BAR_H = 161 * 1920 / 4180.0

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {}
for e in log:
    if e["event"] == "state":
        states.setdefault(e["label"], e)
tenants = [e for e in log if e["event"] == "tenant"]
clicks = [e for e in log if e["event"] == "click"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def tenant(label, key):
    return next(e for e in tenants if e["label"] == label and e["key"] == key)

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 8, str(sorted(shots)))
check("launch_screenshot_is_1920x1080", imgs["01-launch.png"].shape[:2] == (1080, 1920), str(imgs["01-launch.png"].shape))

la = states["launch"]
check("six_fixed_tabs_in_order", la["count"] == 6 and la["fixed_count"] == 6 and [t["key"] for t in la["tabs"]] == FIXED
      and all(t["fixed"] for t in la["tabs"]), str([t["key"] for t in la["tabs"]]))
check("labels_are_the_keys", [t["label"] for t in la["tabs"]] == FIXED)
check("collection_active_at_launch", la["active"] == 4 and la["tabs"][4]["page_visible"]
      and sum(t["page_visible"] for t in la["tabs"]) == 1)
check("no_close_rect_on_fixed_tabs", all(t["close_rect"]["w"] == 0 for t in la["tabs"]))
check("hidden_pages_frozen_at_launch", all(t["frozen"] != t["page_visible"] for t in la["tabs"]),
      str([(t["key"], t["frozen"]) for t in la["tabs"]]))
check("only_the_launch_tenant_is_created", la["tabs"][4]["tenant"] == "ok"
      and all(t["tenant"] is None for i, t in enumerate(la["tabs"]) if i != 4), str([t["tenant"] for t in la["tabs"]]))
check("tenant_state_missing_before_first_show", tenant("launch", "map")["code"] == "shell.tenant_missing"
      and tenant("launch", "collection")["ok"])
check("tabs_left_to_right_within_window", all(la["tabs"][i]["rect"]["x"] < la["tabs"][i + 1]["rect"]["x"] for i in range(5))
      and la["stub_rect"]["x"] + la["stub_rect"]["w"] < 1920 and la["stub_rect"]["x"] > la["tabs"][5]["rect"]["x"])

mp = states["map"]
check("click_map_shows_map_page", mp["active"] == 0 and mp["tabs"][0]["page_visible"] and mp["tabs"][0]["tenant"] == "ok"
      and not mp["tabs"][4]["page_visible"] and mp["tabs"][4]["frozen"] and not mp["tabs"][0]["frozen"])
a, b = tenant("map-shown", "map"), tenant("map-after-20-frames", "map")
check("shown_tenant_process_runs", a["ok"] and b["ticks"] - a["ticks"] >= 15, f"{a['ticks']} -> {b['ticks']}")
sz = a["size"]
check("tenant_fills_page_area", abs(sz[0] - 1920) < 1 and abs(sz[1] - (1080 - BAR_H)) < 1.5, str(sz))

sk = states["sketchbook"]
c, d = tenant("map-hidden", "map"), tenant("map-hidden-after-20-frames", "map")
check("hidden_map_page_frozen", sk["active"] == 1 and sk["tabs"][0]["frozen"] and not sk["tabs"][0]["page_visible"])
check("hidden_tenant_process_stops", d["ticks"] == c["ticks"], f"{c['ticks']} -> {d['ticks']} over 20 frames")
check("hidden_tenant_gets_no_input", d["inputs"] == c["inputs"] and any(e["event"] == "key" for e in log),
      f"inputs {c['inputs']} -> {d['inputs']}")
s0, s1 = tenant("sketchbook-shown", "sketchbook"), tenant("sketchbook-after-20-frames", "sketchbook")
check("shown_sketchbook_runs_and_hears_the_key", s1["ticks"] - s0["ticks"] >= 15 and s1["inputs"] - s0["inputs"] >= 1,
      f"ticks {s0['ticks']}->{s1['ticks']}, inputs {s0['inputs']}->{s1['inputs']}")

e, f = tenant("map-resumed", "map"), tenant("map-resumed-after-20-frames", "map")
check("map_resumes_with_state_intact", 0 <= e["ticks"] - d["ticks"] <= 2 and f["ticks"] - e["ticks"] >= 15,
      f"frozen at {d['ticks']}, resumed {e['ticks']} -> {f['ticks']}")

cf = next(e for e in log if e["event"] == "close_fixed"); fk = states["fixed-kept"]
check("fixed_close_refused_by_interface", not cf["ok"] and cf["code"] == "shell.tab_fixed", cf["code"])
check("fixed_close_click_did_nothing", fk["count"] == 6 and fk["active"] == 0
      and any(e["what"].startswith("where the close button") for e in clicks))

sb = states["stub-blank"]
check("stub_opens_blank_page_with_close", sb["count"] == 7 and sb["tabs"][6]["label"] == "blank_page"
      and not sb["tabs"][6]["fixed"] and sb["tabs"][6]["close_rect"]["w"] > 0 and sb["active"] == 6
      and sb["tabs"][6]["page_visible"], f"count {sb['count']}")
ph = states["phone"]
check("closing_blank_lands_on_phone", ph["count"] == 6 and ph["active"] == 5 and ph["tabs"][5]["page_visible"])
check("phone_has_no_tenant_yet", tenant("phone-shown", "phone")["code"] == "shell.tenant_missing" and ph["tabs"][5]["tenant"] is None)
page = imgs["06-phone.png"][int(BAR_H) + 2:, :]
check("phone_page_is_plain_white", float(page.mean()) > 254, f"mean {float(page.mean()):.2f}")

rs = states["resized"]; rt = tenant("resized", "collection")
check("resize_refits_bar_and_tenant", rs["window"] == [1440, 900] and rs["stub_rect"]["x"] + rs["stub_rect"]["w"] < 1440
      and abs(rt["size"][0] - 1440) < 1 and abs(rt["size"][1] - (900 - 161 * 1440 / 4180.0)) < 1.5,
      f"window {rs['window']}, tenant {rt['size']}")
check("resized_screenshot_is_1440x900", imgs["07-resized.png"].shape[:2] == (900, 1440), str(imgs["07-resized.png"].shape))
check("restore_refits_back", states["restored"]["window"] == [1920, 1080] and hashes["08-restored.png"] != hashes["07-resized.png"])

# pixels: the launch bar has the six tabs (dark glyph pixels spread across the tab row) and no close "x"
# at the close spot of the active tab; the page area below the bar is white at launch
bar = imgs["01-launch.png"][:int(BAR_H)]
check("bar_spans_full_width", (bar[:, 1880:].max(axis=2) < 150).sum() > 5)
t4 = la["tabs"][4]["rect"]; sc = t4["h"] / 123.0
cx, cy = t4["x"] + t4["w"] - (80 + 22) * sc, t4["y"] + (24 + 22) * sc
spot = imgs["01-launch.png"][int(cy - 4):int(cy + 26), int(cx - 4):int(cx + 26)]
check("active_fixed_tab_draws_no_close_button", float(spot.std()) < 3, f"std {float(spot.std()):.1f}")
check("launch_page_area_white", float(imgs["01-launch.png"][int(BAR_H) + 2:].mean()) > 254)
# the dummy tenants are plain white, so map and sketchbook shots may match; the blank tab's page shows its title
check("stub_blank_shot_differs_from_launch", hashes["05-stub-blank.png"] != hashes["01-launch.png"])

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
