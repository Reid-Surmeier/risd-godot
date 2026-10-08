# Original catalogue photographs — #278

VERIFIED: 23 Main Hall works replaced, including the Tiepolo shaped canvas. Museum catalogue photographs only; masters stay outside git. Per-file source URLs, pixels and SHA-256 are in `modules/shell/PROVENANCE.md` and `works.json`.

VERIFIED: mounted Shell 1080×1080; framed 3D renderer 695×465; closest inspection canvas long sides 158–319 px. Wall copies 256–448 px (round 1.25× coverage up to 64 px); fitted view copies 896 px (at most 702 px shown). Full 6× zoom draws 4087–4210 px. Full zoom copies are 3200–4210 px where capped by available native canvas pixels; Copley now uses the 8192×10321 TIFF, converted from Adobe RGB to sRGB.

VERIFIED: imported Hall texture delta -1,951,310 bytes (-1.861 MiB). External JPEGs total 32,037,981 bytes; one is fetched on opening its zoom page, with the packed fitted copy retained during the request. These files stay out of the pack and are copied beside it by the export script.

INFERRED: pack 239 MiB before → 237.14 MiB after, using the owner's baseline and the measured imported-file delta. Packing the 22 initial full zoom trials would instead have added at least 16.85 MiB. Export was deliberately left to the orchestrator; its final pack size and Web run remain to be verified.

VERIFIED: `scripts/check.sh` and `git diff --check` passed. `museum images: 23 works, 69 images, 0 failures`. Negative probes reduced S1 wall and zoom to 64 px; both were rejected and restored. The new check rejects undersized images, changed hashes, non-lossy imports and accidental inclusion of external zooms. The Hall objects/views pass reports 23 objects, 20 views, 0 failures; every inspection, fitted zoom and full zoom was captured. HTTP success, failure fallback and cancellation check: `CATALOGUE_ZOOM_CHECK failures=0`.

![Hall walls before and after](hall-walls-before-after.jpg)

![Inspection and zoom before and after](hall-inspection-zoom-before-after.jpg)

VERIFIED: ordinary Hall walking shots crop the tops of some paintings, and the current Hall walls are very dark; this ticket changes neither camera nor lighting. Pre-existing invalid resource UID and exit-leak warnings remain; the final Hall run contains no script errors.

Next: the two Skylight video crops; three European preview crops; Renaissance book cover and medieval Queens decals. Then the 26 preview-only works, 48 capped textures, 10 untextured models and two unidentified paper candidates.
