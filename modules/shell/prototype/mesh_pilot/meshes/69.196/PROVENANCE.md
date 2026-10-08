# 69.196 Christ in Majesty

Unknown maker, Spanish. *Christ in Majesty*, ca. 1090–1100. Limestone. 97.8 × 55.9 cm. RISD Museum 69.196.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/69.196/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/69.196/views.json` | free |
| Muse views | 3 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/69.196/` | 0.03 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 single view (`i3d-tripo-h3-1-i3d`), geometry detailed, texture off, face limit 500,000; input the clay front alone; run `run_m177qvnergbrevp0g6e3zeh2qs8fxp9x`; raw GLB `724569f9f999ac37…` (489,610 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Rejected mesh | Tripo H3.1 Multi-View from the clay front and the side view Muse inferred, run `run_m1761kq1n3p2x6cgdke92mthzd8fxbn6`: the invented side gave the figure a second arm and a 0.46 m deep block. Not kept | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.5253 m wide and 0.3051 m deep at the catalogue height, after a 9.78° lean was rotated out (`--upright`); set to [0.5589, 0.9782, 0.2005] m (width, height, depth). The catalogue gives no depth: 0.20 m is an estimate from the photograph | free |
| Colour | `colour_mesh2.sh`: the flat front view matched to the photograph, occlusion 0.35; the sides and back, which no view shows (53% of the texture), take the median colour of the front; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-side` | inferred by Muse from the clay front alone; no photograph or usable footage of the side; Muse drew the right profile; mirrored to serve as the left view; not used for the mesh |
| `flat-front` | photograph of this direction |

`69-196.glb` (`14b7cc189a7e62fb…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 258 KB (mesh 202, colour 56).
