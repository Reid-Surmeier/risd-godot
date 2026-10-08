# 2017.74.17 Hudibras

Ralph Wood the younger; John Voyez, modeler. *Hudibras*. Earthenware with glaze. 28.9 × 22.3 × 12.4 cm. RISD Museum 2017.74.17.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.17/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.17/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.17/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front, left (the end view from behind the horse) and back, each a Muse clay view of the museum's photograph of that side; run `run_m176r7ekxnsetxp29kx88kqxbd8fx370`; raw GLB `24f60e5637505448…` (488,160 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.2249 m wide and 0.1292 m deep at the catalogue height, set to [0.2226, 0.2892, 0.1237] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-side` | photograph of this direction |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |

`2017-74-17.glb` (`40573f20a2b89f46…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 259 KB (mesh 204, colour 55).
