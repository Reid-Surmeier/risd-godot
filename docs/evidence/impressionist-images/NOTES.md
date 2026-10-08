# Twelve Impressionist catalogue paintings — #277

Started 8 October 2026 at 20:52 UTC on `feat/impressionist-images-277`, baseline `1757c29c`. Work alone in the assigned worktree. No paid services, generation, bake or installation. The museum's own catalogue photographs are the only permitted new artwork sources. Masters remain outside git in `~/risd-godot-ingestion/catalogue-masters/`.

## Measurements and plan, before implementation

Adopt the fitted placements in `docs/evidence/impressionist-277/WORKS-NEEDED.md`; their metre positions are **INFERRED**, not a fresh calibrated survey. `along` starts at the north end of east/west walls and west end of north/south walls. Position error: ±.5 m on end walls, ±.8 m on long walls. Canvas-centre height error: ±.15 m (Manet ±.10 m). Canvas dimensions are catalogue values; frame extents are film estimates. Reference is ordinary SDR `IMG_6343.MOV`, never a runtime texture.

| Accession | Gallery / wall | along / centre height, m | Canvas width × height, m | Estimated frame width × height, m | IMG_6343 seconds |
| --- | --- | --- | --- | --- | --- |
| 42.190 | A north | 4.95 / 1.62 | .460 × .378 | .64 × .55 ±.06 | 129, 131, 137 |
| 2007.68 | A north | 2.80 / 1.65 | .454 × .635 | .68 × .87 ±.10 | 137.8–140 |
| 57.236 | A west | 5.40 / 1.65 | .737 × .481 | .99 × .73 ±.08 | 103–105 |
| 59.027 | A south | 2.25 / 1.59 | 1.140 × 1.502 | 1.47 × 1.83 ±.10 | 115, 117, 145, 147 |
| 23.072 | A east | 5.20 / 1.64 | .464 × .629 | .70 × .87 ±.08 | 121–125, 143 |
| 72.096 | B west | 5.15 / 1.64 | .656 × .543 | .94 × .82 ±.08 | 178–182 |
| 1999.3 | B west | 7.95 / 1.64 | .546 × .648 | .74 × .85 ±.07 | 185–188 |
| 33.053 | B south | 1.15 / 1.65 | .810 × .654 | .97 × .81 ±.08 | 190–192, 214 |
| 2021.101 | B east | .93 / 1.64 | .235 × .330 | .37 × .47 ±.05 | 200–203 |
| 2010.57 | B east | 2.36 / 1.65 | .499 × .600 | .71 × .81 ±.07 | 205–207 |
| 35.770 | B east | 3.78 / 1.65 | .421 × .340 | .66 × .58 ±.07 | 210–212 |
| 60.095 | B east | 6.80 / 1.65 | .521 × .610 | .77 × .86 ±.07 | 216, 220–223 |

1. Read #278 and the image guard; fetch catalogue pages and photographs sequentially with pauses. Record source URLs, dimensions and SHA-256. Resize downward only for wall and fitted preview copies, using lossy imports at quality .8 with mipmaps. Keep external zoom JPEGs ignored by Godot and exported beside the pack. Push this image checkpoint.
2. Add these works to `impressionist_additions.gd` using the existing `painting_asset.gd` builder and its optional measured moulding widths; inspect film colours and use existing frame assets. Add blank cards, no typed game text. Push the hanging checkpoint.
3. Register exact catalogue text and representation/image records. Run both Python guards and the repository checks. Push the registration checkpoint.
4. Rebuild only with `--draft`, inspect every wall against the footage, and commit one JPEG sheet per gallery below 300 KB plus smaller progress pictures below 150 KB. Record measured imported texture growth against the supplied approximately 218 MB pack / 260 MB limit. Actual export size and baked lighting remain the orchestrator's checks.

## Census and scope

This fills the bare painting walls in the rooms already supplied for census §8 finding 4 and §15 findings 1–3. The existing connected rooms, passage, windows and furniture are outside this image job. No doorway, room bounds, route trials, casings, deep reveals, skirtings, cornices, lamps, character or frozen module files will be changed. The bronze **23.315** is excluded: its six-sided case stays empty pending a mesh.

`scripts/rebuild_rooms.sh` explicitly says `objects.json` and `representation.json` are authored and excludes them from generated-room installation. Those two records and their image detail inputs are required by this job; generated scenes/lightmaps/assets will not be edited or committed here.

The supplied integration tree has stale installed rooms. Expected `REPRESENTATION_CHECK` mismatches do not stop a source-only push under the owner's explicit instruction. Exact baseline lines will be recorded once after the first check; no check will be weakened or called green if it fails.

## Baseline after editor import

`timeout 720 godot --headless --editor --import --path .` completed. The subsequent `scripts/check.sh` has no `ERROR` or `SCRIPT ERROR`; both Python guards pass (43 works / 129 images / zero image failures). It exits 1 at the installed-scene representation gate and does not print `checks passed`. These **16 existing failure lines**, recorded once below, are the integration tree’s stale installations/registrations, not edits from this job:

```text
st-george (Rockefeller) is in the build and not declared
flute-player (Rockefeller) is in the build and not declared
hudibras (Rockefeller) is in the build and not declared
recamier (Rockefeller) is in the build and not declared
2017.46 is declared as mesh but no place_mesh() put it there
2000.103.3 is declared as mesh but no place_mesh() put it there
06.057 is declared as mesh but no place_mesh() put it there
83.152 is declared as mesh but no place_mesh() put it there
2017.74.16 is declared and not in the build
2017.74.17 is declared and not in the build
37.201 is declared and not in the build
2017.74.14 is declared and not in the build
1998.107 is declared and not in the build
41.012 is declared and not in the build
42.219 is declared and not in the build
44.541 is declared and not in the build
```

No doorways or route trials have changed. The first official `--draft` is waiting on the shared host lock. The initial notes were created before any artwork or geometry changes. Disk at preflight: 116 GB free on Linux, 22 GB on C:.

## Catalogue photograph checkpoint

**VERIFIED:** all twelve page responses were HTTP 200 through `~/.local/share/uv/tools/scrapling/bin/python` and `scrapling.fetchers.Fetcher.get`. Requests ran sequentially with two-second pauses. Catalogue pages are retained compressed beside these notes. Ten selected photographs use the museum’s Micrio IIIF service; Manet 59.027 and van Gogh 35.770 use the High-resolution JPEG link in the museum’s download dialog. Van Gogh’s first Micrio `QjAbU/info.json` returned 404, so the public catalogue download route was used; the missing endpoint was not retried. No catalogue painting was unavailable. All selected photos are marked public on their museum pages.

**VERIFIED:** every photograph was visually matched against its filmed work. No video pixels, upscales, generated pictures, new paid calls or colour changes are in the art assets. Selected downloaded JPEGs/IIIF native metadata remain outside git at `~/risd-godot-ingestion/catalogue-masters/impressionist-277/`. No file contains an embedded ICC profile. Van Gogh’s grey photographic backdrop is removed with crop `[47,40,2969,2384]`; Cassatt’s outer canvas edge is removed with `[72,96,3270,3943]` (native source coordinates, visual edge-picking uncertainty ±8 px). Other photos use the complete rectangle. The museum source bytes remain unchanged.

| Accession | Source photo | Wall | Fitted preview | External zoom |
| --- | --- | --- | --- | --- |
| 42.190 | 3535 × 2890 | 256 × 209 | 896 × 733 | 3535 × 2890 |
| 2007.68 | 2900 × 3505 | 212 × 256 | 741 × 896 | 2900 × 3505 |
| 57.236 | 4320 × 2821 | 384 × 251 | 896 × 585 | 4320 × 2821 |
| 59.027 | 2260 × 3000 | 337 × 448 | 675 × 896 | 2260 × 3000 |
| 23.072 | 2010 × 2712 | 190 × 256 | 664 × 896 | 2010 × 2712 |
| 72.096 | 3665 × 3063 | 384 × 321 | 896 × 749 | 3665 × 3063 |
| 1999.3 | 2859 × 3457 | 265 × 320 | 741 × 896 | 2859 × 3457 |
| 33.053 | 3420 × 2772 | 384 × 311 | 896 × 726 | 3420 × 2772 |
| 2021.101 | 3076 × 4320 | 137 × 192 | 638 × 896 | 3076 × 4320 |
| 2010.57 | 3155 × 3786 | 267 × 320 | 747 × 896 | 3155 × 3786 |
| 35.770 | 3000 × 2428 | 256 × 205 | 896 × 719 | 2922 × 2344 |
| 60.095 | 3350 × 4007 | 266 × 320 | 745 × 896 | 3198 × 3847 |

Every source URL, source size, source SHA-256, crop and derivative size/hash is in `image-work/collection-room-remodel/additions/impressionist/catalogue.json`; `prepare_images.py` reproduces derivatives from hash-checked local originals, with assertions against upscaling. Wall and preview imports use `compress/mode=1`, `compress/lossy_quality=0.8`, `mipmaps/generate=true`. These packed images live in `modules/shell/assets/impressionist/`, so their authored imports survive the later generated-room installation.

Full zooms live under `modules/shell/assets/impressionist/zoom/.gdignore`; this avoids editing the prohibited `gallery_walk4/` folder. The one new `scripts/export-web.sh` copy line places them in `museum-images/` beside the pack. The existing catalogue zoom adapter resolves paths by accession and fetches by basename only when opened. **VERIFIED:** 24 imported wall/preview textures total **2110686 bytes (2.013 MiB)**; 12 external JPEGs total **33013634 bytes (31.484 MiB)**. **INFERRED:** the supplied approximately 218 MB pack grows by roughly 2 MB plus small script/record/geometry overhead, well inside 260 MB. Actual exported bytes remain unmeasured here.

Outside the additions file, this checkpoint changes only the new photograph assets/imports, their preparation/metadata, Shell provenance, the export copy line, and a five-line **named Impressionist image block** in `prepare_remodel.py` that copies packed images and imports to their same module paths in the draft. It does not change room bounds, openings, floor patches or trials. The baseline draft printed `ARCHITECTURE_CHECK failures=[]` with 31 cased sides.

The two `0-gallery-*-before.jpg` pictures (68,298 / 64,361 bytes) show footage beside the four-work baseline draft. **VERIFIED in the pictures:** A has a bare Manet end wall and empty dancer case; B has only the existing end-wall Monet. The larger geometry views use the documented review-only .55 ambient; the insets use the unbaked game camera. No lighting acceptance is implied. This baseline capture also samples all 40 existing reciprocal Impressionist/modern-door trials and reports zero failures; no trial changed.

## Hanging checkpoint in progress

The image checkpoint is commit `8dba9051`, pushed to the assigned branch. The draft assembly overlays the unchanged current Hall snapshot after `prepare_remodel.py`'s historical frame-helper copy; the resulting builder already supports measured moulding widths. No builder/pipeline repair is needed.

Two conflicts in the inherited fitted offsets need wall-fit corrections rather than changed architecture. **INFERRED:** 42.190 at along 4.95 m falls in A's north opening, which spans 4.55–5.85 m along that wall. Its proposed centre is **4.00 m** with its blank card to the left; the .64 m frame ends at 4.32 m before the door's .20 m casing begins at 4.35 m. This is a .95 m displacement from the written estimate; it cannot be claimed within that estimate's ±.5 m. An optional owner clarification was sent; absent a reply, the review draft uses the physically supported wall position. No doorway moves. **INFERRED:** van Gogh's proposed centre **3.66 m** is .12 m before the inherited 3.78 m estimate (within its ±.8 m), because B's window casing starts at 4.02 m while the listed .66 m frame would end at 4.11 m. Its card is to the left. The other ten offsets and all centre heights are unchanged.

Moulding widths passed to the existing builder are `(estimated outer size − catalogue canvas size) / 2` on each axis, preserving exact canvas dimensions and avoiding frame vertex stretching. Existing E7/E9/E3/W7/W3 frame textures are reused; colour multipliers apply only to the front/outer/reveal surfaces, never to the painting. Gilt/bronze/silver/wood choices are checked against IMG_6343 at the table's times. Exact carving remains a borrowed approximation, not accepted frame ornament. All twelve cards are plain built geometry with no typed game text.

Frame-colour detail: 180 s and 211 s show pale carved Pissarro/van Gogh mouldings with a crest, not plain dark rectangles. Both reuse W7 carving. A frame-only variation of the existing kit shader reduces its gilt chroma to 8%; warm pale tint for Pissarro, neutral pale tint for van Gogh. The other ten use the existing material directly. Canvas materials/photos remain untouched. This is procedural material colour, not a new generated or video-derived texture.

**VERIFIED in the first hanging capture:** all twelve original catalogue pictures appear, with catalogue canvas proportions, built outer/reveal frame surfaces and twelve blank cards. All 40 reciprocal trials remain clear. The latest source architecture check reports 31 casings and no failures; no `ERROR`/`SCRIPT ERROR` occurred. Direct footprint review shows 42.190 supported by the north wall and van Gogh clear of the east casing after the recorded corrections. A material-only second pass lifts pale frame shadows for Pissarro/van Gogh and gives Gauguin its filmed rose-brown tone, retaining W7 carving; no art photo is changed. No room bounds or shared kit code changes.

Second material review completed without errors; the three corrected frames are visibly pale silver/cream and rose-brown rather than the initial dark/yellow readings. The two `1-gallery-*-hung.jpg` progress pictures (60,235 / 62,112 bytes) compare the matching filmed end walls against the populated draft. Close views use .55 review fill; the insets are the actual unbaked game. Full repository checks at this checkpoint remain the same sixteen baseline representation failures, with no new engine errors; both Python guards pass and `git diff --check` is clean.

## Registration checkpoint

Hanging checkpoint `edc3a852` is pushed. Exactly twelve new authored rows are added to `objects.json` (the six museum-printed fields plus exact accession/credit and the source page/date), with their preview/zoom paths and source-resolution records. Exactly twelve flat/flat declarations are added to `representation.json`, five in A and seven in B. No existing row or shortfall changes; the bronze is not declared as a painting. The image guard needs no code change: it now checks **55 works /165 images /zero failures**. `check_museum_records.py` passes with 193 works and the unchanged 53 shortfalls. An independent saved-page check finds all six descriptive field strings verbatim on each primary page.

The source-draft representation run finds **195 built /193 declared**. Every new painting agrees with its declared room and flat representation. Its only failures are unrelated existing source omissions: `59.128 (light Renaissance room) is in the build and not declared` and `21.398 (light Renaissance room) is in the build and not declared`. These two nodes are not this job's changes and their declarations are left for the orchestrator. The full repository check has 28 installed-scene failures: the sixteen baseline lines above plus these twelve newly declared paintings absent from the stale installed rooms. It still exits 1 without `checks passed`; there are no engine errors, and the two Python guards pass. No check or acceptance flag is weakened.

A native **Web Game pack-only export** completed without errors on the existing installed tree: **231,891,788 bytes (221.149 MiB)**, below the 260 MiB budget. The exporter lists all 24 new wall/preview imports and **zero** new external-zoom files in the pack. This verifies exclusion and current pack size; it is not an installed-gallery/baked Web release. The expected final gallery texture increment remains 2.013 MiB plus small geometry/record overhead, with 31.484 MiB of full zooms beside the pack.

## Final evidence and handoff

Registration checkpoint `059b7827` is pushed. The final full-field audit carries each complete museum-printed maker line, with its nationality/life dates, rather than only its name. Title/date, medium, dimensions and credit also match complete tombstone fields. The detailed continuation is §14 of `docs/evidence/impressionist-277/NOTES.md`, including all twelve pixel sizes, measured game coverage and every source edit.

The initial material-only palette pass was replaced by two numerical W7 texture colour copies before handoff, keeping its dimensions and exact alpha. The existing bake adapter only recognises `/ps1.gdshader`; the three affected frames now use that unchanged shader with the pale/rose colour copies, so work shading is preserved. No painting colour, stock frame source or shared shader/bake code changes. `frame-palettes.json` holds both source/output hashes, recipe and zero spend. The offline image helper preserves existing import UIDs when rerun.

The fresh official --draft passes with 31 casings. All 40 existing trials remain clear; all 12 native picks/inspections/on-demand zooms pass, with 48 successful UV2 surfaces and no premature full-photo load. The two final gallery sheets are 185,144 and 233,078 bytes, below 300 KB. Small review JPEGs are below 150 KB. Final imported texture growth is 2.224 MiB; full zooms are 31.484 MiB outside the pack. Pack-only export measures 221.361 MiB versus 260 MiB. No bake or install was run.

`checks.json`, `catalogue-checks.json` and `catalogue-fields-checks.json` are the exact final checks. The source representation run still has only the two unrelated Renaissance declaration omissions; the installed run still has 16 baseline plus 12 new-source omissions. Both Python guards pass; the full shell check exits 1 without `checks passed`, as explicitly allowed for this integration source tree. No gate was weakened. The bronze stays empty. No doorway or route trial is added/moved. The tailnet report is temporary for this session; the committed GitHub evidence is the persistent handoff.
