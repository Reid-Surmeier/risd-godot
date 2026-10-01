"""Source pixels for the six case A studies. CPU only, no network, no generation.

python3 prepare_textures.py [inventory evidence folder]

1. Copies the official RISD photographs byte for byte into textures/ and checks each against the inventory ledger hash.
2. Straightens the surfaces that only an oblique view shows (book pages and the left ivory leaf from the film,
   one silver board from official photograph 0) with a four-corner perspective fit. Corners were picked by eye.
3. Cuts the two frame reference crops a Muse frame pass would need. It does not call Muse.
4. Measures boxes, the arched outline, the jar profile and median colours, and writes manifest.json and measurements.json.

Straightened film crops are blurred source pixels, not new detail. Nothing here repaints a painting.
"""
import hashlib
import json
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).parent
INVENTORY = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE.parents[0] / "opus-renaissance-case-inventory-20261001"
OUT = HERE / "textures"
REFERENCE = HERE / "muse-reference"

OFFICIAL = {
    "cleric": "portrait-cleric-45042-zoom-0.jpg",
    "woman_front": "portrait-woman-34861-zoom-0.jpg",
    "woman_rear": "portrait-woman-34861-zoom-1.jpg",
    "diptych_front": "diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-0.jpg",
    "diptych_rear": "diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-1.jpg",
    "bookcover_flat": "book-cover-34016-zoom-0.jpg",
    "bookcover_spine": "book-cover-34016-zoom-1.jpg",
    "albarello_front": "drug-jar-albarello-35713-zoom-0.jpg",
    "albarello_rear": "drug-jar-albarello-35713-zoom-1.jpg",
}
# Corners in source pixels, picked by eye on 2x gridded crops: top left, top right, bottom right, bottom left
# of the surface as it will sit upright in the texture. `size` is the output in pixels at about the source resolution.
QUADS = {
    "emblem-left-page": {"source": "frames/IMG_6383-046.40.png", "quad": [(135, 880), (328, 978), (255, 1250), (5, 1160)], "size": (294, 394)},
    "emblem-right-page": {"source": "frames/IMG_6383-046.40.png", "quad": [(328, 978), (452, 888), (415, 1180), (255, 1250)], "size": (294, 394)},
    "diptych-left-native": {"source": "frames/IMG_6383-049.80.png", "quad": [(215, 1268), (376, 1285), (270, 1695), (38, 1660)], "size": (266, 482)},
    "diptych-right-native": {"source": "frames/IMG_6383-049.80.png", "quad": [(376, 1285), (560, 1300), (515, 1740), (270, 1695)], "size": (266, 482)},
    # Spine edge at the left, head at the top.
    "bookcover-board": {"source": "official:bookcover_flat", "quad": [(420, 455), (628, 203), (1203, 492), (1015, 775)], "size": (258, 420)},
}
# Frame references for root's Muse pass: [source, crop box]. The official photograph of 34.861 already holds its frame.
REFERENCES = {
    "cleric-frame-native-49.80": ["frames/IMG_6383-049.80.png", (300, 550, 800, 1150)],
    "cleric-frame-native-41.20": ["frames/IMG_6383-041.20.png", (340, 715, 620, 1045)],
    "woman-frame-native-46.40": ["frames/IMG_6383-046.40.png", (0, 0, 700, 800)],
    "woman-frame-native-41.20": ["frames/IMG_6383-041.20.png", (680, 665, 985, 1060)],
}
CLERIC_FRAME = {"outer": [(342, 598), (758, 595), (730, 1098), (377, 1078)], "sight": [(435, 679), (672, 679), (659, 1007), (450, 1002)]}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def warp(image, placed, quad, size):
    """Perspective fit: four output points `placed` to the four source corners `quad`."""
    rows, target = [], []
    for (x, y), (u, v) in zip(placed, quad):
        rows += [[x, y, 1, 0, 0, 0, -u * x, -u * y], [0, 0, 0, x, y, 1, -v * x, -v * y]]
        target += [u, v]
    return image.transform(size, Image.PERSPECTIVE, np.linalg.solve(np.array(rows, float), np.array(target, float)), Image.BICUBIC)


def straighten(image, quad, size):
    return warp(image, [(0, 0), (size[0], 0), size, (0, size[1])], quad, size)


def frame_bands(image, outer, sight, size, band):
    """The four frame bands of the film, each fitted from its own outer and sight edge to the helper's band widths.
    `size` and `band` are output pixels. The opening is left neutral: the painting is never taken from the film."""
    w, h = size
    out = Image.new("RGB", size, (128, 128, 128))
    to_outer = [(0, 0), (w, 0), (w, h), (0, h)]
    to_sight = [(band[0], band[1]), (w - band[0], band[1]), (w - band[0], h - band[1]), (band[0], h - band[1])]
    for k in range(4):
        j = (k + 1) % 4
        placed = [to_outer[k], to_outer[j], to_sight[j], to_sight[k]]
        mask = Image.new("L", size, 0)
        ImageDraw.Draw(mask).polygon(placed, fill=255)
        out.paste(warp(image, placed, [outer[k], outer[j], sight[j], sight[k]], size), (0, 0), mask)
    return out


def box(image, threshold=60):
    """Bounding box of everything that differs from the studio ground at the left and right margins of its own row."""
    a = np.asarray(image.convert("RGB")).astype(float)
    ground = (a[:, :12].mean(1) + a[:, -12:].mean(1)) / 2
    mask = np.abs(a - ground[:, None, :]).max(2) > threshold
    rows = np.where(mask.sum(1) > 20)[0]
    cols = np.where(mask.sum(0) > 20)[0]
    return [int(cols.min()), int(rows.min()), int(cols.max()) + 1, int(rows.max()) + 1], mask


def hull(points):
    """Convex hull, anticlockwise in image axes turned y up."""
    points = sorted(set(points))
    def half(seq):
        out = []
        for p in seq:
            while len(out) > 1 and (out[-1][0] - out[-2][0]) * (p[1] - out[-2][1]) - (out[-1][1] - out[-2][1]) * (p[0] - out[-2][0]) <= 0:
                out.pop()
            out.append(p)
        return out
    return half(points)[:-1] + half(points[::-1])[:-1]


def median(image, region):
    a = np.asarray(image.convert("RGB").crop(region)).reshape(-1, 3)
    return "%02x%02x%02x" % tuple(int(v) for v in np.median(a, 0))


def main():
    OUT.mkdir(exist_ok=True)
    REFERENCE.mkdir(exist_ok=True)
    ledger = {p["file"]: p["sha256"] for o in json.loads((INVENTORY / "ledger.json").read_text())["objects"] for p in o.get("photos", [])}
    manifest = {"inventory": str(INVENTORY), "official": {}, "straightened": {}, "muse_reference": {}}
    images = {}
    for key, name in OFFICIAL.items():
        shutil.copyfile(INVENTORY / "photos" / name, OUT / name)
        assert sha(OUT / name) == ledger[name], name + " does not match the inventory ledger"
        images[key] = Image.open(OUT / name).convert("RGB")
        manifest["official"][key] = {"file": "textures/" + name, "sha256": ledger[name], "size": list(images[key].size), "copied_unchanged": True}
    for name, spec in QUADS.items():
        source = images[spec["source"].split(":")[1]] if spec["source"].startswith("official:") else Image.open(HERE / spec["source"]).convert("RGB")
        straighten(source, spec["quad"], spec["size"]).save(OUT / (name + ".png"))
        file = OFFICIAL[spec["source"].split(":")[1]] if spec["source"].startswith("official:") else spec["source"]
        manifest["straightened"][name] = {"file": "textures/%s.png" % name, "sha256": sha(OUT / (name + ".png")), "source": file,
            "source_sha256": sha(OUT / file) if spec["source"].startswith("official:") else sha(HERE / file), "quad_px": spec["quad"], "size": list(spec["size"]),
            "corners": "picked by eye", "pixels": "source pixels resampled once, bicubic; no generation"}
    for name, (source, crop) in REFERENCES.items():
        Image.open(HERE / source).convert("RGB").crop(crop).save(REFERENCE / (name + ".png"))
        manifest["muse_reference"][name] = {"file": "muse-reference/%s.png" % name, "sha256": sha(REFERENCE / (name + ".png")), "source": source,
            "source_sha256": sha(HERE / source), "crop_box_px": list(crop), "pixels": "unchanged crop"}
    frame = Image.open(HERE / "frames/IMG_6383-049.80.png").convert("RGB")
    # The grey frame straightened onto its outer rectangle, painting left in as context. A planar fit of a stepped moulding.
    straighten(frame, CLERIC_FRAME["outer"], (508, 660)).save(REFERENCE / "cleric-frame-native-49.80-straightened.png")
    # The helper's stand-in frame image: 2 px per mm of its 23.4 x 32.2 cm outer rectangle, bands 4.4 and 5 cm.
    frame_bands(frame, CLERIC_FRAME["outer"], CLERIC_FRAME["sight"], (468, 644), (88, 100)).save(OUT / "cleric-frame-film.png")
    manifest["straightened"]["cleric-frame-film"] = {"file": "textures/cleric-frame-film.png", "sha256": sha(OUT / "cleric-frame-film.png"),
        "source": "frames/IMG_6383-049.80.png", "source_sha256": sha(HERE / "frames/IMG_6383-049.80.png"), "outer_quad_px": CLERIC_FRAME["outer"],
        "sight_quad_px": CLERIC_FRAME["sight"], "size": [468, 644], "band_px": [88, 100], "corners": "picked by eye",
        "pixels": "the four frame bands of the film, each resampled once onto the helper's band; the opening is neutral grey; no generation"}
    manifest["muse_reference"]["cleric-frame-native-49.80-straightened"] = {"file": "muse-reference/cleric-frame-native-49.80-straightened.png",
        "sha256": sha(REFERENCE / "cleric-frame-native-49.80-straightened.png"), "source": "frames/IMG_6383-049.80.png", "quad_px": CLERIC_FRAME["outer"],
        "size": [508, 660], "note": "planar perspective fit of a stepped moulding; band widths are provisional"}

    measured = {}
    # Portrait of a Woman: object box front and back, hull outline of the front, band widths by pixel run.
    woman, mask = box(images["woman_front"])
    # Left and right edge of the widest run in every 24th row; the hull of those drops stray specks and the cast shadow.
    edges = []
    for y in list(range(woman[1], woman[3], 24)) + [woman[3] - 1]:
        run = np.flatnonzero(np.diff(np.concatenate([[0], mask[y].astype(int), [0]])))
        starts, ends = run[::2], run[1::2]
        if len(starts):
            k = int(np.argmax(ends - starts))
            edges += [(int(starts[k]), -y), (int(ends[k]), -y)]
    woman[0], woman[2] = min(x for x, _ in edges), max(x for x, _ in edges)
    w, h = woman[2] - woman[0], woman[3] - woman[1]
    points = [((x - woman[0]) / w, (-y - woman[1]) / h) for x, y in hull(edges)]
    # Thin the hull to corners about 5% of the height apart.
    thin = [points[0]]
    for p in points[1:]:
        if abs(p[0] - thin[-1][0]) * w / h + abs(p[1] - thin[-1][1]) > .05:
            thin.append(p)
    measured["woman"] = {"front_box_px": woman, "rear_box_px": box(images["woman_rear"])[0], "photo_width_over_height": w / h, "catalogue_width_over_height": 24.8 / 36.2,
        "outline_uv_anticlockwise_y_down": [[round(u, 4), round(v, 4)] for u, v in thin],
        "band_px": {"side": 124, "top": 118, "bottom": 170}, "band_note": "pixel runs along row 900 and column 667 of official photograph 0, read by eye from the colour change"}
    # Diptych: the photographed leaf, and the two backs.
    front = images["diptych_front"]
    ivory = np.abs(np.asarray(front).astype(float) - 255).max(2) > 60  # the ground and the blanked leaf are pure white
    cols = np.where(ivory.sum(0) > front.height * .3)[0]
    rows = np.where(ivory.sum(1) > front.width * .1)[0]
    leaf = [int(cols.min()), int(rows.min()), int(cols.max()) + 1, int(rows.max()) + 1]
    measured["diptych"] = {"photographed_leaf_box_px": leaf, "photo_width_over_height": (leaf[2] - leaf[0]) / (leaf[3] - leaf[1]), "catalogue_width_over_height": 13.3 / 24.1,
        "other_leaf_in_official_photograph_0": "blanked white by the museum; its carved face is taken from the film only"}
    # Albarello: rim plane, base plane, axis and widths, by eye on a gridded crop of official photograph 0, then the masked widths.
    _, jar = box(images["albarello_front"], 28)
    rim, base, axis = 333, 1545, 664
    widths = []
    for y in range(380, 1340, 40):
        xs = np.where(jar[y - 2:y + 3].sum(0) >= 3)[0]
        widths.append([round((base - y) / (base - rim) * 24.1, 2), round((xs.max() - xs.min() + 1) / 2 / (base - rim) * 24.1, 3)])
    measured["albarello"] = {"rim_row_px": rim, "base_row_px": base, "axis_column_px": axis, "rear_axis_column_px": 681, "rear_rows_higher_px": 12, "px_per_cm": (base - rim) / 24.1,
        "height_cm_radius_cm": widths, "widest_cm": max(r for _, r in widths) * 2, "catalogue_widest_cm": 13.0,
        "note": "rows 380..1340 from the mask width; neck and foot in the helper are from the left edge alone because the mask takes in the cast shadow at the right"}
    measured["cleric"] = {"photo_width_over_height": images["cleric"].width / images["cleric"].height, "catalogue_width_over_height": 14.6 / 22.2,
        "frame_outer_quad_px_49.80": CLERIC_FRAME["outer"], "frame_sight_quad_px_49.80": CLERIC_FRAME["sight"],
        # Outer minus sight, halved so the parallax of the recessed painting cancels, against the sight taken as the whole panel.
        # The frame face stands about 4 cm nearer the lens than the painting: divide the outer by 1.044 at 0.94 m and 1.025 at 1.63 m.
        "band_cm_near_49.80": {"sides": (416 / 1.044 - 237) / 2 / 237 * 14.6, "top_and_bottom": (503 / 1.044 - 328) / 2 / 328 * 22.2},
        "band_cm_far_41.20": {"sides": (214.5 / 1.025 - 137) / 2 / 137 * 14.6, "top_and_bottom": (271 / 1.025 - 185) / 2 / 185 * 22.2},
        "far_41.20_px": {"cleric_outer": [214.5, 271], "cleric_sight": [137, 185], "woman_outer": [255, 352]},
        "relative_size_conflict": {"film_woman_over_cleric_frame": {"width": 255 / 214.5, "height": 352 / 271},
            "model_at_catalogue_sizes": {"width": 24.8 / 23.4, "height": 36.2 / 32.2},
            "note": "in the film the arched portrait is larger against the grey frame than two catalogue-sized objects can be; unresolved"},
        "note": "edges read by eye on 2x gridded crops, about +-3 px; sides 3.9..4.9 cm and top and bottom 4.8..5.2 cm between the two frames"}
    native = lambda t: Image.open(HERE / ("frames/IMG_6383-0%s.png" % t)).convert("RGB")
    spine = images["bookcover_spine"]
    jar_front = images["albarello_front"]
    measured["colours"] = {
        "cleric_frame_grey": median(native("49.80"), (350, 610, 420, 1060)),
        "woman_frame_brown": median(images["woman_front"], (40, 700, 130, 1100)),
        "ivory_face": median(front, (leaf[0] + 40, leaf[1] + 40, leaf[2] - 40, leaf[3] - 40)),
        "ivory_back": median(images["diptych_rear"], (100, 100, 600, 1100)),
        "silver": median(spine, (470, 620, 800, 680)),
        "silver_gilt_panel": median(spine, (480, 450, 800, 590)),
        "page": median(native("46.40"), (150, 930, 280, 1010)),
        "gilt_edge": median(native("46.40"), (40, 985, 55, 1010)),
        "book_board_outside": median(native("41.20"), (752, 1150, 762, 1175)),
        "jar_inside": median(native("46.40"), (650, 845, 790, 870)),
        "jar_glaze_blue": median(jar_front, (560, 1330, 640, 1370)),
        "jar_rim": median(jar_front, (450, 322, 880, 340)),
        "jar_foot": median(jar_front, (450, 1500, 880, 1530)),
    }
    (HERE / "measurements.json").write_text(json.dumps(measured, indent=1) + "\n")
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=1) + "\n")

    # One sheet showing every picked corner on its source, for review by eye.
    sheet = []
    for source, quads in [("frames/IMG_6383-046.40.png", ["emblem-left-page", "emblem-right-page"]), ("frames/IMG_6383-049.80.png", ["diptych-left-native", "diptych-right-native"])]:
        im = Image.open(HERE / source).convert("RGB")
        d = ImageDraw.Draw(im)
        for q in quads:
            d.polygon(QUADS[q]["quad"], outline=(255, 0, 255))
        if "049.80" in source:
            d.polygon(CLERIC_FRAME["outer"], outline=(0, 255, 255))
            d.polygon(CLERIC_FRAME["sight"], outline=(255, 255, 0))
        sheet.append(im.crop((0, 500, 1080, 1800)).resize((540, 650)))
    board = images["bookcover_flat"].copy()
    ImageDraw.Draw(board).polygon(QUADS["bookcover-board"]["quad"], outline=(255, 0, 255), width=3)
    sheet.append(board.resize((860, 650)))
    out = Image.new("RGB", (sum(s.width for s in sheet) + 20, 650), "white")
    x = 0
    for s in sheet:
        out.paste(s, (x, 0))
        x += s.width + 10
    out.save(HERE / "picked-corners.jpg", quality=88)
    print(json.dumps(measured, indent=1))


if __name__ == "__main__":
    main()
