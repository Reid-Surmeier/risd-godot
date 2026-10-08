# 2017.74.27.1 Parrot

*Parrot*, one of a pair. Earthenware with glaze. 16.5 × 17 × 7 cm. RISD Museum 2017.74.27.1.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.27.1/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.27.1/views.json` | free |
| Muse views | 8 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.27.1/` | 0.08 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views front, back and right (head-on), each a Muse clay view of the museum's photograph of that side; the back view was drawn twice (the first drawing was a different bird and is rejected); run `run_m1734ey4cmqydsf552wpe55a358fxm4z`; raw GLB `0971d8efa19eabee…` (467,830 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.1535 m wide and 0.0687 m deep at the catalogue height, set to [0.1533, 0.1651, 0.0688] m (width, height, depth). Sized by the catalogue height, 16.5 cm. The catalogue gives 17 cm for the width, wider than tall; the museum's own profile photograph is 0.91 as wide as tall, and the mesh keeps the photograph's proportions | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction; first drawing rejected (clay-back-rejected.png, run-33f9ba8b24d9c72f5646ac15): Muse drew a different bird, standing free on a bell-shaped base. Redone once as key clay-back2 (run-bd2f51b78f7e31ae269b3e70, prompt clay-back2.prompt.txt) from the back photograph alone; that drawing is clay-back.png. The museum's photograph of this flank is turned a little towards the head, not square-on. |
| `clay-right` | photograph of this direction; the head-on view: the bird's beak end is its own right side when the catalogue's first photograph is the front |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `clay-threequarter` | photograph of this direction; the museum's second photograph, from behind and from the tail end; drawn from that photograph alone (run-d61cc5728cab2318191dd70f). Used for colour only: the mesh was already made from the front, back and right views |
| `flat-threequarter` | photograph of this direction |
| `clay-back-rejected` | photograph of this direction; rejected and not used: a different bird (run-33f9ba8b24d9c72f5646ac15, prompt clay-back.prompt.txt) |

`2017-74-27-1.glb` (`eae5a8032bec20d2…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 286 KB (mesh 216, colour 70).
