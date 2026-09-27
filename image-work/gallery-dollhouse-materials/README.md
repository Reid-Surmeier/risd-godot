# Muse material pass — #132

Owner continued after asking whether Muse was being used. This pass produces two
material candidates, one request at a time, via OpenRouter `meta/muse-image`.
Existing approved oak/wall textures and the owner’s screenshot are preserved as
ordered references. No source artwork is changed.

Pre-submission authorization: under the owner’s standing under-$5 rule; maximum
$2 for this pass. Conservative declared reservation $1 per output, two outputs;
actual provider cost will be recorded from each receipt, or explicitly unknown.
No blind retries. Generated pixels remain intact; UV mapping, mipmaps and native
LightmapGI supply placement, filtering and shading.

Acceptance: broad low-contrast surface marks; oak runs along each existing plank;
wall remains quiet at the fixed camera; no baked highlights in albedo, no crawling
fine grain, same 23 artworks and no runtime lights. Compare identical camera poses
with `390b7bd`, inspect walking and turns in Compatibility and Chrome.

## Oak result

`run-9839c903a7d0d67f9cf410c1`: one output, actual recorded cost $0.010000.
Native WebP copied byte-for-byte to `textures/oak-muse.webp`. Agent inspection:
broad horizontal grain, restrained rings, no fine photographic grain or baked
highlight. Mapped in full-length strips inside the existing planks; owner visual
acceptance remains open.

## Wall result

`run-92ba97b16084444f177dc75f`: one output, actual recorded cost $0.010000.
Native WebP copied byte-for-byte to `textures/wall-muse.webp`. Agent inspection:
quiet slate colour, broad low-contrast pigment patches, no directional highlight
or fine grain. Mapped at a four-metre repeat. Final scene inspection follows.

Total: OpenRouter / `meta/muse-image`, 2 outputs, **$0.020000 recorded cost**.
The tool leaves subjective approval unverified; outputs are comparison candidates.

## Preservation and mapping

Both runtime WebPs match their native result hashes exactly; no generated pixels
were repainted or filtered offline. Godot imports supply actual mip chains and
desktop/mobile compressed formats. Source images, native results, sanitized
provider receipts, request hashes, event histories and reservation state are
versioned. The tool’s derived 76 MB normalized RGBA caches remain local under its
existing ignored `runs/` folders. No duplicate paid submission was made.

The floor maps one grain length and one-third texture height per physical plank,
with varied vertical strips. Walls repeat one map every four metres. Native
LightmapGI was rebaked after the colour change: 119 users, 17.16 seconds.

## Verification — runtime build `00c9aa3`

- `scripts/check-gallery.sh /tmp/gallery-muse-verified`: exit 0; all 23 paintings
  opened; hidden-wall and focus-loss cases passed; both bench routes finished;
  FUZZ 0/300 failures; HALF-VISIBLE opened E6. Bake recovery passed.
- `scripts/check.sh` and `git diff --check`: passed. No new test or production
  test hook was needed for this material-only change. Existing behavior checks
  retain the prior test-audit ownership.
- Chrome/ANGLE D3D12 RTX4070SUPER, 1600×900: median 16.7 ms in standing, walking
  and turning; p95 at most 16.8 ms. Within the 10% budget against build 7c23281.
  Actual camera-menu and lighting-toggle clicks passed. Transfer 148,211,930 →
  149,339,218 bytes (+0.76%). Native Compatibility texture allocation 188,356,387
  bytes versus 185,501,013 before; this remains a desktop proxy, not browser
  texture-memory measurement.
- Same-pose rendered comparisons inspected: floor grain is broader; wall pigment
  stays subtle behind the paintings. Mipmaps are enabled. The walking/turning clip
  is retained for the owner’s review. No new screen-space effect, normal map,
  runtime lamp or shadow was introduced.
- Existing browser favicon/MSAA/cursor metadata messages remain. The rendered
  harness also logs exit-time ObjectDB/resource cleanup diagnostics after its
  passing checks. These were not silently removed from the saved output.

Subjective Animal Crossing resemblance remains Reid’s decision; the character
still uses its existing back-view sheet. This is a committed private prototype,
not a release or an approval of new directional character artwork.
