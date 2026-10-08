# 43.195 The Crucified Christ

Unknown maker, Spanish. *The Crucified Christ*, ca. 1150–1200. Oak with traces of polychrome. 215.9 × 215.9 cm. RISD Museum 43.195.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/43.195/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/43.195/views.json` | free |
| Muse views | 4 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/43.195/` | 0.04 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front from the photograph; left inferred with two footage frames as references; run `run_m171wfz14nkkk61drkzy7xyjyx8fwtg3`; raw GLB `4a4af33b4b400435…` (497,845 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 2.1547 m wide and 0.4659 m deep at the catalogue height, set to [2.1526, 2.1602, 0.4644] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-side` | inferred by Muse from the front photograph and two footage frames (IMG_6382 38.5 s and 47.5 s, oblique) |
| `flat-front` | photograph of this direction |
| `flat-side` | inferred by Muse from the other views |

`43-195.glb` (`2050e0cf4f87f030…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 478 KB (mesh 214, colour 264).
