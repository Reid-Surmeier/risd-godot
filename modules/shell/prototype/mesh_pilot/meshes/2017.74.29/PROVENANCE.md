# 2017.74.29 Model of a Cow

*Model of a Cow*. Earthenware with glaze. 13 × 21 × 8 cm. RISD Museum 2017.74.29.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.29/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.29/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.29/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front and back each a Muse clay view of the museum's photograph of that flank; the left (the head end) inferred by Muse; run `run_m174t7kmegmsykj2fet6p11k2x8fxkv4`; raw GLB `9518ebe5e8b984b7…` (475,177 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.2053 m wide and 0.0785 m deep at the catalogue height, set to [0.2102, 0.1301, 0.08] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front and back: the view from the head end; no photograph of an end exists |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |

`2017-74-29.glb` (`436b9b2545beb194…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 219 KB (mesh 161, colour 57).
