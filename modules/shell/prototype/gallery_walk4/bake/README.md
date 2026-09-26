# Dollhouse comparison — #132

The default uses a fixed 45° pitch, 20° vertical field of view and quarter-turn
views. Gallery compares 35°/30°; Original keeps the prior follow camera. WASD
moves relative to the fixed view; Q/E exposes the other walls. The lighting
switch compares the same pose with the old analytical shading.

## Texture and light workflow

1. Keep the approved wall/oak maps as base colour, mapped with UV1. No normal
   maps or new generated assets were needed. Existing artwork masters stay intact.
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
Paid generation: 0 requests, $0.

## Character decision

The existing sheet only supplies a back view. Keep it as a visible placeholder
for this camera decision; billboard rotation cannot supply front/side artwork.
A directional character pass belongs after the owner chooses the view.
Visual inspection of the existing held frames identifies alternating contacts
at frames 0 and 8 of the first 16-frame stride. Later frames turn and settle, so
they are excluded from the repeating stride. Distance advances the animation;
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
