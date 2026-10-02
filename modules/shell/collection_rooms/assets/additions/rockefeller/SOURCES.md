# Sources: Rockefeller additions

All pictures are RISD Museum catalogue photographs, taken 2026-10-01. Records come from
`https://risdmuseum.org/api/v1/collection` (Scrapling fetcher; plain requests get a 403). Every page
marks its images `data-asset-copyright="public"`. Nothing here was generated.

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
