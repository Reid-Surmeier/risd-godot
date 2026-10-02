# Main-build adapter for the Collection rooms

`modules/shell/prototype/collection_reconstruction/main_build_walk.gd` is one Control script that extends the live `gallery_walk4/walk4.gd` and attaches root's room scene to it. It runs headless in root's v49b project unchanged and in a local full-app copy through the real `demo.gd` path. **Nothing here was rendered**: no GPU, no bake, no browser. What a person sees on screen is root's to check.

The earlier review (`../opus-main-build-review-20261001/REVIEW.md`) is unchanged.

## What was verified, and how

All runs headless (`--headless`, dummy renderer) on scratch copies; root's directories were only read.

| Check | v49b project copy | Local full-app copy |
| --- | --- | --- |
| Adapter attaches the room scene (12 rooms, 46 blocks, 128 cut-away bodies) | pass | pass |
| One camera (walk4's, current), one environment, no second Hall, no physics walker | pass | pass |
| Hall: 23 paintings, 139 baked meshes same mesh/transform/layers as plain walk4, same lightmap data | pass | pass |
| Only the stand-in room is hidden beyond what walk4 hides (Surface006-010); portal Surface004/005 shown | pass | pass |
| Hall floor clip limits unchanged; 1674 added floor meshes inside their shifted limits; none under the Hall; every added room has a floor | pass | pass |
| No added mesh on Hall or test-room layers; no added light can reach them; Hall environment equal | pass | pass |
| `_clamp` equal to plain walk4 at 11,425 points (Hall and stone passage) | 0 differ | 0 differ |
| Four Hall walks stepped side by side with plain walk4: position, camera, cull mask | drift 0.0 | drift 0.0 |
| Loop on walk4's own `_process`, 19 legs | complete | complete |
| Root's 87 walk trials from `geometry.json` | 78 agree | 78 agree |
| App boot through `boot_loader` -> `demo.gd` -> `shell.gd:_create_tenant` -> adapter | n/a | `MAIN_BUILD_ROOMS` printed, 0 `ERROR`, 0 `SCRIPT ERROR` |
| Import | n/a | 0 errors |
| Recipe: 362 Hall files equal to root's snapshot hashes; tracked files changed | n/a | `modules/shell/demo.gd`, `export_presets.cfg` only |

Results: `check-v49b.json`, `check-fullapp.json`, `fullapp-recipe.json`, `fullapp-boot-excerpt.log`.

Negative control: with the room scene moved before it builds (my first version), the same check fails with a room losing its floor (`negative-control-old-ordering.log`). The ordering fix is the comment at `main_build_walk.gd:82-85`.

The 9 trials that disagree are the two deliberate differences, not collisions:

- Far door is a cover transition, so the visitor lands 0.7 m inside rather than on root's target: `grey_grand_out`, `grey_grand_back`, `hall_back_to_grey`, `hall_grey_return`, `loop_27`.
- Ground between the portal's stone sides is walk4's passage: `medieval_between_cases_clear`, `medieval_stairs_aisle_clear`, `loop_15`, `loop_16`.

All 13 "blocked" trials agree.

Hashes at the time of the runs:

```text
879e36ef8b280390  main_build_walk.gd
f3bb24f478233ef7  adapter_check.gd
1723158e02d824fd  make_local_fullapp.py
317b8f3b8dac0f98  main build commit (build/v0.1.0)
```

## How to reproduce

```bash
A=docs/evidence/collection-reconstruction/opus-main-build-adapter-20261001
MAIN=/home/reidsurmeier/orca/workspaces/risd-godot/integrate-square-164
EXT=/home/reidsurmeier/risd-godot-ingestion/collection-expansion/main-build-extension-v49b

# 1. Local full-app copy (new directory; MAIN and EXT are only read)
python3 $A/make_local_fullapp.py $MAIN $EXT \
  modules/shell/prototype/collection_reconstruction/main_build_walk.gd  OUT
godot --headless --path OUT --import

# 2. Headless comparison with plain walk4 (exit 1 on any hard failure)
godot --headless --path OUT --script $PWD/$A/adapter_check.gd -- --out=/abs/result.json

# 3. Real composition path
godot --headless --path OUT --quit-after 600      # expect MAIN_BUILD_ROOMS, no ERROR
```

In root's own extension project no transformation is needed: copy `main_build_walk.gd` to `modules/shell/prototype/collection_reconstruction/` and run step 2 with `--path` on the project. The adapter looks for `res://collection_rooms/remodel_room.tscn`, then `res://remodel_room.tscn`; with neither it behaves exactly as `walk4.gd`.

What the recipe changes, and nothing else:

- `modules/shell/demo.gd`, one line: the walk loader path.
- Room project copied under `collection_rooms/`, because the app already has `assets/` and `web/`. Its scripts' `res://` paths move with it (86 in `remodel_room.gd`, 3 in `doorway_walk.gd`); `res://modules/...` paths are untouched.
- `export_presets.cfg`: room JSON added to the Web include filter, `collection_rooms/evidence/*` excluded. Not exported or tested.
- `docs/`, `image-work/`, `build/`, `repos/` are left out: it is a run copy.

## How the adapter works

| Line | What |
| --- | --- |
| `:46-51` | `_build_test_room` override: parent first, then attach. It runs after walk4 has merged and captured the Hall's meshes, so the lighting toggle never touches the rooms. |
| `:82-85` | Room scene enters the tree **at the origin**, then moves to `(-5.55, 0, -28.1)`. The Hall stays at the world origin. |
| `:86-116` | Room scene's own camera, visitor, body, label, contact shadow, Hall copy and environment are removed; its processing and key input are off. |
| `:117-124` | Added meshes go to two new render layers (2048 portal side, 4096 far-door side). Meshes root's `load_bake` parked on layer 2 are set to 0, because 2 is a Hall wall layer here. |
| `:125-143` | Added floor materials' `floor_z_limits` shift by the attach offset, with an assertion per floor mesh. Only materials under the room scene. |
| `:144-175` | Cut-away bodies and walk blocks from the room scene's `casings`. |
| `:216-230` | Stand-in room hidden by geometry (reaches past the portal front), in baked and unbaked Hall lighting. No names, no file edits. |
| `:233-258` | Spaces. Far door: walk4's own cover, landing in the grey gallery. A doorway between the two room groups: flash and space change in place. |
| `:278-370` | Movement. Hall and stone passage: `super`. Elsewhere: `geometry.json` rooms and openings, wall/door clearances, blocks, floor void; axis slide; clicked points snap into the nearest room. |
| `:373-404` | Camera: parent first; adds the room layer to its cull mask; hides bodies whose box lies between camera and visitor; calls the room scene's own `update_baked_visibility` with walk4's camera. |

No root change is required. An optional patch to skip the Hall copy under the host broke root's `placeholders` variable when I tested it, so I dropped it; the adapter frees the copy instead.

## Gaps, stated plainly

- **Not physical continuity.** The far door, and the Rockefeller door between the two room groups, are white-cover transitions. The loop closes in play, not in metres. I did this on purpose so no room has to be stretched; root's stretched v49b geometry is used as it is.
- **No visual proof.** Layers, cut-away, light isolation and floor clipping are asserted on scene state, not on pixels.
- **Light.** v49b has no room bake, so the rooms are lit by two runtime directional lights restricted to the room layers (draft only; the Hall keeps zero runtime lights by cull mask). Whether the Compatibility renderer honours `light_cull_mask` here needs a rendered Hall before/after. With a room bake, two lightmaps are active at once on the portal side; untested.
- **Cut-away.** Box-against-sight-line, same intent as root's ray test. From a medieval-room pose it hides 1 body looking north and 3 looking south; whether that looks right is unseen. walk4 hides the whole arch-end layer (portal included) in sideways dollhouse views from the portal side; unchanged.
- **Paintings in the added rooms cannot be opened.** walk4's detail view loads `gallery_walk4/detail/<tag>.jpg` (`walk4.gd:2621`).
- **Navigation.** No path planning outside the Hall; a blocked click-walk gives up after walk4's 0.5 s stall. Stairs and the landing void are blocked. The tracery opening is passable only in a 0.63 m band. Clearances (`:31-34`) are tuning values.
- **Original follow view** (authoring comparison) follows without wall avoidance in added rooms.
- **Cost.** The room scene stays unmerged (1674 floor meshes alone). No frame-time measurement.
- **Web export** of the copy untested.
- `scripts/check.sh` step 4 (repo-wide Godot run) was not run in this checkout: it would import the whole repo, and this branch carries the stale `walk4.gd`. Steps 1-2 pass by inspection (no `MODULE.md` added, no cross-module `preload`); `gdlint` is not installed. `git diff --check` is clean.

## For root

1. **Build at the origin, then move.** `retained_hall_room.gd:35-39` tests floors against absolute Hall bounds in scene metres. Any host that positions the scene before `_ready` empties the wrong floors.
2. **Far-end overlap in a single world** (sent earlier): the Hall's vestibule reaches Hall-local z = -28.95 (Surface118-124), 2.65 m into where `geometry.json` puts the grey gallery. The adapter avoids it only because the Hall is not drawn in the far space.
3. **Two root trials contradict root's own portal guards.** `medieval_between_cases_clear` ends at scene (6.85, 29.55) and `medieval_stairs_aisle_clear` starts at (6.85, 29.45); the guard box is x 6.5..7.64, z 28.54..30.31. By arithmetic, not run by me.
4. `load_bake` layer 2 and the world-z floor clip are handled in the adapter; root's standalone project keeps its own handling.
