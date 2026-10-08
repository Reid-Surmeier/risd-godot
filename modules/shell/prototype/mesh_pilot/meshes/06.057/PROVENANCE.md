# 06.057 Tabernacle

Domenico Gagini. *Tabernacle*. Marble. 50.8 × 73.7 cm. RISD Museum 06.057.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/06.057/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/06.057/views.json` | free |
| Muse views | 2 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/06.057/` | 0.02 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 (`i3d-tripo-h3-1-i3d`), single view, geometry detailed, texture off, face limit 500,000; views the clay front alone (the rule for reliefs); the clay front drawn from the front photograph and two detail photographs; run `run_m174qe034vakcgq5than1qrrnd8fxd8t`; raw GLB `71be5244776f722f…` (492,515 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.6708 m wide and 0.266 m deep at the catalogue height, after a 14.99° lean was rotated out (`--upright`), set to [0.7373, 0.5083, 0.1799] m (width, height, depth). The catalogue gives no depth: 0.18 m is an estimate from the museum's detail photograph of the right-hand angels; the generator made 0.27 m | free |
| Colour | `plain_colour.py`: one base colour from the lit areas of the catalogue photograph, with the baked occlusion blurred (strength and blur: 0.6 1); no projected views, which streaked this white object | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `flat-front` | photograph of this direction |

`06-057.glb` (`839b85dc72343721…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 260 KB (mesh 214, colour 45).
