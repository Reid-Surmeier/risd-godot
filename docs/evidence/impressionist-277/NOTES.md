# Impressionist galleries — issue #277

Branch `feat/impressionist-277`; source baseline `ecfda16e`. Work alone, source changes only; the orchestrator bakes and installs. No paid services or new artwork downloads. Reference: ordinary SDR `~/risd-godot-ingestion/walkthrough/IMG_6343.MOV`. Times below are seconds in that clip. Survey checkpoint before geometry changes. Measurements are estimates with explicit uncertainty; none is an accepted calibrated survey.

## 1. Footage, dimensions and finishes

Coordinates name the **fitted build plan**, not geographic compass directions. Look south from A's entrance towards Le Repos: windows east (screen left), three Monets west (screen right), Manet south, two portraits/sketches north. Distances along west/east walls start at the north corner; along north/south walls start at the west corner. Hanging heights are canvas centres above the floor. See `WORKS-NEEDED.md` for the complete 17-work inventory and bare positions.

| Element | Estimate and error | Frame / scale |
| --- | --- | --- |
| Stair entry | 1.1 ± .15 m clear; head about 2.5 ± .2 m; white folded panelled leaves | 86, 88, 89.5; A door / adult cross-check |
| Passage | 1.8 ± .25 m wide, 2.0 ± .4 m long, 3.2 ± .25 m high | 89.5, 91; door in same image; depth weakly constrained |
| Passage service leaf | left wall, near A end; .85 ± .10 m wide × 2.5 ± .2 m; closed six-panel white door | 89.5; A opening scale |
| Passage floor | grey stone at stair sill for about .6 ± .2 m; warm straight oak beyond | 89.5; door width |
| Passage walls | warm grey, white baseboard; grille low right and high left; panelled lining at both ends | 89.5 |
| A width | **6.25 ± .60 m** | 147; rectified end wall, Le Repos canvas 1.140 × 1.502 m |
| A depth | **9.6 ± 1.5 m**, inferred | 94, 143, 147; canvas angular width and assumed 50–60° portrait horizontal field of view; optics uncalibrated |
| A height | **3.69 ± .35 m** | 147; same-plane ceiling/floor corners and Manet |
| A entry | north wall, centre about 5.30 ± .45 m from west corner; 1.4 ± .2 m clear; head about2.7 ± .3 m, inferred | 141, 147; door/Manet scale, position weaker than end wall |
| A → B door | south wall, centre .95 ± .20 m from east corner; 1.04 ± .15 m clear, head **2.47 ± .20 m** | 147; Manet-plane homography; floor inside B is behind plane, so use A end-wall floor line |
| A finishes | cool grey painted walls; white skirting/casings/cornice; honey oak straight boards across the room; pale flat ceiling | 98, 121, 145, 147 |
| A window 1 | east wall, centre 3.0 ± .6 m from north; outer width 1.6 ± .2 m, sill .55 ± .12 m, head 3.15 ± .25 m | 143, 149; Degas canvas .464 × .629 m |
| A window 2 | east wall, centre 7.6 ± .8 m from north; same size ± .2 m | 143, 147, 151; same-plane Degas/door cross-check |
| A windows | white sash and deep inner lining; oatmeal solar shades descend to about .61 ± .10 m at the sill, with a brighter lower fabric field; panelled aprons with low horizontal grilles | 121, 143, 149, 151 |
| A case | grey **six-sided** plinth: 1.1 ± .2 m across × .95 ± .12 m high; stepped foot, bevelled pale deck; rectangular clear hood about .85 × .65 × .90 m (± .15 m) | 145, 147, 152; Degas bronze catalogue height .422 m / Manet; hood dimensions inferred |
| A furniture | no bench seen in the full pan | 91–154 |
| B width/depth | **6.3 ± .7 m × 8.8 ± 1.8 m**, inferred | 178, 214, 216; Monet 44.541 canvas .927 × .648 m, doors; extent partly out of frame, uncalibrated optics |
| B height | **3.5 ± .35 m** | 214, 225; existing tall cased door and catalogue canvas |
| B modern exit | south wall near east window, centre about .65 ± .2 m from east corner; 1.3 ± .15 m clear, head 2.7 ± .2 m | 216, 225, 226; same plane as jamb / window |
| B window 1 | east wall, centre about 4.98 ± .8 m from north; width 1.55 ± .2 m; sill .55 ± .12 m, head 3.1 ± .25 m | 216, 218, 220; Cassatt .521 × .610 m |
| B window 2 | east wall, centre about 8.44 ± 1.0 m in the fitted room; same size ± .2 m | 216, 218, 225; modern door; offset fitted rather than independently surveyed |
| B furniture/finishes | one low charcoal tufted bench near centre, about 1.8 × .75 × .45 m (± .2/.12/.08 m); oak boards, cool grey walls, white trim and ceiling | 214, 216; canvas / floor cross-check; length partly out of frame |

`plane-measurement.json` retains A's manually picked canvas corners, homography and wall coordinates. The earlier 5.5 × 7 m estimate was superseded by this scale fit. The doorway sill visible behind A's opening is not on the end-wall plane: treating it as such would incorrectly give a 2.21 m door. The corrected head uses the wall/floor junction and is 2.47 m.

### Lamps for #274 (record only)

A: 147 shows two inset rectangular dark track runs, long sides parallel to the room; nearest loop about .7 m off the walls, a second run inside it. Small white heads aim at each west-wall canvas, Le Repos and Degas; the case has its own bright pool. Window daylight makes a cool pool on the east floor and warm lamps make overlapping broad pools at paintings. A high rectangular ventilation grille is on the west wall near the south end; a small ceiling detector sits near the central track. B: 214 shows a high long wall grille above Monet 44.541, wall-directed heads and a warm oval pool under each picture; 226 shows the modern room's rectangular track beyond the exit. No lamp or track code is in this ticket.

## 2. Fixed ends, closure and fitted plan

Room-scene metres; Hall-local = room-scene + (-5.55, 0, -28.10). Existing marble hall bounds x 11.05–19.45, z -4.96–1.04. Its internal east wall is x **17.85**, door centre z **-1.96**. Existing modern far door: north plane z **22.30**, clear x **15.10–16.40**, centre x **15.75**. Endpoint displacement **(-2.10, +24.26)**, length **24.35 m**. These endpoints and every other room stay fixed.

The footage does **not** establish a calibrated global camera pose. Adding the estimated passage/A/B depths gives 2.0 + 9.6 + 8.8 = **20.4 ± 2.4 m**, against **24.26 m** longitudinal separation in the build: **3.86 m more length is required**. The east-facing stair opening also has to return towards the south-facing modern doorway. The fit therefore uses an elbow outside the stair hall, rather than claiming the filmed short straight passage closes the existing plan.

| New area | Fitted bounds [x0, x1, z0, z1] | Height | Openings |
| --- | --- | --- | --- |
| Impressionist passage | [19.45, 21.45, -2.86, 1.04] | 3.2 | west z[-2.51,-1.41]; south x[19.75,21.15] |
| Impressionist passage return | [14.75, 21.45, 1.04, 3.04] | 3.2 | north x[19.75,21.15]; south x[15.10,16.40] |
| Impressionist gallery A | [10.55, 16.70, 3.04, 12.70] | 3.69 | north x[15.10,16.40]; south x[15.20,16.30] |
| Impressionist gallery B | [10.55, 16.70, 12.70, 22.30] | 3.5 | north x[15.20,16.30]; south x[15.10,16.40] |

A's depth is stretched **.06 m**, B's **.80 m**, and the passage adds **3.00 m** of southward travel (5.00 m from stair centre to A entry instead of the 2.00 m filmed estimate). This totals the required **3.86 m** longitudinal fit. Both gallery widths are **6.15 m**, .10/.15 m narrower than the estimates. The passage return also adds **4.70 m of lateral travel** between x20.45 and x15.75; that return is a build fit, **not observed in the clip**. No existing adjoining room moves. The under-stair internal leg x17.85–19.45 is already inside the hall and has its obstruction opened.

The first draft exposed a mirror error: looking towards +z, screen left is world **east**, and the filmed windows and end door are both on that side. The fit was corrected before the shell checkpoint. A/B now lie west of the passage and have east-side doors and windows; this preserves the filmed relationship and reduces gallery-depth distortion. The four new rectangles do not overlap any existing room. Their opening intervals match pairwise, including the retained modern far door. Source assertions and draft route samples check closure in the build. The passage return, room depths and wall offsets remain **INFERRED**; the exact physical museum plan is **not accepted**.

## 3. Census checklist

- Marble stair hall §8 finding 4: replace the lift-like closed exit with the open doorway, folded leaves and traversable passage.
- Modern adjoining stub §15 findings 1–2: replace the closet and its blank end wall with gallery B, oak, grey walls, shaded sash windows and real door to modern gallery.
- §15 finding 3: new openings use the shared white trim kit; no custom casing/skirting/cornice code or `DEEP_REVEALS` edits.
- Track locations and pools are recorded in§8 for #274. Lamps are outside this ticket's edits.

## 4. Planned source edits and gates

`prepare_remodel.py`: named room entries, openings, floor patches and reciprocal route trials. `impressionist_additions.gd`: room-specific walls/finishes, window assemblies, benches, hexagonal case and approved existing artwork. `remodel_room.gd`: add one name to `ADDITIONS` only if sufficient. `marble_hall_additions.gd`: smallest edit to remove the closed exit obstruction. `main_build_walk.gd`: replace stub name/stage and add required room and connector names. Authored `objects.json` and `representation.json` only for works actually hung; no generated room assets committed. No frozen interfaces, character, gallery_walk4 or playtest edits.

At every push: `scripts/check.sh` must report `checks passed`, `git diff --check`, a `--draft` rebuild with a successful `ARCHITECTURE_CHECK`. Baked doors playtest is deferred to the orchestrator; all added door planes and trial coordinates will be listed here. The baseline and subsequent results are recorded below. The required full-check success remains blocked by the older installed scenes; no green full-check claim is made.

## 5. Baseline gate defect (before source edits)

The initial import completed. `scripts/check.sh` now gets through import but `REPRESENTATION_CHECK` fails on **37.114, 20.254, 59.131**: each is declared a mesh but the shipped generated room scene still places the previous photograph slab. The authored `medieval_additions.gd` already places the new GLBs; the generated copy/bake is older. This is unrelated to #277. No generated files or medieval source/records were changed to suppress it. Pushes were initially held and a scoped exception was requested in chat. No answer arrived; the source-only handoff subsequently proceeded under the task's explicit push authorization, as §9 explains. The source draft subsequently passed `ARCHITECTURE_CHECK` with 28 cased door sides. The final official source rebuild completed at about18:49 UTC with `ARCHITECTURE_CHECK failures=[]`, 28 cased door sides, and source tip `a4132e1e`.

## 6. Survey picture index

`survey-0.jpg`: stair entry/passage and first A wall group (84–115 s). `survey-1.jpg`: A Manet, windows, small works and full end-wall relationship (121–176 s). `survey-2.jpg`: B paintings and modern exit (180–228 s). These are reference-only JPEGs, each below 150 KB. Additional detail/paired draft photographs will be added at the geometry and furnishing checkpoints. All 17 works are listed in `WORKS-NEEDED.md`; 42.219, 1998.107, 41.012 and 44.541 are approved existing images. Cézanne was found under its title rather than its accession; the extra two Monets were found by a full tracked-file search in the older coverflow prototype.

`fitted-plan.jpg` diagrams the room bounds and fixed-end fit (final door intervals are in§7/12); this is a notes diagram, never a game texture. `draft_capture.gd` is a review-only capture script for the draft and samples the added route using the game adapter's actual `_free()` rule. It is not an acceptance-test edit.

## 7. Shell checkpoint (source changes, 8 Oct)

The first preliminary (mirrored) draft command completed in the one `rebuild-impressionist-277` folder: **ARCHITECTURE_CHECK failures=[]**, 26 cased door sides. Its layout was corrected as §2 records; the corrected draft subsequently completed with **ARCHITECTURE_CHECK failures=[]**, **28 cased door sides**, at about 18:03 UTC. The walking adapter sampled **40 reciprocal trials** (38 new, 2 retained) at 41 points per leg: **zero failures**. `2-shell-stair.jpg`, `2-shell-A.jpg` and `2-shell-modern.jpg` show the corrected plain shell beside the source frames. **VERIFIED in those draft pictures:** open stair doorway, A/B end-door relationships, continuous floors, grey walls, white kit trim and flat ceilings. Dimensions and the extra passage return remain **INFERRED**. Full `scripts/check.sh` still fails only on the three baseline medieval mesh declarations in §5; `git diff --check` is clean. `python3 -m py_compile prepare_remodel.py` passes. No generated room files are edited or staged. The scoped exception request received no answer; subsequent source pushes are explained in§9, with the failed installed-scene check reported explicitly.

### Edits outside `impressionist_additions.gd`

1. `prepare_remodel.py`: replace only room index12's modern stub with B; add separate passage/return/A entries; add the marble hall's outer east opening and its head height; keep every old bounds/door fixed; append fit metadata, shared-opening assertions and route trials. The existing floor-patch loop includes the new areas. No other room entry is moved.
2. `remodel_room.gd`: one `ADDITIONS` list entry, after the marble hall. No lamp, casing, deep reveal, skirting or cornice implementation is changed.
3. `main_build_walk.gd`: add four names to `FAR_ROOMS`; replace the obsolete modern-stub join with both passage areas directly joined to A in `JOINED`. A and B get distinct stages from the existing automatic stage builder. Room names/doorways otherwise come from `geometry.json`; there are no literal Renaissance-room registrations to copy in this adapter.
4. `marble_hall_additions.gd`, `inner_walls()` only: replace the single closed exit wall/leaf batch with two piers and a header; call the existing shared casing kit; retain the existing EXIT sign/text, raised from2.55m to the existing landing fascia centre at2.775m so it clears the taller casing. Cut the old continuous base at that opening (no profile change). Split the invisible obstruction behind the landing into north/south blocks to admit only the passage. Flights, other doors, lamps and cornice are untouched.

### Door planes for the orchestrator's baked `--only=doors` check

| Door | Plane | Clear interval | Head height | Change |
| --- | --- | --- | --- | --- |
| stair hall internal exit | x17.85 | z[-2.51,-1.41] | 2.47 | closed double leaf / solid wall removed |
| stair hall outer east ↔ passage west | x19.45 | z[-2.51,-1.41] | 2.47 | new paired opening |
| passage south ↔ return north | z1.04 | x[19.75,21.15] | 2.74 | new paired opening |
| return south ↔ A north | z3.04 | x[15.10,16.40] | 2.74 | new paired opening |
| A south ↔ B north | z12.70 | x[15.20,16.30] | 2.47 | new paired opening |
| B south ↔ modern north | z22.30 | x[15.10,16.40] | 2.74 | modern opening retained, stub replaced by B |

New reciprocal doorway trials (x,z, room-scene metres): `impressionist_stair_inner` (16.85,-1.96) ↔ (19.05,-1.96); `impressionist_stair_outer` (19.05,-1.96) ↔ (20.45,-1.96); `impressionist_passage_return` (20.45,.40) ↔ (20.45,1.80); `impressionist_return_A` (15.75,2.25) ↔ (15.75,3.85); `impressionist_A_B` (15.75,11.85) ↔ (15.75,13.55). Each has `_out` and `_back`.

The **28** `impressionist_route_00..13_out/back` trials follow:
`(20.45,-1.96) → (20.45,.40) → (20.45,2.04) → (18.25,2.04) → (15.75,2.04) → (15.75,3.85) → (14.85,6.20) → (14.85,9.20) → (15.75,11.85) → (15.75,13.55) → (13.25,15.70) → (13.25,18.70) → (13.25,20.65) → (15.75,21.45) → (15.75,23.25)`, each segment ≤3.5 m. The existing `modern_far_opening_out/back` retain their coordinates (15.75,23.25) ↔ (15.75,21.45). **38 added trials; no pre-existing trial moved**. Baked playtest has not been run on a draft.

Close draft photographs use the room draft's .55 ambient fill and show adjacent rooms for geometry review. Game photographs retain the actual walking adapter's zero far-room ambient and its stage masking. The adapter expects a bake; a black ceiling in that unbaked game view is not proof of missing ceiling geometry. No runtime light setting is changed by the capture script.

The private draft capture copies tracked `modules/shell/character/` files, the two existing tab-close icons and the two authored catalogue records into the draft unchanged, then imports it. This only supplies dependencies omitted by the room-only draft; none of those character/tab files is edited or committed.

## 8. Furnishing checkpoint and lamp handoff (8 Oct)

The room-specific source now adds four east-wall window recesses, with white kit surrounds, sash/meeting rails, oatmeal roller shades, painted panelled aprons and built metal grilles. A centres are z6.04/10.64; B z17.68/21.14, all at x16.70, sill .55, glass head 3.10 m. Outside scenery is not invented or photographed. The exterior wall collision remains closed. High vents: A west along8.70/y3.28; B south along3.15/y3.12. Passage low grille and six-panel service leaf are relocated to the fitted return; this side-wall arrangement is inferred, not an exact copy of the short filmed passage.

A: one grey six-sided stepped plinth at (14.10,0,10.55), pale bevelled deck y.95 and transparent rectangular hood to y1.85. It is empty: 23.315 is listed for the orchestrator and is not registered as a displayed object. B: one 1.80 × .75 × .45 m charcoal bench at (12.0,0,17.70), rounded upholstered rim, eight real button depressions, dark rails and four slender legs. Existing Main Hall cloth is reused; no new generated texture. No A bench is invented. Ceiling material is plain pale plaster; no facet texture. The stone band over the fitted under-stair leg is .008 m thick, not a raised plinth.

### #274 placement notes (no lamp code)

All coordinates below are **INFERRED fits** of the observed tracks/pools, not a calibrated lamp survey:

| Area | Track / pool locations in fitted room-scene metres | Evidence |
| --- | --- | --- |
| A | outer inset rectangle approximately x[11.3,15.95], z[3.8,11.95], y3.64; inner runs approximately x[12.3,14.95], z[4.8,10.8] | 143/147: two dark inset rectangular runs; small white adjustable heads |
| A picture pools | west canvas centres (10.55,1.65,5.49/8.44/11.09); south Manet (12.80,1.59,12.70); east Degas (16.70,1.64,8.24) and Cézanne (16.70,1.62,4.39) | 98–149: broad warm pools around each gilt frame |
| A case | separate warm pool on the case at x14.10/z10.55, object level around y1.15 | 145/147/152 |
| A daylight | cool floor patches inside the east windows, around z6.04 and10.64, spread about 1.5 m into the room | 143/149/151 |
| B | outer runs roughly .7 m inside the room; y3.45. Warm painting pools on both long walls and south end, especially Monet 44.541 | 214/216; full track layout not surveyed |
| B daylight | cool floor patches inside east windows z17.68/21.14 | 216/218/225 |

A has a small ceiling detector visible in147; its round built form is included, with an inferred fitted position. B's full ceiling equipment was not recorded. Neither gallery has source-authored lamps here, and their finished baked brightness/pools are not verified.

### Furnishing draft evidence

**VERIFIED by looking at `3-furnish-*.jpg`:** the folded panelled leaves at the stair exit/A entry, service leaf and grilles; two shaded sash windows in each gallery; smooth grey plaster, white kit trims, crosswise oak and flat pale ceiling; A's six-sided stepped plinth/clear case; B's rounded upholstered bench on four legs; the continuous B–modern door and blank name-plate form. Existing modern-gallery Venetian blinds visible through that door are outside #277 and differ from its source roller shades.

**INFERRED:** the absolute furnishing offsets, passage service-wall placement, window recess depth, bench dimensions/button arrangement, detector position and borrowed kit profile fidelity. Finished lighting is unverified. `3-furnish-bench.jpg` deliberately shows the limited bench evidence (corner/leg at214s); no complete bench elevation is claimed.

Native draft capture after the final room-owned detail changes reported **40 trials, zero route failures**, and no `ERROR` / `SCRIPT ERROR`. The unchanged architecture checker reported **28 cased door sides, failures=[]**. The final official rebuild subsequently passed with28, as recorded below; the earlier official furnishing draft also passed with28. The full repository `scripts/check.sh` still exits1 on only the baseline three stale mesh declarations in§5; image/record checks pass. `git diff --check` is clean. Colliding bench/case proxies have an empty visual mesh, so revealing children for a cutaway cannot display a box over the built shape.

Room-owned additions call the kit for trims/leaf beads and reuse existing cloth; no shared lamp, casing, skirting, cornice or reveal implementation changed at this checkpoint. A detector is geometry, not a lamp. Native close photographs use the review fill described in§7; brightness is not a baked-lighting acceptance claim.

## 9. Existing artwork checkpoint (four works, 8 Oct)

Four already-tracked museum photographs are used: A west42.219 at along2.45/y1.65 and1998.107 at along8.05/y1.65; A east41.012 at along1.35/y1.62; B south44.541 at along3.15/y1.65. Canvas sizes are respectively .743×.552, .648×.533, .397×.232 and .927×.648 m, from the linked primary records. Three source JPEGs come from `prototypes/painting-coverflow/web/assets/`; Cézanne comes from the existing `inventory-catalogue/` photo. Every source byte is unchanged. Existing carved gilt E7/plain gilt W10 frames are fitted to approximately1.016×.807, .912×.780, .576×.399 and1.135×.843 m; ornament fidelity is provisional. Blank card shapes go to the viewer's right. The other12 paintings have bare wall positions; the dancer's case is empty.

Additional edits outside the additions file: a separate six-line image-copy block in `prepare_remodel.py`; exactly four new authored rows each in `objects.json` and `representation.json` (no old declaration or shortfall changed); append the four source/provider/hash/cost records to `modules/shell/PROVENANCE.md`. Evidence/capture files are review-only. No generated rooms, images or import settings are committed.

The unchanged representation checker on the source draft reported **181 built, 181 declared, failures=[]**. Its15 pre-existing unregistered works are unchanged and outside #277. The unchanged architecture checker still reports **28 casings, failures=[]**. The native capture completed without errors; all40 route trials remain clear. `4-work-Basin.jpg`, `4-work-Monet.jpg`, `4-work-Cezanne.jpg`, `4-work-Giverny.jpg` and `4-room-A.jpg` show the four actual photographs hung in the draft beside source footage. **VERIFIED:** all four images/frames appear, with bare spaces for the remaining works. **INFERRED:** wall offsets, borrowed ornament fidelity and final baked brightness. The official final draft completed with `ARCHITECTURE_CHECK failures=[]` and28 cased door sides at about18:49 UTC, source tip `a4132e1e`.

### Source handoff and the incompatible installed-scene check

The measurement, connected shell, furnishing and four-artwork checkpoints were pushed in order to `feat/impressionist-277`: `b22e8224`, `32d7bb4f`, `39c29318`, `a4132e1e`. Each source checkpoint has successful draft architecture output and `git diff --check`; shell/furnishing also have native photographs and reciprocal route sampling. **The full repository check did not report `checks passed`**: the generated installed scene is older than the source, as §5 records. At the four-artwork checkpoint it additionally lacks42.219,1998.107,41.012,44.541; these are source-draft-verified and await the orchestrator's installation, rather than a new art defect.

The chat's scoped exception request received no answer. The push handoff proceeds under the task's explicit authorization to push source-only work: making the installed-scene check agree would require producing/installing generated rooms, which this ticket explicitly reserves for the orchestrator. No assertion or declaration was weakened to hide a failure, no bake/install was run, and no green full-check claim is made. The unchanged source-draft representation check is clear (181/181). The orchestrator must run full `scripts/check.sh` and the baked `museum_playtest.gd --only=doors` after installing the merged bake.

Native UV2 preparation sanity check: all409 opaque surfaces under the new rooms/furniture/leaves/artwork unwrap at the pipeline's .14 m texel setting with **zero unwrap failures**. This copied the unwrap operation into an in-memory scratch check; it saved no scene/atlas and ran no lightmap bake. Empty collider-proxy visuals and transparent hood panes are excluded by the existing `remodel_bake.gd` logic. The bake itself and Web-door acceptance remain the orchestrator's checks.

The same source-preparation review also found **no duplicate mesh names involving an Impressionist-owned surface**, so the unchanged bake loader’s name-based bindings remain unique. The existing room assembler assigns its bake-source names after additions are built; no new naming mechanism was added.

## 10. Four-artwork official rebuild (8 Oct, 18:49 UTC)

The requested `ROOMS_TRIAL=…/rebuild-impressionist-277 timeout40m scripts/rebuild_rooms.sh --draft` completed with exit0, source tip `a4132e1e`, **ARCHITECTURE_CHECK failures=[]**, **28 cased door sides**, **19 total plan areas** (four Impressionist areas, one replacing the old stub) and **38 Impressionist route trials**. No bake/install ran. The prepared `impressionist_additions.gd` matches the pushed source byte-for-byte; all four output JPEGs match their tracked source bytes. The one draft folder is retained for the orchestrator, with unchanged capture dependencies re-added for final pictures/checks.

`5-final-passage-panels.jpg` adds a clearer view of the service leaf, folded leaves and low grille. `index.html` is a static review gallery of the evidence only, with no runtime dependency. The temporary share is scoped to this gallery; GitHub keeps the committed pictures for later review.

## 11. Window refinement

The first furnishing pictures exposed four lower divided panes. A closer comparison of149/151/218 identifies the bottom shade hem near the sill: the brighter blue lower region is daylight through a lowered solar shade, not evidence of an exposed four-pane grid. The final source replaces that grid with one full-height, plain translucent fabric sheet (1.46×2.43m), its roller and sill-height hem at.61m. The hidden sash construction remains inferred. This uses the existing plain `look()` alpha material; no photograph, new texture or shader is added. Only `impressionist_additions.gd` changes runtime geometry at this refinement.

The earlier `3-furnish-*` and `4-*` pictures retain their checkpoint appearance. `5-final-A-windows.jpg`, `5-final-B-windows.jpg` and `5-final-room-A.jpg` supersede their exposed-pane detail. The museum's exact optical transmission and final daylight colour/pools still await the lighting agent and bake.

The final corrected-shade official `--draft` completed at about19:08 UTC, source tip `a8e6091a`: **ARCHITECTURE_CHECK failures=[]**, **28 cased door sides**, **19 plan areas**. Its additions and four photographs match the committed source bytes. The updated native UV2 preparation check reports **397 opaque surfaces, zero failures and no duplicate owned names**, with no bake. Full `scripts/check.sh` was run again and exits1 only on the same seven installed-scene mismatches (three stale medieval placements plus the four new works); image checks report43 works/129 images/zero failures and record checks pass. `git diff --check` is clean.

## 12. Inter-gallery opening refinement

The same final comparison corrected A→B's clear width from the preliminary1.30m to **1.10m**, matching the measured **1.04±.15m** at147s. Its centre x15.75 and plane z12.70 are unchanged. Only A's south/B's north opening intervals in the #277 room block change, to **[15.20,16.30]**. The existing modern opening remains **[15.10,16.40]** atz22.30. No room, other door centre, floor patch or route trial moves. This distinction avoids treating the fixed modern door's width as a constraint on the new inter-gallery door. The earlier checkpoint pictures retain the preliminary wider opening.

The final service-leaf detail also calls the unchanged `door_casing()` kit for a.16m white surround around the closed.85×2.50m leaf, with a white kit-painted window apron field. Its high vent is at2.85m so it clears both the door casing and cornice. These are room-owned calls/material choices only; no kit implementation, opening or collision changes.

`stair-surround` exposed the retained EXIT sign overlapping the new taller casing. Only its existing sign/text positions in `marble_hall_additions.gd::inner_walls()` are raised to the existing landing fascia centre (`half-.125`, currently2.775m). No word, font, colour, lamp, stair or room geometry is changed. Its exact height is a fitted clearance, **INFERRED**;86s confirms the sign belongs above the casing.

Final-detail native checks: **ARCHITECTURE_CHECK failures=[]**, **29 cased sides**, now including the closed service leaf; **400 opaque surfaces** unwrap without failure or duplicate owned names; **40 reciprocal route trials** remain clear. `5-final-service.jpg` shows the service surround; `5-final-stair-surround.jpg` shows the raised retained sign with a gap above the open casing. The final A/B window and room-A pictures include white kit-painted apron fields and the narrower1.10m A–B opening. These are **VERIFIED in the native draft pictures**; exact fitted offsets/transmission remain **INFERRED**.

One interim capture was stopped after the rebuild had cleared its unchanged character/icon/record copies; restoring those44 tracked files fixed it. The review-only script now checks these dependencies before loading the walker. No character or tab asset was edited. The successful later native capture has no `ERROR`/`SCRIPT ERROR`.

`fitted_plan.py` regenerates the review diagram directly from the prepared geometry, including the final1.10m A–B gap. Provider/source/output hashes and USD0 cost are recorded in Shell provenance. No runtime asset or dependency is added.

The final official rebuild at source tip9b1e6e9f timed out at20:11 UTC **while waiting in `flock`**, before any preparation or architecture output (exit124). It did not alter the retained draft and is not an architecture failure. The same unpaid `--draft` command was requeued; its result is recorded below. Direct native source checks/pictures remain clear as above.


## 13. Final source handoff

The requeued official `scripts/rebuild_rooms.sh --draft` completed at **20:21 UTC**, source tip **9b1e6e9fa38ae136ce4f98b60f77c96a1b27e877**, and printed **ARCHITECTURE_CHECK failures=[]**, **29 cased sides**, then the draft-project path. The earlier timeout was host-lock waiting only. This rebuild prepared **19 plan areas** and **38 new route trials**; both additions and all four existing artwork photographs match source bytes. The prepared shared shell has only its pipeline's three expected substitutions (retained Hall surface naming and the separate bake resource paths).

The 44 unchanged capture dependencies were restored and imported successfully. The fresh native GL Compatibility capture completed with **40 reciprocal trials clear**, **zero route failures**, exit0 and no `ERROR`/`SCRIPT ERROR`. Source-draft representation again reports **181 built /181 declared, failures=[]**, exit0. The six `5-final-*.jpg` pictures are refreshed from this official final draft, with source footage at143/218/147/89.5/86s beside them. Their close views use the documented review-only.55 ambient fill; their game insets retain the actual zero unbaked far-room ambient. No lighting acceptance is claimed. Fresh in-memory UV2 preparation on this official final draft reports **400 opaque surfaces**, zero failures/duplicate owned names, exit0 and no bake.

The last full `scripts/check.sh` run exits1 on **exactly the same seven installed-scene mismatches**, and does **not** print `checks passed`: three unrelated stale medieval mesh placements plus the four new paintings absent from the old installed scene. Image and record checks pass; no gate or declaration was weakened. `git diff --check` is clean. Baked `museum_playtest.gd --only=doors` remains for the orchestrator after installation. Its six door planes and38 new/two retained trials are specified in§7; no old trial or door moves.

The measured artwork positions/window/door relationships and fitted dimensions retain the uncertainty in§1–2 and `WORKS-NEEDED.md`. Exact physical museum geometry, final daylight/track pools, borrowed frame ornament and incomplete bench elevation remain **INFERRED / unaccepted**. Twelve paintings and the bronze need approved assets; their positions remain bare/empty. The existing modern-room Venetian blinds, the marble hall's other census faults, and the stale generated medieval scene are outside #277. No merge, issue closure, bake, generated-room installation, paid request or copyright-hold image was made. The private draft is left for the orchestrator at the named extension path.

## 14. Twelve original catalogue photographs, image follow-up for #277 (8 October)

**VERIFIED in the final source draft:** five new paintings in A (Manet 42.190, Carolus-Duran 2007.68, Monet 57.236, Manet 59.027 on the end wall, Degas 23.072); seven in B (Pissarro 72.096, Gauguin 1999.3, Cézanne 33.053, Bracquemond 2021.101, Morisot 2010.57, van Gogh 35.770, Cassatt 60.095). The four previously hung works remain, giving 16 paintings. Every new work has its catalogue-sized canvas, built frame front/sides/reveal at the list's estimated moulding width, and a plain blank label card. No world text is added. This addresses the bare painting walls within census§8 finding 4 and§15 findings 1–3; it does not claim the other agents' architecture or lighting.

`6-gallery-A-catalogue-before-after.jpg` and `6-gallery-B-catalogue-before-after.jpg` show footage on the left, the populated unbaked GL Compatibility draft on the right. A covers north/west/south/east; B covers north/west/south and both east spans. The source never supplies a full B north-face view: that row is explicitly labelled and shows the shared doorway's opposite face at 154 s, not a claim of a filmed elevation. Close views use the existing review-only .55 ambient, not baked lighting. Native game inspection/full-zoom evidence is in `../impressionist-images/3-catalogue-59.027.jpg` and `4-catalogue-35.770.jpg`.

All twelve public photographs were fetched sequentially, with 2-second pauses, through the working Scrapling route documented by#180/#278. Ten use museum Micrio IIIF;59.027 and 35.770 use the museum catalogue's High-resolution JPEG download link. Every selected photograph was matched visually to its filmed painting. The van Gogh Micrio endpoint returned 404 once; the public catalogue download was used without retrying that missing endpoint. No missing photograph remains. Original downloaded bytes are outside git under `~/risd-godot-ingestion/catalogue-masters/impressionist-277/`. Only these twelve paintings were fetched. There is no video-frame art, upscaling, AI image generation or paid call.

Exact complete printed title/maker/date/medium/dimensions/credit fields, including nationality/life dates in the maker line, are checked against the saved museum pages. `image-work/collection-room-remodel/additions/impressionist/catalogue.json` and the twelve new `objects.json` rows hold those fields, source page/read date, source URL/size/hash, crop and derivative sizes/hashes. `../impressionist-images/catalogue-fields-checks.json` records the complete-field comparisons. Twelve flat/flat declarations are added to `representation.json`, with every old row and all 53 shortfalls unchanged. The existing image guard reads the new records without a code change.

| Accession | Source pixels | Wall pixels | Preview pixels | External zoom pixels |
| --- | --- | --- | --- | --- |
| 42.190 | 3535 × 2890 | 256 × 209 | 896 × 733 | 3535 × 2890 |
| 2007.68 | 2900 × 3505 | 212 × 256 | 741 × 896 | 2900 × 3505 |
| 57.236 | 4320 × 2821 | 384 × 251 | 896 × 585 | 4320 × 2821 |
| 59.027 | 2260 × 3000 | 337 × 448 | 675 × 896 | 2260 × 3000 |
| 23.072 | 2010 × 2712 | 190 × 256 | 664 × 896 | 2010 × 2712 |
| 72.096 | 3665 × 3063 | 384 × 321 | 896 × 749 | 3665 × 3063 |
| 1999.3 | 2859 × 3457 | 265 × 320 | 741 × 896 | 2859 × 3457 |
| 33.053 | 3420 × 2772 | 384 × 311 | 896 × 726 | 3420 × 2772 |
| 2021.101 | 3076 × 4320 | 137 × 192 | 638 × 896 | 3076 × 4320 |
| 2010.57 | 3155 × 3786 | 267 × 320 | 747 × 896 | 3155 × 3786 |
| 35.770 | 3000 × 2428 | 256 × 205 | 896 × 719 | 2922 × 2344 |
| 60.095 | 3350 × 4007 | 266 × 320 | 745 × 896 | 3198 × 3847 |

Van Gogh's photographic backdrop crop is `[47,40,2969,2384]`; Cassatt's outer support-edge crop is `[72,96,3270,3943]`, visual edge uncertainty±8 source pixels. Other paintings keep their full rectangles. The source bytes and all art colours are unchanged; derivatives only crop, resize downward and encode. Wall/preview images keep their authored imports under `modules/shell/assets/impressionist/`: mode 1, quality.8, mipmaps on, force-added ignored imports. Full zooms are under its `zoom/.gdignore`, outside the pack, copied into `museum-images/` beside the Web pack and requested only when opened.

**INFERRED placement:** ten listed offsets and all centre heights are retained. Two wall-fit corrections are explicit:42.190 at A north along 4.00 m instead of 4.95 m, because 4.55–5.85 m is the existing door opening;35.770 at B east along 3.66 m instead of 3.78 m, because its listed frame overlaps the window casing beginning at 4.02 m. Each frame now clears its casing by roughly 3 cm. The .95 m Manet correction is outside the list's±.5 m end-wall error; this requires physical-layout review, rather than being passed off as a calibrated measure. Van Gogh's .12 m shift is within the±.8 m long-wall estimate. Their blank cards are on the left to stay on painted wall. No doorway or window moves.

Frame widths derive from `(estimated outer size − catalogue canvas size) / 2`. Existing E7/E9/E3/W7/W3 carving is borrowed; exact carving and absolute colour calibration remain unaccepted. Two numerical palette copies of existing W7 preserve its 1361× 966 dimensions and complete alpha channel: pale silver/cream for Pissarro/van Gogh and rose-brown for Gauguin. Source/output hashes and the reproducible linear-colour recipe are in `frame-palettes.json`; new spend USD 0. These copies use the unchanged stock PS1 shader, so the existing bake adapter converts and shades them. The initial custom shader variation was replaced before handoff because it bypassed that conversion. Art materials are never tinted.

At the actual 695× 465 game view, native picking, first inspection and full photograph opening pass for all twelve, with zero premature full-zoom loads. The 48 new frame/canvas surfaces unwrap at.14 m and all use the stock bake material. `../impressionist-images/catalogue-checks.json` preserves the measured sizes; the display measurements have roughly±1 px raster uncertainty, not physical-museum accuracy.

| Accession | Inspected canvas pixels (±1 px) | Required wall long side | Frame width × height, m |
| --- | --- | --- | --- |
| 42.190 | 128 × 106 | 256 | 0.640 × 0.550 |
| 2007.68 | 105 × 146 | 256 | 0.680 × 0.870 |
| 57.236 | 188 × 122 | 384 | 0.990 × 0.730 |
| 59.027 | 156 × 204 | 448 | 1.470 × 1.830 |
| 23.072 | 107 × 145 | 256 | 0.700 × 0.870 |
| 72.096 | 161 × 132 | 384 | 0.940 × 0.820 |
| 1999.3 | 129 × 152 | 320 | 0.740 × 0.850 |
| 33.053 | 202 × 162 | 384 | 0.970 × 0.810 |
| 2021.101 | 76 × 108 | 192 | 0.370 × 0.470 |
| 2010.57 | 124 × 148 | 320 | 0.710 × 0.810 |
| 35.770 | 111 × 90 | 256 | 0.660 × 0.580 |
| 60.095 | 122 × 142 | 320 | 0.770 × 0.860 |

Imported wall/preview textures total **2,110,686 bytes (2.013 MiB)**; the two palette textures add **220,784 bytes**, giving **2,331,470 bytes (2.223 MiB)** of new imported textures. The **33,013,634 bytes (31.484 MiB)** of full zooms stay external. **INFERRED final growth:** about 2.224 MiB plus small geometry/script/record overhead, leaving substantial space within 260 MiB from the supplied approximately 218 MB baseline. **VERIFIED pack-only export of the current installed tree:** 232,113,540 bytes (221.361 MiB),26 new imports and zero new external-zoom files in the pack. This is not a final rebaked export.

Final official `scripts/rebuild_rooms.sh --draft` completed, with 31 cased sides and **ARCHITECTURE_CHECK failures=[]**. The native GL capture reports 40 existing reciprocal trials and zero failures; none was added or moved. Both Python guards pass (193 declarations/53 unchanged shortfalls;55 works/165 photographs). `git diff --check` is clean. The source representation check's only failures are the two existing undeclared Renaissance works 59.128 and 21.398. The full repository check still exits 1 without `checks passed`: the 16 baseline installed mismatches, listed once in `../impressionist-images/NOTES.md`, plus the 12 new paintings absent from stale installed rooms. No check or acceptance flag is weakened. No engine errors occur in these final runs. Baked Web visibility/lighting, final installed pack size and the orchestrator's post-install door playtest remain unverified here.

Edits outside `impressionist_additions.gd`: the own-module photo/palette/import/zoom assets; source catalogue/palette records and preparation helper; exactly twelve authored object/representation rows; a five-line named photo-copy block in `prepare_remodel.py`; one external-zoom copy line in `scripts/export-web.sh`; Shell provenance; and review-only evidence/capture helpers. No edit to `remodel_room.gd`, `main_build_walk.gd`, room bounds/openings/floor patches/route trials, shared lamps/casings/reveals/skirtings/cornices, generated scenes/lightmaps, character, playtest or frozen interfaces/errors.

**Left:** bronze 23.315 needs a mesh and its existing six-sided case remains empty; physical fitted offsets, borrowed carving and final baked light still need judgment. Existing modern-gallery Venetian blinds and the inherited installed/source registration faults are outside this job. No merge, issue closure, installation or bake was made. The one private unbaked project remains at `~/risd-godot-ingestion/collection-expansion/rebuild-impressionist-images/extension/`.
