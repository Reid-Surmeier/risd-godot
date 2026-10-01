# Character movement and interaction prototype — issue 231

The live demo now uses one shared body and 24-bone rig, with separate source-informed WALK, RUN, DASH and skid poses. Full normal input runs at 3.15 Godot units/s; sprint reaches 4.846154. Acceleration, heading, cadence, braking and gait selection share one controller. Partial input selects WALK. These units are a playtest calibration, not recovered Nintendo meters.

| Control | Behavior |
| --- | --- |
| WASD / arrows / left stick | Move; travel follows actor heading |
| Shift / controller B or shoulders | Sprint; a sharp reversal skids |
| Ctrl / Walk–Run button | Partial-input WALK |
| Space / Jump | Grounded hop with preparation, flight, contact compression and recovery; landing presses buffer briefly |
| E / Interact | Talk near the neighbour, receive a gift pose, enter/exit the house |
| Tool | Cycle none, axe and net; selected arm/hand overlays blend while moving |
| Surface / Rain | Review path, grass, sand, water, snow, leaves, indoor suppression and rain |
| Speed | Cycle ×1, ×1.5, ×2.18 travel hypotheses without changing the gait formulas |
| View / R or Reset | Game-angle/profile/lower camera; return outdoors to origin |
| Touch arrows + Sprint | Simultaneous direction and sprint |

The house and neighbour are simple review geometry. The arena is flat. Blink timing, iris transitions, tool poses and surface dispatch follow the researched source behavior; prop shapes, atlas eyelids, audio and effect sprites are local adaptations. Physics blocks walls; blocked movement stops new effect births. Standing jump preparation and landing keep ankle anchors in world space. A moving jump retains the native gait instead of dragging planted feet. Floor rays select landing and prevent a descending sole from crossing the floor. General locomotion stance lock and arbitrary terrain adaptation remain open.

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

## Idle and jump review loop

The first-party WAIT1 idle curves are reconstructed from the pinned public source and validated against the existing WALK1 extractor before retargeting. The six selected assets share one 24-bone rest rig, geometry, UVs and weights. The body/head atlas remains shared; `hand-atlas-profile` adds an isolated hand sampler with a 16-pixel gutter, baked through Blender MCP, to remove neighboring clothing colors at the hand seam without changing UVs.

The jump now changes the trunk, head, arms and leg pose, with a small planted preparation, near-straight airborne legs, impact-scaled contact compression and a 0.23-second recovery. A jump pressed during landing buffers for 0.12 seconds and can launch after 0.10 seconds of recovery. Sprint lean changes by at most 2 degrees per 60 Hz tick. Tool carry keeps the right hand on the prop; the axe off-hand releases along a constrained path and returns to the shaft with its anatomical wrist orientation. The return has its own half-second blend timer and a Cartesian speed cap. Per the owner’s preference, idle position and rotation excursions are halved; the original imported AnimationLibrary is left intact.

`quality_check.gd` includes standing, moving, tool, press/apex/contact steering, sprint lean, repeated landing presses, wrist, knee, footplant and cue checks. `tool_clearance_check.gd` and `.py` check 632 poses against the actual skinned head and torus/shaft/strand/blade surfaces, including a full idle period and receipt. A further 1,920 samples cover 48 standing/running/steering axe regrips at all 16 start phases, with an actual hand-step and arm/body interior gate. Both run at fixed 60 Hz. Native render checks retain material color and blink coverage; browser checks exercise keyboard and simultaneous touch input.

The actual independent reviewer is `claude-opus-5-5`, effort `max`, through the existing Claude Max subscription. Rounds 1, 2, 3 and 4 rejected real defects; the reports are retained in `evidence/opus-round*.md`. Round 5 approved the prototype. Round 6 approved the landing-depth polish in candidate `dbe77dfe4d0f`. The candidate has 64 seconds of normal-speed proof across eight scenarios and four cameras. Inspection views hide tree canopy/trunk meshes only; game views preserve the arena.

These checks establish prototype motion and clearance, not exact Animal Crossing likeness, original sound waveform fidelity, articulated fingers or production readiness. New paid generation calls: zero; aggregate generation liability remains $1.54. Reviewer research used two ScrapeCreators credits (approximately $0.00376) under the owner's bounded research request.

The predicted touchdown uses native floor snap when the capped move does not immediately report floor contact. A 200-case direction/start/timing/gait sweep reports no deferred contacts or backward flight poses and retains flat-hop impact. The pose regression gate fails the previous exact-plane cap and passes this version.

The floor-snap polish clears residual downward velocity and lifts the body to the predicted contact plane only after Godot reports actual floor contact. A known diagonal-walk case now stays within ordinary floor jitter (2.5 mm); the new gate fails the approved-but-unpolished round-5 source and passes the round-6 source. Impact velocity is captured before descent capping, so cues retain their strength.
