# 21.398 Saint Roch

Unknown maker, French. *Saint Roch*, 1475–1525. Wood with polychromy. Height 105.4 cm. RISD Museum 21.398.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/21.398/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/21.398/views.json` | free |
| Muse views | 6 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/21.398/` | 0.06 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front and back each from the museum's photograph of that side; left inferred by Muse; run `run_m171n7e3946p9pzgj3ayprpmdd8fwb3m`; raw GLB `311e252cdb07a086…` (483,629 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.5799 m wide and 0.3517 m deep at the catalogue height, set to [0.5806, 1.0523, 0.3514] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front and back; no photograph of a side exists; a footage frame (IMG_6383 18.3 s, seen from his front right through the case) was attached for the depth of the cape, dog and base |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `flat-left` | inferred: the clay left repainted with the colours of the front photograph; not used: Muse repeated the front view instead of repainting the profile |

`21-398.glb` (`c27d683e2d898dae…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 262 KB (mesh 212, colour 50).
