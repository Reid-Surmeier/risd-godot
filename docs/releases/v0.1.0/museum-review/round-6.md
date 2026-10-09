VERDICT: NOT DONE

Build: `431f5921` — the latest URL redirected to this build at 10:12 EDT on Friday 9 October 2026. Review branch starts at `431f5921d453917be966e7e0a465fa31ddb51d2c` from `origin/build/v0.1.0`.

# Independent museum playtest, round 6

Reviewer: Codex, working alone. Review window: 10:10–11:25 EDT; owner deadline 13:00 EDT. GPU headless Chrome, actual exported Web game, real keyboard and pointer input. No game code or assets changed. Scratch: `build/review-round-6/`.

The verdict is provisional while the browser loop is in progress. VERIFIED means reproduced in this browser; INFERRED means a conclusion not directly reproduced. BLOCKS PLAY means a crash, persistent black screen, inaccessible room, or a work that cannot be closed. Other faults are ordered by the owner's first five minutes and then condensed.

## BLOCKS PLAY

None confirmed yet; the complete loop and work closing checks are in progress.

## First five minutes

### 1. Startup takes almost fifty seconds before the owner can play.

**VERIFIED · POLISH · KNOWN slow-load class, current measurement.** A fresh browser load reaches `window.loadPerf`'s `game-shown` at **48.64 s**; downloads finish at 2.25 s, engine starts at 4.18 s, launch settles at 46.65 s. Steps: (1) open the pinned build in fresh GPU Chrome; (2) wait for the Collection game to appear. This is a wait, not a persistent black screen. The first Hall → medieval doorway subsequently works: its largest game draw/process gap is **0.242 s**, with no round-5 quarter-minute freeze. [Picture and timing](../../../evidence/review-round-6/01-load-48-seconds.jpg). Raw marks: `build/review-round-6/initial.json`; continuous doorway capture and samples: `01-hall-first-door/`, `01-first-door.json`.

### 2. A floor surface covers the visitor on the Skylight lower floor.

**VERIFIED · POLISH · NEW.** A broad herringbone floor surface crosses the foreground above the lower boards; near the landing it hides the visitor's body, leaving only the top of the hat. Steps: (1) in Skylight, click the yellow *Pile* and wait until its caption opens; (2) Escape back to the default walking view; (3) walk toward the upper landing from the lower floor, near (0, -35.84). [Before and after](../../../evidence/review-round-6/07-skylight-floor-covers-visitor.jpg). The three stair flights are usable; walking round to them recovers the view. **INFERRED:** the herringbone surface belongs to another room; the Skylight's lower boards and upper black landing have different finishes. No game code changed to investigate it.

## The rest, one line each

3. **VERIFIED · POLISH · KNOWN doorway class, NEW lower-floor check:** the lower Skylight door under the upper landing still reads as a cool black rectangle; descend the three flights, turn to the wall with lift “4”, and look left of the lift; [picture](../../../evidence/review-round-6/06-lower-skylight-dark-door.jpg). It is outside the required loop and is not counted as an inaccessible loop room.

## Eight owner claims

| Owner claim | Result so far | Browser evidence |
| --- | --- | --- |
| 1. Warm umber beyond rooms; blinds; medieval slab removed | In progress | First Hall doorway is umber; remaining doors and Impressionist windows still to check. |
| 2. Warm pools at every work, including the Hall | In progress | Warm pools visible in Hall, medieval and Renaissance views; not yet judged for every room. |
| 3. Warm medieval room | **YES · VERIFIED** | [Medieval and subsequent rooms](../../../evidence/review-round-6/04-room-lighting-in-motion.jpg). Warm floor, amber pools around wall works and door sills in the medieval walkthrough; dark wall colour remains. |
| 4. Soft warm haze and inviting doorway sill | **YES at the first two crossings · VERIFIED** | [Continuous Hall crossing](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg); full loop pending. |
| 5. Walk 1.9 m/s, run 4.5 m/s | **YES · VERIFIED** | [Walk and run](../../../evidence/review-round-6/03-walk-run-speed.jpg). Sustained browser probe velocity is 1.900 and 4.500 m/s in recordings 10, 13 and 14; the gait changes in motion. |
| 6. Turn to face camera on arrival | **YES at Renaissance arrival · VERIFIED** | [Arrival picture](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg). Release the crossing key, let arrival finish; the visitor turns to the lens. |
| 7. Impressionist entry beside fireplace and re-hung B | In progress | To be walked, not inferred from the plan. |
| 8. Small-room follow camera outside visitor's head | **YES in Rockefeller · VERIFIED; tighter rooms pending** | [Original/follow view, still and moving](../../../evidence/review-round-6/05-follow-camera-rockefeller.jpg). The visitor remains in front of the lens while walking beside cases and turning by a wall; no inside-head frame seen. |

## Coverage and timing

Initial load: **48.64 s to `game-shown`**. Hall → medieval, medieval ↔ Renaissance, Renaissance ↔ European and European → Rockefeller have been walked and continuously captured at 11.9–19.1 fps; no permanent black screen, crash or unclosable work so far. Two medieval works (59.131, 69.196), two Renaissance works (21.398, 58.196) and two European works (44.674, 53.349) have opened readable captions and closed. The latter Renaissance work's zoom page shows the correct photograph and caption and closes. The remaining loop is in progress.

| First crossing | Longest game draw/process gap | Longest browser frame gap |
| --- | ---: | ---: |
| Hall → medieval | 241.8 ms | 239.1 ms |
| Medieval → Renaissance | 42.5 ms | 38.3 ms |
| Renaissance → European | 39.2 ms | 38.0 ms |
| European → Rockefeller | 55.2 ms | 55.4 ms |

These measurements include the approach and opening; they are maxima from this GPU browser, not promises for the owner's device. Captures are looked at as contact sheets. The earlier, unsuccessful attempts to walk through case furniture are retained in scratch and are not counted as doorway crossings.

## What the harness should learn

Pending this round's reproduced findings.
