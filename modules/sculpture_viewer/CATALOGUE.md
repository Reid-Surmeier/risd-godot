# Twenty-card museum metadata mapping — #169

Four identified objects; sixteen museum identities unknown. **Department is unknown for all twenty.** This ordered mapping preserves five rows of four, scans first. “Descriptor” is an appearance label, not a museum title. No row establishes live 3D availability or scan/image redistribution rights.

Primary-photo comparisons and source coordinates/hashes are pinned in the [research checkpoint 39a10662](https://github.com/Reid-Surmeier/risd-godot/blob/39a10662/docs/research/2026-09-28-viewer-panel-photo-matches.md), which links the earlier exact scan matches and twenty-source audit. Titles, accession numbers and summaries below derive only from those primary records. Department is not inferred from material, culture, gallery, or object type.

## Ordered fields

`unknown` explicitly means no verified museum value. Description/source codes resolve to the exact text and primary URL below; they are not additional catalogue entries. The runtime shows the museum title when verified and the descriptor otherwise.

| Slot | Stable source ID | Descriptor | Museum title / accession | Department | Description / source |
| --- | --- | --- | --- | --- | --- |
| 01 | `scan:20260811121459` | Group with skulls | Love Triumphs over Death (Cupid and Skulls) / 73.148 | unknown | A |
| 02 | `scan:20260811122415` | Sculptural relief | unknown | unknown | unknown |
| 03 | `scan:20260811123051` | Bearded bust | unknown | unknown | unknown |
| 04 | `scan:20260820133334` | Pale bust | Portrait of Hadrian / 59.050 | unknown | B |
| 05 | `panel-cell:06` | Decorated bowl | unknown | unknown | unknown |
| 06 | `panel-cell:07` | Bull | unknown | unknown | unknown |
| 07 | `panel-cell:08` | Animal-shaped vessel | unknown | unknown | unknown |
| 08 | `panel-cell:09` | Curved object | unknown | unknown | unknown |
| 09 | `panel-cell:10` | Colored bust | unknown | unknown | unknown |
| 10 | `panel-cell:11` | Standing figure | Aphrodite / 26.117 | unknown | C |
| 11 | `panel-cell:12` | Guardian lion | unknown | unknown | unknown |
| 12 | `panel-cell:13` | Small figure | unknown | unknown | unknown |
| 13 | `panel-cell:14` | Rider | unknown | unknown | unknown |
| 14 | `panel-cell:15` | Dancing figure | unknown | unknown | unknown |
| 15 | `panel-cell:16` | Standing figure | unknown | unknown | unknown |
| 16 | `panel-cell:17` | Terracotta figure | Aphrodite / 06.331 | unknown | D |
| 17 | `panel-cell:19` | Gold mask | unknown | unknown | unknown |
| 18 | `panel-cell:20` | Blue carved form | unknown | unknown | unknown |
| 19 | `panel-cell:21` | Bird | unknown | unknown | unknown |
| 20 | `panel-cell:22` | Blue turtle-like form | unknown | unknown | unknown |

The following are **record-derived summaries**, not verbatim museum narrative descriptions:

- A: “Terracotta sculpture by Gustave Doré, made around 1876–1880; gift of Uforia, Inc.” [Museum record](https://risdmuseum.org/art-design/collection/love-triumphs-over-death-cupid-and-skulls-73148). A museum narrative description was not retrieved.
- B: “Roman marble portrait head, made around 130 CE for insertion into a separate bust. Its damaged portions remain unrestored.” [Museum record](https://risdmuseum.org/art-design/collection/portrait-hadrian-59050).
- C: “Greek bronze figure of Aphrodite, dated 199–100 BCE.” [Museum checklist, physical page 37](https://risdmuseum.org/sites/default/files/museumplus/312237.pdf#page=37).
- D: “Terracotta figure of Aphrodite with gilding, dated 300–200 BCE.” [Museum checklist, physical page 3](https://risdmuseum.org/sites/default/files/museumplus/312237.pdf#page=3).

Unknown rows display “Museum description unknown. This scan thumbnail has not yet been matched to a museum record.” for scan rows, or the same sentence with “image-only entry” for panel rows. Their source reads “Museum source: unknown” followed by “The label above describes appearance only.” Neither fallback claims a museum description.

## Exact thumbnail hashes

For scan IDs, SHA-256 hashes file bytes at `assets/scans/<timestamp>-front.png`. For panel IDs, hashes are raw RGBA crop bytes, **not encoded PNGs**, from `assets/setup/panel-2x.png`. Its file SHA-256 is `d6cdb4c2c3ff042ea3380868184d297ea608f733bd377723cc71fd792f5b99d5`. Cell coordinates: `n=cell-1`, X=`[80,330,582,836,1062,1300,1522,1776][n%8]`, Y=`[410,770,1150][n//8]`, width 216, height 200. Convert to RGBA before cropping and hashing.

| Slot | SHA-256 |
| --- | --- |
| 01 | `a3b68dd79037f55d97c142bb1932b7073970cd2e0f7d657148853c6991224282` |
| 02 | `5ecb033f9efca6071bf580b2d487a2bcf50f6492ab8ec6d115cbf6a50b5b3267` |
| 03 | `30c8fce99f4d74fd6ebb56cde9793cbd629235f8062444a821d0b654f3f6de3e` |
| 04 | `084106155dd8543a0be2ea2360c15aa580a2111df17c6a3a5362dfca661fce92` |
| 05 | `867318375b95b364a49ec56b7bd75c3ccc42f654677fc5283100daacea3f55c7` |
| 06 | `c40dce2c248a756058b3de3200c5fa0c1af875b66dcea59fca747de79f0f9b13` |
| 07 | `41e77b17e454b100e0ef434718c9a3a232008b6076a55214c92a0068d3d16624` |
| 08 | `d67fbe7d3cd61163ee2ff3792fad0d0ea8e134c83966ffe54a5007ec307b30e5` |
| 09 | `92c830fc2b621b7b2da91be97a0268ba9d9e0b39adb9370edb81c17ff54f638a` |
| 10 | `7326b4681293eee746ee11f4cbe5c92e2077a091571bbd23e8a7b08271e3b248` |
| 11 | `a353893306030ae14a5f8036e3538b85326cbbd682afbffded56e5b2f540e836` |
| 12 | `3381fce18c95c3f3742a523659a8581ef3f17637af89f28ceb5e9476c007d434` |
| 13 | `24fae8e0d2b53263c7e5af8294539682c6a53af1222b73f91818b544534e7a88` |
| 14 | `edc2fd14c2f86439473e6276b7a48bb949662ea4a8997d86566c5bcde558b4fd` |
| 15 | `cf825a5f2aac24be0fbf4d94f557daf6bfe4779d7454a07a9747ddf012c435b1` |
| 16 | `32c890e0912d715f20196da918f3ca5b56cb3a1260a77b987ec6f2d6195ea9d9` |
| 17 | `cb84cf6000cd3454460969517cc9c0cf71d27d88dba5b91687ba54da8cedbdea` |
| 18 | `6ccaa10dcf268fb71a9b847b923168875d804ec356c690748377e43d5bab108e` |
| 19 | `699e51f15340ecab5bab54cf480667a1abdb44ea320e63fb3a6a1889debe12ff` |
| 20 | `3dbd7841d4afb2b302a5356a90c3ff899a06dae18af543b3d93020ef04a5aa7b` |

`playtest/record_selection.gd` clicks every card and independently asserts its visible title, department, description, source and scan status. Unknown cards immediately follow all four verified cards, detecting stale metadata. The two identically titled Aphrodite records must still change accession, description, and source page. The frozen legacy state probe continues reporting appearance labels and `department: unverified`; the displayed Labels are the museum metadata test surface.
