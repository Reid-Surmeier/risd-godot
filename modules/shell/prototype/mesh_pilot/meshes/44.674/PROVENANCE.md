# 44.674 River God (The Virile Age; The Euphrates)

Giambologna. *River God (The Virile Age; The Euphrates)*, ca. 1575. Terracotta. 48.3 × 43.5 × 31.8 cm. RISD Museum 44.674.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/44.674/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/44.674/views.json` | free |
| Muse views | none: 5 October twice, and 8 October once more with a description of it as a terracotta sketch model of a river god (HTTP 400); not resubmitted. The museum photographs themselves went to the mesh generator and give the colour, so the colour carries the photographs own light and shadow | 0.00 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; input the museum's photographs themselves, cut out, because Muse refused this object; views front, left and back, each the museum's own photograph of that side (no Muse view); run `run_m172k7aa7pk8cyaa1h5rq1z8298fxpzt`; raw GLB `880e1295b47d5e45…` (494,702 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.3548 m wide and 0.4323 m deep at the catalogue height, set to [0.3549, 0.4829, 0.4323] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.1; `match_in_scene.py` lift for unshaded drawing | free |

| View | Came from |
| --- | --- |
| `photo-front` | photograph of this direction, cut out and given to the mesh generator and used for the colour as it is (no Muse view: Muse refused this object three times) |
| `photo-left` | photograph of this direction, cut out and given to the mesh generator and used for the colour as it is (no Muse view: Muse refused this object three times) |
| `photo-back` | photograph of this direction, cut out and given to the mesh generator and used for the colour as it is (no Muse view: Muse refused this object three times) |

`44-674.glb` (`a8435ea8c61e2d63…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 224 KB (mesh 194, colour 30).
