# Collection: adding the reconstructed rooms to the live Main Hall

Review only. No runtime file, bake, asset, or frozen interface was changed. Nothing was run in Godot; every claim below is from reading files and looking at saved images, and section 8 lists what that leaves unverified.

## 1. Verdict

The v47/v48 prototype does not add rooms to the Main Hall. It rebuilds a stripped copy of an **older** Hall inside a separate scene, and that copy has lost the Hall's reviewed portal, door casings, floor, bench, vestibule, camera and lighting. The painting-count assertion (23) passes and hides this.

The minimum way to add the rooms is the reverse of what `connected_hall.gd` does: one new script that **extends** the live `walk4.gd` and only adds, plus a one-line path change in `demo.gd`. The live Hall already has the two attachment points the rooms need: a walkable stone portal with an empty stand-in medieval room behind it, and a second "space" behind the far door that swaps in by render layer and its own light capture under a white cover.

Recommended order: north rooms through the far door first (no Hall pixel changes at all), then the south rooms at the portal (hides four stand-in wall meshes at runtime; no Hall file changes).

## 2. Git state and evidence commands

| Checkout | Branch | HEAD | State |
| --- | --- | --- | --- |
| `integrate-square-164` (live build, read-only) | `build/v0.1.0` | `317b8f3b8dac0f9811d396bcb0260c7187f93f11` | tracked files clean; untracked owner evidence left alone |
| `collection-reconstruction` (coordinator, read-only) | `Reid-Surmeier/collection-reconstruction` | `12defc0446d5fa1bd4c50e9c598decfef7a7130d` | 10 modified files, v48 work uncommitted |
| `collection-opus-main-build-review` (this report) | `Reid-Surmeier/collection-opus-main-build-review` | `12defc0446d5fa1bd4c50e9c598decfef7a7130d` | only this file added |

```text
git merge-base HEAD 317b8f3b            -> 55e7c3b7 (2026-09-27)
git rev-list --count 317b8f3b..HEAD     -> 61   (reconstruction ahead)
git rev-list --count HEAD..317b8f3b     -> 94   (reconstruction behind the live build)
git log --oneline 55e7c3b7..317b8f3b -- .../gallery_walk4/walk4.gd | wc -l -> 17

sha256 (first 12) and line count of walk4.gd
  399e9f9837ac  3371 lines  integrate-square-164            (live)
  5fb1a1d10bb5  1736 lines  collection-reconstruction       (stale)
  5fb1a1d10bb5  1736 lines  lowpoly-room-v48b-modern-frames (stale copy the draft runs)
painting_asset.gd 0044b1ff6205 and ps1.gdshader db206d444666 are identical in live build and v48b.

Live Hall bake (must stay byte-identical through integration)
  0fe3d246ec52d848  baked/room.tscn    139 Surface nodes, 1 LightmapGI, 0 lights
  e68c711f84cf22d1  baked/room.exr
  6679c19719710465  baked/room.lmbake
  17be77205bf03659  baked/white.lmbake
```

Issues read with `gh issue view 178|181|182|183` (all open). Relevant constraints: #178 "do not invent museum topology", "3D Viewer unchanged", "no production integration during charting"; #181 "recommend real evidenced topology with explicitly unresolved gaps"; #182 "one real connection, both directions"; #183 "reuse final reference-preserving frame recipe".

Images inspected: v48b `evidence/` (`loop-overview`, `hall-wide-arch`, `hall-wide-far`, `hall-walk`, `hall-portal-join`, `hall-grey-join`, `medieval-portal-wall-wide`, `medieval-wide`); v47c baked `hall-walk`, `medieval-walk`, `grey-walk`, `hall-wide-arch`; live build `docs/evidence/architecture-167/integrated/portal/native-9.png`, `native-10.png`, `browser/1920x1080.png`, `room-transition-185/toward-passage.png`, `toward-after.png`, `floor-selection-186/native.png`; source frames `hall-wide-native-v1/hall-22.50|65.00|177.50.png` (IMG_6344), `survey-2fps/IMG_6380/000030|034|076|198|206|496.jpg`, `evidence/IMG_6380-contact.jpg`, `IMG_6382-contact.jpg`.

## 3. How the Collection Page is really composed (live build)

All paths under `integrate-square-164/`.

1. **Shell to Tenant.** `modules/shell/demo.gd:108-117` registers `"collection": collection_factory`. `MODULES.md` states the Collection Page is composed directly in `demo.gd`, not a module.
2. **Factory.** `demo.gd:51-91`. A `TextureRect` with the frame picture (`:20`, `:57`), and the walk loaded at `demo.gd:65`: `load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()`. `:68-78` fits it to the frame opening (458,521 2110x1412). `:82-90` listens to `walk.detail_changed` and reads `walk._open`. These two names are the whole contract between `demo.gd` and the walk.
3. **Walk setup.** `walk4.gd:142-194`. A `SubViewportContainer` with the GameCube finish (`:152`, `_post` `:199-218`, `gamecube.gdshader`), a `SubViewport` with its own 3D world and 2x MSAA (`:154-158`), rendered about 480 px wide (`:21`, `:160`). Build order `:161-167`: `_build_room`, `_build_paintings`, `_partition_surfaces`, `_merge_static`, capture `_source_meshes`, then `_build_test_room`, `_build_kid`.
4. **Hall geometry.** Origin is the arch door centre; the Hall runs to `z = -26.3` (`:24-32`). Walls `_panel` + `_wall_ps` (`:333-359`, `:374-376`, `:393-407`), cornice and skirting by `_trim_profile` (`:419-475`), vault, skylight, lamps (`:476-605`), benches (`:606-645`, `_bench_cushion` `:671`), floor `_build_floor` (`:803`, 1.9x0.36 boards, `oak-board-atlas-168-v3.webp`, `:884`).
5. **Arch end.** `_arch_end` `:1027-1170`: white casing, crown head, EXIT sign (`:1037-1125`); 0.45 m plaster reveal (`:1126-1132`); modelled stone portal 1.2 m deep, `_portal_stone` `:1247` with relief from `portal-capital-relief.json`; then a **stand-in medieval room** 6 m wide, 5 m deep, 5 m high in slate `#56606b` (`:1136-1161`) on a walkable plank floor (`_portal_floor` `:1173-1234`). Its photo card (`:1163-1170`) is hidden at runtime (`:2336-2359`).
6. **Far end.** `_far_end` `:1722-1916`: plain casing, a 2.6 m cream vestibule with a modelled closed second door at the back (`:1795-1880`, #160).
7. **Paintings.** `_build_paintings` `:1934-1996` from `works.json` + `gaps.json`; frames are `painting_asset.gd` `build_framed` / `build_shaped`; `_place` `:1999-2046` adds wall shadow, lamp pool, caption plate and the pick record `{tag, rec, center, normal, corners, outer}`.
8. **Spaces.** `_space` is `"gallery"`, `"arch"` or `"far"` (`:95`). Triggers `:2755-2758`. `"arch"` is the same world, walked straight into (`_enter_space` `:2222-2227`). `"far"` is a separate plain room built at the same coordinates on render layers 64..1024 (`_build_test_room` `:2194-2216`), entered under a white cover (`:2228-2261`).
9. **Movement.** No physics. `_move_to` `:2264-2273` sweeps the end-wall planes; `_clamp` `:2806-2843` holds one rectangle per space, a 0.4 m half-width doorway rule, and bench push-out.
10. **Camera and cutaway.** `_update_camera` `:2871-2975`: fixed 42 degree / 23 degree FOV / 11 m dollhouse view with Q/E orbit; walls hidden by layer from view direction (`:2927-2938`); layers assigned in `_partition_surfaces` `:2100-2123` (1 floor, 2 west, 4 east, 8 arch end, 16 far end, 32 ceiling); dissolve by `cutaway.gdshader` (`_cutaway_mask` `:2849-2868`).
11. **Lighting.** Zero runtime lights. `_set_lighting` `:2285-2359` instances `baked/room.tscn` (`:2292-2294`) and hides the source meshes (`:2333-2334`). The far space has its own probe capture `baked/white.lmbake` in a second `LightmapGI` (`:2323-2332`); `_update_camera` shows one or the other (`:2875-2877`) and moves the visitor to layer 64 (`:2878`).
12. **Bake recipe.** `bake/prepare.gd`: texel 0.12 m, 0.025 m for trim (`:114`), floor 512x1024 on one continuous world UV2 (`:101`); five omni 0.55 (`:204-213`), one warm spot 6.8 per painting (`:215-228`), daylight 0.35 (`:236`), four door fills (`:247-281`); medium quality, 2 bounces, environment `#dfd6c7` at 0.18 (`:290-305`). It always loads `walk4.gd` by path, so a subclass does not change the Hall bake.
13. **Guards.** `scripts/check-gallery.sh` runs nine rendered harnesses against `walk4.gd`. `world_176_check.gd:10-17` takes the script path as an argument and pins the owner's floor scale and wall texture (`:34-39`).

## 4. What the coordinator's prototype does instead

Paths under `collection-reconstruction/modules/shell/prototype/collection_reconstruction/` (dirty tree).

- `connected_hall.gd:2-13` extends `walk4.gd` and empties `_build_floor`, `_arch_end`, `_far_end`.
- `remodel_room.gd:60-122` `build_connected_hall`: builds that reduced Hall in a scratch viewport, moves it to `(5.55, 0, 28.1)` (`:71`), flattens every layer to 1 (`:80`, `:95`), re-parents the long walls into its own wall bodies (`:86-93`), replaces the benches' collision (`:98-101`), and covers the back of its own portal with a slab and cream architrave (`:102-119`).
- `prepare_remodel.py:493-495` copies `walk4.gd` from the reconstruction branch, which is the stale 1736-line file. That file has no `_portal_stone`, no tufted bench texture, no board atlas floor, no `visitor159` (grep: no matches).
- Base scene `doorway_walk.gd`: a `Node3D` with a `CharacterBody3D` capsule, `StaticBody3D` walls, a fixed 35 degree / 30 degree FOV camera with no orbit, and ray-cast wall hiding. `remodel_presenter.gd` re-creates the page frame and screen shaders by hand.
- Materials are lit `StandardMaterial3D` (`look`, `remodel_room.gd:158-168`), not the Hall's `ps()` shader.
- `remodel_bake.gd:246` saves to `res://modules/shell/prototype/gallery_walk4/baked/room.tscn`; `remodel_room.gd:622` loads it from there. Today that is a path inside the throwaway project. Ported into the repo as written, it overwrites the Hall's production bake.
- Worth keeping: the room graph with shared-opening equality checks and no-overlap checks (`prepare_remodel.py:467-473`), 87 walk trials, per-asset SHA-256 manifest, closed-mesh assertions, the Muse frame assets with `margins_px` that already feed `build_framed`, and honest `*_accepted: false` flags throughout.

Coordinate link: prototype global = Hall-local + `(5.55, 0, 28.1)`, no rotation (`remodel_room.gd:71`).

## 5. Source observations

| Frame | Observed | Consequence |
| --- | --- | --- |
| IMG_6344 65.0 s (`hall-65.00.png`) | Arch end: white rectangular casing with a crown head and green EXIT sign; deep white reveal; round stone arch inside it; grey medieval room lit warm beyond. Veronese left, Vanni right. | Matches live `walk4.gd:1037-1132`. v48b shows a cream architrave on a projecting slab instead. |
| IMG_6344 177.5 s (`hall-177.50.png`) | From down the Hall: a crucified figure, lit, on the medieval room's far wall, on the door axis. Tufted blue benches. Barrel vault and skylight. | Live comment `walk4.gd:80`, `:1137` already records it. The prototype has no crucifix (`grep -i crucifix remodel_room.gd` empty; inventory id `crucified-christ` exists unbuilt). |
| IMG_6344 22.5 s (`hall-22.50.png`) | Far end: white casing, EXIT sign, bright opening. A border of straight boards crosses the floor at the arch doorway. | Far door is a real opening. |
| IMG_6382 6.3 s (contact sheet) | Medieval side of the portal: smooth round voussoirs, clustered shafts, carved capitals, ashlar jambs; open iron grille to its right. | Live `_portal_stone` (`native-9.png`) matches in kind. v48b's portal is a flat texture on a stair-stepped cut-out. |
| IMG_6382 44.0 s | Crucified Christ, outstretched arms, no cross behind, on a grey wall. | Same object as above; placement wall is an inference from 177.5 s. |
| IMG_6380 frames 076, 198 | From the grey gallery: an open panelled door leaf folded into a deep white panelled reveal, and directly through it the blue Hall wall with the shaped angel and neighbours. | Grey gallery adjoins the Hall's far door through a thick wall. Neither the live build's closed second door (#160) nor v48b's zero-depth wall matches. |
| IMG_6380 frames 034, 496 | Grey gallery opens between columns to a stair hall with a white bust on a plinth. | Supports the Ionic opening; stair hall itself is beyond evidence. |
| IMG_6380 frame 206 | Purple wall with the lift "5", black wall opposite, straight boards running along the corridor, view ahead into the Rockefeller room. | Purple connector is a corridor with visible length, not a 2.15 m stub. |

Inferences, not observations: every room dimension in `geometry.json`; the wall the crucifix hangs on; the depth of the far-door reveal; the length of the west gallery.

## 6. Ranked defects in the v47/v48 layout and architecture

1. **The Hall is replaced, not preserved.** `connected_hall.gd` + stale `walk4.gd`. Lost against the live build: the #167 stone portal, the crown-headed white casing and EXIT sign, the #186 floor, the tufted bench (v47c shows a plain navy slab), the #160 vestibule, layer cutaway with dissolve, Q/E orbit, Other wall, click-to-open detail, footsteps. Compare `hall-wide-arch.png` with `architecture-167/integrated/browser/1920x1080.png`.
2. **Bake path collision.** `remodel_bake.gd:246` and `remodel_room.gd:622` use the Hall's own `baked/room.tscn` path.
3. **Portal regression.** `stone_asset("romanesque-portal", ...)` (`remodel_room.gd:852-892`, placed `:908`) is a grid-stepped slab; from the Hall it reads as a jagged silhouette behind a mismatched slab (`hall-portal-join.png`). The source and the live build both show a smooth modelled arch.
4. **Rooms were stretched to make rectangles tile around the Hall.** `prepare_remodel.py:410-425`: west gallery lengthened by 9.25 m to 28.5 m (`:421`), purple connector cut from 4.8 m to 2.15 m (`:424`, against frame 206), medieval room set to exactly the Hall's 10 m width. `loop_fit` records `metric_accepted: false`, `connector_length_accepted: false` (`:464`). The Hall-to-medieval wall is 0.12 m thick; the live build and frame 65.0 s show about 1.65 m (0.45 reveal + 1.2 portal).
5. **Two incompatible walkers.** Physics capsule and ray cutaway versus the Hall's kinematic `_clamp` and layer cutaway. One Tenant cannot host both; annex paintings are not in `_paintings`, so they cannot be clicked.
6. **Lighting is not the Hall's recipe.** Values come from the stale `prepare.gd` (daylight 0.8, omni 0.4, spot 6; live is 0.35, 0.55, 6.8); environment `#cbd4e1` 0.22 versus `#dfd6c7` 0.18; one texel size 0.14 for everything including trim; one 512x1024 floor lightmap over roughly 26.5 x 44.6 m, about half the Hall's floor resolution on each axis (`remodel_bake.gd:35`, `:79`, `:181`, `:200`, `:214`, `:228-229`).
7. **Floor scale.** Prototype parquet is 0.84 x 0.14 (`remodel_room.gd:425-463`); the owner-selected Hall floor is 1.9 x 0.36 and pinned by `world_176_check.gd:34`.
8. **Crucifix missing** on the portal axis (section 5).
9. **Typed text.** `Label3D` "EXIT" and "5" (`remodel_room.gd:344-350`, `:1177-1186`). The live build uses `textures/exit-sign.svg` (`walk4.gd:1120-1125`).

## 7. Integration recipe (minimum, rooted in live files)

Hall files touched: none. `walk4.gd`, `baked/*`, `works.json`, textures, frames, canvases, `bake/prepare.gd`, every `*_check.gd`, the 3D Viewer, and all frozen interface/error/test files stay byte-identical.

**A. One line in the composition root.** `modules/shell/demo.gd:65` loads the new script instead of `walk4.gd`. `_open` and `detail_changed` are inherited, so `:68-90` needs no change.

**B. One new script that extends the live Hall.** `modules/shell/prototype/collection_rooms/rooms_walk.gd`:

```gdscript
extends "res://modules/shell/prototype/gallery_walk4/walk4.gd"
```

`_ready` calls its builders by name, and `connected_hall.gd` already proves overrides of `walk4.gd` builders take effect (v48b renders with them emptied). Override only:

| Override | What it adds | Live pattern it follows |
| --- | --- | --- |
| `_build_test_room()` | `super()` (keeps `_portal_flash`), then builds the rooms under one `Node3D` in `_vp`. It runs after `_merge_static` and after `_source_meshes` is captured (`walk4.gd:164-166`), so the lighting toggle at `:2333-2334` never hides the new meshes. | `:2194-2216` |
| `_clamp(p)` | `super(p)` for `"gallery"` and for the portal passage; otherwise clamp to the union of room rectangles inset 0.55 m, doorway strips 0.4 m half-width, obstacle rectangles pushed out like benches. Data: `rooms[].bounds`, `openings` from the existing `geometry.json`. | `:2806-2843` |
| `_move_to(p)` | Sweep each crossed wall plane so a diagonal step cannot cut a jamb. | `:2267-2272` |
| `_update_camera(k)` | `super(k)`, then wall visibility for the added rooms. | `:2927-2938` |
| `_painting_shown(p)` | True for added paintings in their own space. | `:2431-2437` |

**C. Build with the Hall's own helpers, not `look()`/`solid()`.**

| Need | Reuse |
| --- | --- |
| Walls | `_panel(...)` with `ps(tex, tint, uv, true)`; blue rooms `_wall_ps(tint)` (`:333-376`). The v48 plaster PNGs go in as `tex`. |
| Casings, skirting, plinth, crown | `_trim_profile` with the profile arrays at `:1037-1118`, `ivory-trim.svg` |
| EXIT sign | `exit-sign.svg` panel, `:1120-1125` |
| Frames and shaped works | `PaintingAsset.build_framed` / `build_shaped` with the v48 `*-frame.png` + `margins_px` + untouched museum image |
| Frame shadow, lamp pool, caption plate, pick record | the body of `_place` `:2005-2046` (`_shadow_mat`, `_pool_mat`) |
| Herringbone floor | lattice constants from `_portal_floor` `:1178-1182` so planks line up through the portal; board floors `floor_oak.gdshader` with per-room `floor_z_limits` |
| Benches | `_bench_cushion` `:671` |
| Visitor, contact shadows, steps, finish | inherited (`_build_kid`, `_play`, `_post`) |

**D. Phase 1: north rooms through the far door.** Build the grey gallery, purple corridor and Rockefeller room in the far space: layers 64 (floor, objects), 128, 256, 512, 1024 by wall side, replacing the nine white boxes. The trigger (`:2757-2758`), white cover and return (`:2228-2261`) already exist; `_kid.layers` and the cull mask already switch (`:2878`, `:2937`). Light: a second capture following `_white_capture` exactly (`:2323-2332`, `:2877`), saved as `collection_rooms/baked/north.*`. The Hall renders the same pixels as today. Because this door is a cover transition, the loop does not have to close in metres, so defect 4's stretching can be undone and each room keeps its source-fitted size.

**E. Phase 2: south rooms at the portal.** Place the medieval room's portal wall at Hall-local `z = +1.65` (`zr + PORTAL_DEPTH`, `:1127-1133`), not `z = 0`, and hang the Renaissance room, landing, modern gallery and west gallery off it using prototype global minus `(5.55, 0, 28.1)` plus that 1.65 m. Keep the live portal and portal floor. Hide, do not delete, the stand-in room: four `Surface` nodes in `baked/room.tscn` carry albedo `#56606b`; hide them after `_set_lighting` the way `:2336-2359` hides the door cards. Add the crucifix on the axis wall as its own verified asset.

**F. Bake.** A new `collection_rooms/bake/prepare.gd` modelled on `bake/white_prepare.gd` (filter by layer, own output path). Copy the material conversion and light values from live `bake/prepare.gd:126-236`, not from `remodel_bake.gd`. Never write under `gallery_walk4/baked/`. Not run in this review (no bakes).

**G. Proof the Hall is unchanged.**

```bash
git diff --stat build/v0.1.0 -- modules/shell/prototype/gallery_walk4 modules/sculpture_viewer   # must be empty
sha256sum modules/shell/prototype/gallery_walk4/baked/room.{tscn,exr,lmbake}                     # must equal section 2
godot --rendering-method gl_compatibility --path . \
  --script res://modules/shell/prototype/gallery_walk4/world_176_check.gd \
  -- res://modules/shell/prototype/collection_rooms/rooms_walk.gd                               # owner floor/wall pins under the subclass
scripts/check-gallery.sh && scripts/check.sh && git diff --check
```

Then the same fixed camera pose before and after, looked at side by side (arch end and far end).

## 8. Not verified, and open decisions

- Nothing was executed in Godot. The subclass approach rests on reading `_ready` and on `connected_hall.gd` already working the same way.
- Phase 2 needs the Hall lightmap and a second lightmap active together in the Compatibility renderer. The live build only ever shows one at a time. If two do not work together, the fallback is the Hall's older vertex-colour lighting (`ps(..., true)` with an `_ao`-style callable), which needs no lightmap.
- The stand-in room's walls were light blockers in the Hall bake. Hiding them does not change the saved lightmap, but a wider real room behind the portal will look as lit as the narrow stand-in was.
- With several rooms, a neighbouring room's wall can stand between the camera and the visitor. The Hall's direction rule alone does not handle that; hiding walls of other rooms whose centre lies behind the visitor along the view direction is a proposal, untested.
- The detail view loads `gallery_walk4/detail/<tag>.jpg` (`walk4.gd:2621`). Added paintings need their own path, so `_fit_detail` needs a small override or the added works stay non-clickable in the first pass.
- Far door depth: the live vestibule with a closed second door is contradicted by IMG_6380 frames 076/198, but correcting it changes Hall geometry and its bake. That is the owner's call and a separate Issue; Phase 1 hides the mismatch under the cover.
- `demo.gd` is the composition root and the edit is one path, but #178 says no production integration during charting. Landing step A on `build/v0.1.0` needs Issue scope that names it.
- v47/v48 browser checks, Shell 46/50 and spend figures are the coordinator's reports; not re-run here.
