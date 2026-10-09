# Issue 235 — independent review, round 2 (character package and original-sound increment)

Reviewer: Claude Opus 5.5 (same continuous session as round 1 and the issue-231 rounds). 2026-10-01.
Scope: package/sound increment only. Not production release; not "all Animal Crossing sound identical."

## Verdict: **REJECT — one evidence-only blocker (E1)**

Everything in the package itself now passes: code, assets, import, export, binding, and every round-1 item (B1, B2, M1, N1–N3, N5).

The one remaining defect is in the **published comparison recordings** that the owner will listen to:
- Their audio tracks are missing **26% and 37%** of the timeline.
- Meanwhile the compare page says "Both videos record actual browser audio."
- The real browser output is continuous; I tapped it on the audio thread.

No code change is needed. Re-record (or relabel) and I will approve.

## 0. Binding (verified)

| Item | SHA-256 / result |
|---|---|
| demo.gd | `18d9bffcfb10f920baaac86ee67345fea121cd31bfd9d36faec305b4d6825872` |
| sound.gd | `815ca8dc72adfde0d6b9ea10bf08bf041069036e8e53e7d62ad755c43eb90cac` |
| locomotion.gd | `7ebffe36eec34caa1ee132c78eee75c5cdf49c8d7fb60ccce90c3c3bd51d1203` (gdformat only) |
| audio_check.gd | `d1a9f2f18ab5d15fd3090a633ace0c453b7f0607ee4cdbaa7f7f340f3c777dc4` |
| Other scripts | quality `3073e6e3…`, controller `0fbbdc6a…`, driven `f2ba1414…`, appearance `df8f4d30…` / `.py` `1ef2695c…`, tool_clearance `74c0c52d…`, record `30e8511d…`. All equal `verification.json` `package_code_sha256` and the build copies. |
| Packager | `scripts/character_package.py` `2b4b6424ec89acd7a1da57025358abd16e8592ee1628c9bdbabcaacb6434f50e` |
| provenance.json | `24d10e36ba608daa6b94e44c51c014aa85a8610c3653113fb9e855e9e94cc5aa` |
| PROVENANCE.md | `f763b94e5f6e2b5bc561abc170e597220ead317871d93996c1f313660c17d9ba` |
| Assets | Unchanged bytes: six GLBs (walk `7345fcdc…`, run `f752810d…`, dash `85267be2…`, skid `211afac6…`, axe `c84ea317…`, net `620690d7…`), hand atlas `61a76e1d…`, clips `6f17e6df…` `79a1eaf9…` `1fa77382…` `f6ac206b…` `3deaff72…` |
| WAV import receipts | Tracked, all `compress/mode=0` (lossless PCM), trim/normalize off, no loop. door `b2f4b053…`, a `7c066282…`, b `1df609f1…`, c `319ecbca…`, d `cc69b7fb…` |
| GLB receipts | 240 fps, optimizer off (`verification.json` `animation_import_sha256`) |
| **PCK** | `ec637ce1cece5af4e1c587b39d19122c03aa80e36483c0506d3ef1ada3b4b169` = local `site/index.pck` = `verification.json` = `published.json` = **streamed live** `…/character-sound-01a0f3a2/index.pck` |
| Compare page | `…/character-sound-compare-01a0f3a2/` serves exactly `published.json`: index `87560b00…`, original-synchronized.webm `cb7e8fe4…`, adapted-synchronized.webm `c19161a9…`, reference WAV `39699e38…` |

## 1. Round-1 items — status (independently re-measured)

| # | Status | My evidence |
|---|---|---|
| **B1** door trim | **FIXED** | `demo.gd` plays the close from 0.024 s. Native mixer capture: first frame ≈0% of peak, attack +1.5 ms, played peak −7.7 dBFS = clip peak −13.7 + 6 dB makeup, reached 6.5 ms after start (30.4 − 24 ms). `audio_check.gd:95–105` asserts 16-bit PCM, start sample ≤5% of clip peak and remaining peak == whole peak. |
| **B2** lifecycle | **FIXED** | Stop on `NOTIFICATION_EXIT_TREE`, clear only on `PREDELETE`, and `foot_audio.tree_entered` → `_resume_audio`, connected after the first play so it fires only on re-entry. After two detach/re-attach cycles: playback valid, 128 + 4 streams intact, player playing. Grounded footsteps play captured steps through the real mixer (peak 0.0504), the jump plays (0.0558), and free + 150 ms drain gives **0 errors or leaks**. `audio_check.gd:76–92` asserts actions and footsteps after a remount. |
| **M1** lint | **FIXED** | gdlint/gdformat **4.5.0** (what CI's `gdtoolkit==4.*` resolves to): package **0 problems**, gdformat-clean; tracked + package **0 problems**; `check.sh` steps 1–3 (module map, seams, lint) **pass** on the worktree; `git diff --check` clean. |
| **N1** mix | **ADDRESSED** | A common +6 dB `CAPTURED_MIX_DB` applies to captured steps **and** close only (`sound.gd:33,118`, `demo.gd:763`). Gait gains (−2.5/0/+1.9 dB) and pitch 1.0 are unchanged; authored jump/landing/skid levels are unchanged. Live tap: original steps now near the adapted ones (median transient −40.6 vs −37.7 dBFS); no clipping. |
| **N2** import | **FIXED** | PCM receipts tracked via `.gitignore` negation; packager carries and asserts them. |
| **N3** provenance text | **FIXED** | Door identification: "dominant transient at 386.5204 s"; spacing corrected; research note updated. Makeup, PCM and the 24 ms start are documented in PROVENANCE.md. |
| **N5** appearance gate | **FIXED** | `appearance_check.py` is reused by the packager. Metrics: color error 0.025/255, 6 blink levels, 0 outside-face, 0 blue bleed, dust visible. |
| **N4** browser evidence | **NOT FIXED → E1** | See §2. |

**Motion, geometry and regressions after gdformat — identical.**
- Normalising the accepted `9a76b8f` scripts and the package with the same gdformat shows locomotion with 0 differences.
- demo.gd and sound.gd differ only in: paths, audio routing/offsets/makeup, the sound button, bridge fields, the `_notification`/`_resume_audio` lifecycle, a split temporary variable, line-wrapped GLSL inside shader strings, comments, and the playtest lint header.
- My 686-jump contact sweep is **bit-identical to approved round 7 (686/686)**.
- The 23-scenario probe plus Receive is **24/24 identical**, and the skinned mesh dump is identical.
- `quality_check.gd` re-run independently: PASS, landing continuity 0.0328, contact depth −7.45e-9, both identical to round 7. `audio_check.gd` re-run: PASS, 0 errors.

**Steps (unchanged engineering, re-measured):** attack 2.5–3.1 ms after cue start; first sample 0%; full 170 ms bodies and tails. Run b −23.4 / a −32.1 dBFS peak, which is the clip peak +6 dB.

## 2. Blocker E1 — the published comparison recordings drop large parts of the audio

**What I measured** (`ffprobe` packets, `published.json` files, `media-spans.json` claims):
- Every Opus packet is exactly **60 ms**, but timestamps jump.
- `original-synchronized.webm`: 110 packets = **6.60 s of audio over an 8.54 s span**. That is **28 holes totalling 2.25 s (26%)**, the largest 0.50 s (6.35–6.85 s, 7.26–7.75 s, 5.64–6.13 s).
- `adapted-synchronized.webm`: 88 packets = **5.28 s over 8.24 s**, with **27 holes totalling 3.09 s (37%)**.
- A timestamp-respecting decode is 8.47 s long, with silence in the holes. A plain decode is only 6.60 / 5.28 s, so sync drifts.

**Effect on events** (common clock `t` from `browser-audio*.json`):
- Onsets inside holes: original **1/18** (a step at 5.56 s); adapted **6/18**, including **its Jump** (6.11 s) and 5 steps.
- Other cues lose tails.
- The "before vs now" A/B is therefore incomplete and biased.
- "Packets span 8–9 s" is true of the first and last timestamps, not of continuity.

**Not a build defect** — my AudioWorklet tap on the live build ran on the audio thread, immune to page stalls:
- 9.10 s of samples over a 9.15 s context span.
- **All 17 steps play their full 170 ms**, including 3 steps overlapping deliberate **0.4 s main-thread stalls**. Jump plays 85 ms and landing 100 ms.
- Steps land every 0.27–0.28 s; peak −17.6 dBFS; 0 clipped; 0 page errors.
- A second ScriptProcessor tap on the live build confirms both profiles are audible and the toggle works.

**Required fix:**
- Re-record both profiles through a gap-free audio path: for example, the audio-thread PCM tap written to WAV and muxed offline with the canvas frames on the same clock, or Godot `AudioEffectRecord`.
- Or remove the "actual browser audio" claim and point the owner at the live build.

**Acceptance:**
1. Audio packet timestamps are contiguous (no gap larger than one packet), and the decoded duration is within 1% of the span.
2. Every Captured/Path, Skid, Jump and Landing event in `browser-audio*.json` has an output onset within ±30 ms in the recording.
3. Audio peaks stay below 0 dBFS.

## 3. Notes (non-blocking)

1. **#237 touches the 3D Viewer.** `modules/sculpture_viewer/viewer.gd` (the 3D Viewer Tab) changes three `load()` calls to one `preload` constant. It is behavior-equivalent (same cached Shader).
   - Earlier owner guidance recorded in this workspace says the 3D Viewer must not be changed.
   - A comment-only `# gdlint:ignore=duplicated-load` would avoid editing it. Please confirm explicit scope or owner sign-off in #237.
   - The other #237 edits are fine: comment-only `max-returns`/`max-file-lines` regions, and a behavior-equivalent preload in the prototype `final_render_check.gd`.
2. **Duplicated constant.** The door start offset `.024` is hard-coded in both `demo.gd` and `audio_check.gd`; share one constant so the test follows the cue.
3. **Inherited Shell fixture failures** (`scripts/playtest.sh shell`):
   - Base `317b8f3b`: 7 FAILs. Package worktree: 6 FAILs. Both fail pressed-tint, dip, tenant area, flowers grey and resize.
   - They differ only in timing checks: the base also fails cross-fade greys and collection dip; the package run fails settle-time (142 ms vs the 150 ms floor).
   - Cause: load-dependent timing. The fixture uses dummy tenants, never loads the character, and the Shell's code is unchanged except MODULE.md. Record as inherited and re-run on an idle machine before any release; the build is not production-ready on that fixture.
4. **Environment hiccup:** one browser attempt hit a transient Chrome `ERR_CERT_VERIFIER_CHANGED`; the immediate retry succeeded.

## 4. Remaining limits (declared)

- **Captures:** the house captures are YouTube AAC recordings. The checkerboard floor's bank/ID is unknown (`id=-1`), and the variant-to-slot assignment isn't Nintendo's.
- **Not recovered:** outdoor terrain banks, skid, jump/landing, door opening/latch, music, Animalese, ambience and reverb. The authored cues remain adaptations.
- **Mix:** the +6 dB makeup is a mix choice, not the original engine's master volume.
- **Jump:** general jumping is an added ability.
- **Still open:**
  - additional clip research (no guessed samples promoted)
  - audible owner acceptance
  - exact original fidelity
  - museum integration: the package does not yet replace `visitor159`
  - production release, including the inherited Shell fixture failures
- **Inherited character P3s:** dash-entry bounce, platform-lip perch, faceted mittens, unmipmapped hands.

## 5. Evidence (in /tmp/character-opus-review; raw snapshots and media pruned)

- **Native mixer probe:** `r235/audio-probe-round2.json` (also `audio-probe.json`), `r235/audio-probe2.log`
- **Remount probe:** `r235/reattach2.log`
- **Gate re-runs:** `r235/my-audio-check.log`, `r235/my-quality-check.log`
- **Sweeps:** `probe-out/r5-contact/pkg235r2.json`, `probe-out/r235-pkg2/bones3.json`
- **Lint and checks:** `r235/check123.log`, `r235/fmt/` (gdformat-normalised accepted vs package)
- **Packet analysis:** `r235/pk-{original,adapted}.csv`
- **Browser taps:** `r235/browser/worklet-summary.json`, `r235/browser/tap2.json`

## 6. Tool receipt

- **ScrapeCreators:** **0 calls** (cumulative 2/3, ≈$0.0038). No generation, no paid calls.
- **Network:**
  - one streamed live-PCK hash
  - small `curl` reads of the published compare files (webms 290–330 KB, reference WAV 265 KB, page)
  - four headless-Chrome sessions on the live build (one transient cert error, retried)
  - `pip install gdtoolkit 4.5.0` into a temporary `/tmp` venv (free; removed)
- **Writes:** read-only on tracked files; no git or GitHub writes; no credentials or configs read. My probes ran on a `/tmp` copy of the build project, and the `check.sh` steps 1–3 replica ran read-only against the worktree.
