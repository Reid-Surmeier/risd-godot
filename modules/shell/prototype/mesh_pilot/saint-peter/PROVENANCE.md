# Saint Peter 20.254, Muse-first trial (8 October 2026)

Unknown maker, French. *Saint Peter*, ca. 1106–1112. Limestone with traces of gesso and polychromy. 76.2 × 43.2 × 29.2 cm. RISD Museum 20.254.

One object made end to end on the route the owner asked for: Muse views first, then the mesh. Two mesh variants from the same views. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, fetched 8 Oct from https://risdmuseum.org/art-design/collection/saint-peter-20254 : frontal `kAkUzw6M`, rear `1iQiDAkY`, angled `EvBIZlFB`, front `tIpeAYa8` (kept outside git in `~/risd-godot-ingestion/mesh-pilot-263/saint-peter/catalogue/`) | free |
| Clay views | Muse `edit` (OpenRouter, `meta/muse-image`), 1440×1760, four images: front, three-quarter, back, left side. Prompts: `image-work/mesh-pilot-263/saint-peter/clay-*.prompt.txt` | 0.04 USD |
| Clay views, matched | three re-run with the front clay view as the material reference (`clay2-*.prompt.txt`); made after the meshes were queued, so the meshes below come from the first set | 0.03 USD |
| Colour views | Muse `edit`, four images: each first-pass clay view repainted in the stone's material from the matching photograph (`colour-*.prompt.txt`) | 0.04 USD |
| Mesh A | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View (`i3d-tripo-h3-1-multiview-i3d`), views front, left, back; geometry "detailed", texture off, face limit 20,000; run `run_m17c7g9058fcxv12dyrpzh8jds8fxp3d`; raw GLB `a11dc4864c96bfe8…` | quoted 0.48, charged 0.48 USD |
| Mesh B | the same, face limit 500,000; run `run_m171491xxxtkbyyf3nk50wdk3d8fw93x`; raw GLB `353caf2107d24b0b…` (481,316 triangles, not in git) | quoted 0.48, charged 0.48 USD |
| Blender | `clay_mesh.py` (Blender 5.2.2): turned 90° to face front; scaled to 0.762 m high; width set to 0.432 m (made 0.401) and depth to 0.292 m (made 0.327 for A, 0.330 for B). B: collapsed to 15,000 triangles, the high mesh baked onto it as a 1024 px normal map and an occlusion map (12 s) | free |
| Colour | `colour_mesh.sh`: the four colour views laid on one at a time (left, three-quarter, back, front), 1024 px; B's occlusion folded in at 25% | free |

| File | Triangles | Textures | In the pack |
| --- | --- | --- | --- |
| `saint-peter-a.glb` (`0ab141a4e6907322…`) | 19,760 | colour 1024 px | 544 KB (mesh 373, colour 171) |
| `saint-peter-b.glb` (`aa2fc64a18903fab…`) | 15,000 | colour 1024 px, normal map 1024 px | 933 KB (mesh 463, colour 236, normal 233) |

View image hashes: `image-work/mesh-pilot-263/saint-peter/views.sha256`. The view images themselves are not in git.

## Colour test (8 October, later)

| Step | What | Cost |
| --- | --- | --- |
| Corrected projection | `match_colour.py` (views brought to the catalogue photograph's colour), `colour_mesh2.sh` (views cross-faded; the 11.7% of the texture no view saw filled from its surroundings), `match_in_scene.py` (texture lifted until the figure, lit as in the game, matches the photograph: gain 1.44 / 1.57 / 1.80) | free |
| Generator texture | Flora, RISD EDU Workspace, Meshy 5 Retexture (`m3d2m3d-meshy-5-retexture`) on B's 15,000-triangle mesh, original UVs kept, PBR off, reference: the matched front colour view; run `run_m17cytc4rq4jt48m2ga7h412198fwd47`; raw GLB `5f2a1bd474ecf83f…`; its texture put on B beside B's normal map and given the same in-scene lift | quoted 0.36, charged 0.36 USD |

| File | What | In the pack |
| --- | --- | --- |
| `saint-peter-b3.glb` | B, corrected projection, 15,000 triangles, normal map 1024 px | 1,022 KB |
| `saint-peter-b4.glb` | B, Meshy texture, 15,000 triangles, normal map 1024 px | 963 KB |

Measured and not kept: 15,000 triangles with a 512 px normal map, 829 KB.

## Flat colour with baked occlusion (8 October, last)

| Step | What | Cost |
| --- | --- | --- |
| Flat colour views | Muse `edit`, four images lit evenly from all sides with no shading (`flat-*.prompt.txt`); the three-quarter still had shadow and was re-run once with the flat front as its reference (`flat2-threequarter.prompt.txt`) | 0.05 USD (5 images) |
| Colour | `colour_mesh2.sh` with those views (`VIEW_PREFIX=flat`), then the occlusion baked from the 481,316-triangle mesh multiplied over it. Two strengths tried, 0.35 and 0.60; 0.35 kept by eye against the photograph | free |
| Lift | `match_in_scene.py`: gain 1.45 / 1.53 / 1.79 for the lit scene; 1.42 / 1.32 / 1.26 when drawn unshaded | free |

| File | What | In the pack |
| --- | --- | --- |
| `saint-peter-c35.glb` | B (15,000 triangles, normal map 1024 px), flat colour x occlusion 0.35, colour 1024 px | 1,020 KB (mesh 463, normal 233, colour 324) |
| `saint-peter-d10k-c512.glb` | 10,000 triangles, normal map 512 px, the same colour at 512 px | 513 KB (mesh 311, normal 81, colour 120) |

Measured and not kept: 10,000 triangles, normal map 512 px, colour 1024 px: 704 KB (mesh 311, normal 81, colour 311).

## Batch-size candidate (8 October, measured without spending)

| File | What | In the pack |
| --- | --- | --- |
| `saint-peter-u10k.glb` | 10,000 triangles, no normal map, no tangents, flat colour x occlusion 0.35 at 512 px, lifted to the photograph's lit areas (gain 1.48 / 1.39 / 1.32); for drawing unshaded | 324 KB (mesh 204, colour 120) |
