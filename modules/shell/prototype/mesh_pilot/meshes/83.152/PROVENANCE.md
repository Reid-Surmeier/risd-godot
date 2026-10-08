# 83.152 Fireplace Surround

Hugnet Frères. *Fireplace Surround*, 1900. Walnut, glazed tile and copper. 349.8 × 210.8 × 50.8 cm. RISD Museum 83.152.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/83.152/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/83.152/views.json` | free |
| Muse views | 3 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/83.152/` | 0.03 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front from the museum's frontal photographs; left inferred by Muse with the museum's oblique photograph of that flank; run `run_m17dv9ah0dftk6kxedpt8vr64x8fwmaz`; raw GLB `a4f411ed2a10a977…` (474,791 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 9,998 triangles, occlusion baked from the high mesh; made 2.0603 m wide and 0.6594 m deep at the catalogue height, after a 0.0° lean was rotated out (`--upright`), set to [2.1101, 3.498, 0.5082] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35 (the sides and back, which the one view never shows, take the median colour of the front); `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front and the museum's oblique photograph of that flank; no square-on photograph of a side exists; Muse drew the flank's figure as a full-length draped figure |
| `flat-front` | photograph of this direction |

`83-152.glb` (`01ed7c8d77423886…`): 9,998 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 358 KB (mesh 229, colour 128).
