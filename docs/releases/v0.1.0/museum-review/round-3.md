VERDICT: NOT DONE

# Independent museum playtest, round 3 — 8 October 2026

Reviewer: Codex, working alone. No game code or assets changed. Acceptance source: Issue #238 and `docs/playtest/museum-playtest-rules.md`; owner deadline: Friday 9 October, 13:00 America/New_York.

Candidate checkout: `8348b28a1767ed42737c7bce6bb5a71ccdfbf507` on `review/round-3`. Browser candidate: `https://windows-wsl.taile06c45.ts.net/museum-latest-75d82bf6/`. VERIFIED: the served index identifies `3b460c1c` and redirects to its HTML page; Godot changes the document title to `risd-godot`. `git diff 3b460c1c 8348b28a -- modules project.godot` is empty: the runtime source matches. The share suffix is not a git SHA. Documentation commits do not change the candidate game.

VERIFIED means reproduced and inspected by this reviewer. INFERRED identifies a conclusion that has not been reproduced. NEW means absent from both 8 October censuses; KNOWN means the class or instance is already documented. Finding numbers were assigned as reproductions were confirmed; the repair priority list at the end ranks visitor impact.

## Findings

### 1. The first stone doorway interrupts walking with a freeze, then replaces the whole room and darkens the visitor.

**VERIFIED · BLOCKS · NEW** for the measured freeze and visitor lighting switch; **KNOWN** for the static black cut-away already in room census area 2. Where: Main Hall ↔ dark medieval room, central stone portal, WASD and Shift. Reproduce: (1) From the starting position, hold W into the medieval room. (2) Hold S back through the same door, with Shift for the return. The first captured entry has a 0.986 s gap between captured frames; a second session has a 0.455 s entry capture gap and a 0.600 s return capture gap. Those gaps include the recording path and are not exact frame-time measurements. The game's own performance probe reports a 388.7 ms process gap at visitor position `(0, 0.178)`, immediately across the portal. Other measured Hall/grey crossings do not show comparable gaps. On the first browser walk across the medieval room towards its east door, median process gaps rise to 68 ms during the traverse and 94 ms by the door (maximum 124 ms); subsequent passes over that door return to 25–34 ms medians. This supports a first-exposure pacing concern, without isolating its cause. The cut replaces the Hall facade with the medieval set while the visitor changes from lit to dark. INFERRED: room visibility/lightmap work is responsible; the cause was not isolated, and concurrent GPU jobs make these timings host-specific.

A third reproduction immediately after a fresh foreground load records all four combinations of direction and gait. It has a 399.2 ms capture gap; while a key is held within 0.5 m of the threshold, the in-game probe records a maximum 380.8 ms wall-clock process interval and 138.4 ms game delta. All four routes arrive. No native probe was running during this repeat. VERIFIED: the pause survives a fresh browser load; INFERRED: its magnitude on the owner's hardware remains unknown.

Evidence: [continuous portal frames](../../../evidence/review-round-3/01-portal-crossing.jpg); scratch `01-hall-medieval-walk.mp4`, `02-hall-medieval-repeat.mp4`, their `*-frames.json`, `02-path.json`, `22-path.json` / `22-medieval-lion-doors.mp4`, and `45-path.json` / `45-cold-portal-all-gaits.mp4`. The missing timestamps are disclosed in the sheet, not filled with duplicated frames.

### 2. Clicking the floor while holding a movement key suddenly makes the visitor walk at almost twice the speed.

**VERIFIED · BLOCKS · NEW.** Where: marble stair hall and Main Hall; mixed WASD plus click-to-walk. Reproduce: (1) In the marble hall, face north with clear floor behind the visitor. (2) Hold S, then click the floor near the bottom centre while continuing to hold S. (3) Release S after the click route has started. Chrome position/delta samples rise from the normal 1.20 m/s to 2.39 m/s while the key and click route both run, then fall back to 1.20 when the short route ends; no Shift was pressed. An independent fixed-60 engine reproduction in the Hall measures 1.200 m/s for W alone and 2.400 m/s for W plus a forward floor click. The visitor keeps its walking presentation while accelerating. This affects ordinary mixed mouse/keyboard play, not only a diagnostic input combination. Two browser runs also select the Lion relief while W is already held, carry the visitor past its viewing spot to `(7.25, 0.35)`, and never open the inspection, including 4.3 s after W is released. A click-only control near the same starting pose opens the correct Lion caption. The browser logs `NAV_PICK lion-panel#48` in both cases, so the moving click did reach the work. This is another consequence of the competing inputs, not a separate counted finding.

Evidence: [continuous browser movement](../../../evidence/review-round-3/03-key-click-speed.jpg); scratch `09-mixed-key-click-marble.mp4`, `09-mixed-perf.json`, and `mixed-input/report.json` (control versus clicked run). [Moving art click and click-only control](../../../evidence/review-round-3/07-moving-click-no-inspection.jpg); scratch `36-click-art-while-walking.mp4`, `40-lion-mixed-click-repeat.mp4`, `40-mixed-art.json` and `39b-lion-mixed-click-control.mp4`.

### 3. Clicking the carved diptych opens the book cover hanging behind it.

**VERIFIED · POLISH · NEW instance** of the prior rounds' wrong-work picking class; neither census records this mis-selection. Where: Light Renaissance room, north-facing dollhouse view near the north door, glass case on the east wall. Reproduce: (1) Stand near `(-8.05, 1.0)` in Hall-local x/z metres, facing north. (2) Click the middle of the sloping carved diptych 22.201 in the east case. The visitor walks over and the caption reads “Book cover”, RISD Museum 34.016. The native probe delivered a mouse click at `(848.5, 390.9)` in a 960 × 640 museum viewport and recorded requested tag `22.201#30`, selected and inspected tag `34.016#31`. Two browser clicks on the diptych near this pose open the correct work. This finding is therefore verified for the 960 × 640 native viewport, not yet for the browser; the sensitivity to viewport or exact pose is unresolved.

Evidence: [clicked diptych and wrong caption](../../../evidence/review-round-3/04-diptych-wrong-work.jpg); scratch `picks/report.json`, `inspection-motion/report.json`, and the continuous frames in `inspection-motion/diptych/`.

### 4. A click on the visible wall sends the visitor into a different room.

**VERIFIED · POLISH · NEW** for the wall-as-floor interaction; **KNOWN** for the room bleed behind it. Where: Rockefeller, by the east door, camera facing east. Reproduce: (1) Stand inside the east doorway and turn the camera east. (2) Click the blank wall just left of the portrait visible at the picture's right edge (marked in the evidence). (3) Wait about five seconds. The game treats that wall pixel as a floor target, routes the visitor through the connector/grey gallery, and ends in the Main Hall. Two Chrome runs reproduce this; the second moves from `(-5.00, -28.39)`, space `far`, to `(-1.71, -25.48)`, space `gallery`, on one click at browser `(800, 488)` in a 1080-square window. This is an unexpected destination for a visitor trying to interact with the wall beside a visible work.

Evidence: [wall click and resulting room](../../../evidence/review-round-3/05-wall-click-changes-room.jpg); scratch `15-rockefeller-turn-and-case.mp4`, `16-wall-click-repro.mp4`, and `16-wall-click.json`.

### 5. Opening the game means a long wait on an almost blank loader, even after its large download finishes.

**VERIFIED · POLISH · NEW.** Where: first browser load, before Collection appears. Reproduce: (1) Open the supplied build on a fresh page in Chrome. (2) Wait for the Collection to appear. Two foreground page loads take 49.54 s and 48.82 s to `game-shown`; the first finishes downloading at 2.42 s and loading the scene at 4.06 s, but `launch-settled` does not arrive until 40.26 s. The downloaded game pack is 204,592,387 compressed bytes (195.1 MiB), plus a 10,084,300-byte WASM file. A controlled foreground load with the cache disabled, 2 MiB/s download throughput and 100 ms latency takes 159.275 s to `game-shown`: downloads finish at 110.071 s, followed by another 49.204 s of initialization/warmup. Visibility stays `visible`. The earlier slow run had a background-tab pause and is excluded from total-time comparisons. INFERRED: the download weight and post-download construction make this a likely first-visit abandonment point. No first-load performance budget is specified, and host contention affects the construction time.

Evidence: [loader and measured timeline](../../../evidence/review-round-3/06-first-load-wait.jpg); scratch `browser-events.jsonl`, `44-slow-foreground.json`, `44-slow-foreground-load.mp4`, `slow-load-perf.json` (earlier paused run), and `served-page.html`. This is a measured first-load concern, not a claim that loading failed.

### 6. “Other wall” moves the visitor out of sight but leaves the inspection on the old wall.

**VERIFIED · POLISH · NEW.** Where: Main Hall, inspection of *Christ at the Column*, W2 / 56.177; the visible “Other wall” button. Reproduce: (1) Inspect W2. (2) Click “Other wall” at the bottom right. (3) Wait six seconds. The visitor walks from x = −2.953 to +2.575 m across the Hall, disappears from the picture, and the camera and caption stay on *Christ at the Column*. A second reproduction, inspecting *Portrait of a Cavalier with his Hunting Dogs* (E8 / 62.064), moves from x = +2.992 to −2.563 m and retains that east-wall caption and picture. Escape then reveals the wall the visitor actually walked to. The same button works as a wall-view shortcut outside inspection (recording 38). INFERRED: this button starts navigation without ending the inspection state. This is a distinct button/state failure, not the previously known camera-return timing defect.

Evidence: [before and after the button](../../../evidence/review-round-3/10-other-wall-keeps-inspection.jpg); scratch `42-other-wall-during-inspection.mp4`, `42-other-wall-inspection.json`, `42b-other-wall-inspection-repeat.mp4`, `42b-other-wall-inspection.json` and `43-other-wall-escape-recovery.mp4`.

## Coverage and measurements

VERIFIED: the fresh engine harness `--only=doors` completed 38 doorway legs with zero failures. A separate corrected real-key probe completed all 76 walk/sprint legs across its 19 doorway records, reached each expected room, and recorded 5,392 body/camera frames with JPEGs every six fixed-60-FPS frames. Maximum camera and body step was 0.0500002 m (normal 3 m/s sprint at 60 FPS), with no measured position jump. The first probe stopped short of seven endpoints because of its tolerance; those apparent failures were probe errors and are not game findings. [Door coverage pictures](../../../evidence/review-round-3/08-native-door-coverage.jpg) and [reveal/threshold coverage pictures](../../../evidence/review-round-3/09-native-threshold-coverage.jpg) summarize the native run; the continuous frames and raw counts are in `doors/report.json` and `dynamics-confirm/report.json` under the scratch directory.

VERIFIED: browser movement traversed every built physical connection below in both directions at walk and sprint, with continuous crossings inspected as contact sheets. The six extra native records split the ends of reveals already traversed in these routes. The missing Impressionist connection prevents completing the intended marble-to-modern loop; the built circuit was covered by returning through the Hall and medieval room. Camera turns, inspections and their return glides were recorded continuously as well.

| Browser connection | Scratch continuous recording(s) |
| --- | --- |
| Main Hall ↔ medieval | `01`, `02`, `45-cold-portal-all-gaits.mp4` |
| Main Hall ↔ Grey | `04-hall-grey-real.mp4` |
| Grey ↔ marble stair hall | `08-grey-marble-first-entry.mp4`, `10-marble-return-sprint-jump.mp4` |
| Grey ↔ Skylight | `11-grey-skylight-both-gaits.mp4` |
| Grey ↔ purple connector | `13-skylight-grey-purple-doors.mp4` |
| Purple connector ↔ Rockefeller | `14b-purple-rockefeller-doors.mp4` |
| Rockefeller ↔ European | `17-return-to-rockefeller-european.mp4` |
| European ↔ Renaissance | `19b-european-renaissance-doors.mp4` |
| Renaissance ↔ medieval | `21-renaissance-medieval-doors.mp4` |
| Medieval ↔ Lion landing | `22-medieval-lion-doors.mp4` |
| Lion landing ↔ Modern | `24-modern-lion-doors.mp4` |
| Lion landing ↔ white sculpture stub | `31-lion-sculpture-stub.mp4` |
| Modern ↔ adjoining gallery stub | `32-modern-adjacent-stub.mp4` |

VERIFIED: the fresh visitor #259 acceptance check passes its stride, landing and reversal checks. Four additional fixed-60 doorway jump probes (Hall/medieval, Renaissance/medieval, Modern/Lion, Rockefeller/European) each reach a 0.6612 m hop and return to idle on the ground; their continuous sheets were inspected. The browser Renaissance/medieval jump lands cleanly. Walking and sprinting carry their strides through these crossings, and the hop has a consistent rise and landing. No new clip-restart or landing defect was reproduced. This does not certify every animation or stair collision.

VERIFIED: browser resize checks at 1440 × 900 and 640 × 480 preserve the game; the Collection frame grip also scales an open Lion inspection without overflowing its caption. Hall N1 and Lion selection/zoom/close work, including Lion wheel zoom and drag panning. Map/Collection switching preserves the visitor and clears movement held across a tab change. Chrome used the requested ANGLE GL/EGL GPU flags. Recordings target 12 captures/s and retain exact capture timestamps. Actual capture gaps during stalls are disclosed; the 12-FPS encoded movie duration is not elapsed wall time. The native 10-picture/s fixed-FPS run is a continuity check, not a browser frame-pacing benchmark.

VERIFIED: the baseline checks from `scripts/check.sh` pass using a scratch copy with the import log redirected into `build/review-round-3/` and Godot wrapped in `timeout`. `git diff --check` passes. No browser page exceptions, request-failure callbacks or `SCRIPT ERROR` entries were recorded. The final browser log contains 699 resource UID fallback warnings, six unsupported GLES 2D-MSAA warnings and one HTTP 404 console entry across the three foreground loads. The 1,411 console entries classified as errors include warning stack lines; they are not 1,411 separate game failures. Logs are retained, not treated as a clean console. No new game exception was reproduced. All scratch scripts, continuous recordings, timing and console output are under the ignored `build/review-round-3/`, below 1 GB. Eleven selected JPEGs, each below 300 KB, are committed under `docs/evidence/review-round-3/`.

## Ten findings to fix before Friday 13:00

INFERRED: this repair order is reviewer judgment based on when the visitor encounters each defect and how strongly it interrupts exploring. It contains six new findings and four explicitly known carryovers, not ten new discoveries. The Hall lighting, caption blocks and replacement meshes already assigned to builders are not counted again here.

| Order | Fix / visible acceptance | Evidence status |
| --- | --- | --- |
| 1 | **NEW #5:** shorten the cold download and post-download wait; keep the loader visibly informative until the game can be used. | VERIFIED: 48.8–49.5 s foreground loads; 159.3 s at 2 MiB/s. |
| 2 | **NEW #1:** remove the stone-portal pause and abrupt visitor lighting switch while crossing. | VERIFIED: repeated browser capture/process gaps and a lit-to-dark visitor. |
| 3 | **KNOWN:** keep black/navy cut-away slabs and abrupt room replacement out of doorway views. | VERIFIED again in the browser; [room census, common fault 5](../../../playtest/census-2026-10-08-rooms.md#the-same-seven-faults-in-most-rooms), evidence `01`/`02` and recordings `11`, `14b`, `21`, `32`, `45`. |
| 4 | **KNOWN:** keep the lens clear through camera turns and inspection returns. | VERIFIED again: Escape after #6 fills the picture with wall for several captures; [continuous return evidence](../../../evidence/review-round-3/11-inspection-return-wall.jpg). Prior round 2 finding 3. |
| 5 | **NEW #2:** arbitrate click routes and held movement so speed stays correct and an art click finishes its inspection approach. | VERIFIED: 1.2 → 2.4 m/s without Shift; two moving Lion clicks never open inspection. |
| 6 | **NEW #6:** make “Other wall” during inspection change the camera and caption coherently with the visitor's destination. | VERIFIED twice on opposite Hall walls. |
| 7 | **NEW #4:** stop a visible wall click from becoming a floor route to another room. | VERIFIED twice, Rockefeller → Hall. |
| 8 | **KNOWN:** make only visible intended works answer, including works visible through a door; retain the correct inspection/zoom identity. | [Prior round 2 finding 1](round-2.md). INFERRED carryover requiring builder recheck; this round did not recertify its 14 hidden-work count. |
| 9 | **KNOWN:** resolve the broken marble-to-modern route through the missing Impressionist rooms, within the agreed scope. | VERIFIED: the marble end is closed and the modern end is a small dead-end stub. [Room census](../../../playtest/census-2026-10-08-rooms.md#which-room-in-the-footage-is-missing), recordings `10`/`32`; the footage identification is inherited from the census. |
| 10 | **NEW #3:** reproduce and correct the diptych/book-cover picking overlap at 960 × 640. | VERIFIED natively only; browser control clicks passed. Lower browser priority until matching reproduction. |

## What could not be tested

VERIFIED limitation: this round used Linux GPU headless Chrome and native Godot Compatibility on the shared host. Safari, Firefox, mobile/touch, the owner's hardware and an isolated performance run were not tested. First entry into each room was recorded, but each room was not independently cold-loaded and benchmarked. Capture/host overhead prevents attributing every long interval to rendering alone.

VERIFIED limitation: the full 24-minute four-pass census harness was not rerun; its doorway subset and targeted probes were run fresh. This review does not replace the prior 177-object/110-view census, certify every artwork at every size, or exhaustively test every case corner, one-pixel shimmer, reachable stair edge and shadow attachment. Automated navigation mistakes (a stale camera heading, an endpoint tolerance and attempts to take a straight path through furniture) were excluded from game findings. The native diptych mis-pick could not be reproduced in Chrome at the tested nearby pose.

VERIFIED limitation: WebAudio was captured and its waveform distinguishes silent idle from nonzero walking output, but audio playback was unavailable to this reviewer. Floor-specific footstep timbre, perceived loudness and whether browser clicks double their cues are therefore unverified. Native gait acceptance counts pass; that is not a listening test. OS focus loss and slow-device CPU throttling were not fully exercised. The controlled slow-network run was foreground and completed; the earlier background-paused load is excluded.

VERIFIED limitation: reference ledgers, the two censuses, prior-round reports and the owner's ten screenshots were read; this round concentrated on motion and interaction rather than repeating their complete footage census. Work being changed by other builders after the tested candidate is not covered by this verdict.

## What the harness should learn

INFERRED recommendation: add real browser input sequences that overlap a held direction with a floor/art click and exercise “Other wall” during inspection, asserting one movement speed, eventual approach completion, and coherent visitor/camera/caption state. Record external monotonic time as well as fixed game delta through first entry and return, and fail long stalls separately from position jumps: 76 smooth fixed-FPS paths did not certify real-time browser continuity. Retain continuous captured pixels through every camera interpolation and threshold, flag wall-filled frames and abrupt visitor luminance changes, and compare actual visible geometry with the selected work at several viewport sizes. Add a cache-disabled, foreground, bandwidth-limited first-load check that separates download, construction, warmup and game-shown, plus an actual audible-output check. The harness itself was not changed during this review.
