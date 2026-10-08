VERDICT: NOT DONE

# Independent museum playtest, round 4 — 8 October 2026

Reviewer: Claude (Opus 5.5), working alone. No game code or assets changed. Owner deadline: Friday 9 October 2026, 13:00.

Candidate: `https://windows-wsl.taile06c45.ts.net/museum-latest-75d82bf6/`, build `bc33bcc3` (checkout `review/round-4` at `origin/build/v0.1.0` = `bc33bcc3`). Played in GPU headless Chrome with real key and mouse events.

VERIFIED means reproduced and looked at by this reviewer. INFERRED means concluded without reproducing. This report is written first and extended as findings are confirmed; the verdict line stays NOT DONE until the whole brief has been played.

Scope of this round: the room-change wipe at every doorway, the restored Hall lighting, the full-size Hall photographs and their zoom pages, zoom captions, and the walk/run/jump changes. Round 3's six findings and the two 8 October censuses are not re-reported.

## Findings

### 1. The first time through a doorway the picture freezes as the wipe starts and the black lasts about twice as long.

**VERIFIED · POLISH.** What a visitor sees: on the very first doorway (Hall into the dark medieval room) the visitor stops mid-step for half a second, the wipe closes, and the screen stays black for about two and a half seconds before the next room opens; it is over four seconds before the keys work again. Later crossings of the same door are clean. Where: every door the first time it is used in a session; worst at the stone portal, the first door anyone takes. Reproduce: (1) load the build fresh; (2) hold W from the start position into the medieval room; (3) walk back and through again to compare.

| First entry | Freeze at wipe start | Black on screen | Keys back after the doorway |
| --- | --- | --- | --- |
| Hall → medieval (stone portal) | 0.48 s, then 1.49 s under the black | 2.5 s | 4.2 s |
| medieval → Renaissance | 0.66 s | 1.8 s | 3.0 s |
| medieval → lion landing | 0.40 s | 1.6 s | 2.8 s |
| landing → modern | none measured | 1.1 s | 2.5 s |
| any repeat crossing (14 measured) | none | 1.1–1.3 s | 2.45–2.56 s |

The freezes are the game's own frame gaps (its `?qa-perf` probe), not recorder gaps. INFERRED: the next room's meshes and textures are first drawn under the wipe; round 3's portal freeze is the same cost, now mostly hidden by the black but still visible as the frozen half second before the wipe appears. Timings are from this shared host and will differ on the owner's machine.

Evidence: [first and third time through the stone portal](../../../evidence/review-round-4/01-first-entry-freeze.jpg); scratch `A1-hall-medieval-walk.mp4`, `A1-trace.json`, `A5-*`, `B1-*`, `C1-*`.

## All 38 crossing legs

(table follows once the legs are played)

## Ten things to fix first

(pending)

## What could not be tested

(pending)
