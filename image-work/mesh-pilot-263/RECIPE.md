# One museum object as a game mesh: the recipe

Worked through once, on Saint Peter 20.254 (8 October 2026). Run from the repository root. Paid steps are marked **paid**; quote before each Flora call. Not yet approved by the owner for a batch.

`S=image-work/mesh-pilot-263`, `D=$S/batch/<accession>`, `B=~/apps/blender-5.2.2/blender-5.2.2-linux-x64/blender` (run it with `LD_LIBRARY_PATH=/usr/lib/wsl/lib`; the system Blender 4.0.2 bakes nothing).

| # | Step | Command | Cost |
| --- | --- | --- | --- |
| 1 | Catalogue photographs and prompts | `~/.local/share/uv/tools/scrapling/bin/python $S/prepare_batch.py <accession>` fetches the chosen views (Micrio source, up to 2400 px) to `~/risd-godot-ingestion/catalogue-masters/<accession>/` and writes `$D/clay-*.prompt.txt`, `$D/flat-*.prompt.txt`, `$D/views.json`. Read the prompts and name the object's parts before using them. | free |
| 2 | Clay views, **paid** | `$S/muse_view.sh $D clay-front <front photo>`; then side, back and three-quarter, each with its photograph (or the clay front, where no photograph exists) and the clay front as the material reference. Look at all four together: one clay tone, one proportion. Stop at six images. | 0.01 USD an image |
| 3 | Mesh, **paid** | Publish front, side, back with `~/promo-lab/tools/tmp_url.sh FILE </dev/null`. Flora, RISD EDU Workspace, `i3d-tripo-h3-1-multiview-i3d`, `image_urls` in the order front, left, back; `{texture:false, pbr:false, geometry_quality:"detailed", face_limit:500000}`. Poll every 15 s or slower. Download once; `tmp_url.sh --rm` each address. | 0.48 USD |
| 4 | Which way it faces | `python3 $S/project_photo.py RAW.glb <front view cut-out> x.png --view-only` prints the turn. | free |
| 5 | Reduce, bake, size | `$B --background --factory-startup --python $S/clay_mesh.py -- RAW.glb LOW.glb --turn <turn> --height H [--width W] [--depth D] --low 10000 --maps 512 --unshaded`. Leave `--unshaded` off if works will be drawn shaded: that adds a normal map and tangents. Width and depth are set to the catalogue's, because a generator invents depth (a Muse sheet once gave 25 cm for a 13 cm relief). | free |
| 6 | Flat colour views, **paid** | `$S/muse_view.sh $D flat-<view> $D/clay-<view>.png <photograph>` four times. Re-run a view that still has shadow, once, with the flat front as its reference. | 0.01 USD an image |
| 7 | Cut and match the colour views | `python3 $S/cut_photo.py $D/flat-<view>.png $D/flat-<view>-cut.png 0,0,0,0 --key-white 14`, then `python3 $S/match_colour.py <catalogue cut-out> $D/flat-front-cut.png -matched $D/flat-*-cut.png` | free |
| 8 | Colour onto the mesh | `$S/colour_mesh2.sh LOW.glb $D OUT.glb <512 under half a metre, else 1024> -cut-matched 0.35 flat` (views cross-faded, unseen texels filled, occlusion from the high mesh at 0.35) | free |
| 9 | Import | Copy `OUT.glb` under `modules/shell/collection_rooms/assets/meshes/<accession>/`, run Godot `--headless --import`, then `$S/import_settings.sh <folder>` (lossy texture, no LODs, no shadow meshes, no tangents), delete that mesh's entries in `.godot/imported/`, import again. Keep the extracted `.jpg` and both `.import` files in git. | free |
| 10 | Lift to the photograph | Render the front with `pilot.tscn ... front out.png unshaded`, then `python3 $S/match_in_scene.py <catalogue cut-out> out.png COLOUR.png COLOUR2.png` and put `COLOUR2.png` in with `set_texture.py`. It matches the lit half of the figure to the lit half of the photograph. | free |
| 11 | Look, then record | `pilot.tscn` at `game`, `front`, `threequarter`, `side`; a row in the folder's `PROVENANCE.md` and in `$S/SPEND.md`. | free |

## What it cost on Saint Peter

| | Measured |
| --- | --- |
| Muse | 0.16 USD for 16 images: 4 clay, 3 clay re-run to match, 4 colour (superseded), 5 flat colour. A clean run is 8 images, 0.08 USD. |
| Mesh | 0.48 USD (Tripo H3.1 Multi-View, 500,000 faces asked, 481,316 made) |
| A clean run | about 0.56 USD an object |
| Pack size, 10,000 triangles, 512 px colour, no normal map, drawn unshaded | 324 KB (mesh 204, colour 120) |
| The same with a 512 px normal map and tangents, drawn shaded | 513 KB |
| Time | the bake 12 s; Blender, colour and import about 5 minutes together; Tripo 12 to 14 minutes from submission on a busy queue. Muse was not timed. |

## Two rules that replace steps

- **Reliefs: one clay view, single-view Tripo.** For a relief slab the mesh comes from the clay front alone (`i3d-tripo-h3-1-i3d`, geometry detailed, texture off, 500,000 faces), with its depth set to the catalogue's or a stated estimate. This is not a skipped step: the museum shows only the front, and when Muse invented a side for Christ in Majesty it drew a figure seated in the round, which gave the mesh a second arm on the wrong side. The input is still the Muse clay view. A slab's silhouette is the same from the back, so its front is set with `TURN=90`.
- **Plain white marble and white porcelain: no colour views.** `PLAIN="0.6 1" finish_object.sh ...` gives one base colour from the brightest third of the catalogue photograph and the baked occlusion, blurred, at 0.6. Projected views streaked these objects; at 0.35 the form vanished when drawn unshaded.

## What is known to go wrong

- **A clay reference can take over.** On the Hand of God, with the clay front attached as a second reference, Muse copied the front for the back and right views twice. Given the photograph of that side alone it drew the right view. On the Angel the same references worked.
- **Views that are not square-on.** The museum's photographs are rarely at 0, 90, 180 and 270 degrees. `finish_object.sh` finds the mesh's front, and with `view:ALL:weight` each colour view's direction, by silhouette in 15 degree steps.

- **Nudes.** Muse refused the fireplace and the River God; Tripo refused Amphitrite. `prepare_batch.py` writes no prompts for flagged objects and puts a fallback in their `views.json`.
- **A view Muse turns.** Asked for a true right side of Saint Peter, Muse gave a three-quarter. Where no photograph of a side or back exists, the view is Muse's invention; most objects here have only a front photograph.
- **Tripo's view order.** Front, left, back, right. "Left" was taken as the object's own left and that worked once.
- **The optical-flow nudge** in `project_photo.py` must be off on a mesh that starts untextured (`colour_mesh2.sh` does this).
- **Godot** stores a texture taken out of a GLB lossless unless told otherwise, and does not write it out again if its `.import` exists without it.
