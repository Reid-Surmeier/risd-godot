"""Certification of a conformed hover-turn take against its source icon (Issue #110).

Usage: python3 certify.py [icon ...]   (default: all three)
Reads source/<icon>.png and frames/<icon>/*.png, prints one line per check, exits 1 on any failure.
"""
import json
import sys
from pathlib import Path

import numpy as np
from scipy.ndimage import binary_dilation
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ICONS = ["01-staff", "02-green-sculpture", "03-horse-rider", "04-gold-couch", "05-bust", "06-bowl", "07-bull", "08-dog"]

WHITE_DISTANCE = 40      # a pixel further than this from white is object
END_MAE = 6.0            # first/last frame mean abs error, 0-255
END_IOU = 0.97
FRAME_IOU = 0.75
CENTROID_PX = 6.0
AREA_RATIO = 0.15
HIST_DISTANCE = 0.25
PEAK_IOU_MAX = 0.97      # the object must visibly turn: its outline changes...
PEAK_MAE_MIN = 8.0       # ...or, for a round object whose outline a turn cannot change, its pixels do
FOOTPRINT_PAD = 16       # new pixels may not appear further than this from the source bbox
MIN_FRAMES = 12
SHADOW_GROWTH_PX = 100  # soft grey pixels a frame may add over the source: a cast shadow adds hundreds
EDGE_BAND_PX = 3        # the video softens outlines; grey inside this band of the source outline is edge, not shadow


def load(path):
    return np.asarray(Image.open(path).convert("RGB"), dtype=np.float32)


def mask(rgb):
    return np.sqrt(((255.0 - rgb) ** 2).sum(-1)) > WHITE_DISTANCE


def soft_grey(rgb, outside=None):
    lum, sat = rgb.mean(-1), rgb.max(-1) - rgb.min(-1)
    grey = (lum > 150) & (lum < 248) & (sat < 14)
    return int((grey if outside is None else grey & outside).sum())


def iou(a, b):
    return (a & b).sum() / max((a | b).sum(), 1)


def centroid(m):
    ys, xs = np.nonzero(m)
    return np.array([xs.mean(), ys.mean()])


def hist(rgb, m):
    h, _ = np.histogramdd(rgb[m] // 32, bins=(8, 8, 8), range=((0, 8),) * 3)
    return h / max(h.sum(), 1)


def certify(icon):
    source = load(ROOT / "source" / f"{icon}.png")
    frames = sorted((ROOT / "frames" / icon).glob("*.png"))
    checks = []

    def check(name, passed, measured):
        checks.append({"check": name, "passed": bool(passed), "measured": measured})

    check("frame count", len(frames) >= MIN_FRAMES, len(frames))
    if len(frames) < MIN_FRAMES:
        return checks
    rgbs = [load(f) for f in frames]
    check("size", all(r.shape == source.shape for r in rgbs), list(rgbs[0].shape))
    if not all(r.shape == source.shape for r in rgbs):
        return checks

    sm = mask(source)
    sc, sa, sh = centroid(sm), sm.sum(), hist(source, sm)
    ys, xs = np.nonzero(sm)
    box = np.zeros_like(sm)
    box[max(ys.min() - FOOTPRINT_PAD, 0):ys.max() + FOOTPRINT_PAD + 1,
        max(xs.min() - FOOTPRINT_PAD, 0):xs.max() + FOOTPRINT_PAD + 1] = True

    # The take is hover-in only; leaving plays it in reverse, so the frame the pointer leaves on is rgbs[0].
    for label, rgb in (("rest (hover start and leave end)", rgbs[0]),):
        mae = float(np.abs(rgb - source).mean())
        check(f"{label} frame equals source (MAE)", mae <= END_MAE, round(mae, 2))
        check(f"{label} frame silhouette IoU", iou(mask(rgb), sm) >= END_IOU, round(float(iou(mask(rgb), sm)), 3))

    ious, drifts, areas, hists, strays, maes = [], [], [], [], [], []
    for rgb in rgbs:
        m = mask(rgb)
        ious.append(float(iou(m, sm)))
        drifts.append(float(np.linalg.norm(centroid(m) - sc)) if m.any() else 999.0)
        areas.append(float(abs(m.sum() / sa - 1)))
        hists.append(float(np.abs(hist(rgb, m) - sh).sum() / 2) if m.any() else 1.0)
        strays.append(int((m & ~box).sum()))
        maes.append(float(np.abs(rgb - source).mean()))
    check("every frame silhouette IoU", min(ious) >= FRAME_IOU, round(min(ious), 3))
    check("centroid drift px", max(drifts) <= CENTROID_PX, round(max(drifts), 2))
    check("area change", max(areas) <= AREA_RATIO, round(max(areas), 3))
    check("colour histogram distance", max(hists) <= HIST_DISTANCE, round(max(hists), 3))
    check("no pixels outside padded footprint", max(strays) == 0, max(strays))
    away = ~binary_dilation(sm, iterations=EDGE_BAND_PX)
    growth = max(soft_grey(r, away) for r in rgbs) - soft_grey(source, away)
    check("no cast shadow (soft grey growth px)", growth <= SHADOW_GROWTH_PX, growth)
    check("object visibly turns (peak IoU / peak MAE)", min(ious) <= PEAK_IOU_MAX or max(maes) >= PEAK_MAE_MIN,
          [round(min(ious), 3), round(max(maes), 1)])
    return checks


def main(icons):
    failed = False
    report = {}
    for icon in icons:
        checks = certify(icon)
        report[icon] = checks
        for c in checks:
            failed |= not c["passed"]
            print(f"{'PASS' if c['passed'] else 'FAIL'}  {icon:10} {c['check']:38} {c['measured']}")
    (ROOT / "tests" / "certification.json").write_text(json.dumps(report, indent=1))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:] or ICONS))
