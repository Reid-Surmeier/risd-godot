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

11. `11-saint-roch-plinth-lowered-footage-and-unbaked.jpg`: Saint Roch's plinth at the filmed
   height, on the lead's decision. Panels: IMG_6383 61.0 s (cropped); unbaked before; unbaked
   after; 18.3 s; unbaked after from about there. A WORK MOVED: Saint Roch (21.398) stands
   0.20 m lower, its base at 0.48 m (was 0.68 m); nothing else about it changed. The cap's top
   is 0.44 m (was 0.64 m) and the hood's top 1.89 m (was 2.09 m).
   The measurement, in 61.0 s: the figure's catalogue height (1.054 m) spans 385 px of the
   enlarged crop, 2.74 mm a pixel at the figure; the plinth's front face, cap edge to floor,
   spans 170 px, 0.44 m after allowing for its being nearer the camera. Cross-check in the same
   frame: the window sill (0.63 m by the earlier source fit) stands clearly above the cap's top,
   as it now does in the build. Uncertainty +-5 cm: the frame is motion-blurred.
   `architecture_check.gd` changed with it: the figure's pinned height 0.68 -> 0.48 m and the
   lid's 2.09 -> 1.89 m. Pictures 6 and 9 show the case before this.

12. `12-medieval-angel-head-pedestals-labels-footage-and-unbaked.jpg`: the dark medieval room's
   two octagonal pedestals and its label cards. Pairs, footage then unbaked: IMG_6382 60.5 s
   (the Angel), 30.0 s (the Head). NO WORK MOVED: both pedestal tops measured at the build's
   height, within the error.
   - The Angel's pedestal, 60.5 s, ruler the figure's catalogue height (1.524 m, carved base
     included). Height: floor, pedestal top and figure top on the pedestal's axis, corrected for
     the camera's downward tilt (the verticals' vanishing point, about 6500 px down the frame),
     give 0.68 m; the front edge alone gives 0.61 to 0.67 m. So 0.65 +-0.07 m against the build's
     0.69 m: kept. Width: 0.50 m across the flats where the build had 0.61 m, so the radius is
     now 0.27 m (was 0.33 m). That is what made it read squat. Its head band is 12 cm (was 8)
     and the base band of both octagons 15 cm (was 10), as the frame's pale edge lines divide it.
   - The Head's pedestal, 30.0 and 31.5 s, ruler the head's catalogue height (0.813 m). The cap
     is 0.93 of the shaft's width and about 13 cm high: radius 0.28 m (was 0.24 m), height kept
     at 0.14 m, a 2 cm step. The shaft is 0.57 m across in the frame (build 0.55 to 0.60 m) and
     the whole pedestal about 1.5 m (31.5 s; its foot is out of frame in 30.0 s): both kept.
   - Label cards: upright, 0.16 x 0.27 m (they were 0.30 x 0.17 m lying on their side), and the
     filmed colour. Measured, not judged by eye: in 30.0 s the card's plain field is 0.79, 0.74,
     0.75 (red, green, blue, linear) of the pedestal face beside it, which is the pedestal's
     grey a quarter darker and slightly mauve, `605e64`. It looks darker than that in the frame
     because the white lettering sits on it; a first reading as "dark maroon" was that effect.
     The two bars are pale, where the lettering is. The Head's card moved up to sit 2 cm under
     the shaft's top, as filmed. The card lying on the crucifix platform keeps its shape and
     takes the colour; no frame I opened shows it.
   Guessed: the camera's lens (the tilt correction assumes straight lines stay straight); the
   cards on Saint Peter's and the relief's pedestals are placed as before (0.82 m centre).

13. `13-wall-case-risers-footage-and-unbaked.jpg`: the riser inside the four Renaissance wall
   cases. Pairs, footage then unbaked: IMG_6383 44.0 s (east case A), 24.6 s (the Pietà case),
   30.2 s (the triptych case). In the footage the works do not stand on the hood's floor: they
   stand on a white block inside the hood whose sloped front is the label face. The kit's
   wedge-shaped rail is now that block: `wall_case_fittings()` builds it 10 cm high, back to the
   board, its front sloping down over 9 cm to the deck's front edge.
   WORKS MOVED, each straight up by 0.10 m with its floor, nothing else changed:
   - east case A: the diptych (22.201), the book cover (34.016), the emblem (2023.17) and the
     albarello (35.713), base 1.08 -> 1.18 m;
   - east case B: the roundel (51.105) 1.14 -> 1.24 m, the glass (2017.29) 1.20 -> 1.30 m, the
     plaque (34.024) 1.15 -> 1.25 m, and the two small mounts under the roundel and plaque;
   - the triptych (2021.131), base 1.08 -> 1.18 m;
   - the Pietà (59.128), base 1.08 -> 1.18 m.
   Not moved: the two portraits in case A and the two plates in case B, which hang on the back
   board (in 44.0 s the woman's portrait hangs clear of the riser, its foot level with the
   albarello's rim, which is nearer the build after the move than before).
   The measurement, 24.6 s: a camera fit on the Pietà riser's three edges (back, front top,
   foot of the slope), which shorten with distance as 436 : 600 : 640 px, with the riser's
   width (0.575 m, from the Pietà's catalogue width on it) as the ruler and the phone's lens
   taken as 1536 px. It gives the camera 0.53 m above the riser's top, the slope 10.6 cm up over
   9.0 cm, and the Pietà's front 0.18 m from the board (its catalogue depth is 0.13 m, so the
   fit holds together). East case A agrees: its label face reads 0.14 m tall seen from above,
   against the albarello's 0.241 m. Uncertainty +-2 cm.
   ALSO CHANGED, the Pietà's hood: 0.89 m tall (top 1.97 m; it was 0.70 m, top 1.78 m). The same
   fit puts the hood's top 0.78 m above the riser, a third of a metre clear above the figure;
   with the figure raised the old hood left 14 cm. The triptych's hood needed nothing (8 cm clear
   above the gable, as filmed), nor the east cases'.
   `architecture_check.gd`: the Pietà's pinned height 1.08 -> 1.18 m. Nothing else in it.
   Seen and left: the filmed riser top of the Pietà case is about 0.42 m deep, so that case is
   deeper than the build's 0.38 m; and the east cases' and the triptych's hood heights were not
   measured.

14. `14-european-floor-cases-footage-and-unbaked.jpg`: the European gallery's floor cases.
   Pairs, footage then unbaked: IMG_6385 33.0 s (the silver case), IMG_6386 7.0 s (the majolica
   case), IMG_6384 40.0 s (the River God's case). In every one the hood stands on the base and
   the works stand higher, on a white riser sloped down to the hood's foot all round. Before:
   plain boxes, two of them grey, the works on the cap, bare glass. Now the east file's
   `display_case()` builds each of its four cases (silver, cabinet, majolica, River God) as the
   kit's `plinth()` (white, recessed kick), its cap, the kit's `hood_edges()`, and the kit's new
   `case_riser()`, which is Saint Roch's riser taken out of `hooded_floor_case()` so both use it.
   NO WORK MOVED: every object stands at the height it had; the cap and the hood's foot are the
   riser's 8 cm lower instead (bases 0.81, 0.76 and 0.96 m to the cap's top, were 0.89, 0.84,
   1.04 m). The pedestal case under the embroidered panel on the west wall (IMG_6386 26.5 s)
   takes the same three pieces the same way; it is not in the picture.
   Guessed: the riser's 8 cm (by eye; the filmed ones look nearer 10 to 15 cm, the River God's
   tallest), that the cabinet case's base is white (41.2/42.5 s show it pale, far off), and the
   kick (a dark line at the floor in 33.0 and 41.2 s). The River God's pedestal has a stepped
   cap in 40.0 s; the build's is one slab. Not done: the dress case's dark frame edges, the
   shelf case on the north wall, the tabernacle's pedestal (another agent's line).
15. `15-european-platforms-and-bench-footage-and-unbaked.jpg`: pairs, footage then unbaked:
   IMG_6386 67.5 s (the long east platform, the display panel and the commode; the unbaked view
   is past the silver case's glass), IMG_6385 3.5 s (the low platform in the north-west corner),
   IMG_6386 42.5 s (the bench). Both platforms are the kit's `plinth()` now, same footprint and
   height (1.3 x 0.14 m by 4.9 m of the real room; 1.05 x 0.13 x 2.65 m). The label block on
   the east platform is the kit's `label_stand()`. The bench keeps its black slab and four legs
   and gains the rail on the floor that joins each pair, as filmed; the kit's `bench()` is the
   tufted kind and is not used here. The display panel is unchanged: 67.5 s shows it as a plain
   white full-height slab, as built.
   Guessed: the platforms' kick (no frame shows their foot closely), that the east platform's
   label is a folded stand (no frame I opened shows it), the bench's legs (the filmed ones are
   thinner bars than the build's 5 cm).

16. `16-grey-gallery-rodin-plinth-footage-and-unbaked.jpg`: the plinth under Rodin's Hand of God
   in the grey French gallery. Panels: IMG_6380 16.5 s (cropped; the only frame I found that
   shows the plinth, at the picture's edge and motion-blurred), then the unbaked plinth from
   two places. The filmed plinth is a white block on a projecting base, the base about a third
   of its height. The build's was a plain block; it now has that base band (16 cm high, 3 cm
   proud). NO WORK MOVED: the plinth's top stays at 0.50 m and its footprint at 1.0 m square.
   Its blank label card moved up 15 cm to clear the band.
   Not measured: the plinth's height and width. The frame cuts the marble off, so there is no
   ruler in it; IMG_6381 31.5 and 90.5 s show the plinth whole but a few pixels tall. The room
   has no bench or case in its source, and none in the frames I opened (16.5, 37.5 s).
   IMG_6381 plays upside down, like IMG_6382.

The clips are in `~/risd-godot-ingestion/collection-expansion/verified/` (the copies one folder
up are empty or cut short). `IMG_6382.MOV` plays upside down: add `,hflip,vflip` to the filter.

## State for whoever continues

- Done in the Renaissance room: the bench, the four wall cases, the hooded floor case and its
  proportions, the textile platform with its label stands, the window (pictures 1 to 9).
- Saint Roch's plinth is lowered to the filmed 0.44 m and the figure with it (picture 11).
- The four wall cases' works stand on a 10 cm riser with the sloped label face (picture 13).
- Done in the dark medieval room: the two glass cases and the octagonal pedestals (picture 10),
  their filmed proportions and the label cards (picture 12).
- Done in the European gallery: the four floor cases and the west pedestal case (picture 14),
  both platforms, the label stand and the bench (picture 15).
- Done in the grey French gallery: the base band of Rodin's plinth (picture 16).
- Not done: Rockefeller.

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
`2.82,1.32,-1.89:3.39,.82,-.12`; picture 11: `renaissance_west_blind`
`3.9,-.35,.3:.3,-.35,0:55` and `saint_roch_installation` `1.4,1.3,1.0:0,.85,0`. picture 16, `grey_rodin_plinth`: `-1.5,1.3,.7:.2,.25,0` and `-1.6,.5,1.5:0,.1,0:55`; pictures 14 and 15: `european_east_case=silver` `-1.4,.9,-1.4:0,.42,0` and (the north-west
platform) `.9,1.25,-3.4:-1.4,.2,-6.2`, `european_east_case=majolica` `-1.0,.9,1.7:0,.42,.3`,
`european_east_case=river-god` `-1.3,1.1,1.3:0,.5,0`, `european_east_platform`
`-3.6,1.5,3.4:0,.6,-.4`, `european_east_bench` `.9,1.1,2.5:0,-.25,0`; picture 13: `renaissance_wall_case=A` `-1.05,.65,.12:0,.25,.30`, `pieta_wall_case`
`1.0,.65,.05:0,.22,0`, `triptych_wall_case` `.05,.65,1.2:0,.28,0`; picture 12, `medieval_crucifix_platform`: `-3.2,1.6,-1.9:-4.78,.9,-.98` and
`3.6,1.45,-1.6:3.39,1.25,-.12`. A blank or flat picture means the camera is inside a wall: change the
offset's sign. The draft draws every room at once and lights nothing by the bake, so it shows
shape, not the final light or which room the game would draw. If a shot fails with "Cannot open
file res://.godot/imported/...", another draft run is rebuilding the same folder: wait and repeat.
