"""Verify recorded world-space sole contact. Usage: verify.py metrics.json [...]."""
import json
import math
import sys
import gzip

for path in sys.argv[1:]:
    opener = gzip.open if path.endswith(".gz") else open
    with opener(path, "rt") as stream:
        frames = json.load(stream)
    if frames[0].get("realtime"):
        assert frames[0]["time"] < 0.1 and frames[-1]["time"] > 17.9
        assert all(0 < b["time"] - a["time"] < 0.1 for a, b in zip(frames, frames[1:])), "replay stalled"
    else:
        assert len(frames) == 540, (path, len(frames))
    assert {frame["clip"] for frame in frames} == {"Idle", "Walking_A", "Interact"}
    penetration = max(0, -min(frame["skin_min"] for frame in frames))
    anchor_error = max(foot["error"] for frame in frames for foot in frame["support"])
    sides = [[i for i, p in enumerate(frames[0]["sole_vertices"])
              if (p[0] > 0) == (side == 0)] for side in range(2)]
    anchors = [None, None]
    mesh_drift = 0
    for frame in frames:
        for side, support in enumerate(frame["support"]):
            if not support["locked"]:
                anchors[side] = None
                continue
            if anchors[side] is None:
                anchors[side] = frame["sole_vertices"]
            for i in sides[side]:
                a, b = anchors[side][i], frame["sole_vertices"][i]
                mesh_drift = max(mesh_drift, math.hypot(a[0] - b[0], a[2] - b[2]))
    assert penetration < 0.01, ("floor penetration", penetration)
    assert anchor_error < 0.02, ("planted sole drift", anchor_error)
    assert mesh_drift < 0.02, ("planted sole vertex drift", mesh_drift)
    assert any(frame["action"] == "interaction canceled by walk" for frame in frames)
    assert any(frame["action"] == "complete interaction" for frame in frames)
    print(json.dumps({"file": path, "frames": len(frames),
                      "maximum_penetration": penetration,
                      "maximum_planted_sole_error": anchor_error,
                      "maximum_planted_vertex_drift": mesh_drift}))
