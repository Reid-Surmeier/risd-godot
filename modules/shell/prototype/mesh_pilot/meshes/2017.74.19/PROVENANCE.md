# 2017.74.19 Horn-Player

*Horn-Player*. Earthenware with glaze. 16.2 × 7 × 5 cm. RISD Museum 2017.74.19.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Placed in the Rockefeller room source as `image-work/collection-room-remodel/additions/rockefeller/horn-player-20177419.glb` (the same file).

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.19/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.19/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.19/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as front, left, back; views front and back, each a Muse clay view of the museum's photograph of that side; the left profile is Muse's inference from the clay front, the clay back and the museum's part-turned photograph; run `run_m178adefxgdayrwtr1gc8cy5kd8fzvz7`; raw GLB `1504eb90768a6651…` (480,566 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Rejected mesh | Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), run `run_m17e08epcxb3ezw4y2a85gjw8s8fyxce`; views the same three. Flora reported it failed at the provider ("The generation timed out", 8 October); no output. Resubmitted once on 9 October with the lead's word. | quoted 0.48, charged 0.00 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.0707 m wide and 0.0575 m deep at the catalogue height, set to [0.07, 0.162, 0.0501] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front, the museum's part-turned photograph and the clay back; key clay-right when made: my prompt asked for his right side but described him facing left, and the drawing is his left profile, used as the left view |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |

`2017-74-19.glb` (`b9d3d686230bc0f8…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 253 KB (mesh 190, colour 63).

## Generated files

| File | Provider, model, run | Cost | SHA-256 |
| --- | --- | --- | --- |
| `batch/2017.74.19/clay-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-8d43372b5e6bd6984d913780` | 0.01 USD | `5772681d38343282…` (native output) |
| `batch/2017.74.19/clay-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-1f9097c242595b7fa435f4aa` | 0.01 USD | `86a4309498bac3d0…` (native output) |
| `batch/2017.74.19/clay-right.png` (outside git) | OpenRouter, `meta/muse-image`, `run-eb7c234fd611757e656a5026` | 0.01 USD | `62fc5609dc28f57c…` (native output) |
| `batch/2017.74.19/flat-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-99eaf7c9a8516a6ec2ea416e` | 0.01 USD | `77be3b23c9e057af…` (native output) |
| `batch/2017.74.19/flat-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-33de84f7bbe91d4b07484667` | 0.01 USD | `979b9ec817f8e3d7…` (native output) |
| raw mesh (not kept) | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, `run_m178adefxgdayrwtr1gc8cy5kd8fzvz7` | 0.48 USD | `1504eb90768a6651…` |
| `2017-74-19.glb` | built here from the raw mesh and the flat views (Blender 5.2.2, free) | 0 | `b9d3d686230bc0f8…` |
