---
round: 1
commit: a29ad9e9
reviewer: gpt-6.1-sol, xhigh
date: 2026-10-01
verdict: not done
---

VERDICT: NOT DONE

| Room / area | Result | Reason | Picture compared with footage |
|---|---|---|---|
| Main Hall | FAIL | Missing wall vent; brown labels; tall paintings cropped. | [Hall](build/review-round-1/comparisons/grand-gallery.jpg) |
| Medieval | FAIL | Crucifix display missing; simplified contents; detached shadows. | [Medieval](build/review-round-1/comparisons/dark-medieval-room.jpg) |
| Renaissance | FAIL | Wall text absent; simplified supports; inspection obscures small works. | [Renaissance](build/review-round-1/comparisons/light-renaissance-room.jpg) |
| European / adjacent gallery | FAIL | Filmed central displays and much of the hanging are missing. | [European](build/review-round-1/comparisons/adjacent-gallery.jpg) |
| Rockefeller | FAIL | Central pedestal figures, neighboring prints and textile missing. | [Rockefeller](build/review-round-1/comparisons/rockefeller.jpg) |
| Purple elevator connector | FAIL | Call button, opposite opening and lighting detail absent. | [Connector](build/review-round-1/comparisons/purple-elevator-5-connector.jpg) |
| Grey French gallery | FAIL | Missing sculpture; marble hall replaced by a stub. | [Grey](build/review-round-1/comparisons/grey-french-gallery.jpg) |
| Lion stair landing | FAIL | Parallel wooden flights replace the filmed stone open-well stair. | [Stair](build/review-round-1/comparisons/lion-stair-landing.jpg) |
| Modern gallery | FAIL | Opaque blinds, coarse sculpture and shadows of hidden paintings. | [Modern](build/review-round-1/comparisons/modern-painting-gallery.jpg) |
| Ionic threshold | FAIL | Empty narrow stub replaces the marble stair hall. | [Ionic](build/review-round-1/comparisons/ionic-marble-stair-threshold-study-limit.jpg) |
| Piano threshold | FAIL | Skylight Gallery, piano and displays absent. | [Piano](build/review-round-1/comparisons/piano-stair-threshold-study-limit.jpg) |
| White sculpture threshold | FAIL | Visible gallery and sculpture displays replaced by an empty stub. | [Sculpture](build/review-round-1/comparisons/white-sculpture-gallery-threshold-study-limit.jpg) |
| Modern adjoining threshold | FAIL | Visible portrait, windows and gallery continuation omitted. | [Adjoining](build/review-round-1/comparisons/modern-adjoining-gallery-threshold-study-limit.jpg) |
| Main Hall reveal | FAIL | Painting and label beside the opening missing. | [Hall reveal](build/review-round-1/comparisons/grand-gallery-reveal-threshold.jpg) |
| Rockefeller reveal | FAIL | Folded door leaf, lettering and neighboring displays missing. | [Rockefeller reveal](build/review-round-1/comparisons/rockefeller-reveal-threshold.jpg) |

Reviewed commit `a29ad9e9`, including the pre-existing untracked object data. The required four-pass command ran at fixed 60 FPS into the requested directory and **exited 1**: 34 doorway legs, 34 room approaches, 105 views, 104 object attempts. There were **five failures**: piano north view, sculpture-threshold east view, adjoining-threshold north and south views, and the lion’s second-click zoom. Only 103 objects completed inspection, zoom and close. [Actual report](build/review-round-1/playtest/report.json).

I opened all **105 room views in 21 labeled sheets**, **40 distinct inspection pictures in 10 sheets**, all 15 footage comparisons, and additional wall/inspection/walk pictures. [Exact opened-picture list](build/review-round-1/opened-images.md).

Beyond the harness, I exercised 34 Shift doorway legs, 30 Q/E turns, 45 mode changes, 60 corners and 49 floor obstacles/benches. Separate scripts tested jumps, approach cancellation, walking away, modal keys, focus loss and picking. A real Chrome keyboard run completed the museum loop and returned to the Hall. These checks exposed the following defects.

1. **blocks done — Missing rooms, displays and incorrect stair topology.** The table’s paired footage proves specific omissions independently of the inventory total. The filmed stair has an open well and stone flights; the build has parallel wooden runs. Reproduce by following the museum loop and comparing those walls/openings. Fixed means the observed displays, room continuations and stair structure exist with the filmed placement and materials.

2. **blocks done — Inspection hides the selected art.** The visitor’s head covers Apostle 41.046, Madonna 58.196 and other small works; inspection of 51.105 becomes an almost entirely brown image. Reproduce with `checklist_play.gd`, or click those works normally. Fixed means the entire work and frame remain visible with the visitor composed beside them. [Obstructed inspection](build/review-round-1/playtest/object-51.105-9.png).

3. **blocks done — An unreachable floor click throws.** From Renaissance position `(-8,0,2.5)`, north-facing dollhouse, click `(15,200)` in a 960×640 viewport. `extra_play.gd` delivered that pointer event; the log records `Invalid operands 'Nil' and 'Vector3'` at `walk4.gd:3161`. The router returns no target and `_click` subtracts it anyway. Fixed means an unreachable click is harmless. [Log](build/review-round-1/extra-console.log:1766).

4. **blocks done — Picking contradicts visibility and breaks lion zoom.** Nine probes select hidden nodes. Separately, approaching the lion puts the visitor in the neighboring sculpture threshold; the room filter then rejects the visibly selected lion. Its second click advances text instead of opening zoom. Reproduce with `focused_play.gd` and `final_probes.gd`. Fixed means hidden works cannot steal clicks and a visible reachable work remains selectable from its actual inspection position. [Lion evidence](build/review-round-1/final-probes/report.json).

5. **blocks done — Lighting, labels and cut-away shadows fail finish.** Floors dominate the light; individual exhibit pools are incomplete; hidden paintings leave black wall patches. A Hall label measures RGB `(113,101,76)`, R/B **1.487**, exceeding the checklist’s 1.25 limit. Reproduce the room views and rotate the modern gallery. Fixed means work-focused lighting, readable cream labels and shadows consistent with visible geometry. [Detached shadow](build/review-round-1/playtest/modern-painting-gallery-0-s.png).

The remaining findings concern the release gate, controls and animation.

6. **blocks done — The repository baseline fails.** A read-only copy of `scripts/check.sh`, redirecting its temporary log into the permitted directory, exits 1 with four private-module import violations in the generated room files. Reproduce with `check-readonly.sh`. Fixed means the actual baseline passes through approved interfaces. `git diff --check` passes. [Baseline output](build/review-round-1/baseline.log).

7. **should fix — Shift state is mishandled.** Press Shift during reading, then hold W: reading closes, but sprint remains false and pace stays 1.2 m/s. Conversely, a focus-out notification without subsequent Shift key-up leaves the sprint latch selecting 3.0 m/s. The focused and extra scripts reproduce both. Fixed means modifiers remain correct through reading, modal and focus transitions. [Input evidence](build/review-round-1/focused/report.json).

8. **should fix — Approach turning advances the visitor twice per frame.** `main_build_walk.gd:490` calls `pose(delta)` while the parent process also calls it at `walk4.gd:2788`. This advances animation, blink, contacts and hop simulation twice during that turn. This finding is proven by the call path; I did not separately measure its visual speedup. Fixed means one advancement per frame.

9. **should fix — View changes cut instantly.** Mode changes produced same-call camera displacements of approximately **2.80 m** and **5.85–6.24 m**. `_set_view` forces an immediate camera update; Other Wall also relocates the visitor. Reproduce by switching modes and using Other Wall. Fixed means a glide or deliberate wipe. [Measured transitions](build/review-round-1/extra/report.json).

10. **polish — Rate-dependent jumping, working-note captions and extra sound cues.** Jump apex is `.547/.601/.631/.646 m` at 15/30/60/120 Hz. Some titles retain scene descriptions and raw `**Paris**` markup. Zoom opening calls two cues, contrary to the one-sound-per-press requirement. Reproduce the focused rate test and open those entries. Fixed means stable jumping, museum-facing captions and one brief cue per press. [Caption](build/review-round-1/playtest/object-e4.png).

The 23-item checklist follows. H=Hall, M=medieval, R=Renaissance, O=modern. Each linked sheet contains standard/wall, inspection and page pictures: [H](build/review-round-1/sheets/checklist-hall.jpg), [M](build/review-round-1/sheets/checklist-medieval.jpg), [R](build/review-round-1/sheets/checklist-renaissance.jpg), [O](build/review-round-1/sheets/checklist-modern.jpg). **No† means not demonstrated, not a proven defect.**

| # | Finish criterion | H | M | R | O | Picture/evidence |
|---|---|---|---|---|---|---|
| 1 | Whole wall frames visible at 3 m | No | Yes | No | No | Wall pictures; tall hangs cropped |
| 2 | Tall-work camera eases to include frame and label | No | No | No | No | Wall/room views; fixed tilt |
| 3 | Visitor occupies 1/5–1/3 of picture height | No | No | No | Yes | Visitor masks: .394/.370/.356/.327 |
| 4 | Every view change glides or wipes | No | No | No | No | Mode pictures and displacement log |
| 5 | Near-wall removal never flickers or crosses visitor | No† | No† | No† | No† | Sampled walks insufficient |
| 6 | Brightest large area is art or surrounding wall | No | No | No | No | Standard/wall pictures |
| 7 | Individual pool; adjacent wall ≥2× darker | No | No | No | No | Wall pictures |
| 8 | Floor darkens toward edges | Yes | No | No | No | Standard/wall pictures |
| 9 | Lit label cream; R/B ≤1.25 | No | No† | No† | No† | Hall label sample; others unverified |
| 10 | Each pool has an identifiable lit lamp | No | No | No | No | Room views |
| 11 | Soft, attached, body-width visitor shadow | Yes | Yes | Yes | Yes | Wall pictures and sampled walks |
| 12 | Every furnishing has soft floor contact | No† | No | No | No | Room/wall pictures |
| 13 | Soft moving floor highlight, no shimmer | No† | No† | No† | No† | Moving-light condition unverified |
| 14 | No crawling one-pixel floor stripes | No† | No† | No† | No† | Sampled frames insufficient |
| 15 | Recognizable label for every work | Yes | No | No | No | Standard room views |
| 16 | Lit frame top and shaded inner edge | Yes | No | No | Yes | Inspection pictures |
| 17 | Every catalogue item answers with hand and tick | No† | No | No | No | Object pass, omissions, hidden hits |
| 18 | Approach, stop and turn precede inspection | Yes | Yes | Yes | Yes | Inspection records and approach flow |
| 19 | .6–.9 s low glide; work visible above visitor | Yes | No | No | Yes | Inspection pictures; .73 s tween |
| 20 | Whole title first; one page per click | Yes | Yes | Yes | Yes | Inspection/page pictures |
| 21 | Return <1 s; exactly one short sound per press | No | No | No | No | .75 s return; multiple cue calls |
| 22 | Breathing/blinking continues during reading | Yes | Yes | Yes | Yes | Pictures plus animation/blink logs |
| 23 | Bench seating and composed rest view | No | No | No | No | No seating interaction |

The harness should gain these five implementable rules:

1. Deliver clicks through the actual viewport/browser; include unreachable-floor clicks, reject script errors and assert the destination room.
2. Compare against a footage-based expected display manifest. Iterating the current `_objects` cannot detect missing objects.
3. Assert the requested inspection ID, visible work/frame/label and second-click zoom from the actual arrival position. Reject hidden hits; include cross-room works.
4. Test held modifiers across reading, zoom, focus loss and tab changes; test jumps at 15/30/60/120 Hz, including pose-update count and airborne footsteps.
5. Record continuous turns, all modes, corners and doorway transitions; reject camera/head intersections, instantaneous cuts and retained shadows. Add bench seating/rest/return, and reject screenshot seeds inside furniture.

I did **not** independently recount all 212 objects, survey physical painting/room dimensions, establish unseen connections, certify every furniture face or listen to audio. Physical size comparisons remain qualitative. Temporal criteria marked No† remain unverified. `gdlint` is unavailable.

The existing browser export differs from this checkout in **14 caption/image records**. A supplementary four-room browser checklist attempt ended with status 143 before the game appeared; its cause is unknown. I therefore separate the completed browser walk from the current native checklist and claim no complete matching web certification.

[Full report, commands and room-by-room architectural comparisons](build/review-round-1/review.md). Approximately **454 MB** of scripts, pictures, JSON, audio and logs remain under `build/review-round-1/`. The temporary server was stopped. No tracked files or Git state were changed; no paid API calls were made.