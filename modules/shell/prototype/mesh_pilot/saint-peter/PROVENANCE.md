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
