# Issue 235 / 237 — independent review, round 3 (sound package)

Reviewer: Claude Opus 5.5 (`claude-opus-5-5`), maximum effort, session `ab7b9a74-77e4-47fd-8fb1-f1b2919f372a`. This is the same continuous session as rounds 1–2 and the issue-231 rounds. The session was compacted once during this round; every number below was re-read from live files or re-measured, not recalled.

Written 2026-10-01 22:26 EDT. Scope: the sound package and the scoped #237 lint fixes only. Not museum integration, not a production release, not "every Nintendo bank identical".

## Verdict: **REJECT — one build defect (F1). The round-2 blocker E1 is closed.**

1. **E1 passes.** All three published recordings meet all three requirements. The red signal was a clock-measurement error, not missing audio.
2. **F1 blocks.** When the character stops or slows from a run, the same foot sounds twice, about 170 ms apart. It is in the published build and in the published recordings. A one-line change fixes it; I tested that change.
3. **Everything else I checked passes** (§3). Five notes do not block (§4).

Fix F1, re-record, and return to this session.

## 0. What this report is bound to

| Item | Value at 22:21 EDT (unchanged at 22:27) |
|---|---|
| Branch / HEAD | `Reid-Surmeier/character-sound-package` at `317b8f3b8dac0f9811d396bcb0260c7187f93f11`. The package was staged in the git index (not by me); nothing committed. |
| demo.gd | `91f82959d02d5ae5d20e0efedbf42443e8c124fbb37c737578a003154a2e81ec` |
| sound.gd | `27edade82f058379732c7a7bbf80485da30b57d40eb923fb9f27aab76e05166f` |
| audio_check.gd | `4f4f9e8b0cba290e27434dae3665c14d20d4771641cbfadb17afba9141808638` |
| Other package code | locomotion `7ebffe36…`, quality_check `e64f3fbb…`, driven_check `0410f4da…`, controller_check `0fbbdc6a…`, playtest.tscn `d69387e8…` |
| Packager | `scripts/character_package.py` `4cd77e460817486bd878306e1e45918ed0e7728fc8e05bd45c9320219397279e` (threaded export, stream playback, 10 ms buffer, `--serve`) |
| **PCK** | `0963d7d29c55a3e0d5713ef7a175cf4cef0165d564bc4a9472ca193168713302` = local site = `verification.json` = `native-package.json` = `published.json` = served live |
| Live URL | `https://windows-wsl.taile06c45.ts.net/character-sound-live-01a0f3a2/` |
| Recordings | original `f5a2ae187dca86f4…`, stone `f3a8d5be3778fa89…`, adapted `c0f38def6caa5f07…`; served bytes = `published.json` = local files |
| Assets | Six GLBs, hand atlas and eight WAVs equal `verification.json` (15 of 15). Ten code files equal it too. |

The candidate moved while I reviewed. Four builds were published between 21:19 and 21:50: `4e360c78…` (single-threaded, sample playback), `83eb69e8…` (single-threaded, stream playback), `4e360c78…` again, then `0963d7d2…` (threaded, stream playback). The recordings were re-made at 22:08–22:16. Numbers are for the final state unless a build is named.

## 1. E1 — each requirement, on the published recordings

Method: I downloaded the three recordings from the comparison URL, read packet timestamps with ffprobe, decoded each recording's own audio track, and looked for every cue's complete waveform at its audio-clock dispatch time (`t_audio` in `browser-audio*.json`).

| Requirement | original | stone | adapted | Result |
|---|---|---|---|---|
| 1. Packets contiguous; decoded length within 1% of the span | 393 × 20 ms, largest gap 1.0 ms, 99.90% | 393 × 20 ms, 1.0 ms, 99.90% | 396 × 20 ms, 1.0 ms, 99.67% | **PASS** |
| 2. Every event's onset within ±30 ms | 20 of 20, 4.5–16.1 ms | 20 of 20, 13.1–13.2 ms | 19 of 19, 13.1–13.2 ms | **PASS** |
| 3. Peaks below 0 dBFS | −21.5 dBFS, 0 clipped | −19.0 dBFS, 0 clipped | −21.5 dBFS, 0 clipped | **PASS** |

Supporting numbers:
- The cues account for 96.3 / 97.3 / 94.2% of each recording's energy (after Opus coding).
- Each cue's fitted level is 0.89–1.03 of the level the code requested.
- Left and right match (0.00 dB).
- Lowest overlap-corrected correlation: 0.796 / 0.954 / 0.889. The 0.796 is one quiet step 47 ms before the skid; it is present at 0.98 of its requested level.

**Independent capture of the live build** (my own recorder, GPU, audio clock read at each cue's dispatch):

| Profile | Cues within ±30 ms | Delay after dispatch | Output explained by cues | Right vs left |
|---|---|---|---|---|
| House | 20 of 20 | 13.2–16.1 ms | 99.1% | 0.00 dB |
| Stone | 19 of 19 | 13.2 ms | 99.4% | 0.00 dB |
| Adapted | 20 of 20 | 7.3–13.2 ms | 95.8% | 0.00 dB |

No page errors. The delay stays at 13–16 ms even on the two 170–230 ms hitch frames.

### Diagnosis of the red signal

1. **Measurement: the clock.** The earlier alignment mapped cue times onto the audio through a single pairing at capture start. The two clocks drift apart: 23–25 ms within eight seconds on the GPU, 88 ms under software rendering with one 70–100 ms step. On the published recordings the same events give only 14 of 20 and 16 of 20 inside ±30 ms on the performance clock, and 20 of 20 on the audio clock. The earlier "−98 ms" (a sound before its own dispatch) was impossible and came from this.
2. **Measurement: look-alike and overlapping cues.** Only three distinct waveforms exist among the seven captured step clips (§4, N4), and neighbouring cues overlap. A plain correlation picks the neighbour or falls to 0.37–0.86 although the cue is there.
3. **Runtime, older build only.** In `4e360c78…` the browser started each sound when the engine's frame callback returned. Dispatch to start was 6.6–14 ms on the GPU at 57 fps, and about 208 ms on the two hitch frames. Under software rendering at 18.8 fps it was 27–99 ms typically and up to 441 ms. That lag was real and tied to frame time.
4. **Not the 10 ms buffer itself.** But single-threaded stream playback at 10 ms did damage the audio: in `83eb69e8…` only 31.3% of the output matched the cues.
5. **Current build.** Threaded stream playback mixes off the main thread. The delay is a constant 13–16 ms, independent of frame time.

The smallest grounded correction is what the current recorder now does: stamp each cue with the audio clock at dispatch, and fit overlapping cues together. I confirm both. My own first pass also used a single pairing and showed the same false spread (14.6–37.2 ms, 12 of 20); I replaced it.

## 2. Blocker F1 — double footstep when stopping or slowing from a run

**Defect.** `demo.gd:1268` re-arms a foot when its sole rises above `(.05 if state == "Run" else .035)`. The Run clip has a small mid-stance sole bounce: 43 mm left, 36 mm right. Real run swings peak at 100 / 84 mm. While the state is Run, the 50 mm bar ignores the bounce. The state label is speed-based (`locomotion.gd:55–62`: below 3.525 it reads Walk). When the player lets go, speed drops, the label reads Walk, and the body is still blending out of the Run pose. The bar falls to 35 mm, the bounce re-arms the foot, and the same foot cues again.

**Evidence.**
1. Published build, three GPU captures of the scripted run (hold S, release). The last two cues are both Left, 166–167 ms apart: first at run level (phase 0.92), then at walk level (phase 0.12–0.15). House, Stone and Adapted all show it.
2. The published recordings show it. Original: Right at 7.059 s, Right again at 7.175 s. Stone: Right at 7.082 s, Right again at 7.221 s.
3. Native sweep at 60 Hz, 322 gait changes across every release phase:

| Change | Cases | Published scheduler: same foot again within 14 ticks | One 50 mm bar for all gaits |
|---|---|---|---|
| run → stop | 34 | 7 | 0 |
| run → walk (Ctrl pressed) | 34 | 9 | 0 |
| run → dash | 34 | 2 | 0 |
| dash → stop | 27 | 1 | 0 |
| dash → run | 27 | 15 | 15 |
| run → turn, walk → stop, walk → run, start run, start walk | 166 | 0 | 0 |

The 15 dash → run repeats are real re-plants: the foot rises over 50 mm and lands again because the dash and run clips disagree on foot phase. They are inherited, are not F1, and do not block.

**Why the gate missed it.** `audio_check.gd:43` re-uses the scheduler's own thresholds, so it agrees with the scheduler by construction. `audio_check.gd:21–22` forgets the last foot whenever `demo.state` changes, which is exactly the failing case.

**Fix I tested (private copy only).** One pose-based bar for every gait:

```gdscript
			if height > .05 * model.scale.y:
```

Results with that line:
- Zero bounce repeats in the 322 cases.
- 29 cues removed in the sweep; in the per-tick probe every removed cue followed a swing under 45 mm.
- No swing of 60 mm or more lands without a cue.
- Steady Walk (the Ctrl gait), Run and Dash still give exactly one Left and one Right per cycle.
- Body, root and bones are identical over 2,160 ticks.

**Acceptance for round 4.**
1. No same-foot cue within 14 physics ticks unless that sole rose at least 50 mm in between. Cover run → stop, run → walk, run → dash and dash → stop at every release phase.
2. The check measures sole height itself, does not reuse the scheduler's thresholds, and keeps its memory across state changes.
3. Steady Walk, Run and Dash still give one Left and one Right per cycle.
4. The recordings are re-made from the new build and `published.json`, `media-spans.json` and `waveform-alignment.json` are re-bound.
5. The README and research sentences "Run requires a 50 mm lift, Walk/Dash 35 mm" are updated.

## 3. Verified — passes

| Item | Result |
|---|---|
| #237, 3D Viewer | `viewer.gd` equals HEAD byte for byte once two trailing `# gdlint: ignore=…` comments are removed. Comment-only. |
| #237, other edits | `atlas_window.gd`, `walk4.gd`, `main.gd`: comments only. `final_render_check.gd`: two `preload` constants replace four `load()` calls in a private probe. `check.sh` skips `build/`, `.godot/` and `image-work/`. Matches the text of Issue #237. |
| Lint and repository checks | gdlint and gdformat 4.5.0 clean on the package and on the `check.sh` file set. `check.sh` steps 1–3 pass. `git diff --check` clean, staged and unstaged. |
| Native gates, my re-run | Controller, driven, quality and audio checks pass with 0 errors and 0 leaks. Landing continuity 0.0328 and contact depth −7.45e-9, as in approved round 7. |
| Motion | 2,160 ticks of idle, walk, run, jump, dash, skid, stop and steering with no tool, axe and net: package versus the accepted `9a76b8f` scene, largest bone, body and root difference 0. |
| Steady contact timing | Walk, Run and Dash at three travel calibrations: exactly one Left and one Right cue per cycle. Phases: walk 0.82–0.84 / 0.31–0.32, run 0.89–0.92 / 0.39–0.41, dash 0.59–0.62 / 0.09–0.12. |
| Stone clips | Sample-exact crops of the local EmuRetro audio at 605.015, 605.288 and 605.542 s. 16-bit PCM, lossless import, first played sample at most 0.6% of peak, peak kept. |
| Levels | Native peaks at Run: House right −32.1 and left −23.4 dBFS, Stone −20.8 and −22.7, Adapted −24.3. No clipping in any capture. |
| Export | An untouched copy of the build project re-exports to the same PCK byte for byte. |
| Live URL | Sends both isolation headers, `crossOriginIsolated` is true, ready in 4.4 s, no page errors. |
| Sound button and images | Cycles original house → original stone → adapted surfaces at 800×600 and at 390×844. The bridge strings match. The three current stills I opened (original idle, stone running, adapted idle) show the right label and an intact render. |

## 4. Notes — not blocking

**N1. Integration risk for #236.** The module is only proven in a threaded export with stream playback and isolation headers.
- The museum's three web presets are all single-threaded and `project.godot` has no audio override, so the museum would use sample playback.
- In sample playback with this module's polyphonic player, every cue is 4.65 dB louder on the right. Measured on build `4e360c78…`: left 0.999 and right 1.706 of the requested level. The engine's sample bus also feeds the signal into channel 5, and Chrome's stereo down-mix adds 0.707 of that to the right.
- Single-threaded stream playback at 10 ms breaks up (§1, point 4).
- Tested alternative if the museum stays single-threaded: sixteen plain `AudioStreamPlayer` voices in place of the polyphonic player. Result: channels 0 and 1 only, right equals left, 17 cues gave 17 starts, 99.1% explained, tails still overlap, re-attach works, a 40-cue burst is clean, motion identical.

```gdscript
func play_cue(stream: AudioStream, offset: float, volume_db: float, pitch: float) -> int:
	var voice: AudioStreamPlayer = voices[voice_next % voices.size()]
	voice_next += 1
	voice.stream = stream
	voice.volume_db = volume_db
	voice.pitch_scale = pitch
	voice.play(offset)
	return voice_next
```

**N2. Stray files inside the published PCK.** `contact-probe.json` and `foot-heights.json` (probe outputs left in the build project) and `modules/shell/character/provenance.json` are packed. The exclude entry `provenance.json` does not match a full path; `*provenance.json` would. The packager never cleans the build project, so a clean clone would produce a different PCK hash than the published one.

**N3. The old link is broken.** `https://windows-wsl.taile06c45.ts.net/character-sound-01a0f3a2/` still answers, serves the threaded build without isolation headers, and shows Godot's "Cross-Origin Isolation … SharedArrayBuffer … missing" error. Remove it or point it at the live URL.

**N4. House and Stone are the same two samples.**
- house b = house d = stone b (correlation 0.973–0.984).
- house c = stone a = stone c (0.988–0.992).
- house a matches nothing else (0.32 at most).
- Two independent YouTube captures agreeing this closely is good evidence that these are real game samples. It also means "original house" and "original stone" are one two-sample bank at different levels.
- In the House profile most right steps use clip a, which is 8.7 dB quieter (−38.1 versus −29.4 dBFS) and duller than the left steps. Stone is even within 1.8 dB. Please record this in `PROVENANCE.md`; keeping both profiles is the owner's call by ear.

**N5. Evidence polish.**
- The recordings are 800×600 at 16.8–18.4 fps with frame gaps up to 163 ms, because Chrome ran on the software renderer. The sound is exact; the picture is coarse.
- The GPU works headless on this machine: environment `GALLIUM_DRIVER=d3d12 MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA LD_LIBRARY_PATH=/usr/lib/wsl/lib`, Chrome flags `--use-gl=angle --use-angle=gl-egl --ignore-gpu-blocklist`, `headless: 'new'`. I measured 57 fps that way.
- My GPU probes overlapped the 22:12–22:14 captures and may have cost them frames.
- `browser-audio*.json` carry no PCK hash or URL. Add both.

## 5. Declared limits

1. **Scope.** Sound package and #237 only. Museum integration, release, and the inherited Shell fixture failures were not re-run this round.
2. **Browsers.** Headless desktop Chrome only, on the GPU and on the software renderer. No phone, Safari or Firefox; the threaded build on iOS is untested. Timing is measured inside the audio graph; a real device adds its own output latency.
3. **Sources.** Unchanged from round 2: YouTube AAC captures with unknown bank IDs. Skid, jump, landing and door-opening sounds remain authored.
4. **My fixes.** The F1 and N1 changes were tested only in a private copy. The root's implementation needs its own review.
5. **Inherited, not re-opened.** Dash-entry bounce, dash → run re-plants, two 170–230 ms hitch frames (first dash dust, after the skid), platform-lip perch, faceted mittens, unmipmapped hands.

## 6. Evidence kept

All under `build/character-review/opus-round3/` (git-ignored). Not pruned: file deletion was not permitted in this session. Safe to delete there: `web-S1/`, `web-repro/`, `web-fix/`, `project/`, `repro-project/`, `accepted-project/`, `published/`, `*.f32`, `emu-601-611.wav`, `motion-*.json` and the raw `contact-{S1,fixA,fixB,prev35}.json` (about 330 MB together).

- **E1:** `verify_published.py`, `published-verification.json`; `r3_clock.cjs`, `analyze_clock.py`, `clock-live-{house,stone,adapted}-analysis.json`.
- **Red-signal diagnosis:** `r3_browser.cjs`, `analyze_browser.py`, `browser-{gpu-house,sw-house,gpu-stone,gpu-adapted,gpu-stream83eb,gpu-threads-stream,sw-threads-stream}-analysis.json`.
- **F1:** `r3_sweep.gd`, `analyze_sweep.py`, `sweep-{S1,prev35,fixA,fixB}-summary.json` (+ raw `sweep-*.json`); `r3_contact.gd`, `analyze_contact*.py`, `contact-*-summary.json`, `contact-*-transitions.json`; `variants/demo_fixA.gd`.
- **N1:** `r3_channels.cjs`, `channels.json`, `browser-gpu-fixB-analysis.json`, `r3_voices_native.gd`, `voices-native.log`, `variants/demo_fixB.gd`.
- **Gates and lint:** `native-{controller,driven,quality,audio}.log`, `check123.sh`, `check123.log`, `r3_motion.gd`, `fmt/`; `load-live.txt`, `load-old-final.txt`, `mobile-three-profiles.png`.

To repeat the sweep, run it against a copy of the build project so nothing lands in the export: `godot --headless --fixed-fps 60 --path <copy of build/character-package/project> -s build/character-review/opus-round3/r3_sweep.gd -- --tag=<name> --out=<absolute path of build/character-review/opus-round3>`, then `python3 build/character-review/opus-round3/analyze_sweep.py <name>`.

## 7. Tool receipt

- **Model:** Claude Opus 5.5, maximum effort, session `ab7b9a74-77e4-47fd-8fb1-f1b2919f372a`, existing subscription.
- **Paid:** none. ScrapeCreators 0 calls this round (cumulative 2 of 3, about $0.0038). No generation, no footage or ROM downloads.
- **Network:** the public tailnet URLs only (PCK hash streams, three recordings of about 0.4 MB, pages); about 30 headless Chrome sessions; read-only `gh issue view` for #235 and #237. One transient `ERR_CERT_VERIFIER_CHANGED`, retried.
- **Local:** Godot 4.7.2 headless probes and three private web exports in scratch; two local servers on 127.0.0.1:9871 and 9872, both stopped; gdtoolkit 4.5.0 from the existing local venv.
- **Writes:** this report and scratch only. No tracked file edited, no git or GitHub write, no credentials or configs read. One slip, corrected: for about two minutes (21:54–21:57) two of my files sat in the repository root and six small CSVs in `/tmp`; all were moved into scratch.
