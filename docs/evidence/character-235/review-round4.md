# Issue 235 / 237 — independent review, round 4 (sound package)

Reviewer: Claude Opus 5.5 (`claude-opus-5-5`), maximum effort, session `ab7b9a74-77e4-47fd-8fb1-f1b2919f372a`, resumed. This is the same continuous session as rounds 1–3 and the issue-231 rounds. I read `review-round3.md` from disk first (hash `d452f0418a143d52…`, unchanged).

Written 2026-10-01 23:59 EDT. Scope: the sound package and the scoped #237 lint fixes only. Not museum integration, not a production release, not "every Nintendo bank identical".

## Verdict: **APPROVE_SOUND_PACKAGE**

1. **F1 is fixed as specified.** All five round-4 acceptance items pass on my own measurements (§1).
2. **The refreshed recordings pass all three E1 requirements** and are bound to the new build (§2).
3. **Two small side effects of the single 50 mm rule remain.** They follow from the rule I proposed in round 3. They do not block, but the owner should know them before listening (§3).
4. **Nothing else regressed.** Motion is byte-identical, all gates pass, the audio path is unchanged (§4).

## 0. What this report is bound to

| Item | Value (unchanged from 22:49 to 23:57 EDT) |
|---|---|
| Branch / HEAD | `Reid-Surmeier/character-sound-package` at `317b8f3b8dac0f9811d396bcb0260c7187f93f11`. The package is staged in the git index (not by me); nothing committed. |
| demo.gd | `001c3d528780816c7492ea1377e1f2fb7fe25af668cf3aaa7af48ca4190e3899` |
| contact_check.gd (new) | `1afd60586d3daeb2a355db2c7ec6257ff8abb3b9ef94479665f5e2094ae47555` |
| audio_check.gd | `08acced35b6d456a84c75f6566664e0389f119bfb08fb412e40d810eef96ff98` |
| Unchanged since round 3 | sound.gd `27edade8…`, locomotion.gd `7ebffe36…`, quality, driven and controller checks, playtest.tscn, all assets and import receipts |
| Packager | `scripts/character_package.py` `76f56aabbd2a82ebb9ca80cb2e0767df91c9747cf5b56e1b4ded07ae7d7304fd` |
| **PCK** | `7951713bf47a4eb9b71779bb1256020cb06d006c30766c32571b259180562245` = local site = `verification.json` = `native-package.json` = `published.json` = served live |
| Live URL | `https://windows-wsl.taile06c45.ts.net/character-sound-live-01a0f3a2/` |
| Recordings | original `5020aad09fb08da6…`, stone `92ea7694dac6f70d…`, adapted `92c4389ad1b1e740…`; served bytes = `published.json` = local files |
| Code and inputs | 11 code files, 15 inputs and 6 animation receipts in `verification.json` equal the sources and the build copies. |

The scheduler change is exactly the tested line plus its comment: `demo.gd` differs from the round-3 file only at lines 1267–1268, and from my round-3 test file only in the comment.

## 1. Round-4 acceptance — each item

| # | Item from round 3 | Result | My evidence |
|---|---|---|---|
| 1 | No same-foot cue within 14 ticks unless the sole rose 50 mm | **PASS** | My sweep, 322 gait changes, 2,613 cues: zero in run → stop, run → walk, run → dash, run → turn, dash → stop, walk → stop, walk → run and starts. 15 in dash → run, each after a rise of 51.2–95.1 mm. Smallest swing before any cue 51.2 mm; highest sole at any cue 10.0 mm. |
| 2 | The check measures soles itself and keeps memory across gait changes | **PASS** | `contact_check.gd` computes sole height from skeleton poses, uses fixed rule values (60 mm must sound, 50 mm minimum, 10 mm plant) and resets only when the character is not moving. It passes 325 cases and 2,687 cues on my runner. |
| 3 | Steady gaits: one Left and one Right per cycle | **PASS** | My per-tick probe: Walk, Run and Dash at three travel calibrations, exactly (1, 1) in every cycle. `contact_check.gd` asserts the same. |
| 4 | Recordings re-made and re-bound | **PASS** | §2. |
| 5 | Wording updated | **PASS** | Evidence README line 13, PROVENANCE.md line 37, research note lines 139 and 147. |

**The new gate is real.** I ran it against two deliberately wrong schedulers on a private copy:
- Round-3 line: `contact_check.gd` logs 29 "Toe roll played as a stride" failures. That is exactly the number of cues my round-3 sweep said the fix removes.
- Bar raised to 100 mm: `contact_check.gd` logs 33,828 "substantial swing landed without its cue" failures, and `audio_check.gd` fails too.

**Before and after.**

| Stops | Round-3 line | Now |
|---|---|---|
| Run → stop and run → walk, 68 release phases | 16 with a same-foot double | 0 |
| The same, three run cycles of phases (202 cases) | not run | 0 |
| Short runs of 0.2–1.3 s from standstill, then stop (340 cases) | 63 | 5 (see §3, L1) |

## 2. Refreshed evidence — E1 on the published recordings

Method as in round 3: bytes downloaded from the comparison URL, ffprobe packet timestamps, a decode of each recording's own audio track, every cue's complete waveform searched at its audio-clock dispatch time.

| Requirement | original | stone | adapted | Result |
|---|---|---|---|---|
| 1. Packets contiguous; decoded length within 1% of the span | 391 × 20 ms, largest gap 1.0 ms, 99.76% | 392 × 20 ms, 1.0 ms, 99.80% | 391 × 20 ms, 1.0 ms, 99.76% | **PASS** |
| 2. Every event's onset within ±30 ms | 17 of 17, 13.1–24.8 ms | 16 of 16, 13.1–24.8 ms | 18 of 18, 13.1–13.2 ms | **PASS** |
| 3. Peaks below 0 dBFS | −21.6 dBFS, 0 clipped | −18.9 dBFS, 0 clipped | −22.3 dBFS, 0 clipped | **PASS** |

Supporting numbers:
- Lowest overlap-corrected correlation 0.928 / 0.930 / 0.955; each cue's fitted level is 0.91–1.03 of the requested level; left equals right.
- Each capture file now names the live URL, the PCK hash and the renderer (NVIDIA D3D12). URL and PCK equal `published.json`.
- Video: 800×600 at 28.6–28.9 fps. 4–6 frames per recording share a timestamp with the previous frame, as disclosed. Largest frame gap 232–256 ms (the two known hitch frames).
- `media-spans.json` and `waveform-alignment.json` agree with my numbers and carry the new recording hashes.

**My own captures of the live build** (one clean take per profile at 57–58 fps, GPU, audio clock read at each cue's dispatch):

| Profile | Cues within ±30 ms | Delay after dispatch | Output explained by cues | Right vs left |
|---|---|---|---|---|
| House | 18 of 18 | 13.2–24.8 ms | 99.1% | 0.00 dB |
| Stone | 17 of 17 | 13.2 ms | 99.4% | 0.00 dB |
| Adapted | 18 of 18 | 13.2 ms | 98.3% | 0.00 dB |

No page errors; `crossOriginIsolated` true; the Sound button reaches all three profiles. None of these three takes ends with a double step.

## 3. What the single 50 mm rule still does — declared, not blocking

The rule is now consistent: a foot sounds when its sole rose at least 50 mm and returned to within 10 mm while the character is moving. Two consequences are audible.

**L1. A rare double step when stopping.**
- **When.** A stop early in a run, released one tick after the left foot plants. In the stop blend the Run pose's foot bounce reaches 50.1–50.8 mm, just over the bar, and the same foot sounds again about 0.15 s later.
- **How often.** 5 of 340 short-run stops (1.5%). 0 of 202 stops after a steady run. The round-3 line gave 63 of 340.
- **Where to hear it.** The end of the published adapted recording: Left at 6.989 s, Left again at 7.152 s.
- **Why the bar cannot simply move.** The bounce normally peaks at 46–49.5 mm, so 50 mm has 0.5–4 mm of margin. A 58 mm bar removes the double but silences the first step of every dash from standstill (its lift is 54–57 mm).

**L2. A silent first small step on some starts.**
- **When.** The walk cycle is not reset between moves. A new start can begin mid-cycle, so the first foot movement is a short lift under 50 mm. By the rule it is silent.
- **How often.** After 44 different earlier stop phases, the first footfall is silent in 18 run starts, 20 dash starts and 23 walk starts. The lifts are 15–50 mm.
- **Effect.** The first footstep sound comes 0.27–0.42 s after a run starts instead of 0.17–0.27 s (walk: up to 0.53 s). 6 of 65 nudges of 0.2–0.4 s make no footstep sound at all.
- **Compared with round 3.** The round-3 line sounded these lifts when they passed 35 mm. Of the 194 cues the fix removed in the short-run sweep, 62 came after the release (the F1 class) and 132 were first lifts at the start.

**Why I do not block on these.**
- Both follow from one documented rule, and that rule is the one I asked for.
- Across 2,613 + 3,181 + 919 cues no cue follows a swing under 50 mm.
- Every swing of 65 mm or more that lands while the character is moving is sounded, except one release phase in 34 where the foot hovers 10.4 mm above the floor (the cue is 0.1 s late, or silent if the character has already stopped). The plant threshold did not change this round, so this is not new.
- The doubles fell from about one stop in four or five to about one short-run stop in seventy.
- I found no drop-in improvement. Two private variants (the first lift after a standstill counts from 35 mm; main bar 50 or 58 mm) restore the first step, and the 58 mm one removes L1, but 9–10 of 44 dash starts then sound the same foot twice within 14 ticks (1 of 44 in the current build).

Whether L1 and L2 are acceptable is the owner's call by ear. A further scheduler change needs its own review.

## 4. Other checks — pass

| Item | Result |
|---|---|
| Native gates, my re-run | controller, driven, quality, contact and audio checks pass on a private runner with the current scripts: 0 script errors, 0 errors, 0 leaks. |
| Motion | The 2,160-tick probe (idle, walk, run, jump, dash, skid, stop, steering × no tool, axe, net) on the current scripts gives output byte-identical to the accepted `9a76b8f` scene: 7,182,559 bytes, SHA-256 `4477e7bea770ad3d…`. |
| Lint and repository checks | gdlint and gdformat 4.5.0 clean on all 11 package scripts including `contact_check.gd`. `check.sh` steps 1–3 pass. `git diff --check` clean, staged and unstaged. Step 4 (museum import) read from the root's log, not re-run. |
| #237 | The five #237 files, `check.sh`, `.gitignore` and `MODULE.md` are untouched since before round 3. `viewer.gd` is still comment-only. |
| PCK contents | 53 files (56 in round 3). Only `demo.gdc` and the uid cache differ; the three stray JSON files are gone; the other 51 entries, including `sound.gdc`, every sample and `project.binary`, are identical to the round-3 build. |
| Links | Live URL sends both isolation headers. The old broken link now returns 404. |
| Stills | The three I opened (original idle, stone idle, adapted running) show the right Sound label and an intact GPU render. |

## 5. Notes — not blocking

**N1. For #236.** Carry L1 and L2, plus the round-3 note (single-threaded sample playback is 4.65 dB louder on the right). One addition: the 10 ms buffer has little headroom. While another session loaded this machine (load average 60–90 on 32 cores) the audio thread missed 11.6 ms blocks and 2–6 of 16–17 cues lost part of their body (78.8–92.4% explained). The byte-identical round-3 build did the same under that load (90.5%). On the idle machine every cue came through at full level (98.3–99.4%).

**N2. The contact gate reports success even when it fails.** `contact_check.gd` exits 0 and prints PASS when assertions fail; only the packager's log scan turns it red. The two booleans in `native-contact.json` are constants. Count the failures and write the real numbers.

**N3. Keep both checks.** `audio_check.gd` alone does not notice the round-3 line (0 failures); `contact_check.gd` does.

**N4. One sentence is slightly too strong.** Evidence README line 13 says the toe roll "no longer rearms a contact". It still does when the bounce passes 50 mm (L1).

**N5. Cases to add when the scheduler is next touched.** Short runs from standstill and starts after earlier movement. Neither is in the 325 cases, and both L1 and L2 live there.

## 6. Declared limits

1. **Scope.** Sound package and #237 only. Museum integration, release and the inherited Shell fixture failures were not re-run.
2. **Browsers.** Headless desktop Chrome on the GPU only this round. No phone, Safari or Firefox; the threaded build on iOS is untested. Timing is measured inside the audio graph.
3. **Sources.** Unchanged: YouTube AAC captures with unknown bank IDs; skid, jump, landing and door-opening sounds remain authored.
4. **Inherited motion, not re-opened.**
   - Dash → run and dash → stop re-plants: the foot really rises 5 cm or more and lands again. Every recording shows one about 4.0–4.3 s in (the left foot twice, 0.2–0.28 s apart).
   - The foot still in the air when the character comes to rest lands silently (44 of 111 stop phases); cues are only made while moving.
   - Dash-entry bounce, two hitch frames, platform-lip perch, faceted mittens, unmipmapped hands.
5. **My measurements.** Native sweeps ran on a private copy of the build project with the current scripts. The two scheduler variants in §3 exist only there.

## 7. Evidence kept

All under `build/character-review/opus-round4/` (git-ignored, 8 MB after I removed 25 intermediate files).

- **Acceptance 1–3:** `sweep-r4.json` with `analyze_sweep.py`; `r4_heights.gd`, `heights-r4.json`, `heights-wide.json`, `analyze_heights.py`, `heights-*-summary.json`; `gate-*.log`; `mutation-summary.txt`.
- **L1 and L2:** `r4_tap.gd`, `heights-tap.json`, `heights-tap-round3line.json`, `r4_start.gd`, `heights-start-{run,dash,walk}.json`, `analyze_bar.py`, `analyze_start.py`, `variants/`.
- **E1 and captures:** `verify_published.py`, `published-verification.json`; `r3_clock.cjs`, `analyze_clock.py`, `clock-r4-*-analysis.json`; loaded-machine results in `loaded-*-analysis.json`.
- **Binding and motion:** `pck_list.py`, `r4_motion_hash.gd`, `motion-r4.log`, `check123.log`.

To repeat a sweep: `godot --headless --fixed-fps 60 --path <copy of build/character-package/project> -s build/character-review/opus-round4/r4_tap.gd -- --tag=<name> --out=<absolute path of build/character-review/opus-round4>`, then `python3 build/character-review/opus-round4/analyze_bar.py <name>`.

## 8. Tool receipt

- **Model:** Claude Opus 5.5, maximum effort, session `ab7b9a74-77e4-47fd-8fb1-f1b2919f372a`, existing subscription.
- **Paid:** none. ScrapeCreators 0 calls this round (cumulative 2 of 3, about $0.0038). No generation, no downloads beyond the three published recordings (about 0.6 MB each).
- **Network:** the two public tailnet URLs only; 10 headless Chrome captures of the live build and one control capture of the round-3 build on 127.0.0.1:9873 (server stopped).
- **Local:** about 36 headless Godot runs on my private runner (my round-3 copy of the build project, with the 11 current scripts copied in); gdtoolkit 4.5.0 from the existing venv. No run used the root's build project.
- **Writes:** this report and scratch only. No tracked file edited, no git or GitHub write, no credentials or configs read.
- **Disturbance:** another session's Godot jobs loaded the machine on and off from about 23:28 to 23:49. Captures degraded by that load are reported in N1; §2 uses one clean take per profile.
