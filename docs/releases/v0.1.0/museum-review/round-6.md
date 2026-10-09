VERDICT: NOT DONE

Build: `431f5921` — the latest URL redirected to this build at 10:12 EDT on Friday 9 October 2026. Review branch starts at `431f5921d453917be966e7e0a465fa31ddb51d2c` from `origin/build/v0.1.0`.

# Independent museum playtest, round 6

Reviewer: Codex, working alone. Review window: 10:10–11:25 EDT; owner deadline 13:00 EDT. GPU headless Chrome, actual exported Web game, real keyboard and pointer input. No game code or assets changed. Scratch: `build/review-round-6/`.

The verdict is provisional while the browser loop is in progress. VERIFIED means reproduced in this browser; INFERRED means a conclusion not directly reproduced. BLOCKS PLAY means a crash, persistent black screen, inaccessible room, or a work that cannot be closed. Other faults are ordered by the owner's first five minutes and then condensed.

## BLOCKS PLAY

None confirmed yet; the complete loop and work closing checks are in progress.

## First five minutes

### 1. Startup takes almost fifty seconds before the owner can play.

**VERIFIED · POLISH · KNOWN slow-load class, current measurement.** A fresh browser load reaches `window.loadPerf`'s `game-shown` at **48.64 s**; downloads finish at 2.25 s, engine starts at 4.18 s, launch settles at 46.65 s. Steps: (1) open the pinned build in fresh GPU Chrome; (2) wait for the Collection game to appear. This is a wait, not a persistent black screen. The first Hall → medieval doorway subsequently works: its largest game draw/process gap is **0.229 s**, with no round-5 quarter-minute freeze. [Picture and timing](../../../evidence/review-round-6/01-load-48-seconds.jpg). Raw marks: `build/review-round-6/initial.json`; continuous doorway capture and samples: `01-hall-first-door/`, `01-first-door.json`.

## Eight owner claims

| Owner claim | Result so far | Browser evidence |
| --- | --- | --- |
| 1. Warm umber beyond rooms; blinds; medieval slab removed | In progress | First Hall doorway is umber; remaining doors and Impressionist windows still to check. |
| 2. Warm pools at every work, including the Hall | In progress | Warm pools visible in Hall, medieval and Renaissance views; not yet judged for every room. |
| 3. Warm medieval room | **YES · VERIFIED** | Warm floor, amber pools around wall works and door sills in the medieval walkthrough; dark wall colour remains. Picture to follow with the lighting comparison. |
| 4. Soft warm haze and inviting doorway sill | **YES at the first two crossings · VERIFIED** | [Continuous Hall crossing](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg); full loop pending. |
| 5. Walk 1.9 m/s, run 4.5 m/s | In progress | Actual browser movement measurement pending. |
| 6. Turn to face camera on arrival | **YES at Renaissance arrival · VERIFIED** | [Arrival picture](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg). Release the crossing key, let arrival finish; the visitor turns to the lens. |
| 7. Impressionist entry beside fireplace and re-hung B | In progress | To be walked, not inferred from the plan. |
| 8. Small-room follow camera outside visitor's head | In progress | Follow view still to test. |

## Coverage and timing

Initial load and per-door frame timing are being captured. Untested areas will be named explicitly at handoff.

## What the harness should learn

Pending this round's reproduced findings.
