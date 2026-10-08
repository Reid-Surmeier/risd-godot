# 2017.46 Commode

Charles Cressent. *Commode*, ca. 1725–1730. Veneered oak and pine, gilt-bronze mounts, marble top. 86.4 × 144.8 × 64.8 cm. RISD Museum 2017.46.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.46/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.46/views.json` | free |
| Muse views | 6 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.46/` | 0.06 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front, left and back, each a Muse clay view of the museum's photograph of that side; run `run_m171htcvg4zpz11fk0rk79csds8fwrqj`; raw GLB `b4648610706a499e…` (483,830 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 1.3161 m wide and 0.742 m deep at the catalogue height, set to [1.4465, 0.8633, 0.647] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-side` | photograph of this direction |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `flat-side` | photograph of this direction |

`2017-46.glb` (`b28d7309ffb9a718…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 361 KB (mesh 211, colour 149).
