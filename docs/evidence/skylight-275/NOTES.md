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
grey gallery/entry level y = 0. Gallery oak floor y = −3.30.

| Item | Reconstruction estimate, error | Frames / method |
| --- | --- | --- |
| Plan | 9.50 × 5.00 m, ±0.60 / ±0.30 m | Inherited 9.55 / 5.04 m canvas-scaled fit; 6.5, 127, 154.5 s corroborate wall order and stair footprint |
| Lower storey | 3.30 m, ±0.20 m | Inherited floor-point fit; 6.5, 99, 127, 132 s show entry platform above lower door heads |
| Landing to ceiling | 3.90 m, ±0.30 m; total 7.20 m | Inherited canvas-to-cornice fit, checked at 40 / 127 / 154.5 s |
| Upper landing | 2.70 × 1.65 m, ±0.20 / ±0.15 m | Rail endpoints in earlier fit; 54, 127, 154.5, 170 s show front and west guards, stair departing east |
| Entry | centre 5.20 m from west, ±0.40 m; current 2.00 m clear width retained, ±0.30 m | Camera route 170–182 s; reciprocal IMG_6380 0–14 s. Reveal 0.80 m is existing kit extent, not a new measured claim |
| Stair well | 1.75 × 2.07 m, ±0.20 m | Earlier rail fit; 54 / 68 / 159.5 s corroborate U around east end |
| Stair run / width | upper and lower runs about 1.75 m, middle 2.07 m (±0.20); upper width 1.59 m, east 1.14 m, lower 1.22 m (±0.15) | Fit well inside measured room with landing depth; 26 / 127 / 159.5 s. Provisional 21 risers at 0.157 m, 7 / 8 / 6 descending; counts to refine against close frames |
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
| Diao 69.094 | west, 2.50 m from north; +1.64 m (+4.94) | Canvas triangulation inherited; 40 / 127 / 154.5 s; ±0.15 height, ±0.25 position |
| Mangold 73.018 | north, 2.20 m from west; +1.75 (+5.05) | 132 / 154.5 s; ±0.25 height / ±0.30 position |
| Feldman 2026.3 | north, 4.65 m; +2.00 (+5.30) | Over lower exit, 54 / 109.5 / 132 s; ±0.25 height / ±0.25 position |
| Congdon 2000.17 | north, 7.63 m; +1.75 (+5.05) | East of exit, 6.5 / 54 / 144 s; ±0.25 height / ±0.30 position |
| Walsh 2025.19 | east, 2.50 m from north; +1.90 (+5.20) | Over turn of stair, 6.5 / 159.5 s; ±0.30 height / ±0.30 position |

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
