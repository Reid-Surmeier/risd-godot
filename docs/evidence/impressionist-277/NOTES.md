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
| A entry | north wall, centre about 5.30 ± .45 m from west corner; 1.4 ± .2 m clear | 141, 147; door/Manet scale, position weaker than end wall |
| A → B door | south wall, centre .95 ± .20 m from east corner; 1.04 ± .15 m clear, head **2.47 ± .20 m** | 147; Manet-plane homography; floor inside B is behind plane, so use A end-wall floor line |
| A finishes | cool grey painted walls; white skirting/casings/cornice; honey oak straight boards across the room; pale flat ceiling | 98, 121, 145, 147 |
| A window 1 | east wall, centre 3.0 ± .6 m from north; outer width 1.6 ± .2 m, sill .55 ± .12 m, head 3.15 ± .25 m | 143, 149; Degas canvas .464 × .629 m |
| A window 2 | east wall, centre 7.6 ± .8 m from north; same size ± .2 m | 143, 147, 151; same-plane Degas/door cross-check |
| A windows | white sash and deep inner lining, two panes below the meeting rail; oatmeal roller shades cover upper roughly 55%; panelled aprons with low horizontal grilles | 121, 143, 149, 151 |
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
| Impressionist gallery A | [10.55, 16.70, 3.04, 12.70] | 3.69 | north/south x[15.10,16.40] |
| Impressionist gallery B | [10.55, 16.70, 12.70, 22.30] | 3.5 | north/south x[15.10,16.40] |

A's depth is stretched **.06 m**, B's **.80 m**, and the passage adds **3.00 m** of southward travel (5.00 m from stair centre to A entry instead of the 2.00 m filmed estimate). This totals the required **3.86 m** longitudinal fit. Both gallery widths are **6.15 m**, .10/.15 m narrower than the estimates. The passage return also adds **4.70 m of lateral travel** between x20.45 and x15.75; that return is a build fit, **not observed in the clip**. No existing adjoining room moves. The under-stair internal leg x17.85–19.45 is already inside the hall and has its obstruction opened.

The first draft exposed a mirror error: looking towards +z, screen left is world **east**, and the filmed windows and end door are both on that side. The fit was corrected before the shell checkpoint. A/B now lie west of the passage and have east-side doors and windows; this preserves the filmed relationship and reduces gallery-depth distortion. The four new rectangles do not overlap any existing room. Their opening intervals match pairwise, including the retained modern far door. Source assertions and draft route samples check closure in the build. The passage return, room depths and wall offsets remain **INFERRED**; the exact physical museum plan is **not accepted**.

## 3. Census checklist

- Marble stair hall §8 finding 4: replace the lift-like closed exit with the open doorway, folded leaves and traversable passage.
- Modern adjoining stub §15 findings 1–2: replace the closet and its blank end wall with gallery B, oak, grey walls, shaded sash windows and real door to modern gallery.
- §15 finding 3: new openings use the shared white trim kit; no custom casing/skirting/cornice code or `DEEP_REVEALS` edits.
- Track locations and pools will be described for #274. Lamps are outside this ticket's edits.

## 4. Planned source edits and gates

`prepare_remodel.py`: named room entries, openings, floor patches and reciprocal route trials. `impressionist_additions.gd`: room-specific walls/finishes, window assemblies, benches, hexagonal case and approved existing artwork. `remodel_room.gd`: add one name to `ADDITIONS` only if sufficient. `marble_hall_additions.gd`: smallest edit to remove the closed exit obstruction. `main_build_walk.gd`: replace stub name/stage and add required room and connector names. Authored `objects.json` and `representation.json` only for works actually hung; no generated room assets committed. No frozen interfaces, character, gallery_walk4 or playtest edits.

At every push: `scripts/check.sh` must report `checks passed`, `git diff --check`, a `--draft` rebuild with a successful `ARCHITECTURE_CHECK`. Baked doors playtest is deferred to the orchestrator; all added door planes and trial coordinates will be listed here. The baseline checks/draft are running; no success is claimed yet.

## 5. Baseline gate defect (before source edits)

The initial import completed. `scripts/check.sh` now gets through import but `REPRESENTATION_CHECK` fails on **37.114, 20.254, 59.131**: each is declared a mesh but the shipped generated room scene still places the previous photograph slab. The authored `medieval_additions.gd` already places the new GLBs; the generated copy/bake is older. This is unrelated to #277. No generated files or medieval source/records were changed to suppress it. A push is held until the required check genuinely passes or the owner gives a scoped exception. The source draft subsequently passed `ARCHITECTURE_CHECK` with 28 cased door sides. The final furnishing rebuild is queued behind other bakes on `/tmp/risd-rebuild-rooms.lock`.

## 6. Survey picture index

`survey-0.jpg`: stair entry/passage and first A wall group (84–115 s). `survey-1.jpg`: A Manet, windows, small works and full end-wall relationship (121–176 s). `survey-2.jpg`: B paintings and modern exit (180–228 s). These are reference-only JPEGs, each below 150 KB. Additional detail/paired draft photographs will be added at the geometry and furnishing checkpoints. All 17 works are listed in `WORKS-NEEDED.md`; 1998.107 and 41.012 are approved existing images. The Cézanne photograph was found under its title rather than its accession.

`fitted-plan.jpg` diagrams the exact fixed-end fit; this is a notes diagram, never a game texture. `draft_capture.gd` is a review-only capture script for the draft and samples the added route using the game adapter's actual `_free()` rule. It is not an acceptance-test edit.

## 7. Shell checkpoint (source changes, 8 Oct)

The first preliminary (mirrored) draft command completed in the one `rebuild-impressionist-277` folder: **ARCHITECTURE_CHECK failures=[]**, 26 cased door sides. Its layout was corrected as §2 records; the corrected draft subsequently completed with **ARCHITECTURE_CHECK failures=[]**, **28 cased door sides**, at about 18:03 UTC. The walking adapter sampled **40 reciprocal trials** (38 new, 2 retained) at 41 points per leg: **zero failures**. `2-shell-stair.jpg`, `2-shell-A.jpg` and `2-shell-modern.jpg` show the corrected plain shell beside the source frames. **VERIFIED in those draft pictures:** open stair doorway, A/B end-door relationships, continuous floors, grey walls, white kit trim and flat ceilings. Dimensions and the extra passage return remain **INFERRED**. Full `scripts/check.sh` still fails only on the three baseline medieval mesh declarations in §5; `git diff --check` is clean. `python3 -m py_compile prepare_remodel.py` passes. No generated room files are edited or staged. The scoped push exception was asked in chat because the user explicitly requires the full check to pass; it is still pending.

### Edits outside `impressionist_additions.gd`

1. `prepare_remodel.py`: replace only room index12's modern stub with B; add separate passage/return/A entries; add the marble hall's outer east opening and its head height; keep every old bounds/door fixed; append fit metadata, shared-opening assertions and route trials. The existing floor-patch loop includes the new areas. No other room entry is moved.
2. `remodel_room.gd`: one `ADDITIONS` list entry, after the marble hall. No lamp, casing, deep reveal, skirting or cornice implementation is changed.
3. `main_build_walk.gd`: add four names to `FAR_ROOMS`; replace the obsolete modern-stub join with both passage areas directly joined to A in `JOINED`. A and B get distinct stages from the existing automatic stage builder. Room names/doorways otherwise come from `geometry.json`; there are no literal Renaissance-room registrations to copy in this adapter.
4. `marble_hall_additions.gd`, `inner_walls()` only: replace the single closed exit wall/leaf batch with two piers and a header; call the existing shared casing kit; retain the existing EXIT sign. Cut the old continuous base at that opening (no profile change). Split the invisible obstruction behind the landing into north/south blocks to admit only the passage. Flights, other doors, lamps and cornice are untouched.

### Door planes for the orchestrator's baked `--only=doors` check

| Door | Plane | Clear interval | Head height | Change |
| --- | --- | --- | --- | --- |
| stair hall internal exit | x17.85 | z[-2.51,-1.41] | 2.47 | closed double leaf / solid wall removed |
| stair hall outer east ↔ passage west | x19.45 | z[-2.51,-1.41] | 2.47 | new paired opening |
| passage south ↔ return north | z1.04 | x[19.75,21.15] | 2.74 | new paired opening |
| return south ↔ A north | z3.04 | x[15.10,16.40] | 2.74 | new paired opening |
| A south ↔ B north | z12.70 | x[15.10,16.40] | 2.47 | new paired opening |
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

Native draft capture after the final room-owned detail changes reported **40 trials, zero route failures**, and no `ERROR` / `SCRIPT ERROR`. The unchanged architecture checker reported **28 cased door sides, failures=[]**. The final official rebuild has been queued; the previous official furnishing draft also passed with28. The full repository `scripts/check.sh` still exits1 on only the baseline three stale mesh declarations in§5; image/record checks pass. `git diff --check` is clean. Colliding bench/case proxies have an empty visual mesh, so revealing children for a cutaway cannot display a box over the built shape.

Room-owned additions call the kit for trims/leaf beads and reuse existing cloth; no shared lamp, casing, skirting, cornice or reveal implementation changed at this checkpoint. A detector is geometry, not a lamp. Native close photographs use the review fill described in§7; brightness is not a baked-lighting acceptance claim.
