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
