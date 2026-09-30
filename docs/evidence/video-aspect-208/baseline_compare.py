#!/usr/bin/env python3
"""Compare owning frozen playtest on pre208 source; restores only this writer's candidate."""
from pathlib import Path
import hashlib, subprocess, json
root = Path(__file__).resolve().parents[3]
source = root / "modules/video_player/video_player.gd"
candidate = source.read_bytes()
baseline = subprocess.check_output(["git", "show", "125927da:modules/video_player/video_player.gd"], cwd=root)
out = Path("/tmp/risd-aspect-208/player-baseline")
log = Path("/tmp/risd-aspect-208-player-baseline.log")
try:
    source.write_bytes(baseline)
    with log.open("w") as stream:
        result = subprocess.run(["scripts/playtest.sh", "video_player", str(out)], cwd=root, stdout=stream, stderr=subprocess.STDOUT)
finally:
    source.write_bytes(candidate)
assert source.read_bytes() == candidate
candidate_log = Path("/tmp/risd-aspect-208-player-playtest.log")
def failures(path):
    return sorted({line.split()[1] for line in path.read_text().splitlines() if line.startswith("FAIL ")})
a, b = failures(log), failures(candidate_log)
record = {"baseline": "125927da", "baseline_exit": result.returncode, "baseline_failures": a, "candidate_failures": b, "same_failures": a == b, "candidate_restored_sha256": hashlib.sha256(candidate).hexdigest()}
Path("/tmp/risd-aspect-208/player-baseline-comparison.json").write_text(json.dumps(record, indent=2) + "\n")
print(json.dumps(record, indent=2))
assert a == b, "Classify changed frozen playtest findings before proceeding"
