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

4. `4-wall-case-edges-and-labels-footage-and-unbaked.jpg`: the four wall cases after the lead's
   notes. Pairs, footage then unbaked: east case A (IMG_6383 44.0 s), the Pietà case (24.6 s),
   the triptych case (30.2 s).
   - Hood edges. In all three frames the hood's top edges read as narrow dark slate lines against
     the white board, and the upright edges as thinner grey ones; none is a bright line. So all
     four cases now take the same edges from `wall_case_fittings()`: four dark top rails 8 mm
     thick, eight mid grey-green lines 4 mm thick (they were 7 mm and near white).
   - Pietà and triptych hoods: dark top rails, kept. Settled by 24.6 s (a dark bar across the
     hood's top front edge, grey uprights) and 30.2 s (dark top front and rear edges, dark
     uprights). 17.0 s shows the Pietà case too small and blurred to settle anything. 44.0 s
     shows the east cases have the same dark top edges, so they are now built the same way.
   - The check: `architecture_check.gd` counted the Pietà and triptych rails (8). The kit now
     makes the top rails of all four cases, so the check expects 16 and accepts a rail owned by
     any of the four cases. That is the only change to the check.
   - Labels. The grey blocks were on the body's front face in all four cases. They now lie on
     the sloped rail inside the hood, as filmed; the Pietà and triptych cases take the rail too
     (24.6/30.2 s show a label on a sloped white face in front of the work). Blocks only, no text.

   Guessed, not measured: the rail's slope (1 in 2) and depth (14 cm, less in the shallow Pietà
   case so it clears the work); in the footage the rail's face is taller and the works stand on a
   raised floor behind it. The works were not moved, so the floor was not raised.
5. `5-wall-case-floor-strips-footage-and-unbaked.jpg`: the floor under the wall cases. Footage
   IMG_6383 62.0 s (cropped): under the Pietà and triptych cases a thin brown rectangle on the
   boards, darker than the oak. Unbaked: the same corner from 0.9 m up, and east case A from
   0.5 m up. The strips were white rails 3 cm high; they are now flat brown strips 2 cm wide
   round the case's footprint. Guessed: that the strip is flat (it could be a low rail), its
   exact colour (the frame is motion-blurred), and that the east cases have one (no frame I
   opened shows the floor under them; the census says all four do).

The clip is at `~/risd-godot-ingestion/collection-expansion/verified/IMG_6383.MOV`.

## State for whoever continues

- Done: the bench, the four wall cases (pictures 1 to 5).
- Not done: the hooded floor case (Saint Roch), the textile platform with its label blocks, the
  window reveal and shade, the pedestals.

## How the unbaked pictures are taken

A draft room project is made once (it waits on the host's rebuild lock) and then reused:

```bash
source ~/promo-lab/gpu-env.sh; export DISPLAY=:99
ROOMS_TRIAL=$HOME/risd-godot-ingestion/collection-expansion/rebuild-trim273 timeout 40m scripts/rebuild_rooms.sh --draft
EXT=$HOME/risd-godot-ingestion/collection-expansion/rebuild-trim273/extension
```

After each edit to `remodel_room.gd`, copy it into that project with the two text changes the
generator's extension step makes, instead of rebuilding:

```bash
python3 - <<'EOF'
from pathlib import Path
import os
src = Path('modules/shell/prototype/collection_reconstruction/remodel_room.gd').read_text()
src = src.replace('if not visitor.is_ancestor_of(surface):',
                  'if not visitor.is_ancestor_of(surface) and not surface.has_meta("retained_main_hall"):')
src = src.replace('res://modules/shell/prototype/gallery_walk4/baked/', 'res://addition_baked/')
Path(os.path.expanduser('~/risd-godot-ingestion/collection-expansion/rebuild-trim273/extension/remodel_room.gd')).write_text(src)
EOF
```

(An edited `*_additions.gd` is copied across unchanged.) Then check and photograph:

```bash
godot --headless --path $EXT --script $PWD/modules/shell/prototype/collection_reconstruction/architecture_check.gd
godot --path $EXT --display-driver x11 --rendering-method gl_compatibility \
  --script $PWD/docs/evidence/furniture-261/draft_shot.gd -- \
  renaissance_wall_case=A "/tmp/a.png:-1.05,.42,.12:0,.40,.30"
```

`draft_shot.gd` finds the piece by a metadata key (`furniture=bench`, `renaissance_wall_case=A`,
`pieta_wall_case`, `triptych_wall_case`, `saint_roch_installation`,
`renaissance_textile_platform`, `renaissance_west_blind`) and takes one picture per shot argument:
`<out.png>:<camera offset>:<aim offset>[:<fov>[:<width>x<height>]]`, offsets in metres from the
piece's origin in the room's axes (x east, y up, z south). It stops the room's physics process
(which would cut walls away), shows every node and hides the on-screen help. Default 540 x 960,
upright like the footage, 70 degrees. The shots in pictures 4 and 5:
east case A `-1.05,.42,.12:0,.40,.30` and low `-1.7,-.55,1.0:0,-.62,0`; Pietà case
`1.0,.40,.12:0,.25,0` and the corner `2.3,-.1,1.4:.4,-.5,-.7:60`; triptych case
`.05,.42,1.3:0,.36,0`. A blank or flat picture means the camera is inside a wall: change the
offset's sign. The draft draws every room at once and lights nothing by the bake, so it shows
shape, not the final light or which room the game would draw. If a shot fails with "Cannot open
file res://.godot/imported/...", another draft run is rebuilding the same folder: wait and repeat.
