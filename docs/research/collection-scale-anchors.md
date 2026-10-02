# Collection reconstruction: two verified metric anchors

Research for [Prototype: reconstruct connected rooms from dense video evidence](https://github.com/Reid-Surmeier/risd-godot/issues/182), checked 2026-09-29. No paid calls, runtime changes, or 3D Viewer changes. Research used the installed Scrapling Fetcher and primary RISD catalogue records. Existing CUDA-extracted survey images were inspected; no CPU video extraction or reconstruction was run.

**Two works in the reconstructed cabinet section have visually matched official photographs and physical catalogue dimensions.** Use the painting's planar canvas as the primary scale candidate and the cabinet as an independent check. This identifies candidates; it does not establish the reconstruction's actual scale or measurement error.

## Verified identities

| Work | Official identification | Catalogue dimensions | Video evidence and visual match |
| --- | --- | --- | --- |
| Cabinet | Guillaume Beneman, [Drop-Front Secretary (Secrétaire à Abattant)](https://risdmuseum.org/art-design/collection/drop-front-secretary-secretaire-abattant-80106), accession **80.106**, web ID **1510491** | **143.5 × 114.3 × 42.6 cm**; interpreted as overall height × width × depth, consistent with official photographs | `survey-2fps/IMG_6385/000025.jpg`, nominal output time **12.0 s**. Paired winged sea creatures with coiling tails, paired lower lions under the arched brass trim, sphinx column mounts, upper drawer ornament and wood cracks match the [official front photograph](https://risdmuseum.cdn.picturepark.com/v/I9OPTRGV/). |
| Painting | Eugène Delacroix, [Arabs Traveling](https://risdmuseum.org/art-design/collection/arabs-traveling-35786), 1855, accession **35.786**, web ID **1539276** | **54.1 × 65.1 cm**, oil on canvas; height × width | `survey-2fps/IMG_6385/000054.jpg`, nominal output time **26.5 s**. The white-robed rider on the brown horse at left, white horse and rider at center, blue-clad walking figure at lower right, mountain ridge, and sky match the [official canvas photograph](https://risdmuseum.cdn.picturepark.com/v/vYBlWEMP/). |

Times use the survey's one-based file numbering at 2 fps: `(frame_number - 1) / 2`. They are output sampling times, not independently recovered exact source-frame PTS. Survey extraction used `-noautorotate`, so the viewed images are sideways; coordinates for calibration must remain in the actual reconstruction image orientation.

Direct metadata endpoints: [cabinet](https://risdmuseum.org/api/v1/collection?id=1510491), [painting](https://risdmuseum.org/api/v1/collection?id=1539276). These were read live through Scrapling. The official [API documentation](https://risdmuseum.org/art-design/projects-publications/articles/risd-museum-collection-api) limits `items_per_page` to 5/10/15/20/25: an initial request using 100 returned an empty array and must not be interpreted as absence of works. Successful searches and the relevant responses are retained locally.

## Calibration candidacy

1. Prefer the **canvas plane**, with target width **0.651 m** and height **0.541 m**. Match distinctive painted landmarks or the canvas corners in several already registered frames; use triangulated points on that plane. The museum photograph excludes the decorative frame. Do not assign its dimensions to the frame's outer edge. The catalogue does not explicitly call these sight dimensions, so possible overlap hidden by the frame rebate remains uncertainty.
2. Measure horizontal and vertical extents independently and across views. Consistent scale from both directions and a small reprojection residual support use; do not make a whole-room accuracy claim from one selected edge. Retain source-frame coordinates, correspondence counts, and rejected views with the computed scale.
3. The cabinet gives an independent **1.435 m height / 1.143 m width / 0.426 m depth** check, but is less convenient: its marble top overhangs, feet extend below the body, and front decoration lies in several depth planes. Catalogue overall height must include the feet and top, not just the brass rectangular border. Catalogue depth must not be assigned to the front door panel. Inspect multiple viewpoints before claiming its overall silhouette is recovered.
4. A metric object sets scale, not room topology or world-up by itself. Neither `onView:true` nor maker/place fields establish a gallery. These matches establish placement only in the cited video frames. No other clip or doorway is certified by this report.

## Saved evidence

Evidence directory: `/home/reidsurmeier/risd-godot-ingestion/collection-expansion/anchors/`. `verified-anchors.json` records URLs, retrieval time, dimensions, image sizes, hashes, and image-specific rights. Raw API responses and object HTML are retained. These are research inputs, not runtime dependencies.

| Download | Pixels | SHA-256 |
| --- | --- | --- |
| `secretary-0.jpg` | 1324 × 1612 | `7aa1573462a75fdfb905fc466271b7f5440a8a244a5315868c2eb37b11760604` |
| `painting-0.jpg` | 1324 × 1094 | `15e93a4af2b87e64280f3008f67846d609a2c74df1a37b84b4b89a0af4b6ab7f` |

Seven additional official cabinet images are retained as `secretary-1.jpg` through `secretary-7.jpg`; their hashes and source URLs are in the manifest. They were downloaded but not all visually inspected in this research pass. No claim of maximum available resolution is made.

API `publicDomain` is false for the cabinet and null for the painting; each corresponding object's fetched HTML gives `data-asset-copyright="public"` for its carousel images. Preserve both facts rather than silently replacing the API field. This pass establishes reference and calibration evidence; runtime asset acceptance belongs to the owning module's provenance and quality gate.
