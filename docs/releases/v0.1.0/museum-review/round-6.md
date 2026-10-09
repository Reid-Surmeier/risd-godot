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

Each claim will be judged YES / PARTLY / NO from continuous browser play and accompanied by a picture.

## Coverage and timing

Initial load and per-door frame timing are being captured. Untested areas will be named explicitly at handoff.

## What the harness should learn

Pending this round's reproduced findings.
