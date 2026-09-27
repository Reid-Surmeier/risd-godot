# Overnight gallery: 3D character, performance and GameCube target

Owner rejected the sprite solution on September 26. Earlier animation approval applies only to its prototype usefulness; it does not accept a flat rotating image as the final character. Earlier reviewer DONE verdicts are superseded for this objective.

## Settled scope

- All requested tasks are in scope: actual grounded animated 3D mesh, environment-dependent lighting, smooth repeated/combined WASD, cold-load and runtime performance, reference-driven final shader, independent blind review of actual live output.
- Correct 3D motion and lighting take priority over retaining the red-cap appearance.
- Owner tests on a Mac M3 and sees both loading and random movement lag. Desktop RTX4070 requestAnimationFrame counts are insufficient proof. Use measured loading, actual game/render timing and documented proxy conditions; never label Linux proxy evidence an M3 test.
- Preserve the museum and its artwork placements. Reference screenshots/video are comparisons, not replacement room layouts or texture sources.
- No new paid generation, push, merge or release. Use primary research and existing/free inspectable assets first. Record licenses and source hashes.
- User requested an Orca heartbeat every 30 minutes overnight. Configure through 08:00 America/New_York on September 27, then stop scheduled ticks. This end time is an operational assumption, not a delivery promise.

## Work order and evidence

1. Resolve the character/lighting pipeline, reproduce performance/input bugs, and establish independent visual acceptance in parallel. Record decisions on the existing Grand Gallery map.
2. Implement the smallest complete 3D slice in an isolated candidate checkout, then integrate only reviewed changes. No further sprite offsets are a substitute for the requested mesh.
3. Compare controlled live captures to reference, fix verified failures, and repeat. Include diagonal starts, rapid W/A/S/D changes, stopping/turning, feet/shadow contact and moving through lit/shaded zones.
4. Measure cold startup bytes/time and actual frame stalls before/after. Keep existing 23-artwork and doorway checks. Test real browser rendering, not only static formulas.
5. Write a morning report that distinguishes completed work, evidence, rejected trials and remaining failures. Do not substitute a generic DONE verdict for the owner's goal.

## Coordination

The active API coordinator owns /home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype. Research agents have separate named report files. Heartbeat agents must inspect current issue activity and this directory first, and must not edit code in a checkout another agent is using. If stalled, advance a research decision or create an isolated Orca candidate based on the recorded prototype branch; do not reset, overwrite, or close another agent's work. Log actual progress and the next concrete action. A timestamp alone is not permission to take over a dirty worktree.

## Current checkpoint

Primary character and GameCube research passed the implementation gate at cde21b9. The independent blind baseline at c5700d4 verifies foot/shadow separation, abrupt reversal, and no character lighting response; its scale comparison says the current figure is already close to the house reference. Exported runtime 670e820 remains the unchanged control. Issue #139 has an isolated rig candidate worktree; #140 has an isolated display candidate worktree; #137 has an isolated performance worktree. The coordinator will integrate only candidates that pass native/browser and visual checks. No claim of M3 measurement or Nintendo-exact rendering follows from the Linux baseline.

Research tickets: [grounded 3D visitor](https://github.com/Reid-Surmeier/risd-godot/issues/136), [load and WASD performance](https://github.com/Reid-Surmeier/risd-godot/issues/137), [GameCube renderer and blind comparison](https://github.com/Reid-Surmeier/risd-godot/issues/138). Orca heartbeat automation: 283bf0fc-59d8-4e5b-8ecb-20bfc8a2d13c (every :00 and :30, America/New_York; hard precheck after 08:00 September 27).

## First measured baseline (Linux Chrome proxy)

A cache-disabled launch of exported `670e820.html` on local Chrome/RTX4070 took 16.21 seconds until `game-shown` (21.23 seconds including five seconds of subsequent observation). `downloads-done` 2.82s, `godot-ready` 3.69s, `game-instanced` 3.94s, `tabs-warm` 14.34s, `game-shown` 16.21s. During startup, compositor requestAnimationFrame p95 was 300ms, max 2.12s with sixteen gaps >100ms; after game-shown it was 16.7ms median/16.8ms p95 for five seconds. The 137MB game pack transferred 143,481,240 bytes and ~9.7MB WASM 10,084,599 bytes. Total compressed transfer previous test ~159.7MB. The warm-every-tab stage occupies ~10.4s and is the largest local delay. This is not an M3 measurement and rAF is not a Godot frame-time monitor; `/tmp/gallery-cold-profile.json` has raw marks and resources. Diagnose tab warm-up before treating download alone as root cause.
