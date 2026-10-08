# 2000.103.3 Dress

*Dress*, English or American, early 1800s. Cotton muslin. Shown 1.50 m tall on its form. RISD Museum 2000.103.3.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2000.103.3/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2000.103.3/views.json` | free |
| Muse views | 3 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2000.103.3/` | 0.03 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views front from the museum's one photograph; left and back inferred by Muse; run `run_m170qzbabkecm4sa2gmchz8jqx8fxfrv`; raw GLB `96f1c7efa5b0e597…` (491,750 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.6202 m wide and 0.4568 m deep at the catalogue height, set to [0.6212, 1.4996, 0.4568] m (width, height, depth) | free |
| Colour | `plain_colour.py`: one base colour from the catalogue photograph, with the baked occlusion blurred (strength, blur, and where given which third of the photograph gives the base and whether the shading runs to the photograph own shadow colour: 0.55 0.8 bright grey); no projected views, which streaked this white object | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front; the museum has one photograph of this dress |
| `clay-back` | inferred by Muse from the clay front and the clay left; the button closure and gathers at the back are Muse's, not seen |

`2000-103-3.glb` (`2f0bfdadc3223e40…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 261 KB (mesh 209, colour 51).
