# 2017.74.6.4 Wall Sconce

*Wall Sconce*, one of a pair, with birds. Carved and gilded wood. Height 87.6 cm. RISD Museum 2017.74.6.4.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.6.4/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.6.4/views.json` | free |
| Muse views | 1 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.6.4/` | 0.01 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 (`i3d-tripo-h3-1-i3d`), single view, geometry detailed, texture off, face limit 500,000; views the clay front alone (a wall piece, by the rule for reliefs); the clay front drawn from the museum's front photograph and an angled one; run `run_m179p73pdfh4yda6pqp1qh35t58fwdk1`; raw GLB `e6c0d136a5495079…` (498,792 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.5388 m wide and 0.2463 m deep at the catalogue height, after a 0.09° lean was rotated out (`--upright`), set to [0.5393, 0.8764, 0.2503] m (width, height, depth) | free |
| Colour | `plain_colour.py`: one base colour from the catalogue photograph, with the baked occlusion blurred (strength, blur, and where given which third of the photograph gives the base and whether the shading runs to the photograph own shadow colour: 0.9 0.7 bright photo); no projected views, which streaked this white object | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |

`2017-74-6-4.glb` (`4f9c98abd8252978…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 272 KB (mesh 230, colour 42).
