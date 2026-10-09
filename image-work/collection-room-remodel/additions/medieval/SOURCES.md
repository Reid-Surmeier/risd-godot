# Medieval room additions: sources

All six records and photographs are from the RISD Museum online collection (risdmuseum.org),
fetched 2026-10-01 with Scrapling's HTTP fetcher. Each record page marks the object Public
Domain, CC0 1.0. No paid call was made. `make_assets.py` cut the photographs; nothing was
generated or redrawn.

| File | Object | Record | Photograph | Credit line |
| --- | --- | --- | --- | --- |
| `59.131-front.jpg`, `head-cut.jpg` | Head of Christ or a Saint, Unknown Maker, Spanish, ca. 1220-1240, walnut with polychromy, 81.3 x 50.8 x 50.8 cm | https://risdmuseum.org/art-design/collection/head-christ-or-saint-59131 | https://risdmuseum.cdn.picturepark.com/v/m78wVE8W/ | Museum Works of Art Fund 59.131 |
| `69.196-front.jpg`, `relief-cut.jpg` | Christ in Majesty, Unknown Maker, Spanish, ca. 1090-1100, limestone, 97.8 x 55.9 cm | https://risdmuseum.org/art-design/collection/christ-majesty-69196 | https://risdmuseum.cdn.picturepark.com/v/lUVDsSDa/ | Gift of John Nicholas Brown 69.196 |
| `43.195-front.jpg`, `cross-cut.jpg` | The Crucified Christ, Unknown Maker, Spanish, ca. 1150-1200, oak with traces of polychrome, 215.9 x 215.9 cm | https://risdmuseum.org/art-design/collection/crucified-christ-43195 | https://risdmuseum.cdn.picturepark.com/v/KmBdUFtl/ | Museum Special Reserve Fund 43.195 |
| `20.254-front.jpg`, `peter-cut.jpg` | Saint Peter, Unknown Maker, French, ca. 1106-1112, limestone with traces of gesso and polychromy, 76.2 x 43.2 x 29.2 cm | https://risdmuseum.org/art-design/collection/saint-peter-20254 | https://risdmuseum.cdn.picturepark.com/v/tIpeAYa8/ | Museum Appropriation Fund 20.254 |
| `16.243-front.jpg`, `anthony-cut.jpg` | St. Anthony Abbot Enthroned, Spinello Aretino, ca. 1385, tempera and gold on panel, 232.4 x 92.1 x 22.2 cm | https://risdmuseum.org/art-design/collection/st-anthony-abbot-enthroned-16243 | https://risdmuseum.cdn.picturepark.com/v/ySH7WpJ6/ | Gift of Jesse H. Metcalf 16.243 |
| `37.114-front.jpg`, `angel-cut.jpg` | Angel of the Annunciation, Unknown Maker, Italian (Sienese), ca. 1350, wood with polychromy, height 152.4 cm | https://risdmuseum.org/art-design/collection/angel-annunciation-37114 | https://risdmuseum.cdn.picturepark.com/v/LRWlG3nl/ | Museum Appropriation Fund 37.114 |

## Identification

59.131, 16.243 and 37.114 were already named in `sculpture-room-inventory.json`. The other
three were matched here by setting the catalogue photograph beside the footage:

1. **69.196 Christ in Majesty** is the "stone relief slab of a seated draped figure"
   (IMG_6382 36.0 s): raised right hand, inscribed book on the left knee, beaded collar and
   central band, both feet, the same slab outline. Found with the catalogue search "christ majesty".
2. **20.254 Saint Peter** is the "bust-length bearded figure with a staff" (IMG_6382 49-51.5 s):
   the "staff" is the key over his right shoulder, its ring in his hand. Found in the earlier
   agent's saved query `medieval-fragments-api-v1/query-review.json`.
3. **43.195 The Crucified Christ** was a candidate in the inventory; the photograph matches
   (IMG_6382 38.5-43 s): turban-like crown, loincloth with a ragged hem, both arms, no cross.

The wall labels are not legible in the footage, so none of the three was confirmed by its label.

## Sizes

Heights are the catalogue's. Widths follow each photograph's own outline (`shapes.json`
`aspect`), which agrees with the catalogue width within 5 % for the five objects that have one.
Depths are provisional: 16.243 is built 0.10 m deep on a 0.08 m backing (catalogue 22.2 cm
overall), the others 0.12 to 0.35 m by eye.

`37.114-front.jpg` was cropped on 8 October 2026 (#263) to the figure and its plinth, columns 180 to 1040 of the museum's 1200 px picture: the photograph has a white wedge in its top right corner and a pale strip down its left edge where the studio backdrop ends, and both fall outside the crop. Nothing else in the picture is changed.
