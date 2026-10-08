# Skylight Gallery — #275

Source branch: `feat/skylight-275`, starting at `ecfda16e`. Sources only; the
orchestrator must bake and install. No paid services. Measurements and shape
judgments below are estimates, not acceptance flags.

## 1. Survey and plan (8 October)

Read #275, the room pipeline runbook, the Skylight findings 9.1–9.7 and reveal
findings 14.1–14.3 of the 8 October census, and the earlier #238 survey. Viewed
the whole 182.55-second clip as a sequence, including newly tone-mapped frames
at 3, 6.5, 9, 13.5, 26, 40, 54, 68, 82, 99, 112, 127, 132, 144, 154.5,
159.5, 170 and 180 seconds. `00-footage-levels.jpg` and
`01-footage-detail.jpg` retain the principal comparisons.

The zero-byte `collection-expansion/IMG_6379.MOV` is unusable. Read the complete
191 MB copy at `collection-expansion/verified/IMG_6379.MOV`. These are HLG
frames converted with the owner's zscale / Hable filter; no video pixels enter
the architectural materials.

Scale: the existing #238 multi-view survey triangulated the Diao canvas,
69.094, at its catalogue width of 2.21 m (frames 37.7, 38.0, 39.1, 39.9,
151.3 and 153.3 s). Its reported scale error is ±1.3%. That model is not in
this checkout: its numerical fit is inherited, not re-computed here. New
frame checks distinguish direct observations from dimensions inferred from
that fit. Error ranges below include uncertain wall/rail endpoints.

Room coordinates: x increases west to east, z increases north to south;
grey gallery/entry level y = 0. Gallery oak floor y = −2.55 (revised below).

| Item | Reconstruction estimate, error | Frames / method |
| --- | --- | --- |
| Plan | 9.50 × 5.00 m, ±0.60 / ±0.30 m | Inherited 9.55 / 5.04 m canvas-scaled fit; 6.5, 127, 154.5 s corroborate wall order and stair footprint |
| Lower storey | **2.55 m, ±0.30 m** | New independent Diao / Feldman wall-plane checks at 127 / 54 s; initial inherited 3.30 m estimate rejected |
| Landing to ceiling | 3.90 m, ±0.30 m; total 6.45 m | Canvas-to-cornice fit, checked at 40 / 127 / 154.5 s |
| Upper landing | 2.70 × 1.65 m, ±0.20 / ±0.15 m | Rail endpoints in earlier fit; 54, 127, 154.5, 170 s show front and west guards, stair departing east |
| Entry | centre 5.20 m from west, ±0.40 m; current 2.00 m clear width retained, ±0.30 m | Camera route 170–182 s; reciprocal IMG_6380 0–14 s. Reveal 0.80 m is existing kit extent, not a new measured claim |
| Stair well | 1.75 × 2.07 m, ±0.20 m | Earlier rail fit; 54 / 68 / 159.5 s corroborate U around east end |
| Stair run / width | upper and lower runs about 1.75 m, middle 2.07 m (±0.20); upper width 1.65 m, east 1.20 m, lower 1.28 m (±0.15) | Fit well inside measured room with landing depth; 26 / 127 / 159.5 s. Provisional 18 risers at 0.142 m, 5 / 7 / 6 descending; 35 / 29 / 72 s, ±1 riser total |
| Landing rail | 0.90 m tall, ±0.08; slender rods at about 0.14 m pitch, ±0.02 | 54 / 154.5 / 159.5 s; proportions to known canvas and estimated platform |
| Laylights | west 3.40 × 2.60 m, east 1.70 × 2.60 m, ±0.30; 5 transverse panes, 4 / 2 along room | 6.5 / 99 / 144 s; common transverse grid, separated by a substantial plaster beam. Plan positions provisional pending draft comparison |
| Piano | 1.75 × 1.48 m, ±0.20; closed lid about 0.98 m high, ±0.10 | 3 / 13.5 / 127 / 132 s; curved grand case, keyboard west, bench at keyboard, three legs and caster feet |

Plan at the current room-scene attachment: shell `[0.35, 9.85, -10.76, -5.76]`;
entry `[4.55, 6.55]` on the south wall. Upper landing x 4.20–6.90,
z −7.41–−5.76. Descend east along south wall, turn north at the south-east
corner, then west at the north-east corner onto the oak floor. Inner well
x 6.90–8.65, z −9.48–−7.41. Piano in north-west corner. Lift in south wall
on the lower floor under / west of the entry platform. Existing deep reveal
and folded leaves stay at y = 0.

## Works and lighting handoff

Five works have images already in `image-work/collection-room-remodel/additions/skylight/`.
The footage survey shows no sixth work needing an absent image. Walsh's
accession remains inferred from the earlier catalogue match; the unreadable
label does not establish its identity.

| Work | Wall / centre from west or north; centre above entry (above lower floor) | Evidence / error |
| --- | --- | --- |
| Diao 69.094 | west, 2.50 m from north; +1.64 m (+4.19) | Canvas triangulation inherited; new floor-plane check +4.109; 40 / 127 / 154.5 s; ±0.20 height, ±0.25 position |
| Mangold 73.018 | north, 2.20 m from west; +1.75 (+4.30) | 132 / 154.5 s; ±0.25 height / ±0.30 position |
| Feldman 2026.3 | north, 4.65 m; +2.00 (+4.55) | Over lower exit; new floor-plane check +4.528; 54 / 109.5 / 132 s; ±0.25 height / ±0.25 position |
| Congdon 2000.17 | north, 7.63 m; +1.75 (+4.30) | East of exit, 6.5 / 54 / 144 s; ±0.25 height / ±0.30 position |
| Walsh 2025.19 | east, 2.50 m from north; +1.90 (+4.45) | Over turn of stair, 6.5 / 159.5 s; ±0.30 height / ±0.30 position |

Light comes from the two diffuse laylights, with white cylindrical track
heads on narrow tracks round their perimeter and on the dividing beam
(6.5 / 99 / 144 s). A grey high vent and small security devices appear in the
south-east corner (99 s). Lamps / bake are #274's work. Retain pale grey walls,
white kit trim, pale straight oak below, black painted stair/landing and
warm brown wood handrails. There is no window at floor level.

## 2. Build sequence and review checklist

1. Push this survey. Rebuild shell, lower floor, landing, three descending
   runs and quarter landings; supply collision ramps / floor patches and
   trials for entry, stair both ways, landing guards and lower circulation.
2. Inspect a draft against 6.5 / 127 / 154.5 / 159.5 s, then push the shell.
   Keep geometry in `skylight_additions.gd`; only named Skylight plan and
   walking-adapter edits in shared sources.
3. Replace plain rail proxies with paired scroll / leaf balusters, decorated
   corner posts, curved cage newel and wood volute; replace box piano with
   curved case, separate closed lid, keyboard, three legs, pedals and bench.
   Inspect and push that detail.
4. Check five existing images at true heights over the lower floor, move
   room records only if necessary, and push final side-by-side evidence.

Census 9.1 / 14.1: two floors and real stair; 9.2: look upward at both
laylights; 9.3: high hanging; 9.4: piano outline; 9.5: lower exit and lift;
9.6: lighting handoff; 9.7: preserve grey walls / pale floor / white trim /
entry reveal. Census 14.2's navy slabs and 14.3's exit sign need a baked
stage view to judge; do not claim their integration state from a draft.

## Verification / integration record

Initial check failed on missing local Godot texture imports and three
pre-existing representation mismatches (`37.114`, `20.254`, `59.131` declared
mesh with no `place_mesh()` in the installed generated rooms). This predates
any source edit for #275. Running the initial editor import; do not alter
these other rooms or install generated rooms. Draft requested at the one
fixed trial folder `collection-expansion/rebuild-skylight-275` (host lock).

Doorways and route trials, every edit outside the additions file, draft
pictures and exact check results will be recorded here at each checkpoint.

### New height checks, superseding the inherited lower-storey estimate

`measure.py` and `height-check.json` reproduce two plane homographies from the
catalogue rectangle corners to metres. Diao at 127 s gives its centre 4.109 m
above the lower wall/floor line; subtract the inherited +1.64 m relative to
entry and the storey is 2.469 m. Feldman at 54 s gives +4.528 m above the lower
floor; subtract +2.00 and the storey is 2.528 m. These independently support
2.55 m, not the earlier 3.30. Coordinate jitter, floor-line choice and the
entry-relative heights still leave about ±0.30 m uncertainty. The field of
view / wall extrapolation is why an unrectified pixel ratio is unreliable.
The earlier numerical SfM floor result cannot be checked without its missing
model; do not treat it as ground truth.

At 35 s the short top flight shows five risers, at 29 s the middle flight
about seven, at 72 / 75 s the bottom flight six including its curved start.
18 × 0.142 m supports the corrected storey. Counts remain provisional by
one riser; the footage confirms the three runs and two corner landings.

### Shell source checkpoint

The named Skylight block in `prepare_remodel.py` produces nine real collision
patches: three lower floor regions, the upper deck, three descending ramps,
and two quarter landings. The additions file replaces this room's level
visual boards with pale oak at −2.55, adds the downward wall extensions and
platform enclosure, and places the lift and existing piano on that floor.
It reuses kit mouldings / casings; the kit's implementation is untouched.
The lower EXIT is a wall feature with folded leaves / push bars and the
existing Hall sign texture, closing after a 0.95 m doorway study. No new
gallery beyond it is implied.

Outside `skylight_additions.gd`, source edits are:

1. `prepare_remodel.py`: remove the old three flattened Skylight trials;
   append a separate #275 block after all other room layout changes. That
   block changes only the Skylight room's floor tag / height, its collision
   patches, its own walking record and the 16 trials listed below.
2. `main_build_walk.gd`: read the Skylight floor patches / guard lines;
   `_skylight_height` and `_skylight_step` set the visitor's y from those
   same floors / ramps and reject unsupported drops. Skylight floor clicks
   intersect the actual surface planes; the stage mask is lowered to the
   oak floor so it cannot cover the lower room. Other room heights stay
   on the existing path. No room names, stages or joins change.
3. This evidence directory only. No `remodel_room.gd`, lamp, reveal, kit,
   character, playtest, interface or error file changed.

Entry door / both reveal openings stay `[4.55,6.55]`, at y=0, with bounds
`[4.55,6.55,-5.76,-4.96]`. Nothing moves in the grey gallery. Lower north EXIT
is centred at x=5.00, z=−10.76, 1.80 m wide at y=−2.55, 2.40 m clear height; it is not a new
room connection in `geometry.json`. No new room label was added.

Route trials: `grey_skylight_out`, `grey_skylight_back` now stop on / depart
the upper deck (z=−6.58); `skylight_landing_east`, `skylight_upper_down`,
`skylight_east_down`, `skylight_lower_down`, `skylight_lower_aisle`,
`skylight_lower_west`, `skylight_lower_lift`, `skylight_lower_up`,
`skylight_east_up`, `skylight_upper_up`, `skylight_landing_back`,
`skylight_front_guard`, `skylight_west_guard`, `skylight_piano_blocked`.
The guard trials expect collision; the piano trial is moved to the lower
floor. At the stair foot, x=6.30 clears the bottom rail's end; x=6.60 did not.

The actual walking adapter's clamps, grid and pulled click route were run
against the new plan in a small scratch harness: 15 surface / guard trials
pass, entry-to-lower click route has 49 grid cells and reaches the lower
floor, no unsupported height jumps, largest movement step 0.023 m. The
draft must still test the actual piano / rails / walls and supply pictures.

For #274: built pane centres `(3.95,3.888,-8.26)` / `(7.05,3.888,-8.26)`,
dimensions 3.40×2.60 / 1.70×2.60, above a lower floor at −2.55. Ceiling and
tracks seen in the footage are at about +3.90 / +3.65. The current positive
painting centre heights in the table are in entry-level metres, not lower
floor metres. Probes must reach below y=0 as well as the upper deck.


### Shell pictures and checks

Draft #1 completed at the fixed `rebuild-skylight-275/extension` directory.
`ARCHITECTURE_CHECK` has `failures: []` (`shell-architecture.json`). Looked at
seven 960px renderings from entry, upper landing, three lower positions,
stair and ceiling. The comparisons below have footage left and draft right;
all are JPEGs below 150 KB. These establish the shell, not iron / piano detail.

- `03-shell-lower.jpg`: IMG_6379 6.5 s; lower room looks up across all three
  stair runs and full-height east / north walls. Balusters and piano are proxies.
- `04-shell-entry.jpg`: 154.5 s; elevated deck and high-hung north works.
  The draft camera is still in the grey gallery to include the deep reveal.
- `05-shell-stair.jpg`: 159.5 s; descending east flight, lower floor beyond.
- `06-shell-ceiling.jpg`: 144 s; two gridded laylights viewed from below.

Census 9.1 / 9.2 / 9.3 are visible in the draft; 9.4 and iron ornament are
next. Lower exit is on the **north** wall in the plan, under Feldman: the
census's west-wall wording describes the old camera view, not the compass
position corroborated by the filmed wall order. Existing upper door / reveal
casings and leaves are preserved. The floor inside that reveal is black.

`scripts/check.sh` still fails only on the same installed-room representation
mismatches (`installed-representation.json`). It cannot print `checks passed`
against the unchanged generated tree. Missing-import failures were resolved
by a headless editor import. Python compilation, own GDScript check-only and
`git diff --check` pass. No generated room was installed or committed.

The existing draft physical runner completed all **16 movement / collision
trials**, on actual floor or ramp at every endpoint. Recorded y values are
0.0008, −0.707, −1.699 and −2.549 m at the four levels, within 4 mm of plan
(`shell-physical-routes.json`). Its flat-study camera check fails on two
lower-floor segments, `skylight_lower_aisle_camera` and
`skylight_lower_west_camera`: the entry deck is between its overhead camera
and the lower visitor. This is a camera limitation to resolve / inspect in
the actual walking adapter during the detail pass, not a failed stair
collision hidden by the pictures. Draft geometry was restored after selecting
just these trials; no acceptance test source was edited.


## 3. Iron, stair detail and piano

Reference forms: 54 / 99 / 127 / 154.5 / 159.5 s. The rail shafts have mirrored
rolled leaf / heart scrolls below the rail and above the tread, four collars,
and an iron strip under the oval wood. Corner posts are open panels with five
pairs of C scrolls. The lower newel is a cylindrical cage with four hoops,
finished with the curled wood volute. The handrail bends continuously through
the corners and changes slope at the actual quarter landings. Wall rails have
metal brackets into their walls. Pitch ~0.14 m, motifs ~0.11 m across / 0.17 m
high, rods 0.016 m diameter, wood ~0.074 × 0.050 m; all inferred ±15–25% from
the frames. These are closed geometry, batched by material, with no video
texture on architecture. Black treads have rounded noses; the bottom step
curls 0.15 m round the newel. Collision remains on smooth supported ramps.

The old L-shaped piano has been replaced by a closed curved grand case and
a separate lid, cheek blocks, fallboard, 52 ivory / 36 black keys in the two /
three grouping, folded music rack, three turned legs with caster wheels,
pedal lyre / three pedals, padded bench with piping and button tufts / four
legs. The small lid card seen at 13.5 s is blank. Maker and unreadable wording
are omitted. Dimensions remain 1.75 × 1.48 × 0.98 m, ±0.20 / 0.20 / 0.10;
case curve, feet and small details are inferred from 3 / 13.5 / 132 s.
Materials reuse the room builder's iron / wood / plain paint construction and
the kit white. The room's filmed smooth grey walls use plain grey paint.

Census 9.5: lower north EXIT now has a 2.40 m clear opening / approximately
2.50 m outer casing, consistent with the new 2.535 m wall-plane check at 54 s.
Two open fire-door leaves have hinges, two moulded panels each and push bars.
The existing Hall EXIT texture is reused. The short study closes 0.95 m behind
it: it adds no destination / new room / route. Under the platform, a 1.20 m
wide, 2.20 m high cased vestibule study closes after 0.40 m; a white cupboard
fills the underside of the first run. The wayfinding screen faces west toward
the lift, at x=4.07, y=−0.97, z=−6.43; 0.64 × 0.86 m, dark glass / metal.
Its map and lettering are not invented. These feature dimensions / casing
positions are inferred from 6.5 / 23 / 99 s, ±0.15–0.25 m.

Draft #2 and the refreshed own additions passed `ARCHITECTURE_CHECK` with
`failures: []`, 21 casings. The actual attached walking game now passes all
16 movement / collision trials and both pulled click routes, entry to lower
floor and back (`detail-game-routes.json`, review harness `check-walk.gd`).
The physical draft runner independently passes all 16 movement trials, with
floor height errors under 4 mm (`detail-physical-routes.json`). Its two
flat-camera failures remain; it is not the runtime camera. The runtime hides
obstructing Skylight decks / treads and tests the full visitor head. Source
camera changes, beyond the first shell checkpoint, are named Skylight-only
structure collection / visibility, floor-relative low-case handling, head
clearance rays and clicks skipping hidden upper decks while retaining the
existing through-door click rule. No shared kit / reveal / lamp code changed.

For reproducible runtime review, the existing character / close-icon assets
and authored captions were copied **only into the disposable draft**, with
`main_build_walk.gd` copied as `skylight_main_walk.gd`. The repository character
and generated rooms are untouched. The default draft presenter does not use
the actual walking adapter and resets manual visitors below y=−2; the runner's
QA mode bypasses that old reset. Actual adapter trials / pictures use y=−2.55.


### Detail pictures and runtime camera

Looked at the detail pass in both the room scene and the actual walking
adapter. `07-detail-rail.jpg`, `08-detail-stair.jpg`, `09-detail-piano.jpg`
and `10-detail-lower.jpg` compare footage on the left with the draft on the
right. `11-game-two-levels.jpg` shows the runtime visitor on the upper deck
and on the lower oak floor. These JPEGs are each under 150 KB. The keyboard,
curved closed lid, bench, cage newel, scroll panels, rolled balusters, wall
rail brackets and the lower cased openings are visible, not claimed from
node counts alone.

An extra camera edit in `main_build_walk.gd` follows the room scene's
`update_baked_visibility()` call: **only while the current stage is Skylight**,
it restores that stage's hiding of neighbouring ceiling details. The draft
callback was reshowning a grey-gallery ceiling track across the lower room's
camera. The track was diagnosed from its AABB and `grey_additions.gd` source;
no lamp or ceiling geometry was edited. The latest runtime pictures show
that stray white track removed. Existing same-stage laylights remain visible
from inside the room.
