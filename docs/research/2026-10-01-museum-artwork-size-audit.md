# Museum artwork size audit — 2026-10-01

Checkout `consolidate-character-236`. Read-and-measure only: no project file was changed. 126 built artworks and objects were audited: 23 in the Main Hall and 103 in the seven added rooms.

The scene was dumped at `32d3ba8c` and again at `a29ad9e9`, after other sessions moved the checkout. The two dumps agree to the millimetre for every mesh except the visitor and its shadow (4 of 4,721), and both bakes are identical. Line numbers are those of `a29ad9e9`.

**Answer.** The canvases are almost all the catalogue size. What is wrong is mostly around them.

1. **Hang heights are wrong for 32 works.** 20 of the 23 Hall paintings hang 0.12–0.40 m too low and W6 hangs 0.30 m too high. The 14 Hall works built at a 1.55 m centre really hang at 1.72 m on average. In the added rooms the error goes the other way: the three European-gallery paintings are 0.13–0.29 m too high, the wallpaper panel 0.55 m too high, and the Madonna 58.196 is 0.31 m too low.
2. **Frames are the wrong width for 9 works.** S2 is built 2.7 times too wide (0.24 m against 0.09 m), S1 and E1 about twice, W10 1.4 times, Fetti 1.65 times. The Matisse frame is built at 0.4 of its real width.
3. **Seven Hall canvases have the wrong shape or size**, because the catalogue figure disagrees with the object on the wall: W7 is 10 % too tall, E8 is 6 % too short, W6 is 4 % too small, and W5, W2, W3 and E1 are 3.5–5 % off in aspect.
4. **Objects.** Both armchairs are 26 % too narrow and the Romanesque portal is 7–9 % too tall for its width; footage confirms the catalogue in both cases. Mrs. Edwards is about 6 % too wide. Three pieces of furniture have the wrong depth: the settee is 15 % shallow, the bookcase 12 % deep, the entrance armchair 8 % deep.

Totals: 41 wrong, 79 correct, 3 unidentified, 3 with no usable catalogue dimensions.

## How each number was obtained

| Label | Source | How |
|---|---|---|
| [code] | `works.json`, `remodel_room.gd`, `*_assets.gd`, `collection_rooms/assets/*.json` | Read at the cited line or key. A bare file name is the runtime copy under `collection_rooms/`, which `scripts/rebuild_rooms.sh` generates from `modules/shell/prototype/collection_reconstruction/`. The source `remodel_room.gd` is 43 lines longer (another session's room-additions loader), so every cited line is 43 higher there; the asset scripts have the same line numbers in both copies. |
| [dump] | Headless Godot 4.7.2 run of `main_build_walk.gd` (the scene the atlas photographs) | World bounds of every mesh. All 23 Hall paintings in `gallery_walk4/baked/room.tscn` and 1,357 of 1,357 single-source meshes in `collection_rooms/addition_baked/room.tscn` match the live geometry to 2 mm, so neither bake is stale. |
| [catalogue] | RISD API (`risdmuseum.org/api/v1/collection`) | 76 records were already in `image-work/collection-room-remodel/{catalogue,inventory-catalogue}/` and `collection_rooms/assets/`; 47 were fetched live on 2026-10-01 with the Scrapling fetcher (plain `curl` gets a Cloudflare 403), including all 23 Hall records. |
| [footage] | `risd-godot-ingestion/walkthrough/IMG_6344.MOV` (Hall), `collection-expansion/verified/IMG_638x.MOV` (rooms) | The official photograph is SIFT-matched to a frame. With the camera's focal length (890 px at 1080 x 1920, recovered from the homographies and equal to the 886–900 px in the existing COLMAP models) this fixes the wall plane, which is then resampled in metres. Sizes of Hall canvases come from the existing COLMAP models `sfm-6344-east/sparse/{0,1,2,3,5}` and `sfm-6344-west/sparse/0`. The armchair and portal checks use the existing room models `collection-expansion/sfm-connected-v4/sparse/5` and `6`, which have no metric scale. |

Footage error bars: visible canvas size ±1 % (two SfM methods agree to about 1 %); frame bands ±0.015 m; heights above the floor ±0.06 m in the Hall and ±0.08 m in the rooms. Times come from 4 and 5 fps extraction and are good to ±0.25 s.

The catalogue gives one figure per work with no "framed" note. For paintings it is the unframed support: in footage every Hall frame's outer edge lies outside the catalogue size by the frame band, and 15 of 23 visible canvases match the catalogue to 2.5 %. Exceptions are marked in the tables.

## 1. Every artwork

Ratios are built ÷ catalogue. "Verdict" also uses the footage columns. A work is called wrong when its canvas aspect is more than 3 % off, its frame band is outside 0.75–1.35 of the band seen, its centre is more than 0.10 m off, or its depth is more than 5 % off. Low-confidence readings are stated but not counted.

### Main Hall (Grand Gallery) — `modules/shell/prototype/gallery_walk4/works.json`, keys `canvas_w`, `canvas_h`, `hang`, `margins_px` per tag

Height is set by `walk4.gd:1921-1933` (`_hang_center`) from the `hang` string; the frame band by `painting_asset.gd:58-63`.

| Pos. | Title (maker) | Acc. | Catalogue H x W cm [catalogue, unframed] | Built canvas W x H m [code] | W ratio | H ratio | Built canvas centre / frame bottom m [dump] | Visible canvas W x H m [footage] | Frame band built / seen m | Canvas centre seen m [footage] | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|
| S1: S (arch-end) wall, east of door | Wisdom and Strength (Paolo Veronese) | 56.096 | 214.6 x 166.4 | 1.664 x 2.146 | 1.000 | 1.000 | 1.941 / 0.750 | 1.663 x 2.163 | 0.114 / 0.057 | 2.06 | wrong size (frame) — band x1.99: framed size should be 1.78 x 2.28; hung 0.12 m too low |
| S2: S (arch-end) wall, west of door | The Virgin and Child Appearing to Saint Francis of Assisi (Francesco Vanni) | 57.227 | 266.1 x 182.9 | 1.829 x 2.661 | 1.000 | 1.000 | 2.079 / 0.502 | 1.840 x 2.661 | 0.239 / 0.088 | 2.10 | wrong size (frame) — band x2.73: framed size should be 2.01 x 2.84 |
| W1: W wall, 1 of 10 from arch end | The Supper at Emmaus (Jan Cossiers) | 23.332 | 85.1 x 111.1 | 1.111 x 0.851 | 1.000 | 1.000 | 1.550 / 1.001 | 1.086 x 0.850 | 0.122 / 0.111 | 1.73 | correct size — hung 0.18 m too low |
| W2: W wall, 2 of 10 from arch end | Christ at the Column (Matthias Stom) | 56.177 | 182.9 x 114.5 | 1.145 x 1.829 | 1.000 | 1.000 | 1.500 / 0.363 | 1.101 x 1.834 | 0.218 / 0.212 | 1.90 | wrong aspect — canvas W/H is +4.3 % off: should be 1.101 x 1.834; hung 0.40 m too low |
| W3: W wall, 3 of 10 from arch end | The Resurrection of Christ (Benjamin Gerritsz. Cuyp) | 62.019 | 92.1 x 70.2 | 0.702 x 0.921 | 1.000 | 1.000 | 1.550 / 0.918 | 0.669 x 0.911 | 0.171 / 0.163 | 1.78 | wrong aspect — canvas W/H is +3.8 % off: should be 0.669 x 0.911; hung 0.23 m too low |
| W4: W wall, 4 of 10 from arch end | Portrait of a Woman (Bartholomeus van der Helst) | 60.009 | 111.8 x 97.2 | 0.980 x 1.120 | 1.008 | 1.002 | 1.550 / 0.842 | 0.941 x 1.089 | 0.145 / 0.152 | 1.70 | correct size — hung 0.15 m too low |
| W5: W wall, 5 of 10 from arch end | Charity (Fontainebleau School) | 57.157 | 158.1 x 133.4 | 1.334 x 1.581 | 1.000 | 1.000 | 1.550 / 0.616 | 1.300 x 1.623 | 0.141 / 0.113 | 1.72 | wrong aspect — canvas W/H is +5.3 % off: should be 1.300 x 1.623; frame band x1.25 (marginal, within reading error); hung 0.17 m too low |
| W6: W wall, 6 of 10 from arch end | The Angel of Fame (Giovanni Battista Tiepolo) | 32.246 | 198.1 x 330.8 † | 1.980 x 3.310 | 0.999 | 1.001 | 2.855 / 1.200 | 2.060 x 3.460 | none (shaped canvas) | 2.55 | wrong size — canvas -4 % W, -4 % H: should be ≈2.06 x 3.46; hung 0.30 m too high |
| W7: W wall, 7 of 10 from arch end | A Musical Group (Pier Leone Ghezzi) | 44.161 | 122.2 x 170.5 | 1.705 x 1.222 | 1.000 | 1.000 | 1.550 / 0.704 | 1.704 x 1.111 | 0.253 / 0.198 | 1.71 | wrong aspect — canvas W/H is -9.0 % off: should be 1.704 x 1.111; frame band x1.28 (marginal, within reading error); hung 0.16 m too low |
| W8: W wall, 8 of 10 from arch end | Allegorical Portrait of a Lady as Fortune (Henri Gascard) | 55.152 | 195.6 x 109.2 | 1.092 x 1.956 | 1.000 | 1.000 | 1.671 / 0.553 | 1.067 x 1.945 | 0.136 / 0.128 | 1.92 | correct size — hung 0.25 m too low |
| W9: W wall, 9 of 10 from arch end | The Marriage of Peleus and Thetis (Joachim Anthonisz Wtewael) | 62.058 | 109.5 x 166.4 | 1.664 x 1.095 | 1.000 | 1.000 | 1.550 / 0.873 | 1.667 x 1.099 | 0.131 / 0.100 | 1.73 | correct size — frame band x1.31 (marginal, within reading error); hung 0.18 m too low |
| W10: W wall, 10 of 10 from arch end | Still Life with Figure (Michele Pace del Campidoglio) | 60.107 | 122.2 x 160.7 | 1.607 x 1.222 | 1.000 | 1.000 | 1.550 / 0.749 | 1.609 x 1.222 | 0.194 / 0.135 | 1.73 | wrong size (frame) — band x1.44: framed size should be 1.89 x 1.48; hung 0.18 m too low |
| N1: N (far-end) wall, west of door | Portrait of a Lady of the Hampden Family (Anglo-Flemish, unknown) | 42.283 | 201.3 x 120 | 1.200 x 2.013 | 1.000 | 1.000 | 1.728 / 0.500 | 1.182 x 2.013 | 0.220 / 0.195 | 2.07 | correct size — hung 0.34 m too low |
| N2: N (far-end) wall, east of door | Portrait of Lady Sarah Ingestre (Thomas Lawrence) | 60.039 | 235.1 x 142.9 | 1.429 x 2.351 | 1.000 | 1.000 | 1.855 / 0.541 | 1.418 x 2.351 | 0.222 / 0.202 | 2.07 | correct size — hung 0.22 m too low |
| E1: E wall, 1 of 9 from far end | Arsenal in a Ruined Basilica (Alessandro Magnasco) | 63.061 | 146.7 x 214.6 | 2.146 x 1.467 | 1.000 | 1.000 | 1.550 / 0.648 | 2.069 x 1.464 | 0.173 / 0.090 | 1.76 | wrong aspect — canvas W/H is +3.5 % off: should be 2.069 x 1.464; wrong size (frame) — band x1.93: framed size should be 2.24 x 1.65; hung 0.21 m too low |
| E2: E wall, 2 of 9 from far end | Portrait of Theodore Atkinson, Jr. (1737-1769) (John Singleton Copley) | 18.264 | 127 x 101.6 | 1.016 x 1.270 | 1.000 | 1.000 | 1.550 / 0.775 | 1.000 x 1.270 | 0.139 / 0.137 | 1.72 | correct size — hung 0.17 m too low |
| E3: E wall, 3 of 9 from far end | Landscape with a Mill (Sébastien Bourdon) | 51.506 | 86 x 105.1 | 1.051 x 0.860 | 1.000 | 1.000 | 1.550 / 1.003 | 1.047 x 0.863 | 0.119 / 0.127 | 1.74 | correct size — hung 0.19 m too low |
| E4: E wall, 4 of 9 from far end | A View of Paris from the Louvre (Louise-Joséphine Sarazin de Belmont) | 1987.056 | 119.7 x 162.6 | 1.626 x 1.197 | 1.000 | 1.000 | 1.550 / 0.814 | 1.610 x 1.220 | 0.141 / 0.111 | 1.71 | correct size — frame band x1.26 (marginal, within reading error); hung 0.16 m too low |
| E5: E wall, 5 of 9 from far end | Portrait of Antoine-Georges-François de Chabaud-Latour and his Family (Jacques-Luc Barbier-Walbonne) | 2003.105 | 221 x 174 | 1.740 x 2.210 | 1.000 | 1.000 | 2.006 / 0.549 | 1.721 x 2.223 | 0.375 / 0.312 | 1.94 | correct — side and bottom rails x1.3 (0.35 built, 0.27 seen; corner ornaments reach 0.32), marginal; centre 0.07 m high, inside the 0.10 m threshold |
| E6: E wall, 6 of 9 from far end | Architectural Fantasy (Hubert Robert) | 37.104 | 114 x 147.8 | 1.478 x 1.140 | 1.000 | 1.000 | 1.550 / 0.856 | 1.456 x 1.132 | 0.126 / 0.105 | 1.69 | correct size — hung 0.14 m too low |
| E7: E wall, 7 of 9 from far end | The Ferry Boat (Salomon van Ruysdael) | 33.204 | 97.2 x 144.2 | 1.442 x 0.972 | 1.000 | 1.000 | 1.550 / 0.881 | 1.432 x 0.972 | 0.194 / 0.198 | 1.72 | correct size — hung 0.17 m too low |
| E8: E wall, 8 of 9 from far end | Portrait of a Cavalier with His Hunting Dogs (Bartolomeo Passarotti) | 62.064 | 197.5 x 114.9 | 1.149 x 1.975 | 1.000 | 1.000 | 1.661 / 0.493 | 1.138 x 2.104 | 0.176 / 0.154 | 1.88 | wrong aspect — canvas W/H is +7.6 % off: should be 1.138 x 2.104; hung 0.22 m too low |
| E9: E wall, 9 of 9 from far end | Hagar and Ishmael (Francisco Collantes) | 18.096 | 109.2 x 139.1 | 1.391 x 1.092 | 1.000 | 1.000 | 1.550 / 0.803 | 1.389 x 1.088 | 0.205 / 0.194 | 1.69 | correct size — hung 0.14 m too low |

† The record reads 198.1 x 330.8; the work hangs 3.3 m tall, so the pair is read as W x H.

W4: the visible image is 3 cm smaller than the catalogue each way, which is the frame's rebate; the build follows the catalogue and is left as correct.

N1 and N2 are each alone in their SfM model, so only their aspect is measured there; their height is confirmed to ±3 % by the baseboard under them (0.292 m and 0.300 m against the Hall mean of 0.30 m).

### Rockefeller decorative-arts room

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| N wall, centre, on 0.13 m platform | Bookcase | 2017.74.9 | 151.5 x 110 x 33 [overall] | 1.100 x 1.517 x 0.37 deep<br>`remodel_room.gd:649` | 1.000 | 1.001 | stands 0.13–1.647 | wrong size (depth) — 0.37 deep built, 0.33 catalogue (x1.12); width and height correct |
| in bookcase, top of bookcase (1.62) | St. George and the Dragon | 2017.74.14 | 26.4 x 20.3 x 12.3 [overall] | 0.203 x 0.264 x 0.123 deep<br>`catalogue-objects.json instances[0].size_m` | 1.000 | 1.000 | base at 1.62 | correct |
| in bookcase, top of bookcase (1.62) | The Flute Player | 2017.74.16 | 25.4 x 17.7 x 12.4 [overall] | 0.177 x 0.254 x 0.124 deep<br>`catalogue-objects.json instances[1].size_m` | 1.000 | 1.000 | base at 1.62 | correct |
| in bookcase, top of bookcase (1.62) | Hudibras | 2017.74.17 | 28.9 x 22.3 x 12.4 [overall] | 0.223 x 0.289 x 0.124 deep<br>`catalogue-objects.json instances[2].size_m` | 1.000 | 1.000 | base at 1.62 | correct |
| in bookcase, shelf 1.42 | Brown Bear Jug and Cover | 2017.74.18.ab | H 14 [height only] | 0.089 x 0.140 x 0.053 deep<br>`catalogue-objects.json instances[3].size_m` | — | 1.000 | base at 1.42 | correct height; width not catalogued (taken from the Muse silhouette) |
| in bookcase, shelf 1.42 | Horn-Player | 2017.74.19 | 16.2 x 7 x 5 [overall] | 0.070 x 0.162 x 0.050 deep<br>`catalogue-objects.json instances[4].size_m` | 1.000 | 1.000 | base at 1.42 | correct |
| in bookcase, shelf 1.42 | Finch | 2017.74.15.1 | H 5.1 [height only] | 0.059 x 0.051 x 0.035 deep<br>`catalogue-objects.json instances[5].size_m` | — | 1.000 | base at 1.42 | correct height; width not catalogued (taken from the Muse silhouette) |
| in bookcase, shelf 1.42 | Finch | 2017.74.15.2 | H 5.1 [height only] | 0.059 x 0.051 x 0.035 deep<br>`catalogue-objects.json instances[6].size_m` | — | 1.000 | base at 1.42 | correct height; width not catalogued (taken from the Muse silhouette) |
| in bookcase, shelf 1.42 | Figure of a Bagpiper | 2017.74.21 | 15 x 7 x 6 [overall] | 0.070 x 0.150 x 0.060 deep<br>`catalogue-objects.json instances[7].size_m` | 1.000 | 1.000 | base at 1.42 | correct |
| in bookcase, shelf 1.42 | Brown Bear Jug and Cover | 2017.74.22.ab | H 16.2 [height only] | 0.070 x 0.162 x 0.042 deep<br>`catalogue-objects.json instances[8].size_m` | — | 1.000 | base at 1.42 | correct height; width not catalogued (taken from the Muse silhouette) |
| in bookcase, shelf 1.19 | Cream Jug | 2017.74.25 | 15 x 11.7 x 9.5 [overall] | 0.117 x 0.150 x 0.095 deep<br>`catalogue-objects.json instances[9].size_m` | 1.000 | 1.000 | base at 1.19 | correct |
| in bookcase, shelf 1.19 | Parrot | 2017.74.27.1 | 16.5 x 17 x 7 [overall] | 0.170 x 0.165 x 0.070 deep<br>`catalogue-objects.json instances[10].size_m` | 1.000 | 1.000 | base at 1.19 | correct |
| in bookcase, shelf 1.19 | Figure of a Fox | 2017.74.20 | 13.3 x 16.5 x 8 [overall] | 0.165 x 0.133 x 0.080 deep<br>`catalogue-objects.json instances[11].size_m` | 1.000 | 1.000 | base at 1.19 | correct |
| in bookcase, shelf 1.19 | Parrot | 2017.74.27.2 | 16.5 x 16 x 6.5 [overall] | 0.160 x 0.165 x 0.065 deep<br>`catalogue-objects.json instances[12].size_m` | 1.000 | 1.000 | base at 1.19 | correct |
| in bookcase, shelf 1.19 | Agateware Teapot | 2017.74.24.ab | 13.3 x 45.7 [overall] | 0.190 x 0.133 x 0.115 deep<br>`catalogue-objects.json instances[13].size_m` | 0.416 | 1.000 | base at 1.19 | no usable catalogue width — record says 45.7 cm wide, built 0.19 m by video fit; height correct |
| in bookcase, shelf 0.91 | Figure of a Shepherd | 2017.74.23 | 21.3 x 8 x 8 [overall] | 0.080 x 0.213 x 0.080 deep<br>`catalogue-objects.json instances[14].size_m` | 1.000 | 1.000 | base at 0.91 | correct |
| in bookcase, shelf 0.91 | Figural Candlestick | 2017.74.28.1 | 21 x 12 x 11 [overall] | 0.120 x 0.210 x 0.110 deep<br>`catalogue-objects.json instances[15].size_m` | 1.000 | 1.000 | base at 0.91 | correct |
| in bookcase, shelf 0.91 | Model of a Cow | 2017.74.29 | 13 x 21 x 8 [overall] | 0.210 x 0.130 x 0.080 deep<br>`catalogue-objects.json instances[16].size_m` | 1.000 | 1.000 | base at 0.91 | correct |
| in bookcase, shelf 0.91 | Figural Candlestick | 2017.74.28.2 | 21.6 x 12 x 11 [overall] | 0.120 x 0.216 x 0.110 deep<br>`catalogue-objects.json instances[17].size_m` | 1.000 | 1.000 | base at 0.91 | correct |
| in bookcase, shelf 0.91 | Figure of a Parrot | 2017.74.26 | 15.6 x 17 x 7 [overall] | 0.170 x 0.156 x 0.070 deep<br>`catalogue-objects.json instances[18].size_m` | 1.000 | 1.000 | base at 0.91 | correct |
| in bookcase, shelf 1.42 | Ewe and Lamb | 2017.74.32 | 9.5 x 15 x 9 [overall] | 0.150 x 0.095 x 0.090 deep<br>`catalogue-objects.json instances[20].size_m` | 1.000 | 1.000 | base at 1.42 | correct for the candidate record (identity not photo-verified) |
| W wall plinth (beside settee) | Bust of Madame Récamier | 37.201 | 60.6 x 33.7 x 23.5 [overall] | 0.337 x 0.606 x 0.235 deep<br>`catalogue-objects.json instances[19].size_m` | 1.000 | 1.000 | base 1.30, top 1.906 | correct |
| N wall, left of bookcase | Mirror | 2017.74.4.2 | 231.1 x 91.4 [overall] | 0.914 x 2.311<br>`remodel_room.gd:699` | 1.000 | 1.000 | 0.996–3.305 (centre 2.15, :701) | correct size; top is 0.195 m under the 3.5 m ceiling, footage shows ≈0.22 m (IMG_6380 230.75 s) |
| N wall, right of bookcase | Mirror | 2017.74.4.1 | 231.1 x 91.4 [overall] | 0.914 x 2.311<br>`remodel_room.gd:699` | 1.000 | 1.000 | 0.996–3.305 (centre 2.15, :701) | correct size; hang as above |
| N wall, above bookcase | Portrait of Mrs. Edwards (John Constable) | 58.197 | 76 x 63.7 [unframed] | 0.637 x 0.760 (outer 0.816 x 0.939)<br>`remodel_room.gd:734` | 1.000 | 1.000 | canvas centre 2.43; frame 1.979–2.918 | wrong aspect (minor) — official photo 0.789 and footage sight 0.80 against built 0.838; canvas ≈0.60 x 0.76 (medium-low confidence). Frame and height agree with footage |
| W wall, above settee | Portrait of the Dancer, Auguste Vestris (Adèle Romany) | 2009.9 | 95.2 x 76.2 [unframed] | 0.762 x 0.952 (outer 1.036 x 1.241)<br>`remodel_room.gd:735` | 1.000 | 1.000 | canvas centre 2.12; frame 1.512–2.754 | correct size; frame agrees (0.12–0.13 m); height not measurable (floor hidden by settee), frame–settee gap 0.44 built vs ≈0.30 seen |
| E wall, by gold-service case | Arabesque Wallpaper (François Louis Prieur) | 34.912 | 114.5 x 56 [sheet] | 0.560 x 1.145 (mount 0.76 x 1.345)<br>`remodel_room.gd:751` | 1.000 | 1.000 | centre 2.10 (:752); paper 1.528–2.672 | correct size; hung 0.55 m too high — paper bottom is 0.98 m above the floor (IMG_6380 159.75 s), centre should be ≈1.55 |
| W wall, on platform | Settee | 2017.74.5 | 94 x 139 x 77 [overall] | 1.376 x 0.940 x 0.655 deep<br>`remodel_room.gd:812,828 + settee-parts.json` | 0.990 | 1.000 | 0.13–1.07 | wrong size (depth) — 0.655 deep built, 0.77 catalogue (x0.85); width and height correct |
| N wall, right of bookcase, on platform | Armchair | 2017.74.7.1 | 93 x 82 x 57 [overall] | 0.604 x 0.930 x 0.55 deep<br>`remodel_room.gd:812,828` | 0.737 | 1.000 | 0.13–1.06 | wrong size — width 0.604 should be 0.82 (seat `width` .56 at :828); pair of 2017.74.7.2, not measured separately in footage; 0.55 deep built vs 0.57 |
| N wall, left of bookcase, on platform | Armchair | 2017.74.7.2 | 93 x 82 x 57 [overall] | 0.604 x 0.930 x 0.55 deep<br>`remodel_room.gd:812,828` | 0.737 | 1.000 | 0.13–1.06 | wrong size — width 0.604 should be 0.82. Footage agrees: arm tip to arm tip is 0.90 of the height (IMG_6380 143.2 s), catalogue 0.88, built 0.65; 0.55 deep built vs 0.57 |
| W wall near door, on platform | Armchair (pierced-loop back) | 2017.74.12 | 94 x 68 x 58 [overall] | 0.676 x 0.939 x 0.625 deep<br>`remodel_room.gd:812 + entrance-chair-parts.json` | 0.994 | 0.999 | 0.13–1.069 | wrong size (depth) — 0.625 deep built, 0.58 catalogue (x1.08); width and height correct |
| S wall, east of door | Wall Sconce (deer) | 2017.74.6.3 | 87.6 x 48.3 x 21.5 [overall] | 0.483 x 0.876 x 0.215 deep<br>`catalogue-objects.json instances[21].size_m` | 1.000 | 1.000 | 2.08–2.956 | correct size; height not measured |
| S wall, west of door | Wall Sconce (bird) | 2017.74.6.4 | 87.6 x 48.3 x 25 [overall] | 0.483 x 0.876 x 0.25 deep<br>`catalogue-objects.json instances[22].size_m` | 1.000 | 1.000 | 2.08–2.956 | correct size; height not measured |
| W wall, on platform | Writing Table | 2017.74.8 | 72 x 42 x 26 [overall] | 0.420 x 0.720 x 0.26 deep<br>`catalogue-objects.json instances[23].size_m` | 1.000 | 1.000 | 0.13–0.85 | correct for the candidate record; identity unconfirmed (filmed table is half-round) |
| gold-service case (E side) | Soup Tureen with Cover on Stand (Rockefeller Service) | 2017.74.38.1a-c | 28 x 35 x 26.7 [overall] | 0.350 x 0.280 x 0.267 deep<br>`catalogue-objects.json instances[24].size_m` | 1.000 | 1.000 | base at 1.20 | correct |
| gold-service case (E side) | Ecuelle with Cover (Rockefeller Service) | 2017.74.38.3a-c | 14 x 19.5 x 19.5 [overall] | 0.195 x 0.140 x 0.195 deep<br>`catalogue-objects.json instances[25].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| gold-service case (E side) | Pierced Basket and Stand (Rockefeller Service) | 2017.74.38.4ab | 10 x 20.5 x 17.5 [overall] | 0.205 x 0.100 x 0.175 deep<br>`catalogue-objects.json instances[26].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| gold-service case (E side) | Pierced Basket and Stand (Rockefeller Service) | 2017.74.38.5ab | 10 x 20.5 x 17.5 [overall] | 0.205 x 0.100 x 0.175 deep<br>`catalogue-objects.json instances[27].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| gold-service case (E side) | Square Dish (Rockefeller Service) | 2017.74.38.11 | 3.7 x 19 x 19 [overall] | 0.190 x 0.037 x 0.190 deep<br>`catalogue-objects.json instances[28].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| gold-service case (E side) | Square Dish (Rockefeller Service) | 2017.74.38.12 | 3.9 x 19 x 19 [overall] | 0.190 x 0.039 x 0.190 deep<br>`catalogue-objects.json instances[29].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| gold-service case (E side) | Dinner Plate (Rockefeller Service) | 2017.74.38.23 | 2.5 x 25 x 25 [overall] | 0.250 x 0.025 x 0.250 deep<br>`catalogue-objects.json instances[30].size_m` | 1.000 | 1.000 | base at 1.19 | correct |
| gold-service case (E side) | Dinner Plate (Rockefeller Service) | 2017.74.38.25 | 2.6 x 25 x 25 [overall] | 0.250 x 0.026 x 0.250 deep<br>`catalogue-objects.json instances[31].size_m` | 1.000 | 1.000 | base at 1.19 | correct |
| gold-service case (E side) | Saucer (Rockefeller Service) | 2017.74.38.9 | 3.6 x 14.4 x 14.4 [overall] | 0.144 x 0.036 x 0.144 deep<br>`catalogue-objects.json instances[32].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| gold-service case (E side) | Saucer (Rockefeller Service) | 2017.74.38.10 | 3.9 x 14.4 x 14.4 [overall] | 0.144 x 0.036 x 0.144 deep<br>`catalogue-objects.json instances[33].size_m` | 1.000 | 0.923 | base at 1.10 | correct (0.036 built vs 0.039, 3 mm) |
| gold-service case (E side) | Cup (Rockefeller Service) | 2017.74.38.7 | 6.7 x 8.8 x 6.8 [overall] | 0.088 x 0.067 x 0.068 deep<br>`catalogue-objects.json instances[34].size_m` | 1.000 | 1.000 | base at 1.13 | correct |
| gold-service case (E side) | Cup (Rockefeller Service) | 2017.74.38.8 | 6.9 x 8.7 x 6.8 [overall] | 0.087 x 0.069 x 0.068 deep<br>`catalogue-objects.json instances[35].size_m` | 1.000 | 1.000 | base at 1.13 | correct |
| pink Worcester case (S side) | covered tureen and stand (Worcester) | 2017.74.39.18a-c | 45.7 x 55.9 x 35.6 [overall] | 0.420 x 0.320 x 0.267 deep<br>`catalogue-objects.json instances[36].size_m` | 0.751 | 0.700 | base at 1.10 | no usable catalogue dimensions — record (round inches) is 40–50 % larger than the piece filmed beside the 25 cm plates; built by video fit |
| pink Worcester case (S side) | covered sauce tureen and stand (Worcester) | 2017.74.39.19a-c | 48.3 x 55.9 x 30.5 [overall] | 0.420 x 0.320 x 0.250 deep<br>`catalogue-objects.json instances[37].size_m` | 0.751 | 0.663 | base at 1.10 | no usable catalogue dimensions — record (round inches) is 40–50 % larger than the piece filmed beside the 25 cm plates; built by video fit |
| pink Worcester case (S side) | compote (Worcester) | 2017.74.39.3 | 9.7 x 30.6 x 22.2 [overall] | 0.306 x 0.097 x 0.222 deep<br>`catalogue-objects.json instances[38].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| pink Worcester case (S side) | square bowl (Worcester) | 2017.74.39.12 | 4.4 x 20.5 x 20.5 [overall] | 0.205 x 0.044 x 0.205 deep<br>`catalogue-objects.json instances[39].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| pink Worcester case (S side) | square bowl (Worcester) | 2017.74.39.13 | 4.4 x 20.5 x 20.5 [overall] | 0.205 x 0.044 x 0.205 deep<br>`catalogue-objects.json instances[40].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| pink Worcester case (S side) | dish (Worcester) | 2017.74.39.2 | 4.5 x 28.9 x 22.2 [overall] | 0.289 x 0.045 x 0.222 deep<br>`catalogue-objects.json instances[41].size_m` | 1.000 | 1.000 | base at 1.10 | correct |
| pink Worcester case (S side) | ladle (Worcester) | 2017.74.39.20 | 17 x 15 x 6.6 [overall] | 0.150 x 0.170 x 0.066 deep<br>`catalogue-objects.json instances[42].size_m` | 1.000 | 1.000 | base at 1.15 | correct |

### European (adjacent) gallery

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| W wall, by Rockefeller door, on 0.13 m platform | Drop-Front Secretary (Guillaume Beneman) | 80.106 | 143.5 x 114.3 x 42.6 [overall] | 1.143 x 1.435 x 0.426 deep<br>`catalogue-objects.json instances[43].size_m` | 1.000 | 1.000 | 0.13–1.565 | correct |
| W wall, after the secretary | Arabs Traveling (Eugène Delacroix) | 35.786 | 54.1 x 65.1 [unframed] | 0.651 x 0.541 (outer 0.947 x 0.813)<br>`remodel_room.gd:941` | 1.000 | 1.000 | canvas centre 1.75 (:945); frame 1.344–2.157 | correct size; frame agrees (0.14–0.15 m); hung 0.17 m too high — canvas bottom 1.27–1.31 m (IMG_6385 28.25 s, IMG_6386 60.75 s), centre should be ≈1.57 |
| W wall, mid-gallery | Christ Ministered To by the Angels (Domenico Fetti) | 36.003 | 89.5 x 78.1 [unframed] | 0.781 x 0.895 (outer 1.107 x 1.233)<br>`remodel_room.gd:950` | 1.000 | 1.000 | canvas centre 1.80 (:951); frame 1.184–2.416 | wrong size (frame) — band 0.165 built vs 0.10 seen: outer should be 0.98 x 1.10; hung 0.29 m too high — canvas bottom 1.06 m (IMG_6386 30.5 s), centre should be ≈1.51 |
| W wall, far end | Christ on the Cold Stone with Two Angels (Hendrick Goltzius) | 61.006 | 51 x 34.5 [unframed; copper panel support] | 0.345 x 0.510 (outer 0.482 x 0.642)<br>`remodel_room.gd:995` | 1.000 | 1.000 | canvas centre 1.75 (:996); frame 1.437–2.079 | correct size (outer 0.46 x 0.66 seen); hung 0.13 m too high — panel bottom 1.37 m (IMG_6386 0.0 s), centre should be ≈1.62 |

### Grey French gallery

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| W wall | Jura Landscape (Gustave Courbet) | 43.571 | 59.7 x 73.3 [unframed] | 0.733 x 0.597 (outer 0.981 x 0.912)<br>`courbet-frame-geometry.json canvas_m; remodel_room.gd:487` | 1.000 | 1.000 | canvas centre 1.80; frame 1.333–2.245 | correct size; side bands thin (0.124 built vs ≈0.165); probably 0.15–0.2 m too high — baseboard top is 1.12 m below the canvas (IMG_6380 3.5 s), floor line out of frame |
| N wall | Banks of a River Dominated in the Distance by Hills (J.-B.-C. Corot) | 24.089 | 31.9 x 46 x 3.8 [unframed; third number is thickness] | 0.460 x 0.319 (outer 0.606 x 0.501)<br>`corot-frame-geometry.json canvas_m; remodel_room.gd:487` | 1.000 | 1.000 | canvas centre 1.80; frame 1.537–2.038 | correct size (outer 0.60 x 0.475 seen, weak match, IMG_6380 29.25 s); height not determined |
| S (Hall-door) wall | Tivoli (Jean-Victor Bertin) | 56.214 | 48.9 x 65.1 [unframed] | 0.651 x 0.489 (outer 0.760 x 0.634)<br>`bertin-frame-geometry.json canvas_m; remodel_room.gd:487` | 1.000 | 1.000 | canvas centre 1.75; frame 1.440–2.075 | correct — band ≈0.07–0.085 seen; centre 1.69–1.77 seen (IMG_6380 92.5 s) |

### Renaissance room

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| N wall, right of European door | Madonna and Child (Pietro Perugino) | 16.236 | 57.5 x 39.1 [unframed] | 0.391 x 0.575 (outer 0.512 x 0.820)<br>`remodel_room.gd:1062` | 1.000 | 1.000 | canvas centre 1.55 (:1063); frame 1.177–1.997 | correct panel; tabernacle frame short — 0.82 built vs ≈0.93 seen (cornice 0.20 and base 0.15 against 0.16 and 0.085), cornice overhang 0.73 wide not modelled (IMG_6383 38.25 s); height not determined (floor out of frame) |
| N wall case, left of door | Madonna Enthroned, with Saints and Angels (Lippo di Benivieni), triptych | 2021.131 | 67 x 72.5 (open) [overall] | 0.722 x 0.670<br>`triptych-2021131-geometry.json panels[].size_m; remodel_room.gd:1171` | 0.996 | 1.000 | 1.08–1.75 in wall case | correct (open width 0.722 vs 0.725) |
| W wall case, north of window | Pietà (Tilman Riemenschneider) | 59.128 | 45.7 x 38.1 x 13.2 [overall] | 0.381 x 0.457 x 0.132 deep<br>`pieta_asset.gd:20` | 1.000 | 1.000 | 1.08–1.537 in wall case | correct |
| W side, floor plinth before window | Saint Roch | 21.398 | H 105.4 [height only] | 0.545 x 1.054 x 0.278 deep<br>`saint_roch_asset.gd:14` | — | 1.000 | 0.68–1.734 | correct height (only height catalogued); plinth 0.68 built vs ≈0.57 seen (IMG_6383 62 s, by eye) |
| E wall case A (back panel) | Portrait of a Cleric (Bruges Master) | 45.042 | 22.2 x 14.6 x 5.7 [unframed] | 0.146 x 0.222 (outer 0.234 x 0.322)<br>`renaissance_case_a_assets.gd:16-35` | 1.000 | 1.000 | panel centre 1.58 | correct panel; frame bands 0.044/0.05 from film (outer 0.234 x 0.322) |
| E wall case A (back panel) | Portrait of a Woman (Jan Joest) | 34.861 | 36.2 x 24.8 [overall] | 0.248 x 0.362<br>`renaissance_case_a_assets.gd:16-35` | 1.000 | 1.000 | centre 1.58 | correct per catalogue; photo is 0.731 wide per high vs catalogue 0.685 (noted in the asset file) |
| E wall case A (deck) | Diptych with scenes of the Nativity, the Crucifixion, and the Last Judgement | 22.201 | 24.1 x 13.3 (each) [panel] | 0.133 x 0.241<br>`renaissance_case_a_assets.gd:16-35` | 1.000 | 1.000 | on mount, 1.10–1.20 (lying) | correct (each leaf) |
| E wall case A (deck) | Book cover | 34.016 | 14 x 8.6 x 5.1 [overall] | 0.086 x 0.140 x 0.051 deep<br>`renaissance_case_a_assets.gd:16-35` | 1.000 | 1.000 | 1.08–1.295 | correct |
| E wall case A (deck) | One Hundred Christian Emblems (Georgette de Montenay) | 2023.17 | 197 x 147 mm [page] | 0.147 x 0.197<br>`renaissance_case_a_assets.gd:16-35` | 1.000 | 1.000 | 1.08–1.29 (open, reclined) | correct (page size) |
| E wall case A (deck) | Drug Jar (Albarello) | 35.713 | 24.1 x 13 [overall] | 0.130 x 0.241<br>`renaissance_case_a_assets.gd:16-35` | 1.000 | 1.000 | 1.08–1.321 | correct |
| E wall case B (back panel) | Bella Donna Plate (Castel Durante) | 46.391 | D 22.5 [diameter] | 0.225 x 0.225<br>`renaissance_case_b_assets.gd:28-49` | 1.000 | 1.000 | centre 1.55 | correct |
| E wall case B (back panel) | Bella Donna Plate | 57.302 | D 23.2 [diameter] | 0.232 x 0.232<br>`renaissance_case_b_assets.gd:28-49` | 1.000 | 1.000 | centre 1.55 | correct |
| E wall case B (deck) | Death of the Virgin (roundel) | 51.105 | D 11.1 [diameter] | 0.111 x 0.111<br>`renaissance_case_b_assets.gd:28-49` | 1.000 | 1.000 | 1.11–1.18 (tilted) | correct |
| E wall case B (deck) | The Virgin as the Woman of the Apocalypse (glass roundel) | 2017.29 | D 190 mm [diameter] | 0.190 x 0.190<br>`renaissance_case_b_assets.gd:28-49` | 1.000 | 1.000 | 1.11–1.31 | correct |
| E wall case B (deck) | Virgin and Child with Clerics and Donors (Pierre Reymond), probable | 34.024 | 12.9 x 10.7 [overall] | 0.107 x 0.129<br>`renaissance_case_b_assets.gd:28-49` | 1.000 | 1.000 | 1.10–1.20 (tilted) | correct for the probable record; label not legible in film |
| S wall, east half, above platform | Velvet Cover | 23.307X | 127 (length) | 0.500 x 1.270 (mount 0.971 x 1.448)<br>`renaissance_wall_assets.gd:28-41` | — | 1.000 | centre 1.31; cloth 0.675–1.945 | correct to catalogue length; footage gives 1.32 m against the tapestry (IMG_6383 8.5–8.75 s, x1.04); width is not catalogued; sits ≈0.10 m higher above the platform than built |
| S wall, west half, above platform | The Woodcutters (tapestry) | 29.280 | 152.4 x 94 [overall] | 0.940 x 1.524<br>`renaissance_wall_assets.gd:28-41` | 1.000 | 1.000 | centre 1.35; 0.588–2.112 | correct size; bottom is ≈0.53 m above the platform top in footage vs 0.43 built (platform height not measured) |
| W wall, south of window | Madonna and Child with Saint Barbara and Saint Catherine | 58.196 | 91.4 x 87 [unframed] | 0.870 x 0.914 (outer 1.005 x 1.060)<br>`renaissance_wall_assets.gd:28-41` | 1.000 | 1.000 | centre 1.22; panel 0.763–1.677; frame 0.690–1.750 | correct size, frame agrees (0.08 m); hung 0.31 m too low — panel bottom 1.075 m above floor (IMG_6383 15.0 s), centre should be ≈1.53 |
| E doorway to medieval room, on shafts | Tracery Arch | 40.156.1 | 109.2 x 141 x 27.3 [overall] | 1.410 x 1.092 x 0.273 deep<br>`tracery-arch-geometry.json size_m; remodel_room.gd:1073` | 1.000 | 1.000 | 2.25–3.342 | correct; springing height 2.25 m is not measured |

### Medieval room

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| S end / Hall arch doorway | Romanesque Portal | 40.014 | 386.1 x 422.9 [overall] | 4.180 x 4.140 (x 1.77 deep)<br>`walk4.gd:37-46 (DOORS.arch) and :1249 (_portal_stone); retained in baked/room.tscn Surface004/005` | 0.988 | 1.072 | 0–4.14 (hood to 4.22) | wrong aspect — width 4.18 over the impost ends (4.08 over the masonry) vs 4.229 is right; height 4.14 (third order) to 4.22 (hood) vs 3.861 is 7–9 % tall. Footage confirms the catalogue height: 3.83 m in near frames, 3.75 m in a far one (IMG_6382 1.2–5.8 s and 88.75 s, ±4 %) |
| W wall | Madonna and Child (Bartolo di Fredi) | 20.207 | 90.2 x 63.5 [overall, integral frame] | 0.635 x 0.902<br>`panel-20.207.json size_m; remodel_room.gd:1090` | 1.000 | 1.000 | centre 1.55; 1.099–2.001 | correct size; ≈0.12 m too high — bottom ≈0.95–1.0 m (IMG_6382 68.0 s, ±0.08) |
| W wall | Virgin of the Annunciation (Matteo di Giovanni) | 57.301 | 73.7 x 41.9 x 3.2 [overall; third number is thickness] | 0.419 x 0.737<br>`panel-57.301.json size_m; remodel_room.gd:1090` | 1.000 | 1.000 | centre 1.55; 1.182–1.918 | correct size (ratio to 20.207 in one frame 0.85–0.86 vs 0.817, IMG_6382 67.75–69.25 s); ≈0.15 m too high; built 0.35 m too far from 20.207 (centres 1.22 m apart vs 0.87 seen) |
| N wall | The Taking of Saint Peter (Jacopo di Cione) | 22.047 | 38.7 x 54 [overall] | 0.540 x 0.387<br>`panel-22.047.json size_m; remodel_room.gd:1090` | 1.000 | 1.000 | centre 1.55; 1.357–1.744 | correct size; ≈0.16 m too high — bottom ≈1.2 m (IMG_6382 74.25 s, ±0.08) |
| N wall | Mary Magdalene (Lippo Memmi) | 21.250 | 49.5 x 22.5 [read as painted panel] | 0.225 x 0.495 (gabled frame 0.296 x 0.585)<br>`remodel_room.gd:1640; magdalene-frame.json` | 1.000 | 1.000 | painted panel 1.302–1.798; gabled frame 1.260–1.845 | correct if the catalogue size is the painted panel (its 0.455 aspect matches the painted area 0.444, not the framed object 0.494); not checked against a second object in footage |
| N wall, right of portal, on 0.12 m plinth | Iron grille | — | — | 0.980 x 2.380<br>`medieval-grille-geometry.json size_m; remodel_room.gd:1506` | — | — | 0.12–2.50 | unidentified — no accession matched (geometry file: catalogue_identity unmatched; 17 rows provisional). Footage: the front leaf is 2.11 m tall and about 0.7–0.8 m wide, its top 2.30 m above the floor, with a second leaf folded behind (IMG_6382 12.25 s, ±4 %); built as one panel with its top at 2.50 m |
| E (stair-door) wall, left bracket | Apostle | 41.046 | 82.6 x 26.7 [overall] | 0.267 x 0.826 x 0.12 deep<br>`catalogue-objects.json instances[44].size_m` | 1.000 | 1.000 | 1.04–1.866 on bracket | correct size; bracket height not measured |
| E (stair-door) wall, right bracket | Apostle | 41.045 | 86.4 x 25.4 [overall] | 0.254 x 0.864 x 0.12 deep<br>`catalogue-objects.json instances[45].size_m` | 1.000 | 1.000 | 1.04–1.904 on bracket | correct size; bracket height not measured |
| tall case | Virgin and Child | 15.108 | H 39.4 [height only] | 0.223 x 0.394<br>`virgin_child_asset.gd:10` | — | 1.000 | 1.12–1.514 | correct height (only height catalogued) |
| tall case | God Save the Queens (Léopold L. Foulem) | 2020.55 | 33 x 16 x 16 [overall] | 0.160 x 0.330 x 0.16 deep<br>`medieval_ceramic_ivory_assets.gd:14` | 1.000 | 1.000 | 0.985–1.315 | correct |
| tall case | Monstrance | 40.002 | H 46.4 [height only] | 0.176 x 0.464<br>`medieval_metal_assets.gd:13` | — | 1.000 | 0.93–1.394 | correct height (only height catalogued) |
| tall case | Communion Beaker, probable | 1992.051 | H 14 [height only] | 0.095 x 0.140<br>`medieval_metal_assets.gd:14` | — | 1.000 | 0.93–1.07 | correct height for the probable record |
| tall case | Pyx, probable | 30.011 | H 8.9 [height only] | 0.064 x 0.089<br>`medieval_metal_assets.gd:15` | — | 1.000 | 0.93–1.019 | correct height for the probable record |
| tall case, on wedge | Christ in Majesty, probable | 2014.110 | 15.9 x 6.4 [overall] | 0.064 x 0.159<br>`medieval_ceramic_ivory_assets.gd:18` | 1.000 | 1.000 | lying on wedge 0.95–1.03 | correct for the probable record |
| tall case, on rod stand | Pax | 52.002 | 12.1 x 8.9 x 2.2 (without handle) [overall] | 0.089 x 0.121 x 0.022 deep<br>`medieval_metal_assets.gd:16` | 1.000 | 1.000 | leaning, 1.05–1.135 | correct |
| low case | Paper L1 | — | — | 0.070 x 0.090<br>`remodel_room.gd:1274` | — | — | flat at 0.935 | unidentified — filmed image on a paper slot, no accession |
| low case | Paper L2 | — | — | 0.270 x 0.160<br>`remodel_room.gd:1275` | — | — | flat at 0.935 | unidentified — filmed image on a paper slot, no accession |

### Lion stair landing

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| N wall, right of modern-gallery door | Panel with Striding Lion | 34.652 | 104.1 x 228.6 [overall] | 2.286 x 1.041<br>`catalogue-objects.json instances[46].size_m` | 1.000 | 1.000 | 1.180–2.221 | correct — bottom ≈1.15 m in footage (IMG_6387 42.0 s, ±0.08) |

### Modern painting gallery

| Wall / position | Title | Acc. | Catalogue cm, H x W (x D) [what it measures] | Built m, W x H [code: file:line or key] | W ratio | H ratio | Built height above floor m | Verdict |
|---|---|---|---|---|---|---|---|---|
| S (entry) wall | Still Life (Georges Braque) | 48.248 | 46.4 x 72.1 [unframed] | 0.721 x 0.464 (outer 0.881 x 0.624)<br>`remodel_room.gd:1396` | 1.000 | 1.000 | canvas centre 1.65 (:1398); frame 1.338–1.962 | correct — band 0.08–0.09 seen; canvas bottom 1.37 m seen vs 1.418 built (IMG_6387 53.8 s); photo is 1.608 wide per high, catalogue 1.554 |
| N wall, left | The Green Pumpkin (Henri Matisse) | 57.037 | 80 x 64.5 [unframed] | 0.645 x 0.800 (outer 0.756 x 0.911)<br>`remodel_room.gd:1405` | 1.000 | 1.000 | canvas centre 1.65 (:1406); frame 1.195–2.105 | wrong size (frame) — band 0.055 built vs 0.135 seen: outer should be 0.91 x 1.07; hung 0.11 m too high — canvas bottom 1.14 m (IMG_6387 74.4 s), centre should be ≈1.54 |
| N wall, right | On the Banks of a River (Paul Cézanne) | 43.255 | 61 x 73.7 [unframed] | 0.737 x 0.610 (outer 0.947 x 0.820)<br>`remodel_room.gd:1411` | 1.000 | 1.000 | canvas centre 1.65 (:1412); frame 1.240–2.060 | correct size; frame slightly thin (0.105 built vs 0.12–0.135 seen); height agrees (canvas bottom 1.30 m seen vs 1.345, IMG_6387 70.6 s) |
| S (entry) wall, toward windows | Head of a Woman (Jacques Villon), oval | 70.058 | 54.8 x 46 [unframed] | 0.460 x 0.548 (box 0.630 x 0.720)<br>`remodel_room.gd:1428 (oval), :1419 (box)` | 1.000 | 1.000 | oval centre 1.65 (:1420); box 1.290–2.010 | correct oval; white box small — 0.630 x 0.720 built vs ≈0.72 x 0.87 seen; ≈0.13 m too high (IMG_6387 56.8 s, weak match, low confidence) |
| W wall | Mountaineers Attacked by Bears (Henri Le Fauconnier) | 1995.043 | 239.6 x 305.4 x 4.4 [unframed; third number is thickness] | 3.054 x 2.396 (outer 3.122 x 2.464)<br>`remodel_room.gd:1434` | 1.000 | 1.000 | canvas centre 1.65 (:1435); frame 0.418–2.882 | correct size and height (canvas bottom 0.44 m seen vs 0.452); frame thin — 0.034 built vs 0.05–0.09 seen on the bottom rail (IMG_6387 78.8 s, low confidence) |
| E wall, case on pier between windows | Seated Woman (Raymond Duchamp-Villon) | 67.089 | 71.1 x 20.3 x 24.1 [overall] | 0.203 x 0.711 x 0.241 deep<br>`seated_woman_asset.gd:7,11-14` | 1.000 | 1.000 | figure 0.92–1.631 | correct figure; case deck 0.92 built vs ≈0.86–0.95 seen (IMG_6387 64.8 s, by eye) |

## 2. Frames

**The built size never includes the frame.** The catalogue size is given to the canvas quad; the frame is added outside it. `painting_asset.gd:58-66` turns the frame texture's `margins_px` into metres with `canvas_h / opening_px_h`, so the band is whatever proportion the generated frame texture happens to have. That proportion is the error: the band cannot be corrected by changing a number in `works.json`, because `margins_px` also sets where the texture is cut.

Hall bands, left / right / top / bottom, in metres. "Seen" is read on the rectified frame of `IMG_6344.MOV` at the time given.

| Tag | Built band [code] | Seen band [footage] | Built ÷ seen | Built framed size | Seen framed size | Framed ratio W / H | Time s | Note |
|---|---|---|---|---|---|---|---|---|
| S1 | 0.111 / 0.111 / 0.118 / 0.118 | 0.060 / — / — / 0.055 | 1.99 | 1.885 x 2.382 | 1.78 x 2.28 | 1.059 / 1.047 | 36.8 | top and right rails not seen close up |
| S2 | 0.229 / 0.229 / 0.251 / 0.246 | 0.085 / 0.085 / 0.100 / 0.080 | 2.73 | 2.287 x 3.157 | 2.01 x 2.84 | 1.138 / 1.111 | 73.8 |  |
| W1 | 0.121 / 0.121 / 0.122 / 0.123 | 0.120 / 0.105 / 0.100 / 0.120 | 1.09 | 1.352 x 1.096 | 1.31 x 1.07 | 1.032 / 1.024 | 79.4 |  |
| W2 | 0.204 / 0.218 / 0.227 / 0.222 | 0.210 / 0.210 / 0.220 / 0.210 | 1.02 | 1.567 x 2.278 | 1.52 x 2.26 | 1.030 / 1.006 | 83.8 |  |
| W3 | 0.169 / 0.169 / 0.174 / 0.172 | 0.165 / 0.160 / 0.155 / 0.170 | 1.05 | 1.040 x 1.266 | 0.99 x 1.24 | 1.046 / 1.024 | 88.8 |  |
| W4 | 0.144 / 0.141 / 0.147 / 0.148 | 0.150 / 0.150 / 0.160 / 0.150 | 0.95 | 1.265 x 1.416 | 1.24 x 1.40 | 1.019 / 1.012 | 95.6 |  |
| W5 | 0.138 / 0.138 / 0.144 / 0.144 | 0.110 / 0.110 / 0.115 / 0.115 | 1.25 | 1.610 x 1.869 | 1.52 x 1.85 | 1.059 / 1.009 | 100.6 |  |
| W7 | 0.263 / 0.262 / 0.251 / 0.235 | 0.190 / 0.200 / 0.200 / 0.200 | 1.28 | 2.230 x 1.708 | 2.09 x 1.51 | 1.065 / 1.131 | 111.2 |  |
| W8 | 0.130 / 0.130 / 0.146 / 0.139 | 0.130 / 0.123 / 0.130 / 0.130 | 1.06 | 1.352 x 2.241 | 1.32 x 2.21 | 1.024 / 1.017 | 121.8 |  |
| W9 | 0.131 / 0.131 / 0.134 / 0.129 | 0.110 / 0.090 / 0.090 / 0.110 | 1.31 | 1.926 x 1.359 | 1.87 x 1.30 | 1.032 / 1.046 | 126.8 |  |
| W10 | 0.202 / 0.199 / 0.185 / 0.190 | 0.130 / 0.150 / 0.120 / 0.140 | 1.44 | 2.007 x 1.597 | 1.89 x 1.48 | 1.063 / 1.077 | 131.6 |  |
| N1 | 0.218 / 0.218 / 0.222 / 0.222 | 0.197 / 0.193 / 0.190 / 0.200 | 1.13 | 1.636 x 2.456 | 1.57 x 2.40 | 1.041 / 1.022 | 137.8 |  |
| N2 | 0.186 / 0.193 / 0.371 / 0.138 | 0.150 / 0.150 / 0.360 / 0.150 | 1.10 | 1.808 x 2.860 | 1.72 x 2.86 | 1.053 / 1.000 | 148.4 | sides 0.18 with the garlands |
| E1 | 0.178 / 0.179 / 0.168 / 0.168 | 0.090 / 0.085 / 0.090 / 0.095 | 1.93 | 2.503 x 1.803 | 2.24 x 1.65 | 1.116 / 1.093 | 152.4 |  |
| E2 | 0.134 / 0.138 / 0.142 / 0.140 | 0.140 / 0.140 / 0.133 / 0.135 | 1.01 | 1.288 x 1.552 | 1.28 x 1.54 | 1.006 / 1.009 | 155.8 |  |
| E3 | 0.120 / 0.119 / 0.121 / 0.117 | 0.140 / 0.137 / 0.110 / 0.120 | 0.94 | 1.290 x 1.098 | 1.32 x 1.09 | 0.975 / 1.005 | 159.0 |  |
| E4 | 0.144 / 0.142 / 0.139 / 0.137 | 0.110 / 0.110 / 0.110 / 0.115 | 1.26 | 1.912 x 1.473 | 1.83 x 1.45 | 1.045 / 1.019 | 167.6 |  |
| E5 | 0.346 / 0.350 / 0.451 / 0.352 | 0.270 / 0.270 / 0.450 / 0.260 | 1.20 | 2.436 x 3.013 | 2.26 x 2.93 | 1.077 / 1.027 | 61.0 | top includes the crest; rails 0.27, corner cartouches reach 0.32 |
| E6 | 0.127 / 0.127 / 0.124 / 0.124 | 0.110 / 0.110 / 0.100 / 0.100 | 1.20 | 1.733 x 1.389 | 1.68 x 1.33 | 1.034 / 1.042 | 55.2 |  |
| E7 | 0.209 / 0.192 / 0.192 / 0.183 | 0.193 / 0.210 / 0.197 / 0.190 | 0.98 | 1.843 x 1.347 | 1.83 x 1.36 | 1.004 / 0.991 | 50.2 |  |
| E8 | 0.179 / 0.177 / 0.167 / 0.180 | 0.150 / 0.150 / 0.145 / 0.170 | 1.14 | 1.504 x 2.322 | 1.44 x 2.42 | 1.046 / 0.960 | 44.2 |  |
| E9 | 0.207 / 0.207 / 0.203 / 0.201 | 0.187 / 0.200 / 0.190 / 0.200 | 1.05 | 1.805 x 1.496 | 1.78 x 1.48 | 1.016 / 1.012 | 39.8 |  |

Defensible allowance per work is the "seen" column. Wrong by more than the reading error: S2, S1, E1, W10. Marginal (1.2–1.35): W5, W7, W9, E4, E5, E6. Right: W1, W2, W3, W4, W8, N1, N2, E2, E3, E7, E8, E9. W6 has no frame, only a thin gilt edge.

Added rooms, same method:

| Work | Built band m [code] | Seen band m [footage] | Video, time | Result |
|---|---|---|---|---|
| Delacroix 35.786 | 0.135 / 0.161 / 0.136 / 0.136 | 0.14–0.15 | IMG_6385 28.25 s; IMG_6386 60.75 s | right |
| Fetti 36.003 | 0.163 / 0.163 / 0.169 / 0.169 | 0.10 / 0.094 / 0.095 / 0.11 | IMG_6386 34.0 s, 31.0 s | 1.65 x too wide |
| Goltzius 61.006 | 0.063 / 0.074 / 0.074 / 0.058 | framed 0.46 x 0.66 against 0.482 x 0.642 | IMG_6386 19.25 s, 0.0 s | right |
| Courbet 43.571 | 0.132 / 0.117 / 0.147 / 0.168 | 0.16–0.17 all round | IMG_6380 3.5 s | sides 0.75 x |
| Corot 24.089 | 0.061 / 0.085 / 0.079 / 0.104 | framed 0.60 x 0.475 against 0.606 x 0.501 | IMG_6380 29.25 s (weak match) | right |
| Bertin 56.214 | 0.055 / 0.055 / 0.080 / 0.065 | 0.07–0.085 | IMG_6380 92.5 s | right |
| Edwards 58.197 | 0.071 / 0.109 / 0.108 / 0.071 | 0.08–0.10 | IMG_6380 153.0 s | right |
| Romany 2009.9 | 0.121 / 0.153 / 0.158 / 0.132 | 0.12–0.13 | IMG_6380 140.75 s | right |
| Perugino 16.236 | 0.060 / 0.060 / 0.160 / 0.085 | sides 0.07, cornice 0.20, base 0.15 | IMG_6383 38.25 s | 0.82 tall against 0.93 |
| Madonna 58.196 | 0.077 all round | 0.08 | IMG_6383 15.0 s | right |
| Braque 48.248 | 0.080 | 0.08–0.09 | IMG_6387 53.8 s | right |
| Matisse 57.037 | 0.055 | 0.147 / 0.12 / 0.137 / 0.137 | IMG_6387 74.4 s | 0.41 x: gold rails plus ivory liner |
| Cézanne 43.255 | 0.105 | 0.12–0.135 | IMG_6387 70.6 s, 71.8 s | 0.8 x, marginal |
| Villon 70.058 (white box) | 0.085 / 0.086 | 0.15 / 0.11 / 0.15 / 0.17 | IMG_6387 56.8 s (18 matches) | box 0.63 x 0.72 against 0.72 x 0.87, low confidence |
| Le Fauconnier 1995.043 | 0.034 | 0.05–0.09, bottom rail only | IMG_6387 78.8 s | thin, low confidence |

## 3. Relative-scale checks from the footage

| Room | Video, time | What was compared | Footage | Build | Result |
|---|---|---|---|---|---|
| Hall | IMG_6344 178.6 s | S1 and S2 framed heights in one frame | 137.5 : 168.5 px = 0.82 | 2.382 : 3.157 = 0.75 | S2's frame is too big |
| Hall | IMG_6344 178.6 s | Arch-door opening between the casing's inner edges, scale from S1 and S2 (0.0167 m/px) | 100 x 183.5 px = 1.67 x 3.06 m (±0.05) | 1.9 x 3.1 m | width 14 % wide, height right |
| Hall | IMG_6344 178.6 s | South wall, corner to corner | 597 px = 9.97 m | 10.0 m | right |
| Hall | IMG_6344 178.6 s | Cornice above the floor | 5.76 m to 6.30 m | 5.5 m to 6.0 m | about 5 % low |
| Hall | IMG_6344 178.6 s | Two visitors 1.5 m in front of S1 | 1.77 m and 1.88 m | visitor 1.75 m | plausible |
| Hall | IMG_6344 26.0 s | Far-door opening, scale from N2 (0.0202 m/px) | 1.61 x 3.06 m | 1.9 x 2.8 m | built 0.26 m short and 0.3 m wide |
| Hall | IMG_6344 26.0 s | Person in the far doorway | 79 px = 1.6–1.7 m | visitor 1.75 m | plausible |
| Hall | IMG_6344 117.8–119.0 s, 5 frames | Canvas height W9 ÷ W8 | 0.566 ± 0.002 | 0.560 | right |
| Hall | IMG_6344 124.2 s | Canvas height W10 ÷ W9 | 1.120 | 1.116 | right |
| Hall | IMG_6344 41.8–42.0 s | Canvas height E9 ÷ E8 | 0.527 | 0.553 | E8 is 5 % taller than built |
| Hall | SfM `sfm-6344-east/sparse/0` | Catalogue height ÷ model height, against W8–W10 | W7 1.100, W6 0.887, W5 0.974, W4 1.029 | 1.000 | W7 and W6 wrong |
| Hall | SfM `sfm-6344-west/sparse/0` | Same, against E5–E7, E9, S1 | E8 0.941 | 1.000 | E8 wrong |
| Hall | SfM `sfm-6344-east/sparse/{1,2}` | Same | E1–E4 0.98–1.00; S2, W1–W3 1.00–1.01 | 1.000 | heights right |
| Hall | IMG_6344, 21 close-ups (W1 and E2 not readable) | Baseboard under each painting, in that painting's own scale | 0.29–0.32 m for 20, 0.34 m under W3; mean 0.30 | 0.28 m (`walk4.gd:454-458`) | one ruler fits once W7, E8, W6 are resized; at catalogue size they read 0.33, 0.28, 0.27 m |
| Rockefeller | IMG_6380 153.0 s | Mrs. Edwards frame above bookcase 2017.74.9: gap | 188 px = 0.33–0.35 m | 0.33 m | right |
| Rockefeller | IMG_6380 153.0 s | Edwards sight width ÷ height | 350 : 438 px = 0.80 | 0.838 | canvas 5 % wide |
| Rockefeller | IMG_6380 159.75 s, 210.5 s, 211.25 s | Wallpaper bottom above floor; baseboard 0.19–0.21 m | 0.94–0.98 m | 1.53 m | 0.55 m too high |
| Rockefeller | IMG_6380 140.75 s | Romany frame bottom above settee back | ≈0.30 m | 0.44 m | not conclusive (settee is in front of the wall) |
| Rockefeller | IMG_6380 230.75 s | Mirror top below the ceiling line | 58 px = 0.22 m | 0.195 m | right |
| Rockefeller | IMG_6380 143.2 s, model `sfm-connected-v4/sparse/5` | Armchair left of the bookcase: arm tip to arm tip ÷ height above its feet; level from 35 points on the seat | 0.90, or 0.84 m at the catalogue height; seat 0.44 m high | 0.65 (0.604 m) | built 28 % narrow; catalogue 0.88 |
| European | IMG_6386 60.75 s, 0.0 s, 30.5 s | Baseboard height in each painting's own scale | Delacroix 0.19–0.21, Goltzius 0.20, Fetti 0.185 m | 0.16 m | the three canvases agree with each other |
| European | IMG_6385 21.5 s | Secretary and Delacroix in one frame | a framed print hangs between them | 0.25 m gap, no print | spacing differs; Delacroix cut off, no size ratio |
| Grey French | IMG_6380 92.5 s | Bertin sight opening against its catalogue size | 0.68 x 0.52 in photo scale | 0.651 x 0.489 | photo is cropped 4–6 %; size right |
| Grey French | IMG_6380 3.5 s | Courbet canvas above the baseboard top | 1.12 m | 1.33 m | too high |
| Renaissance | IMG_6383 8.5 s, 8.75 s | Velvet ÷ Woodcutters height in one frame | 0.866, 0.871 | 0.833 | velvet 4 % longer |
| Renaissance | IMG_6383 8.5 s, 8.75 s | Velvet to Woodcutters, centre to centre | 1.48 m, level to 1.5 cm | 1.45 m, 4 cm apart in height | right |
| Renaissance | IMG_6383 64.0 s | Door opening against the Perugino frame (178 px) | 545 px = 2.66 ± 0.25 m | 2.74 m | right within error |
| Renaissance | IMG_6383 15.0 s, 14.5 s | Madonna 58.196 panel bottom above floor; baseboard 0.19 m | 1.075 m | 0.763 m | 0.31 m too low |
| Renaissance | IMG_6383 62 s | Saint Roch (1.054 m) against its plinth | 260 : 140 px, plinth ≈0.57 m | 0.68 m | by eye |
| Medieval | IMG_6382 67.75–69.25 s, 3 frames | Panel height 57.301 ÷ 20.207 in one frame | 0.852, 0.860 and 0.820 | 0.817 | right within 5 % |
| Medieval | IMG_6382 67.75–69.25 s | 20.207 to 57.301, centre to centre | 0.86–0.875 m, level | 1.22 m, level | built 0.35 m too far apart |
| Medieval | IMG_6382 68.0 s, 70.75 s, 74.25 s | Panel bottoms above floor | ≈0.95–1.0, ≈0.97, ≈1.2 m | 1.10, 1.18, 1.36 m | 0.12–0.16 m too high |
| Medieval | IMG_6382 57.2 s, model `sfm-connected-v4/sparse/6` | Ruler for that model: St. Anthony Abbot Enthroned 16.243 (not built; catalogue 232.4 x 92.1 cm), plane through 1,398 model points on the panel | 2.403 x 0.949 units: 0.967 and 0.970 m per unit, aspect within 0.4 % of the catalogue | — | scale 0.969 m per unit; ±4 % allowed across the model |
| Medieval | IMG_6382 1.2–5.8 s, same model | Romanesque portal: arch top above its base line ÷ width (top read in three frames, spread 0.3 %) | 0.874 over the impost ends, 0.939 over the masonry (±0.015) | 1.010 to the hood and 0.990 to the third order over the impost ends (4.18 m); 1.034 and 1.015 over the masonry (4.08 m) | built 8–16 % tall for its width; catalogue 0.913 |
| Medieval | IMG_6382 1.2–5.8 s and 88.75 s, same model | Portal in metres | top 3.83 (3.75 in the far frame), impost top 2.20, masonry 4.08, impost ends 4.38 | 4.22 (hood), 2.41, 4.08, 4.18 | top and impost 10 % high; masonry width right; catalogue 3.861 x 4.229 |
| Medieval | IMG_6382 12.25 s, same model | Iron grille, front leaf | 2.11 m tall, 0.70–0.82 m wide, top 2.30 m above the floor | one panel 0.98 x 2.38 m, top at 2.50 m | built 13 % tall and 0.20 m high |
| Lion landing | IMG_6387 42.0 s | Lion panel (395 px = 1.041 m) bottom above floor | ≈1.15 m | 1.18 m | right |
| Modern | IMG_6387 48.0 s | Cézanne ÷ Matisse framed height in one frame, with a visitor and the bench | 118 : 134 px = 0.88 | 0.90 | right within blur; visitor ≈1.8 ± 0.1 m |
| Modern | IMG_6387 74.4 s, 53.8 s, 70.6 s, 78.8 s | Canvas bottoms above floor; baseboard 0.19–0.20 m | Matisse 1.14, Braque 1.37, Cézanne 1.30, Le Fauconnier 0.44 m | 1.25, 1.42, 1.345, 0.452 m | Matisse 0.11 m high; others right |

No bench was measured in any room. A door or a person served as a ruler only in the Hall, the Renaissance room and the modern gallery; the other rooms are checked against the floor, the baseboard, the ceiling line or a second catalogued object. In the grey French gallery the three paintings hang on three walls, and none of 1,042 frames holds two of them.

## 4. Corrections, in order

1. **Hall hang heights** — `modules/shell/prototype/gallery_walk4/works.json`, key `hang`. Confidence high: one method, ±0.06 m, checked against the wide shots at 26.0 s and 178.6 s and the SfM floor.

| Tag | Old | New | Canvas centre m |
|---|---|---|---|
| S1 | `frame bottom ≈ 0.75 m` | `centre ≈ 2.06 m` | 1.941 → 2.06 (+0.12) |
| W1 | `centre ≈ 1.55 m` | `centre ≈ 1.73 m` | 1.550 → 1.73 (+0.18) |
| W2 | `centre ≈ 1.5 m` | `centre ≈ 1.90 m` | 1.500 → 1.90 (+0.40) |
| W3 | `centre ≈ 1.55 m` | `centre ≈ 1.78 m` | 1.550 → 1.78 (+0.23) |
| W4 | `centre ≈ 1.55 m` | `centre ≈ 1.70 m` | 1.550 → 1.70 (+0.15) |
| W5 | `centre ≈ 1.55 m` | `centre ≈ 1.72 m` | 1.550 → 1.72 (+0.17) |
| W6 | `bottom ≈ 1.2 m, top ≈ 4.5 m` | `bottom ≈ 0.82 m` | 2.855 → 2.55 (-0.30) |
| W7 | `centre ≈ 1.55 m` | `centre ≈ 1.71 m` | 1.550 → 1.71 (+0.16) |
| W8 | `frame bottom ≈ 0.5–0.6 m` | `centre ≈ 1.92 m` | 1.671 → 1.92 (+0.25) |
| W9 | `centre ≈ 1.55 m` | `centre ≈ 1.73 m` | 1.550 → 1.73 (+0.18) |
| W10 | `centre ≈ 1.55 m, above a floor vent` | `centre ≈ 1.73 m` | 1.550 → 1.73 (+0.18) |
| N1 | `frame bottom ≈ 0.5 m` | `centre ≈ 2.07 m` | 1.728 → 2.07 (+0.34) |
| N2 | `frame bottom ≈ 0.35–0.5 m` | `centre ≈ 2.07 m` | 1.855 → 2.07 (+0.22) |
| E1 | `centre ≈ 1.55 m, above a floor vent` | `centre ≈ 1.76 m` | 1.550 → 1.76 (+0.21) |
| E2 | `centre ≈ 1.55 m` | `centre ≈ 1.72 m` | 1.550 → 1.72 (+0.17) |
| E3 | `centre ≈ 1.55 m` | `centre ≈ 1.74 m` | 1.550 → 1.74 (+0.19) |
| E4 | `centre ≈ 1.55 m` | `centre ≈ 1.71 m` | 1.550 → 1.71 (+0.16) |
| E6 | `centre ≈ 1.55 m` | `centre ≈ 1.69 m` | 1.550 → 1.69 (+0.14) |
| E7 | `centre ≈ 1.55 m` | `centre ≈ 1.72 m` | 1.550 → 1.72 (+0.17) |
| E8 | `frame bottom ≈ 0.5 m` | `centre ≈ 1.88 m` | 1.661 → 1.88 (+0.22) |
| E9 | `centre ≈ 1.55 m, above a floor vent` | `centre ≈ 1.69 m` | 1.550 → 1.69 (+0.14) |

2. **Hall canvases** — same file, keys `canvas_w` / `canvas_h`.

| Tag | Old W x H | New W x H | Confidence |
|---|---|---|---|
| W7 (44.161) | 1.705 x 1.222 | 1.705 x 1.111 | high: two SfM methods, baseboard and photo aspect agree |
| E8 (62.064) | 1.149 x 1.975 | 1.138 x 2.104 | high: same four checks plus the E9 pair |
| W6 (32.246) | 1.98 x 3.31 | 2.06 x 3.46 | medium: SfM 2.08 x 3.48, grid reading 2.04 x 3.44 |
| W5 (57.157) | 1.334 x 1.581 | 1.300 x 1.623 | medium |
| W2 (56.177) | 1.145 x 1.829 | 1.101 x 1.829 | medium: may be rebate |
| W3 (62.019) | 0.702 x 0.921 | 0.669 x 0.911 | medium: may be rebate |
| E1 (63.061) | 2.146 x 1.467 | 2.069 x 1.467 | medium |

Where one side agrees with the catalogue inside the ±1 % error (W7 width, W2 height, E1 height) the catalogue value is kept; section 1 gives the measured value.

3. **Added-room heights** — the `y` of each position in `remodel_room.gd`. Edit the source copy (each line is 43 higher there) and rebuild with `scripts/rebuild_rooms.sh`; the lines below are the runtime copy's.

| Line | Work | Old y | New y | Confidence |
|---|---|---|---|---|
| 752 | Wallpaper 34.912 | 2.10 | 1.55 | high: three frames |
| 1719 (third entry, `madonna_58196`) | Madonna 58.196 | 1.22 | 1.53 | high: two frames |
| 951 | Fetti 36.003 | 1.8 | 1.51 | high: two frames |
| 945 | Delacroix 35.786 | 1.75 | 1.57 | high: two videos |
| 996 | Goltzius 61.006 | 1.75 | 1.62 | medium: one frame |
| 1406 | Matisse 57.037 | 1.65 | 1.54 | medium |
| 487 (first entry, `courbet`) | Courbet 43.571 | 1.8 | 1.62 | medium-low: floor line not in frame |
| 1090 (three entries) | Panels 20.207, 57.301, 22.047 | 1.55 | 1.43, 1.43, 1.39 | medium-low: ±0.08 m |

4. **Frame bands** — needs a metric band per work; no existing value expresses it. Smallest change: an optional `band_m` [left, top, right, bottom] in the record, used at `painting_asset.gd:60-63` in place of `margins[i] * mpp`. Targets: S2 0.085 / 0.10 / 0.085 / 0.08 (high); S1 0.06 all round (medium: two sides seen); E1 0.09 (high); W10 0.135 (medium); Fetti 0.10 (high); Matisse 0.135 (high); Perugino top 0.20, bottom 0.15 (medium).
5. **Object sizes**, in this order:

| Where | Work | Old | New | Confidence |
|---|---|---|---|---|
| `remodel_room.gd:828`, `width` for kind `armchair` only (the entrance chair shares the `.56` branch and is already 0.676 wide); reliefs in `assets/armchair-parts.json` x 1.36 in x | Armchairs 2017.74.7.1, .7.2 | .56 (overall 0.604) | .78 (overall 0.82) | high: catalogue and footage agree |
| `walk4.gd:1249` `_portal_stone`: heights and arch radii x 0.915, masonry kept 4.08 m wide | Romanesque portal 40.014 | hood top 4.22, impost top 2.41, outer radius 1.83, opening 1.90 m | 3.86, 2.20, 1.68, 1.74 m | high for the height: catalogue 3.861 m and footage 3.83 m agree. Medium for the opening, which is the Hall's arch door (`DOORS.arch`): 1.67 m wide from the Hall, 1.51–1.64 m from this side |
| `remodel_room.gd:734` | Mrs. Edwards 58.197 | `Vector2(.637,.760)` | `Vector2(.60,.760)` | medium-low |
| `remodel_room.gd:829` `depth` (settee `.64`, chairs `.47`) with the part files; the z constants of `build_bookcase` (`:640-690`) | Settee 2017.74.5, bookcase 2017.74.9, entrance armchair 2017.74.12 | 0.655, 0.37, 0.625 m deep | 0.77, 0.33, 0.58 m | medium: catalogue only |
| `remodel_room.gd:1419` (box), `fauconnier-frame-geometry.json`, `courbet-frame-geometry.json`, `remodel_room.gd:1090` (z of 20.207 and 57.301) | Villon box, Le Fauconnier frame, Courbet side bands, panel spacing | see sections 2 and 3 | re-measure first | low |

## 5. Not determined

1. **Sources.** `docs/research/grand-gallery-hang.md` is not in this checkout, any local ref, or the remote (branch `research/grand-gallery-hang` returns 404), so the Hall `hang` strings could not be traced. The top-level `collection-expansion/IMG_6378.MOV`–`IMG_6380.MOV` are 0 bytes and `IMG_6381`/`IMG_6382` are shorter than the copies in `verified/`; only `verified/` was used. `IMG_6379`, `IMG_6381` and `IMG_6384` were not examined beyond a match search; `IMG_6378` is an auditorium. The existing room SfM models were used only for the armchair, the portal and the grille; room hang heights, and the size and spacing of the medieval panels, were not re-measured against them.
2. **Catalogue against the wall.** Why the records for W7, E8 and W6 disagree with the hung object; the footage does not show which is in error. Whether catalogue figures are sight or stretcher size (under 3 cm where it could be checked, W4). Whether 49.5 x 22.5 cm for the Magdalene 21.250 is the painted panel or the framed object. The real sizes of the pink Worcester tureens (2017.74.39.18, .19) and the agateware teapot (2017.74.24): the records cannot be right and nothing in the case serves as a ruler.
3. **Frames.** S1's top and right rails. W5, W7, W9, E4, E5, E6 beyond "20–35 % wide". The Le Fauconnier frame beyond its bottom rail. The Villon box (18 matched points).
4. **Heights.** Corot, Perugino, Romany, both mirrors, both sconces, the apostles' brackets, the tracery arch springing, every case deck, and the Renaissance south platform (so the absolute height of the velvet and tapestry). The lion panel against its door: both are in IMG_6387 42.8 s, but the wall recedes and the frame is blurred.
5. **Out of reach.** The iron grille and the two papers in the low medieval case have no accession. The portal's width to better than ±4 %: the catalogue's 4.229 m lies between the masonry (4.08 m) and the impost ends (4.38 m) seen in footage, and two small objects in the tall case give a model scale 5 % larger than the St. Anthony panel. Ceiling heights and door sizes of the added rooms, except one Renaissance door (2.66 ± 0.25 m). Filmed objects that are not built were not audited: in the medieval room the crucifix, a head and a bust on pedestals, a relief on a pedestal, a large gabled panel and a standing polychrome saint; elsewhere the textile above the entrance chair and the print between the secretary and the Delacroix. Nor were the room additions another session is preparing (`ADDITIONS` in the source `remodel_room.gd`), which do not exist yet.

Scratch (git-ignored, 29 MB): `build/audit-sizes/` holds the dump (`scene_dump.json`), the live catalogue responses (`risd-live/`), the scripts, the rectified crops (`ev/`) and the portal and armchair measurements (`portal3.py`, `chair5.py`). Extracted video frames were deleted.
