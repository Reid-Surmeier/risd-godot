# 59.128 Pietà

Tilman Riemenschneider. *Pietà*. Linden wood. 45.7 × 38.1 × 13.2 cm. RISD Museum 59.128.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/59.128/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/59.128/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/59.128/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front from the photograph; left inferred by Muse from the clay front (no photograph of a side or the back exists); run `run_m176zfw962c0e14aqkv3jn0ggn8fw97d`; raw GLB `e54f7847944af4cf…` (480,748 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.3575 m wide and 0.1759 m deep at the catalogue height, after a 4.31° lean was rotated out (`--upright`), set to [0.3815, 0.457, 0.1322] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35 (the sides and back, which the one view never shows, take the median colour of the front); `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front; no photograph of a side exists; a blurred footage frame (IMG_6383 18.3 s) gave only how narrow the group is; Muse drew the flat back as a board |
| `clay-side` | inferred by Muse; came out a three-quarter view, not a profile; not used for the mesh |
| `clay-back` | inferred by Muse; no photograph of the back exists; not used for the mesh: Muse carved the back in the round, against the flat back its own profile view and the 13.2 cm catalogue depth give |
| `flat-front` | photograph of this direction |

`59-128.glb` (`82f9029222059ec5…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 252 KB (mesh 213, colour 39).
