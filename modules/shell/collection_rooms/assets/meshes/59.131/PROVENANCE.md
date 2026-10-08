# 59.131 Head of Christ or a Saint

Unknown maker, Spanish. *Head of Christ or a Saint*, ca. 1220–1240. Walnut with polychromy. 81.3 × 50.8 × 50.8 cm. RISD Museum 59.131.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/59.131/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/59.131/views.json` | free |
| Muse views | 6 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/59.131/` | 0.06 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front and back from photographs; left inferred (Muse drew the right profile, mirrored); run `run_m178k1b4qgdjebt2qa0148pxa98fxejm`; raw GLB `1449eaab67fff9a1…` (486,558 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.5169 m wide and 0.565 m deep at the catalogue height, set to [0.5084, 0.8137, 0.508] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-side` | inferred by Muse from the other views; Muse drew the right profile; mirrored to serve as the left view |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `flat-side` | inferred by Muse from the other views |

`59-131.glb` (`934bc5e33b9cf33a…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 467 KB (mesh 199, colour 267).
