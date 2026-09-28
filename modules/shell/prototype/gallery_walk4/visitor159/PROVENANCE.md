# #159 visitor gallery experiment — not a release asset

This folder replaces only the visitor in the existing Grand Gallery prototype.
The inherited room, paintings, picking, navigation and detail view remain controls.
No generated replacement body, geometry simplification, UV changes, skin-weight
changes, rest-skeleton edits, or bind-pose edits are made.

## Local inputs (intentionally not committed)

| Input | SHA-256 | Source |
| --- | --- | --- |
| `inputs/character.glb` | `a2e6e0948dafb5b0ac10ffdc7359c64fbe04371038f0265d9cb1e1af390e54c4` | #163 Hair36 static candidate `/tmp/risd-163-hair36-candidate.glb`; report commit `cf4a17ae` on `prototype/163-character-materials` |
| `inputs/donor.glb` | `e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d` | KayKit Rogue, pinned upstream `672074b73ba276876a19e8816ecdc5241817ab47`, CC0; local `/tmp/gallery-grounded-character/Rogue.glb` |

The New Horizons authored body/hair geometry, textures and skeleton remain
Nintendo-derived material. Educational/prototype use is **not** redistribution
permission. Neither the GLB nor a release/runtime acceptance is conveyed here.
Input acquisition and exact source attribution remain in #163's report and
`docs/research/2026-09-27-acnh-authored-hair-source.md` on that branch.

The 42-bone imported target adapts #171 rotation transfer and contact
solver (historical report pin `422e3d40d146cae4be77340cbc008d44e3ce8e59`;
#171 was later reopened for resting-stance visual repair). Only donor Idle,
Walking_A and Interact are sampled. All motion is **non-authentic fallback**;
authentic New Horizons clips remain an open source route, not a claim here.
The controller adds turning, blending and reach-limited planted-foot corrections.
After the first visual rejection, a disclosed procedural Interact accent extends
the left arm/forearm outward; look rotation peaks at 0.65 rad. Stationary settling
uses source-rest sole positions, neutral hip height and forward knee poles with
a 0.2-second blend, avoiding donor crouch/sideways knee bend. These remain
non-authentic pose corrections, not geometry or bind edits.

Material copies convert the source emission color/texture to diffuse albedo,
set metallic=0, roughness=1, disable specular, and use the gallery's established
1.6 indirect-light gain. The repaired batch retains character-only source-color
emission fill of 0.25 (0.6 for hair) for readability; this does not light the room.
Imported emission is already sRGB. This conversion is
necessary because the emissive-only source export has metallic=1: simply disabling
emission produces black under diffuse light probes. `VISITOR_MATERIAL=source`
(Web `?material=source`) preserves the unchanged source-emissive material route.
The default prototype camera pitch is 25° (42° and 15° were compared), with a
1.55 m target height. No global lighting or room finish is changed. No
generation/provider spend occurred. Source identity and rights are unchanged.

## Reproduce (Godot 4.7.2)

Copy the two pinned inputs above to `inputs/character.glb` and `inputs/donor.glb`,
then run the editor import once. Inputs and extracted textures are gitignored.

```bash
godot --headless --editor --path . --import
godot --rendering-method gl_compatibility --path . res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn
VISITOR_CAPTURE=1 godot --rendering-method gl_compatibility --path . res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn --resolution 1080x1080
VISITOR_FAST=1 VISITOR_CAPTURE=1 godot --headless --path . res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn --fixed-fps 30
node modules/shell/prototype/gallery_walk4/visitor159/verify.cjs /tmp/risd-159-evidence/native-metrics.json
godot --rendering-method gl_compatibility --path . --script res://modules/shell/prototype/gallery_walk4/visitor159/light_check.gd
godot --headless --path . --export-release Visitor159 /tmp/risd-159-web/index.html
```

Native capture writes `/tmp/risd-159-evidence/`. The Web feature override selects
this throwaway scene only for the `Visitor159` preset; the ordinary main scene is
unchanged. Serve that scratch Web export on port 8159 and run `browser.cjs` with
`PLAYWRIGHT_PATH` pointing to an installed Playwright package. It checks browser
wall time independently of the Godot demo clock and records normal-speed video.
Do not publish the scratch export containing restricted input geometry as a release.
