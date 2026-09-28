"""Check the two recorded stop transitions against flat-foot sliding."""
import gzip
import json
import math
import sys


with gzip.open(sys.argv[1], "rt") as stream:
    frames = json.load(stream)
indices = [[i for i, p in enumerate(frames[0]["sole_vertices"])
            if (p[0] > 0) == (side == 0)] for side in range(2)]

for start in (5, 13):
    stop = [f for f in frames if start <= f["time"] <= start + 0.9]
    assert len(stop) >= 25
    assert all(any(s["locked"] for s in f["support"]) for f in stop), start
    for side in range(2):
        centers = [[sum(f["sole_vertices"][i][axis] for i in indices[side]) / len(indices[side])
                    for axis in range(3)] for f in stop]
        travel = sum(math.hypot(b[0] - a[0], b[2] - a[2])
                     for a, b in zip(centers, centers[1:]))
        lift = max(p[1] for p in centers) - min(p[1] for p in centers)
        assert travel < 0.03 or lift > 0.02, (start, side, travel, lift)
    print(f"{start}s stop: continuous support and lifted recovery feet")
