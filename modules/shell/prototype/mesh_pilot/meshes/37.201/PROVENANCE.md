# 37.201 Bust of Madame Récamier

Joseph Chinard. *Bust of Madame Récamier*. Marble. 60.6 × 33.7 × 23.5 cm with its socle. RISD Museum 37.201.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/37.201/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/37.201/views.json` | free |
| Muse views | 3 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/37.201/` | 0.03 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round, because the left view failed); views front and right each from the museum's photograph of that side; back inferred by Muse; no left view (the Muse call failed with HTTP 502 and was not resubmitted); run `run_m176j6j9xvqh2cgavbw9hhmpm58fx6dm`; raw GLB `2f59f0c41cc4bae9…` (477,562 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Rejected mesh | Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), run `run_m171mq2jvy2r4gkzr2qzg9bdvs8fx0jw`; views front from the photograph; left and back inferred (Muse drew the right profile, mirrored). Rejected 8 October: the photograph taken as the front is a view from her right side, Muse drew a round lump for the square stepped socle, and the colour had invented veining and dark hair; mesh kept outside git | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.3535 m wide and 0.2802 m deep at the catalogue height, set to [0.337, 0.6061, 0.2352] m (width, height, depth) | free |
| Colour | `plain_colour.py`: one base colour from the lit areas of the catalogue photograph, with the baked occlusion blurred (strength and blur: 0.6 1); no projected views, which streaked this white object | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-right` | photograph of this direction; the photograph is from her right and a little behind; Muse turned it to a strict profile |
| `clay-back` | inferred by Muse from the clay front, the clay right and the right-side photograph; no photograph or footage of the back exists |

`37-201.glb` (`2170f679bcf9a266…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 261 KB (mesh 212, colour 49).
