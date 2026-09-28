#!/usr/bin/env python3
"""Independently check #170 native interaction states and captured pixels."""
import hashlib
import json
import sys
from pathlib import Path
from PIL import Image, ImageChops

out = Path(sys.argv[1])
log = json.loads((out / "report.json").read_text())["log"]
states = {e["label"]: e for e in log if e["event"] == "viewer"}
assert [e["active"] for e in log if e["event"] == "tab"] == list(range(7))
assert states["initial"]["rows"] == 5 and states["initial"]["columns"] == 4
cards = states["initial"]["cards"]
assert len(cards) == 20
assert len({round(r["x"], 2) for r in cards}) == 4
assert len({round(r["y"], 2) for r in cards}) == 5
for i in range(20):
    s = states[f"selected-{i:02d}"]
    assert s["selected"] == s["hovered"] == i
    assert not s["3d_preview_available"] and s["department"] == "unverified"
assert states["selected-02"]["selected_id"] == "20260811123051"
assert states["selected-19"]["selected_id"] == "panel-cell:22"
assert states["selected-02"]["selected_name"] != states["selected-19"]["selected_name"]
assert states["hover"]["hovered"] == 5
assert states["hover-later"]["hover_tick"] > states["hover"]["hover_tick"]
for field in ("selected", "hovered", "hover_tick", "ticks", "inputs"):
    assert states["hidden"][field] == states["hidden-after-input"][field], field
assert states["returned"]["selected"] == 19
assert states["returned"]["ticks"] > states["hidden"]["ticks"]
shots = [e["file"] for e in log if e["event"] == "screenshot"]
hashes = {}
for name in shots:
    img = Image.open(out / name).convert("RGB")
    assert img.size == (1080, 1080)
    hashes[name] = hashlib.sha256((out / name).read_bytes()).hexdigest()
first = Image.open(out / "selected-02.png").convert("RGB")
last = Image.open(out / "selected-19.png").convert("RGB")
assert ImageChops.difference(first.crop((110, 235, 470, 435)), last.crop((110, 235, 470, 435))).getbbox()
assert ImageChops.difference(first.crop((115, 710, 390, 994)), last.crop((115, 710, 390, 994))).getbbox()
(out / "verify.json").write_text(json.dumps({"pass": True, "sha256": hashes}, indent=2) + "\n")
print("PASS: seven tabs, 5x4 geometry, 20 selections, truthful metadata, animated hover, freeze, return, pixels")
