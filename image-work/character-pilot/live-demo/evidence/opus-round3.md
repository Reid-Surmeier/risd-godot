# Round 3 — independent review of frozen candidate `debd2597c1f3` (issue 231)

Reviewer: Claude Opus 5.5 (independent; not implementer). 2026-10-01. Same session as rounds 1–2.

## Verdict: **REJECT** — one blocking regression (R3-1, axe off-hand teleport). Every round-2 finding (N1–N5) is fixed and independently verified; the remaining items are P3.

## 0. Binding (verified)
- Stamp recomputed from the worktree with the current `build.py` formula (scripts + build.py + appearance_check.py + tool_clearance_check.py + hand-atlas.png + six GLBs) = **debd2597c1f3**. All 9 project scripts, the hand atlas and the six GLBs are byte-identical to the worktree.
- demo.gd `75a5498188da2f74bfb1fd9628a0d8963626ab455a8a20dd7b190fd24952e3bb`
- hand-atlas.png `61a76e1d580c23a2b3c357ca544051a55c26bf8ae00d0fc332431f7329c45517`
- quality_check.gd `9aaed02b…53cf1`; tool_clearance_check.gd `0f6473f3…93b2`; tool_clearance_check.py `17ba9e61…e019`
- GLBs (unchanged since round 2): walk `7345fcdc…041d` · run `f752810d…d6bb` · dash `85267be2…43d0` · skid `211afac6…4016` · axe `c84ea317…9c63699` · net `620690d7…e6c4`
- PCK `57fd0d1a86a9cd74f4a90ebff890134fcdcf17b2ce9af1c2cba66c64fbdb264f`. The served validation PCK was streamed and hashed: **identical**, matching the packet.
- Proof: re-running `evidence/pose-review-capture.gd` on my frozen snapshot reproduces **1920/1920** trace frames of `pose-candidate-multiview.json`. The 64 s video depicts this build.

## 1. Blocking

**R3-1 · P1 (new regression) — the axe off-hand teleports 0.70 units in one tick on every axe jump.**
- *Repro (native, `--fixed-fps 60`):*
  - Standing axe jump: at landing end (tick 59, Land→Idle) LeftHand jumps (0.532,0.505,−0.038)→(−0.081,0.680,0.244), **0.698 in one tick**.
  - Running axe jump: the same snap at contact (tick 43, Land/Run).
  - Standing axe jump steered at apex: tick 45.
- *Visible in the root's own proof:* `pose-candidate-multiview.mp4` axe segment, game-zoom frames 568→569 and front frames 688→689. The off-hand crosses the body between consecutive 30 fps frames. Browser repro: `r3-browser.png` (axe Land → Idle).
- *Cause:*
  - `demo.gd:638` now keeps `overlay = tool` during `Jump` ("holding arm preserved for Axe too"), so the overlay name never changes and `overlay_time` stays saturated at 0.30 (`:641`).
  - On the first non-Jump tick the off-hand grip solve (`:669–673`) runs with `alpha = overlay_time/.30 = 1` and puts the palm on the shaft immediately.
  - Round 2 restarted this 0.30 s approach because the overlay went None→Axe.
- *Fix direction:* start a dedicated grip-approach timer whenever the grip solve resumes (Jump→ground and moving contact). Reuse the Cartesian palm speed cap and pole blend from the release path, in reverse.
- *Acceptance:* LeftHand step ≤0.06/tick and zero arm/body penetration through the approach, for standing, running and steered axe jumps at all 16 WAIT1 start phases.

## 2. Round-2 findings — status (measured on this build)

| # | Finding | Status | Evidence |
|---|---|---|---|
| N1 | steering after a standing jump collapsed | **FIXED** | input at press, apex, contact, landing tick 3 and landing tick 8: hips ≥0.455 (was 0.147); planted drift 0; head/hips step ≤0.065; browser lands straight into Run (`r3-browser.png`); root steer guides agree |
| N2 | sprint lean snap | **FIXED** | lean ≤2.00° per tick in dash and dash-turn; head step 0.053 ≤ steady 0.039+0.02 |
| N3 | net through head | **FIXED** | surface samples, synced attachment: net hoop ≥0.254, shaft 0.151, strands 0.296 from head; zero inside over standing/running/steered net jumps and post-landing idle; carry still plausible (`r3-tool-holds.png`) |
| N4 | mitten seam | **FIXED** | orange line gone in close "out" views (`r3-hands.png`, `r3-seam-zoom.png`); no new wrist line from the hand-atlas switch (`r3-wrist-compare.png`) |
| N5 | axe takeoff graze | **FIXED** | 0/16 WAIT1 start phases intrude across ticks 0–69, min gap 0.0165 |
| N5 | dash landing skipped footfall | **FIXED** | first step after contact +13 ticks (cadence 13–14) |
| N5 | jump buffer / mid-air press | **WORKS** | buffered second jump fires 9 ticks after contact (standing) and 7 ticks (running), clean continuity, 2 Jump + 2 Landing cues; mid-air press ignored |
| N6 | proof gaps | **FIXED** | eight scenarios × four cameras; trunks hidden; bound by trace reproduction |

Full skinned clearance over 3,000 poses in 30 scenarios: zero arm-in-body, hand-in-head and prop-in-head/body. My exact point-to-triangle closest prop–head gap is **0.0434** (axe blade near apex), independently matching the root's 0.04338.

## 3. Non-blocking (P3)
1. Walk→Run clip switch inside a moving landing (`stand_move_contact` t50→51) re-captures an already-compressed pose: the head dips an extra 0.046 in one tick, recovering over ~5 ticks. Apply the carried-compression subtraction to any clip switch during Land, not only the Jump exit.
2. Touchdown on a walking jump: the physics body overshoots 5.4 cm below the floor on its last airborne tick (also present in round 2). The new floor-ray lift then gives a +0.03 / −0.055 head hiccup across two ticks. Run/dash show a 2.4 cm one-tick dip at contact, and landing end a ~3 cm bob.
   - AC's own STANDUP1 drops the root 15% of hip height within one 30 fps frame at contact, so a sharp downward step is source-consistent; the upward pre-contact hiccup is not.
3. The hand sampler uses `filter_linear` with no mipmaps, while the body atlas uses mipmaps. Possible shimmer at game distance; not observed (near-uniform skin).
- Declared limitations unchanged: faceted mitten/thumb topology; locally synthesized waveforms.

## 4. Inherited vs jump-caused (method as round 2)
- Steady references are identical to round 2: run feet 0.097/0.026, dash hands 0.159/0.081, dash head 0.039/0.055.
- Jump-related moving and buffered transitions stay within those inherited ranges, **except R3-1** (0.698 in one tick, ≈4× steady-dash hand step) and the P3 items above.

## 5. Repro / evidence (all /tmp/character-opus-review)
- Scripts:
  - `tools/opus_probe3.gd` (23 scenarios + Receive, every tick, synced attachment, surface-sampled props) with `tools/analyze3.py` (4-direction inside + exact point-triangle distance), `tools/analyze3b.py` (continuity, knees, plant, lean, cues, buffer) and `tools/analyze3_tools.py`;
  - `tools/opus_axephase.gd` (16 start phases, ticks 0–69);
  - `tools/browser_r3.cjs` (served PCK).
- Sheets:
  - `r3-proof-axe-teleport.png`
  - `r3-browser.png`
  - `r3-tool-holds.png`
  - `r3-hands.png`
  - `r3-seam-zoom.png`
  - `r3-wrist-compare.png`
  - `r3-proof-net-lower.png`
- Metrics: `probe-out/r3-debd/{bones3.json,geo3.json,tools3.json}`.

## 6. Tool receipt (round 3)
- ScrapeCreators: **0 new credit-consuming calls** (cumulative 2/3, ≈$0.0038).
- No external media. Network: one streamed hash of our served PCK and one headless-Chrome session on the validation URL.
- No repo, model, evidence, provenance, git or GitHub writes; no credentials read; `/tmp` pruned.
