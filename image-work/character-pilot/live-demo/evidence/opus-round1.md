# Round 1 — independent review: jump, idle arms, rig/hands/audio (issue 231)

Reviewer: Claude Opus 5.5 (independent; not implementer). Date 2026-10-01. Scope: research + baseline critique, plus a
provisional pre-check of whatever the root staged during this session. **Not an approval round.**

## Verdict: **REJECT** — baseline `4ca9358b` and staged candidate `70ab53bf39de`. Next step: **NEEDS_CANDIDATE** (see §4).

## 0. Code state vs proof state (what each statement below applies to)

| Label | What it is | Status in this review |
|---|---|---|
| `4ca9358b` baseline | owner's live site; HEAD demo.gd + HEAD GLBs | rebuilt in /tmp from `git show`, probed + rendered |
| `d0a45b4e85fe` | **hybrid** project: walk.glb replaced in place 10:31, demo.gd `be83149d`, other GLBs = HEAD; stamp no longer content-bound | diagnostic only, not a candidate |
| `e5346c31cbb8` | first staged packet (10:44): build.py output, demo.gd `be83149d`, all 6 GLBs re-baked | probed + rendered (snapshot) |
| `70ab53bf39de` | **current staged packet** (11:01): demo.gd `fe4c1b1b…`, quality_check `25990295…`, axe GLB `add96f13…`; served at `character-validation-01a0f3a2` (pck size 6,173,596 + Last-Modified 10:57:42 match; hash not checked) | probed (headless metrics, silhouettes, close-ups, normal-speed strip) |
| worktree | moved twice this session (`d8bb57a0` 10:56:05 → `fe4c1b1b` 10:56:27 = staged) | any approval must bind to stamp + hashes |

Proof files: `evidence/jump-float-before-review.mp4` was byte-identical to the 09:16 `jump-review.mp4` (sha256 `0c9e2c14…`), which has since been replaced (now `a7c69678…`, 10:58) — valid baseline, label it as the 09:16 capture. Root's staged stills (`jump-side-key-poses.jpg`, `jump-game-key-poses.jpg`) are too small/occluded to judge knees, foot plant or deformation (≈80 px figure; legs hidden behind the mitten in side view).

## 1. Findings (severity · status · evidence · root cause · fix direction)

**F1 · P0 in e5346 · FIXED in 70ab53 (regression test incomplete) — knees hinge backward in planted IK keys.**
`be83149d demo.gd:709` used `pole = Vector3.FORWARD` (−Z) while skeleton space = model space (0.01·I) and the model faces +Z
(toe +0.125 Z of ankle). Godot: `FORWARD=(0,0,-1)`, `MODEL_FRONT=(0,0,1)` (Vector3.xml L454–477 @4.7.2); glTF front = +Z (spec L708).
Measured: knee offset from hip–ankle line −0.137 @87° flex (crouch), −0.153 @102° (landing); knees flip direction 4× per jump
(tick 1, 9, 52, ~79). AC keyframes (derived FK) put knees +Z in every crouch/landing frame. `fe4c1b1b:713` uses `Vector3.BACK`;
min runtime knee offset now 0.000 (never negative). Staged test asserts knee-forward only during *anticipation* (quality_check
L121–125, knee-forward-of-ankle); landing is unchecked. Proof: `candidate-knees-side.png` (reversed) vs `wip-knees-side.png` (fixed).

**F2 · P1 · OPEN — the airborne phase still reads as "body translating with a fixed silhouette" at the real game camera.**
Translation-removed silhouette IoU vs neutral at 960×720/FOV20/22u/45° (`game-camera-silhouettes.png`):
baseline launch .905 / ascent .917 / apex .935; staged 70ab53 launch .940 / ascent .925 / apex .908. Grounded crouch improved
(.966→.846). Width is 121 px in every pose (hat horns bound it). Root causes: (a) jump keys never touch spine/neck/head
(`fe4c1b1b:689–730` keys Hips, legs, arms only) — AC's hops pitch spine +7…+15° at launch, −10° near apex with +15° head nod,
+3…+13° nod through landing (CLEAR_TABLE1/STANDUP1, derived FK); (b) the only height cue is the sun shadow cast sideways —
AC draws a ground-anchored circle decal under the player (`m_player.c:651` `mAc_ActorShadowCircle`, size 18×18) that shrinks to
60% and fades to 0 linearly over ~101 game units of height (`m_actor_shadow.c:103–118, 179–189, 214–226`, rate 1.0 at L386–388),
and hop clips key the shadow by frame (`climbup_pitfall:141–195`). Fix: actor shadow decal (scale .6+.4x, alpha x, x=1−h/H),
trunk/head pitch keys, AC-like arm drive (below).

**F3 · P1 · OPEN — timing/pose language diverges from AC's own hops and from first-party responsiveness.**
- Takeoff after 0.16 s grounded crouch (`fe4c1b1b:537`). AC: chair/bed crouch 2 frames (0.067 s), table hop 0, boat 5 (0.17 s,
  cutscene); SM64 sets vy on the input frame and runs the airborne action that frame (`mario.c:763–771, 1699–1751`).
- Apex tuck knee 129° (thigh −60°, knee 110° key at .50). AC: legs ~straight in the air (hip–ankle 843–850/850 in SITDOWN1;
  ≤10° until descent in CLEAR_TABLE1). Tuck also stretches the shorts into a "diaper" block (`wip-knees-front.png` t30).
- Landing: pelvis drop .15 u = 28% of hip height, knee ~101°, 0.36 s lock (`:541`). AC: contact cue on contact frame,
  minimum 1 frame later at −10…−18% root height (knee 62–80°), settle ~7–10 frames (0.23–0.33 s). SM64: 4-frame land, then a
  cancellable stop. Celeste: impact squash scales with fall speed, ~0.23 s recovery (Player.cs L2554–2559, L1162–1166).
- Arms: staged apex arm abd 84°/sag 85° is consistent with AC CLEAR_TABLE1 (sag ~90–98°, abd 90–114°) — keep that direction.
  AC anticipation swings arms *back* (−22…−41°) before the forward-up drive (SITDOWN1).
Reference sheets: `ac-hop-clear_table1-fk.png`, `ac-hop-standup1-fk.png`, `ac-hop-sitdown1-fk.png` (joint FK only, no art).

**F4 · P1 · OPEN (changed form) — running jumps.** e5346: planted feet skated 0.63 u during the crouch and 1.10 u during the
landing (body kept 3.15 u/s). 70ab53 freezes horizontal velocity in planted phases (`:557–558`): speed 3.15→0 (tick 0)→3.15
(tick 8)→0 (contact)→3.15 (tick 74); heading frozen (`:569`) then snaps; feet still slide 0.21 u in 2 ticks as the run stride is
blended (.04 s, `:582`) into a symmetric planted stance. Fix: moving jumps keep momentum (SM64 keeps 0.8·forward speed and
adds it to vy), skip/layer the crouch when moving, land into locomotion with a short additive compression; plant stance feet via
runtime IK if needed (Godot 4.7.2 `TwoBoneIK3D`: target + pole node required; mid joint nearest the pole).

**F5 · P1 · OPEN — early/different-height contact pops.** On a 0.45 u platform the pose time jumps .649→.840 in one tick (knee
81°→20°, `:566`), i.e. landing does not start from the displayed pose (the research report warned against exactly this). Fix:
blend from the current flight pose into compression; size compression by impact |vy|.

**F6 · P2 · OPEN — idle arms: clipping fixed, but the idle is frozen.** Baseline: 365 distal-arm vertices inside torso by a
4-direction test (depth .107); the candidate's lateral-only metric counted 105 (3.5× undercount). `.22` lateral clears (0 inside,
gap .042) at 33.4° frontal abduction (baseline 12°). **I withdraw my first read that 33° is "too splayed":** AC WAIT1 (derived FK,
re-run and checked) holds its single-segment arm at 40.8–50.1°. But our idle moves ≤0.1 mm over the whole loop; WAIT1 bobs the
root +5% hip height, sways forward and swings the arms −12°…+16° sagittally over 33 frames (1.07 s). Feasibility sweep
(`idle-arm-feasibility.png`): clearance holds across many angles, so pick the angle for fidelity, not clipping. AC arm has no
elbow — keep our elbow near-straight. Original idle at game camera: `ref-ac/idle-player-zoom.png` (qualitative, 360p).

**F7 · P2 · MOSTLY FIXED in 70ab53 — tool holds.** e5346/baseline: Axe hold 18 vertices inside (depth .025), jump start
teleported the right hand .478 u in one tick, left mitten never reaches the shaft (`candidate-axe-front.png`). 70ab53: 0 inside
(gap only .008), pop .055 u. Remaining: off-hand grip, marginal gap.

**F8 · P2 · OPEN — sole normalization lifts the model during planted phases** (+0.033 u at crouch tick 3, +0.025 at landing):
joint-space interpolation between IK-solved keys pushes soles below the floor between keys, and the root correction then
cancels part of the compression. Bake planted keys per frame or solve IK at runtime; normalization should be ~0 when planted.

**F9 · P2 · OPEN — jump audio/effects.** AC defines `NA_SE_JUMP`/`NA_SE_LANDING` and fires them on frames (sitdown JUMP at start,
standup LANDING f17, boat JUMP f15) — `m_player_sound.c_inc:151–157` + state files. Demo: no takeoff cue; one synthetic landing
cue, always variant 0, fixed −14 dB, surface-agnostic (`:563`). AC hops spawn **no** dust (shadow fade instead), so landing dust
should not be presented as AC-like.

**F10 · P2 · OPEN — tests pass visibly broken animation.** Motion-amount asserts (crouch>.08, impact>.10, tuck>.15, arm_drive>.20)
passed e5346's reversed knees. Missing: landing knee direction, per-tick pop limits, foot-plant drift, momentum continuity,
different-height landing, game-camera readability, takeoff audio. Clearance helper casts world-X rays only (wrong for any heading
≠0/180 and for lean), undercounts, and now returns `minimum_gap: null` instead of failing on zero lateral hits (vacuous pass).

**F11 · P3 · OPEN — hands.** Faceted mittens, thumb notch reads as a "beak" from the front, thin red atlas-bleed seam on the back
of the mitten (`hands-closeups.png`) → UV padding/dilation around the hand island.

**F12 · P3 · NOTE — pipeline facts.** Godot and glTF skin with linear blend only; Blender "Preserve Volume" (dual quaternion) is
not exported; `normalize_idle.py:53` and `rigid_head.py:44` export ACTIONS without forced sampling (constraint-only poses drop);
`correct.py:304` uses NLA_TRACKS (sampled). Re-bake changed only the idle (max bone delta 0.152 on idle hands; walk/run/dash/skid
identical).

Verified non-defect: per-tick `seek(t-δ,false)+advance(δ)` preserves the `play(clip,blend)` cross-fade (empirical: 18.6% after
0.1 s of a 0.5 s fade; source: animation_player.cpp L472–509, L674–725).

## 2. Research report critique (`docs/research/character-rig-jump-techniques-2026-10-01.md`)
Correct: airborne root normalization, contact-driven landing, skinned-surface clearance, mechanisms from GDQuest/TPS/platformer.
Wrong: "omitted properties can blend against rest" holds only with `AnimationMixer.deterministic=true`; default is false in 4.7.2
(AnimationMixer.xml L308–315; animation_mixer.cpp L1162–1217, L1270–1276). Missing first-party evidence now available: AC hop
keyframes/timing/sounds, no scale channel (no squash in AC), AC actor shadow, Vector3.FORWARD vs MODEL_FRONT trap, Godot 4.7
TwoBoneIK3D, SM64 immediate takeoff + short cancellable landing, Celeste impact-scaled squash, glTF LBS-only. Full citations:
`research/primary-sources-round1.md`.

## 3. Reproduction (all read-only; /tmp snapshots)
`tools/opus_probe.gd` (504 poses: clip sweeps, runtime idle/jump/axe-jump/net/run-jump/0.45 u platform), `tools/analyze.py`
(model-space 4-direction inside test, knee offset/flex, abduction, sole height), `tools/opus_silhouette.gd` (IoU),
`tools/opus_closeup.gd`, `tools/opus_hands.gd`, `tools/opus_armgrid.gd`, `tools/opus_seekblend.gd`. Run:
`godot --headless --path <snapshot> --script res://opus_probe.gd -- --variant=<name>; python3 tools/analyze.py <name>`.

## 4. What the next candidate must prove (all at 60 Hz, bound to a build.py stamp + hashes)
1. **Knees:** offset along model +Z ≥ +0.005 u whenever flex ≥10°, every tick of standing, running, tool and platform jumps, incl. landing; no sign flips.
2. **Continuity:** no bone (relative to body) moves >0.06 u in one tick except authored contact frames; no clip-time jump >0.05 s at jump start (idle/run/tool), contact (flat and +0.45 u) or landing end.
3. **Foot plant:** planted-foot XZ drift ≤0.01 u, sole 0…0.005 u; model-root correction ≤0.005 u while planted.
4. **Momentum/latency:** horizontal speed change ≤0.6 u/s per tick on moving jumps; takeoff ≤3 ticks after input (or owner-approved exception).
5. **Landing:** blends from displayed pose at any contact |vy| 1.5–3.6; compression scales with |vy| (≈10–18% hip height at full height); settle ≤0.25 s; movement cancels after ≥4 ticks.
6. **Clearance:** model-space multi-direction inside test = 0 with non-vacuous hits for distal arms vs torso/thighs and hands/props vs head over idle loop, all gait phases, Axe/Net/Receive holds, every jump tick and all blends; min gap ≥0.01.
7. **Readability:** translation-removed IoU ≤.85 at crouch and apex at the game camera, *or* equivalent measured channels (trunk/head pitch ≥8°, actor-shadow scale ≤.9 at apex).
8. **Idle:** animated loop (bob/sway/arm swing within ±50% of WAIT1-derived amplitudes) unless the owner chooses static.
9. **Audio:** takeoff cue at launch ±1 tick; landing cue once at contact; gain by impact speed; none airborne.
10. **Proof:** normal-speed side-by-side vs baseline (standing, running, tool, platform) in game, game-angle zoom, side and front; slow key frames with knee/foot overlay; browser playtest of the served build with pck hash. Prior wrist/blink/appearance/footstep/controller checks must still pass.

## 5. Tool-use receipt
- **ScrapeCreators:** `credit_balance` (24,892; no charge observed) · `youtube_search` "Animal Crossing GameCube pitfall…" (1 credit → 24,891) · `youtube_video` muvFyiBCVxs (1 credit → 24,890). **2 credit-consuming calls, 2 credits ≈ $0.0038** at the highest published rate ($47/25k; endpoint page states 1 credit/request). Cap (≤3 calls, ≤$0.10) respected; third call unused.
- **Bounded media (yt-dlp, no credits):** muvFyiBCVxs 0–20 s and 20–30 s, 360p video-only: 960,376 B (`ce66af62…`) + 690,845 B (`049ffabf…`) = 1.65 MB < 2 MiB. Shows a villager pitfall and the idle player; no player hop. Qualitative only.
- **Scrapling:** make_request ×4 (scrapecreators.com home/anchors, `/pricing` 404, ac-decomp `m_actor_shadow.h`), fetch ×2 (pricing section, docs YouTube-search page).
- **Direct source:** raw GitHub `m_actor_shadow.c` (12,192 B, `1713e7dd…`), `m_player.c` (85,442 B, `ec453c49…`) @09ca8e8b; `gh api` code search ×2.
- **Research subagent:** `research/primary-sources-round1.md` (~1.09 MB text fetched; no ScrapeCreators, no media).
- **Local:** Godot 4.7.2 headless/x11 runs on /tmp snapshots only; numpy/PIL/ffmpeg. No repo, model, provenance, evidence or git writes; no GitHub messages; credential/config files (`mcp.json`, `session.json`, `process.json`) not opened.
