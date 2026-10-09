# 2017.74.22.ab Brown Bear Jug and Cover

*Brown Bear Jug and Cover*. Stoneware with glaze. Height 16.2 cm. RISD Museum 2017.74.22.ab.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Placed in the Rockefeller room source as `image-work/collection-room-remodel/additions/rockefeller/bear-jug-horn-20177422ab.glb` (the same file).

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.22.ab/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.22.ab/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.22.ab/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views front and right side, each a Muse clay view of the museum's photograph of that side; the back is Muse's inference from those two clay views and the museum's part-turned photograph; run `run_m1711gzs4jwmmatx3918e5eppd8fyeav`; raw GLB `1249524a70a39a80…` (476,360 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.0768 m wide and 0.1029 m deep at the catalogue height, set to [0.0711, 0.1619, 0.0968] m (width, height, depth). The catalogue gives the height only (16.2 cm). Width and depth follow the museum's own front and side photographs: 0.439 and 0.599 of the height, 7.1 and 9.7 cm | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-right` | photograph of this direction |
| `clay-back` | inferred by Muse from the clay front, the clay right side and the museum's part-turned photograph |
| `flat-front` | photograph of this direction |
| `flat-right` | photograph of this direction |

`2017-74-22-ab.glb` (`5879db7fba33531e…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 285 KB (mesh 260, colour 24).

## Generated files

| File | Provider, model, run | Cost | SHA-256 |
| --- | --- | --- | --- |
| `batch/2017.74.22.ab/clay-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-3a0971de45e81d8d6ab829f6` | 0.01 USD | `574a00cd0cdd5d48…` (native output) |
| `batch/2017.74.22.ab/clay-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-821a3adf3719aca10ef2bd3d` | 0.01 USD | `f785d149e6a97e4e…` (native output) |
| `batch/2017.74.22.ab/clay-right.png` (outside git) | OpenRouter, `meta/muse-image`, `run-8595380d16827b9573f96fc3` | 0.01 USD | `f2a4a9edb3b830fb…` (native output) |
| `batch/2017.74.22.ab/flat-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-675370b33f212765883703c4` | 0.01 USD | `b16dd11eadd0972f…` (native output) |
| `batch/2017.74.22.ab/flat-right.png` (outside git) | OpenRouter, `meta/muse-image`, `run-2305f9b901fe2b0f596abdf9` | 0.01 USD | `df09000537a12917…` (native output) |
| raw mesh (not kept) | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, `run_m1711gzs4jwmmatx3918e5eppd8fyeav` | 0.48 USD | `1249524a70a39a80…` |
| `2017-74-22-ab.glb` | built here from the raw mesh and the flat views (Blender 5.2.2, free) | 0 | `5879db7fba33531e…` |
