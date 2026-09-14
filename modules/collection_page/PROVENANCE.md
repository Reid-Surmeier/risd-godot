# collection_page — where every pixel comes from

Nothing in `assets/` is hand-drawn. Every PNG is a crop of a picture that already existed; crop boxes are `(left, top, right, bottom)` in the source's own pixels. The page shows the header, the Info box and the cut-outs at 2x with the project's nearest filter; thumbnails are scaled to fit a 280x200 card.

**Rights: the object photographs, the video frames and the Buddha render are RISD Museum material whose rights record is pending on ticket #35.** They ship here as draft-mockup evidence, exactly as the other prototypes' pixels do; nothing in this module asserts a licence for them.

## The owner's Collection page reference

Source: `docs/evidence/collection-page/reference.png` (859x803, sha256 `d596106f9c0938166b225cceecad55dead4dd68ddfad43544f134fd8c392997f`), attached by the owner on ticket #26: the RISD Museum "Collections page" window.

| File | Crop | What it is |
| --- | --- | --- |
| `header.png` | (126, 92, 730, 142) | the logo row: "RISD Museum / Digital Playground", the small icon at right, "Collections page:" |
| `info_box.png` | (126, 686, 742, 754) | the Info box: "Saved objects — this is where you see the objects you have saved…" |
| `obj_bust.png` | (174, 213, 408, 443) | cut-out: bust of a bearded man, painted wood (record `ref-bust`) |
| `obj_bronze.png` | (411, 274, 676, 576) | cut-out: feline finial, bronze (record `ref-bronze`) |
| `obj_seals.png` | (250, 500, 390, 582) | cut-out: two resting seals, ceramic (record `ref-seals`) |

## The Buddha scan

`obj_buddha.png`: crop (116, 118, 528, 522) of `painting-tool-prototype/artifacts/qa/statue-viewer-v003/initial-viewer.png` in the `figma-ui-ux-qwen-pipeline` repository (commit `f8f8e75`; sha256 `17a7b512a4229a7f4f4c10fffa9c4426382a6c2db6ff0d6822a00c3d51fdaf92`) — the Sculpture Viewer prototype's own render of `assets/models/proton-buddha-3124123123.glb`, the one model the 3D Viewer will hold (ticket #27, record `buddha-scan`, `has_3d`).

## The five RISD Museum videos

One frame each at 10 s, scaled to 320 px wide (`ffmpeg -ss 10 -frames:v 1 -vf scale=320:-2`), from the prepared preview files on this repository's branch `Reid-Surmeier/issue-20-video-player-usability` (commit `f2097ff`, `prototypes/video-player-usability/media/<id>.ogv`). Titles are the `exact_title` values of `docs/evidence/video-player-usability/media-provenance.json` on that branch (owner-authorized downloads from Vimeo, issue #18). The `year` on each record is a guess from the Vimeo id, not a museum record.

| File | Source `.ogv` sha256 | Title |
| --- | --- | --- |
| `video_1191767929.png` | `b672830e2a9e03465c562dcb8c192746c01daf32cfaeebcfba02c8d1ca4acc5f` | The Observer |
| `video_1187745268.png` | `d9b1b6271eca62f3dc0afda60975da26623316a7bde1359f6af59afa63911a73` | Inside the Exhibition, Natchiq _ Onkeehq _ Isuwiq – Indigenous Artists Honor the Seal |
| `video_1014865523.png` | `a824e34fe775b9e638ae52680a3b99dec8a8f6cf8279e50751ee8a229055b68c` | A Look Into Our Collection’s Polaroid Photographs by Andy Warhol |
| `video_1009870521.png` | `e5d392f7ca1be302c6fca0f56f3dc033de8b6d952e9500ee388d810abb7ccf89` | The Making of Wallpaper |
| `video_1008943970.png` | `ef30b360c6de670fabc8e789fdd30595116128afb52798c28306d7a3c18756e3` | Short Cuts Sháńdíín Sháńdíín on Diné textiles |

## The seven prototype-81 artworks

Source: `godot/prototype-image-viewer/reference.png` in `qwen-image-pipeline`, branch `prototype/81-image-viewer` (commit `5d55209`; 4591x2816, sha256 `c39ac61850b59fe297ffc2a09fcd30adbdb37c78181275248344a5e5016ad501`), the owner's seven-artwork screenshot. Crops are the `WORKS` rectangles of that prototype's `viewer.gd`, scaled to 320 px wide (LANCZOS); `art_01` is trimmed to the print itself (the source rectangle also holds three icon groups below it). Their records are `descriptive` in `data/collection.json`: title, maker, department, medium and year were written from looking at the picture and are not museum records; a maker marked "(by eye)" is an attribution, not a fact.

| File | Crop (x, y, w, h) | Record |
| --- | --- | --- |
| `art_01.png` | (125, 200, 1215, 810) | `art-01` |
| `art_02.png` | (1374, 200, 763, 1118) | `art-02` |
| `art_03.png` | (2174, 198, 833, 1126) | `art-03` |
| `art_04.png` | (3030, 250, 1350, 1022) | `art-04` |
| `art_05.png` | (125, 1493, 1215, 805) | `art-05` |
| `art_06.png` | (2174, 1384, 1165, 932) | `art-06` |
| `art_07.png` | (3475, 1276, 905, 1075) | `art-07` |

## Icons and font

- The `has_video` / `has_3d` badges are `assets/icons/set/MED-01-has-video.png` and `MED-06-point-cloud.png`, the repository's own stills, loaded at run time (ticket #27: ship the stills that exist).
- `LiberationSans-Regular.ttf` is the system's `fonts-liberation` package file (sha256 `4659bc0c58c5028dd488ec928d41d9265db43d9b669fc14ca8b0832daca7b144`), SIL Open Font License 1.1. Fonts are allowed inside a Page (ticket #24); the strip stays font-free.
