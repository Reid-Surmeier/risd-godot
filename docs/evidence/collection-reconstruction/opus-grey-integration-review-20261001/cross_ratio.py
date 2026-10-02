"""Independent re-reading of the grey gallery west wall, with no camera model at all.

The fit under review (opus-grey-register-fit-20261001/fit.py) rectifies the wall with an assumed
principal point and focal length. This uses only projective invariants: the vanishing points of the
wall's own horizontal and vertical lines give the wall's vanishing line; along any image row the map
from metres-along-the-wall to pixels is then x = x_inf + k / (s - s0), fixed by where the row meets
that vanishing line (x_inf) and by the Courbet canvas width (0.733 m, RISD 43.571).

It reads the same eye-picked anchors (picks.json), so it tests the arithmetic and the camera
assumption, not the picks. Run: python3 cross_ratio.py <path to fit folder> [--jitter]
"""
import json, sys
from pathlib import Path
import numpy as np

fit = Path(sys.argv[1])
picks = json.loads((fit / "picks.json").read_text())
published = json.loads((fit / "fit.json").read_text())


def vanishing(lines):
    rows = [np.cross([*a, 1.0], [*b, 1.0]) for a, b in lines]
    rows = [r / np.hypot(r[0], r[1]) for r in rows]
    return np.linalg.svd(np.array(rows))[2][-1]


def read(frame, rng=None):
    j = (lambda p, sx, sy: [p[0] + rng.normal(0, sx), p[1] + rng.normal(0, sy)]) if rng is not None else (lambda p, sx, sy: p[:2])
    vh = vanishing([[j(p, 0, 1.5) for p in line] for line in frame["horizontals"].values()])
    vv = vanishing([[j(p, 1.5, 0) for p in line] for line in frame["verticals"].values()])
    horizon = np.cross(vh, vv)  # the wall plane's vanishing line
    out = {}
    stations = {k: j(v, v[2] if len(v) > 2 else 3.0, 0) for k, v in frame["stations"].items()}
    y = stations["courC_L"][1]
    x_inf = -(horizon[1] * y + horizon[2]) / horizon[0]
    inv = {k: 1.0 / (v[0] - x_inf) for k, v in stations.items()}
    k = 0.733 / abs(inv["courC_R"] - inv["courC_L"])
    s = {name: k * abs(value - inv["swc"]) for name, value in inv.items()} if "swc" in inv else {}
    if s:
        out["corner_to_casing"] = s["casL"]
        out["corner_to_clear_south"] = s["darkL"]
        out["clear_width"] = abs(s["jamR"] - s["darkL"])
        out["corner_to_clear_north"] = s["jamR"]
        out["corner_to_courbet_centre"] = (s["courC_L"] + s["courC_R"]) / 2
    out["courbet_frame_width"] = k * abs(inv["courF_R"] - inv["courF_L"])
    if "nwc" in inv:
        centre = (inv["courC_L"] + inv["courC_R"]) / 2
        out["courbet_centre_to_nw_corner"] = k * abs(inv["nwc"] - centre)
        if s:
            out["whole_wall"] = k * abs(inv["nwc"] - inv["swc"])
    return out


for name in ["A1", "A2", "B1"]:
    frame = picks["frames"][name]
    got = read(frame)
    spread = {}
    if "--jitter" in sys.argv:
        rng = np.random.default_rng(1)
        runs = [read(frame, rng) for _ in range(2000)]
        spread = {q: np.percentile([r[q] for r in runs], [2.5, 97.5]) for q in got}
    print(name, frame["file"])
    for q, v in got.items():
        print("  %-28s %5.2f m" % (q, v) + ("   95%% of pick noise %.2f..%.2f" % tuple(spread[q]) if spread else ""))
print("published fit view / held-out view:", json.dumps({k: v for k, v in published.items() if k in ("table", "estimates")}, default=str)[:0])
