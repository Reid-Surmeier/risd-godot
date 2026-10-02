# Museum object manifest: captions and detail pictures for the clickable works

2026-10-01. Data only: `collection_rooms/objects.json`, 53 pictures under `collection_rooms/assets/details/`, and this report. No code, scene, interface or acceptance file was touched. No paid call and no generated picture. Spend: 0 USD.

## Result

1. `collection_rooms/objects.json` has one entry for each of the 67 keys in `build/registered-objects.json`. **65 are identified, 2 are not.** It also has 14 entries beyond that list, all identified, for the framed paintings that commit `a29ad9e9` made clickable after the list was written. 81 entries in all.
2. **59 of the 67 detail pictures change.** 53 are new files in `collection_rooms/assets/details/` (6.65 MB in total, largest 251 KB, long side 1024 px). 6 point at museum photographs that were already in `collection_rooms/assets/`. 8 keep the picture they had.
3. Every caption field is the text the RISD Museum catalogue page prints for that accession. For the 67, 58 pages were read from copies already saved by this project and 9 from the live site; for the 14 more, 6 and 8.
4. Two works have no museum photograph at all: the emblem book 2023.17 and the ewe and lamb 2017.74.32.
5. **The 53 new pictures are imported in this checkout.** Another agent's Godot pass wrote their `.import` files at 22:44 on 2026-10-01; this task ran Godot only in a scratch project. In a checkout where they are not imported, `ResourceLoader.exists()` is false for them and the detail view keeps the old texture without any error.

## How it was done

1. **Key to accession.** Accession numbers come from the node metadata listed in `build/registered-objects.json` and, for the asset names, from `collection_rooms/assets/catalogue-objects.json`. Where `image-work/collection-room-remodel/inventory-catalogue/<key>.json` exists it gives the same number (43 of 43), and 44 of the 45 generation prompts (`<key>-prompt.txt`) name that number too; the lion panel's prompt names none.
2. **Text.** Title, maker, date, medium, dimensions, credit line and object number are read from the catalogue page ("Tombstone" and field list). For all 67 the title, dimensions, credit line and object number are identical in the saved API record, and the printed date lies inside the API record's year range.
3. **Maker.** The catalogue prints, for example, "Joseph Chinard (French, 1756-1813)". `maker` keeps the name and any role or qualifier ("maker", "modeler", "Attributed to", "Probably") and drops the bracket with nationality and life dates, because the game prints maker and date on one line. Two or more makers are joined with "; ". "Unknown Maker, English" is kept as printed. The dropped brackets are listed at the end of the table.
4. **Pictures.** All 396 photographs on the 65 catalogue pages that have any were looked at on contact sheets and the front view was chosen by eye. It is the page's first photograph except in the eight cases named below. Every new file is the museum's photograph made smaller (long side 1024 px, the same as the Main Hall's `detail/*.jpg`; Pillow, Lanczos) and saved as a baseline JPEG at quality 85. Photographs already 1024 px or smaller were only re-encoded. All 53 sources are sRGB. Nothing was cropped, retouched or generated.
5. **Not identified.** Where the repo itself holds a match at "probable" or "candidate", the entry gets a plain description as its title and empty caption fields. The catalogue record is kept under a `candidate` key so nothing is lost. That key is an addition to the ten requested fields; the game does not read it.

## Sources of the text

All seven text fields of a row come from the one page named in its Source column. The page address is the link on the title. Two exceptions are marked ¹ and ².

| Code | Where | Works |
| --- | --- | --- |
| A | `image-work/collection-room-remodel/inventory-catalogue/official-responses.tar.gz:` (saved catalogue pages, this checkout) | 41 |
| B | `image-work/collection-room-remodel/catalogue/official-page-sources.tar.gz:` (saved catalogue pages, this checkout) | 1 |
| C | `docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001/photos/` (saved catalogue pages; see the note under the table) | 14 |
| D | `docs/evidence/collection-reconstruction/opus-unmatched-paper-research-20261001/photos/` (saved catalogue page; same note) | 1 |
| E | `docs/evidence/collection-reconstruction/opus-medieval-case-inventory-20261001/photos/` (saved catalogue page; same note) | 1 |
| L | live RISD page, read through the project's Scrapling route (plain HTTP is refused with 403) | 9 |

C, D and E are tracked in this branch, but this worktree's sparse-checkout leaves `docs/evidence/collection-reconstruction/` out. They were read in the `collection-reconstruction` worktree, and each of the 31 files used there (16 pages, 11 photographs, 4 others) was checked to be identical to this branch's HEAD.

The nine live pages. Their copies were scratch files and are deleted; the hash is of the page as received. Title, maker, medium, dimensions, credit line and object number for these nine are also in the saved API record named; only the printed date came from the live page alone.

| Key | Live page | Read (UTC; the evening of 2026-10-01 local) | sha256 of the page | Saved API record |
| --- | --- | --- | --- | --- |
| `lion-panel` | https://risdmuseum.org/art-design/collection/panel-striding-lion-34652 | 2026-10-02 02:09 | `6d0f40c812b45f3d…` | `collection_rooms/assets/lion-panel-catalogue.json` |
| `48.248` | https://risdmuseum.org/art-design/collection/still-life-48248 | 2026-10-02 02:09 | `cb7f4c114a7c11df…` | `image-work/collection-room-remodel/inventory-catalogue/braque-still-life.json` |
| `70.058` | https://risdmuseum.org/art-design/collection/head-woman-70058 | 2026-10-02 02:09 | `85e89aac336a1635…` | `image-work/collection-room-remodel/inventory-catalogue/villon-head-woman.json` |
| `1995.043` | https://risdmuseum.org/art-design/collection/mountaineers-attacked-bears-1995043 | 2026-10-02 02:09 | `b7a850a32b40a1c3…` | `image-work/collection-room-remodel/inventory-catalogue/fauconnier-mountaineers.json` |
| `57.037` | https://risdmuseum.org/art-design/collection/green-pumpkin-57037 | 2026-10-02 02:10 | `6aa996dc931a6221…` | `image-work/collection-room-remodel/inventory-catalogue/matisse-green-pumpkin.json` |
| `43.255` | https://risdmuseum.org/art-design/collection/banks-river-au-bord-dune-riviere-43255 | 2026-10-02 02:10 | `4c1c5be6f793b81b…` | `image-work/collection-room-remodel/inventory-catalogue/cezanne-banks-river.json` |
| `apostle-41046` | https://risdmuseum.org/art-design/collection/apostle-41046 | 2026-10-02 02:10 | `96f6e3eaa6d7f02e…` | `image-work/collection-room-remodel/inventory-catalogue/apostle-41046.json` |
| `apostle-41045` | https://risdmuseum.org/art-design/collection/apostle-41045 | 2026-10-02 02:10 | `ffe727fe8cbbe0d2…` | `image-work/collection-room-remodel/inventory-catalogue/apostle-41045.json` |
| `67.089` | https://risdmuseum.org/art-design/collection/seated-woman-67089 | 2026-10-02 02:10 | `9a58139062a15cb5…` | `image-work/collection-room-remodel/inventory-catalogue/seated-woman-duchamp-villon.json` |

## The 67 entries

Picture paths are under `collection_rooms/assets/`. "kept" means the picture the game already showed.

| Key | Accession | Title | Maker | Date | Medium | Dimensions | Credit line | Identified | Picture | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `58.196` | 58.196 | [Madonna and Child with Saint Barbara and Saint Catherine](https://risdmuseum.org/art-design/collection/madonna-and-child-saint-barbara-and-saint-catherine-58196) | Unknown Maker, Possibly Netherlandish ¹ | ca. 1525 | Oil on panel | 91.4 x 87 cm (36 x 34 1/4 inches) | Museum Works of Art Fund | yes | `renaissance-wall/madonna-58196-front.png` (kept) | C:`madonna-and-child-saint-barbara-and-saint-catherine-58196.html.gz` |
| `45.042` | 45.042 | [Portrait of a Cleric](https://risdmuseum.org/art-design/collection/portrait-cleric-45042) | Bruges Master | ca. 1490 | Oil on panel | 22.2 x 14.6 x 5.7 cm (8 3/4 x 5 3/4 x 2 1/4 inches) | Museum purchase with funds from Mrs. Gustav Radeke, Manton B. Metcalf, Museum Works of Art Fund and Museum Appropriation Fund, by exchange, and Museum Special Reserve Fund | yes | `renaissance-case-a/textures/portrait-cleric-45042-zoom-0.jpg` (kept) | C:`portrait-cleric-45042.html.gz` |
| `34.861` | 34.861 | [Portrait of a Woman](https://risdmuseum.org/art-design/collection/portrait-woman-34861) | Jan Joest; Attributed to Jan Mostaert | ca. 1520 | Oil on panel | 36.2 x 24.8 cm (14 1/4 x 9 3/4 inches) | Museum Appropriation Fund | yes | `renaissance-case-a/textures/portrait-woman-34861-zoom-0.jpg` (kept) | C:`portrait-woman-34861.html.gz` |
| `22.201` | 22.201 | [Diptych with scenes of the Nativity, the Crucifixion, and the Last Judgement](https://risdmuseum.org/art-design/collection/diptych-scenes-nativity-crucifixion-and-last-judgement-22201) | Unknown Maker, French | ca. 1275-1325 | Ivory with traces of polychromy (colored paint) | Panel: 24.1 x 13.3 cm (9 1/2 x 5 1/4 inches) (each) | Museum Appropriation Fund | yes | `renaissance-case-a/textures/diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-0.jpg` (kept) | C:`diptych-scenes-nativity-crucifixion-and-last-judgement-22201.html.gz` |
| `34.016` | 34.016 | [Book cover](https://risdmuseum.org/art-design/collection/book-cover-34016) | Unknown Maker, German | 1500-1550 | Silver with niello and gilding | 14 x 8.6 x 5.1 cm (5 1/2 x 3 3/8 x 2 inches) | Gift of Messrs. E. & A. Silberman | yes | `renaissance-case-a/textures/book-cover-34016-zoom-0.jpg` | C:`book-cover-34016.html.gz` |
| `2023.17` | 2023.17 | [One Hundred Christian Emblems (Emblematum Christianorum Centuria)](https://risdmuseum.org/art-design/collection/one-hundred-christian-emblems-emblematum-christianorum-centuria-202317) | Georgette de Montenay, author; Pierre Woeiriot, engraver | 1584 | Letterpress and engraving | 197 x 147 mm (197 x 147 mm) | Museum purchase: gift of Ambassador J. W. Middendorf II and Esther Mauran Acquisitions Fund | yes | `renaissance-case-a/textures/emblem-right-page.png` | D:`one-hundred-christian-emblems-emblematum-christianorum-centuria-202317.html.gz` |
| `35.713` | 35.713 | [Drug Jar (Albarello)](https://risdmuseum.org/art-design/collection/drug-jar-albarello-35713) | Unknown Maker, Italian | ca.1550 | Earthenware with tin glaze and enamels | 24.1 x 13 cm (9 1/2 x 5 1/8 inches) | Bequest of Susan Martin Allien | yes | `renaissance-case-a/textures/drug-jar-albarello-35713-zoom-0.jpg` | C:`drug-jar-albarello-35713.html.gz` |
| `46.391` | 46.391 | [Bella Donna Plate](https://risdmuseum.org/art-design/collection/bella-donna-plate-46391) | Probably Castel Durante | ca. 1535-1540 | Earthenware with tin glaze and enamels | Diameter: 22.5 cm (8 7/8 inches) | Gift of Mrs. Jesse H. Metcalf | yes | `details/46.391.jpg` | C:`bella-donna-plate-46391.html.gz` |
| `57.302` | 57.302 | [Bella Donna Plate](https://risdmuseum.org/art-design/collection/bella-donna-plate-57302) | Unknown Maker, Italian | 1500-1550 | Earthenware with tin glaze and enamels | Diameter: 23.2 cm (9 1/8 inches) | Gift of Mr. Robert Lehman | yes | `details/57.302.jpg` | C:`bella-donna-plate-57302.html.gz` |
| `51.105` | 51.105 | [Death of the Virgin](https://risdmuseum.org/art-design/collection/death-virgin-51105) | Unknown Maker, German | ca. 1460 | Silver | Diameter: 11.1 cm (4 3/8 inches) | Museum Works of Art Fund | yes | `details/51.105.jpg` | C:`death-virgin-51105.html.gz` |
| `2017.29` | 2017.29 | [The Virgin as the Woman of the Apocalypse](https://risdmuseum.org/art-design/collection/virgin-woman-apocalypse-201729) | Unknown Maker, German | late 1400s | Clear glass with silver stain and enamel, modern blue glass | Diameter: 190 mm (190 mm) | Gift of Mary Jane and Glenn Creamer | yes | `details/2017.29.jpg` | C:`virgin-woman-apocalypse-201729.html.gz` |
| `34.024` | — | **Small rectangular enamel plaque with figures on a blue ground** (a description, not a catalogue title) | — | — | — | — | — | **no** | `details/34.024.jpg` | none; candidate [Virgin and Child with Clerics and Donors](https://risdmuseum.org/art-design/collection/virgin-and-child-clerics-and-donors-34024), 34.024, read from C:`virgin-and-child-clerics-and-donors-34024.html.gz` |
| `2021.131` | 2021.131 | [Madonna Enthroned, with Saints and Angels](https://risdmuseum.org/art-design/collection/madonna-enthroned-saints-and-angels-2021131) | Lippo di Benivieni | ca. 1320 | Tempera with gold ground on wood panel (triptych) | 67 x 72.5 cm (26 3/8 x 28 9/16 inches) (open) | Gift of Ambassador J. William Middendorf II | yes | `details/2021.131.jpg` | C:`madonna-enthroned-saints-and-angels-2021131.html.gz` |
| `23.307X` | 23.307X | [Velvet Cover](https://risdmuseum.org/art-design/collection/velvet-cover-23307x) | Unknown Maker, French | ca. 1600 | Silk-velvet ground with silver- and gilt-silver-wrapped silk thread embroidery (couching stitch) | 127 cm (50 inches) (length) | Museum Appropriation Fund | yes | `details/23.307X.jpg` | C:`velvet-cover-23307x.html.gz` |
| `29.280` | 29.280 | [The Woodcutters](https://risdmuseum.org/art-design/collection/woodcutters-29280) | Unknown Maker, French | ca. 1500-1510 | Wool tapestry weave | 152.4 x 94 cm (60 x 37 inches) | Gift of Dr. and Mrs. Murray S. Danforth | yes | `details/29.280.jpg` | C:`woodcutters-29280.html.gz` |
| `lion-panel` | 34.652 | [Panel with Striding Lion](https://risdmuseum.org/art-design/collection/panel-striding-lion-34652) | Unknown Maker, Neo-Babylonian | 604-562 BCE | Brick with glaze | 104.1 x 228.6 cm (41 x 90 inches) | Museum Appropriation Fund | yes | `lion-panel-official.jpg` | L (live page) |
| `48.248` | 48.248 | [Still Life](https://risdmuseum.org/art-design/collection/still-life-48248) | Georges Braque | 1918 | Oil on canvas | 46.4 x 72.1 cm (18 1/4 x 28 3/8 inches) | Mary B. Jackson Fund | yes | `painting-48.248.jpg` | L (live page) |
| `70.058` | 70.058 | [Head of a Woman](https://risdmuseum.org/art-design/collection/head-woman-70058) | Jacques Villon | 1914 | Oil on canvas | 54.8 x 46 cm (21 9/16 x 18 1/8 inches) | Mary B. Jackson Fund | yes | `villon-official-original.jpg` | L (live page) |
| `1995.043` | 1995.043 | [Mountaineers Attacked by Bears](https://risdmuseum.org/art-design/collection/mountaineers-attacked-bears-1995043) | Henri Victor Gabriel Le Fauconnier | 1910-1912 | Oil on canvas | 239.6 x 305.4 x 4.4 cm (94 5/16 x 120 1/4 x 1 3/4 inches) | Gift of the Peau de L'Ours II Society in celebration of Daniel Robbins | yes | `painting-1995.043.jpg` (kept) | L (live page) |
| `57.037` | 57.037 | [The Green Pumpkin](https://risdmuseum.org/art-design/collection/green-pumpkin-57037) ² | Henri Matisse | ca. 1916 | Oil on canvas | 80 x 64.5 cm (31 1/2 x 25 3/8 inches) | Anonymous gift | yes | `painting-57.037.jpg` (kept) | L (live page) |
| `43.255` | 43.255 | [On the Banks of a River (Au Bord d'une Rivière)](https://risdmuseum.org/art-design/collection/banks-river-au-bord-dune-riviere-43255) | Paul Cézanne | ca. 1904-1905 | Oil on canvas | 61 x 73.7 cm (24 x 29 inches) | Museum Special Reserve Fund | yes | `painting-43.255.jpg` (kept) | L (live page) |
| `st-george` | 2017.74.14 | [St. George and the Dragon](https://risdmuseum.org/art-design/collection/st-george-and-dragon-20177414) | Ralph Wood the younger | ca. 1770 | Earthenware with glaze and metal | 26.4 x 20.3 x 12.3 cm (10 3/8 x 8 x 4 13/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/st-george.jpg` | A:`st-george.html` |
| `flute-player` | 2017.74.16 | [The Flute Player](https://risdmuseum.org/art-design/collection/flute-player-20177416) | Ralph Wood the younger | ca. 1770 | Earthenware with glaze | 25.4 x 17.7 x 12.4 cm (10 x 6 15/16 x 4 7/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/flute-player.jpg` | A:`flute-player.html` |
| `hudibras` | 2017.74.17 | [Hudibras](https://risdmuseum.org/art-design/collection/hudibras-20177417) | Ralph Wood the younger, maker; John Voyez, modeler | ca. 1770 | Earthenware with glaze | 28.9 x 22.3 x 12.4 cm (11 3/8 x 8 3/4 x 4 7/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/hudibras.jpg` | A:`hudibras.html` |
| `bear-jug` | 2017.74.18.ab | [Brown Bear Jug and Cover](https://risdmuseum.org/art-design/collection/brown-bear-jug-and-cover-20177418ab) | Unknown Maker, English | ca. 1730 | Stoneware with glaze | 14 cm (5 1/2 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/bear-jug.jpg` | A:`bear-jug.html` |
| `horn-player` | 2017.74.19 | [Horn-Player](https://risdmuseum.org/art-design/collection/horn-player-20177419) | Unknown Maker, English | ca. 1745 | Earthenware with glaze | 16.2 x 7 x 5 cm (6 3/8 x 2 3/4 x 1 15/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/horn-player.jpg` | A:`horn-player.html` |
| `finch` | 2017.74.15.1 | [Finch](https://risdmuseum.org/art-design/collection/finch-201774151) | Unknown Maker, English | ca. 1750 | Earthenware with glaze | 5.1 cm (2 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/finch.jpg` | A:`finch.html` |
| `finch-pair` | 2017.74.15.2 | [Finch](https://risdmuseum.org/art-design/collection/finch-201774152) | Unknown Maker, English | ca. 1750 | Earthenware with glaze | 5.1 cm (2 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/finch-pair.jpg` | A:`finch-pair.html` |
| `bagpiper` | 2017.74.21 | [Figure of a Bagpiper](https://risdmuseum.org/art-design/collection/figure-bagpiper-20177421) | Unknown Maker, English | ca. 1745 | Earthenware with glaze | 15 x 7 x 6 cm (5 7/8 x 2 3/4 x 2 3/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/bagpiper.jpg` | A:`bagpiper.html` |
| `bear-jug-pair` | 2017.74.22.ab | [Brown Bear Jug and Cover](https://risdmuseum.org/art-design/collection/brown-bear-jug-and-cover-20177422ab) | Unknown Maker, English | ca. 1730 | Stoneware with glaze | 16.2 cm (6 3/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/bear-jug-pair.jpg` | A:`bear-jug-pair.html` |
| `cream-jug` | 2017.74.25 | [Cream Jug](https://risdmuseum.org/art-design/collection/cream-jug-20177425) | Unknown Maker, English | ca. 1745 | Earthenware with glaze | 15 x 11.7 x 9.5 cm (5 7/8 x 4 5/8 x 3 3/4 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/cream-jug.jpg` | A:`cream-jug.html` |
| `parrot` | 2017.74.27.1 | [Parrot](https://risdmuseum.org/art-design/collection/parrot-201774271) | Unknown Maker, English | ca. 1820 | Earthenware with glaze | 16.5 x 17 x 7 cm (6 1/2 x 6 11/16 x 2 3/4 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/parrot.jpg` | A:`parrot.html` |
| `fox` | 2017.74.20 | [Figure of a Fox](https://risdmuseum.org/art-design/collection/figure-fox-20177420) | Ralph Wood the younger, maker; John Voyez, modeler | ca. 1770 | Earthenware with glaze | 13.3 x 16.5 x 8 cm (5 1/4 x 6 1/2 x 3 1/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/fox.jpg` | A:`fox.html` |
| `parrot-pair` | 2017.74.27.2 | [Parrot](https://risdmuseum.org/art-design/collection/parrot-201774272) | Unknown Maker, English | ca. 1820 | Earthenware with glaze | 16.5 x 16 x 6.5 cm (6 1/2 x 6 5/16 x 2 9/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/parrot-pair.jpg` | A:`parrot-pair.html` |
| `agate-teapot` | 2017.74.24.ab | [Agateware Teapot](https://risdmuseum.org/art-design/collection/agateware-teapot-20177424ab) | Unknown Maker, English | ca. 1745 | Earthenware with glaze | 13.3 x 45.7 cm (5 1/4 x 18 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/agate-teapot.jpg` | A:`agate-teapot.html` |
| `shepherd` | 2017.74.23 | [Figure of a Shepherd](https://risdmuseum.org/art-design/collection/figure-shepherd-20177423) | Ralph Wood the younger, maker; John Voyez, modeler | ca. 1770 | Earthenware with glaze | 21.3 x 8 x 8 cm (8 3/8 x 3 1/8 x 3 1/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/shepherd.jpg` | A:`shepherd.html` |
| `candlestick` | 2017.74.28.1 | [Figural Candlestick](https://risdmuseum.org/art-design/collection/figural-candlestick-201774281) | Unknown Maker, English | late 1800s | Earthenware with glaze | 21 x 12 x 11 cm (8 1/4 x 4 3/4 x 4 5/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/candlestick.jpg` | A:`candlestick.html` |
| `cow` | 2017.74.29 | [Model of a Cow](https://risdmuseum.org/art-design/collection/model-cow-20177429) | Unknown Maker, English | ca. 1760 | Earthenware with glaze | 13 x 21 x 8 cm (5 1/8 x 8 1/4 x 3 1/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/cow.jpg` | A:`cow.html` |
| `candlestick-pair` | 2017.74.28.2 | [Figural Candlestick](https://risdmuseum.org/art-design/collection/figural-candlestick-201774282) | Unknown Maker, English | ca. late 1800s | Earthenware with glaze | 21.6 x 12 x 11 cm (8 1/2 x 4 3/4 x 4 5/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/candlestick-pair.jpg` | A:`candlestick-pair.html` |
| `parrot-third` | 2017.74.26 | [Figure of a Parrot](https://risdmuseum.org/art-design/collection/figure-parrot-20177426) | Unknown Maker, English | ca. 1760 | Earthenware with glaze | 15.6 x 17 x 7 cm (6 1/8 x 6 11/16 x 2 3/4 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/parrot-third.jpg` | A:`parrot-third.html` |
| `recamier` | 37.201 | [Bust of Madame Récamier](https://risdmuseum.org/art-design/collection/bust-madame-recamier-37201) | Joseph Chinard | 1805-1812 | Marble | 60.6 x 33.7 x 23.5 cm (23 7/8 x 13 1/4 x 9 1/4 inches) | Gift of Mrs. Harold Brown | yes | `details/recamier.jpg` | A:`recamier.html` |
| `ewe-lamb` | — | **Earthenware figure of a ewe and lamb** (a description, not a catalogue title) | — | — | — | — | — | **no** | `ewe-lamb-volume.png` (kept) | none; candidate [Ewe and Lamb](https://risdmuseum.org/art-design/collection/ewe-and-lamb-20177432), 2017.74.32, read from A:`ewe-lamb.html` |
| `sconce-left` | 2017.74.6.3 | [Wall Sconce](https://risdmuseum.org/art-design/collection/wall-sconce-20177463) | Unknown Maker, English | ca. 1755 | Gilded wood | 87.6 x 48.3 x 21.5 cm (34 1/2 x 19 x 8 7/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/sconce-left.jpg` | A:`sconce-left.html` |
| `sconce-right` | 2017.74.6.4 | [Wall Sconce](https://risdmuseum.org/art-design/collection/wall-sconce-20177464) | Unknown Maker, English | ca. 1755 | Gilded wood | 87.6 x 48.3 x 25 cm (34 1/2 x 19 x 9 13/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/sconce-right.jpg` | A:`sconce-right.html` |
| `gold-tureen` | 2017.74.38.1a-c | [Rockefeller Service Soup Tureen with Cover on Stand](https://risdmuseum.org/art-design/collection/rockefeller-service-soup-tureen-cover-stand-201774381a-c) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 28 x 35 x 26.7 cm (11 x 13 3/4 x 10 1/2 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-tureen.jpg` | A:`gold-tureen.html` |
| `gold-ecuelle-clean` | 2017.74.38.3a-c | [Rockefeller Service Ecuelle with Cover](https://risdmuseum.org/art-design/collection/rockefeller-service-ecuelle-cover-201774383a-c) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 14 x 19.5 x 19.5 cm (5 1/2 x 7 11/16 x 7 11/16 inches) (assembled) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-ecuelle-clean.jpg` | A:`gold-ecuelle.html` |
| `gold-basket-a` | 2017.74.38.4ab | [Rockefeller Service Pierced Basket and Stand](https://risdmuseum.org/art-design/collection/rockefeller-service-pierced-basket-and-stand-201774384ab) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 10 x 20.5 x 17.5 cm (3 15/16 x 8 1/16 x 6 7/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-basket-a.jpg` | A:`gold-basket-a.html` |
| `gold-basket-b` | 2017.74.38.5ab | [Rockefeller Service Pierced Basket and Stand](https://risdmuseum.org/art-design/collection/rockefeller-service-pierced-basket-and-stand-201774385ab) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | assembled 10 x 20.5 x 17.5 cm (3 15/16 x 8 1/16 x 6 7/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-basket-b.jpg` | A:`gold-basket-b.html` |
| `gold-square-a` | 2017.74.38.11 | [Rockefeller Service Square Dish](https://risdmuseum.org/art-design/collection/rockefeller-service-square-dish-2017743811) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 3.7 x 19 x 19 cm (1 7/16 x 7 1/2 x 7 1/2 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-square-a.jpg` | A:`gold-square-a.html` |
| `gold-square-b` | 2017.74.38.12 | [Rockefeller Service Square Dish](https://risdmuseum.org/art-design/collection/rockefeller-service-square-dish-2017743812) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 3.9 x 19 x 19 cm (1 9/16 x 7 1/2 x 7 1/2 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-square-b.jpg` | A:`gold-square-b.html` |
| `gold-plate-a` | 2017.74.38.23 | [Rockefeller Service Dinner Plate](https://risdmuseum.org/art-design/collection/rockefeller-service-dinner-plate-2017743823) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 2.5 x 25 x 25 cm (1 x 9 13/16 x 9 13/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-plate-a.jpg` | A:`gold-plate-a.html` |
| `gold-plate-b` | 2017.74.38.25 | [Rockefeller Service Dinner Plate](https://risdmuseum.org/art-design/collection/rockefeller-service-dinner-plate-2017743825) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 2.6 x 25 x 25 cm (1 x 9 13/16 x 9 13/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-plate-b.jpg` | A:`gold-plate-b.html` |
| `gold-saucer-a` | 2017.74.38.9 | [Rockefeller Service Saucer](https://risdmuseum.org/art-design/collection/rockefeller-service-saucer-201774389) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 3.6 x 14.4 x 14.4 cm (1 7/16 x 5 11/16 x 5 11/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-saucer-a.jpg` | A:`gold-saucer-a.html` |
| `gold-saucer-b` | 2017.74.38.10 | [Rockefeller Service Saucer](https://risdmuseum.org/art-design/collection/rockefeller-service-saucer-2017743810) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 3.9 x 14.4 x 14.4 cm (1 9/16 x 5 11/16 x 5 11/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-saucer-b.jpg` | A:`gold-saucer-b.html` |
| `gold-cup-a` | 2017.74.38.7 | [Rockefeller Service Cup](https://risdmuseum.org/art-design/collection/rockefeller-service-cup-201774387) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 6.7 x 8.8 x 6.8 cm (2 5/8 x 3 7/16 x 2 11/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-cup-a.jpg` | A:`gold-cup-a.html` |
| `gold-cup-b` | 2017.74.38.8 | [Rockefeller Service Cup](https://risdmuseum.org/art-design/collection/rockefeller-service-cup-201774388) | Unknown Maker, Chinese export | ca. 1790 | Porcelain with enamels and gilding | 6.9 x 8.7 x 6.8 cm (2 11/16 x 3 7/16 x 2 11/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/gold-cup-b.jpg` | A:`gold-cup-b.html` |
| `tureen` | 2017.74.39.18a-c | [Dragons-in Compartments pattern covered tureen and stand](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-covered-tureen-and-stand-2017743918a-c) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 45.7 x 55.9 x 35.6 cm (18 x 22 x 14 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/tureen.jpg` | B:`tureen.html` |
| `pink-small-tureen` | 2017.74.39.19a-c | [Dragons-in Compartments pattern covered sauce tureen and stand](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-covered-sauce-tureen-and-stand-2017743919a-c) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 48.3 x 55.9 x 30.5 cm (19 x 22 x 12 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/pink-small-tureen.jpg` | A:`pink-small-tureen.html` |
| `pink-compote` | 2017.74.39.3 | [Dragons-in Compartments pattern compote](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-compote-201774393) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 9.7 x 30.6 x 22.2 cm (3 13/16 x 12 1/16 x 8 3/4 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/pink-compote.jpg` | A:`pink-compote.html` |
| `pink-bowl-a` | 2017.74.39.12 | [Dragons-in Compartments pattern square bowl](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-square-bowl-2017743912) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 4.4 x 20.5 x 20.5 cm (1 3/4 x 8 1/16 x 8 1/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/pink-bowl-a.jpg` | A:`pink-bowl-a.html` |
| `pink-bowl-b` | 2017.74.39.13 | [Dragons-in Compartments pattern square bowl](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-square-bowl-2017743913) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 4.4 x 20.5 x 20.5 cm (1 3/4 x 8 1/16 x 8 1/16 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/pink-bowl-b.jpg` | A:`pink-bowl-b.html` |
| `pink-dish` | 2017.74.39.2 | [Dragons-in Compartments pattern dish](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-dish-201774392) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 4.5 x 28.9 x 22.2 cm (1 3/4 x 11 3/8 x 8 3/4 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/pink-dish.jpg` | A:`pink-dish.html` |
| `pink-ladle` | 2017.74.39.20 | [Dragons-in Compartments pattern ladle](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-ladle-2017743920) | Worcester Porcelain Company | ca. 1810 | Porcelain with enamels and gilding | 17 x 15 x 6.6 cm (6 11/16 x 5 7/8 x 2 5/8 inches) | Gift and Bequest from the Collection of David and Peggy Rockefeller | yes | `details/pink-ladle.jpg` | A:`pink-ladle.html` |
| `apostle-41046` | 41.046 | [Apostle](https://risdmuseum.org/art-design/collection/apostle-41046) | Unknown Maker, French | ca. 1110 | Limestone | 82.6 x 26.7 cm (32 1/2 x 10 1/2 inches) | Museum Appropriation Fund | yes | `details/apostle-41046.jpg` | L (live page) |
| `apostle-41045` | 41.045 | [Apostle](https://risdmuseum.org/art-design/collection/apostle-41045) | Unknown Maker, French | ca. 1110 | Limestone | 86.4 x 25.4 cm (34 x 10 inches) | Museum Appropriation Fund | yes | `details/apostle-41045.jpg` | L (live page) |
| `2020.55` | 2020.55 | [God Save the Queens](https://risdmuseum.org/art-design/collection/god-save-queens-202055) | Léopold L. Foulem | 1994-1997 | Ceramic with decals, glaze, and metal | 33 x 16 x 16 cm (13 x 6 5/16 x 6 5/16 inches) | Georgianna Sayles Aldrich Fund | yes | `details/2020.55.jpg` | E:`god-save-queens-202055.html.gz` |
| `67.089` | 67.089 | [Seated Woman](https://risdmuseum.org/art-design/collection/seated-woman-67089) | Raymond Duchamp-Villon; Roman Bronze Works, foundry | cast 1915 | Bronze, gold wash | 71.1 x 20.3 x 24.1 cm (28 x 8 x 9 1/2 inches) | Mary B. Jackson Fund and Museum Membership Fund | yes | `details/67.089.jpg` | L (live page) |

¹ The page prints the maker line as "Unknown Maker, Possibly" and gives "Possibly, Netherlandish" under Culture. The two are joined here. The museum's 2020 caption for this painting reads "Possibly; Netherlandish".
² The page lists four titles: The Green Pumpkin; La Courge; Der Kürbis; La Fênètre sur le jardin (The Garden Window). The first is used; it is the page heading and the API title.

Maker lines as the catalogue prints them, where `maker` is shorter:

- Bruges Master (Netherlandish, active late 15th century)
- Jan Joest (Dutch, ca. 1450-1519)
- Attributed to Jan Mostaert (Dutch, ca. 1475-1555/56)
- Georgette de Montenay (French, 1540 - 1581), author
- Pierre Woeiriot (French, 1532 - 1599), engraver
- Probably Castel Durante (Italian)
- Pierre Reymond (French, ca. 1513-after 1584), enameler
- Lippo di Benivieni (Italian, active 1296-1327)
- Georges Braque (French, 1882–1963, b. in Le Havre, France)
- Jacques Villon (French, 1875-1963)
- Henri Victor Gabriel Le Fauconnier (French, 1881-1946)
- Henri Matisse (French, 1869–1954, b, in Le Cateau-Cambrésis, France)
- Paul Cézanne (French, 1839-1906)
- Ralph Wood the younger (English, 1748-1795)
- Ralph Wood the younger (English, 1748-1795), maker
- John Voyez (English, fl. 1765-1791), modeler
- Joseph Chinard (French, 1756-1813)
- Worcester Porcelain Company (English, 1751- present)
- Léopold L. Foulem (Canadian, 1945–2023, b. in Caraquet, New Brunswick, Canada)
- Raymond Duchamp-Villon (French, 1876-1918)

Two further notes on makers. The Woodcutters 29.280 is printed "Unknown Maker, French" while its Culture field reads "French, South Netherlandish"; the printed line is kept. For the Diptych 22.201 and the others printed "Unknown Maker, …" the line is kept whole, so the caption still says where the work was made.

## Fourteen more entries, beyond the list

`build/registered-objects.json` was written at 21:58. At 22:44 commit `a29ad9e9` changed the registry in `main_build_walk.gd`: a framed painting with no catalogue metadata is now clickable too, keyed by the accession number in its canvas file name (`painting-<accession>.jpg`, `wallpaper-<accession>.jpg`), and without an entry its caption is that bare number. Reading `collection_rooms/remodel_room.gd` gives 14 such works. Their keys are inferred from that code; the game was not run and no new registry list exists, so the list of 14 is not checked against the running game.

All 14 are identified. The builder counts each among its verified paintings, panels and wallpaper (`collection_rooms/remodel_room.gd`). For 13 the repo's inventories record a match against the official photograph, most of them naming the matching details (`image-work/collection-room-remodel/hall-stairs-inventory.json`, `european-gallery-inventory.json`, `sculpture-room-inventory.json`, `video-inventory.json`, `catalogue/verified-inventory.json`, `docs/research/collection-scale-anchors.md`). For the Romany portrait 2009.9 no written match was found, so it was looked at for this report: the film frame its frame was made from (IMG_6380 at 140 s) shows the same sitter, fur hat, white cravat and cane as the catalogue photograph, and the catalogue's label copy for the Récamier bust in the same room says Vestris's "portrait hangs nearby".

The text was taken and cross-checked the same way as for the 67. No picture changes: each entry points at the canvas the game already shows.

| Key | Accession | Title | Maker | Date | Medium | Dimensions | Credit line | Identified | Picture | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `43.571` | 43.571 | [Jura Landscape (Paysage de Jura)](https://risdmuseum.org/art-design/collection/jura-landscape-paysage-de-jura-43571) | Gustave Courbet | 1869 | Oil on canvas | 59.7 x 73.3 cm (23 1/2 x 28 7/8 inches) | Museum Appropriation Fund, by exchange and Walter H. Kimbell Fund | yes | `painting-43.571.jpg` | L (live page) |
| `24.089` | 24.089 | [Banks of a River Dominated in the Distance by Hills](https://risdmuseum.org/art-design/collection/banks-river-dominated-distance-hills-24089) | Jean-Baptiste-Camille Corot | ca. 1871-1873 | Oil on canvas | 31.9 x 46 x 3.8 cm (12 9/16 x 18 1/8 x 1 1/2 inches) | Museum Appropriation Fund | yes | `painting-24.089.jpg` | L (live page) |
| `56.214` | 56.214 | [Tivoli](https://risdmuseum.org/art-design/collection/tivoli-56214) | Jean-Victor Bertin | ca. 1835-1842 | Oil on canvas | 48.9 x 65.1 cm (19 1/4 x 25 5/8 inches) | Gift of Mr. Robert R. Endicott | yes | `painting-56.214.jpg` | L (live page) |
| `58.197` | 58.197 | [Portrait of Mrs. Edwards](https://risdmuseum.org/art-design/collection/portrait-mrs-edwards-58197) | John Constable | ca. 1818 | Oil on canvas | 76 x 63.7 cm (29 15/16 x 25 1/16 inches) | Corporate Membership Fund | yes | `painting-58.197.jpg` | L (live page) |
| `2009.9` | 2009.9 | [Portrait of the Dancer, Auguste Vestris](https://risdmuseum.org/art-design/collection/portrait-dancer-auguste-vestris-20099) | Adèle Romany | 1793 | Oil on canvas | 95.2 x 76.2 cm (37 1/2 x 30 inches) | Purchased with the Edith C. Erlenmeyer Bequest and the Helen M. Danforth Acquisition Fund | yes | `painting-2009.9.jpg` | A:`romany.html` |
| `34.912` | 34.912 | [Arabesque Wallpaper](https://risdmuseum.org/art-design/collection/arabesque-wallpaper-34912) | Attributed to François Louis Prieur, designer; Jean-Baptiste Réveillon, manufacturer | ca. 1780 | Woodblock print on paper | 114.5 x 56 cm (45 1/16 x 22 1/16 inches) | Mary B. Jackson Fund | yes | `wallpaper-34.912.jpg` | L (live page) |
| `35.786` | 35.786 | [Arabs Traveling](https://risdmuseum.org/art-design/collection/arabs-traveling-35786) | Eugène Delacroix | 1855 | Oil on canvas | 54.1 x 65.1 cm (21 5/16 x 25 5/8 inches) | Museum Appropriation Fund | yes | `painting-35.786.jpg` | L (live page) |
| `36.003` | 36.003 | [Christ Ministered To by the Angels](https://risdmuseum.org/art-design/collection/christ-ministered-angels-36003) | Domenico Fetti | ca. 1620 | Oil on canvas | 89.5 x 78.1 cm (35 1/4 x 30 3/4 inches) | Museum Appropriation Fund | yes | `painting-36.003.jpg` | L (live page) |
| `61.006` | 61.006 | [Christ on the Cold Stone with Two Angels](https://risdmuseum.org/art-design/collection/christ-cold-stone-two-angels-61006) | Hendrick Goltzius | 1602 | Oil on copper | 51 x 34.5 cm (20 1/16 x 13 9/16 inches) (measure of the copper panel support) | Museum Gift Fund, Museum Works of Art Fund and Corporate Membership Fund | yes | `painting-61.006.jpg` | L (live page) |
| `16.236` | 16.236 | [Madonna and Child](https://risdmuseum.org/art-design/collection/madonna-and-child-16236) | Circle of Pietro Perugino, artist | ca. 1490 | Tempera | 57.5 x 39.1 cm (22 5/8 x 15 3/8 inches) | Gift of Manton B. Metcalf | yes | `painting-16.236.jpg` | `image-work/collection-room-remodel/inventory-catalogue/perugino-madonna.html.gz` |
| `20.207` | 20.207 | [Madonna and Child](https://risdmuseum.org/art-design/collection/madonna-and-child-20207) | Bartolo di Fredi Cini | ca. 1380 | Tempera and gold on panel | 90.2 x 63.5 cm (35 1/2 x 25 inches) | Anonymous gift | yes | `painting-20.207.jpg` | F:`bartolo-madonna.html.gz` |
| `57.301` | 57.301 | [Virgin of the Annunciation](https://risdmuseum.org/art-design/collection/virgin-annunciation-57301) | Matteo di Giovanni di Bartolo | ca. 1474 | Tempera and gold on wood panel | 73.7 x 41.9 x 3.2 cm (29 x 16 1/2 x 1 1/4 inches) | Gift of Mr. Robert Lehman | yes | `painting-57.301.jpg` | F:`virgin-annunciation.html.gz` |
| `22.047` | 22.047 | [The Taking of Saint Peter](https://risdmuseum.org/art-design/collection/taking-saint-peter-22047) | Jacopo di Cione | 1370-1371 | Tempera and gold on panel | 38.7 x 54 cm (15 1/4 x 21 1/4 inches) | Gift of Manton B. Metcalf | yes | `painting-22.047.jpg` | F:`taking-peter.html.gz` |
| `21.250` | 21.250 | [Mary Magdalene](https://risdmuseum.org/art-design/collection/mary-magdalene-21250) | Lippo Memmi | ca. 1330 | Tempera and gold on panel | 49.5 x 22.5 cm (19 1/2 x 8 7/8 inches) | Museum Appropriation Fund | yes | `painting-21.250.png` | F:`memmi-magdalene.html.gz` |

F is `docs/evidence/collection-reconstruction/main-worker-connected-loop-20261001T0735/` (saved catalogue pages, tracked in this branch, read in the other worktree and checked identical to HEAD: 4 of 4). For 13 of the 14 the title, dimensions, credit line, object number and page address equal the saved API record and the printed date lies inside its year range. 35.786 has no saved API record; its page agrees with the maker, title, date, medium and size written in `docs/research/collection-scale-anchors.md`.

The eight live pages for these entries, read the same way as the nine above:

| Key | Live page | Read (UTC; the evening of 2026-10-01 local) | sha256 of the page | Saved API record |
| --- | --- | --- | --- | --- |
| `43.571` | https://risdmuseum.org/art-design/collection/jura-landscape-paysage-de-jura-43571 | 2026-10-02 02:50 | `2dbe75892b93870e…` | `image-work/collection-room-remodel/inventory-catalogue/courbet-jura.json` |
| `24.089` | https://risdmuseum.org/art-design/collection/banks-river-dominated-distance-hills-24089 | 2026-10-02 02:50 | `42583f0ae89551be…` | `image-work/collection-room-remodel/inventory-catalogue/corot-river.json` |
| `56.214` | https://risdmuseum.org/art-design/collection/tivoli-56214 | 2026-10-02 02:50 | `ec19004015e6fb0d…` | `image-work/collection-room-remodel/inventory-catalogue/bertin-tivoli.json` |
| `58.197` | https://risdmuseum.org/art-design/collection/portrait-mrs-edwards-58197 | 2026-10-02 02:50 | `a60cdddbdc49bb38…` | `image-work/collection-room-remodel/catalogue/edwards.json` |
| `34.912` | https://risdmuseum.org/art-design/collection/arabesque-wallpaper-34912 | 2026-10-02 02:50 | `6a539e152a97ea7a…` | `image-work/collection-room-remodel/inventory-catalogue/arabesque-wallpaper.json` |
| `35.786` | https://risdmuseum.org/art-design/collection/arabs-traveling-35786 | 2026-10-02 02:50 | `3b21158130abdeaf…` | none |
| `36.003` | https://risdmuseum.org/art-design/collection/christ-ministered-angels-36003 | 2026-10-02 02:50 | `453a5ca92601b23e…` | `image-work/collection-room-remodel/inventory-catalogue/fetti-angels.json` |
| `61.006` | https://risdmuseum.org/art-design/collection/christ-cold-stone-two-angels-61006 | 2026-10-02 02:50 | `b6c15f38ec5cb9da…` | `image-work/collection-room-remodel/inventory-catalogue/goltzius-cold-stone.json` |

The pictures, each checked against the first photograph on its catalogue page. Nine are that photograph with the frame or backdrop margin trimmed off, as the room uses them:

| Key | File | Same as | Photograph address | Flag |
| --- | --- | --- | --- | --- |
| `43.571` | `painting-43.571.jpg` | the same photograph trimmed to the picture's edge (1286 x 1041 of 1324 x 1076 px) | https://risdmuseum.cdn.picturepark.com/v/x3xSx1hh/ | public |
| `24.089` | `painting-24.089.jpg` | the same photograph trimmed to the picture's edge (1288 x 893 of 1324 x 934 px) | https://risdmuseum.cdn.picturepark.com/v/DQCmD2OA/ | public |
| `56.214` | `painting-56.214.jpg` | the same photograph trimmed to the picture's edge (1312 x 961 of 1324 x 974 px) | https://risdmuseum.cdn.picturepark.com/v/T4qrVDcs/ | public |
| `58.197` | `painting-58.197.jpg` | byte-identical | https://risdmuseum.cdn.picturepark.com/v/2ksGfrXn/ | public |
| `2009.9` | `painting-2009.9.jpg` | byte-identical | https://risdmuseum.cdn.picturepark.com/v/dRo3vnmy/ | public |
| `34.912` | `wallpaper-34.912.jpg` | byte-identical | https://risdmuseum.cdn.picturepark.com/v/qBOEG5od/ | public |
| `35.786` | `painting-35.786.jpg` | byte-identical | https://risdmuseum.cdn.picturepark.com/v/vYBlWEMP/ | public |
| `36.003` | `painting-36.003.jpg` | the same photograph trimmed to the picture's edge (1251 x 1441 of 1324 x 1502 px) | https://risdmuseum.cdn.picturepark.com/v/HAjDcGPD/ | public |
| `61.006` | `painting-61.006.jpg` | byte-identical | https://risdmuseum.cdn.picturepark.com/v/R1EfsPhB/ | public |
| `16.236` | `painting-16.236.jpg` | the same photograph trimmed to the picture's edge (1266 x 1873 of 1324 x 1931 px) | https://risdmuseum.cdn.picturepark.com/v/ow98TCfy/ | none printed |
| `20.207` | `painting-20.207.jpg` | the same photograph trimmed to the picture's edge (1201 x 1710 of 1324 x 1760 px) | https://risdmuseum.cdn.picturepark.com/v/hIc18mFg/ | public |
| `57.301` | `painting-57.301.jpg` | the same photograph trimmed to the picture's edge (1123 x 1987 of 1324 x 2125 px) | https://risdmuseum.cdn.picturepark.com/v/v8oXDCDk/ | public |
| `22.047` | `painting-22.047.jpg` | the same photograph trimmed to the picture's edge (1269 x 912 of 1324 x 958 px) | https://risdmuseum.cdn.picturepark.com/v/2NRhK6lw/ | public |
| `21.250` | `painting-21.250.png` | the same photograph trimmed to the painted panel, without its tabernacle frame (850 x 1913 of 1324 x 2358 px) | https://risdmuseum.cdn.picturepark.com/v/elCzH3HD/ | public |

"Trimmed" was judged by eye on a side-by-side sheet for the nine; the five others are byte-identical. All 14 files already have `.import` files.

Maker lines as the catalogue prints them: Gustave Courbet (French, 1819-1877); Jean-Baptiste-Camille Corot (French, 1796-1875); Jean-Victor Bertin (French, 1767-1842); John Constable (English, 1776-1837); Adèle Romany (French, 1769-1846); Attributed to François Louis Prieur (French, active 1780-1800), designer; Jean-Baptiste Réveillon (French, 1753–1791), manufacturer; Eugène Delacroix (French, 1798-1863); Domenico Fetti (Italian, ca. 1589-1623); Hendrick Goltzius (Dutch, 1558-1617); Circle of Pietro Perugino (Italian, ca. 1450-1523), artist; Bartolo di Fredi Cini (Italian, active in Siena by 1353); Matteo di Giovanni di Bartolo (Italian, ca. 1430-1495); Jacopo di Cione (Italian, ca. 1330- 1398); Lippo Memmi (Italian, Active 1317–ca. 1350).

These 14 have no `size_m` in the list, so they are not in the dimension comparison below.

## Pictures changed, and why

59 changed. In short:

1. **45: generated texture, now a museum photograph.** The 42 Rockefeller room pieces bar the ewe and lamb, the two apostles, `2020.55` and `67.089`.
2. **4: wrong view, now the front.** `34.016`, `35.713`, `2021.131`, `23.307X`.
3. **7: cut-out or crop, now the whole photograph.** `46.391`, `57.302`, `51.105`, `2017.29`, `34.024`, `29.280`, `70.058`.
4. **2: frame or texture sheet, now the picture.** `lion-panel`, `48.248`.
5. **1: better page of the open book.** `2023.17`.

| Key | Was | Now | New picture |
| --- | --- | --- | --- |
| `34.016` | `book-cover-34016-zoom-1.jpg`: the spine only (catalogue photograph 2 of 7) | the catalogue's first photograph: cover board, boss and chains | `renaissance-case-a/textures/book-cover-34016-zoom-0.jpg` |
| `2023.17` | `emblem-left-page.png`: the verse page of the open book | the facing page with the emblem engraving. Both are crops of the owner's film; the museum publishes no photograph | `renaissance-case-a/textures/emblem-right-page.png` |
| `35.713` | `drug-jar-albarello-35713-zoom-1.jpg`: the reverse of the jar (catalogue photograph 2 of 2) | the front, with the saint in the cartouche | `renaissance-case-a/textures/drug-jar-albarello-35713-zoom-0.jpg` |
| `46.391` | `plate-46391-front.png`: a crop to the plate's outline, corners filled with smeared edge pixels | the museum's front photograph | `details/46.391.jpg` |
| `57.302` | `plate-57302-front.png`: a crop to the plate's outline, corners filled with smeared edge pixels | the museum's front photograph | `details/57.302.jpg` |
| `51.105` | `roundel-51105-front.png`: a crop to the roundel's outline, corners filled with smeared edge pixels | the museum's front photograph | `details/51.105.jpg` |
| `2017.29` | `glass-201729-front.png`: a crop to the roundel's outline, corners filled with smeared edge pixels | the museum's front photograph | `details/2017.29.jpg` |
| `34.024` | `plaque-34024-front.png`: a crop to the plaque's outline with smeared edge padding | the museum's front photograph | `details/34.024.jpg` |
| `2021.131` | `triptych-2021131-centre-back.png`: the bare wooden back of the centre panel | the whole triptych, open, from the front | `details/2021.131.jpg` |
| `23.307X` | `velvet-23307x-rear.png`: the back, the plain lining, cut out of its photograph | the front, whole photograph | `details/23.307X.jpg` |
| `29.280` | `woodcutters-29280-front.png`: the front cut out of its backdrop, with a transparent surround | the whole photograph | `details/29.280.jpg` |
| `lion-panel` | `lion-panel-volume.png`: the model's texture sheet with the panel twice | the official photograph | `lion-panel-official.jpg` |
| `48.248` | `braque-frame.png`: the frame texture with an empty white middle | the painting | `painting-48.248.jpg` |
| `70.058` | `painting-70.058.png`: the oval cut out onto white | the official photograph of the whole canvas | `villon-official-original.jpg` |
| `recamier` | `recamier-volume.png`: the model's texture sheet: a generated front and back side by side | the museum's front photograph | `details/recamier.jpg` |
| `apostle-41046` | `apostle-41046-volume.png`: the model's texture sheet: a generated front beside a blank stone swatch | the museum's front photograph | `details/apostle-41046.jpg` |
| `apostle-41045` | `apostle-41045-volume.png`: the model's texture sheet: a generated front beside a blank stone swatch | the museum's front photograph | `details/apostle-41045.jpg` |
| `2020.55` | `decal-queens-roundel.png`: a crop of a generated view showing one roundel only | the museum's front photograph | `details/2020.55.jpg` |
| `67.089` | `seated-woman-bronze.webp`: a generated bronze surface swatch with no figure in it | the museum's front photograph | `details/67.089.jpg` |

The other 40 changed the same way. Each showed `<key>-volume.png`, a generated low-polygon cut-out of the object on a transparent ground (the model's texture), not a photograph, and now shows `details/<key>.jpg`, the museum's front photograph: `st-george`, `flute-player`, `hudibras`, `bear-jug`, `horn-player`, `finch`, `finch-pair`, `bagpiper`, `bear-jug-pair`, `cream-jug`, `parrot`, `fox`, `parrot-pair`, `agate-teapot`, `shepherd`, `candlestick`, `cow`, `candlestick-pair`, `parrot-third`, `sconce-left`, `sconce-right`, `gold-tureen`, `gold-ecuelle-clean`, `gold-basket-a`, `gold-basket-b`, `gold-square-a`, `gold-square-b`, `gold-plate-a`, `gold-plate-b`, `gold-saucer-a`, `gold-saucer-b`, `gold-cup-a`, `gold-cup-b`, `tureen`, `pink-small-tureen`, `pink-compote`, `pink-bowl-a`, `pink-bowl-b`, `pink-dish`, `pink-ladle`.

Kept as they were (8): `58.196`, `45.042`, `34.861`, `22.201`, `1995.043`, `57.037`, `43.255` already showed the catalogue's first photograph. `ewe-lamb` keeps its generated texture because no museum photograph exists.

The official photograph of the diptych 22.201 shows one carved leaf beside a blank white leaf. That is the museum's own picture; it was not cropped.

## Pictures added: source and credit

Each file is the museum's catalogue photograph for that accession, made smaller. "Photo" is its position on the catalogue page. "Flag" is the museum's own `data-asset-copyright` mark on that photograph. 52 of the 53 pages state "This object is in the Public Domain and available under a CC0 1.0 Universal (CC0 1.0) Public Domain Dedication". The page for 2020.55 states "This object is in copyright". The repo's standing credit for catalogue images is "Courtesy of the RISD Museum, Providence, RI" (`modules/shell/PROVENANCE.md`).

| File in `details/` | Pixels | KB | Accession | Photo | Photograph address | Flag | Credit line |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `46.391.jpg` | 1024 x 915 | 144 | 46.391 | 1 of 1 | https://risdmuseum.cdn.picturepark.com/v/w5YG5o7l/ | public | Gift of Mrs. Jesse H. Metcalf |
| `57.302.jpg` | 1024 x 1024 | 170 | 57.302 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/2VTIqMAb/ | public | Gift of Mr. Robert Lehman |
| `51.105.jpg` | 1006 x 1024 | 251 | 51.105 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/NjBqgH31/ | public | Museum Works of Art Fund |
| `2017.29.jpg` | 1024 x 949 | 194 | 2017.29 | 1 of 2 | https://risdmuseum.cdn.picturepark.com/v/hQORsuBr/ | public | Gift of Mary Jane and Glenn Creamer |
| `34.024.jpg` | 1024 x 1024 | 214 | 34.024 | 1 of 2 | https://risdmuseum.cdn.picturepark.com/v/mCSt3L6m/ | public | Mary B. Jackson Fund |
| `2021.131.jpg` | 1024 x 856 | 143 | 2021.131 | 1 of 8 | https://risdmuseum.cdn.picturepark.com/v/PJYjnH8u/ | public | Gift of Ambassador J. William Middendorf II |
| `23.307X.jpg` | 434 x 1024 | 129 | 23.307X | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/Boy93jNs/ | public | Museum Appropriation Fund |
| `29.280.jpg` | 647 x 1024 | 218 | 29.280 | 1 of 2 | https://risdmuseum.cdn.picturepark.com/v/XFexgLtH/ | public | Gift of Dr. and Mrs. Murray S. Danforth |
| `st-george.jpg` | 765 x 1024 | 82 | 2017.74.14 | 1 of 12 | https://risdmuseum.cdn.picturepark.com/v/KOCc1yRw/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `flute-player.jpg` | 1024 x 683 | 56 | 2017.74.16 | 1 of 6 | https://risdmuseum.cdn.picturepark.com/v/jhhCOZ1D/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `hudibras.jpg` | 808 x 1024 | 99 | 2017.74.17 | 1 of 12 | https://risdmuseum.cdn.picturepark.com/v/l4NTeToS/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `bear-jug.jpg` | 791 x 1024 | 100 | 2017.74.18.ab | 2 of 14 | https://risdmuseum.cdn.picturepark.com/v/3otLhIE5/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `horn-player.jpg` | 703 x 1024 | 57 | 2017.74.19 | 1 of 8 | https://risdmuseum.cdn.picturepark.com/v/A12G8Hpd/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `finch.jpg` | 1011 x 1024 | 55 | 2017.74.15.1 | 1 of 6 | https://risdmuseum.cdn.picturepark.com/v/8jvC5QQJ/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `finch-pair.jpg` | 1024 x 1004 | 61 | 2017.74.15.2 | 1 of 6 | https://risdmuseum.cdn.picturepark.com/v/ivk9OMKC/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `bagpiper.jpg` | 703 x 1024 | 52 | 2017.74.21 | 1 of 8 | https://risdmuseum.cdn.picturepark.com/v/Zx0xVBiB/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `bear-jug-pair.jpg` | 776 x 1024 | 101 | 2017.74.22.ab | 2 of 12 | https://risdmuseum.cdn.picturepark.com/v/ta7826qy/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `cream-jug.jpg` | 803 x 1024 | 109 | 2017.74.25 | 1 of 8 | https://risdmuseum.cdn.picturepark.com/v/YjAbQJdm/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `parrot.jpg` | 871 x 1024 | 76 | 2017.74.27.1 | 1 of 10 | https://risdmuseum.cdn.picturepark.com/v/e7tq4kSw/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `fox.jpg` | 980 x 1024 | 99 | 2017.74.20 | 1 of 5 | https://risdmuseum.cdn.picturepark.com/v/c10eRBXj/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `parrot-pair.jpg` | 871 x 1024 | 79 | 2017.74.27.2 | 1 of 10 | https://risdmuseum.cdn.picturepark.com/v/sXEdKPE1/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `agate-teapot.jpg` | 1024 x 883 | 95 | 2017.74.24.ab | 1 of 8 | https://risdmuseum.cdn.picturepark.com/v/KZFRgFus/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `shepherd.jpg` | 749 x 1024 | 63 | 2017.74.23 | 1 of 6 | https://risdmuseum.cdn.picturepark.com/v/QwJV4vor/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `candlestick.jpg` | 748 x 1024 | 55 | 2017.74.28.1 | 1 of 14 | https://risdmuseum.cdn.picturepark.com/v/YAru9uEj/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `cow.jpg` | 1024 x 759 | 68 | 2017.74.29 | 1 of 5 | https://risdmuseum.cdn.picturepark.com/v/8qJLFajx/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `candlestick-pair.jpg` | 748 x 1024 | 61 | 2017.74.28.2 | 1 of 13 | https://risdmuseum.cdn.picturepark.com/v/T4Ocrlgt/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `parrot-third.jpg` | 973 x 1024 | 83 | 2017.74.26 | 1 of 6 | https://risdmuseum.cdn.picturepark.com/v/S3PPbnNl/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `recamier.jpg` | 875 x 1024 | 50 | 37.201 | 3 of 6 | https://risdmuseum.cdn.picturepark.com/v/3ShRxwBU/ | public | Gift of Mrs. Harold Brown |
| `sconce-left.jpg` | 769 x 1024 | 76 | 2017.74.6.3 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/2GeESMJp/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `sconce-right.jpg` | 725 x 1024 | 72 | 2017.74.6.4 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/RyZvucLj/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-tureen.jpg` | 1024 x 801 | 105 | 2017.74.38.1a-c | 2 of 8 | https://risdmuseum.cdn.picturepark.com/v/NJ5xCHxF/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-ecuelle-clean.jpg` | 683 x 1024 | 114 | 2017.74.38.3a-c | 4 of 4 | https://risdmuseum.cdn.picturepark.com/v/5L2ohQHG/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-basket-a.jpg` | 1024 x 954 | 197 | 2017.74.38.4ab | 1 of 5 | https://risdmuseum.cdn.picturepark.com/v/ECzhZL30/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-basket-b.jpg` | 1024 x 954 | 189 | 2017.74.38.5ab | 1 of 5 | https://risdmuseum.cdn.picturepark.com/v/XyByehJ1/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-square-a.jpg` | 1024 x 1024 | 243 | 2017.74.38.11 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/iyCrCjFY/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-square-b.jpg` | 1024 x 1024 | 236 | 2017.74.38.12 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/V8ZkUbb9/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-plate-a.jpg` | 1024 x 1024 | 231 | 2017.74.38.23 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/k90KY64f/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-plate-b.jpg` | 1024 x 1024 | 220 | 2017.74.38.25 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/6N57GSJm/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-saucer-a.jpg` | 1024 x 1024 | 169 | 2017.74.38.9 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/o3a7yqny/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-saucer-b.jpg` | 1024 x 1024 | 173 | 2017.74.38.10 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/WpTvz81i/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-cup-a.jpg` | 768 x 1024 | 100 | 2017.74.38.7 | 2 of 3 | https://risdmuseum.cdn.picturepark.com/v/qFznDBkm/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `gold-cup-b.jpg` | 768 x 1024 | 95 | 2017.74.38.8 | 2 of 3 | https://risdmuseum.cdn.picturepark.com/v/tdp6hLMT/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `tureen.jpg` | 1024 x 768 | 93 | 2017.74.39.18a-c | 1 of 19 | https://risdmuseum.cdn.picturepark.com/v/kTy8940V/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `pink-small-tureen.jpg` | 1024 x 768 | 91 | 2017.74.39.19a-c | 1 of 10 | https://risdmuseum.cdn.picturepark.com/v/SrOd1gxP/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `pink-compote.jpg` | 1024 x 696 | 56 | 2017.74.39.3 | 2 of 5 | https://risdmuseum.cdn.picturepark.com/v/4YhdkvzY/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `pink-bowl-a.jpg` | 1024 x 1024 | 248 | 2017.74.39.12 | 1 of 10 | https://risdmuseum.cdn.picturepark.com/v/Lfrj405Y/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `pink-bowl-b.jpg` | 1024 x 1024 | 242 | 2017.74.39.13 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/8AltdYOb/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `pink-dish.jpg` | 1024 x 768 | 163 | 2017.74.39.2 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/9Cqdf64G/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `pink-ladle.jpg` | 768 x 1024 | 51 | 2017.74.39.20 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/fNB1PRCy/ | public | Gift and Bequest from the Collection of David and Peggy Rockefeller |
| `apostle-41046.jpg` | 585 x 1024 | 107 | 41.046 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/DHU20bNx/ | public | Museum Appropriation Fund |
| `apostle-41045.jpg` | 516 x 1024 | 98 | 41.045 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/zuhuw9Ju/ | public | Museum Appropriation Fund |
| `2020.55.jpg` | 665 x 1024 | 77 | 2020.55 | 1 of 4 | https://risdmuseum.cdn.picturepark.com/v/KbpEh5DI/ | in_copyright | Georgianna Sayles Aldrich Fund |
| `67.089.jpg` | 772 x 1024 | 63 | 67.089 | 1 of 3 | https://risdmuseum.cdn.picturepark.com/v/oEoan8PK/ | public | Mary B. Jackson Fund and Museum Membership Fund |

Total: 53 files, 6,653,559 bytes (6.65 MB).

Where the first photograph was not used:

1. `bear-jug`, `bear-jug-pair`: photograph 1 shows the two jugs together. Photograph 2 is the single jug, with the lute for 2017.74.18.ab and with the horn for 2017.74.22.ab.
2. `gold-tureen`: photograph 1 is the stand alone, from above. Photograph 2 is the tureen assembled, from the front.
3. `gold-ecuelle-clean`, `gold-cup-a`, `gold-cup-b`: the studio photographs show only the stand or the underside. The one upright view of each is a registration snapshot with the museum's handwritten tag in it (photograph 4 of 4, and 2 of 3). They are the museum's own photographs and the tag gives the same number.
4. `pink-compote`: photograph 2 is the front. Photograph 1 looks down into the dish.
5. `recamier`: photograph 3 is the frontal view. Photograph 1 is a three-quarter view.

Saved copies came first:

1. For 10 of the new pictures the project already held the photograph (`46.391`, `57.302`, `51.105`, `2017.29`, `34.024`, `2021.131`, `23.307X`, `29.280`, `2020.55`, `67.089`). Each saved file was checked to be byte-identical to the photograph address above.
2. For the two apostles the saved copies are 500 px renditions; the 1324 px rendition was downloaded from the address above.
3. The other 41 were downloaded from the museum's image host at the addresses printed on the saved catalogue pages.

Photographs already in `collection_rooms/assets/` that entries now point at, each checked against the catalogue page's first photograph:

| Key | File | Same as | Flag |
| --- | --- | --- | --- |
| `48.248` | `painting-48.248.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/WIyhGZjJ/ | in_copyright |
| `70.058` | `villon-official-original.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/cRCDzmxu/ | in_copyright |
| `1995.043` | `painting-1995.043.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/RK1csqaA/ | public |
| `57.037` | `painting-57.037.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/ywzOF1RV/ | public |
| `43.255` | `painting-43.255.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/sBCgV21W/ | public |
| `lion-panel` | `lion-panel-official.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/eXYnlWu0/ | public |
| `45.042` | `renaissance-case-a/textures/portrait-cleric-45042-zoom-0.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/oAufUR56/ | public |
| `34.861` | `renaissance-case-a/textures/portrait-woman-34861-zoom-0.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/oERfpI6k/ | public |
| `22.201` | `renaissance-case-a/textures/diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-0.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/NvaH0LOW/ | public |
| `34.016` | `renaissance-case-a/textures/book-cover-34016-zoom-0.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/34mkvosa/ | public |
| `35.713` | `renaissance-case-a/textures/drug-jar-albarello-35713-zoom-0.jpg` | byte-identical to https://risdmuseum.cdn.picturepark.com/v/IKFPnPof/ | public |
| `58.196` | `renaissance-wall/madonna-58196-front.png` | pixel-identical (PNG of the same photograph) to https://risdmuseum.cdn.picturepark.com/v/E9uDki01/ | public |
| `2023.17` | `renaissance-case-a/textures/emblem-right-page.png` | not a museum photograph: a straightened crop of the owner's film (IMG_6383 at 46.40 s) | — |
| `ewe-lamb` | `ewe-lamb-volume.png` | not a museum photograph: the model's generated texture | — |

## Left unidentified

Both have a strong candidate. The repo holds each below "matched", so neither is printed as fact. To accept one, copy its `candidate` fields up and set `identified` to true.

1. **`34.024`, the small plaque in Renaissance case B.**
   - Candidate: Pierre Reymond, *Virgin and Child with Clerics and Donors*, RISD 34.024.
   - The repo: the inventory holds it at "probable (form only)" (`docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001/REPORT.md`). The builder carries `identity: "probable"` (`collection_rooms/renaissance_case_b_assets.gd`), its check requires that value (`docs/evidence/collection-reconstruction/opus-renaissance-case-b-assets-20261001/check.gd`), and the room lists it under `probable` (`collection_rooms/remodel_room.gd`).
   - For it, from the inventory: the right size and colour, and the only such enamel plaque its searches returned as on view.
   - For it, read on both catalogue pages for this report: its label copy opens with the same sentence as that of the glass roundel 2017.29, which stands beside it ("Objects made for private devotion often depicted Mary as an intercessor for the faithful"), and goes on "In this French enamel plaque…".
   - Against calling it settled: the film (IMG_6383 at 56 to 57 s, sheet `docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001/sheets/R18-enamel-plaque-34.024.jpg`) does not resolve the scene, and the case label is not legible.
   - What would settle it: a readable photograph of the case B label, or one sharp front view of the plaque.
   - The picture shown is the museum's photograph of 34.024, because the model in the room is built from it.
2. **`ewe-lamb`, the pale group in the middle of the bookcase's upper shelf.**
   - Candidate: *Ewe and Lamb*, RISD 2017.74.32.
   - The repo: "catalogue candidate supported by title/dimensions and video; photo verification unavailable" (`collection_rooms/assets/catalogue-objects.json`).
   - For it, read and counted for this report: the catalogue page says "Now On View" and carries the bookcase's label copy ("Its shelves are populated with a collection of English ceramic figures"). The source frame (`docs/evidence/collection-reconstruction/main-worker-inventory-20260930/source-bookcase.png`) shows 20 objects on the bookcase. The repo matches the other 19 to records by photograph. 19 saved pages carry the bookcase label copy: 18 of those matched objects and *Ewe and Lamb*. The teapot's page has its own label copy.
   - Against calling it settled: the museum publishes no photograph of it, the film is blurred, and the saved API listing is not complete, so a 21st record cannot be ruled out.
   - What would settle it: a museum photograph of 2017.74.32, or a sharp view of the figure or of the shelf label.

## Catalogue dimensions against the built size (over 15%)

For the size audit; nothing was changed. `size_m` in `build/registered-objects.json` is read as the registry's `outer` in `main_build_walk.gd`: the wider horizontal side and the height of everything under the registered node. That reading is inferred from the code and the numbers; the script that wrote the file was not found. Catalogue numbers are read as height x width x depth. 18 of 67 differ by more than 15% in at least one direction. The reason given is what the builder or the repo's own report says the node contains, read in the file named; nothing was measured in the running game.

| Key | Catalogue | Built w x h (m) | Difference | Why, as built |
| --- | --- | --- | --- | --- |
| `58.196` | 91.4 x 87 cm (36 x 34 1/4 inches) | 1.158 x 1.06 | height +16%; width +33% | the node includes the frame (1.005 x 1.060 m) and the wall-label proxy beside it (`remodel_room.gd` build_renaissance_wall_art) |
| `45.042` | 22.2 x 14.6 x 5.7 cm (8 3/4 x 5 3/4 x 2 1/4 inches) | 0.234 x 0.322 | height +45%; width +60% | includes the grey frame: 23.4 x 32.2 cm framed (case A report) |
| `22.201` | Panel: 24.1 x 13.3 cm (9 1/2 x 5 1/4 inches) (each) | 0.267 x 0.102 | height -58%; width +101% | two leaves side by side, lying on a sloped mount (case A report) |
| `34.016` | 14 x 8.6 x 5.1 cm (5 1/2 x 3 3/8 x 2 inches) | 0.13 x 0.215 | height +54%; width +51% | stands open with its chains raised to a ring (case A report) |
| `2023.17` | 197 x 147 mm (197 x 147 mm) | 0.262 x 0.211 | height +7%; width +78% | open across two pages and reclined on its cradle (case A report) |
| `34.024` | 12.9 x 10.7 cm (5 1/16 x 4 3/16 inches) | 0.107 x 0.1 | height -22%; width +0% | tilted back 0.72 rad on its mount, so its height is foreshortened; width matches (`remodel_room.gd` build_renaissance_east_cases) |
| `23.307X` | 127 cm (50 inches) (length) | 1.046 x 1.606 | length +26% | the node includes the white board and the acrylic hood, 1.04 x 1.60 m (`remodel_room.gd` build_renaissance_wall_art). The catalogue gives a length only |
| `48.248` | 46.4 x 72.1 cm (18 1/4 x 28 3/8 inches) | 0.881 x 0.624 | height +34%; width +22% | includes the frame (`Painting.build_framed`) |
| `70.058` | 54.8 x 46 cm (21 9/16 x 18 1/8 inches) | 0.63 x 0.719 | height +31%; width +37% | includes the white box frame |
| `57.037` | 80 x 64.5 cm (31 1/2 x 25 3/8 inches) | 0.756 x 0.911 | height +14%; width +17% | includes the frame |
| `43.255` | 61 x 73.7 cm (24 x 29 inches) | 0.947 x 0.82 | height +34%; width +28% | includes the frame |
| `agate-teapot` | 13.3 x 45.7 cm (5 1/4 x 18 inches) | 0.185 x 0.133 | height +0%; width -60% | the catalogue's 45.7 cm width was judged impossible on the shelf and a 19 cm fit to the film used; height matches (`catalogue-objects.json` dimension_basis) |
| `recamier` | 60.6 x 33.7 x 23.5 cm (23 7/8 x 13 1/4 x 9 1/4 inches) | 0.336 x 0.476 | height -22%; width -0% | the registered mesh is the bust alone, 0.476 m; its 0.13 m socle is built as separate solids below it, which together give the catalogue 60.6 cm (`remodel_room.gd` build_catalogue_objects, `prepare_remodel.py`) |
| `gold-plate-a` | 2.5 x 25 x 25 cm (1 x 9 13/16 x 9 13/16 inches) | 0.249 x 0.238 | height +852%; width -0% | the plate stands tilted at 1.15 rad, so its built height is the diameter on edge, not the 2.5 cm thickness; diameter matches |
| `gold-plate-b` | 2.6 x 25 x 25 cm (1 x 9 13/16 x 9 13/16 inches) | 0.249 x 0.238 | height +815%; width -0% | the same |
| `tureen` | 45.7 x 55.9 x 35.6 cm (18 x 22 x 14 inches) | 0.416 x 0.32 | height -30%; width -26% | the catalogue heights were judged in conflict with the displayed arrangement and 0.32 m fitted from the film (`catalogue-objects.json` dimension_basis) |
| `pink-small-tureen` | 48.3 x 55.9 x 30.5 cm (19 x 22 x 12 inches) | 0.417 x 0.32 | height -34%; width -25% | the same; note the catalogue lists the sauce tureen as taller than the tureen |
| `pink-ladle` | 17 x 15 x 6.6 cm (6 11/16 x 5 7/8 x 2 5/8 inches) | 0.17 x 0.066 | height -61%; width +13% | the ladle lies flat, so its 17 cm length is horizontal; the sizes agree once turned |

The other 49 agree within 15% in every direction that the catalogue gives. Works catalogued with a height only (`bear-jug`, `bear-jug-pair`, `finch`, `finch-pair`) or a diameter only were compared in that one direction.

## Not resolved

1. **No museum photograph.** 2023.17: the catalogue page has none, so the picture is the owner's film crop of the open page, 294 x 394 px and blurred. 2017.74.32 (`ewe-lamb`): none either, so the generated texture stays.
2. **Import size and tracking.** With Godot's default lossless import the 6.65 MB of JPEG is 28.4 MB of imported textures in `.godot/imported/`, and the same again in an exported pack (measured on a scratch export). A lossy import setting would shrink that. The 53 new `.import` files are ignored by `.gitignore` (`*.import`), while the 164 `.import` files already under `collection_rooms/assets/` are tracked; whoever commits the pictures has to add the sidecars by force if that convention holds. Neither was changed here.
3. **Copyright flags.** The museum marks the photographs of 2020.55 (Foulem), 48.248 (Braque) and 70.058 (Villon) `in_copyright`. The last two were already in the repo and are only pointed at. `details/2020.55.jpg` is new; the repo records private prototype use as authorised (`image-work/collection-room-remodel/queens-202055-sources.json`). The owner should confirm or remove it.
4. **Which of a pair stands where.** For eight look-alike pairs (the finches, parrots 27.1 and 27.2, pierced baskets, square dishes, dinner plates, saucers, cups, square bowls) the builder places both, but the repo holds no check of which of the two is on which side. Each model was made from its own record's photograph, so caption, picture and model agree with each other; only left and right could be swapped.
5. **The list is older than the game.** The 14 entries beyond the list rest on reading the new registry code, not on a registry dump. Other works may have become clickable too. A fresh `build/registered-objects.json` would settle which keys the game now uses.

## Checks

Run in this checkout on 2026-10-01.

| Check | Result |
| --- | --- |
| `objects.json` parses; every key of `build/registered-objects.json` has an entry; all ten fields present with the right types | passed: 67 of 67 keys covered; 81 entries, the 14 others being the works added beyond the list |
| every `image` path exists on disk | passed: 81 of 81 |
| new pictures: JPEG, long side at most 1600 px, under 400 KB each, under 15 MB together | passed: 53 files, largest 251 KB, 6.65 MB |
| Godot 4.7.2, scratch project: `JSON.parse_string` of `objects.json`, then `ResourceLoader.exists` and `load` of each new picture after import | passed: 53 pictures loaded, 0 failures; the final 81-entry file parsed again with accented names intact |
| the web export will carry `objects.json` | passed on a scratch `all_resources` export (Godot 4.7.2 stored `res://collection_rooms/objects.json`); and the real pack `build/web/32d3ba8c.game.pck` already holds `collection_rooms/main-build-adapter.json` and `gallery_walk4/works.json`, which no include filter names. Not tested: a real export with the new file |
| the pictures pointed at in `collection_rooms/assets/` outside `details/` already have `.import` files | passed: 28 of 28 (14 for the 67, 14 for the 14 more) |
| the 53 new pictures have `.import` files and imported textures in this checkout (written by another agent's Godot pass at 22:44, not by this task) | passed: 53 of 53, none marked invalid |
| catalogue page against saved API record: title, dimensions, credit line, object number equal; printed date inside the API year range | passed: 67 of 67, and 13 of the 14 more (35.786 has no saved record) |
| files read in the `collection-reconstruction` worktree are identical to this branch's HEAD | passed: 31 of 31, and 4 of 4 for the 14 more |
| pictures pointed at or added are the photograph the catalogue page names: sha256 of the saved file against the photograph address | passed: 11 of 11 existing files and 10 of 10 saved copies byte-identical; the Madonna PNG pixel-identical |
| `scripts/check.sh` | **not run**: its Godot pass writes import files across the shared checkout, outside the paths this task may touch |

Rerun the first three:

```bash
python3 - <<'EOF'
import json, os
from PIL import Image
reg = json.load(open("build/registered-objects.json")); obj = json.load(open("collection_rooms/objects.json"))
keys = {r["key"] for r in reg}
assert keys <= set(obj), keys - set(obj)
total = 0
for k, e in obj.items():
    for f in ["title", "maker", "date", "medium", "dimensions", "accession", "credit", "image", "source"]:
        assert isinstance(e[f], str), (k, f)
    assert isinstance(e["identified"], bool) and e["title"] and e["image"].startswith("res://collection_rooms/assets/")
    path = e["image"][len("res://"):]
    assert os.path.isfile(path), path
    if "/details/" in path:
        im = Image.open(path); size = os.path.getsize(path); total += size
        assert im.format == "JPEG" and max(im.size) <= 1600 and size < 400 * 1024, path
assert total < 15e6
print(len(keys), "listed keys covered,", len(obj), "entries,", sum(e["identified"] for e in obj.values()), "identified,", round(total / 1e6, 2), "MB new pictures: ok")
EOF
```
