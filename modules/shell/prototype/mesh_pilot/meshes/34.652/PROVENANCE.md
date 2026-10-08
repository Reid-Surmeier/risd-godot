# 34.652 Panel with Striding Lion

Unknown maker, Neo-Babylonian. *Panel with Striding Lion*, 604–562 BCE. Brick with glaze. 104.1 × 228.6 cm. RISD Museum 34.652.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/34.652/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/34.652/views.json` | free |
| Muse views | 2 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/34.652/` | 0.02 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 (`i3d-tripo-h3-1-i3d`), single view, geometry detailed, texture off, face limit 500,000; views the clay front alone (the rule for reliefs); the clay front drawn from the front photograph, an angled photograph and a close view; run `run_m1742zwe5b6x05wfajjtype5nh8fwtfy`; raw GLB `36d9829bdea1e6ba…` (488,794 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 1.9529 m wide and 0.2737 m deep at the catalogue height, after a 0.51° lean was rotated out (`--upright`), set to [2.2856, 1.0416, 0.0993] m (width, height, depth). The catalogue gives no depth: 0.10 m is an estimate from the museum's angled photograph of the mounted panel; the generator made it deeper | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.5 (the sides and back, which the one view never shows, take the median colour of the front); `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `flat-front` | photograph of this direction |

`34-652.glb` (`64030e49c413bcdb…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 360 KB (mesh 185, colour 174).
