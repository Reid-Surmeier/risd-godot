"""Prepare batch objects without spending: fetch each object's catalogue photographs, choose the views, write prompts.

    ~/.local/share/uv/tools/scrapling/bin/python prepare_batch.py [ACCESSION ...]

For each object in OBJECTS: reads its catalogue page (the museum answers 403 to a plain request, so this uses
Scrapling), lists its photographs, picks one for each of front, side, back and three-quarter from the museum's own alt texts,
fetches only those from the Micrio deep-zoom source (at most 2400 px wide, one request at a time) into
~/risd-godot-ingestion/catalogue-masters/<accession>/, and writes eight prompts
(clay-<view>, flat-<view>) and views.json to batch/<accession>/. A view with no photograph is written to be turned
by Muse from the front and whatever else exists. Objects with nude figures are flagged and get no prompts."""
import os, re, sys, json, time, html
from scrapling.fetchers import Fetcher
HERE = os.path.dirname(os.path.abspath(__file__)); MASTERS = os.path.expanduser("~/risd-godot-ingestion/catalogue-masters")
BASE = "https://risdmuseum.org/art-design/collection/"
NUDE_M = "Muse refused this kind of picture twice (River God, 5 Oct) and the fireplace (7 Oct)."
OBJECTS = {  # accession: page, what it is (named parts come from the museum's alt text), real material for the flat colour, nude note
 "43.195": ("crucified-christ-43195", "an oak figure of the crucified Christ, arms outstretched, without its cross", "weathered pale grey-brown oak with traces of old paint", None),
 "59.131": ("head-christ-or-saint-59131", "a large carved walnut head of a bearded man", "walnut with worn flesh-coloured, red and brown paint", None),
 "37.114": ("angel-annunciation-37114", "a standing carved wood angel in a long robe and mantle on its own octagonal base", "painted wood: dark green robe, red mantle with gilding, pale face", None),
 "69.196": ("christ-majesty-69196", "a limestone relief slab of Christ seated, right hand raised, a book on his knee", "pale buff limestone", None),
 "41.045": ("apostle-41045", "a tall narrow limestone relief of a standing apostle with crossed hands", "weathered grey-buff limestone", None),
 "41.046": ("apostle-41046", "a tall narrow limestone relief of a standing apostle", "weathered grey-buff limestone", None),
 "06.057": ("tabernacle-06057", "a marble tabernacle relief with two kneeling angels either side of a rectangular opening that goes right through", "ivory-white marble with warm staining", None),
 "37.201": ("bust-madame-recamier-37201", "a marble bust of a young woman with curled hair bound in a cloth, on a round socle", "white marble, slightly warm", None),
 "23.005": ("hand-god-23005", "a marble of one great right hand rising upright from a rough-hewn block of stone, its fingers curled around a lump of rough stone from which two small entwined figures are only half carved; the block below is pitted and coarse, the hand smooth", "plain white marble, the hand polished and the block rough and pitted, with no veining and no cracks",
            "The two small figures are nude. Tripo accepted the catalogue photograph of this piece on 8 Oct; Muse is untested. Try one clay view; if refused, use the fallback."),
 "2017.74.31.1": ("neptune-river-deity-201774311", "", "", "Nude male figure. " + NUDE_M + " Tripo accepted the photograph (8 Oct). Fallback: no Muse; Tripo H3.1 single view from the cut-out photograph, plain white glaze needs no colour pass."),
 "2017.74.31.2": ("amphitrite-river-deity-201774312", "", "", "Nude female figure. " + NUDE_M + " Tripo also refused the photograph (content policy, 8 Oct). Fallback: Trellis from the cut-out photograph (made 8 Oct, soft, pits at the back), or leave as it is."),
 "44.674": ("river-god-virile-age-euphrates-44674", "", "", "Nude male figure. Muse refused it twice. Tripo accepted the photograph (8 Oct, mesh kept outside git). Fallback: that Tripo mesh with the catalogue photographs projected as colour (28 exist)."),
 "83.152": ("fireplace-surround-83152", "", "", "Two nude women carved on the arch. Muse refused it. Tripo accepted the photograph (8 Oct). Fallback: the Tripo mesh with the photograph over the front, already built; or ask Muse for clay views of a crop without the figures."),
}
CLAY = ("Redraw this exact sculpture as an unpainted, matte, light grey clay maquette. Keep the same shape, proportions, pose and viewpoint: {what}; {alt} "
        "Remove any museum plinth, mount or label: the object ends at its own edge. Show the whole object, centred, filling about three quarters of the frame. Plain seamless white background with no horizon line. "
        "Soft, even light from the front. Level camera, no perspective distortion. No cast shadow, no reflections, no glaze, no paint, no text.")
CLAY_MATCH = ("Reference 1 is a photograph of a sculpture and is the view to draw. Reference 2 is a clay maquette of the same sculpture from the front and is the authority for material and light only. Reference 3 is the museum's front photograph, for the form only. " + CLAY[0].lower() + CLAY[1:] +
              " Exactly the material of reference 2: the same light grey matte clay, one even tone, the same light.")
TURN = ("Reference 1 is the front of a sculpture as a clay maquette{extra}. Draw this exact sculpture, in the same light grey matte clay and light, seen {how}: {what}. Keep every proportion of the references. "
        "Show the whole object, centred, filling about three quarters of the frame. Plain seamless white background with no horizon line. Level camera. No cast shadow, no reflections, no text.")
PLAIN = {"23.005", "37.201", "06.057", "2017.74.31.1", "2017.74.31.2"}  # plain marble or white glaze: ask for no markings
FLAT = ("Reference 1 is a grey clay maquette of a sculpture. Reference 2 is the museum's photograph of the real sculpture. Repaint reference 1 exactly as it is drawn, with the same outline, the same viewpoint, "
        "the same size and place in the frame and every carved line where it is, as a flat colour map of the real material of reference 2: {material}, with its own colour only. Keep its real markings: paint traces, stains, chips. "
        "Light it perfectly evenly from every side, as in a light tent, so that there is no shading at all: no shadows, no dark creases, no darkening in grooves, hair or hollows, no highlights. "
        "Matte. Plain seamless white background, no cast shadow, no plinth, no text.")
HOW = {"right": "exactly from its own right side in true profile, camera level and at ninety degrees to the front", "side": "exactly from its own left side in true profile, camera level and at ninety degrees to the front", "back": "from directly behind", "threequarter": "three-quarter from the front, turned about forty-five degrees"}
PICK = {"back": r"\b(rear|back view|from behind|back of|reverse)\b", "side": r"\b(profile|side view|from the side|seen from the (left|right))\b", "threequarter": r"\b(angled|three-quarter|oblique|at an angle|turned)\b"}
BY_EYE = {"59.131": {"back": 3}, "23.005": {"side": 10, "back": 2, "right": 7}, "37.201": {"threequarter": 2}, "37.114": {"side": 17, "back": 4, "right": 16, "threequarter": 7}}  # photographs with no alt text, assigned by looking: accession -> view -> photograph number
CLOSE = r"\b(close-up|detail|close up|closeup)\b"

def get(url, binary=False):
    r = Fetcher.get(url, stealthy_headers=True, impersonate="chrome"); assert r.status == 200, (url, r.status)
    b = r.body if isinstance(r.body, bytes) else str(r.body).encode(); time.sleep(1.5); return b if binary else b.decode("utf-8", "replace")

for acc in (sys.argv[1:] or OBJECTS):
    page, what, material, nude = OBJECTS[acc]; d = f"{MASTERS}/{acc}"; out = f"{HERE}/batch/{acc}"; os.makedirs(d, exist_ok=True); os.makedirs(out, exist_ok=True)
    idx = f"{d}/index.json"
    if os.path.exists(idx): items = json.load(open(idx))
    else:
        h = get(BASE + page); items = []
        for tag, rest in re.findall(r'(<div class="carousel-item[^>]*>)(.{0,400})', h, re.S):
            z = re.search(r'data-zoom-url="([^"]+)"', tag); a = re.search(r'data-alt-text="([^"]*)"', tag); m = re.search(r'<micr-io id="([^"]+)"', rest)
            if z: items.append({"zoom": z.group(1), "alt": html.unescape(a.group(1)) if a else "", "micrio": m.group(1) if m else None})
        assert items, f"{acc}: no photographs found on the page"
        json.dump(items, open(idx, "w"), indent=1, ensure_ascii=False)
    whole = [it for it in items if not re.search(CLOSE, it["alt"], re.I)] or items
    views = {"front": whole[0]}
    for v, rx in PICK.items(): views[v] = next((it for it in whole[1:] if re.search(rx, it["alt"], re.I)), None)
    for v, n in BY_EYE.get(acc, {}).items(): views[v] = items[n - 1]
    for v, it in views.items():  # fetch only the chosen views, one request at a time: the Micrio deep-zoom source, at most 2400 px wide
        if not it or it.get("file"): continue
        it["file"] = f"{v}.jpg"; path = f"{d}/{it['file']}"
        if not os.path.exists(path):
            try:
                info = json.loads(get(f"https://iiif.micr.io/{it['micrio']}/info.json")); wpx = min(2400, info["width"])
                open(path, "wb").write(get(f"https://iiif.micr.io/{it['micrio']}/full/{wpx},/0/default.jpg", binary=True)); it["px_wide"] = wpx; it["source_px"] = [info["width"], info["height"]]
            except Exception as e:  # fall back to the page's 1324 px zoom rendition
                open(path, "wb").write(get(it["zoom"], binary=True)); it["px_wide"] = 1324; it["note"] = f"zoom rendition; Micrio failed: {e}"
    json.dump(items, open(idx, "w"), indent=1, ensure_ascii=False)
    record = {"accession": acc, "page": BASE + page, "photographs": len(items), "nude": nude,
              "views": {v: ({"file": f"~/risd-godot-ingestion/catalogue-masters/{acc}/{it['file']}", "px_wide": it.get("px_wide"), "source_px": it.get("source_px"), "alt": it["alt"]} if it else "no photograph: Muse turns it from the front") for v, it in views.items()}}
    json.dump(record, open(f"{out}/views.json", "w"), indent=1, ensure_ascii=False)
    if not nude or acc == "23.005":
        alt = views["front"]["alt"].strip(); alt = alt if alt.endswith(".") else alt + "."
        open(f"{out}/clay-front.prompt.txt", "w").write(CLAY.format(what=what, alt=alt) + "\n")
        for v in [k for k in views if k != "front"]:
            it = views[v]
            if it: a2 = it["alt"].strip(); text = CLAY_MATCH.format(what=what, alt=a2 if a2.endswith(".") else a2 + ".")
            else: text = TURN.format(extra="; the other references are photographs of the real sculpture from other sides", how=HOW[v], what=what)
            open(f"{out}/clay-{v}.prompt.txt", "w").write(text + "\n")
        for v in views: open(f"{out}/flat-{v}.prompt.txt", "w").write((FLAT.replace(" Keep its real markings: paint traces, stains, chips.", " The surface is plain: no veining, no cracks, no stains, no painted lines.") if acc in PLAIN else FLAT).format(material=material) + "\n")
    print(f"{acc}: {len(items)} photographs | " + " ".join(f"{v}={str(it.get('px_wide')) + 'px' if it else 'TURN'}" for v, it in views.items()) + (" | NUDE: no prompts" if nude and acc != '23.005' else ""))
