#!/usr/bin/env python3
"""Independent verifier for a collection_page playtest run. Never trusts the harness's own summary:
re-reads data/collection.json itself, re-hashes every screenshot, re-reads pixels, and checks the
logged page and shell states against the interface contract (every record on a card, each filter
narrows to exactly the matching records, the count follows, sort order, a card click emits
card_selected(record) and nothing else, freeze and resume across a tab switch, resize).
usage: verify.py OUT_DIR"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE.parent / "data" / "collection.json").read_text())["records"]
BAR_H = 161 * 1920 / 4180.0
PAGE_H = 1080 - BAR_H  # the page fills the window above the bar (bar along the bottom)

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
pages, shells = {}, {}
for e in log:
    if e["event"] == "page":
        pages.setdefault(e["label"], e)
    if e["event"] == "shell":
        shells.setdefault(e["label"], e)
signals = [e for e in log if e["event"] == "signal"]
clicks = [e for e in log if e["event"] == "click"]
results = {}

def check(name, cond, detail=""):
    results[name] = {"pass": bool(cond), "detail": detail}

def ids(state):
    return [c["id"] for c in state["cards"]]

def expect(medium="All", has_image=False, sort="none"):
    rs = [r for r in DATA if (medium == "All" or r["medium"] == medium) and (not has_image or r["has_image"])]
    if sort == "newest":
        rs.sort(key=lambda r: (-r["year"], r["id"]))
    elif sort == "oldest":
        rs.sort(key=lambda r: (r["year"], r["id"]))
    return [r["id"] for r in rs]

shots = {e["file"]: e for e in log if e["event"] == "screenshot"}
hashes = {f: hashlib.sha256((out / f).read_bytes()).hexdigest() for f in shots}
imgs = {f: np.array(Image.open(out / f).convert("RGB")).astype(int) for f in shots}
check("screenshots_present", len(shots) == 9, str(sorted(shots)))
check("screenshots_differ_except_card_click_and_resume", len({h for f, h in hashes.items() if f not in ("06-after-card.png", "08-collection-again.png")}) == len(hashes) - 2)
check("card_click_changes_no_pixels", hashes["06-after-card.png"] == hashes["05-all-oldest.png"])

# 1. launch
la, ls = pages["launch"], shells["launch"]
check("collection_tab_active_with_this_tenant", ls["active"] == 4 and ls["tabs"][4]["tenant"] == "ok" and ls["tenant_ok"])
check("data_has_the_agreed_records", len(DATA) == 16 and sum(r["has_3d"] for r in DATA) == 1
      and sum(r["has_video"] for r in DATA) == 5 and sum(r["has_image"] for r in DATA) == 10, f"{len(DATA)} records")
check("every_record_on_a_card_at_launch", la["total"] == len(DATA) and la["count"] == len(DATA)
      and set(ids(la)) == {r["id"] for r in DATA} and len(ids(la)) == len(set(ids(la))), f"{la['count']}/{la['total']}")
check("launch_filter_is_open", la["filter"] == {"medium": "All", "sort": "none", "has_image": False})
check("mediums_are_the_data's", la["mediums"] == sorted({r["medium"] for r in DATA}), str(la["mediums"]))
check("launch_cards_in_file_order", ids(la) == [r["id"] for r in DATA])
check("three_controls_have_rects", all(la["controls"][k]["w"] > 0 and la["controls"][k]["h"] > 0 for k in ("medium", "sort", "has_image")))
check("tenant_fills_page_area", abs(la["size"][0] - 1920) < 1 and abs(la["size"][1] - (1080 - BAR_H)) < 1.5, str(la["size"]))
cards = la["cards"]
check("cards_do_not_overlap", all(not (a["rect"]["x"] < b["rect"]["x"] + b["rect"]["w"] and b["rect"]["x"] < a["rect"]["x"] + a["rect"]["w"]
      and a["rect"]["y"] < b["rect"]["y"] + b["rect"]["h"] and b["rect"]["y"] < a["rect"]["y"] + a["rect"]["h"])
      for i, a in enumerate(cards) for b in cards[i + 1:]))
check("cards_flow_left_to_right_top_down", all((cards[i + 1]["rect"]["y"] > cards[i]["rect"]["y"]) or
      (cards[i + 1]["rect"]["y"] == cards[i]["rect"]["y"] and cards[i + 1]["rect"]["x"] > cards[i]["rect"]["x"]) for i in range(len(cards) - 1)))

# 2. has image
hi = pages["has-image"]
check("has_image_click_narrows_to_records_with_a_photo", hi["filter"]["has_image"] is True and ids(hi) == expect(has_image=True)
      and hi["count"] == len(expect(has_image=True)) and hi["total"] == len(DATA), f"{hi['count']} of {hi['total']}")
check("has_image_shot_differs_from_launch", hashes["02-has-image.png"] != hashes["01-launch.png"])

# 3. medium
mf = pages["medium-first-with-image"]
first = sorted({r["medium"] for r in DATA})[0]
check("medium_click_picks_first_medium", mf["filter"]["medium"] == first and ids(mf) == expect(medium=first, has_image=True), f"{mf['filter']['medium']}: {ids(mf)}")
m1 = pages["medium-first"]
check("has_image_click_again_turns_it_off", m1["filter"]["has_image"] is False and ids(m1) == expect(medium=first))
mv = pages["medium-video"]
check("medium_video_shows_the_five_videos", mv["filter"]["medium"] == "Video" and ids(mv) == expect(medium="Video") and mv["count"] == 5, str(ids(mv)))
check("medium_video_shot_differs", hashes["04-medium-video.png"] != hashes["03-medium-first.png"])

# 4. sort
vn, vo, ao = pages["video-newest"], pages["video-oldest"], pages["all-oldest"]
check("sort_newest_orders_videos_by_year_desc", vn["filter"]["sort"] == "newest" and ids(vn) == expect(medium="Video", sort="newest"), str(ids(vn)))
check("sort_oldest_orders_videos_by_year_asc", vo["filter"]["sort"] == "oldest" and ids(vo) == expect(medium="Video", sort="oldest"), str(ids(vo)))
check("medium_wraps_to_all_keeping_sort", ao["filter"] == {"medium": "All", "sort": "oldest", "has_image": False}
      and ids(ao) == expect(sort="oldest") and ao["count"] == len(DATA), str(ids(ao)[:4]))
years = {r["id"]: r["year"] for r in DATA}
check("all_oldest_years_non_decreasing", all(years[a] <= years[b] for a, b in zip(ids(ao), ids(ao)[1:])))

# 5. card click
bc, ac, ag = pages["before-card"], pages["after-card"], pages["after-ground"]
card_click = next(e for e in clicks if e["what"].startswith("card "))
clicked_id = card_click["what"][5:]
rec = next(r for r in DATA if r["id"] == clicked_id)
check("card_click_emits_card_selected_with_the_record", len(signals) == 1 and signals[0]["id"] == clicked_id and signals[0]["title"] == rec["title"]
      and set(signals[0]["keys"]) >= {"id", "title", "maker", "department", "medium", "year", "has_image", "has_video", "has_3d"},
      f"{len(signals)} signal(s): {[s['id'] for s in signals]}")
check("clicked_card_is_the_first_visible", bc["cards"][0]["id"] == clicked_id)
check("card_click_changes_nothing_else", ac["filter"] == bc["filter"] and ids(ac) == ids(bc) and ac["count"] == bc["count"]
      and [c["rect"] for c in ac["cards"]] == [c["rect"] for c in bc["cards"]])
check("ground_click_emits_nothing", ag["filter"] == ac["filter"] and ids(ag) == ids(ac) and len(signals) == 1
      and any(e["what"] == "white ground" for e in clicks))

# 6. invalid filter
inv = next(e for e in log if e["event"] == "set_filter_invalid"); ai = pages["after-invalid"]
check("invalid_filter_refused_by_interface", not inv["ok"] and inv["code"] == "collection_page.filter_invalid", inv["code"])
check("invalid_filter_changed_nothing", ai["filter"] == ag["filter"] and ids(ai) == ids(ag))

# 7. tab switch
mp, ca, cp = shells["map"], shells["collection-again"], pages["collection-again"]
check("map_tab_hides_and_freezes_collection", mp["active"] == 0 and not mp["tabs"][4]["page_visible"] and mp["tabs"][4]["frozen"]
      and mp["tabs"][0]["page_visible"] and mp["tenant_ok"])
check("collection_tab_resumes_the_same_page", ca["active"] == 4 and ca["tabs"][4]["page_visible"] and not ca["tabs"][4]["frozen"]
      and ca["tabs"][4]["tenant"] == "ok" and cp["filter"] == ai["filter"] and ids(cp) == ids(ai)
      and [c["rect"] for c in cp["cards"]] == [c["rect"] for c in ai["cards"]])
check("collection_again_shot_matches_after_card", hashes["08-collection-again.png"] == hashes["06-after-card.png"] or
      float(np.abs(imgs["08-collection-again.png"] - imgs["06-after-card.png"]).mean()) < 0.5)
check("map_page_is_white_above_the_bar", float(imgs["07-map.png"][:int(PAGE_H) - 2].mean()) > 254, f"{float(imgs['07-map.png'][:int(PAGE_H) - 2].mean()):.2f}")

# 8. resize
rs = pages["resized"]
check("resize_relays_cards_within_the_page", abs(rs["size"][0] - 1440) < 1 and abs(rs["size"][1] - (900 - 161 * 1440 / 4180.0)) < 1.5
      and ids(rs) == ids(cp) and all(c["rect"]["x"] + c["rect"]["w"] <= 1440 for c in rs["cards"])
      and max(c["rect"]["x"] + c["rect"]["w"] for c in rs["cards"]) < max(c["rect"]["x"] + c["rect"]["w"] for c in cp["cards"]), str(rs["size"]))
check("resized_screenshot_is_1440x900", imgs["09-resized.png"].shape[:2] == (900, 1440), str(imgs["09-resized.png"].shape))

# pixels: the page ground is white; the sliced header sits top-left of the window; the Info box sits just above the bar;
# a card with a thumbnail has non-white pixels inside its rect and a page with fewer cards has more white
def page_px(img, r, dy=0):
    return img[int(dy + r["y"]):int(dy + r["y"] + r["h"]), int(r["x"]):int(r["x"] + r["w"])]
launch_img = imgs["01-launch.png"]
check("launch_page_mostly_white", float((launch_img[:int(PAGE_H) - 2].min(axis=2) > 250).mean()) > 0.6)
hdr = launch_img[16:116, 24:1232]
check("header_pixels_present_top_left", float(hdr.std()) > 20 and float(hdr.mean()) > 150, f"std {float(hdr.std()):.1f}")
info = launch_img[int(PAGE_H) - 16 - 136:int(PAGE_H) - 16, 24:1256]
check("info_box_pixels_present_bottom", float(info.std()) > 10 and float(info.mean()) > 150, f"std {float(info.std()):.1f}")
thumb_cards = [c for c in la["cards"] if next(r for r in DATA if r["id"] == c["id"]).get("thumbnail")]
check("thumbnail_cards_have_pixels", all(float(page_px(launch_img, c["rect"]).std()) > 15 for c in thumb_cards[:6]))
check("filtered_page_has_more_white_than_launch", float((imgs["04-medium-video.png"].min(axis=2) > 250).mean()) > float((launch_img.min(axis=2) > 250).mean()))

ok = all(r["pass"] for r in results.values())
(out / "verify.json").write_text(json.dumps({"pass": ok, "checks": results, "sha256": hashes}, indent=1))
for k, r in results.items():
    print(("PASS" if r["pass"] else "FAIL"), k, r["detail"])
print("VERDICT", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
