# Renaissance room furniture (#261): evidence

Each picture: the footage frame on the left, the piece unbaked in the draft room project beside
it. Unbaked means the draft's own flat light; the baked look is judged from the integration build.

1. `1-bench-footage-and-unbaked.jpg`: the central bench. Footage IMG_6383 62.5 s: a grey tufted
   seat on a dark wooden frame. Before: a black slab on four square posts. Now `bench()` in the
   room generator: one upholstered surface a third of the bench's height, with a rounded rim, its
   fabric side showing and stitched tufts (3 by 2, as filmed), on a dark brown base rail carried
   by four stout square legs. Its length, width and place are unchanged (1.65 x 0.55 m, by eye
   from the earlier build; not measured).
2. `2-wall-case-footage-and-unbaked.jpg`: Renaissance east wall case A. Footage IMG_6383 44.0 s:
   a white body with a recessed lower step, a sloped label rail inside a clear hood whose
   polished edges read as bright lines. Before: a thin slab under a glass box with four black
   wire edges on top. Now `wall_case_fittings()` adds, to the deck, board and hood that were
   there: bright edge lines on all twelve hood edges, the lower step, the label rail, and the
   thin frame on the floor under the case. Both east cases use it; the works did not move.
   Not yet done: the Pietà and triptych wall cases, the hooded floor case, the textile platform,
   the window, the pedestals.
3. `3-pieta-triptych-cases-footage-and-unbaked.jpg`: the Pietà case (west wall) and the triptych
   case (north wall). Footage IMG_6383 17.0 s shows the Pietà case small, behind Saint Roch: a
   white stepped body under a clear hood. Both cases keep the dark top rails and the label the
   earlier builder read from the footage (IMG_6383 24.6/30.2 s) and take the kit's lower step
   and floor frame only. The floor frames are below this picture's edge and were not seen.
   Not yet done: the hooded floor case, the textile platform, the window, the pedestals.

## State for whoever continues (written at the tip, `bbad8bd2` plus this note)

- The lead's two bench corrections (a cushion a third of the bench's height; stout dark-brown
  square legs under a base rail) are IN, at commit `2265a6b7`. They are not in `25d271c2`.
- Commits after `c289856c` on this branch: `2265a6b7` bench corrections, `f2536345` Pietà and
  triptych cases, `bbad8bd2` a recut evidence picture. Start from the tip, not from `c289856c`.
- Open notes from the lead on the wall case: the hood's edge lines are a little heavy and bright
  against the footage's thin greenish edges (`edge_light` colour and `t` in
  `wall_case_fittings()`); the label blocks should sit on the sloped rail inside the hood, not
  on the body's front face (those grey rectangles are the earlier builder's, in
  `build_renaissance_east_cases()`).
- Not done: the hooded floor case (Saint Roch), the textile platform with its label blocks, the
  window reveal and shade, the pedestals.

## How the unbaked pictures are taken

No bake and no wait on the rebuild lock. A draft room project is made once and then reused:

```bash
ROOMS_TRIAL=$HOME/risd-godot-ingestion/collection-expansion/rebuild-trim273 scripts/rebuild_rooms.sh --draft
EXT=$HOME/risd-godot-ingestion/collection-expansion/rebuild-trim273/extension
```

After each edit to `remodel_room.gd`, copy it into that project with the two text changes the
generator's extension step makes, instead of rebuilding:

```bash
python3 - <<'PY'
from pathlib import Path
import os
src = Path('modules/shell/prototype/collection_reconstruction/remodel_room.gd').read_text()
src = src.replace('if not visitor.is_ancestor_of(surface):',
                  'if not visitor.is_ancestor_of(surface) and not surface.has_meta("retained_main_hall"):')
src = src.replace('res://modules/shell/prototype/gallery_walk4/baked/', 'res://addition_baked/')
Path(os.path.expanduser('~/risd-godot-ingestion/collection-expansion/rebuild-trim273/extension/remodel_room.gd')).write_text(src)
PY
```

(An edited `*_additions.gd` is copied across unchanged.) Then check and photograph:

```bash
godot --headless --path $EXT --script $PWD/modules/shell/prototype/collection_reconstruction/architecture_check.gd
source ~/promo-lab/gpu-env.sh; export DISPLAY=:99
godot --path $EXT --display-driver x11 --rendering-method gl_compatibility \
  --script $PWD/docs/evidence/furniture-261/draft_shot.gd -- <out dir> bench
```

The camera trick, in `draft_shot.gd`: instantiate `res://remodel_room.tscn`, wait ten frames,
stop its physics process (which would otherwise cut walls away), make every node visible, find
the piece by a metadata key (`furniture` = `bench`; use `renaissance_wall_case` = `A` or
`has_meta("pieta_wall_case")` for the cases), then set `scene.camera.global_transform` to an
offset from the piece looking at it, wait four frames and save `root.get_texture()`. A blank or
flat picture means the offset put the camera inside a wall: change its sign. The draft draws
every room at once and lights nothing by the bake, so it shows shape, not the final light or
which room the game would draw.
