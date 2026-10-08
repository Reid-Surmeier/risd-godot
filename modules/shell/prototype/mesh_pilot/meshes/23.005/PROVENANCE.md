# 23.005 The Hand of God

Auguste Rodin. *The Hand of God*. Marble. 100.3 × 82.6 × 68 cm. RISD Museum 23.005.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/23.005/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/23.005/views.json` | free |
| Muse views | 8 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/23.005/` | 0.08 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front, left, back, right, each from the museum's photograph of that side; run `run_m172w6rwjf81z0t8cgehw56pz98fwwc4`; raw GLB `31855dba5f153420…` (478,284 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.7749 m wide and 0.9383 m deep at the catalogue height, set to [0.8275, 1.0026, 0.6816] m (width, height, depth) | free |
| Colour | `plain_colour.py`: one base colour from the lit areas of the catalogue photograph, with the baked occlusion blurred (strength and blur: 0.6 1); no projected views, which streaked this white object | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction; third attempt: with the clay front attached as a reference Muse copied the front twice; drawn from the photograph alone |
| `clay-side` | photograph of this direction |
| `clay-right` | photograph of this direction; third attempt: with the clay front attached as a reference Muse copied the front twice; drawn from the photograph alone |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `flat-side` | photograph of this direction |
| `flat-right` | photograph of this direction |

`23-005.glb` (`9c94534e4d0ad827…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 233 KB (mesh 190, colour 43).
