# Collection expansion: sources and reusable asset procedure

Research for [Research: verify RISD sources and the reusable Muse reconstruction pipeline](https://github.com/Reid-Surmeier/risd-godot/issues/180), under [the Collection expansion map](https://github.com/Reid-Surmeier/risd-godot/issues/178). Checked 2026-09-29 against repository `55e7c3b7f048a5a7a27b71fc962c040e7aa5893e`. Paid requests: **0; $0**. No runtime files or 3D Viewer changes.

**Decision:** reuse the existing source-photo → rectified frame → Muse edit → nine-slice geometry route, and UV1 surface colour + native UV2 lightmap baking. RISD's live collection API plus object-page Picturepark images work through installed Scrapling. An IIIF service is unnecessary and was not verified. Research establishes usable sources and a prototype route; it does not establish the new videos' room identities or approve a finished map.

## Verified live museum sources

The [official API documentation](https://risdmuseum.org/art-design/projects-publications/articles/risd-museum-collection-api) describes a JSON object search, web IDs distinct from accession numbers, and zero-based pagination. The following requests actually returned HTTP 200 through `scrapling.fetchers.Fetcher` on this host:

| Request | Observed result |
| --- | --- |
| [Monet, five results](https://risdmuseum.org/api/v1/collection?search_api_fulltext=monet&has_images=1&items_per_page=5) | Five records. First is web ID `1377691`, accession `1998.107`, *A Walk in the Meadows at Argenteuil*, dimensions 53.3 × 64.8 cm, `onView:true`, `publicDomain:null`. No image field. |
| [Object page](https://risdmuseum.org/art-design/collection/walk-meadows-argenteuil-1998107) | HTML carousel contains `data-zoom-url`, `data-preview-url`, `data-download-url`, and image-specific `data-asset-copyright="public"`. Page states CC0. Thus null API rights are not proof of restricted rights, nor permission by themselves. |
| [Painting zoom image](https://risdmuseum.cdn.picturepark.com/v/P9EJtJ0v/) | JPEG, **1324 × 1108**, 2,613,195 bytes, SHA-256 `b7e66eee6aac0ed42db55788dd2d2cd2e65fa3128b6599c769f140eff71e0ce6`. Visually opened: an unframed painting photograph, useful as a canvas texture. Not a verified maximum-resolution original. |
| [Buddha search](https://risdmuseum.org/api/v1/collection?search_api_fulltext=buddha&has_images=1&items_per_page=5) | Five records spanning sculpture, painting, textile and ceramics. First is web ID `1554066`, accession `36.015`, *Buddha Mahavairocana (Dainichi Nyorai)*, dimensions 294.6 × 212.1 × 165.1 cm, `onView:true`. Search terms alone are not a sculpture filter. |
| [Buddha object page](https://risdmuseum.org/art-design/collection/buddha-mahavairocana-dainichi-nyorai-36015) | Multiple official front, side, detail and installation photographs with image-specific rights fields. Useful for proportions and material reference; no 3D model or calibrated multiview reconstruction was established. |
| [Buddha installation photo](https://risdmuseum.cdn.picturepark.com/v/GtPsXraQ/) | JPEG, **1324 × 993**, 1,039,600 bytes, SHA-256 `5a7203aa09615347c9bd9fe34a504e35314add41a8ced5685f37f655f0fd2985`. Visually opened: statue, stepped plinth, wood floor, light walls and dark rear panels. Photograph date and current installation identity remain unverified. |

These are direct museum sources, not invented endpoint templates. `onView:true` does **not** give a room, wall, position, viewing direction, or observation date. Museum `place` may be place of manufacture. Neither field proves placement in the owner's videos. Keep accession/web ID evidence separate from timestamped video placement evidence. The painting photo dimensions above describe the downloaded pixels; the catalog dimensions describe the physical work.

Additional usable official photo leads include the Buddha [side view](https://risdmuseum.cdn.picturepark.com/v/ebxiTHPl/) and [installation angle](https://risdmuseum.cdn.picturepark.com/v/80m0shYe/), extracted from its current object HTML. Their bytes were not fetched in this pass. An [April 2026 Grand Gallery event page](https://risdmuseum.org/exhibitions-events/events/night-museum) was fetched, but did not yield a useful directly linked room image in the simple image scan. The museum visit URL redirected successfully to Hours & Admission; no architectural plan was recovered. Do not substitute generic internet floorplans as measured evidence.

### Reproduce the source check

The installed `scrapling-mcp` executable exists, but no Scrapling tool was exposed in this session's callable MCP tool list. Its own Python environment successfully ran the same package's HTTP Fetcher. No browser challenge or paid scraping service was needed.

```bash
/home/reidsurmeier/.local/share/uv/tools/scrapling/bin/python - <<'PY'
from scrapling.fetchers import Fetcher
import hashlib, json
api = 'https://risdmuseum.org/api/v1/collection?search_api_fulltext=monet&has_images=1&items_per_page=5'
r = Fetcher.get(api)
assert r.status == 200
records = json.loads(r.body)
assert isinstance(records, list) and len(records) <= 5
print(records[0]['id'], records[0]['url'])
page = Fetcher.get(records[0]['url'])
assert page.status == 200 and b'data-zoom-url=' in page.body
image = Fetcher.get('https://risdmuseum.cdn.picturepark.com/v/P9EJtJ0v/')
assert image.status == 200
print(len(image.body), hashlib.sha256(image.body).hexdigest())
PY
```

Pillow was absent from the Scrapling environment; image dimensions and visual opening were checked with the existing system Python/Pillow and image viewer instead. This is a tooling limitation, not a failed museum request. No dependencies were installed. Future asset acquisition should retain raw response hashes, retrieval time, accession, image-specific rights, source URL and source bytes in the owning provenance record; temporary files from this investigation are not runtime dependencies.

## What the repository actually does

[MODULES.md](../../MODULES.md) correctly says Collection is currently composed in `demo.gd`, not a standalone module. [demo.gd](../../modules/shell/demo.gd) mounts `gallery_walk4/walk4.gd` into Collection. The [Shell module prose](../../modules/shell/MODULE.md) still describes only a framed picture and is stale on that detail. The `3d_viewer` registry entry is a different Tenant and stays outside this effort.

| Stage | Evidence and implication |
| --- | --- |
| Video frame matching | [find_views.py](../../image-work/grand-gallery-v4/views/find_views.py) SIFT-matches known painting masters against 3 fps extracted frames, requires 18 ratio-test matches and 15 homography inliers, rejects nonconvex/small/oblique projections, then rectifies a crop enlarged 32% around the canvas. It uses a hard-coded old `/tmp/claude-1000/gg-frames` path and fixed portrait scaling. Reuse the method after supplying the new inputs; it is not a general space reconstructor. The docstring mentions sharpness, but the implemented score uses area, frontality and inlier count, not a blur metric. |
| Latest saved frame procedure | [frames2 recipe](../../image-work/grand-gallery-v4/frames2/recipe-W1.json), [preflight](../../image-work/grand-gallery-v4/frames2/generation-preflight.json), and [prompt](../../image-work/grand-gallery-v4/frames2/prompts/frame.txt) use Muse **edit**, ordered hashed reference photos, a white canvas opening and magenta exterior. The request preserves the observed ornament/profile and asks for crisp planar game shading. This supersedes earlier description-only frames. A prompt's demand for exactness is not measured preservation. |
| Geometry | [painting_asset.gd](../../modules/shell/prototype/gallery_walk4/painting_asset.gd) maps the edited frame onto eight front patches around a separate museum canvas, extrudes outer sides and inner reveals, and derives band widths from opening pixels and canvas metres. Current constants are 0.09 m depth and 0.035 m inset: authored defaults, not recovered frame measurements. Shaped works use their own outline slab. |
| Architecture | [walk4.gd](../../modules/shell/prototype/gallery_walk4/walk4.gd) authors walls, vault, doors, benches and floor geometry. The [original record](../../image-work/grand-gallery-v4/README.md) explicitly labels room size and early spacing as estimates. SIFT homographies recover planar image correspondences; they do not recover metric 3D rooms or connectivity. That record's `docs/research/grand-gallery-hang.md` pointer is missing in this checkout, so its survey cannot be treated as available proof. |
| Surface colour and lighting | [prepare.gd](../../modules/shell/prototype/gallery_walk4/bake/prepare.gd) copies colour textures/UV1, unwraps UV2, preserves continuous floor lighting UVs, strips previous analytical lighting, keeps paintings/frames unshaded, and makes static room meshes for LightmapGI. [run.py](../../modules/shell/prototype/gallery_walk4/bake/run.py) and the [bake notes](../../modules/shell/prototype/gallery_walk4/bake/README.md) define native editor baking and recovery. Changing geometry or source texture alone does not update saved `baked/room.tscn`: regenerate and rebake. Current floor UV2 extents are room-specific; expanding the map requires revisiting those bounds. |

The look is not simply an “8-bit texture” conversion. Saved frame references, authored depth, restrained materials, offline light, internal viewport and display treatment all contribute. Older README PS1/analytical-light statements must not override current baked-scene behaviour. This pass traced source but did not rerun Godot or certify the current exported rendering.

## Muse versus DIS, and the sculpture experiment

The maintained Muse procedure source was read locally at `/home/reidsurmeier/Image-generation-pipline/procedures/muse/README.md`; this local source is the inspected authority. Ordinary source preservation uses `edit`. `dis-composite` is specifically DIS-photo advertising composition with contents guard and separate refinement. Invented-product generation is another procedure. They share Muse/OpenRouter infrastructure but are not interchangeable creative plans. The user's requested existing frame quality therefore maps to the saved **Muse edit** procedure, without importing advertising instructions.

For a sculpture, recommend one bounded prototype after the video survey identifies an actual placed work: museum front/side photographs and catalog dimensions → authored simple mesh with explicit unknown rear surfaces → one Muse material/reference edit preserving observed silhouette and wear → authored UV mapping → the existing room bake. Reuse an existing scanned mesh only after matching its accession, dimensions and provenance; a filename or resemblance alone is insufficient. A generated still provides neither hidden geometry nor reliable turnaround views. Do not flatten a walk-around statue into the frame's nine-slice method.

Prepare the single edit with the installed pipeline's `identity → prepare → image` preview gates before any `--execute`, using the application's lock, original reference order/hashes and spend record. Keep full-resolution museum painting masters separate from generated frame/surface assets. For sculpture views, compare front, profile and a camera orbit against the supplied evidence; reject silhouette changes, invented limbs/ornament, baked-in contradictory lighting or missing backside coverage. Start with one sculpture, not a batch. This report incurred no generation and does not authorize an unbounded pass.

## GPU requirement

The owner explicitly requires GPU-first processing. `nvidia-smi` in this research session verifies **NVIDIA GeForce RTX 4070 SUPER, 12282 MiB**. The coordinating session verified FFmpeg CUDA support and is producing GPU-decoded contact sheets. `command -v colmap` found no executable on PATH here; no CUDA-enabled COLMAP or pycolmap reconstruction was verified. The historical OpenCV SIFT script is a method reference, not an approved CPU-heavy default. Before any reconstruction experiment, verify the chosen tool actually selects the RTX GPU and capture utilization/device logs; keep heavy decode, reconstruction where supported, and rendering/baking on that device. CPU-only fallback requires an explicit exception, not a silent substitution. The historical bake README records software Vulkan timings and therefore does not prove current NVIDIA use.

## Decision gate for the next prototype

1. Survey the five downloaded videos with source hashes, real timestamps, contact sheets and selected full-resolution frames. Identify repeated doorways/work identities, then draw a connected room graph. Record each connection as observed or hypothesized. Catalog dimensions can anchor scale; missing views remain uncertainty, not invented accuracy.
2. Block out one linked pair of rooms in Collection using the existing movement/collision/camera. Demonstrate both directions through its doorway, ceiling/cutaway correctness, one retained painting and one candidate sculpture. No change to 3D Viewer.
3. Compare actual exported screenshots and movement at matching views: frame silhouette/band widths, artwork preservation, material scale, sculpture proportions, lightmap seams and doorway continuity. Retain annotated video timestamps alongside each comparison. A still cannot certify connected navigation or texture stability in motion.
4. Run existing gallery rendered checks and repository checks when implementation exists; record browser load/frame timing against the current build on the same device. The current bake README's prior 10% frame-time budget is historical, not proof for an expanded map. Confirm the budget in the prototype ticket before scoring it.
5. Resolve the human prototype ticket only after actual owner feedback. This research resolves source feasibility and the minimal route, not visual acceptance. Room identities, final topology, unobserved geometry and sculpture acceptance remain with the survey/prototype decisions.

**Passed:** live API/object/image fetching with Scrapling; sample image decode and visual inspection; local frame/geometry/bake trace; no paid calls or runtime changes. **Failed/tooling:** Pillow import in Scrapling venv (worked with existing system Pillow); missing historical hang report. **Unverified:** IIIF, maximum downloadable image sizes, current room placement, complete architectural dimensions, new-video content, actual new sculpture mesh/UV quality and expanded-map performance.
