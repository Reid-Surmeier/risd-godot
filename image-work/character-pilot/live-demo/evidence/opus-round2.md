# Round 2 — independent review of frozen candidate `1b998d1d40c0` (issue 231)

Reviewer: Claude Opus 5.5 (independent; not implementer). 2026-10-01. Same session as round 1.

## Verdict: **REJECT** — two blocking jump defects remain (N1, N2) plus net/head clipping (N3). Most round-1 findings are fixed and verified (§2).

## 0. Binding (verified, not assumed)
- `build.py` content stamp recomputed from worktree sources = **1b998d1d40c0**; all 8 runtime/check scripts and 6 GLBs in the native project are byte-identical to the worktree and to `provenance.json`.
- demo.gd `820cbe9624ad575b41aaa30255d1aed9d904e860949c2938cd01e92e2a6f20f3` · sound.gd `b1399871…f738c` · quality_check.gd `e239f3f8…c6f90` · locomotion.gd `722745a0…eaa`
- GLBs: walk `7345fcdc…041d` · run `f752810d…d6bb` · dash `85267be2…43d0` · skid `211afac6…4016` · axe `c84ea317…9c63699` · net `620690d7…e6c4`
- PCK `55c445df31b715b0ec427e857cf1d33e66a12034e166351994cc54e16355e5c8`. The served `character-validation-01a0f3a2/index.pck` was streamed and hashed (not stored) and is **identical**.
- Proof: re-running the root's `evidence/pose-review-capture.gd` on my frozen snapshot reproduces all **960/960** trace frames of `pose-candidate-multiview.json` exactly. So `pose-before-after-multiview.mp4` depicts this build. `browser.json` and the multiview JSON carry no stamp themselves.

## 1. Remaining defects

**N1 · P1 (blocking) — a standing jump steered in the air collapses into a dragged squat, then pops.**
- *Repro (native, 60 Hz):* standing jump, press a direction at the apex (`stand_then_move`) or together with the jump (`stand_press_move`). The axe variant behaves the same.
  - Contact is still treated as a planted standing landing while the body runs at 3.15 u/s.
  - Hips drop 0.532→0.147 (−0.35, 65% of hip height); head drops 0.78→0.39.
  - Feet lose reach and drift up to 0.284 from their anchors.
  - When the landing ends, head/hips step 0.12–0.15 per tick and root correction spikes to +0.106.
- *Browser repro:* on the published build, the first Land frame shows the head on the ground with legs folded out of view while the character slides (`r2-browser-repro.png`). Native sheet: `r2-steer-collapse.png`.
- *Root cause:*
  - `jump_moving` is latched at the press (`demo.gd:750`).
  - The planted landing captures world anchors at contact (`:585–589`) and lowers the pelvis without limit to reach them (`:659–669`).
  - Meanwhile horizontal velocity always follows input (`:582`). `planted_jump` is computed but never used (`:581, :587`).
- *Fix direction:* decide the landing type at contact from the current horizontal speed/input. Switch a planted landing to the moving path, with a blend, when input starts. Cap reach-lowering to the authored compression and release the anchors instead of sinking.

**N2 · P1 (blocking, new regression) — sprint jumps snap the whole figure 20° in one frame at takeoff and again at recovery.**
- `demo.gd:597` sets `model.rotation.x = 0 if jump_time>=0 else movement.lean`. Dash lean is 20° (run 1.5°), so it goes 20°→0 at tick 0 and 0→20° at tick 57.
- Head steps 0.249/0.279 u in one tick; hands 0.27–0.38. Steady dash head never exceeds 0.039.
- Baseline and both round-1 builds kept the lean during moving jumps. Evidence: `r2-dash-lean-snap-half.png`, `r2-dash-end-snap.png`.
- *Fix direction:* smooth the lean toward 0 in flight and back after landing, using the controller's own `1−0.8^ticks` smoothing, or keep it through takeoff.

**N3 · P2 — the net hoop intersects the head.**
- Surface-sampled hoop, strands and shaft against the skinned head:
  - standing net jump: hoop inside the head in 89/131 ticks (max 3.2 cm), strands in 28 ticks;
  - settled **idle hold**: 34/72 ticks >1 mm;
  - running net jump: 51/131 ticks (≤0.7 cm).
- The animated WAIT1 idle now bobs and nods the head into the statically posed net. The axe is clean (≥0.125 from the head).
- Evidence: `r2-net-clip.png`, `r2-net-head.png`. The root's geometry check sampled the net in only one idle row.

**N4 · P3 — the "red seam removed" claim is false in native renders.** The orange-red line on the back of the mitten is unchanged from round 1 at the close side/"out" camera (`r2-seam-zoom.png`, `r2-hands-seam.png`, `r2-legs-side.png`). It's tiny at game scale, but the claim must be corrected or the seam actually fixed.

**N5 · P3 — minor issues:**
- Axe takeoff grazes the body (**reproduced and classified genuine**; the root asked for this):
  - It depends on the WAIT1 phase at which the jump starts: 10 of 16 start phases, ticks 3–6, ≤5 distal-arm vertices, max 0.99 cm, ≤3 ticks.
  - My round-2 standing-axe run started at a clean phase, which is why it showed zero.
  - Fix: keep the off-hand outward for the first ~0.1 s of the Axe→jump overlay blend; target gap ≥0.005 at every start phase (`tools/opus_axephase.gd`).
- On a walking jump the soles sit 2.5–3.1 cm under the floor on the last airborne tick.
- A dash landing skips one footfall and its dust (27-tick gap against a normal 14), because footsteps are muted while `jump_time≥0`.
- A jump pressed during the 0.23 s landing is ignored (no buffer).

**N6 · proof gaps (P3):**
- The side camera's tree trunk hides the running and platform landings at contact and compression.
- The capture omits sprint jumps, steering after a standing jump, net, and lower-floor landings — exactly where N1–N3 occur.

## 2. Round-1 findings — status (measured on this build)

| # | Round-1 finding | Status | Evidence |
|---|---|---|---|
| F1 | backward knees | **FIXED** | knees bend forward on every tick of 15 scenarios (min 0.004; ≥0.011 outside N1) |
| F2 | air phase reads as floating | **FIXED** | IoU launch .851, ascent .816, apex .827, descent .835 (baseline .905/.917/.935/.980); AC circle shadow at .747 scale, .11 opacity at apex; trunk/head pitch keys present |
| F3 | timing/shape vs AC | **FIXED** (prototype) | standing takeoff tick 2, moving tick 0 (SM64-like); legs near-straight at apex (AC); standing compression −0.072 (13.5% of hip height) peaking at +5 ticks, settled by 0.23 s (AC 10–18%, ~0.23 s); arms out and up at apex (AC CLEAR_TABLE1) |
| F4 | running jump skate/stutter | **FIXED** when moving at the press: speed change per tick ≤0.39 (controller acceleration), heading kept, lands into native locomotion. N1 remains for jumps that start standing |
| F5 | early-contact pop | **FIXED** | +0.45 platform and lower-floor contacts start from the displayed pose; no step/jerk beyond the inherited run range; compression scales with impact (platform gain .543/drop ≈.05; lower .12) |
| F6 | frozen idle | **FIXED** | 1.067 s loop; abduction 41.4–50.1° (WAIT1 FK 40.8–50.1°); sagittal −11.5…+27° (+37% range); hip bob 2.9% (AC 5%); spine/head ranges match |
| F7 | tool holds | **AXE FIXED** (off-hand reaches the shaft, 0.001 gap; zero intrusion on recovery); **NET → N3** |
| F8 | planted root lift | **FIXED** | standing planted drift 0.0000, root correction 0.0000 |
| F9 | jump audio | **FIXED** | exactly one Jump cue on the launch tick and one Landing cue on the contact tick in every scenario; gain follows impact; 4 variants; no hop dust (consistent with AC) |
| F10 | tests | **IMPROVED** | knees every tick, bone steps, plant drift, cues, moving momentum — but no steer, sprint, net-surface or seam test |
| F11 | hands | seam **NOT FIXED** (N4); faceting/thumb: declared limitation |
| F12 | pipeline | locomotion clips unchanged (steady walk/run/dash steps identical to baseline) |

## 3. Continuity, separating inherited motion from jump-caused
- Steady-gait reference (identical in baseline and candidate, max step/jerk per tick): run feet 0.097/0.026, dash hands 0.159/0.081, dash head 0.039/0.055. Fast-gait steps above 0.06 are inherited, not caused by the jump.
- Skid entry/exit jerks are no worse than the baseline's (exit hands 0.147 vs 0.225).
- **Jump-caused discontinuities exceed those references only in N1 (≈3–7× run) and N2 (head 0.25–0.28 vs dash 0.039).**

## 4. Acceptance tests to add (all at 60 Hz, `--fixed-fps 60`)
1. Mixed input: standing jump with the direction pressed at the press, mid-air and at contact. Pelvis drop ≤0.10; no planted landing at contact if horizontal speed >0.2 (or drift ≤0.01); head/hips step ≤0.06 at landing end.
2. Sprint jump: lean change ≤3° per tick; head step ≤ steady-dash max + 0.02 at takeoff and recovery.
3. Net: surface samples of hoop, strands and shaft against the skinned head — zero inside, gap ≥0.01, over 66 idle phases, every standing/running net-jump tick, and the Receive interaction.
4. Seam: the close "out" camera on both mittens shows no orange line.

## 5. Repro / evidence (all /tmp/character-opus-review)
- Scripts:
  - `tools/opus_probe2.gd` (15 scenarios × every tick) with `tools/analyze2.py` (skinned clearance) and `tools/analyze2b.py` (continuity, knees, plant, cues, shadow);
  - `tools/opus_toolsurf.gd` (net/axe surface samples);
  - `tools/opus_render2.gd`, `opus_net3.gd`, `opus_skid.gd`, `opus_grip.gd`;
  - `tools/browser_r2.cjs` (published build).
  - Use `--fixed-fps 60`: `move_and_slide` integrates with the engine frame delta.
- Sheets: `r2-steer-collapse(-half).png`, `r2-browser-repro.png`, `r2-dash-lean-snap-half.png`, `r2-dash-end-snap.png`, `r2-net-clip.png`, `r2-net-head.png`, `r2-seam-zoom.png`, `r2-hands-seam.png`, `r2-legs-side.png`/`-front.png`, `r2-skid.png`, `r2-tool-holds.png`, `r2-proof-{side,gamezoom,game,front}.png`, `game-camera-silhouettes` table in this file.

## 6. Tool receipt (round 2)
- ScrapeCreators: **0 new credit-consuming calls** (cumulative 2/3, ≈$0.0038).
- No new external media. Root proof frames were extracted locally from existing evidence.
- Network: one streamed hash of our own served PCK (5.45 MB, not stored); one headless-Chrome session on the validation URL.
- Scrapling and research subagent: not used this round; first-party sources reused from round 1 and `research/primary-sources-round1.md`.
- No repo, model, evidence, provenance, git or GitHub writes. No credential files read.
