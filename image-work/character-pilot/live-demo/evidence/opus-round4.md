# Round 4 — independent review of frozen candidate `3d9fb0309b55` (issue 231)

Reviewer: Claude Opus 5.5 (independent; not the implementer). 2026-10-01. Same session as rounds 1–3.

## Verdict: **REJECT** — one blocking regression (R4-1)

The new descent velocity cap sometimes leaves the character airborne at floor height for one tick, so a steered standing jump loses its landing impact.

What passed:
- R3-1 (axe off-hand teleport) is fixed and independently verified.
- The owner's quieter idle is correct, loops cleanly, and does not mutate any shared resource.
- Both round-3 P3 motion items are fixed. One small jerk residual remains (P3).

R4-1 is the only thing between this build and APPROVE_PROTOTYPE.

## 0. Binding (verified)

| Item | Result |
|---|---|
| Stamp | Recomputed from the worktree with the `build.py` formula = **3d9fb0309b55**. 0 mismatches across 9 scripts, 6 GLBs and the hand atlas. |
| demo.gd | `b4452286f80e0a11fbe60d46266267ef70caaa1350165805e88548ae100530bf` (worktree = snapshot = build) |
| quality_check.gd | `8324ee9a410d8e5dc257306dffaae18831cbf7bad6edc5d9fda0bb4bce1eb6ec` |
| tool_clearance_check.gd | `cf363dbaa6203c9f4b3566223fd49d3d29fe67d563a17503f799442b16f23acc` |
| Unchanged scripts | appearance_check, controller_check, driven_check, locomotion, record, sound |
| GLBs | Byte-identical to rounds 2–3: walk `7345fcdc…041d`, run `f752810d…d6bb`, dash `85267be2…43d0`, skid `211afac6…4016`, axe `c84ea317…9c63699`, net `620690d7…e6c4` |
| Hand atlas | `61a76e1d…5517` (unchanged) |
| PCK | `89a8c9e003839b530e686fd02ff1c4e90594951671a1780eabf0a71bbd779dcb`. The served validation PCK was streamed and hashed: **identical**. |
| Pose proof | Re-running `evidence/pose-review-capture.gd` on my snapshot reproduces **1920/1920** frames of `pose-candidate-multiview.json`. |
| Idle proof | `idle-rocking-capture.gd`, redirected to my folder, reproduces trace sha256 `afcf17785ff8…92c5d`, equal to `idle-rocking-preview.json`. |
| Root logs | All PASS: `tool-clearance-geometry` (regrip 1920 poses / 48 scenarios, max step 0.043147, min gap 0.043379, 0 inside), appearance-pixel 0.025/255, controller, driven, quality. |

The root's `root4-regrip*` folders were not used.

## 1. Blocking

**R4-1 · P2, new regression, blocking — a steered standing jump spends one tick airborne at floor height. The flight pose snaps back toward the apex, and the landing loses its impact.**

*Native repro* (`--fixed-fps 60`): stand still, jump, press any direction at the apex. This is probe scenario `stand_then_move`; the axe and net variants behave the same.
- t44: y = 0.0056, vy = −3.423.
- t45: the cap sets vy to **−0.336**. The body ends at y = −0.0000 with `is_on_floor()` false, stage Descend.
- t45 pose: the flight clip time is recomputed from the capped vy (`demo.gd:631`), so it jumps **0.585 → 0.328**.
  - Hands move **0.19 m in one tick** (jerk 0.21). That is 3.2× the 0.06 limit and 4.5× the steady run hand step of 0.042.
  - Hips rise 1.3 cm.
- t46: contact registers using that tick's pre-cap |vy| = 0.50, giving **impact 0.25** instead of 0.996.
  - Landing cue gain is **0.35** (round 3: 1.0).
  - The moving-landing hip drop is ×0.25: hips minimum 0.506 vs 0.486.
- Round 3 (`debd`) on the same input: contact at t45, impact 0.996, gain 1.0, no pose regression.

*Frequency* (`tools/opus_r4cap.gd`, 200 jumps):

| Case | Failing jumps |
|---|---|
| Steered standing jumps (8 directions × 4 timings × 4 start points) | **75/128 (59%)** |
| Walking jump, turn at apex | 6/18 |
| Run or dash jumps, with or without a turn | 0/48 |

Every failure shows the same three signatures: the capped tick, the flight-time regression of about 0.257 s, and impact 0.25 / gain 0.35. The failures depend on start position: 11/32 at the origin, 25/32 at (0.37, 0.11).

*Also visible in other evidence:*
- **Root's own proof:** `pose-candidate-multiview` frame **1342** (steer/side) has stage Descend with body y = −8.4e-9. Frames 1222, 1282 and 1402 show the same tick in the other views.
- **Served build:** a headless-Chrome loop of 24 steered standing jumps caught **2 bridge samples** in Descend at y = −7.9e-9. That matches the expected rate given the bridge's 0.1 s sampling.

*Images:*
- `r4-steer-touchdown-pop.png` — native 60 Hz frames t43–t47, round 3 vs round 4, side and game cameras.
- `r4-root-proof-steer-frames.png` — frames 1280–1284, 1340–1344 and 1400–1404 from the root's proof video.

*Cause:*
- `demo.gd:614–620` sets the downward velocity so the root lands exactly on the floor.
- `move_and_slide()` (`:621`) can then end the tick on the surface without reporting a floor collision, so landing slips to the next tick.
- `impact_velocity` (`:613`) and `jump_pose_time` (`:631`) are then computed from the capped velocity. The claim "preserving pre-cap impact velocity" therefore holds only when contact registers in the same tick.

*Fix direction (choose one route to contact, then make impact and pose robust):*
1. Contact: when the sweep engages, register the landing in that same tick, or aim slightly below the surface (a target within the safe margin) so the collision reports.
2. Impact: latch the largest pre-cap descent speed for `jump_impact`.
3. Pose: keep the flight clock monotonic during Descend, or drive it from the uncapped velocity.

*Acceptance:* in a sweep at least as wide as `opus_r4cap.gd` (standing, steered at apex / apex+6 / apex+16 / pre-held slow, 8 directions, ≥4 start points; walk/run/dash with turns):
- No launched, not-landed tick at floor height.
- Flight clip time is monotonic during Descend.
- Flat-ground impact = 0.996 and Landing gain = 1.0.
- Hand step ≤0.06 per tick over the last three airborne ticks.
- The walking-jump overshoot fix (§3) is not reintroduced.

## 2. R3-1 (axe off-hand teleport) — **FIXED**, independently repeated

`tools/opus_r4regrip.gd` sweeps 6 scenarios × 16 start phases: stand, stand+steer at apex, walk, run, run+turn at apex, and dash. That is 96 axe jumps, 10,064 rows every tick, and 4,240 skinned poses from landing−1 to landing+42.

| Scenario | Max LeftHand step, landing → +40 | First landing-frame step |
|---|---|---|
| stand | 0.0437 | 0.030 |
| stand + steer | 0.0349 | 0.035 |
| walk | 0.0350 | 0.027 |
| run | 0.0432 | 0.027 |
| run + turn | 0.0433 | 0.027 |
| dash | 0.0655 (steady dash hand step is 0.159) | 0.027 |

- Round 3 had a **0.698** step in one tick.
- Geometry over all 4,240 poses: zero arm-in-body, hand-in-head and axe-in-head/body. The minimum arm–body gap is 0.0108 (dash).
- In my full probe, the exact axe–head triangle gap is **0.04338** (stand_axe_move t23), matching the root's 0.043379.
- Browser (`r4-browser.png`, frames axe-0…5): the off-hand visibly travels to the shaft after landing. No snap.
- The in-air turn yaw rate (13.7°/tick in dash_turn) is unchanged from round 3 and inherited from `locomotion.gd` (same hash).

## 3. Owner idle preference — **verified as specified** (accepted criterion, not a fidelity failure)

| Check | Result |
|---|---|
| Key formula (positions lerped, rotations slerped halfway to key 0) | Max error 4.9e-6 over 38 tracks; key times unchanged |
| Loop | Length 1.0667 s unchanged; first key = last key (seam 0) |
| Vertical range | Hips 0.015493→0.007746 (**50.00%**), head 0.015923→0.008224 (**51.65%**), exactly the root's numbers. 3D path ranges: hips 50.0%, head 50.6%, hands 50.5% |
| Shared-source mutation | None. After demo `_ready`, a fresh `walk.glb` idle and walk are byte-identical to source. A second demo instance gets the same idle (no double halving). Library, idle and walk objects are distinct, and the pristine walk `loop_mode` is no longer mutated. |
| Clearance | Idle arm–body gap 0.0757→0.0902; hand–head 0.360→0.382; zero penetrations in all idle, tool-overlay and receive rows |
| Transitions (16 idle phases) | Idle→walk 0.053→0.044; →run 0.063 (same); →dash 0.150→0.148; →jump 0.041 (same); run stop→idle 0.0755 (same). Landing→idle identical to round 3. Steady idle per-tick max 0.0122→0.006 |

Side effect (not visible): halving each channel separately breaks the source's exact foot planting by ≤1.5 mm (clip space). In game, sole normalization keeps world foot drift at ≤0.1 mm. Images: `r4-idle-extremes.png` (before/after extremes from my reproduced proof frames) and `r4-browser.png` (idle-0/2).

## 4. P3 items

1. **Clip switch during Land (round-3 P3-1) — FIXED, small residual.**
   - Worst one-tick head drop during Land, sweeping the press tick 0–14 × {run, slow, sprint}: 0.0457 → **0.0336**, which equals the standing landing's own compression step.
   - `stand_move_contact` t51 dip 0.046 → 0.015.
   - Residual: a mild jerk bump of up to 0.046 when the press lands on tick 3–5 (round 3 ≤0.033). Example: `stand_move_land3` t54, head −0.026 at the second clip switch.
2. **Walking-jump overshoot (round-3 P3-2) — FIXED where contact registers.**
   - Walk jump: round 3 put the body 5.4 cm below the floor with a +0.0305 model correction. Round 4 contacts at t43 with −0.0237 compression and no upward correction. Walk flags 23→9.
   - The cap is also the source of R4-1.
3. **Hand sampler** `filter_linear` without mipmaps: retained as a declared ceiling; no shimmer observed.
4. **Inherited and unchanged:** steady references (run feet 0.097/0.026, dash hands 0.159/0.081, dash head 0.039/0.055); skid one-tick Idle flicker 0.103 (inside the dash range); walk/run/dash/skid clip geometry identical to round 3.

## 5. Scope and limitations of this review

- **No claims:** exact original-game likeness, original-waveform fidelity, production/shipping readiness, or owner acceptance.
- **Open:** full-game fidelity.
- **Owner-adjusted:** the idle is intentionally quieter at the owner's request.
- **Declared limitations unchanged:** faceted mitten/thumb topology, locally synthesized waveforms, hand texture filtering.

## 6. Repro / evidence (all in /tmp/character-opus-review)

- **Scripts:**
  - `tools/opus_probe3.gd` + `analyze3.py` / `analyze3b.py` → `probe-out/r4-3d9f/{bones3,geo3}.json`
  - `tools/opus_r4regrip.gd` + `analyze4_regrip.py` → `probe-out/r4-regrip/regrip4.json`
  - `tools/opus_r4cap.gd` → `probe-out/r4-cap/cap.json`
  - `tools/opus_r4idle.gd` → `probe-out/r4-idle/idle.json`
  - `tools/opus_r4idleexit.gd`, `opus_r4landswitch.gd` (`landswitch-*.txt`), `opus_r4render.gd`
  - `tools/browser_r4.cjs`, `browser_r4cap.cjs` → `browser-r4/`
- **Sheets:** `r4-steer-touchdown-pop.png`, `r4-root-proof-steer-frames.png`, `r4-browser.png`, `r4-idle-extremes.png`.
- **Reproduced root traces:** `probe-out/r4-posecap/trace.json` (1920/1920) and `probe-out/r4-idleproof/trace.json` (sha `afcf1778…`).

## 7. Tool receipt (round 4)

- **ScrapeCreators:** **0 new credit-consuming calls** (cumulative 2/3, ≈$0.0038). No generation and no paid calls.
- **Network:** one streamed hash of the served PCK and two headless-Chrome sessions on the validation URL. No external media.
- **Writes:** none to the repo, models, evidence, provenance, git or GitHub; root evidence was only read or copied into `/tmp`. No credentials or configs read. Bulky intermediates in `/tmp` pruned after analysis.
