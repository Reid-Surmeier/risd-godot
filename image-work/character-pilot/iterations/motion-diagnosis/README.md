# Native motion diagnosis and planar correction trial

This is a throwaway #231 prototype, not a runtime dependency. Provider files and earlier raw proof are unchanged. Read the owner's visual reaction and root continuous-camera proof before accepting this asset.

Run from any directory:

```bash
/home/reidsurmeier/.local/opt/blender-4.3.2/blender --background --factory-startup --threads 1 --python-exit-code 1 --python /absolute/path/to/correct.py
python3 /absolute/path/to/validate.py
```

`correct.py` consumes neighboring `../rigid-head.glb`, produces `footplant-candidate.glb`, saves a compressed editable `footplant-candidate.blend` with walk active, and writes `correction.json`. No secrets, paid calls, or new dependencies are used. It preserves the24bone names/parents/rests and mesh topology/atlas; target-specific shoe weights below20cm rest height become rigid Foot weights. Only derived idle/walk are exported; originals retain base/run.

`validate.py` imports the candidate into separate disposable Godot4.7.2 projects. It first imports to create metadata, disables the AnimationPlayer subresource optimizer, deletes only its own imported GLB cache, and reimports. The exact supported metadata is saved under `candidate-proof/*-target.glb.import`. Godot's tested import FPS remains30 while source baking uses60. This precision setting is essential: default import optimization discarded foot-compensation keys and failed the1mm stance gate.

The numerical gates use257samples, including interpolation between baked keys, actual imported duration and24bones, rigid Foot-weighted shoe vertices, unwrapped right stance across the cycle, and controller+Z travel at0.52m/s. `contact-manifest.json` contains the handoff: Left at8/30s, Right at24/30s, two expected walk events per loop, zero idle events. The prototype must suppress events during blends. Planar sampled contact does not establish turning, slopes, terrain, blend contact lock, or visual acceptance.

The walk has a32/30s period; idle121/30s. Both final idle and walk loops have matching endpoint geometry and local T/Q/S tangents. `idle-seam-comparison.json` retains the measured idle hitch before the repair:0.02486m/s remained constant as delta shrank. Reusing the same generic neighbor adjustment reduced it to0.000307m/s at1ms; sub-millimetre foot gates remained unchanged. The final validator also checks shrinking-delta tangent evidence for both clips. `candidate-proof/walk.json` records shrinking-delta velocity evidence separately from contact-boundary velocities. Geometric endpoint equality is insufficient evidence for smooth velocity.

## Measured attempts

- Existing normalized provider walk: Foot+Toe-weighted dense minima−8.84/−9.18cm against rest sole plane; old review plane is1.5cm below it. Raw evidence is `evidence.json`; previous raw screenshots remain outside this directory.
- Initial analytic correction: planar stance passed at30fps with ≤0.37mm sole error, but source body had an initial held frame; maximum finite-interval loop velocity difference2.10m/s. Source idle also had a2.21mm geometric seam.
- Resampling body motion and matching seam tangents: contact midpoint drift temporarily exceeded1mm. Increasing source bake density alone failed because Godot optimized away compensation keys. The GLB contained485idle Foot rotations while Godot kept106.
- Precise per-AnimationPlayer import with optimized keys disabled: final60fps bake passes stance at native30fps. Reported sole max error idle0.060mm/walk0.494mm, stance world X/Z drift0.129/0.311mm, endpoint maximum skin displacement0.359/0.100µm.
- Final quintic loop velocity differences converge0.09451→0.02835→0.00939→0.00300m/s as delta10→3→1→0.3ms. This supports matched loop tangents. A bounded cubic→quintic swing comparison reduced contact-boundary ankle velocity changes from0.196/0.201 to0.0701/0.0670m/s at native30fps, with unchanged stance gates. `quintic-comparison.json` preserves both SHAs and metrics. Native45degree sampled poses were inspected with no obvious new joint detachment; visual acceptance remains pending.
- Root's earlier0.2s blend proof measured16.17mm penetration on a preceding candidate. Blended local rotations can violate planted world-space contacts. Root owns an explicit visual-root floor lift during transition and records both unclamped/clamped results. That correction prevents penetration; it does not claim stance lock during blending.

The research note cites primary APIs and the45°/20°FOV Animal Crossing camera default: `docs/research/character-motion-contact-2026-09-30.md` on the research branch.
