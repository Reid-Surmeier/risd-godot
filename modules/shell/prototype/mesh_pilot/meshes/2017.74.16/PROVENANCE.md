# 2017.74.16 The Flute Player

Ralph Wood the younger. *The Flute Player*. Earthenware with glaze. 25.4 × 17.7 × 12.4 cm. RISD Museum 2017.74.16.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.16/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.16/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.16/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views front and right each a Muse clay view of the museum's photograph of that side; back inferred by Muse; run `run_m17ch6ett90rc521yzpyv9wgx18fwnfm`; raw GLB `baf63509a6715cff…` (482,582 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.1911 m wide and 0.1368 m deep at the catalogue height, set to [0.1773, 0.2539, 0.1242] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-right` | photograph of this direction; came out three-quarter, with the woman in view; not used for the mesh |
| `clay-rightprofile` | photograph of this direction; drawn a second time as a strict profile, as the photograph has it |
| `clay-back` | inferred by Muse from the clay front and the first clay right; no photograph of the back exists |
| `flat-front` | photograph of this direction |

`2017-74-16.glb` (`ff87147d6eb60c60…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 266 KB (mesh 215, colour 50).
