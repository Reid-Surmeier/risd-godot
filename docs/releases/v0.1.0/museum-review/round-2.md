---
round: 2
commit: fbb57bcc
reviewer: gpt-6.1-sol, xhigh
date: 2026-10-02
verdict: not done
note: the reviewer reached its two-hour limit before filing; this is its own finished draft (review.md, written 33 minutes before the stop), not a filed verdict. Linked evidence stayed in the review checkout under build/review-round-2/ and is not in the repository.
---

VERDICT: NOT DONE

|Round-1 finding|Closure|Current reproduction|Picture/log|
|---|---|---|---|
|1 — omissions / stairs|Partly closed|New displays/stone stair exist; shelf, inlay board and Skylight levels absent.|[wall-ledger.md](wall-ledger.md)|
|2 — inspection occlusion|Partly closed|41.046 / 58.196 / 51.105 closed; new covered/absent inspections remain.|[playtest/object-69.196-46.png](playtest/object-69.196-46.png)|
|3 — unreachable click throws|Closed|Exact position (-8,0,2.5), heading north, click (15,200): no error, no target.|[hidden/report.json](hidden/report.json)|
|4 — hidden picks / lion zoom|Partly closed|Lion zoom works; 14 hidden works still answer.|[hidden/report.json](hidden/report.json)|
|5 — light / labels / shadows|Partly closed|Hall relit; seven galleries have brightest floors; ghost patches remain.|[playtest/object-2017.46-127.png](playtest/object-2017.46-127.png)|
|6 — baseline failure|Closed|Read-only baseline copy exits 0: checks passed.|[baseline.log](baseline.log)|
|7 — Shift state|Partly closed|Reading now sprints at 3 m/s; synthetic focus result is inconclusive for actual OS focus.|[focused/report.json](focused/report.json)|
|8 — double pose advance|Closed|Main no longer calls pose; current parent process advances it once.|[code-diff.patch](code-diff.patch)|
|9 — instant camera / Other wall cut|Closed|48 mode changes have zero same-call displacement; Hall Other wall walks/glides.|[residual/report.json](residual/report.json)|
|10 — jump / captions / zoom cues|Partly closed|Apex .656–.661222 m; captions cleaned; true zoom one cue. First inspection still two.|[audio-zoom/analysis.md](audio-zoom/analysis.md)|

|Room / area|Result|Round-1 room closure|Reason|Picture|
|---|---|---|---|---|
|Main Hall|FAIL|Still open|Low vents remain absent; tall hangs crop; 21/23 hang centres differ by >10cm.|[grand-gallery](comparisons/grand-gallery.jpg)|
|Medieval|FAIL|Partly closed|Crucifix and six displays added; wrong doors/heights and covered inspection remain.|[dark-medieval-room](comparisons/dark-medieval-room.jpg)|
|Renaissance|FAIL|Partly closed|Old Madonna/Death occlusion closed; wall text, rough supports and clipped book panel remain.|[light-renaissance-room](comparisons/light-renaissance-room.jpg)|
|European / adjacent|FAIL|Partly closed|Hanging/cases added; ≥6 shelf pieces and inlay board absent; seven pieces unclickable.|[adjacent-gallery](comparisons/adjacent-gallery.jpg)|
|Rockefeller|FAIL|Closed: original omissions|Central pair, prints and textile now present; wallpaper +.55m high and chairs too narrow.|[rockefeller](comparisons/rockefeller.jpg)|
|Purple elevator connector|FAIL|Still open|Call button, opposite panelled opening and recessed lamps absent.|[purple-elevator-5-connector](comparisons/purple-elevator-5-connector.jpg)|
|Grey French gallery|FAIL|Closed: original omissions|Rodin and marble hall added; missing pier label/text, ghost shadows and bright floor remain.|[grey-french-gallery](comparisons/grey-french-gallery.jpg)|
|Lion stair landing|FAIL|Closed: old stair topology|Stone open-well stair now built; void +1.515m, tall door heads and missing rack/text remain.|[lion-stair-landing](comparisons/lion-stair-landing.jpg)|
|Modern gallery|FAIL|Still open|Opaque blinds, absent labels and shadows of hidden works; inspection removes visitor.|[modern-painting-gallery](comparisons/modern-painting-gallery.jpg)|
|Marble hall (old Ionic threshold)|FAIL|Partly closed|Hall/stairs/displays built; upper floor inaccessible and chandelier cannot be selected.|[marble-stair-hall](comparisons/marble-stair-hall.jpg)|
|Skylight Gallery (old Piano threshold)|FAIL|Partly closed|Piano and five works added; filmed stairs/void/upper and lower landings flattened.|[skylight-gallery](comparisons/skylight-gallery.jpg)|
|White sculpture threshold|FAIL|Still open|Empty study-limit stub omits observed display/door detail.|[white-sculpture-gallery-threshold-study-limit](comparisons/white-sculpture-gallery-threshold-study-limit.jpg)|
|Modern adjoining threshold|FAIL|Still open|Empty stub omits observed portrait/windows and door detail.|[modern-adjoining-gallery-threshold-study-limit](comparisons/modern-adjoining-gallery-threshold-study-limit.jpg)|
|Main Hall reveal|FAIL|Partly closed|Pier painting added; label absent, pier .50m too narrow.|[grand-gallery-reveal-threshold](comparisons/grand-gallery-reveal-threshold.jpg)|
|Rockefeller reveal|FAIL|Partly closed|Neighboring works added; folded leaf and lettering still absent.|[rockefeller-reveal-threshold](comparisons/rockefeller-reveal-threshold.jpg)|
|Skylight reveal (new area)|FAIL|New in round 2|Leaves added, but the filmed upper landing is absent.|[skylight-gallery-reveal-threshold](comparisons/skylight-gallery-reveal-threshold.jpg)|

Reviewed `fbb57bcc08682e5720edee71c12461471557b07f` with Godot 4.7.2. The required four passes **exited 1**: **38 doorway legs, 38 room-click approaches, 110 views, 177 object attempts, 176 completed inspections/zooms/closes, one failure**. Chandelier `2011.60#153` projects to `(480,-157)` in follow view and cannot be selected. [Report](playtest/report.json), [failure log](playtest-console.log:2301). No `SCRIPT ERROR` in this run. Baseline, visitor movement check, 430 rendered room probes and 16 click-route checks passed; `git diff --check` passed.

I opened all 110 harness views in 22 sheets and all 176 completed inspection pictures in 15 sheets. Also opened all 16 comparison panels, 18 wall/base sheets, nine final geometry sheets, 36 temporal sheets, eight round-1 reproduction sheets and four checklist sheets. [Exact opened pictures](opened-images.md).

Independent input runs cover 38 Shift doorway legs, 32 Q/E turns, 48 mode changes, 64 corners and 73 furnishing/bench approaches. Standing, walking, wall and doorway jumps settle with no airborne foot contacts. Space during reading advances/closes reading rather than jumping. A new click during approach selects W6; walking away closes inspection; zoom movement keys move zero distance, and closing clears held directions. [Extra records](extra/report.json), [rate/modifier tests](focused/report.json), [targeted tests](targeted/report.json). The Hall bench collision check initially applied clearance twice; that flag is a reviewer-test artefact, not a game defect.

The requested 8,139-line code diff was reviewed with two independent code-review agents and checked against runtime reproductions. [Diff](code-diff.patch). [Exact commands and runnable scripts](commands.md). Findings concern behaviour, not style.

1. **blocks done — Picking contradicts visibility and misses displays.** Across four headings in 16 areas, 228 on-screen hidden-work probes produce **14 false hits in five rooms**. Example: `NAV_PICK 34.912#67` while `drawn_meshes:0,parent_visible:true`. The picker tests the visible root while cut-away hides its children (`main_build_walk.gd:423`). Seven catalogue-tagged European case pieces never enter either registry because they have no picture; six clicks pick nothing, the Turkish woman picks plate `09.351`. A visibly exposed Grey landscape clicked from Marble also picks nothing. The chandelier fails the standard pass. Reproduce with `hidden.gd`, `registry_probe.gd`, `cross_room.gd`; rotate Rockefeller π/2 and click the gone wallpaper. Fixed: only effectively drawn works answer; every expected display has a usable selection/view; visible reachable works through doors can be selected. [Hidden log](hidden-console.log:2117), [seven omitted pieces](registry/report.json), [cross-room picture](cross-room/candidate-05.png).

2. **blocks done — Successful inspections can hide the selected work.** The harness accepts Christ `69.196` with half the relief covered by Anthony's backing; Commode `2017.46` with the entire commode absent; Plate `35.703` with the camera looking at the tabernacle. Other case inspections show untextured backs/edges. Modern `1995.043` inspection removes the visitor; the code permits this at lines 1138–1140. Projected bounds do not prove visibility. Reproduce by clicking these works or running the object pass. Fixed: the whole selected work/frame faces the camera, unobstructed, with the visitor beside it. [Christ](playtest/object-69.196-46.png), [absent commode](playtest/object-2017.46-127.png), [wrong plate view](playtest/object-35.703-138.png), [absent visitor](checklist/modern-inspection.png).

3. **blocks done — View glides put walls/ceilings across the lens.** `temporal.gd` records 1,680 samples at 30 game frames/s: 36 sequences in Hall, medieval, Renaissance and modern. Maximum consecutive displacement: **1.107049 m**; per-room maxima H .759909, M 1.043102, R 1.079220, O 1.107049 m. Door sequences peak at .100 m. There are no detected camera-origin intersections with the approximate visitor box or recorded wall AABBs, but wall-filled frames occur at Renaissance mode-2 frame 20 and modern mode-2 frames 0/18/20; medieval mode-2 shows the ceiling; Hall inspection return frame 26 shows wall/vent. Cut-away is computed before final camera interpolation at line 1227. Reproduce: switch modes at room centre, or close Hall inspection. Fixed: visibility follows the actual interpolated camera, keeping the lens clear throughout. [Renaissance sequence](temporal/renaissance-mode-2-sheet.jpg), [modern sequence](temporal/modern-mode-2-sheet.jpg), [complete metrics](temporal/summary.json).

4. **blocks done — Room, door and artwork measurements remain wrong.** All 23 Hall canvases/heights were measured; 22 were independently matched to actual meshes. **21 hanging centres differ by more than 10 cm**. W2 centre 1.50 versus 1.90 m; W6 bottom 1.20 versus .82 m and height 3.31 versus 3.46 m; W7 height 1.222 versus 1.111 m. Hall length 26.3 versus 21.9±.5 m. Medieval east doorway centre 3.665 versus 2.60 m; west 3.665 versus 3.04 m. European east placements stretch by 26.3/21.2: Crucifix +1.802 m, Reynolds +3.245 m from the south. Modern length 5.8 versus 7.3 m. Reproduce: `dump_scene.gd` and compare the cited audits/frames. Fixed: apply measurements within their uncertainty, or record why a particular target cannot be determined. [23 works](measurements/size-comparison.md), [actual meshes](measurements/hall-live-meshes.json), [every room and defined opening](measurements/architecture.md).

5. **blocks done — Observed architecture/displays remain missing or provisional.** At least six European north-shelf contents and the flat inlay board are missing. Skylight's piano/five works exist, but the filmed stair/void/upper and lower landings become one floor. Marble upper floor and lower service continuation cannot be walked or are absent. Lion chair rack/directory remain absent. Empty threshold studies omit observed displays/windows and place bars on flat walls without door leaves. Rockefeller wallpaper hangs .55 m high; chairs are approximately .604 versus .82 m wide. Several furniture/sculpture representations remain boxes/photo slabs. Reproduce: walk the loop and compare the four wall pairs per area. Fixed: complete the observed displays/structure; use a finished explicitly closed threshold where the issue permits closure, without inventing unfilmed topology. [Wall-by-wall display/fixture ledger](wall-ledger.md), [Skylight levels](comparisons/skylight-gallery.jpg), [threshold bars](geometry/white-sculpture-gallery-threshold-study-limit-corner-2.jpg).

6. **blocks done — Seven galleries still make the floor the brightest large area.** Rockefeller, European, Renaissance, medieval, Grey, Skylight and modern fail this criterion in the pictures and sampled means below. The relit Hall has work brightness 101.6 versus floor 53.9. Nine of 23 Hall card samples exceed R/B 1.25; medieval three of six, Renaissance seven of fifteen. Modern has no label cards. Cut-away/inspection can leave work-shaped dark patches: absent commode leaves a large black wall patch; modern turns leave a hidden-work patch. Reproduce: `walls.gd`, `lighting.py`, then rotate Modern or inspect Commode. Fixed: exhibit-focused pools, cream labels and no retained shadows from hidden works. [Annotated Rockefeller](lighting/rockefeller-south-0.jpg), [modern turn](temporal/modern-turn-Q-sheet.jpg), [commode patch](playtest/object-2017.46-127.png).

7. **should fix — The emblem-book panel clips below the viewport.** Its three-line title and two-line maker grow past the fixed-position panel; the accession is cut off. Reproduce: inspect `2023.17` in Renaissance at 960×640. Fixed: the complete first page stays on screen at supported sizes. [Picture](playtest/object-2023.17-32.png). Relevant code: lines 578–590.

8. **should fix — Controls resume before camera return; Other wall does nothing outside Hall.** Closing then holding D moves .09 m while `_inspect_t=.470508`; inspection state clears before the .75 s return finishes. The visible Other wall button walks 2.56 m in Hall, zero in medieval/Renaissance/modern, because `walk4.gd:2435` accepts only the Hall space. Reproduce with `targeted.gd` and `residual.gd`, or press those controls. Fixed: resume control after camera settling; make the button perform a room-valid action or show its unavailable state. [Return record](targeted/report.json), [button records](residual/report.json).

9. **should fix — A first inspection click still plays two cues.** Actual mixed native audio records `select` then `item_select` from one press; the longer capture has them at 48.268 and 51.051 s. The independent Compatibility capture confirms the duplicate. True second-click zoom now plays one `menu_open`, closing one `menu_close`. The longer recording has 41 foot contacts with a live footstep stream and nonzero audio within ±120 ms, grounded lowest soles, and no airborne jump foot contacts. Reproduce: `audio.gd` or `audio_zoom.gd` without fixed FPS. Fixed: one short cue per press; approach completion adds no second selection cue. [Mixed audio analysis](audio/analysis.md), [true zoom analysis](audio-zoom/analysis.md), [recording](audio/native.flac).

10. **should fix — Bench seating/rest is absent.** There is no sit/interact input path in the changed runtime; tested benches only block walking. Reproduce: approach/click benches or try Enter/Space. Fixed: a usable sitting action, animation and composed rest shot. [Modern bench](checklist/modern-3m-wall.png), [Renaissance bench](checklist/renaissance-3m-wall.png).

The wall ledger rechecks older inventory claims rather than adopting them. Crucifix, Rockefeller pair/prints/textile, Rodin, European hanging/cases, Skylight piano/artworks and marble hall now have representations. Fresh medieval frame `000026` shows one grille and its shadow, not an established missing second panel. New defects include unregistered pieces, back/absent inspections, chandelier selection, flattened levels, shifted openings, title overflow and mixed-audio duplication.

Brightness below is sampled 8-bit sRGB luminance, not physical illumination. Surface colours and projected occlusion affect it. [Annotated locations, raw counts and 87 candidate card ratios](lighting/analysis.md); [per-card RGB/R/B](lighting/labels.json). Some card projections are occluded and cannot certify label colour. Marble's wall/work projections are unreliable and are marked unknown. A dash means no displayed work exists in that area.

|Area|Floor|Wall beside works|Work/display|
|---|---:|---:|---:|
|Grand Gallery|53.9|16.6|101.6|
|Rockefeller|192.4|172.3|136.2|
|adjacent gallery|179.1|162.9|141.0|
|light Renaissance room|139.5|125.1|90.9|
|dark medieval room|135.1|84.4|123.3|
|lion stair landing|130.1|120.6|148.8|
|purple elevator-5 connector|156.2|103.5|—|
|grey French gallery|198.9|102.8|100.4|
|marble stair hall|169.6|unknown|unknown|
|Skylight Gallery|216.0|177.1|198.7|
|modern painting gallery|181.0|166.0|88.8|
|white sculpture gallery threshold study limit|109.4|132.1|—|
|modern adjoining gallery threshold study limit|107.6|140.3|—|
|Grand Gallery reveal threshold|171.7|85.0|—|
|Rockefeller reveal threshold|164.8|99.5|—|
|Skylight Gallery reveal threshold|199.2|141.7|—|

The checklist follows. H=Hall, M=medieval, R=Renaissance, O=modern. Picture keys: [H](sheets/checklist-hall.jpg), [M](sheets/checklist-medieval.jpg), [R](sheets/checklist-renaissance.jpg), [O](sheets/checklist-modern.jpg). Each sheet has standard, wall, inspection and page pictures. These are native 960×640 results; matching web certification is outstanding. **No† means not demonstrated, not a proven defect.**

|#|Finish criterion|H|M|R|O|Picture / measured evidence|
|---|---|---|---|---|---|
|1|Whole wall frames at 3 m|No|Yes|No|No|H/M/R/O wall views; tall hangs crop|
|2|Tall-work camera includes frame and label|No|No|No|No|H/M/R/O near-wall views; fixed tilt|
|3|Visitor 1/5–1/3 of picture height|No|No|No|Yes|Matched visitor masks: .3625/.3703/.3719/.3281|
|4|Every view change glides/wipes|Yes|Yes|Yes|Yes|36 temporal sheets; Hall Other wall walks|
|5|Near walls leave without flicker/visitor crossing|No|No|No|No|H return 26; M ceiling; R/O mode-2 walls|
|6|Art/nearby wall brightest large area|Yes|No|No|No|H/M/R/O wall views; means above|
|7|Individual pool; wall 1 frame-width away ≥2× darker|No†|No|No|No|Hall exact offset contrast unverified; M/R/O flat light|
|8|Floor darkens toward edges|Yes|No|No|No|H/M/R/O standard views|
|9|Lit labels cream, R/B ≤1.25|No|No|No|No|H 9/23, M 3/6, R 7/15 over; O lacks cards|
|10|Identifiable lit lamp for every pool|No|No|No|No|Room/ceiling views; heads do not look lit|
|11|Soft attached body-width visitor shadow|Yes|Yes|Yes|Yes|H/M/R/O wall and walk views|
|12|All furnishings have soft contact band|No†|No|No|No|Hall all bench faces unverified; M/R/O hard contacts|
|13|Soft moving highlight, no shimmer|No†|No†|No†|No†|Temporal pictures insufficient for this material criterion|
|14|Slow walk free of crawling 1-pixel stripes|No†|No†|No†|No†|Saved walk samples do not certify every slow-walk frame|
|15|Every work has a recognizable label|Yes|No|No|No|Room views; M/R missing groups, O no cards|
|16|Frame top lit, inner edge shaded|Yes|No|No|Yes|H/M/R/O inspection views|
|17|Every catalogue item answers with hand/tick|Yes|No|Yes|Yes|23/13/16/6 registered clicks; M catalogue coverage incomplete|
|18|Approach, stop, turn before inspection|Yes|Yes|Yes|Yes|Arrival logs / inspection pictures|
|19|.6–.9 s low glide; whole work and visitor|Yes|No|No|No|H shot; M covered Christ; R case compositions; O visitor absent|
|20|Whole title first; one page per click|Yes|Yes|No|Yes|H/M/R/O pages; R emblem-book overflow|
|21|Return <1 s; exactly one cue per press|No|No|No|No|.75 s return; first-click duplicate cue|
|22|Reading breathing/blinking continues|Yes|Yes|Yes|Yes|H/M/R/O shots plus alive-reading logs|
|23|Sit on bench; composed rest view|No|No|No|No|Bench pictures; no seating action|

The harness should gain these five implementable rules:

1. Read an expected footage display list independently of `_objects`; fail missing entries, unregistered catalogue nodes and unapplied measured room/door/hang corrections.
2. At four headings, validate effective drawn geometry/occlusion before accepting a pick. Reject hidden hits, wrong case works and blank backs; test visible cross-room works/chandelier. Assert work/frame and visitor pixels in the actual inspection, not just projected bounds.
3. Record 30 game frames/s through Q/E, all modes, Other wall, doors and inspection in/out. Fail wall-filled frames and retained work-shaped patches; keep movement disabled until camera return settles.
4. In the matching browser, hold Shift through reading/zoom/tab/focus transitions, release while unfocused and return. Test Space at rest/moving/wall/door/reading and 15/30/60/120 Hz; assert one pose update per frame and no airborne footsteps.
5. Record actual mixed audio: one cue per press, footsteps at ground contacts. Measure visible floor/wall/work and card colour masks; add bench sit/rest/return and long-title/resize checks.

What remains unverified: a matching-checkout browser whole-loop with sound. The supplied URL loads `5e85b55e.html`; that filename was not mapped conclusively to tested HEAD. A Collection browser screenshot was opened, not accepted as matching certification. Real OS/browser focus and tab modifier handoff remain unverified; a synthetic notification leaves globally held Input and cannot prove a real focus bug. Continuous films are 30 game frames/s fixed simulation, not a browser performance benchmark. The long audio capture used slow native Vulkan/llvmpipe; true zoom used Compatibility/NVIDIA D3D12. Exact one-frame-width pool contrast, moving floor highlights, every slow-walk shimmer frame, every lit-card colour and concealed geometry faces remain unverified. Unknown room/door targets and unfilmed threshold walls are explicitly unknown. Close survey cameras can be inside displays; their black pixels are not accepted as game holes. No additional static gap/z-fight is claimed from those blocked views. `gdlint` is unavailable.

All controlled artifacts are under `build/review-round-2/`: runnable scripts, PNG/JPEG proof, 36 MP4 sequences, two FLAC recordings, JSON measurements/logs and this report. [Integrity and exact byte count](integrity.json). No tracked files or Git state changed; no paid calls. Review Godot/browser processes stopped.
