# 2017.74.28.2 Figural Candlestick

*Figural Candlestick*, the other of the pair. Earthenware with glaze. Height 21.6 cm. RISD Museum 2017.74.28.2.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.28.2/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.28.2/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.28.2/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`); no run of its own: the pair are casts of one model, and this one takes the mesh made for 2017.74.28.1, geometry detailed, texture off, face limit 500,000; views the clay front, left and back of its pair 2017.74.28.1; its colour from its own two photographs; run `run_m176m5adkpjp3jgyrgz4qnzrqd8fwtp7`; raw GLB `67a5289926e35f64…` (492,941 triangles, not kept) | quoted 0.00, charged 0.00 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.1008 m wide and 0.1122 m deep at the catalogue height, set to [0.12, 0.2101, 0.11] m (width, height, depth). The museum's photographs show the same pose from the front, the side and the back in both candlesticks; small differences between the two casts (the curl of a hat brim) are not in this mesh | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `clay-front` | photograph of this direction, of its pair 2017.74.28.1: the same clay view, since the two are casts of one model |
| `clay-side` | photograph of this direction, of its pair 2017.74.28.1: the same clay view, since the two are casts of one model |
| `clay-back` | photograph of this direction, of its pair 2017.74.28.1: the same clay view, since the two are casts of one model |

`2017-74-28-2.glb` (`65b74ae2cdbdea10…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 263 KB (mesh 211, colour 52).
