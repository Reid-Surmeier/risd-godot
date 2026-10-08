# 2017.74.27.2 Parrot

*Parrot*, the other of the pair. Earthenware with glaze. 16.5 × 16 × 6.5 cm. RISD Museum 2017.74.27.2.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.27.2/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.27.2/views.json` | free |
| Muse views | 3 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.27.2/` | 0.03 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`); no run of its own: the pair are casts of one model, and this one takes the mesh made for 2017.74.27.1, geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views the clay front, back and right of its pair 2017.74.27.1; its colour from its own two photographs; run `run_m1734ey4cmqydsf552wpe55a358fxm4z`; raw GLB `0971d8efa19eabee…` (467,830 triangles, not kept) | quoted 0.00, charged 0.00 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.1535 m wide and 0.0687 m deep at the catalogue height, set to [0.1533, 0.1651, 0.0688] m (width, height, depth). The museum's photographs show the same model in both parrots (profile 0.91 and 0.92 as wide as tall); the catalogue's half-centimetre differences in width and depth are not in this mesh, which is sized by the shared height, 16.5 cm | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `clay-front` | photograph of this direction, of its pair 2017.74.27.1: the same clay view, since the two are casts of one model |
| `clay-back` | photograph of this direction, of its pair 2017.74.27.1: the same clay view, since the two are casts of one model |
| `clay-right` | photograph of this direction, of its pair 2017.74.27.1: the same clay view, since the two are casts of one model |
| `clay-threequarter` | photograph of this direction, of its pair 2017.74.27.1: the same clay view, since the two are casts of one model |
| `flat-threequarter` | photograph of this direction |

`2017-74-27-2.glb` (`d074cfceda179ea3…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 287 KB (mesh 216, colour 71).
