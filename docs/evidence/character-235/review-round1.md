# Issue 235 — independent review of the character package and original-sound increment

Reviewer: Claude Opus 5.5 (independent; same session as the issue-231 reviews). 2026-10-01.
Worktree reviewed: `character-sound-package`, untracked package `modules/shell/character/`, plus `scripts/character_package.py`. Baseline is the accepted prototype commit `9a76b8f997d1b8243c2f5f6275a5c2a92e22d888` (round-7 approved scene).

## Verdict: **REJECT** — two blocking defects (B1, B2) and one merge-gate item (M1)

The packaging is faithful:
- Motion, geometry, rig and textures are identical to the approved prototype.
- The four step captures are clean, unmodified and well engineered.

Two things need fixing before a scoped approval:
- **B1:** the captured door-close cue is trimmed *after* its slam peak.
- **B2:** the audio teardown in `_exit_tree` breaks the character after any detach/re-attach.

M1 (the lint gate) must be resolved before merge. Each fix is small.

## 0. Binding (verified)

| Item | Result |
|---|---|
| Accepted baseline | `git show 9a76b8f:` gives demo.gd `4823db46…` (= round-7 scene), locomotion `722745a0…`, sound.gd `b1399871…` |
| Package demo.gd | `86973bfb7d65b7b9865cff4a5319ff9ef225df420b0dad8c6dd0ab42ef0a96b6` |
| Package sound.gd | `b1305f451abf661db8bc67337bffb2b2879703bf27a91351c034135703142a3a` |
| Package locomotion.gd | `722745a0…` (unchanged) |
| Package audio_check.gd | `e7dab7f2…` |
| Package playtest.tscn | `d69387e8…` |
| Package provenance.json | `e1c4a00f…` |
| scripts/character_package.py | `bfc388a4…` |
| GLBs and hand atlas | Byte-identical to `provenance.json` and to the accepted prototype (walk `7345fcdc…`, run `f752810d…`, dash `85267be2…`, skid `211afac6…`, axe `c84ea317…`, net `620690d7…`, atlas `61a76e1d…`) |
| Audio | step_a `6f17e6df…`, step_b `79a1eaf9…`, step_c `1fa77382…`, step_d `f6ac206b…`, door_close `3deaff72…` — all equal to `provenance.json` |
| Build copies | `build/character-package/project` copies of demo.gd, sound.gd, audio, GLB and atlas equal the package source |
| PCK | `verification.json` `pck_sha256` = local `site/index.pck` = streamed served `…/character-sound-01a0f3a2/index.pck` = **`2a4bcc377c0da2440fda8ffcb50849c495e41127b3c1492e66d3945097129307`** |
| Native logs | controller, driven, quality and audio PASS; import and export clean (0 `ERROR` in export.log) |
| Tracked changes | `modules/shell/MODULE.md` (documentation only) and `scripts/check.sh` (excludes `build/` and `.godot/`). No Shell interface, error or acceptance file changed. |

## 1. Source claims (verified)

1. **The five clips are sample-identical to my own independent crops.**
   - I decoded the local 30 s excerpt `malo-house-376-406.mp4` (sha256 `b56970994b928f081fba8efcbd1212ee19c149dee037f1d3027713b6cd07ba9f`) with ffmpeg to mono 22,050 Hz.
   - Cropping at `int((t−376)·sr)` with the stated timestamps reproduces all **5/5** files byte for byte.
   - "Unmodified AAC-decoded crops" therefore holds. Mono 16-bit at 22,050 Hz; 4,079–4,080 frames (185 ms); the door clip is 11,907 frames (540 ms).
2. **Peaks:** −38.1 / −29.4 / −32.8 / −33.4 dBFS for the steps; −13.7 dBFS for the door. They match the research note.
3. **Onsets:**
   - The research's first two contact onsets (388.908 s and 389.178 s) agree with my RMS onsets (388.9096 s and 389.1799 s).
   - The contact sheet shows the empty checkerboard house, the inactive boombox and the upward traverse. The floor identity and anatomical side are correctly left unknown.
4. **Hedging is appropriate:** no archive WAV is promoted, there is no recovered bank or ID claim (`id=-1`), `requested_id`/`requested_bank` are kept separately, and the floor is labelled unidentified.

## 2. Engineering checks

**Steps — PASS:**
- **Alignment:** start offsets of 15/15/16/15 ms land 1.5–2.5 ms before the measured attack (RMS onset 16.6–16.9 ms). The first played sample is ≤0.5% of the clip peak, so there's no click.
- **Tails:** the last 10 ms sit 33–39 dB below the body, and the final sample is ≤0.5% of peak. No end click and no truncation.
- **Native mixer probe** (`tools/opus_r235audio.gd`, real-time capture through the package's own `footstep()` path):
  - Run steps reproduce the clip peaks within ±0.2 dB.
  - Walk and Dash sit exactly −2.5 / +1.9 dB from Run (0.54/0.72/0.9).
  - The attack arrives 2.4–3.0 ms after the cue starts. Pitch is 1.0.
- The gain arithmetic is exact: 14 − 20·log10(0.72) = 16.853 dB, so indoor Run plays at capture level.

**Polyphony and tails — PASS:** a single `AudioStreamPolyphonic` with 16 voices. New cues don't cut earlier tails; this is exercised by `audio_check.gd`, and my probe shows full tails.

**Grounded-only steps; one launch, landing and skid — PASS** (code path and native check).

**Serialization — PASS:** bridge events carry `audio_profile` and the last 8 `audio_events` (bank, source, requested id/bank, playback_id, time, foot, stage, on_floor). Stream resources are erased before history.

**A/B toggle — PASS natively and on the served build.** My headless-Chrome tap of the real AudioContext output (1 context, 0 page errors):
- "original house" plays captured a/b steps; after clicking the button, "adapted surfaces" plays authored `Path` steps.
- Both profiles are audible.

**Motion, geometry and regressions — PASS (identical):**
- The demo.gd diff is limited to resource paths, the audio routing, the sound button, bridge fields and `_exit_tree`.
- My 686-jump contact sweep on the package project is **bit-identical to approved round 7 in 686/686** rows.
- The 23-scenario probe plus Receive is identical in 24/24, and the skinned mesh dump (6,262 vertices, indices, weights) is identical.
- No geometry, regrip or jump change is possible or observed.

**Mobile UI (`mobile.png`, 390×844) — PASS:** a readable control panel with the full-width "Sound: original house" button, a D-pad and Jump/Sprint touch buttons. Nothing covers the character.

## 3. Blocking defects

### B1 · Door-close capture is trimmed after its slam peak

`demo.gd:551` plays `house_door_close.wav` from **0.0343 s**. The clip's measured envelope (2 ms windows):

| Time in clip | Peak level | What it is |
|---|---|---|
| 24–26 ms | −30 dBFS | attack begins |
| 26–28 ms | −20.9 dBFS | attack rising |
| **30.4 ms** | **−13.7 dBFS** | **sample peak** |
| 34–36 ms | −20.4 dBFS | where playback starts |

**Effect:**
- Playback begins on a sample at **−46% of the clip peak**, so the cue starts with a step discontinuity.
- The attack and primary peak (**25.1% of the clip's energy**) are never heard.
- In the native mixer the played maximum is a later −15.9 dBFS bang at +20 ms, and the onset is abrupt (attack +0.0 ms). Every step cue has a 2–3 ms rise by comparison.

**Cause:** the research note and provenance state the dominant transient as 386.5243 s. The measured sample peak is **386.5204 s**, with the attack from about 386.514 s.

**Fix:**
- Start at about **0.024 s**, just before the attack. The pre-attack residual there is about −37 dBFS.
- Optionally trigger the cue about 6 ms earlier so the true peak meets the DoorShut milestone.
- Correct the transient time in `provenance.json`/PROVENANCE.md and the research note.

**Acceptance:**
- First played sample ≤5% of the clip peak.
- Played peak = clip peak (−13.7 dBFS at unity), with the attack within about 3 ms of cue start.
- Assert this in `audio_check.gd` (captured-door first-frame and peak relation).

### B2 · `_exit_tree` destroys audio state; detach and re-attach breaks the character

`demo.gd:1028–1031` stops the player, nulls the polyphonic playback and clears all synthesized and captured streams on *any* tree exit.

**Repro** (`r235/pkg/opus_r235reattach.gd`, now pruned): detach and re-attach the character node, as a reparent or page remount would.
- After: playback is null, 0 of 128 synthesized streams and 0 of 4 captured streams remain, and the player isn't playing.
- The next action cue raises `SCRIPT ERROR: Invalid access to property or key 'Jumpfalse0'`. Footsteps would fail the same way.

**Scope:** today's Shell hides and freezes pages (`shell.gd:138,154`), so the current playtest doesn't hit this. But the package is explicitly prepared to replace the Collection visitor.

**Fix:** tear down in `NOTIFICATION_PREDELETE` (object destruction), or rebuild in `_enter_tree`.

**Acceptance:**
- A detach/re-attach probe plays steps and actions with no script errors.
- `audio_check.gd`'s free-and-drain stays clean, with no resource or leak errors.

## 4. Merge gate

### M1 · gdlint

CI installs `gdtoolkit==4.*` (`.github/workflows/verify.yml:25–26`). `scripts/check.sh` lints every `.gd` under `set -euo pipefail`.

With gdtoolkit **4.5.0** in a temporary `/tmp` venv:
- The package adds **200 problems**: 197 `max-line-length`, plus `max-public-methods`, `max-file-lines`, `functions` and `class-variable-name`.
- Tracked files already fail with 8, and recent Verify runs on `build/v0.1.0` are red.
- Locally gdlint isn't installed, so `check.sh` skipped lint silently.

**Fix:** either reformat the package scripts, or obtain Issue-scoped lint exclusion as #216 did for Mixbox. The Issue needs to name it.

## 5. Non-blocking findings (fix or record)

**N1 · Mix calibration** — the owner should listen.
- Original-house steps play at −27.6 to −40.6 dBFS peak and **−47 to −55 dBFS RMS(100 ms)**.
- That is about 9 dB quieter than the adapted steps they replace (−38 to −44 RMS).
- It is **6–21 dB** below the authored action cues: jump −41, landing −37, skid −34 and door creak −36 dBFS RMS. The captured door close is −29.5.
- The browser tap shows the same relationship.
- "Capture level" is anchored to an arbitrary YouTube master. A single uniform make-up gain applied to *all* captured cues (steps and close together) would preserve every source-relative level while making the steps audible against the authored cues.

**N2 · Lossy import.** The WAVs import with Godot's default `compress/mode=2` (QOA, lossy). The measured effect is small (output peaks within ±0.2 dB), but it contradicts "unmodified" at runtime. Also, `character_package.py` ignores `*.import`, so WAV import settings come from defaults. Use `compress/mode=0` and keep the WAV `.import` receipts with the package, as the GLB receipts are.

**N3 · Provenance text.** Besides the B1 transient time, the door's `processing` and `identification` strings in `provenance.json` are missing spaces ("AAC-decodedmono22050Hz…").

**N4 · Browser evidence.**
- The recordings are 5.5 s and 4.0 s and cover only the first run segment.
- `browser-audio.json` metrics and events use different clocks (about 1.4 s apart), so the evidence can't show sync.
- Add aligned markers. My own tap confirms audibility and the toggle.

**N5 · Appearance gate.** The package's appearance step only captures images. The prototype's `appearance_check.py` pixel-equivalence gate isn't included. Risk is low because the material and mesh code is unchanged apart from paths.

## 6. Remaining limits (declared; not defects of this increment)

- **Not recovered:**
  - The floor bank/ID behind the captured footsteps.
  - Outdoor terrain banks.
  - Skid, jump/landing, door opening and latch (all still authored).
  - Music, Animalese, ambience and room reverb.
- **Source quality:** the captures are YouTube AAC recordings, not soundbank masters, and the variant-to-slot assignment isn't Nintendo's.
- **Jump:** general jumping remains an added ability.
- **Inherited character P3s** remain: dash-entry bounce, platform-lip perch, faceted mittens, unmipmapped hands.
- **Still open:** audible owner acceptance, exact Animal Crossing fidelity and production/museum integration. This review is a scoped package/audio review, not release sign-off.

## 7. Evidence (all in /tmp/character-opus-review; raw snapshots and media pruned)

- **Native mixer probe:** `r235/audio-probe.json` (38 cue measurements, both profiles), from `tools/opus_r235audio.gd`
- **Browser tap:** `r235/browser/tap.json` and `desktop.png`, from `tools/browser_r235tap.cjs`
- **Contact sweep:** `probe-out/r5-contact/pkg235.json`
- **Probe metrics:** `probe-out/r235-pkg/bones3.json`
- **Lint outputs:** `r235/gdlint-package.txt`, `r235/gdlint-tracked.txt`
- **Accepted scripts:** `r235/accepted/` (extracted read-only from `9a76b8f`)

## 8. Tool receipt

- **ScrapeCreators:** **0 calls** (cumulative 2/3, ≈$0.0038). No generation or paid calls.
- **Network:**
  - one streamed hash of the served PCK
  - two headless-Chrome sessions on the served build
  - one read-only `gh run list`
  - `pip install gdtoolkit 4.5.0` into a temporary `/tmp` venv (free; removed)
- **Media:** no new media downloaded; I decoded only the research worker's existing local 30 s excerpt.
- **Writes:** none tracked, and no git or GitHub writes; no credentials or configs read. Private `/tmp` package snapshot, venv and decoded WAVs removed.
