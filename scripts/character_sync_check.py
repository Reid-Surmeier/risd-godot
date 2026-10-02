"""Check estimated audible footsteps against frame completion, not mixer dispatch.

Usage: python3 scripts/character_sync_check.py [sync-investigation.json]
Browser timestamps estimate output; this does not measure speakers or display photons.
"""
import json
import statistics
import sys
from pathlib import Path


def check(capture):
    delays = [
        event["heard_ms"] - event["dispatch_to_frame_end_ms"]
        for event in capture["events"]
        if event.get("foot")
        and event.get("corr", 0) >= .9
        and event.get("heard_ms") is not None
        and "dispatch_to_frame_end_ms" in event
        and event.get("frame_ms", 1000) <= 50
    ]
    assert len(delays) >= 5, "Insufficient usable landing frames"
    median = statistics.median(delays)
    print(f"{capture['tag']}: {len(delays)} steps, estimated output after frame {median:.1f} ms")
    assert -30 <= median <= 45, f"Sound/frame timing unresolved: {median:.1f} ms"


if __name__ == "__main__":
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else (
        Path(__file__).resolve().parents[1]
        / "docs/evidence/character-235/sync-investigation.json"
    )
    check(json.loads(path.read_text())["captures"][0])
