# 41.045 Apostle

Unknown maker. *Apostle*. Limestone. Height 86 cm. RISD Museum 41.045.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/41.045/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/41.045/views.json` | free |
| Muse views | 3 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/41.045/` | 0.03 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front from the photograph; left inferred by Muse (mirrored from the right profile it drew); run `run_m172axfcqfdp4p2k9ew6h9cdd98fwv7e`; raw GLB `aada9f126d336c46…` (472,594 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.2621 m wide and 0.243 m deep at the catalogue height, set to [0.2625, 0.8591, 0.1402] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-side` | inferred by Muse from the clay front alone; no photograph or usable footage of the side; Muse drew the right profile; mirrored to serve as the left view |
| `flat-front` | photograph of this direction |

`41-045.glb` (`87f9441ca49a76ab…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 256 KB (mesh 187, colour 69).
