# Works needed — Impressionist galleries, #277

The footage contains **16 paintings and one bronze**. **42.219**, **1998.107**, **41.012** and **44.541** have existing repository images; the source hangs three in A and one in B. The other **12 paintings** keep their wall positions bare, with no placeholder frames, label cards or video textures. The dancer's case is built but empty pending an approved sculpture asset/image. No art images have been downloaded for this ticket. The copyright holds on 2025.19, 2026.3 and new photographs of 2020.55 remain in force; none is used here.

Wall directions and metres refer to the fitted plan in `NOTES.md`, not geographic north. `along` is the canvas centre measured from the **north end** of west/east walls or **west end** of north/south walls. `y` is canvas-centre height above floor. Sizes below are **width × height**, excluding frames. Catalogue sizes are exact record values; inferred frame extents and wall offsets are estimates. Position error is ±.5 m on end walls and ±.8 m on long walls; hanging height ±.15 m (Manet ±.10 m); source layout order is firmer than absolute metres. The fit stretches the room depths; offsets are consequently fitted estimates, not calibrated measurements.

## Missing images / geometry

| Slot | Title, maker, accession | Wall | along / y (m) | Canvas / object size (m) | Footage and record |
| --- | --- | --- | --- | --- | --- |
| A-N1 | Children in the Tuileries Gardens — Édouard Manet — **42.190** | A north | 4.95 / 1.62 | .460 × .378; frame about .64 × .55 ± .06 | 129, 131, 137; [RISD](https://risdmuseum.org/art-design/collection/children-tuileries-gardens-42190) |
| A-N2 | Portrait of Édouard Manet — Carolus-Duran (Charles-Auguste-Émile Durand) — **2007.68** | A north | 2.80 / 1.65 | .454 × .635; frame about .68 × .87 ± .10 | 137.8–140; straw hat, reddish beard, cheek on hand. Identity supported by [RISD curator's article](https://risdmuseum.org/manual/125_new_ways_to_paint_a_boating_party); [RISD catalogue](https://risdmuseum.org/art-design/collection/portrait-edouard-manet-200768) confirms accession and canvas size |
| A-W2 | The Seine Near its Estuary, Honfleur — Claude Monet — **57.236** | A west | 5.40 / 1.65 | .737 × .481; frame .99 × .73 ± .08 | 103–105; [RISD](https://risdmuseum.org/art-design/collection/seine-near-its-estuary-honfleur-57236) |
| A-S1 | Repose (Le Repos) — Édouard Manet — **59.027** | A south | 2.25 / 1.59 | 1.140 × 1.502; frame about 1.47 × 1.83 ± .10 | 115, 117, 145, 147; [RISD](https://risdmuseum.org/art-design/collection/repose-le-repos-59027); plane ruler in `plane-measurement.json` |
| A-E2 | La Savoisienne — Edgar Degas — **23.072** | A east, between windows | 5.20 / 1.64 | .464 × .629; frame .70 × .87 ± .08 | 121–125, 143; [RISD](https://risdmuseum.org/art-design/collection/la-savoisienne-23072) |
| A-C1 | Grand Arabesque, Second Time — Edgar Degas — **23.315** (identity inferred from pose) | A case | x14.10, z10.55; bronze bottom about 1.02 | .606 wide × .422 high × .270 deep | 145, 147, 152; [RISD](https://risdmuseum.org/art-design/collection/grand-arabesque-second-time-23315); bronze on six-sided grey plinth under clear hood |
| B-W1 | Field and Mill at Osny — Camille Pissarro — **72.096** | B west | 5.15 / 1.64 | .656 × .543; frame .94 × .82 ± .08 | 178–182; [RISD](https://risdmuseum.org/art-design/collection/field-and-mill-osny-72096); label reads Camille Pissarro, green pasture/cows/buildings |
| B-W2 | Busagny Farm, Osny — Paul Gauguin — **1999.3** | B west | 7.95 / 1.64 | .546 × .648; frame .74 × .85 ± .07 | 185–188; [RISD](https://risdmuseum.org/art-design/collection/busagny-farm-osny-19993); label reads Paul Gauguin |
| B-S2 | Chestnut Trees and Farm at Jas de Bouffan — Paul Cézanne — **33.053** | B south | 1.15 / 1.65 | .810 × .654; frame .97 × .81 ± .08 | 190–192, 214; [RISD](https://risdmuseum.org/art-design/collection/chestnut-trees-and-farm-jas-de-bouffan-33053) |
| B-E1 | Iris in a Pitcher / Iris in a Vase — Marie Bracquemond — **2021.101** | B east | .93 / 1.64 | .235 × .330; frame .37 × .47 ± .05 | 200–203; [RISD](https://risdmuseum.org/art-design/collection/iris-pitcher-2021101); readable maker on 201.8 |
| B-E2 | Child in a Red Apron — Berthe Morisot — **2010.57** | B east | 2.36 / 1.65 | .499 × .600; frame .71 × .81 ± .07 | 205–207; [RISD](https://risdmuseum.org/art-design/collection/child-red-apron-201057) |
| B-E3 | View of Auvers-sur-Oise — Vincent van Gogh — **35.770** | B east | 3.78 / 1.65 | .421 × .340; frame .66 × .58 ± .07 | 210–212; [RISD](https://risdmuseum.org/art-design/collection/view-auvers-sur-oise-35770) |
| B-E4 | Simone in a Blue Bonnet — Mary Cassatt — **60.095** | B east, between windows | 6.80 / 1.65 | .521 × .610; frame .77 × .86 ± .07 | 216, 220–223; [RISD](https://risdmuseum.org/art-design/collection/simone-blue-bonnet-60095) |

## Existing images used by the source

The prototype coverflow catalogue (`prototypes/painting-coverflow/web/paintings.json`) supplied two extra matches outside the shell's assets. Its three Monet photographs and the existing Cézanne are copied **byte-for-byte**, not fetched, cropped or generated. Their source/output hashes are in `modules/shell/PROVENANCE.md`. Provider: RISD Museum. New spend: $0. All originals stay unchanged.

| Slot | Title, maker, accession | Wall | along / y (m) | Canvas / frame size (m) | Footage and record |
| --- | --- | --- | --- | --- | --- |
| A-W1 | The Basin at Argenteuil (Le Bassin d'Argenteuil) — Claude Monet — **42.219** | A west | 2.45 / 1.65 | .743 × .552; frame 1.02 × .79 ± .08 | 98–100; [RISD](https://risdmuseum.org/art-design/collection/basin-argenteuil-le-bassin-dargenteuil-42219) |
| A-W3 | A Walk in the Meadows at Argenteuil — Claude Monet — **1998.107** | A west | 8.05 / 1.65 | .648 × .533; frame .90 × .79 ± .08 | 109–113; [RISD](https://risdmuseum.org/art-design/collection/walk-meadows-argenteuil-1998107) |
| A-E1 | Still Life with Apples — Paul Cézanne — **41.012** | A east | 1.35 / 1.62 | .397 × .232; frame .58 × .41 ± .05 | 133/149; [RISD](https://risdmuseum.org/art-design/collection/still-life-apples-41012) |
| B-S1 | The Seine at Giverny — Claude Monet — **44.541** | B south | 3.15 / 1.65 | .927 × .648; frame 1.13 × .85 ± .08 | 195, 197, 214; [RISD](https://risdmuseum.org/art-design/collection/seine-giverny-44541) |

| Accession | Existing tracked source | Pixels | SHA-256 |
| --- | --- | --- | --- |
| 42.219 | `prototypes/painting-coverflow/web/assets/42-219.jpg` | 1324 × 984 | `5bb288637b2285d4ab8276b9c51e96c4936af7a93d1a54871806473b3dc22bf1` |
| 1998.107 | `prototypes/painting-coverflow/web/assets/1998-107.jpg` | 1324 × 1095 | `ffe677d378d0a295078ab004bc6b9490f227e445f1f528d4ef0ebc995e97b648` |
| 41.012 | `image-work/collection-room-remodel/inventory-catalogue/cezanne-apples-zoom-0.jpg` | 1324 × 776 | `8bcaa3e4fa2ae5999975db8b578cc94e7d5f4493c83623630e67cc95b7e23e59` |
| 44.541 | `prototypes/painting-coverflow/web/assets/44-541.jpg` | 1324 × 933 | `a6f171bd6bb87750e3b233fd4339ca258e17d2636199f33d2cfff44711091968` |

The previously found framed IIIF copy of1998.107 is retained untouched but is not a runtime input: the coverflow copy is larger and already contains only the canvas. Existing Main Hall gilt frame E7 is used for the three Monets, W10 for Cézanne. Frame ornament is a provisional borrowed match; outer size is fitted to the footage while the canvas keeps catalogue dimensions. Blank built label cards are beside these four hung works only, without typed text.

## Follow-up certainty

All 17 visible works have an inventory entry. Identities are visual/label matches to primary museum records; the dancer's exact cast remains inferred; the Carolus-Duran accession is resolved as 2007.68. New fetched images must be checked against these frames; do not treat an approximate matching title or a different Cézanne accession already in the modern room (43.255) as this painting.
