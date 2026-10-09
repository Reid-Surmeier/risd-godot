# 2017.74.20 Figure of a Fox

*Figure of a Fox*. Earthenware with glaze. 13.3 × 16.5 × 8 cm. RISD Museum 2017.74.20.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Placed in the Rockefeller room source as `image-work/collection-room-remodel/additions/rockefeller/fox-20177420.glb` (the same file).

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.20/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.20/views.json` | free |
| Muse views | 8 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.20/` | 0.08 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as front, left, back; views front, a Muse clay view of the museum's square-on photograph of the one flank it shows; the head-on view and the other flank are Muse's inference from that clay view (the museum has no photograph of them); run `run_m1747dd07vs6444yq9nhwcxbpd8fztdf`; raw GLB `1c71e7980ea3f4ac…` (474,778 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Rejected mesh | Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), run `run_m17a9r4y6kptnwzffjp72zhzn18fy2n8`; views the same three. Flora reported it failed at the provider ("The generation timed out", 8 October); no output. Resubmitted once on 9 October with the lead's word. | quoted 0.48, charged 0.00 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.161 m wide and 0.1191 m deep at the catalogue height, set to [0.1647, 0.1331, 0.08] m (width, height, depth) | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction; key clay-square when made: the museum's third photograph, square to the flank |
| `clay-threequarter` | photograph of this direction; not used for the mesh; key clay-front when made: the museum's first photograph, seen a little from the front and above |
| `clay-back-rejected` | not used: asked for the museum's third photograph, Muse repeated the first view |
| `clay-left` | inferred by Muse from the clay front and the clay three-quarter view; the head-on view: no photograph exists |
| `clay-back` | inferred by Muse from the clay front and the clay three-quarter view; the other flank: no photograph exists |
| `flat-front` | photograph of this direction |
| `flat-back` | the inferred other-flank clay view, coloured from the museum's photograph of the first flank |
| `flat-left` | not used: asked for the head-on view in colour, Muse drew the three-quarter view of the photograph |

`2017-74-20.glb` (`0232a85b1798d3d0…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 262 KB (mesh 203, colour 59).

## Generated files

| File | Provider, model, run | Cost | SHA-256 |
| --- | --- | --- | --- |
| `batch/2017.74.20/clay-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-006ba1aef79c4e7824470da1` | 0.01 USD | `14e5496bd0dbb9d8…` (native output) |
| `batch/2017.74.20/clay-back-rejected.png` (outside git) | OpenRouter, `meta/muse-image`, `run-ee3f501f03b88eff166166e5` | 0.01 USD | `2d0baf4e40c5fa84…` (native output) |
| `batch/2017.74.20/clay-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-a468b09663e279eeb0f5eb06` | 0.01 USD | `36cf205de9277255…` (native output) |
| `batch/2017.74.20/clay-left.png` (outside git) | OpenRouter, `meta/muse-image`, `run-6fc06079affcf93272ef495e` | 0.01 USD | `5bcafae6a50bbb65…` (native output) |
| `batch/2017.74.20/clay-threequarter.png` (outside git) | OpenRouter, `meta/muse-image`, `run-37346fda366d70c1c09ba55e` | 0.01 USD | `24fa9b3b7ecc74c1…` (native output) |
| `batch/2017.74.20/flat-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-484f285e50fdb340e83ff466` | 0.01 USD | `faf5483c95fb9d8d…` (native output) |
| `batch/2017.74.20/flat-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-a93e074da83ccc4383f7f473` | 0.01 USD | `263ca8b65a4a59d0…` (native output) |
| `batch/2017.74.20/flat-left.png` (outside git) | OpenRouter, `meta/muse-image`, `run-70e9900222e02961b7d2df20` | 0.01 USD | `2d57b96f8a59a336…` (native output) |
| raw mesh (not kept) | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, `run_m1747dd07vs6444yq9nhwcxbpd8fztdf` | 0.48 USD | `1c71e7980ea3f4ac…` |
| `2017-74-20.glb` | built here from the raw mesh and the flat views (Blender 5.2.2, free) | 0 | `0232a85b1798d3d0…` |
