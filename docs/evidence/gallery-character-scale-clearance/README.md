# Larger rig with tighter doorway clearance: bounded follow-up

**Rejected. Keep production scale.** The scale-only trial's larger visitor can clear a 1.9 m doorway only inside a very narrow centre corridor. The parent stopped further GPU iterations after reviewing the dynamic clearance measurements, considering that precision inappropriate for casual keyboard and trackpad navigation. A larger character needs a separately scoped doorway/interaction design.

This follow-up changed the wall margin from 0.55 m to 0.85 m and doorway centre tolerance from ±0.40 m to ±0.10 m, consistently in the controller's clamp and swept end-wall check. It retained the preceding 1.42 rig multiplier. Museum geometry remained unchanged. [The isolated diff](trial.patch) records the experiment; it is not integrated. Production source in this worktree was restored to base `9e1fbea` after rejection. The preceding [scale-only evidence](../gallery-character-scale/README.md) remains separate.

## Dynamic mesh evidence

[dynamic-clearance.gd](dynamic-clearance.gd) samples actual skinned vertices every third simulation frame during 240 frames of straight walking and 78 frames of the interaction wave. It records world-space lateral extrema, not a collider proxy. [Full output](dynamic-clearance.log).

| Rig | Walking half-width | Wave half-width | Side clearance at x=0.10 m in doorway |
| --- | ---: | ---: | ---: |
| Current, factor 1.17 | 0.687945 m | 0.673062 m | 0.162055 m |
| Larger, factor 1.42 | 0.834919 m | 0.816879 m | **0.015081 m** |

The larger rig's widest sampled walk leaves **1.5 cm** on the near side at the proposed ±0.10 m centre limit. Even without a safety allowance, the widest sampled pose permits only `2 × (0.95 − 0.834919) = 0.230162 m` of lateral centre travel. The bounded candidate therefore uses a 20 cm centre corridor. Sampling does not certify all intermediate frames or arbitrary turns; that uncertainty cannot make this already narrow tolerance more forgiving.

## Native navigation findings

The unchanged existing [navigation check](../../../modules/shell/prototype/gallery_walk4/navigation_check.gd) reported four failures; [log](navigation.log). Portal transitions and floor clicks continued to work: arch and far roundtrips passed via click-walk, real keyboard input, and actual floor-click rays. Drag/easing/pan/wheel/click/cancel checks also passed, and the scene retained 23 painting records.

The four failures involve hardcoded old-clearance fixtures:

- Two white-room wall cases inject x=2.45 m, then require no movement. The new 0.85 m margin clamps that position inward to x=2.15 m, so the “crossed wall” message describes inward correction, not escape through the wall.
- Two diagonal wall-sweep cases start 0.80 m from an end wall, already inside the new 0.85 m clearance. The moved sweep plane is behind the injected start; the check fails. No adaptation of the frozen test or production fix was made.

No claim is made that this variant passed the repository's original navigation acceptance. After the parent stopped the experiment, the proposed adapted fixture, 23-artwork opening sweep, 300-route fuzz run, and additional doorway walk captures were **not run**. Existing screenshots and walk replays establish the scale-only variant's appearance, not this follow-up's doorway steerability. The measured corridor width and original-check failures are sufficient grounds to reject the narrow change without further rendering.

No production integration, room rebuild, paid generation, or public deployment occurred. GPU ownership is released.
