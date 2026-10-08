# 37.114 Angel of the Annunciation

Unknown maker, Italian (Sienese). *Angel of the Annunciation*, ca. 1350. Wood with polychromy. Height 152.4 cm. RISD Museum 37.114.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/37.114/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/37.114/views.json` | free |
| Muse views | 8 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/37.114/` | 0.08 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front, left, back, right (all from photographs of those sides); run `run_m1718mk3xkebtjdzxn5a92fjt18fxe5b`; raw GLB `649fac35a775692d…` (469,628 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.4124 m wide and 0.4124 m deep at the catalogue height, set to [0.4117, 1.5241, 0.412] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-side` | photograph of this direction |
| `clay-right` | photograph of this direction |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `flat-side` | photograph of this direction |
| `flat-right` | photograph of this direction |

`37-114.glb` (`df831e3816f3cf5d…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 391 KB (mesh 186, colour 204).

Brightness, 8 October 2026: the colour texture was lifted by one gain of 2.0 in linear light (0.8% of texels clip), with no paid call and no recolouring. The museum's photograph of the Angel is about three times darker than its neighbours', so the mesh matched to it read unlit in the room. The gain was judged against the gallery footage (IMG_6382 60.5 s): the lit parts of the Angel measure 0.46 there and 0.21 in the served build, a ratio of 2.2, capped at 2.0 at the lead's word. In the pack: 442 KB (mesh 186, colour 256).
