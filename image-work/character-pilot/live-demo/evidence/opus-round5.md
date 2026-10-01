# Round 5 — independent review of frozen candidate `c0aec056189b` (issue 231)

Reviewer: Claude Opus 5.5 (independent; not the implementer). 2026-10-01. Same session as rounds 1–4.

## Verdict: **APPROVE_PROTOTYPE** (scoped; see §6)

R4-1, the last blocker, is fixed. I verified it on my own 200-case round-4 set plus 486 new contact cases, on the served build, and in the root's primary proof. There are no regressions.

One new low-severity item is noted as P3, not a blocker:
- **R5-1:** the native snap can leave the root up to 8 mm inside the floor for 1–2 ticks after landing, in 3.8% of jumps.
- It is sub-pixel at the gameplay and proof cameras.
- A two-statement remedy is tested below.

## 0. Binding (verified)

| Item | Result |
|---|---|
| Stamp | Recomputed with `build.py`'s formula (all 9 `live-demo/*.gd` + build.py + appearance_check.py + tool_clearance_check.py + hand atlas + six GLBs) = **c0aec056189b**. 0 mismatches between the worktree and `build/…/c0aec056189b/project`. |
| demo.gd | `8a60abf5da490072f96fdc6d47dd386e4c428536fa98911c73be4fde38a35698`, equal to the packet's `scene_sha256` |
| quality_check.gd | `bf3349acd160da8a3f61f6b4ffb3e6415b134598ff1615c15d3c1a90fed7c6b9` (new gate) |
| Unchanged scripts | tool_clearance_check.gd `cf363dba…`, locomotion `722745a0…`, appearance/controller/driven/record/sound |
| Other inputs | build.py `b12cc37b…`, appearance_check.py `1ef2695c…`, tool_clearance_check.py `b2f3c13a…` |
| GLBs, hand atlas | Byte-identical to rounds 2–4 (walk `7345fcdc…`, run `f752810d…`, dash `85267be2…`, skid `211afac6…`, axe `c84ea317…`, net `620690d7…`, atlas `61a76e1d…`) |
| PCK | `05ee4162c728cc02032108bad98ad82fe5330de9851b7b88ddd4f075cb00c2a5`. The served validation PCK was streamed and hashed: **identical**. |
| Primary proof | `pose-candidate-multiview.json` declares stamp `c0aec056189b`. My headless reproduction of `pose-review-capture.gd` (rendering removed, identical physics) matches **1920/1920** frames. The mp4 (`d786abfa…`, 1920 frames at 30 fps) shows frame 1342 as Land/Run where round 4 was parked in Descend. |
| Gate logs | All PASS. `tool-clearance-geometry`: 2552 poses, 48 regrip scenarios, 0 inside, min gap 0.043379, max regrip step 0.043147. |
| Legacy, not used | `idle-rocking-preview.json` still says `3d9fb0309b55` and is being refreshed. The demo.gd diff touches only the four jump-descent lines, so the idle proof content still applies. |

## 1. Fix under review

`demo.gd:614,621,624`:
- A local `swept_contact` flag is set when the descent floor ray caps vy.
- After `move_and_slide()`, `if swept_contact and not body.is_on_floor(): body.apply_floor_snap()`.
- The flag is local, so it cannot leak into later ticks or takeoffs.

Engine contract, checked in the Godot **4.7.2-stable source**, not only the docs. Bounded fetch of `scene/3d/physics/character_body_3d.cpp`, sha256 `97f7a626…`:
- `apply_floor_snap()` (L459–493) returns early if already on the floor.
- It tests a motion of `-up × max(floor_snap_length, margin)`, with defaults 0.1 / 0.001 (`.h` L149/L117), and accepts only floor-angle contacts (≤45° + 0.01).
- It moves the body only along the up axis, or not at all if travel ≤ margin.
- It sets the floor state and **does not touch velocity**.

The root's research appendix (`docs/research/character-rig-jump-techniques-2026-10-01.md` L89) cites the docs correctly.

## 2. R4-1 acceptance — **PASS**

`tools/opus_r5contact.gd`: 686 jumps, every tick, run identically on c0ae / 3d9f / debd.

Case sets:
- **A** = my exact round-4 200-case set.
- **B** = 12 random start points × 8 directions × 2 timings.
- **C** = Axe/Net × 8 directions × 2 timings × 2 starts.
- **D** = travel calibration ×1.5 / ×2.18.
- **E** = platform run-ups across the front lip, including diagonals.
- **F** = jumping off platforms.
- **G** = buffered second jumps.
- **H** = arena wall, tree trunk, house front.
- **I** = indoor floor and all six outdoor surfaces.

| Criterion (from round 4) | c0ae | 3d9f (round 4) |
|---|---|---|
| Launched, not-landed tick at floor height / cap without contact / flight clock rewinds | **0 / 686** | 205 / 686 (78 / 200 in set A) |
| Contact registers once per jump; `landings` and `jumps` deltas correct | 686 / 686 | 686 / 686 |
| Impact = ballistic pre-cap value (\|vy_prev − g·dt\|/3.6) | **698 / 698** contacts (incl. 12 buffered second landings) | Also equal, but from the already-capped velocity, so 0.25 |
| Flat-ground impact / Landing gain (set A) | **0.99630 / 0.99630** for all 200 | min 0.25 / 0.35 |
| Exactly one Landing cue, gain = clamp(impact) | all 698 contacts; full gain on Path/Grass/Sand/Snow/Water/Leaves and indoors | 0.35 on 8 of 14 surface/indoor cases |
| Hand step, last 3 air ticks + contact | Pose (model-local) **≤0.0099** on flat ground (tools 0.0183). Heading-removed **≤0.0237** (tools 0.0272). Platform-lip set E: 0.0688 / 0.0659, identical to round 3. | 0.19 |
| Old walking overshoot (airborne below floor, pre-contact upward model correction) | **0**. Min airborne clearance +2.2 mm overall, +4.7 mm on flat ground; no flat-ground model lift. | 0 (parks at 0.0). Round 3: −54.4 mm. |

*World-space steps of 0.1506 m are inherited steering, not a pop.*
- The per-case maximum yaw step is identical to round 3 in **686 / 686** cases (max 13.73°/tick).
- That is `locomotion.gd:14–19` clamping turns at 2500 binary-angle units per tick. The file is unchanged since round 2 (`722745a0…`).
- Round 3 shows the same 0.1506 m maximum world step for the same inputs. With a tool held, round 5's maximum is 0.1599 (round 3: 0.7467, the old axe teleport). Removing heading leaves ≤0.0237 m (tools 0.0272).
- The root's numbers (0.009934 / 0.0237415) match mine.

**New quality gate** (`quality_check.gd:217,224,231`, press / apex / contact):
- PASSes on the c0ae scene; its mixed_input values are identical to `evidence/quality-check.json`.
- With the same gate dropped into the round-4 scene, it **FAILS**: "Descent pose rewound before contact: apex".

**Served build** (headless Chrome, 48 steered standing jumps, 727 bridge samples): **0** Descend samples at floor height. Round 4 showed 2 in 24 jumps. 0 page errors. Screenshots: `r5-browser.png`.

**Visual check:** `r5-steer-contact-fixed.png` shows native 60 Hz side frames t43–47.
- Round 4 parks at t45 with the arms flung back to the apex pose.
- Round 5 contacts at t45 with continuous arms.

`r5-root-proof-steer-frames.png` shows root proof frames 1280–1284, 1340–1344 and 1400–1404, all Land/Run at contact.

## 3. Regression (standing / moving / tool / raised / lower / buffer)

- **probe3** (23 scenarios + Receive, every tick):
  - 20 scenarios + Receive are **bit-identical** to round 4.
  - The 3 changed scenarios are `stand_then_move`, `stand_axe_move` and `stand_net_move`. They now contact at t45 with Landing 1.0, a hand step of 0.059 and hips minimum 0.486, which are **exactly round 3's values**. Flags dropped 26→15, 17→12 and 24→13.
- **Skinned geometry** on the 186 changed rows (185 skinned): 0 arm-in-body, hand-in-head or prop-in-head/body. Arm gap ≥0.0139; exact prop–head gap ≥0.0573. The global minimum stays 0.04338 (`stand_axe_move` t23, unchanged row).
- **Axe regrip sweep** (`opus_r5regrip.gd`, 96 jumps = 6 scenarios × 16 phases):
  - Steered standing axe jumps now have impact 0.9963 and 0 capped ticks; round 4 failed all 16.
  - The airborne off-hand step is 0.033 (round 4: 0.19).
  - The regrip maximum is 0.0437 (dash 0.0655, below the steady dash hand step of 0.159).
  - 0 penetrations in 4,224 skinned poses. Every other number equals round 4.
- **Owner idle:** code is byte-identical to round 4 apart from the descent lines. The round-4 verification stands: 50.00% / 51.65% of source, seamless, no shared-source mutation.

## 4. New P3 — R5-1: snap can leave the root inside the floor for 1–2 ticks

*Repro* (native, `--fixed-fps 60`, `tools/opus_r5trace.gd`): start (0.21, 0, −0.47), hold slow + up + left, jump.

Instrumented private copy (`cand-c0ae-instr`):
- t44: y = +0.00536.
- t45, after the capped `move_and_slide`: y = −0.000000, `is_on_floor()` false.
- **t45, after `apply_floor_snap()`: y = −0.005423**, on floor, 0 slide collisions.
- t46: the residual vy from the cap (−0.485) carries the body to **−0.007957**.
- t47: the engine restores +0.00082, an **8.8 mm pop in one tick**.
- Round 3, same input: +0.00083 throughout.

*Extent:*
- **26 / 686** jumps sink deeper than 2.5 mm; the worst is **−7.96 mm**.
- Round 4 (cap, no snap): worst −2.18 mm, which is ordinary grounded jitter.
- Round 3's native landings: 2.5–6 mm in 13 cases, plus the 53 mm walk overshoot.

*Visibility* (`r5-snap-sink.png`, `r5-snap-sink-diff.png`):
- A 1.5 m floor-level close-up shows the shoe 10–13 px lower for two frames.
- At the 9–22 m gameplay and proof cameras this is about 1 px or less.

*Not affected:*
- Body-relative pose, impact, cue and yaw.
- The shadow (its ray starts 2 cm above the root).
- Dust and footsteps (suppressed for the first 4 landing ticks).

*Remedy, tested on a private copy only (`cand-c0ae-fix`):* after a snap-registered contact,

```
body.velocity.y = 0
body.global_position.y = maxf(body.global_position.y, swept_floor)
```

where `swept_floor` is the ray hit y. Result over all 686 cases:
- Worst sink −2.18 mm, with **0 cases deeper than 2.5 mm**.
- Contact tick, impact, cue and yaw identical in 686 / 686.

## 5. Inherited observations (present in rounds 3, 4 and 5; out of R4-1 scope; P3)

1. **Platform-lip perch.** Contacts register with the root centre beyond the platform edge, with the capsule's rounded bottom on the lip (0.39–0.45 m clear under the root centre): 11 / 12 / 12 contacts in rounds 5 / 4 / 3.
   - Dashing into the lip can register a "landing" while still ascending (t8, impact 0.592 taken from the upward speed).
   - The airborne sole guard can lift the model up to 6.2 cm before such contacts.
2. **Steady references unchanged:** run feet 0.097/0.026, dash hands 0.159/0.081.
3. **Earlier P3 items unchanged:**
   - head jerk ≤0.046 when a direction is pressed 3–5 ticks after contact
   - hand `filter_linear` without mipmaps
   - synthesized timbre
   - faceted mitten/thumb topology
4. The Landing cue's history metadata says `surface: Path` indoors. It is a single authored hop cue, and this is cosmetic.

## 6. Scope and limitations of this approval

- **Approved:** the in-scope playable prototype of candidate `c0aec056189b` — idle (owner-quieted), pose, rig, jump, hands, effects/audio and their QA gates — as a prototype.
- **Not claimed:** exact original-game likeness, original-waveform fidelity, production/shipping readiness, or owner acceptance. **Full-game fidelity remains open.**
- **Owner-adjusted:** the idle is intentionally half-amplitude at the owner's request. This is an accepted criterion, not a fidelity claim.
- **Recommended follow-ups (non-blocking):** R5-1 (tested remedy above) and §5 item 1.

## 7. Repro / evidence (all in /tmp/character-opus-review)

- **Scripts:**
  - `tools/opus_r5contact.gd` → `probe-out/r5-contact/{c0ae,3d9f,debd,c0ae-fixtrial}.json`, analysed by `tools/analyze5_contact.py`
  - `tools/opus_r5trace.gd`, `tools/opus_r5render.gd`
  - `tools/opus_probe3.gd` + `analyze3b.py` + `analyze5_geo.py` → `probe-out/r5-c0ae/bones3.json`
  - `tools/opus_r5regrip.gd` + `analyze5_regrip.py` → `probe-out/r5-regrip/regrip5.json`
  - `tools/browser_r5cap.cjs`, `browser_r4.cjs` → `browser-r5/`
- **Sheets:** `r5-steer-contact-fixed.png`, `r5-root-proof-steer-frames.png`, `r5-snap-sink.png`, `r5-snap-sink-diff.png`, `r5-browser.png`.
- **Engine source excerpt:** `research/character_body_3d-4.7.2.cpp`.
- **Reproduced trace:** `probe-out/r5-trace/trace.json` (1920/1920).

## 8. Tool receipt (round 5)

- **ScrapeCreators:** **0 new credit-consuming calls** (cumulative 2/3, ≈$0.0038). No generation, no paid or other-provider calls.
- **Network:**
  - one streamed hash of the served PCK, plus one index.html request (301)
  - two headless-Chrome sessions on the validation URL
  - two bounded GitHub raw requests: Godot 4.7.2 `character_body_3d.cpp` (39 KB) and `.h` (grep only)
  - no media downloads
- **Writes:** none to the repo, models, evidence, provenance, git or GitHub; no credentials or configs read.
  - Private `/tmp` copies (`cand-c0ae-instr`, `-qc`, `-fix`, `cand-3d9f-qc`) were used only for instrumentation, the gate cross-check and the remedy trial, then removed.
  - Bulky intermediates pruned.
