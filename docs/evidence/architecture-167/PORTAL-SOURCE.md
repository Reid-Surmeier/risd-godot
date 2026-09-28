# Stone portal source and bounded prototype

Question: can the existing round tunnel acquire the photographed nested stone
orders and columned supports while preserving its opening, gallery paintings,
and navigation seam? This is a separate batch after cornice checkpoint
`c424cb35`; no portal candidate is selected yet.

## Original source, not generated examples

| File | SHA-256 |
| --- | --- |
| `image-work/grand-gallery-v2/source/arch-outside.png` | `fdaaf16656bfd239bde16c849d78d0238d672f50bbee0034ad24de9336dfbc10` |
| `image-work/grand-gallery-v4/frames2/references/portal-t19.png` | `7532d1e6ecf472436b2c2ce0818878e4c10d28a786d1cb5ed4ff43189386e78f` |
| `image-work/grand-gallery-v2/source/wide-north-bench.png` | `c428fecb268a6181eeeef519f69a1b8d9f4bc3e634b74938897df8aaeb283783` |

The v2 source record identifies the owner video `IMG_6344.MOV`, with the
portal view near 19 seconds. The first two images show the museum-side stone
face; the third shows the gallery-side white casing and the benches. The
1080-wide source supports nested concentric orders, radial stone joints,
paired cylindrical supports, broad capital/impost masses, masonry backing,
and low stepped bases. The tiny earlier doorway crop did not resolve these.

Missing evidence: an orthographic survey, opening/stone depth measurements,
sharp close-ups of individual capital figures and outer-band ornament, and
the unseen rear/side construction. The prototype does not invent those
motifs or certify any dimensions. It retains the existing opening and tunnel
depth; added masses are a bounded visual interpretation of the source ratios.
Its segment counts and section offsets are authoring parameters, not a claim
about surveyed stonework.

## Treatment under test

Three stepped ring orders with narrow modeled radial gaps, two rounded
supports per side, plain capital masses, an impost band, and backing courses.
No fabricated animals, foliage, or carved iconography. The existing Muse
limestone image is sampled inside a block so its rectangular mortar grid
does not run across the arch and columns. Its pixels are unchanged:
`textures/stone.png`, SHA-256
`54f9436e284d82827459666b4d73c24e6bd0b54f62b3a44c810c57f9ddb6d882`.
The source and earlier paid generation record remain in
`image-work/grand-gallery-v4/README.md`; this batch makes no paid calls.

The gallery-side casing reuses the existing ivory material; its blank green
EXIT rectangle becomes the already-authored vector EXIT lettering. The
arch floor starts at the opening instead of leaving an uncovered strip.
Other-room scenery and the plain navigation destination are inherited,
not redesigned or certified by this batch.

`portal-base-native/` and `portal-base-browser/` preserve matched square
views 8–10 at 720/1600 from cornice checkpoint `c424cb35`, using the final
camera positions and field of view. The baseline was freshly imported and
exported in an isolated archive of that checkpoint. Final captures,
traversal checks and a separate external image-only gate are required.

## Passage-floor regression and repair

The existing native `doorway_check.gd` caught the extended backing floor
covering the retained white passage: all four arch cases returned 0/9 clear
samples, while all far-door cases remained 9/9. The new floor had started at
z=0 with y=+0.002, above the live passage at y=0. Lowering only that backing
plane to y=-0.002 immediately restored both original-lighting arch cases to
9/9; the still-stale saved bake remained 0/9, isolating the geometry cause.
The final rebake must restore both baked cases too. Exported gameplay now
checks the same nine projected samples before its real keyboard roundtrip;
the private prototype launcher reports the count into browser evidence.
