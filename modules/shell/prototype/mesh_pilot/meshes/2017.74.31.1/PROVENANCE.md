# 2017.74.31.1 Neptune as River Deity

Vincennes Porcelain Manufactory. *Neptune as River Deity*, 1745–1750. Soft-paste porcelain. 29.8 × 27 × 24 cm. RISD Museum 2017.74.31.1.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.31.1/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.31.1/views.json` | free |
| Muse views | none: not tried: a nude male figure, the kind Muse refused for the River God three times and the fireplace once; the lead set the photograph route for it. The museum photographs themselves went to the mesh generator and give the colour, so the colour carries the photographs own light and shadow | 0.00 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; input the museum's photographs themselves, cut out; views front, left and back, each the museum's own photograph of that side (no Muse view); run `run_m179gbf1q3yg9307gepqavkgb18fw28k`; raw GLB `fa57088b3dd1ee99…` (484,180 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.2741 m wide and 0.2389 m deep at the catalogue height, set to [0.275, 0.2981, 0.2388] m (width, height, depth) | free |
| Colour | `plain_colour.py`: one base colour from the catalogue photograph, with the baked occlusion blurred (strength, blur, and where given which third of the photograph gives the base and whether the shading runs to the photograph own shadow colour: 0.6 1); no projected views, which streaked this white object | free |

| View | Came from |
| --- | --- |
| `photo-front` | photograph of this direction, cut out by its difference from the studio backdrop and given to the mesh generator as it is (no Muse view) |
| `photo-left` | photograph of this direction, cut out by its difference from the studio backdrop and given to the mesh generator as it is (no Muse view) |
| `photo-back` | photograph of this direction, cut out by its difference from the studio backdrop and given to the mesh generator as it is (no Muse view) |

`2017-74-31-1.glb` (`dd4c8cd00076a80b…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 260 KB (mesh 212, colour 48).

Status, 8 October 2026: a trial only. It is not in the game sources. The run was submitted minutes before the lead withdrew this route (the museum's photographs straight to the mesh generator, with no Muse pass); the owner's rule is that a mesh starts from a Muse pass and that a refused step is a stop. The question is with the owner as item 20 on #262. What is wrong with it as a mesh: the three photographs are not square to one another (the side view is from a little behind), the front came out at 45 degrees where every Muse-first mesh came out at 90, and the back of the mesh is not the wave-covered back the photograph shows.
