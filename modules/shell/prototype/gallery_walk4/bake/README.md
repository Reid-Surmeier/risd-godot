# Dollhouse comparison — #132

The default uses a fixed 45° pitch, 20° vertical field of view and quarter-turn
views. Gallery compares 35°/30°; Original keeps the prior follow camera. WASD
moves relative to the fixed view; Q/E exposes the other walls. The lighting
switch compares the same pose with the old analytical shading.

## Texture and light workflow

1. Map surface colour with UV1. The continuation now uses Muse `oak-muse.webp`
   and `wall-muse.webp`; original wall/oak maps and artwork masters stay intact.
   Recipes, references and $0.02 spend are in `image-work/gallery-dollhouse-materials`.
   No normal maps are used.
2. `python3 modules/shell/prototype/gallery_walk4/bake/run.py` persists the merged
   room, separated into floor, four walls and ceiling. It unwraps UV2 for static
   lighting; the floor has one continuous world-space UV2 layout so individual
   planks do not produce lighting seams.
3. Godot's editor bakes five broad static lamps plus environment light, two
   bounces, into `baked/room.exr` and `room.lmbake`. The final scene contains
   119 meshes and LightmapGI, **zero runtime lights**. Cutaway walls and ceiling
   remain occluders during the offline bake. Re-bake after geometry changes.
4. Compatibility/Web displays the saved scene using native materials and the
   lightmap. The old vertex illumination and lamp/shadow cards are excluded;
   plank colour variation and the character's contact shadow remain. Artwork
   and painted frames remain unshaded to preserve their source colour.

Requires Godot 4.7.2 and an X display. The offline editor uses Mobile/Vulkan;
the shipped viewer uses Compatibility. There is no public GDScript bake method
in this version, so the temporary editor plugin invokes the native Bake Lightmaps
control. `run.py` checks plugin configuration before preparation and restores
project settings and the previous bake assets on failure. Rerun the rendered
checks before exporting a successful bake.

**Renderer correction to the research:** keep `disable_ambient_light = false` on
the baked materials. Compatibility also gates lightmap evaluation with that flag.
The environment's live ambient energy is zero. Setting the flag true made the
room black despite a valid bake; the pixel regression detects this.

Texture imports are committed for the oak mip chain and the lightmap's required
2D-array format. No screen-space noise, snapping or texture warping was added.
Native bake took 18.22 seconds on this host's software Vulkan renderer.
Initial camera/bake pass: 0 paid requests. Material continuation: 2 Muse requests
through OpenRouter, $0.02 total, with unchanged native image bytes.

## Character decision

The existing sheet only supplies a back view. Keep it as a visible placeholder
for this camera decision; billboard rotation cannot supply front/side artwork.
A directional character pass belongs after the owner chooses the view.
Visual inspection of the existing held frames identifies alternating contacts
at frames 0 and 8 of the first 16-frame stride. Later frames turn and settle, so
they are excluded from the repeating stride. Actual movement speed sets the cadence (about3.6 contacts/s at full keyboard speed);
crossing a contact frame plays a step, and blocked movement does not advance it.
No generated pixels or Nintendo source audio were modified.

## Test audit

Applied the [OpenClaw test-audit authoring gate](https://github.com/openclaw/openclaw/blob/main/.agents/skills/test-audit/SKILL.md)
to this prototype's tests. Its Vitest/crabbox commands do not apply to Godot;
the repository checks and Compatibility harness are the executable proof here.

| Test owner | Observable contract / credible regression | Why needed / production seam |
| --- | --- | --- |
| `dollhouse_shot.gd` | Lit wall/floor pixels after runtime lamps are removed; catches the Compatibility ambient flag black-room bug. | Headless import cannot see lighting. Real rendered pixels, no production test flag. |
| `dollhouse_shot.gd` | Right moves screen-right without rotating the camera; E changes the viewing side; lost focus stops movement. | Old tank-control tests do not cover the new input model. Real input events and existing controls. |
| `dollhouse_shot.gd` | Every real room artwork opens from its visible side. | Cutaway-wall picking is new; reads the actual room inventory rather than copying a fixture list. Real click/approach/detail path. |
| `shot.gd` | Both bench routes arrive, backing out cancels approach, random routes finish, partly visible E6 opens. | Retains earlier regressions; converts diagnostic-only output into nonzero failure status. No new production seam. |
| `bake/test_run.py` | An editor failure or preflight refusal preserves the previous bake and project settings. | Rendered success cases cannot cover offline process failure. Runs the real command in a temporary project with a failing child executable; no production hook. |

The black-room negative control temporarily restored the faulty material flag:
the lighting check exited 1 with `baked surface is black with runtime lights
removed`. Restoring the material made it exit 0. No test was deleted to conceal
a failure, and no frozen module acceptance files were changed.

Run `scripts/check-gallery.sh` for the two rendered harnesses, then
`scripts/check.sh` and `git diff --check`. Screenshots default to
`/tmp/gallery-check/`. The test harness may set a starting pose, select a camera through the public OptionButton API, and read scene
state, as the existing prototype harness does; asserted outcomes are motion,
rendered illumination and the opened artwork, not private call order.

Browser budget declared before candidate measurement: median and p95 frame
intervals at most 10% above the fresh 84604cb baseline on the same Chrome/GPU,
1600×900 viewport. Report load bytes separately; this prototype keeps both
lighting sets resident to permit comparison. Desktop texture allocation is a
proxy only, not a browser GPU-memory measurement.

Camera setup locates the option by its visible label, independent of toolbar order.
The harness does not claim to test dropdown wiring: the Chrome check uses actual
mouse/keyboard selection and verifies the resulting URL variant. The recovery
regression fails on the pre-fix command and passes after restoration was added;
the cutaway regression also fails when the hidden-wall filter is removed.

Web export must include both desktop and mobile VRAM texture formats, and import
ETC2/ASTC as well as S3TC/BPTC. The old export disabled both, which omitted the
newly compressed textures and crashed on load. See the [Godot Web export guide](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html).
The Chrome check waits for completed tab warm-up and rejects missing resources
before measuring frame times; a loading screen is not a performance result.

## Reference refinement continuation

The normal view hides authoring comparisons; F6 reveals them. OtherWall crosses
to the opposite collection at the same gallery bay. The selected screenshot's
measured target is about33% visible character height and80% feet position; the
current uniform scale/aim trial measures about32%/79%. See
`docs/research/animal-crossing-reference-composition.md`.

The native bake now uses less omni fill, narrower warm spots and a directional
skylight. Glazing remains visible but is excluded from static GI geometry;
runtime shadow flags alone do not exclude it from the bake. Lighting remains
fully offline. The continuation uses medium bake quality, a lit oak shader with
a wider minification footprint and reduced grain contrast, bevelled bench
upholstery with unchanged outer bounds, and a sloped cornice underside. The
shader retains the existing Muse image bytes; it is a material treatment, not
a new generated texture or an exact Nintendo lighting reconstruction.

The rendered checks now cover real OtherWall clicks both ways, absence of the
toolbar after closing artwork, walking/blocked footstep counts, and agreement
between bench triangle winding and shaded normals. An old-cadence negative
control fails the two-second walk with four contacts; the candidate gives seven.
Audio timbre and exact audiovisual phase remain unverified.

## Final lamp refinement

The final comparison lowers painting spot energy from 8 to 6 and aims at the
painting centre instead of 0.3 m above it. Fixed-pose Compatibility renders
show less conspicuous olive light caps above the west-wall frames while the
warm floor pools, artwork colours and ivory trim face separation remain.
An independent visual review retained this restrained change; the room layout,
materials, skylight/fill lights and accepted visitor assets are unchanged.
The offline bake completed in 51.25 seconds with 118 lightmap users; the rendered
scene reports zero runtime lights. This is visual refinement, not an exact
Nintendo appearance claim. Before/after evidence is packaged with the final
refinement report; no generated source pixels were edited and no paid calls
were made for this pass.

## Light after the New Horizons museum (#238)

`prepare.gd` bakes little fill, one cream-white spot per painting with a cone sized from the
frame's width, and daylight straight down through the glazing as a pool on the floor. It also
writes `baked/lamps.json`, the lamp list the floor highlight reads, from the same values.
`measure_light.gd` reads the five light targets of
`docs/research/2026-10-01-acnh-museum-polish-spec.md` (section 4, step 3) from the standard
dollhouse view of each long wall and prints PASS or FAIL per target; it also reads the
visitor at five places. After a bake run `godot --headless --editor --import --path .` before
looking: the editor leaves the previous lightmap texture in the import cache, so the game
shows the old light without any error. Values, numbers and pictures:
`docs/evidence/museum-238/light-hall/NOTES.md`.

## The approved light restored (#258)

The owner played the #238 light on 7 Oct and asked for the Hall's original light back. The
lamp values in `prepare.gd` are again those of the bake he approved on 26-30 Sep (`dbfe2393`,
unchanged until `b40d0091`): fill 0.55 `#ffe1b2`, spots 6.8 at 25 degrees `#ffd391` aimed at
each painting's centre, daylight 0.35 across the Hall, environment 0.18, skirting and cornice
glow 0.55 and 0.35. The white label cards and the shallow portal stay, so the Hall was baked
again rather than given its old lightmap back. `measure_light.gd` still reads the #238
targets; this light fails them on purpose and the script is not an acceptance check.
`baked/lamps.json` is still written and still has no reader.

Trap, seen: the bake editor turns the frames' and two textures' `.import` files back to VRAM
compression with mipmaps (20 files), undoing the lossy import the Web pack budget relies on.
After a bake, `git checkout` those `.import` files, then run the headless import.
Pictures and the cause of the wall patches: `docs/evidence/hall-lighting-258/NOTES.md`.
