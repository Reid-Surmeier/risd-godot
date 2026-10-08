VERDICT: NOT DONE

# Independent museum playtest, round 3 — 8 October 2026

Review in progress. Reviewer: Codex, working alone. No game code or assets changed. Acceptance source: Issue #238 and `docs/playtest/museum-playtest-rules.md`; owner deadline: Friday 9 October, 13:00 America/New_York.

Candidate checkout: `8348b28a1767ed42737c7bce6bb5a71ccdfbf507` on `review/round-3`. Browser candidate: `https://windows-wsl.taile06c45.ts.net/museum-latest-75d82bf6/`. VERIFIED: the served index identifies `3b460c1c` and redirects to its HTML page; Godot changes the document title to `risd-godot`. `git diff 3b460c1c 8348b28a -- modules project.godot` is empty: the runtime source matches. The share suffix is not a git SHA. Documentation commits do not change the candidate game.

VERIFIED means reproduced and inspected by this reviewer. INFERRED identifies a conclusion that has not been reproduced. NEW means absent from both 8 October censuses; KNOWN means the class or instance is already documented. Finding numbers were assigned as reproductions were confirmed; the repair priority list at the end ranks visitor impact.

## Findings

### 1. The first stone doorway interrupts walking with a freeze, then replaces the whole room and darkens the visitor.

**VERIFIED · BLOCKS · NEW** for the measured freeze and visitor lighting switch; **KNOWN** for the static black cut-away already in room census area 2. Where: Main Hall ↔ dark medieval room, central stone portal, WASD and Shift. Reproduce: (1) From the starting position, hold W into the medieval room. (2) Hold S back through the same door, with Shift for the return. The first captured entry has a 0.986 s gap between captured frames; a second session has a 0.455 s entry capture gap and a 0.600 s return capture gap. Those gaps include the recording path and are not exact frame-time measurements. The game's own performance probe reports a 388.7 ms process gap at visitor position `(0, 0.178)`, immediately across the portal. Other measured Hall/grey crossings do not show comparable gaps. On the first browser walk across the medieval room towards its east door, median process gaps rise to 68 ms during the traverse and 94 ms by the door (maximum 124 ms); subsequent passes over that door return to 25–34 ms medians. This supports a first-exposure pacing concern, without isolating its cause. The cut replaces the Hall facade with the medieval set while the visitor changes from lit to dark. INFERRED: room visibility/lightmap work is responsible; the cause was not isolated, and concurrent GPU jobs make these timings host-specific.

Evidence: [continuous portal frames](../../../evidence/review-round-3/01-portal-crossing.jpg); scratch `01-hall-medieval-walk.mp4`, `02-hall-medieval-repeat.mp4`, their `*-frames.json`, `02-path.json`, and `22-path.json` / `22-medieval-lion-doors.mp4`. The missing timestamps are disclosed in the sheet, not filled with duplicated frames.

### 2. Clicking the floor while holding a movement key suddenly makes the visitor walk at almost twice the speed.

**VERIFIED · BLOCKS · NEW.** Where: marble stair hall and Main Hall; mixed WASD plus click-to-walk. Reproduce: (1) In the marble hall, face north with clear floor behind the visitor. (2) Hold S, then click the floor near the bottom centre while continuing to hold S. (3) Release S after the click route has started. Chrome position/delta samples rise from the normal 1.20 m/s to 2.39 m/s while the key and click route both run, then fall back to 1.20 when the short route ends; no Shift was pressed. An independent fixed-60 engine reproduction in the Hall measures 1.200 m/s for W alone and 2.400 m/s for W plus a forward floor click. The visitor keeps its walking presentation while accelerating. This affects ordinary mixed mouse/keyboard play, not only a diagnostic input combination.

Evidence: [continuous browser movement](../../../evidence/review-round-3/03-key-click-speed.jpg); scratch `09-mixed-key-click-marble.mp4`, `09-mixed-perf.json`, and `mixed-input/report.json` (control versus clicked run).

### 3. Clicking the carved diptych opens the book cover hanging behind it.

**VERIFIED · POLISH · NEW instance** of the prior rounds' wrong-work picking class; neither census records this mis-selection. Where: Light Renaissance room, north-facing dollhouse view near the north door, glass case on the east wall. Reproduce: (1) Stand near `(-8.05, 1.0)` in Hall-local x/z metres, facing north. (2) Click the middle of the sloping carved diptych 22.201 in the east case. The visitor walks over and the caption reads “Book cover”, RISD Museum 34.016. The native probe delivered a mouse click at `(848.5, 390.9)` in a 960 × 640 museum viewport and recorded requested tag `22.201#30`, selected and inspected tag `34.016#31`. Two browser clicks on the diptych near this pose open the correct work. This finding is therefore verified for the 960 × 640 native viewport, not yet for the browser; the sensitivity to viewport or exact pose is unresolved.

Evidence: [clicked diptych and wrong caption](../../../evidence/review-round-3/04-diptych-wrong-work.jpg); scratch `picks/report.json`, `inspection-motion/report.json`, and the continuous frames in `inspection-motion/diptych/`.

### 4. A click on the visible wall sends the visitor into a different room.

**VERIFIED · POLISH · NEW** for the wall-as-floor interaction; **KNOWN** for the room bleed behind it. Where: Rockefeller, by the east door, camera facing east. Reproduce: (1) Stand inside the east doorway and turn the camera east. (2) Click the blank wall just left of the portrait visible at the picture's right edge (marked in the evidence). (3) Wait about five seconds. The game treats that wall pixel as a floor target, routes the visitor through the connector/grey gallery, and ends in the Main Hall. Two Chrome runs reproduce this; the second moves from `(-5.00, -28.39)`, space `far`, to `(-1.71, -25.48)`, space `gallery`, on one click at browser `(800, 488)` in a 1080-square window. This is an unexpected destination for a visitor trying to interact with the wall beside a visible work.

Evidence: [wall click and resulting room](../../../evidence/review-round-3/05-wall-click-changes-room.jpg); scratch `15-rockefeller-turn-and-case.mp4`, `16-wall-click-repro.mp4`, and `16-wall-click.json`.

### 5. Opening the game means a long wait on an almost blank loader, even after its large download finishes.

**VERIFIED · POLISH · NEW.** Where: first browser load, before Collection appears. Reproduce: (1) Open the supplied build on a fresh page in Chrome. (2) Wait for the Collection to appear. Two foreground page loads take 49.54 s and 48.82 s to `game-shown`; the first finishes downloading at 2.42 s and loading the scene at 4.06 s, but `launch-settled` does not arrive until 40.26 s. The downloaded game pack is 204,592,387 compressed bytes (195.1 MiB), plus a 10,084,300-byte WASM file. With 2 MiB/s download throughput and 100 ms latency, downloads alone take 109.26 s. The slow run eventually shows the game, but its total time is excluded because a background-tab pause interrupted warmup. INFERRED: the download weight and post-download construction make this a likely first-visit abandonment point. No first-load performance budget is specified, and host contention affects the construction time.

Evidence: [loader and measured timeline](../../../evidence/review-round-3/06-first-load-wait.jpg); scratch `browser-events.jsonl`, `slow-load-perf.json`, and `served-page.html`. This is a measured first-load concern, not a claim that loading failed.

## Coverage and measurements

VERIFIED: fresh engine harness `--only=doors` completed 38 doorway legs with zero failures. A separate corrected real-key probe completed all 76 walk/sprint legs, reached each expected room, recorded 5,392 body/camera frames and JPEGs every six fixed-60-FPS frames. Maximum camera and body step was 0.0500002 m (normal 3 m/s sprint at 60 FPS), with no measured position jump. The first probe stopped short of seven endpoints because of its tolerance; those apparent failures were probe errors and are not game findings. The fresh visitor #259 acceptance check passes its stride, landing and reversal checks. Four additional fixed-60 doorway jump probes (Hall/medieval, Renaissance/medieval, Modern/Lion, Rockefeller/European) each reach a 0.6612 m hop and return to idle on the ground; continuous sheets were inspected. The browser Renaissance/medieval jump lands cleanly. No new clip-restart or landing defect was reproduced. Chrome uses the requested ANGLE GL/EGL GPU flags. Its first two loads reached `game-shown` at 49.54 s and 48.82 s; downloads finished at 2.42 s on the first load. These are shared-host observations, not isolated benchmarks. Continuous recordings, frame timing, browser console output and scratch probes stay under `build/review-round-3/` (ignored). Browser resize checks at 1440 × 900 and 640 × 480 preserve the game, and the Collection frame grip also scales an open Lion inspection without overflowing its caption. Lion selection, the correct zoom image, wheel zoom, drag panning and Escape close work. Map/Collection switching preserves the visitor and clears movement held across a tab change. No browser page exceptions or script errors have been logged; the console does contain 466 resource UID fallback warnings, four unsupported GLES 2D-MSAA warnings, and a favicon 404 across the two instrumented loads. Selected JPEG evidence is committed under `docs/evidence/review-round-3/`.

## Ten findings to fix before Friday 13:00

Pending confirmed findings and prioritization.

## What could not be tested

Pending final coverage accounting.

## What the harness should learn

Pending confirmed motion and interaction failures. This review will not modify the harness.
