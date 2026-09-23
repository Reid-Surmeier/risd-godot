"""Proves certify.py rejects the failures it exists to catch. No model output involved."""
import shutil
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

import certify

source = Image.open(certify.ROOT / "source" / "07-bull.png").convert("RGB")


def run(make_frame):
    real_root = certify.ROOT
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        shutil.copytree(real_root / "source", root / "source")
        (root / "frames" / "07-bull").mkdir(parents=True)
        for i in range(16):
            make_frame(i).save(root / "frames" / "07-bull" / f"{i:03}.png")
        certify.ROOT = root
        try:
            return {c["check"]: c["passed"] for c in certify.certify("07-bull")}
        finally:
            certify.ROOT = real_root


def shifted(i):
    return Image.fromarray(np.roll(np.asarray(source), 12 if 3 < i < 12 else 0, axis=1))


def recoloured(i):
    a = np.asarray(source).copy()
    if 3 < i < 12:
        a[..., 0], a[..., 2] = a[..., 2].copy(), a[..., 0].copy()
    return Image.fromarray(a)


still = run(lambda i: source)
assert not still["object visibly turns (peak IoU / peak MAE)"], "a still must fail"
assert still["rest (hover start and leave end) frame equals source (MAE)"] and still["colour histogram distance"]

drift = run(shifted)
assert not drift["centroid drift px"], "a 12 px slide must fail"

colour = run(recoloured)
assert not colour["colour histogram distance"], "a red/blue swap must fail"

empty = run(lambda i: Image.new("RGB", source.size, "white"))
assert not empty["every frame silhouette IoU"], "an empty frame must fail"

print("selfcheck: certifier rejects still, slide, recolour and empty takes")
