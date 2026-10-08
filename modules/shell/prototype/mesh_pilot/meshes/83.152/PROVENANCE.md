# 83.152 Fireplace Surround

Hugnet Frères (French, active in Paris ca. 1900), designer. *Fireplace Surround*, 1900. Walnut, ceramic tiles, and copper. 349.8 × 210.8 × 50.8 cm. RISD Museum 83.152.

| Step | What | Cost | sha256 |
| --- | --- | --- | --- |
| Source | the museum's catalogue photograph, `modules/shell/collection_rooms/assets/additions/marble-hall/fireplace-83.152.jpg` (see the `SOURCES.md` there) | — | — |
| Cut-out | `cut_photo.py`, saturation key inside the measured outline: `image-work/mesh-pilot-263/fireplace/trellis-input.png` | free | `0dcb3d1646687fee…` |
| Mesh | Flora, RISD EDU Workspace, Tripo H3.1 (`i3d-tripo-h3-1-i3d`), face limit 20,000, texture on, PBR off, geometry and texture "detailed"; run `run_m17fzd9jh9296yzs5ktnrmqwr18fx0ka` | quoted 0.72 USD, charged 0.72 USD | `36fa9958d9b79916…` |
| Photograph over the front | `project_photo.py`: view turn 90°, silhouette overlap 0.936; 33% of the texture repainted from the cut-out, the rest is Tripo's | free | — |
| Clean-up | `prepare_mesh.py`: back pressed flat onto the wall plane, depth 0.608 m → 0.508 m, width to 2.108 m | free | `17c29ba52f525f59c5970a885963a68f1ae1e64f97ff6df12a7f4de77be2b46a` |

17,824 triangles, one 2048 px texture. In the pack: 863 KB (mesh 252, texture 611). That is over the 400 KB aim; a 1024 px texture brings it to about 400 KB.

Known faults: where Tripo modelled the two women differently from the photograph, the photograph's figures lie slightly off the modelled ones. Seen close up only.
