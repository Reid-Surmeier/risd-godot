# 2017.74.21 Figure of a Bagpiper

*Figure of a Bagpiper*. Earthenware with glaze. 15 × 7 × 6 cm. RISD Museum 2017.74.21.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Placed in the Rockefeller room source as `image-work/collection-room-remodel/additions/rockefeller/bagpiper-20177421.glb` (the same file).

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.21/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.21/views.json` | free |
| Muse views | 7 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.21/` | 0.07 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as front, left, back; views front and left side, each a Muse clay view of the museum's photograph of that side; the back is Muse's inference from those two clay views (the museum has no photograph from behind); run `run_m178jr6bxaz9g9dh87g4qm0t4d8fz00z`; raw GLB `8d2adb8ea16471b7…` (491,251 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.0642 m wide and 0.0585 m deep at the catalogue height, set to [0.0699, 0.1501, 0.0601] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-side` | photograph of this direction; his left side |
| `clay-back-rejected` | not used: inferred back with the drones on the wrong shoulder (my prompt named the wrong one) |
| `clay-back` | inferred by Muse from the clay front and the clay side; key clay-back2 when made: the back redrawn once with the drones beside his right shoulder |
| `flat-front` | photograph of this direction |
| `flat-back` | the inferred clay back, coloured from the museum's side photograph |
| `flat-side` | photograph of this direction |

`2017-74-21.glb` (`cd8b63b0edc69308…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 257 KB (mesh 203, colour 54).

## Generated files

| File | Provider, model, run | Cost | SHA-256 |
| --- | --- | --- | --- |
| `batch/2017.74.21/clay-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-d532e1c585fdedff07c63ea4` | 0.01 USD | `09a7b319360e8368…` (native output) |
| `batch/2017.74.21/clay-back2.png` (outside git) | OpenRouter, `meta/muse-image`, `run-18d0025c40a979748cdd5026` | 0.01 USD | `e28e34a48c243120…` (native output) |
| `batch/2017.74.21/clay-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-d3d8be0e882af5d656480cf7` | 0.01 USD | `23dd5bc855232e4a…` (native output) |
| `batch/2017.74.21/clay-side.png` (outside git) | OpenRouter, `meta/muse-image`, `run-0ed0038f56664d4be93aee55` | 0.01 USD | `f4ded7d89102e49f…` (native output) |
| `batch/2017.74.21/flat-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-550d887a9f35cb58a08aacf5` | 0.01 USD | `7db6b798dafd1824…` (native output) |
| `batch/2017.74.21/flat-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-e8dad4e00253c4c4a16be3be` | 0.01 USD | `d0cd433c2344a886…` (native output) |
| `batch/2017.74.21/flat-side.png` (outside git) | OpenRouter, `meta/muse-image`, `run-2b4919da1c53707789ac6c8e` | 0.01 USD | `e68d7170c4fedd28…` (native output) |
| raw mesh (not kept) | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, `run_m178jr6bxaz9g9dh87g4qm0t4d8fz00z` | 0.48 USD | `8d2adb8ea16471b7…` |
| `2017-74-21.glb` | built here from the raw mesh and the flat views (Blender 5.2.2, free) | 0 | `cd8b63b0edc69308…` |
