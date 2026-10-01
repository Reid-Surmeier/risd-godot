# Character movement and interaction prototype — issue 231

The live demo now uses one shared body and 24-bone rig, with separate source-informed WALK, RUN, DASH and skid poses. Full normal input runs at 3.15 Godot units/s; sprint reaches 4.846154. Acceleration, heading, cadence, braking and gait selection share one controller. Partial input selects WALK. These units are a playtest calibration, not recovered Nintendo meters.

| Control | Behavior |
| --- | --- |
| WASD / arrows / left stick | Move; travel follows actor heading |
| Shift / controller B or shoulders | Sprint; a sharp reversal skids |
| Ctrl / Walk–Run button | Partial-input WALK |
| E / Interact | Talk near the neighbour, receive a gift pose, enter/exit the house |
| Tool | Cycle none, axe and net; selected arm/hand overlays blend while moving |
| Surface / Rain | Review path, grass, sand, water, snow, leaves, indoor suppression and rain |
| Speed | Cycle ×1, ×1.5, ×2.18 travel hypotheses without changing the gait formulas |
| View / R or Reset | Game-angle/profile/lower camera; return outdoors to origin |
| Touch arrows + Sprint | Simultaneous direction and sprint |

The house and neighbour are simple review geometry. The arena is flat. Blink timing, iris transitions, tool poses and surface dispatch follow the researched source behavior; prop shapes, atlas eyelids, audio and effect sprites are local adaptations. Physics blocks walls; blocked movement stops new effect births. A complete visual-root correction keeps the lower sole above the flat floor during lean/blends. It does **not** lock the stance foot in world space.

Build and exercise the isolated project:

```bash
python3 image-work/character-pilot/live-demo/build.py
```

The command imports at 240fps with animation optimization disabled, runs controller/integration checks, the exported-palm/wrist/audio checks, and native render/pixel checks before exporting under ignored `build/character-playtest/<content-hash>/site`. It changes no shipped runtime module. Publish and check the generated site:

```bash
python3 ~/agentic-workflow/scripts/share.py <printed-site-folder> --label character-walk --reason 'Owner-requested refined character demo, issue231' --keep 3d
node image-work/character-pilot/live-demo/browser_check.cjs <published-url> image-work/character-pilot/live-demo/evidence
python3 image-work/character-pilot/live-demo/check.py
```

The browser check actually holds keys, enters/exits the house and sends two simultaneous touch contacts at 960×720 and 390×844. Native integration also exercises analog input, wall push, tool visibility, dialogue lock, receipt pose, surface/rain dispatch, blinks and floor clearance. A physical gamepad remains untested. `evidence/provenance.json` binds the build, clips, checks and screenshots.

Record whole-viewport evidence, then compare with the retained short EmuRetro excerpt:

```bash
DISPLAY=:99 ~/bin/godot --path <generated-project> --fixed-fps 60 --display-driver x11 --rendering-method gl_compatibility --script res://record.gd
python3 image-work/character-pilot/live-demo/compare_reference.py <generated-project> <short-source-excerpt>
```

The native record advances two 60Hz updates per 30fps image. The comparison preserves the full viewport and uses one fixed pose crop/uniform body scale, without phase warping. Ground optical flow and RANSAC homographies are diagnostics, not pose alignment. `record.gd -- --walk-reference` records partial WALK at the ×2.18 travel hypothesis; pass `walk-alternative` as the comparison's third argument to retain that alternative. Preserve the ordinary record before running the alternative because its ignored frame files are reused.

The pure source joint-ratio candidate looked too long in the arms. The selected `fitted-*` clips use 72% of that arm-chain length, source hip/shoulder widths, 80% boots, unchanged UVs and the retained head-weight repair. This is a visible-fit adaptation; the public source omits original vertex assets. Both rejected and selected candidates remain reproducible. Read [the implementation report](../../../docs/research/character-driven-implementation-2026-09-30.md) for comparisons, failures and source limits.

Exact likeness, original tool/effect assets, source world scale, stance drift on turns and non-flat terrain remain unaccepted. The reference footage has unknown input/gait, different clothing and uncertain capture settings. The web export requires WebGL2; [Godot web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html). No additional provider calls or API cost; aggregate pilot liability remains $1.54 of the authorized $4.

## Appearance, hands and audio regression pass

The blink shader now preserves the original material’s lighting, roughness, color handling and filtering. It closes and opens over five eased updates rather than switching among three images. Calibrated skin patches prevent unrelated atlas colors from entering the eyelid. A head-weight mask prevents UV overlap from blinking the sleeves or palms. This remains an atlas-specific pilot effect, not a reusable arbitrary-character eyelid generator.

Hand repair uses the existing mesh, a small amount of local thumb subdivision, interpolated thumb UVs, short matched palms and rigid distal weights. The forearm anatomical correction is inherited by Hand; the old omission produced about 10.59 degrees of unwanted wrist counter-rotation. The original head coordinates/UV correspondence and all other shared-rig checks remain guarded. These are stylized mittens with a thumb, not articulated fingers.

`sound.gd` selects distinct terrain, side, variant and sprint samples at pitch 1, with the researched gait gains. Skidding has a separate cue. Four door events use the source-frame proportions within the existing prototype transition. Waveforms are local synthesis: exact original effects, voice, ambience and original reverb remain open. [Audio evidence and sources](../../../docs/research/character-audio-correction-2026-09-30.md).

The build now runs these failure-capable checks before Web export:

- `appearance_check.gd` + `appearance_check.py`: same-pose render against the original material, 16 timed blink updates, no repaint outside the face and no blue eyelid bleed. The old build fails color equivalence and blink continuity.
- `quality_check.gd`: actual imported palm reach/thumb contour, 65 poses per WALK/RUN/DASH/skid checking relative wrist alignment, distinct PCM waveforms, terrain/side/sprint bank IDs, gait gains, decay/no clipping and idle silence.
- `driven_check.gd`: real moving/stopped audio, separate skid and all four entry/exit door cues, alongside the existing gait/tool/collision/interaction checks.

Render proof contains open, intermediate and closed blink frames and front/side hand views at four gait phases. A physical gamepad and exact original-game likeness remain unaccepted. Every selected clip must continue to share the same exported mesh, atlas, skin and rest rig.
