# 2017.74.14 St. George and the Dragon

Ralph Wood the younger. *St. George and the Dragon*, ca. 1770. Earthenware with glaze and metal. 26.4 × 20.3 × 12.3 cm. RISD Museum 2017.74.14.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.14/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.14/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.14/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views front, back and right, each a Muse clay view of the museum's photograph of that side; run `run_m17caqs5dan77rt417b1z380758fxxy8`; raw GLB `9a96d0602a390237…` (498,216 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.1855 m wide and 0.1197 m deep at the catalogue height, set to [0.2033, 0.2639, 0.1234] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-right` | photograph of this direction |
| `wrong-colour` | three flat views made with a colour description I wrote before looking at the photograph (a cream-white horse; the real one is brown), and a 'right' view that repeated the front; not used; 0.03 USD |
| `mauve-horse` | two flat views made with the horse described as purplish brown; the photograph's horse is a warm chestnut; not used; 0.02 USD |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |

`2017-74-14.glb` (`3a0d69f77c63307c…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 278 KB (mesh 222, colour 56).
