# 2017.74.26 Figure of a Parrot

*Figure of a Parrot*. Earthenware with glaze. 15.6 × 17 × 7 cm. RISD Museum 2017.74.26.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Placed in the Rockefeller room source as `image-work/collection-room-remodel/additions/rockefeller/parrot-20177426.glb` (the same file).

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/2017.74.26/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/2017.74.26/views.json` | free |
| Muse views | 9 images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/2017.74.26/` | 0.09 USD |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), geometry detailed, texture off, face limit 500,000; views given as back, right, front (the frame turned half round: there is no left view); views front and back, each a Muse clay view of the museum's photograph of that flank, and a head-on view that Muse inferred from the two clay flanks (the museum has no photograph from the beak end); run `run_m17cwhvbtrz2w43rdpw3t5sfjh8fxgjg`; raw GLB `bc28aec230d3e91b…` (476,870 triangles, not kept) | quoted 0.48, charged 0.48 USD |
| Blender 5.2.2 | `clay_mesh.py`: reduced to 10,000 triangles, occlusion baked from the high mesh; made 0.1407 m wide and 0.0937 m deep at the catalogue height, set to [0.1472, 0.156, 0.0701] m (width, height, depth). Height and depth are the catalogue's (15.6 and 7 cm; the generator made it 9.4 cm deep). The catalogue's 17 cm width is wider than the museum's own profile photograph shows (0.945 as wide as tall), so the width follows the photograph: 14.7 cm | free |
| Colour | `colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion 0.35; no in-scene lift (a many-coloured object) | free |

| View | Came from |
| --- | --- |
| `clay-front` | photograph of this direction |
| `clay-back` | photograph of this direction; the museum's photograph of this flank is turned a little towards the tail, not square-on |
| `clay-right` | inferred by Muse from the clay front and clay back; the head-on view, from the beak end: no photograph exists. The head came out turned a little; redrawn once as key clay-right2 (run-10b67cfdfccc45b9c5cf7152) asking for a square-on head, which gave the same drawing and is not used |
| `clay-right2` | inferred by Muse from the clay front and clay back; not used |
| `flat-front` | photograph of this direction |
| `flat-back` | photograph of this direction |
| `clay-left` | inferred by Muse from the clay front and clay back; the tail-end view, for colour only: no photograph exists and the mesh was already made without it |
| `flat-left` | the inferred tail-end clay view, coloured from the museum's photograph of the back flank |
| `flat-right` | not used: asked for the head-on view in colour, Muse repeated the flat front (run-5fe629e245945b5c01bf1832) |

`2017-74-26.glb` (`b94e8e2566191336…`): 10,000 triangles, one colour texture, no normal map, for drawing unshaded. In the pack: 306 KB (mesh 192, colour 113).

## Generated files

| File | Provider, model, run | Cost | SHA-256 |
| --- | --- | --- | --- |
| `batch/2017.74.26/clay-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-3c25e978cf7e24b25ac6b619` | 0.01 USD | `d5332b71d4f72fb2…` (native output) |
| `batch/2017.74.26/clay-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-a20e0b06f984c6f552ebe80f` | 0.01 USD | `686be9468b73e89d…` (native output) |
| `batch/2017.74.26/clay-left.png` (outside git) | OpenRouter, `meta/muse-image`, `run-9e8e02a463e94e31dca65429` | 0.01 USD | `8475bd667acfe254…` (native output) |
| `batch/2017.74.26/clay-right.png` (outside git) | OpenRouter, `meta/muse-image`, `run-b2e940cf09036349ee5c8746` | 0.01 USD | `f876cb6c7b64c7bb…` (native output) |
| `batch/2017.74.26/clay-right2.png` (outside git) | OpenRouter, `meta/muse-image`, `run-10b67cfdfccc45b9c5cf7152` | 0.01 USD | `9a1b4ac95cf0f0dc…` (native output) |
| `batch/2017.74.26/flat-back.png` (outside git) | OpenRouter, `meta/muse-image`, `run-4dbe2cc846f0120f64134744` | 0.01 USD | `1643d0e71465aa85…` (native output) |
| `batch/2017.74.26/flat-front.png` (outside git) | OpenRouter, `meta/muse-image`, `run-5996499f1d4d8ed7d153e0dd` | 0.01 USD | `53f5eb44ea9eb14e…` (native output) |
| `batch/2017.74.26/flat-left.png` (outside git) | OpenRouter, `meta/muse-image`, `run-01b96e4b8fe07b3c5cf6c8bc` | 0.01 USD | `c9e15204b43dc43e…` (native output) |
| `batch/2017.74.26/flat-right.png` (outside git) | OpenRouter, `meta/muse-image`, `run-5fe629e245945b5c01bf1832` | 0.01 USD | `c6b0b3185117aec1…` (native output) |
| raw mesh (not kept) | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, `run_m17cwhvbtrz2w43rdpw3t5sfjh8fxgjg` | 0.48 USD | `bc28aec230d3e91b…` |
| `2017-74-26.glb` | built here from the raw mesh and the flat views (Blender 5.2.2, free) | 0 | `b94e8e2566191336…` |
