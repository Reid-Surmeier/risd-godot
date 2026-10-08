# Original sources ledger: footage and catalogue images for every room and object

Research for [Research: original images and footage for every room and object](https://github.com/Reid-Surmeier/risd-godot/issues/256), under [the finish-the-museum map](https://github.com/Reid-Surmeier/risd-godot/issues/249). Written 2026-10-07 (evening) against `build/v0.1.0` at `88b7c207`; the object half was measured at `3b460c1c`, to which the branch had moved. Read-and-measure only: no runtime file, bake or export was touched. Paid calls: **0; 0 USD**.

Every claim is marked **V** (verified this session: I opened the frame, measured the file, or read the hash) or **I** (inferred; the basis is given). "1 Oct audit" means `docs/research/2026-10-01-museum-inventory-audit.md` or `-architecture-audit.md`; timestamps taken from them were spot-checked on my own contact sheets, not re-read frame by frame.

## Answer first

1. **One reference clip has never been used: `IMG_6343.MOV`.** The 1 Oct inventory audit says "I did not open the other earlier clip, `IMG_6343.MOV`", and no file in the build cites it past its first half second. It is a 264 s walk through seven spaces, and it is the only footage of two whole galleries. (V)
2. **The missing room is, most likely, the gallery behind the closed white doors in the marble stair hall** (crit screenshot 09). `IMG_6343` walks through that doorway at 88–91 s into an Impressionist gallery (91–154 s), then a second one (176–223 s), and comes out in the modern painting gallery (224 s). The build has a closed door and a 1.3 × 1.6 m stub where these two rooms are. Confidence that these rooms are filmed and absent: high (V). Confidence that this is the room the owner meant: medium (I). See section 3.
3. **No original is larger than 1920 × 1080.** All twelve museum clips were recorded at 1080p; Proton's own metadata says so and the local files match Proton byte for byte. The gain available is not resolution, it is (a) taking frames at native size, since the survey frames the build was made from are 1280 × 720, (b) choosing sharp frames, and (c) decoding the ten September clips as HDR. See section 2.
4. **The Main Hall's paintings are the blurriest thing in the build, and no footage is to blame.** 22 of its 23 canvases are 320 px files, shrunk from 1024 px copies that are already in the repo; the museum's own masters for them run to 10372 × 13472. In all, 29 of 205 objects are flagged (plus 2 candidates), and only 5 objects use a video-frame crop. The museum serves far larger files than the 1324 px image the earlier check found. See section 5.
5. **Enough views for 3D:** 16 of the 26 sculptures, furniture and carved pieces checked have three or more filmed directions; the catalogue adds photographs for all but the piano (41 for the fireplace surround). See section 4.

## 1. Rooms

`geometry.json` has 16 entries: 11 rooms, 2 doorway stubs ("threshold study limit") and 3 reveal thresholds. Its "Grand Gallery" is the Main Hall. Clip names are shortened: 6380 = `IMG_6380.MOV`. Times are seconds from the start of the clip.

| # | Room in the build | Footage (clip: seconds) | Not covered by any footage |
| --- | --- | --- | --- |
| 4 | **Main Hall** (Grand Gallery) | 6344: 16–176 (both long walls, painting by painting; whole-room views at 20–24 and 168–176). Through its doors: 6382 0–10 (portal), 6380 96–100, 6343 0–2 and 60–68 (grey door). (V) | Filmed once only. Vault rise and cornice height are weak (1 Oct audit). No close view of the far end wall above the door. |
| 3 | Dark medieval room | 6382: whole clip, 113 s (frames are upside down; rotate 180°). 6344: 4–16. (V) | Backs of the plinth sculptures. Depth of the passage to the Hall (1 Oct audit). |
| 2 | Light Renaissance room | 6383: whole clip, 73 s. Through its doors: 6384 12 and 36–38; 6386 96–100. (V) | Ceiling seen at 60 s only. Board direction not checked (1 Oct audit). |
| 1 | European gallery ("adjacent gallery") | 6384: whole, 104 s (from the south end). 6385: whole, 37 s (north end). 6386: whole, 106 s (west wall, ceiling 68–84, both ends). (V) | Nothing structural. The north wall is filmed (6385) but is not in the 1 Oct measurement model, so the length is inferred. |
| 0 | Rockefeller | 6380: 120–240 (all four walls, ceiling 224–236). Through its door: 6385 0. (V) | Nothing found. |
| 6 | Purple elevator-5 connector | 6380: 102–104, 118–122 (elevator "5", purple reveal), 238–254 (purple wall left, black wall with a screen right). From the grey gallery: 6380 8; 6343 24 and 28–34. (V) | No square-on view of either side wall. |
| 7 | Grey French gallery | 6380: 0–50, 80–118. **6343: 0–82, every wall, second visit, not used by the build.** Also 6379 170–177; 6381 20–31, 84. (V) | Nothing found. |
| 8 | Marble stair hall | 6381: whole, 99 s (frames upside down; rotate 180°). 6380: 45–82. **6343: 46–56 through the columns, 80–88 from the floor.** (V) | The stair going down behind the round arch (6380 72–77 shows its top steps only). The corridor behind the exit door. The three rooms off the upper landing (6381 37–64, thresholds only). |
| 9 | Skylight Gallery (piano room) | 6379: whole, 182 s, from both levels, all four walls and the ceiling. From the grey gallery: 6380 12–14. (V) | The dark room behind the exit doors and the vestibule under the landing. No close full view of the piano (section 4). |
| 5 | Lion stair landing | 6387: 0–46, 82–85 (camera rolls; rotate per frame). 6382: 18–23 through the medieval door. 6344: 0–6. 6343: 260–263 through the modern gallery's exit doors. (V) | Floors above and below (seen from the landing only). Step counts beyond the first run (1 Oct audit). |
| 10 | Modern painting gallery | 6387: 46–82. **6343: 224–263, a second walk of the room, not used by the build.** (V) | Nothing found between the two clips. |
| 11 | White sculpture gallery (stub) | 6387: 0–5 and 36–39, through the open door only. (1 Oct audit; I did not re-open) | Everything but one viewing direction. Not buildable as a room from this footage. |
| 12 | Modern adjoining gallery (stub) | 6387: 59–69 through the doorway. **6343: 176–223, the whole room** (and 91–154 for the room beyond it). (V) | The doorway between the two galleries is crossed with the camera pointing at the floor (6343 154–176). |
| 13 | Grand Gallery reveal threshold (Hall ↔ grey) | 6343 0–2, 60–68; 6380 96–100; 6344 172–176. (V) | — |
| 14 | Rockefeller reveal threshold (European ↔ Rockefeller) | 6385 0; 6386 100–104; 6380 129–131, 186–187. (V) | — |
| 15 | Skylight Gallery reveal threshold (grey ↔ piano room) | 6380 12–14; 6379 149, 170–177. (V) | — |

Filmed and not in the build at all:

| Space | Footage | Buildable? |
| --- | --- | --- |
| **Impressionist gallery A** (mauve-grey walls, straight oak boards, sash windows with blinds on one wall) | 6343: 88–91 (the passage from the marble stair hall, two cased openings, white panelled leaves folded back), 91–154 (the room). (V) | Yes. All four walls are on film. |
| **Impressionist gallery B** (grey walls, two black benches, windows) | 6343: 176–223. (V) | Yes. |
| Metcalf Auditorium (name from the 1 Oct audit) | 6378: whole, 180 s (frames are sideways; rotate 90°). (V that it is an auditorium) | As a room, yes. How it connects to the galleries is not filmed. |

## 2. The originals

All twelve clips exist locally at the size they were recorded. (V: `ffprobe` on each file; SHA-1 of the two walkthrough clips computed tonight and compared with Proton; the ten September clips were compared on download, `collection-expansion/verified-manifest.json`.)

| Clip | Local path under `~/risd-godot-ingestion/` | Pixels | Codec | Length | Bytes | SHA-256 | On Proton Drive |
| --- | --- | --- | --- | --- | --- | --- | --- |
| IMG_6343 | `walkthrough/IMG_6343.MOV` | 1920 × 1080 | H.264, 8-bit, SDR | 263.97 s | 278,455,062 | `26cf510924e7ecb20b05a04e45420f8ebbf37c67061f2645f8f06923be429135` | `/my-files/OBJ/IMG_6343.MOV`, SHA-1 matches |
| IMG_6344 | `walkthrough/IMG_6344.MOV` | 1920 × 1080 | H.264, 8-bit, SDR | 178.94 s | 209,967,825 | `f6d489290f77e4cf50e6696893f396c434eb6d814c01cbda51396c7edfa7ae16` | `/my-files/IMG_6344.MOV`, SHA-1 matches |
| IMG_6378 | `collection-expansion/verified/IMG_6378.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 179.97 s | 386,879,912 | `a79c9a65e82293d43a46d1f54034ba398bce135b839a402dcbadbf33e3ec5e52` | Photos timeline |
| IMG_6379 | `…/verified/IMG_6379.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 182.55 s | 199,480,923 | `abc4922925e560966d5987cc3208b9a819f743b7ac7bbdc8c40741a4eab38e34` | Photos timeline |
| IMG_6380 | `…/verified/IMG_6380.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 260.54 s | 462,407,873 | `eaf7a7853b6cc5610517631b44aa83de1006ac6caa5aa673038f1f067cafd3d4` | Photos timeline |
| IMG_6381 | `…/verified/IMG_6381.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 99.12 s | 177,199,140 | `12df06479e7d2a7121d1647c8b14a5feba6a61362b0449c252fe9ae00fe5468d` | Photos timeline |
| IMG_6382 | `…/verified/IMG_6382.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 113.24 s | 242,950,032 | `415467db2d2216363fbccb41801851180f48bbdb3304c95861f90f3f5767020e` | Photos timeline |
| IMG_6383 | `…/verified/IMG_6383.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 73.70 s | 144,702,365 | `8cfd089e769000369419f577f28a1bfc68b09f8cc7cda4cbe93d840194e6eeef` | Photos timeline |
| IMG_6384 | `…/verified/IMG_6384.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 104.62 s | 198,544,074 | `0a2255c4fbcbbb44c48202e617b3978abfed4832633c6a21c73b5861570a0530` | Photos timeline |
| IMG_6385 | `…/verified/IMG_6385.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 37.42 s | 69,210,448 | `a15a2e90b2ae6152727ab1afd3c205d31f0405215e606adf678be3f5c1cf01a2` | Photos timeline |
| IMG_6386 | `…/verified/IMG_6386.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 106.71 s | 198,583,583 | `3112391373f03128f0b1a4deac345e7d30c1ed27c4d9d0d850da37d25c97351f` | Photos timeline |
| IMG_6387 | `…/verified/IMG_6387.MOV` | 1920 × 1080 | HEVC, 10-bit, HLG | 85.54 s | 163,821,728 | `75c4892c1a37e1c83dd7103187d1c284e13fd0ac458710f4e8fd6e14daf1c7af` | Photos timeline |

The ten September hashes are copied from `~/risd-godot-ingestion/collection-expansion/verified-manifest.json`; the two walkthrough hashes were computed tonight.

Remote copies, listed tonight (V). Nothing is remote only: every row is also on disk and its SHA-1 equals Proton's. Times are UTC.

| File | Where on Proton Drive | Bytes | Uploaded | SHA-1 (Proton's) | Shows | Held locally |
| --- | --- | --- | --- | --- | --- | --- |
| IMG_6378.MOV | Photos timeline | 386,879,912 | 2026-09-29 16:56 | `6214b1ed436336aa79139984be13cfeca4f96542` | museum | yes |
| IMG_6379.MOV | Photos timeline | 199,480,923 | 2026-09-29 16:56 | `d51f22af4204ffcd8d28586ca9a17db38fc59737` | museum | yes |
| IMG_6380.MOV | Photos timeline | 462,407,873 | 2026-09-29 16:55 | `678c4cfca503d3eb703bb3fc890ddf56bd34050e` | museum | yes |
| IMG_6381.MOV | Photos timeline | 177,199,140 | 2026-09-29 16:57 | `e1df18653d7ec38b8dd7608ba61cb30e089c79cb` | museum | yes |
| IMG_6382.MOV | Photos timeline | 242,950,032 | 2026-09-29 16:55 | `6335f3db5e176d1bab3da65c7ec210282f547a91` | museum | yes |
| IMG_6383.MOV | Photos timeline | 144,702,365 | 2026-09-29 16:55 | `db33edbc0c7dd089f693ffc6206e23ba82bdf29a` | museum | yes |
| IMG_6384.MOV | Photos timeline | 198,544,074 | 2026-09-29 16:54 | `2c8d24cc807997de6cc9656ecbbe1870429a8630` | museum | yes |
| IMG_6385.MOV | Photos timeline | 69,210,448 | 2026-09-29 16:55 | `f3ba23f199e4fb8d8da3af3471a3cc301815f23d` | museum | yes |
| IMG_6386.MOV | Photos timeline | 198,583,583 | 2026-09-29 16:54 | `dbb75233d01f9127e1b0bd0c561f5d7a1f2e874d` | museum | yes |
| IMG_6387.MOV | Photos timeline | 163,821,728 | 2026-09-29 16:55 | `bab811b83dd169da9ecdc6477c2876a6df3650d3` | museum | yes |
| IMG_6343.MOV | /my-files/OBJ/IMG_6343.MOV | 278,455,062 | 2026-09-25 21:09 | `fef61f8931466a23cb155aa3ec76f53fc4fa02bc` | museum | yes |
| IMG_6344.MOV | /my-files/IMG_6344.MOV | 209,967,825 | 2026-09-25 21:19 | `5683c0d4a8f6b7b3a5f6f1b95f854f2da2c2c2cc` | museum | yes |
| Screen Recording 2026-10-05 at 12.25.36 PM.mov | /my-files/RISD-VIDEOS | 449,932,917 | 2026-10-05 16:36 | `d2882312ee837885899a17687715ff12733bab15` | the game build, not the museum | yes (`~/risd-godot/.orca/drops/`) |
| Screen Recording 2026-10-05 at 12.28.44 PM.mov | /my-files/RISD-VIDEOS | 167,128,543 | 2026-10-05 16:35 | `0f19b24d471e2636a9b5875747119fd7a3097456` | the game build, not the museum | yes (`~/risd-godot/.orca/drops/`) |
| Screen Recording 2026-10-05 at 12.30.08 PM.mov | /my-files/RISD-VIDEOS | 300,472,625 | 2026-10-05 16:35 | `49ab43403d693a63a5a1621e789e88ff530a8221` | the game build, not the museum | yes (`~/risd-godot/.orca/drops/`) |

Proton's node IDs for these fifteen files are in `~/risd-godot-ingestion/proton-remote-ids.json`, not here: this repository is public, and the path, size and SHA-1 above are enough to fetch a file again.

What I checked on Proton Drive tonight (V):

- The Photos timeline holds 38 videos. The only museum clips are the ten of 29 September. Nothing has been added to Photos since 29 September.
- `/my-files/RISD-VIDEOS` (5 October) holds three screen recordings. They are recordings of **the game build**, not of the museum, and all three are already local at `~/risd-godot/.orca/drops/` with matching SHA-1. They are not a source for any room.
- `/my-files/video refrence.` holds nine of the ten September clips again (6380 is not there), at the same sizes as the Photos originals to the hundredth of a MiB. I did not compare their hashes; the files on disk came from Photos.
- Nothing was downloaded: no museum video on Proton is missing locally. Free space: 140 GB on `/` and 57 GB on `C:` at the start; `C:` was at 45 GB later the same evening for reasons outside this task, so a later session should check before fetching anything.

Three things that cost detail today, each fixable without new footage:

1. **The build was read from 1280 × 720 frames.** `collection-expansion/survey-2fps/` holds the frames the audits and room scripts cite; they are two thirds of the originals' width and height (V: `survey-2fps/IMG_6380`, 522 frames, 1280 × 720). No frame of `IMG_6343` has been extracted at all.
2. **Frames were taken every half second regardless of blur.** The clips are 30 frames a second with a moving hand-held camera; many half-second samples are smeared (V on my sheets, for example 6380 58 s). Taking the sharpest frame inside each half-second window costs nothing.
3. **The ten September clips are HDR (HLG, BT.2020).** A plain 8-bit frame grab comes out flat and yellow-green; a tone-mapped grab of the same frame is visibly warmer and more saturated (V: one frame, 6380 58 s, both ways). I have not checked either against a colour reference, so which is right is **not known**; the museum's catalogue photograph of the same object is the reference to match. The two walkthrough clips are ordinary SDR and need none of this.

Native-size grab that worked here (GPU decode, CPU tone map):

```bash
ffmpeg -hwaccel cuda -ss 58 -i IMG_6380.MOV -frames:v 1 \
  -vf "zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p" \
  -q:v 1 out.jpg
```

Orientation: `ffmpeg` applies each clip's rotation tag, but the phone was held differently from the tag in four clips. 6381 and 6382 come out upside down (add `hflip,vflip`); 6378 comes out sideways; 6387 rolls during the clip and has to be turned frame by frame. (V on the contact sheets)

## 3. The missing room

**Best match: the two Impressionist galleries in `IMG_6343.MOV`, 88–223 s, entered through the doorway that the build shows as closed white doors in the marble stair hall.**

What is verified:

- The owner's dictation runs, in order: the wood carving "I'm going to attach a screenshot for"; then "This room, which I'm going to attach a screenshot for, is also needs to be there. I have a video for it in the Proton Drive. The lighting in that room also is not lit yet."; then the clipping remark "I can sort of like see into like other rooms here". The saved screenshots in that order are 08 (fireplace), 09 (stair hall), 10 (doorway, rooms visible over the wall). So the remark sits where screenshot 09 sits.
- Screenshot 09 is the build's marble stair hall, looking at a wall of white panelled leaves. In `marble_hall_additions.gd` that mesh is `PassageDoorClosed`, with the note "closed leaves: the gallery beyond was only glimpsed".
- `IMG_6343` 82–91 s stands in that hall, turns to that doorway (leaves folded open, a vent to its right) and walks through it. At 89–91 s the room beyond is visible with a mauve end wall and a large painting of a woman in white on it; 91–154 s is that room; 176–223 s is the next room; 224 s is the doorway into the modern painting gallery (Fauconnier, Cézanne, Matisse, the gold figure, Braque, then the exit doors to the lion landing at 260 s).
- The 1 Oct audit lists "the gallery beyond the lit passage" and "the room beyond the modern gallery" as not determinable, and says it could not tell whether they are one room or two. `IMG_6343` shows they are the two ends of one run of rooms.
- `IMG_6343.MOV` is on Proton Drive at `/my-files/OBJ/`, and identical to the local copy.

What is inferred:

- That screenshot 09 is the one the owner attached for this remark. The dictation has two "I'm going to attach" phrases before a single image marker, so the pairing of remark to picture rests on order alone.
- That A and B are two rooms, not one: they hang different works, each has its own windows, and a doorway with a person standing in it is visible at 152–153 s and again at 215 s; but the crossing itself is filmed pointing at the floor.
- The works, by eye from 250-pixel frames. One was checked: the RISD collection API returns *Repose (Le Repos)*, Édouard Manet, accession 59.027, on view (V: live query tonight); that it is the painting on the end wall is by eye. The rest were not looked up. In A: *Le Repos* on the end wall (114–117), three Monet or Sisley landscapes along the right wall (92–112), a portrait of a woman in a white cap (121–126), two small still lifes (129–134), a garden scene (136), a portrait of a man in a straw hat (138–139), and a bronze in a vitrine on a plinth (142–153); in B, two spring landscapes (180–187), a landscape with a tree (189–191), a river with reflections (193–196), a small flower piece (198–202), a girl in red (204–207), a wheat field in the manner of Van Gogh (208–212) and a child in a blue hat (219–222).

Other readings, and why they rank lower:

| Reading | For | Against |
| --- | --- | --- |
| The marble stair hall itself (the room in screenshot 09) | "The lighting in that room also is not lit yet" fits the flat grey render. | It is already in the build; "needs to be there" does not fit. |
| The purple connector seen through the door in screenshot 10 | The image marker `[Image #10]` follows the remark directly. | It is in the build. Screenshot 10 matches the next remark (seeing into other rooms over the wall) exactly. |
| Metcalf Auditorium (6378) | The only filmed space with no trace in `geometry.json`; the 1 Oct audit's first guess for an earlier, similar remark. | Nothing in any of the ten screenshots relates to it, and its connection to the galleries is not filmed. |

If the owner confirms a different room, sections 1 and 2 already carry its clip and seconds.

## 4. Views enough for 3D

"Enough" means three or more clearly different directions on the object, so an image-to-3D model has something to work from on more than the front. The verdict is for the footage alone, V on one-frame-a-second sheets unless marked. The last column is the number of photographs on the object's catalogue page (from the object table); it is a count, not a count of distinct angles, and I did not open those photographs. Where a medieval piece is matched to an accession by its description only, the cell says (I).

| Object (build name) | Room | Footage views | Verdict | Best frames | Catalogue photographs |
| --- | --- | --- | --- | --- | --- |
| Art Nouveau chimneypiece (the wood fireplace surround; catalogue *Fireplace Surround*, Hugnet Frères, 83.152, on view: V, live API query) | Marble stair hall | Front and close detail; left oblique; left profile from across the hall; from the stair above, showing top and right side | **Enough** for a relief with real depth. The back is against the wall. | 6380: 48–50 (left oblique), 52–56 (front, figures), 58 and 64 (full height). 6343: 85–87 (profile). 6381: 4–6, 86–88 (from above). | 41 (83.152) |
| Grand piano | Skylight Gallery | Two close partial views; three far views from the stair and landing, one from above | **Two** usable close views, both cut off. Enough to place and proportion a grand piano; not enough to model this one from the footage alone. | 6379: 3, 13 (close), 66–68 (from the stair), 106 (side, far), 128 (from above). | none; not a catalogued work |
| Rodin marble (`rodin`) | Grey French gallery | Back-left close; front-right close; front; far from the other side; side; back | **Enough**, including the back. | 6343: 26, 52, 54, 56, 76. 6380: 17, 37, 246. | 14 (23.005, *The Hand of God*) |
| Gold service tureen and its case (`gold-*`) | Rockefeller | The case is walked round about 180° twice | **Enough** for the tureen; the small pieces are a few pixels each, so catalogue photographs carry them. | 6380: 162–173, 213–221. | 8 for the tureen (2017.74.38.1a-c); 3–5 for each small piece |
| Dragons-pattern service (`tureen`, `pink-*`) | Rockefeller | Front and one oblique of the wall case | **Two.** Which service is in which case is read from colour (I). | 6380: 123–128, 175–178. | 19 for the tureen (2017.74.39.18a-c); 4–10 for the others |
| Bookcase with the pottery figures | Rockefeller | Front; strong left oblique showing the side | **Enough** for the case as furniture. The figures on its shelves (`st-george`, `fox`, `parrot`…) are seen from the front only: **one** view each. | 6380: 146–148, 152–153 (front), 203–207 (side). | 7 for the bookcase (2017.74.9); 5–14 for each figure |
| Settee | Rockefeller | Front-left, front, left three-quarter | **Enough** for the front half. | 6380: 136–141, 197–199. | 8 (2017.74.5) |
| Black armchair | Rockefeller | Front-left, front, front-right | **Enough** for the front half. | 6380: 131–135, 193–196. | 5 if it is the entrance chair 2017.74.12 (I) |
| Walnut armchair | Rockefeller | Four passes from different sides | **Enough.** | 6380: 142–144, 149–151, 157–158, 207–209. | 6 if it is 2017.74.7.1 (I); its twin 2017.74.7.2 not checked |
| Bust on a plinth (`recamier`) | Rockefeller | Front-right, front, left | **Enough** for the front half. | 6380: 138–142, 199–200. | 6 (37.201) |
| Mirrors, sconces (`sconce-left`, `sconce-right`) | Rockefeller | Front and one oblique | **Two.** Wall-mounted, so that covers what is visible. | 6380: 143–144, 154–156, 182–191. | 1 for each mirror; 3 for each sconce |
| Stone head on a plinth | Medieval | Front-left, front, front-right, right profile | **Enough** for the front half. No back. | 6382: 29–34. | 5 if it is 59.131 (I) |
| Crucifix | Medieval | Right oblique from below, front, left oblique, and far side views | **Enough** for the front half. Wall-mounted. | 6382: 38–43, 78–79, 96–97. | 1 if it is 43.195 (I) |
| Apostles (`apostle-41045`, `apostle-41046`) | Medieval | Front and one oblique each | **Two.** Wall reliefs on a shelf. | 6382: 13–17, 24–27. | 3 each |
| Seated relief slab on a plinth | Medieval | Front, one oblique | **Two.** | 6382: 35–37. | 1 if it is 69.196 (I) |
| Half-figure on a plinth | Medieval | Front, front-right, right side close | **Enough** for the front half. | 6382: 49–52. | 19 if it is Saint Peter 20.254 (I) |
| Polychrome standing figure on a six-sided pedestal | Medieval | Front-left, front, right three-quarter, far left | **Enough** for the front half. | 6382: 59–61, 81–83. | 38 if it is the Angel of the Annunciation 37.114 (I) |
| Seated Virgin statuette and the small objects in the tall case | Medieval | The case is walked round about 270° | **Enough** for the statuette; the small metal pieces are too small on film. | 6382: 100–112. | 6 (15.108) |
| Stone portal (40.014) | Medieval ↔ Hall | Both faces and both obliques | **Enough.** | 6382: 0–11, 88–90. 6344: 16–20. | 3 (40.014) |
| Saint Roch (`saint_roch_asset`) | Renaissance | Front-left, front, front-right, through glass | **Enough** for the front half. No back. | 6383: 18, 20, 22. | 4 (21.398) |
| Secretary | European gallery | Front, front-right, right three-quarter, right side | **Enough.** | 6385: 12, 15, 18, 21. | 8 (80.106) |
| Commode | European gallery | Front-left, front | **Two.** | 6384: 92, 94. | 11 (2017.46) |
| River God in its case | European gallery | One close view, two far | **One.** | 6384: 40 (close), 34–38. | 28 (44.674) |
| Dress in a case | European gallery | Two views through glass | **Two.** | 6385: 6, 9. | 1 (2000.103.3) |
| Seated Woman, gold bronze (`67.089`) | Modern painting gallery | Four frames over about 60°, through a vitrine; one more in 6387 | **Two** distinct directions. | 6343: 241–245. 6387: about 64. | 3 (67.089) |
| Lion panel (`lion-panel`) | Lion landing | Front, obliques | **Two.** A flat glazed-brick relief; the catalogue photograph carries it. | 6387: 0–12, 40–46. | 22 (34.652) |

Count: 26 rows; **16 enough** on film (9 of those for the front half only), 9 two views, 1 one view. Of the ten that fall short on film, the River God (28 photographs), the lion panel (22), the Dragons tureen (19) and the commode (11) have the most catalogue photographs to make it up; the piano has none. Not looked at tonight for views: the Renaissance case objects, the Pietà, the Schreibtisch cabinet, the majolica and silver cases, and the white sculpture gallery's marbles.

## 5. Objects

205 objects are drawn in the walkable rooms. The full table, one row each, is [the object table](2026-10-08-original-sources-ledger-objects.md); its rows as JSON are at `~/risd-godot-ingestion/research-256-objects/objects-ledger.json`. It was built by a background agent; I re-measured every texture size in it and spot-checked its network figures before publishing (that file's opening says exactly what).

| | Count |
| --- | --- |
| Objects | 205 |
| In-room texture is a catalogue photograph (possibly resized or cut out) | 128 |
| … a Muse pass | 58 |
| … a video-frame crop | 5 |
| … nothing: flat colour or plain blocks | 14 |
| **Flagged: a video crop or under 512 px, and a larger catalogue photograph exists** | **29** |
| Candidates: the same, but the catalogue record is only probable | 2 |
| Untextured although catalogue photographs exist | 10 |
| At the 512 px cap exactly (not flagged by the rule) | 48 |
| Using the 600 px preview where the 1324 px image exists (not flagged) | 26 |

**What the catalogue serves** (V, measured from file headers; no master was downloaded). The earlier check for #180 found a 1324 px image and stopped. Each photograph marked public has four sizes:

| Rendition | Long side | How to get it |
| --- | --- | --- |
| Preview | 600 px | `data-preview-url` on the object page |
| Zoom | 1324 px wide (112 of 115 measured) | `data-zoom-url` |
| High-resolution JPEG | 3000 px (4 of 4 large masters) | the dialog behind `data-download-url` |
| High-resolution TIFF, the master | 3449 × 5993 up to 10372 × 13472 in the four read | the same dialog |

772 of the 1,069 photographs on these pages are also in the museum's Micrio viewer, whose `https://iiif.micr.io/<id>/info.json` gives the master's size and serves it in tiles; that is the only large route for the eight objects whose photographs are in copyright. Not every work has a large master: the Küssell prints stop at 512 × 384 in every rendition.

**The 29 flagged, by room** (V for the current sizes; the larger source is in each row of the object table):

| Room | Flagged | What |
| --- | --- | --- |
| Main Hall | 22 of 23 paintings | Every canvas is `gallery_walk4/canvas/<tag>.jpg` at 320 px on its long side (for example `S1` 248 × 320), a shrink of `image-work/grand-gallery-v4/canvas/<accession>.jpg` at 1024 px, which is already in the repo and is what the popup uses. The museum's masters for 21 of them run from 1884 × 3200 to 10372 × 13472. The Tiepolo is a 1024 × 1751 Muse cut-out and is not flagged. |
| European gallery | 3 | Bruegel print 84.198.1032 (443 × 362), cake basket 2016.124 (473 × 443), Schreibtisch 75.023 (493 × 393): crops of the 600 px preview; their 1324 px images measure 1324 × 993, 1324 × 1139 and 1324 × 1091. |
| Medieval | 1, and 2 candidates | *God Save the Queens* 2020.55: decals cropped from a Muse sheet at 372 × 472, with catalogue photographs in the repo at 1324 × 2040. Candidates: two paper works in the low case, film crops of 28 × 14 and 66 × 37 px, with only a probable catalogue record each. |
| Skylight Gallery | 2 | *Foreign Sign* 2026.3 and *Spectrum II* 2025.19 are film crops (1000 × 996, 1000 × 1000) because the catalogue had no photograph on 1 October. It has one of each now: 1324 × 1321 and 1324 × 1316, with Micrio sources of 9333 × 9315 and 10315 × 10254 (I re-fetched all four figures). |
| Renaissance | 1 | Book cover 34.016, 258 × 420, cut from the 1324 px image; only the 3000 px JPEG or the TIFF improves it. |

Of the five video-crop objects, two are flagged (the Skylight pair), two are the candidates, and the fifth, the emblem book 2023.17, has no catalogue photograph to go to. The diptych 22.201 also carries a film crop on its second leaf, a face the catalogue does not show.

**Not flagged, worth a builder's eye:**

1. The 48 at the cap are mostly the Rockefeller pottery and porcelain: Muse passes at 512 px made from catalogue photographs that exist at 1324 px and above.
2. The 26 on the 600 px preview are nearly all the European gallery's east wall.
3. The 10 untextured models include the Pietà 59.128, Saint Roch 21.398, the Virgin and Child 15.108 and the medieval metalwork; each has 1 to 11 catalogue photographs.
4. The fireplace surround 83.152 is drawn from one 1273 × 2269 catalogue photograph; its page has 41, and the TIFF of the one in use is 3449 × 5993.

**No catalogue photograph or no identity:** the ewe and lamb 2017.74.32 and the emblem book 2023.17 (pages have none); the piano, the iron grille, the two paper works and three small European-gallery pieces have no accepted catalogue identity.

## 6. What was not done

- I did not re-read the 1 Oct audits' timestamps frame by frame; I checked them on sheets at one frame every four seconds (every second for 6382, 6380 120–248 and 6343 82–263).
- The works in the two Impressionist galleries are named by eye; only *Le Repos* (59.027) was looked up, so the others have no accession number.
- The HDR colour question in section 2 is open.
- No frame set was extracted for a builder; the commands and seconds are here, the frames are not.
- The object table's catalogue pages were read by the background agent, not by me; I checked its sizes and a sample of its network figures, not its 115 page reads.
- Which catalogue photograph of an object is the best view, and how many distinct angles a page's photographs give, was not judged.
- The contact sheets made for this were scratch and are deleted.
