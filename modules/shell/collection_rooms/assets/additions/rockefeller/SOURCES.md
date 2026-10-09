# Sources: Rockefeller additions

All pictures are RISD Museum catalogue photographs, taken 2026-10-01. Records come from
`https://risdmuseum.org/api/v1/collection` (Scrapling fetcher; plain requests get a 403). Every page
marks its images `data-asset-copyright="public"`. The pictures were not generated; the meshes listed at the end were.

| File | Work | Record | Picture | Credit line |
| --- | --- | --- | --- | --- |
| `neptune-2017.74.31.1.jpg`, `-cut.png`, `-cut.json` | Vincennes, *Neptune as River Deity*, 2017.74.31.1, 29.8 x 27 x 24 cm | https://risdmuseum.org/art-design/collection/neptune-river-deity-201774311 | https://risdmuseum.cdn.picturepark.com/v/zcDVQrOi/ | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `amphitrite-2017.74.31.2.jpg`, `-cut.png`, `-cut.json` | Vincennes, *Amphitrite as River Deity*, 2017.74.31.2, 29.8 x 28 x 19 cm | https://risdmuseum.org/art-design/collection/amphitrite-river-deity-201774312 | https://risdmuseum.cdn.picturepark.com/v/PID38amQ/ | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `smirke-2016.80.89.jpg` | Mary Smirke, *Cloisters' Wood*, 2016.80.89, image/sheet 16.6 x 24.5 cm | https://risdmuseum.org/art-design/collection/cloisters-wood-20168089 | https://risdmuseum.cdn.picturepark.com/v/PAPVDiBO/, cropped to the image inside its ruled border (172,163)-(1152,814) | Anonymous gift |
| `smirke-2016.80.91.jpg` | Mary Smirke, *A Lady in a Park*, 2016.80.91, image/sheet 13 x 21.2 cm | https://risdmuseum.org/art-design/collection/lady-park-20168091 | https://risdmuseum.cdn.picturepark.com/v/4cFTM57k/, cropped to the image (179,179)-(1121,778) | Anonymous gift |
| `textile-44.226.jpg` | Unknown maker, English, *Apparel textile length*, 44.226, length 99.7 cm | https://risdmuseum.org/art-design/collection/apparel-textile-length-44226 | https://risdmuseum.cdn.picturepark.com/v/CCn9f34h/, cropped to the textile (120,45)-(1250,2170) | Mary B. Jackson Fund |

The two `-cut.png` files are the front photographs with the studio ground removed (OpenCV GrabCut);
each `-cut.json` is the silhouette in 24 rows. The derivation script is
`docs/evidence/museum-238/grey-rockefeller/prep_assets.py`.

Identification: the Vincennes pair comes from the repository's earlier records. The two watercolours and
the silk length were found in this round: the label beside the prints reads "Mary Smirke" (IMG_6380
188.2 s) and both sheets match the catalogue photographs by eye; the silk matches by eye only
(IMG_6380 135.0 s, 195.6 s). None of the three was confirmed by a feature match.

## Generated meshes (#263, 8 October 2026, second batch)

Each was made on the Muse-first route and reduced to 10,000 triangles with one colour texture. Prompts, the ledger of every view and each mesh's full record are on `proto/mesh-pilot-263` under `image-work/mesh-pilot-263/batch/<accession>/` and `modules/shell/prototype/mesh_pilot/meshes/<accession>/PROVENANCE.md`. The meshes placed earlier (St. George, Hudibras, the Flute Player, Récamier, the sconces, candlesticks, Shepherd, Cow and the pair of parrots) are recorded there too.

| File | Work | Source and views | Mesh | SHA-256 |
| --- | --- | --- | --- | --- |
| `parrot-20177426.glb` | *Figure of a Parrot*. Earthenware with glaze. 15.6 × 17 × 7 cm. RISD Museum 2017.74.26 | the museum's catalogue photographs, redrawn as clay and flat colour views by Muse (OpenRouter, `meta/muse-image`): 9 images, 0.09 USD | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, run `run_m17cwhvbtrz2w43rdpw3t5sfjh8fxgjg`, 0.48 USD | `b94e8e2566191336bce4635d13d0df66076486b44d51f6d541e5d39782c8f932` |
| `bear-jug-horn-20177422ab.glb` | *Brown Bear Jug and Cover*. Stoneware with glaze. Height 16.2 cm. RISD Museum 2017.74.22.ab | the museum's catalogue photographs, redrawn as clay and flat colour views by Muse (OpenRouter, `meta/muse-image`): 5 images, 0.05 USD | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, run `run_m1711gzs4jwmmatx3918e5eppd8fyeav`, 0.48 USD | `5879db7fba33531ebaad46b4feb0ce6a4a331dbe59f135e02efa1a6bc94fbde1` |
| `bagpiper-20177421.glb` | *Figure of a Bagpiper*. Earthenware with glaze. 15 × 7 × 6 cm. RISD Museum 2017.74.21 | the museum's catalogue photographs, redrawn as clay and flat colour views by Muse (OpenRouter, `meta/muse-image`): 7 images, 0.07 USD | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, run `run_m178jr6bxaz9g9dh87g4qm0t4d8fz00z`, 0.48 USD | `cd8b63b0edc6930843bef9b5fcc9b5784dc7040696f239a151de59fce4fc3a60` |
| `horn-player-20177419.glb` | *Horn-Player*. Earthenware with glaze. 16.2 × 7 × 5 cm. RISD Museum 2017.74.19 | the museum's catalogue photographs, redrawn as clay and flat colour views by Muse (OpenRouter, `meta/muse-image`): 5 images, 0.05 USD | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, run `run_m178adefxgdayrwtr1gc8cy5kd8fzvz7`, 0.48 USD | `b9d3d686230bc0f8725bff4eaaf81ba2df1e9605c0c71cb752c94b0ae0a22098` |
| `fox-20177420.glb` | *Figure of a Fox*. Earthenware with glaze. 13.3 × 16.5 × 8 cm. RISD Museum 2017.74.20 | the museum's catalogue photographs, redrawn as clay and flat colour views by Muse (OpenRouter, `meta/muse-image`): 8 images, 0.08 USD | Flora, RISD EDU Workspace, Tripo H3.1 Multi-View, run `run_m1747dd07vs6444yq9nhwcxbpd8fztdf`, 0.48 USD | `0232a85b1798d3d0b2fe6ca408c2cf9aef77019d625d228756216d97d76fafaa` |
