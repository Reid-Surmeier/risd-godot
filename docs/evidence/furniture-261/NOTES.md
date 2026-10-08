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

6. `6-hooded-floor-case-footage-and-unbaked.jpg`: the hooded floor case (Saint Roch). Footage
   IMG_6383 18.3 s and 20.0 s, each followed by the unbaked case from about the same place; the
   last panel is the foot of the plinth from 0.35 m up. Before: a box with a wider foot and cap,
   a label on the cap's side, bare glass. Now `hooded_floor_case()`: a plinth on a recessed
   kick, a cap slab that oversails it by 4 cm, the hood standing on the cap inside its edge with
   pale edge lines (here the edges read bright, against the grey wall), and inside the hood a
   riser with sloped sides, the blank label block on its front slope (20.0/21.0 s). The figure,
   its height (0.68 m) and the hood's top (2.09 m) did not move.
   Guessed: the kick. No frame shows the plinth's foot closely; 18.3 s shows a thin dark line
   where it meets the floor, built as a 2 cm recess. The riser's slope (10 cm out, 4 cm up) is
   by eye from 20.0/21.0 s.

7. `7-textile-platform-and-label-stands-footage-and-unbaked.jpg`: the textile platform on the
   south wall. Pairs, footage then unbaked: IMG_6383 7.0 s (the velvet's stand at the platform's
   east end), 10.0 s (the tapestry's stand, seen along the wall), 60.6 s (the platform's whole
   length). The footage's label blocks are not blocks: each is a folded white sheet, two cheeks
   carrying a plate that slopes down toward the reader, open underneath. Before: a small white
   box with a flat card on top, centred under each textile. Now `label_stand()`, with a blank
   label block on the plate (no text), and the platform is the kit's `plinth()`: the same
   footprint and height (4.30 x 0.16 x 0.95 m) on a recessed kick.
   Guessed: the stand's size (0.38 wide, 0.20 high at the front, 0.34 at the back), scaled
   against the platform's 16 cm face in 7.0 and 10.0 s, which disagree by a few centimetres;
   where the tapestry's stand sits along the platform (the velvet's is 12 cm in from the east
   end, read from 7.0 s); the platform's kick (a thin dark line at the floor in 7.0 s).

8. `8-window-footage-and-unbaked.jpg`: the west window. Footage IMG_6383 61.0 s (cropped) and
   17.0 s, each followed by the unbaked window from about the same place; the last panel is the
   sill's corner from close. Before: a white slab on the wall over a white block. Now
   `shaded_window()`: the trim kit's casing (its doorway section, 10 cm wide, standing on the
   sill), a shallow reveal, a drawn shade with faint folds, daylight as pale blue strips down
   both sides and under the head box, and a sill of a projecting stool over an apron. The
   shade's and the sill's heights are the earlier source fit (0.63 to 3.00 m, 0.51 to 0.63 m;
   the check holds them) and the opening is still 1.25 m wide.
   Not as filmed: the reveal. The wall is not cut, so the reveal is 3.5 cm of frame standing on
   the wall's face and the casing stands 7 cm off the wall; in the footage the reveal goes into
   the wall and the casing lies nearly flat on it.
   Choices to judge in the bake: the shade and the strips keep their own brightness (unshaded),
   because in every frame the window is the brightest thing on that wall; if the baked room
   makes that too strong, `cloth` in `shaded_window()` is the one colour to lower.
   Guessed: the strips' width (6 cm; the footage's are blurred by glare), the fold spacing
   (28 cm), the stool's projection (4 cm past the casing). `door_casing()` gained a `base`
   argument (default 0, doors unchanged) so a casing can start on a sill.
   Seen while here, not mine to change: the Madonna hangs about 10 cm from the casing; in
   61.0 s the gap is nearer half the window's width.

9. `9-floor-case-proportions-footage-and-unbaked.jpg`: the room's pedestals. A listing of
   everything standing on this room's floor in the draft gives the four wall cases, the bench,
   the textile platform and Saint Roch's case: his plinth is the room's only pedestal. Panels:
   IMG_6383 61.0 s (cropped); the unbaked case before this step; after it; 20.0 s; the unbaked
   cap and riser after it. Measured in 61.0 s with the figure's catalogue height (1.054 m) as
   the ruler: the cap is about 1.0 m wide and the body about 0.83 m, so the cap oversails the
   body by about 9 cm a side; the build had a 0.78 m cap on a 0.70 m body. The hood is now
   0.86 m square (was 0.70), the cap 0.98, the body 0.80. The picture pairs with picture 6,
   which was taken before the widening.
   NOT matched, and left for the lead: the plinth's height. The same frame puts the cap's top
   at about 0.44 m, well under the window sill (0.63 m); the build's is 0.64 m, level with the
   sill. Lowering it means lowering the figure by 0.20 m and the hood with it, and changing the
   check, which pins the figure at 0.68 m and the lid at 2.09 m. The figure was not moved.
   No base moulding was added: the frames show a plain body under an oversailing cap. The kick
   stays a guess (see 6).

10. `10-medieval-cases-and-pedestals-footage-and-unbaked.jpg`: the dark medieval room. Pairs,
   footage then unbaked: IMG_6382 79.0 s (the two glass cases), 60.5 s (the angel's octagonal
   pedestal), 30.0 s (the head's). In this room the filmed base detail is a projecting band at
   the floor, not a recessed kick, so `plinth()` is not used here. The two glass cases take the
   kit's `hood_edges()` (split out of `hooded_floor_case()`), a base band 10 cm high standing
   2 cm proud, and the pedestals' slate grey (they were a neutral dark grey). The octagonal
   pedestals take a base band, and the angel's a band round its head (60.5 s). The two
   rectangular pedestals already had a foot and a narrower cap and are unchanged.
   Not done here: the labels (the footage's are dark maroon cards; the build's are the finish
   spec's off-white cards), the crucifix platform (a plain low white box in 46.0/49.0 s, as
   built), the iron grille's platform. The unbaked greys read darker than the footage because
   the draft has no light on them.

The clips are in `~/risd-godot-ingestion/collection-expansion/verified/` (the copies one folder
up are empty or cut short). `IMG_6382.MOV` plays upside down: add `,hflip,vflip` to the filter.

## State for whoever continues

- Done in the Renaissance room: the bench, the four wall cases, the hooded floor case and its
  proportions, the textile platform with its label stands, the window (pictures 1 to 9).
- Open, the lead's decision: lowering Saint Roch's plinth from 0.64 to about 0.44 m (see 9).
- Done in the dark medieval room: the two glass cases and the octagonal pedestals (picture 10).
- Not done: the European gallery (`european_east_additions.gd`, `european_west_additions.gd`;
  footage IMG_6384, 6385, 6386). Its platforms and case bases are the white kind: start from
  `plinth()`, `hood_edges()` and `label_stand()`, after reading the footage for each piece.

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
`.05,.42,1.3:0,.36,0`; picture 6, `saint_roch_installation`: `1.3,1.2,.9:0,.75,0`,
`1.15,1.25,.15:0,.35,0`, `1.5,.05,.8:0,-.1,0:50`; picture 7, `renaissance_textile_platform`:
`1.75,1.55,-2.3:1.75,.55,0`, `1.0,1.4,-1.2:-.7,.75,.25`, `2.6,1.3,-1.6:-.6,.2,-.2`; picture 8,
`renaissance_west_blind`: `3.9,-.35,.3:.3,-.35,0:55`, `1.5,-.25,2.1:0,-.75,.2`,
`.9,-.9,.95:0,-1.2,.62:45`; picture 10, `medieval_crucifix_platform` (the nearest piece
with a key): `-2.6,1.5,-3.6:1.6,.5,-1.9`, `-3.5,1.3,-2.6:-4.78,.75,-.98`,
`2.82,1.32,-1.89:3.39,.82,-.12`. A blank or flat picture means the camera is inside a wall: change the
offset's sign. The draft draws every room at once and lights nothing by the bake, so it shows
shape, not the final light or which room the game would draw. If a shot fails with "Cannot open
file res://.godot/imported/...", another draft run is rebuilding the same folder: wait and repeat.
