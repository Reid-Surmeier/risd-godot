# Round 7 — independent review of frozen candidate `1ade974755c5` (issue 231)

Reviewer: Claude Opus 5.5 (independent; not the implementer). 2026-10-01. Same session as rounds 1–6.

## Verdict: **APPROVE_PROTOTYPE** (scoped; see §5)

The two-line landing-compensation change fixes the inherited late-input head jerk it targets. The root cause and the new gate check out. Contact, impact, cues, yaw, shoe depth and clearance are invariant, and no transition gets a worse worst case.

One **inherited** issue was newly measured this round: the dash-entry bounce (§3). This delta did not introduce it. It is declared as P3 with a recommended follow-up.

## 0. Binding (verified)

| Item | Result |
|---|---|
| Stamp | Recomputed with `build.py`'s formula = **1ade974755c5**. 0 mismatches against `build/…/1ade974755c5/project`. |
| demo.gd | `4823db4641ee5e8db5a7b79faf1cc26b517740ffb7dd89133be874e647183b8d`, equal to the packet's `scene_sha256` |
| quality_check.gd | `c7e2e2981a68caa53f315e3fa8468f7748ed06638b10f253c73b8a8e97e0d454` |
| Unchanged vs round 6 | All other scripts; build.py `b12cc37b…`; appearance_check.py `1ef2695c…`; tool_clearance_check.py `b2f3c13a…`; six GLBs; hand atlas `61a76e1d…` |
| PCK | Local = served (streamed) = **`21367f7df48b636a8aa26a5fa597d3bfdaf669cffcae6fdf2469d087dc71750b`**, matching the packet |
| Main 64 s proof | `pose-candidate-multiview.json` declares `1ade974755c5`; my headless reproduction matches **1920/1920** frames. The mp4 (`c16918e8…`, 1920 frames at 30 fps) carries the `1ade974755c5` label in all eight scenarios. |
| Main proof vs round 6 | The trace is identical to round 6 because this delta changes pose, not body path. In my probe, the poses of all eight proof scenarios are unchanged (stand, run, axe, platform, dash, steer, net, lower). |
| Landing film | `landing-transition-before-after.mp4` (`c7a9e2cf…`, 1920×720, 100 frames), `.jpg` (`f36a87f0…`), `landing-transition-check.json` (before `dbe77dfe4d0f`, after `1ade974755c5`) |
| Film pixel binding | I re-rendered with the root's `landing-transition-record.gd` (output redirected). On the frames where the builds differ (27–29 and 77–79), the film's left half matches my round-6 render (side view 30.0 dB vs 23.7 against round 7) and the right half matches my round-7 render (29.2 dB vs 23.4). See `r7-film-binding.png`. |
| Film numbers | Before 0.046393 / after 0.032800 equal my own gate runs. |
| Native gate logs | All PASS (controller, driven, quality, tool-clearance geometry 2552 / 48 / 0 inside / 0.043379 / 0.043147, appearance-pixel 0.025/255) |

## 1. Delta and root cause (verified)

**`demo.gd:727–729`**
- The moving-landing drop now subtracts `carried × (1 − age/0.167)` without `max(0)`.
- `last_landing_drop` stores `drop + carried × f`, i.e. the uncompensated target.

**Root cause, checked in code and with an instrumented private copy:**
- The pose captured at each clip switch is taken at tick start (`demo.gd:582–583`). It therefore already contains the procedural pelvis compression.
- `play_from_displayed(...,0.167)` (`demo.gd:659`, `844–857`) cross-fades it linearly over exactly the compensation window.
- **Old clipping:** a standing-to-moving switch carries the standing compression (amplitude 0.085 plus reach lowering). That exceeds the moving target (0.065), so `max(0)` left extra baked compression that kinked out as the blend faded.
- **Old bookkeeping:** `last_landing_drop` stored the net drop, so a second switch (Walk→Run) under-counted the baked compression and applied it twice.
- Signed compensation keeps visible compression equal to the moving-landing target.

**New gate** (`quality_check.gd:202–220`): a standing hop, `down` pressed at landing tick 0–8, with vertical body-relative head second difference ≤0.033 through landing tick 18.
- It **PASSes** on 1ade (per-delay values identical to `evidence/quality-check.json`).
- It **FAILs** on the round-6 scene: "Landing gait change jerks head: 2 0.03301709890366".
- The margin is tight (worst 0.0328 vs 0.033), and the gate covers only run + `down`.

## 2. Independent results

**Steady references** (vertical head second difference): walk 0.0115, run 0.0165, dash 0.0538. An ordinary running-landing contact is 0.040.

1. **Target: late input after a standing hop.** `tools/opus_r7late.gd`, 563 cases on each build: tool None/Axe/Net × run/walk/dash × 4 directions × press tick −6…18, plus moving-hop input changes.
   - Gate-equivalent (run, `down`, ticks 0–8): **0.0464 → 0.0328**.
   - Walk presses at ticks 4–6: 0.035–0.037 → **0.030**. Axe and Net match the no-tool numbers. Ticks ≥9 are unchanged.
   - Dash entries from standing stay ≤0.051, within steady dash, in both rounds. Dash at tick 2 with a tool goes 0.046 → 0.051.
   - Contact ticks identical 563/563. `stand_move_land3` in probe3: head 0.046 → 0.033, hips 0.046 → 0.032, knees 0.052 → 0.035, flags 27 → 16.
2. **Regression probe** (`opus_probe3.gd`, 23 scenarios + Receive):
   - **21/24 identical** to round 6. The 3 changed scenarios are the late-input standing hops (`stand_move_contact`, `_land3`, `_land8`), and every metric improves or holds.
   - Only `stand_move_contact`'s internal sole-normalisation offset step grows (0.008 → 0.017); its visible head and hips motion is unchanged.
   - 26 rows changed (≤3.2 cm in model space).
3. **Skinned clearance where poses changed:**
   - The 26 changed probe rows: 0 penetrations, arm gap ≥0.145, hand–head ≥0.316.
   - Targeted late-input tool landings (Axe/Net at ticks 0, 2, 3, 4, 5, 8; Axe Run→Dash at 5, 6, 8; 345 skinned poses per build): 0 penetrations in both rounds, and every minimum gap is identical (arm 0.034, axe–head 0.079, axe–body 0.054, net ≥0.166).
4. **686-jump contact sweep** (`opus_r5contact.gd`):
   - Contact tick, impact, cue, gain, surface, state, contact clearance, air clearance and yaw are **identical in 686/686**.
   - Shoe depth unchanged (worst −2.18 mm; 0 cases deeper than 2.5 mm). Last-3-air plus contact pose steps identical.
   - Landing-phase maxima unchanged. Only 2 per-case increases above 5 mm (an axe hand step 0.033 → 0.040, below steady run's 0.042).
5. **Moving-landing gait changes across stride phases** (`opus_r7gait.gd`: 16 run-up lengths × 15 switch ticks × 6 changes = 1,536 cases per build):
   - Run→Walk, Walk→Run, stop and turn are **identical to round 6 in all 960 cases**.
   - Dash entries change per case in both directions with no new worst case:
     - **Run→Dash:** 23 cases worse and 4 better by more than 0.005; worst case 0.0994 in both rounds.
     - **Walk→Dash:** 12 worse and 30 better; worst case 0.0870 → 0.0881.
6. **Served build:** 48 steered standing jumps, 738 bridge samples, 0 parked, lowest Land sample −2.17 mm, 0 page errors.

## 3. Newly measured INHERITED P3 — dash-entry bounce (not introduced by this delta)

**What happens:**
- Entering Dash produces a sharp vertical head bounce. On flat ground with **no hop**, Run→Dash reaches 0.0887 and Walk→Dash 0.0760, against 0.054 for steady dash.
- After a landing it reaches 0.099 in **both** round 6 and round 7.

**Cause** (instrumented trace): the phase-matched dash clip's hip trough (animated hip 0.430, vs run 0.589) is entered inside the 0.167 s blend.

**How this delta touches it:**
- It shifts which switch timings are sharpest. Example: Run→Dash pressed 7–8 ticks after a running landing, on some stride phases, goes 0.078 → 0.098.
- Mechanism: the signed compensation can raise the pelvis while the baked compression fades. Sole normalisation then cancels that raise when a dash foot plants.
- The worst case does not rise, and other timings improve.

**Recommended follow-up (non-blocking):**
- Smooth dash entry, e.g. a longer Run/Walk→Dash blend, or enter the dash cycle at a height-matched phase.
- Extend the landing gate to cover walk/dash modifiers and tools, with gait-specific envelopes.

## 4. Declared limits (inherited, unchanged)

- Platform-lip perch and ascending lip landing.
- Faceted mitten/thumb topology; hand `filter_linear` without mipmaps.
- Synthesized audio and timbre.
- Dash-entry bounce (§3).

## 5. Scope of approval

- **Approved:** the playable prototype of `1ade974755c5` — idle (owner-quieted, unchanged), pose, rig, jump, hands, effects/audio and their gates — as a prototype only.
- **Still open:** exact Animal Crossing likeness, original sound, production/shipping readiness and full-game fidelity. Owner acceptance is the owner's call; the owner's positive preview is not evidence of original sound or game fidelity.

## 6. Evidence (all in /tmp/character-opus-review; compact metrics kept, raw snapshots and meshes pruned)

- **Sweeps:**
  - `probe-out/r7-late/{dbe7,1ade}.json`
  - `probe-out/r7-gait/{dbe7,1ade}.json`
  - `probe-out/r5-contact/1ade.json`
- **Probe and clearance:**
  - `probe-out/r7-1ade/bones3.json`
  - `probe-out/r7-toolgeo.json`
  - `probe-out/r7-trace/trace.json`
- **Images:** `r7-film-binding.png`, `r7-proof-sample.png`
- **Browser:** `browser-r7/cap-log-r7.json`
- **Tools:** `tools/opus_r7late.gd`, `opus_r7gait.gd`, `opus_r7one.gd`, `opus_r7toolgeo.gd`, `analyze7_late.py`, `analyze7_geo.py`, `analyze7_toolgeo.py`, `browser_r7cap.cjs`

## 7. Tool receipt (round 7)

- **ScrapeCreators:** **0 new credit-consuming calls** (cumulative 2/3, ≈$0.0038). No generation, no paid or other-provider calls.
- **Network:** one streamed hash of the served PCK and one headless-Chrome session on the validation URL. No other fetches.
- **Writes:** none to the repo, models, evidence, provenance, git or GitHub; no credentials or configs read.
  - Private `/tmp` copies (`instr7-*` instrumentation, `qc7-*` gate cross-check and film re-render) were removed after use.
- **Storage:** pruned my review folder from 895 MB to 386 MB (old snapshots, raw indexes, meshes and frames).
