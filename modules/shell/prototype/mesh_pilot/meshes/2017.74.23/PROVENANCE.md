# 2017.74.23 Figure of a Shepherd

*Figure of a Shepherd*. Earthenware with glaze. Height 21.3 cm. RISD Museum 2017.74.23.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.23/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.23/views.json` | free |
| Muse views | 5 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.23/` | 0.05 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views front, back and right, each a Muse clay view of the museum's photograph nearest that side (the back and side photographs are not square-on); run `run_m175cpat7av74rmdw8et1eeqr18fx1cc`; raw GLB `0c85ad86afd03279…` (472,304 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.0853 m wide and 0.0772 m deep at the catalogue height, set to [0.0855, 0.2131, 0.0771] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction |
| `clay-right` | photograph of this direction |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |

`2017-74-23.glb` (`d8b2925aedd77b93…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 262 KB (mesh 201, colour 61).
