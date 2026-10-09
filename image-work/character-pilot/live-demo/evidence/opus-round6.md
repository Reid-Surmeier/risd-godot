# Round 6 — independent review of frozen candidate `dbe77dfe4d0f` (issue 231)

Reviewer: Claude Opus 5.5 (independent; not the implementer). 2026-10-01. Same session as rounds 1–5.

## Verdict: **APPROVE_PROTOTYPE** (scoped; see §5)

This candidate changes only one thing from approved round 5 (`c0aec056189b`): the R5-1 shoe-depth cleanup.
- The code is byte-for-byte the remedy I trialled in round 5.
- It removes the snap sink and changes nothing else measurable.
- The new gate catches the round-5 defect. Binding is exact.
- R5-1 is **closed**.

## 0. Binding (verified)

| Item | Result |
|---|---|
| Stamp | Recomputed from the worktree with `build.py`'s formula = **dbe77dfe4d0f**. 0 mismatches against `build/…/dbe77dfe4d0f/project`. |
| demo.gd | `688cf0669220b0e43c0f8667479d5cc0a3a532b29c28c8d9bbe394a5b62f4533`, equal to the packet's `scene_sha256` |
| quality_check.gd | `56f9d55aecd2bc7ab805a7173f8073a20400be6f502646558f7138bfc6766e15` |
| Unchanged vs round 5 | All other scripts (tool_clearance_check `cf363dba…`, locomotion `722745a0…`, appearance/controller/driven/record/sound); build.py `b12cc37b…`; appearance_check.py `1ef2695c…`; tool_clearance_check.py `b2f3c13a…`; six GLBs (walk `7345fcdc…`, run `f752810d…`, dash `85267be2…`, skid `211afac6…`, axe `c84ea317…`, net `620690d7…`); hand atlas `61a76e1d…` |
| PCK | Local = served (streamed) = **`d82ce6a0d273d9e0b0966a5652a23c68c2e8c584ca18e6b47028416f7063caec`**, matching the packet |
| Primary proof | `pose-candidate-multiview.json` declares `dbe77dfe4d0f`. My headless reproduction of `pose-review-capture.gd` matches **1920/1920** frames. |
| Proof vs round 5 | Differs only in 152 steer frames, by ≤1.1e-5 m, with identical stage and state |
| Native gate logs | All PASS (controller, driven, quality, tool-clearance geometry 2552 / 48 / 0 inside / 0.043379 / 0.043147, appearance-pixel 0.025/255) |
| Legacy, not used | `idle-rocking-preview.json` still says `3d9fb0309b55` and is being refreshed. The idle code is unchanged since its round-4 verification. |

## 1. Delta under review (c0ae → dbe7)

**`demo.gd:614,621,624–626`**
- Declares `swept_floor := -INF` and records `swept_floor = hit.position.y` when the touchdown ray caps vy.
- After `apply_floor_snap()`, and only if `is_on_floor()`, it sets `velocity.y = 0` and `global_position.y = maxf(global_position.y, swept_floor)`.

The `diff` output is **byte-identical to my round-5 private trial** (`cand-c0ae-fix`). The zeroing is needed because Godot 4.7.2's `apply_floor_snap()` does not touch velocity (`character_body_3d.cpp` L459–493; cited in round 5).

**`quality_check.gd:202–212, 289`** — the new gate:
- Reproduces body (0.21, 0, −0.47), slow + up + left, jump.
- Asserts the minimum root y over the first three contact ticks is ≥ −0.0025.
- Writes `contact_depth` to `quality-check.json`.

## 2. Independent results

1. **686-jump contact sweep** (`tools/opus_r5contact.gd`; sets A–I as in round 5, including my original 200 cases):
   - **686 / 686 rows are bit-identical to my round-5 fix-trial output.**
   - 0 cap-without-contact, 0 flight rewinds, 0 airborne-at-floor.
   - Against approved round 5, contact tick, impact, cue count, gain, cue surface, state, yaw, apex, jumps and landings are identical in **686 / 686**.
   - Pose metrics move by ≤3.2e-6 m (hands, head and hips at contact and through Land), which is float noise.
2. **Shoe depth:**

   | Measure | Round 5 | Round 6 |
   |---|---|---|
   | Worst contact-tick root | −7.18 mm | **0.00 mm** |
   | Worst over 12 ticks after contact | −7.96 mm | **−2.18 mm** (ordinary grounded jitter, as in round 4) |
   | Jumps sinking deeper than 2.5 mm | 26 | **0** |

   - Snap-contact residual vy is now 0. The only non-zero vy at contact is the inherited +2.13 ascending lip-landing.
   - The clamp never floats the body: every contact is within 1.5 mm of the floor, except the inherited platform-lip perches (11 / 11, unchanged).
   - Two buffered second jumps start 0.4–0.7 mm higher, because the first landing is no longer sunk.
3. **Visual** (`r6-shoe-depth.png`, 1.5 m floor-level camera, rounds 3 / 5 / 6, t44–47):
   - Round 6's sole edge is within **+1 px of round 3** at contact; it sits exactly on the plane where round 3 sits 0.8 mm above it.
   - It is identical to round 3 afterwards. Round 5 was 10–13 px low.
4. **Gate effectiveness:**
   - The round-6 gate PASSes on the dbe7 scene (`minimum_root_y` = −7.45e-9, equal to `evidence/quality-check.json`).
   - With the same gate dropped into the round-5 scene, it **FAILS**: "Floor snap drove shoes below the surface: −0.00795676", exactly the R5-1 depth I measured.
5. **Regression probe** (`opus_probe3.gd`, 23 scenarios + Receive, every tick):
   - Continuity metrics, flags, cues, knees, plant, lean and contact ticks are **identical to round 5 in 24 / 24**.
   - Only 25 of 3,890 rows change at all: ≤4.3e-5 m in model space and ≤1.3e-5 m in body position.
   - Skinned geometry was not rerun. Changes of 0.04 mm cannot cross the smallest measured gaps (arm 0.0108, prop–head 0.0434, the latter in unchanged pre-contact rows).

Also verified:
- **Root evidence:** `contact-velocity-check.json` (stamp `dbe77dfe4d0f`, scene `688cf066…`) has 200 cases with contact y in [−7.45e-9, 8.24e-4], contact vy all 0, and 0 failures.
- **Served build:** headless Chrome, 48 steered standing jumps, 721 bridge samples, **0** parked Descend samples, lowest Land sample −2.08 mm, 0 page errors.

## 3. Reused evidence (unchanged inputs, not repeated)

- **Rig, idle, textures, research:** the owner-quieted idle stays 50.00% hip / 51.65% head vertical, with no shared-source mutation.
- **Axe regrip:** 96 jumps; this delta cannot alter it, and the probe confirms pose invariance.
- **Earlier proofs:** tool clearance and the round-1–5 research citations.

## 4. Declared limits (inherited, unchanged; not delta failures)

- Platform-lip perch and ascending lip "landing" (11 contacts, identical).
- Head jerk ≤0.046 on sharp direction changes 3–5 ticks after contact.
- Faceted mitten/thumb topology; hand `filter_linear` without mipmaps.
- Synthesized timbre.

## 5. Scope of approval

- **Approved:** the in-scope playable prototype of `dbe77dfe4d0f` — idle (owner-quieted), pose, rig, jump, hands, effects/audio and their gates — as a prototype only.
- **Still OPEN:** exact Animal Crossing likeness, original audio, production/shipping readiness, owner acceptance and full-game fidelity.

## 6. Evidence (all in /tmp/character-opus-review)

- `probe-out/r5-contact/dbe7.json` (vs `c0ae.json` and `c0ae-fixtrial.json`)
- `probe-out/r6-dbe7/bones3.json`
- `probe-out/r6-trace/trace.json`
- `probe-out/r5-render/dbe7-sink-t4*-low.png`
- `r6-shoe-depth.png`
- `browser-r6/cap-log-r6.json`
- `tools/browser_r6cap.cjs`

## 7. Tool receipt (round 6)

- **ScrapeCreators:** **0 new credit-consuming calls** (cumulative 2/3, ≈$0.0038). No generation, no paid or other-provider calls.
- **Network:** one streamed hash of the served PCK and one headless-Chrome session on the validation URL. No other fetches.
- **Writes:** none to the repo, models, evidence, provenance, git or GitHub; no credentials or configs read.
  - Private `/tmp` copies (`qc6-dbe7`, `qc6-c0ae`) were used only for the gate cross-check and proof-trace reproduction, then removed.
  - Bulky `poses.bin` pruned.
