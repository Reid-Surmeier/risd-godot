# Mesh pilot (#263): provenance

Prototype. Two museum objects as Flora Trellis meshes, shown in a standalone scene (`pilot.tscn`) with the rooms' light, camera and display. Nothing here is placed in a room.

## The meshes

| File | Object | Made from | Triangles | Texture | File | Imported (mesh + texture) | sha256 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `fireplace-83152.glb` | Hugnet Frères, *Fireplace Surround*, 1900, RISD 83.152, 349.8 × 210.8 × 50.8 cm | Trellis run 1 (`mesh_simplify` 0.98) | 6,175 | 1024 px | 309 KB | 212 KB (111 + 102) | `a8cee9433673e254…` |
| `fireplace-83152-detail.glb` | the same | Trellis run 3 (`mesh_simplify` 0.90) | 26,141 | 1024 px (made at 2048) | 926 KB | 523 KB (404 + 119) | `1463d4fe259b5337…` |
| `neptune-2017-74-31-1.glb` | Vincennes, *Neptune as River Deity*, 1745–1750, RISD 2017.74.31.1, 29.8 × 27 × 24 cm | Trellis run 2 (`mesh_simplify` 0.98) | 19,312 | 1024 px | 730 KB | 461 KB (327 + 134) | `a4228ad57a8b44bf…` |
| not in git | the same | Trellis run 4 (`mesh_simplify` 0.90, 25 structure steps) | 100,639 | 1024 px | 3.49 MB | 1.58 MB (1,433 + 151) | `d89aa1a9146f8ceb…` |

"Imported" is what Godot 4.7.2 writes to `.godot/imported/` with the settings in the `.import` files here: texture lossy at 0.8 (the repository's setting for catalogue photographs), no tangents, no LODs, no shadow meshes. At Godot's defaults the first row is 1.27 MB, because a texture taken out of a GLB is stored lossless.

Each `.json` beside a GLB is the clean-up script's own record: source hash, steps, and what it read back from the file.

## Sources

Both are the museum's catalogue photographs already in the repository (`modules/shell/collection_rooms/assets/additions/`, see the `SOURCES.md` there): `marble-hall/fireplace-83.152.jpg` and `rockefeller/neptune-2017.74.31.1.jpg`. No video frame was used as a source.

Neptune was chosen over the three medieval figures because its photograph is a studio shot on plain grey from a three-quarter angle, which shows depth; it is the object on the white plinth in the owner's screenshot.

## Paid calls

| # | Provider, model | Input (sha256) | Quote | Charged | Output (sha256) |
| --- | --- | --- | --- | --- | --- |
| 1 | OpenRouter, `meta/muse-image`, isolate the fireplace on white | padded photograph `fd501c265db2155f…`, prompt `image-work/mesh-pilot-263/fireplace/edit-prompt.txt` `6846e2743b26c497…` | 0.01 USD ceiling | not confirmed: refused, HTTP 400; the pipeline marks the run `possibly_spent` (`run-4704175fd67b53c99cbca470`) | none |
| 2 | Flora, `i3d-trellis`, texture 1024, simplify 0.98 | `image-work/mesh-pilot-263/fireplace/trellis-input.png` `0dcb3d1646687fee…` | 0.024 USD | 0.024 USD | `run_m176nxjs4w5vbbn7w1wx6js3px8fx0je`, GLB `ceedef0ceb7e070e…` |
| 3 | Flora, `i3d-trellis`, texture 1024, simplify 0.98 | `image-work/mesh-pilot-263/neptune/trellis-input.png` `b8e902321c99bd69…` | 0.024 USD | 0.024 USD | `run_m179ny9wszxg2t3z2m1rvyamwx8fx5jh`, GLB `2228ee33ed90aec7…` |
| 4 | Flora, `i3d-trellis`, texture 2048, simplify 0.90 | the fireplace input again | 0.024 USD | 0.024 USD | `run_m171f7pcpv6672swcakdwha8p18fx36p`, GLB `a5a7a142c1902de7…` |
| 5 | Flora, `i3d-trellis`, texture 1024, simplify 0.90, 25 structure steps | the Neptune input again | 0.024 USD | 0.024 USD | `run_m173ntdbr9fdy66tqx3yjzdsjh8fxd4e`, GLB `eb2d9e66b2a4e5df…` |

Flora balance (personal workspace): 0.30 USD before, 0.204 USD after. Total charged by Flora: 0.096 USD. Flora project: "risd-godot mesh pilot 263". The raw Trellis GLBs are not in git; Flora keeps them under the run ids.

The Muse call was the only one. Muse refused the fireplace the way it refused the River God twice on 5 October (`image-work/collection-room-remodel/european-case-passes/README.md`); both carry nude figures. So both objects were isolated without it, for nothing: `cut_photo.py` cuts the object out of the photograph and Trellis is given the photograph's own pixels with a transparent ground.

## How they were made

Scripts are in `image-work/mesh-pilot-263/`.

1. `cut_photo.py`: the catalogue photograph → an RGBA cut-out (fireplace by saturation key inside its measured outline, Neptune by GrabCut).
2. `~/promo-lab/tools/tmp_url.sh`: a temporary public URL for Flora; removed after each run.
3. Flora `i3d-trellis`, quoted first.
4. `prepare_mesh.py` (Blender 4.0.2): join, drop loose scraps, scale to the catalogue height, set metallic 0, recalculate normals, export GLB with a JPEG texture, then read the file back and check it. For the fireplace also: press the invented back flat onto the wall plane, scale depth to 50.8 cm and width to 210.8 cm.
5. Godot import with the `.import` files here. Each `*_Image_0.jpg` is the texture Godot writes out of its GLB on import. It is kept in git with its `.import`, because Godot does not write it out again when the `.import` is already there, and the import then fails.

Not done, and why: no triangle reduction in Blender. Collapsing a Trellis mesh tears its texture, and the bake that would repair it came out black three times; the count is whatever `mesh_simplify` gives.
