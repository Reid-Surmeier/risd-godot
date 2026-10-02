# Original GameCube character audio — 2026-10-01

Follow-up to the owner's request to find original clips and engineer them into the approved animation. Scope is [character replacement issue 235](https://github.com/Reid-Surmeier/risd-godot/issues/235). The approved prototype remains preserved; the runtime package in #235 applies these findings. No paid calls, disc images, full gameplay videos, or new dependencies were used.

## Usable original sample source

[WDLmaster's firsthand decoding report](https://hcs64.com/mboard/forum.php?showthread=64579) links [Animal Crossing samples.zip](https://drive.google.com/file/d/1M2fUPjUmXV2UbGltqGcsNLrWXLBFbC27/view). The author describes decoding the GameCube game's samples using wavetable indices and VADPCM predictor coefficients. The export rate is 32,000 Hz, **without the soundfont's per-instrument tuning**. One sample can have several tunings. Consequently a decoded WAV is not automatically the fully rendered in-game cue. The original disc region and revision are unverified.

The archive downloaded successfully on this date:

| Verified property | Value |
| --- | --- |
| Compressed archive | 22,150,270 bytes |
| Archive SHA-256 | `1daba0cc50043bd43dcdadd31a9cd101b9179581a1ab509ed4fdd9a8190f0766` |
| WAV entries | 1,157 |
| Total uncompressed WAV bytes | 24,071,280 |
| WAV format | mono PCM16, 32,000 Hz |
| Sample name groups | T0:65; T1:17; T2:93; T3:181; T4:211; T5:590 |
| Scratch archive | `/tmp/ac-sound-research/archive.zip` |

These are local byte/header measurements, not uploader assertions. Files are numerically named `T0W0.wav` through the six groups; there is no cue-name manifest. Individual files can be read from the ZIP without extracting all 24 MB. Public download endpoint: `https://drive.usercontent.google.com/download?id=1M2fUPjUmXV2UbGltqGcsNLrWXLBFbC27&export=download`.

The same primary discussion links [audiorom.7z](https://www.mediafire.com/file/54h0qojtmnfjnpm/audiorom.7z/file), potentially supplying the missing sequence and soundfont data. The normal link, shortcut, file-info API, and archived page's old direct-download URL all return HTTP404 in this pass. Wayback retains the HTML page from 2025-03-04 but no downloadable archive was recovered. This is a specific missing input, not evidence that no public copy exists.

## What must connect the WAV to the animation

All source references here are pinned to ACreTeam/ac-decomp `09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c`.

`Sou_TrgStart` splits a cue into low-eight-bit index and sound-bank selector in bits8–11, then writes those into subtrack ports0 and1. The sound-effect group starts **sequence242**, rather than treating the cue ID as an archive WAV index. [Cue dispatch and initialization](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L868-L947).

The compiled [audio headers](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/audioheaders.c#L2433-L2442) place sequence242 at `0xA6100`, size `0x5960`; its soundfont list is `2,155,154,153`. The binary soundfont region starts at `0xCF700` and spans `0x67C80`; the waveform region starts at `0x137380`. These headers identify where to read, but do not contain the missing per-instrument sample/tuning payload. They must not be presented as a recovered cue-to-WAV table.

The smallest exact recovery is: read sequence242's event subroutine for the selected bank/index; resolve its instrument and note to a soundfont sample plus tuning; apply its note duration, envelope and any pitch changes; render that cue; then trigger it on the existing animation contact/action event. Source structs explicitly store the sample reference and `float tuning` together. [Sample and tuning structure](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/jaudio_NES/audiostruct.h#L110-L126).

The [OpenCrossing-Dreamcast source reader](https://github.com/GabeConway/OpenCrossing-Dreamcast/blob/main/tools/dcaudio/audiorom.py) already parses soundfonts and samples from `audiorom.img` plus the compiled headers; reuse it if the missing binary becomes available. Its `audiorom-s8.tables.json` contains rewritten region extents, **not cue/sample identities**. Boot-time JaiSeq/IBNK extraction tools do not establish the gameplay cue mapping.

## Exact event identifiers to preserve

| Event | Original cue identifier | Animation integration |
| --- | --- | --- |
| Grass step | `0x4201` | Existing ground contact; side/variant bank offsets below |
| Soil/path step | `0x4202` | Actual surface under the contact foot |
| Stone step | `0x4203` | Same event, separate material sample |
| Wood step | `0x4204` | Same event, separate material sample |
| Grass DASH step | `0x4229` | DASH bank, not a pitch-raised ordinary step |
| Wood DASH step | `0x422C` | DASH bank, same contact-event scheduling |
| Indoor floor step | `0x42E6 + SE_FLOOR_DATA[floor_index]` | Floor data selects the cue; wood fallback is explicit |
| Skid | `0x4129` | Enter TURN_DASH or SLIP_NET once |
| House door | `0x6/0x7/0x8/0x9` | Distinct four-stage transition cues |
| Shop door | `0x44B/0x44C` | Open/close, distinct from house door |
| Jump | `NA_SE_JUMP = 0x42A` | Emit at actual launch, once |
| Landing | `NA_SE_LANDING = 0x42B` | Emit on the physical landing edge, once |
| Axe/net swing | `NA_SE_TOOL_FURI = 0x5A` | Tool swing event |
| Net impact | `NA_SE_AMI_HIT = 0x5C` | Impact event, distinct from swing |
| Tool catch/get | `NA_SE_TOOL_GET = 0x5D` | Confirmed catch/get event |
| Axe hit/cut | `NA_SE_AXE_HIT = 0x41D`; `NA_SE_AXE_CUT = 0x41E` | Respective impact/cut events |

Footstep selection adds decimal40 for DASH and decimal10 for ordinary left-foot variation; occasional alternate variants add decimal20/30. Normal outdoor WALK/RUN/DASH gains are `.6/.8/1.0`; indoor `.54/.72/.9`. Frequency scale remains1.0 at this game-level dispatch, which does **not** mean the sample's underlying instrument tuning is1.0. Full contact/final-step, material, door-frame and variant details are already captured in [the earlier source audit](https://github.com/Reid-Surmeier/risd-godot/blob/9a76b8f997d1b8243c2f5f6275a5c2a92e22d888/docs/research/character-audio-correction-2026-09-30.md), including its direct source links.

Jump/landing and tool constants are verified in [audio_defs.h](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/audio_defs.h#L260-L283); the [player sound functions](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_sound.c_inc#L86-L157) call them separately. Finding these cues does not establish that the prototype's general-purpose standing/moving jump is the original game's action behavior.

## Avoid substituting the wrong game

[Cory Martin's firsthand sample-pack description](https://corymartin.net/misc/) identifies instrument samples selected from the **Animal Forest N64 ROM** and converted into musical soundfonts. It does not supply GameCube gameplay cue identities; it is unsuitable as proof of an exact GameCube footstep.

The readily found [New Horizons Footsteps archive](https://sounds.spriters-resource.com/nintendo_switch/animalcrossingnewhorizons/asset/449654/) explicitly belongs to the Nintendo Switch game. Filenames such as `Pl_Footstep_Hard_Grass_Walk_00_Ac.wav` are attractive but must not replace the original GameCube bank. The similarly named DS voices and Japanese N64 Animalese archives are separate versions.

## Quantitative matching and its current limit

The existing [bounded gameplay references](https://github.com/Reid-Surmeier/risd-godot/blob/9a76b8f997d1b8243c2f5f6275a5c2a92e22d888/image-work/character-pilot/live-demo/audio-reference/references.json) include EmuRetro601–611s, MaloDogfish645–653s, and Nintendo Utopia1501–1507s. The initial broad scan treated these as potentially mixed recordings. Follow-up visual and quiet-gap analysis below identifies a clean station-stone passage in the Emu excerpt. The Utopia segment is a shop exit, not an identified house-door waveform.

An exploratory scan compared decoded samples against the three existing candidate WAV windows with a 2–8kHz band-pass, normalized sliding waveform correlation and40 playback ratios spanning.35–2.4. It yielded high scores for very short, unrelated candidates: Emu `.724` over14ms, Malo `.611` over12ms, and shop exit `.911` over18ms. These do **not** identify a footstep or door. Short periodic/music transients can score highly; the fitted ratios and candidate windows are also uncertain. None has been promoted to a runtime cue. Scratch method/results: `/tmp/ac-sound-research/fingerprint.py` and `fingerprint.json`.

Acceptance for a fingerprint-based recovery requires repeated visually confirmed contacts, a stable sample/rate across those contacts, no corresponding false matches during stillness, and comparison of the full cue's onset/body/tail rather than a tiny correlated slice. Listening comparison remains required; this research worker has no audio-input tool and has not claimed to listen to the clips.

## Captured indoor clips ready for contact playback

[MaloDogfish's original-game footage at6:28](https://www.youtube.com/watch?v=o7pRJ3Vhu7s&t=388s) provides a much better source: the first tour of an almost empty house. The room contains an apparently inactive boombox; the character moves from the doorway, turns, stops, and leaves. Visual review locates the indoor movement at388–394s. The floor has a checkerboard appearance; its actual floor-data index and original cue identifier are **unidentified**. Use a captured house-floor profile, not an asserted grass/wood/stone mapping.

The 30s source excerpt376–406s is `/tmp/ac-sound-research/malo-house-376-406.mp4`:1,377,460bytes, SHA-256 `b56970994b928f081fba8efcbd1212ee19c149dee037f1d3027713b6cd07ba9f`. Numeric analysis finds stillness391–392s at RMS approximately.00004 versus movement windows around.001–.005. This is strong evidence of a practically music-free interior, not proof of a pristine disc sample. The source is YouTube AAC, decoded and downmixed to mono22050Hz; compression and capture gain remain part of the recording.

Four185ms contact clips preserve roughly15ms before onset and the full approximately90ms body/tail plus quiet padding. No synthesis, filtering, denoising, pitch change or normalization was applied:

| Scratch WAV | Absolute source interval | SHA-256 |
| --- | --- | --- |
| `/tmp/ac-sound-research/indoor_step_a.wav` |388.893–389.078s| `6f17e6df149cff1fd781ac8888377d7800343f3533e934e897fccbb29289a421` |
| `/tmp/ac-sound-research/indoor_step_b.wav` |389.163–389.348s| `79a1eaf9cca7b74af8058d41663d10ac455af4e3548d14ccb770ba82c25e996b` |
| `/tmp/ac-sound-research/indoor_step_c.wav` |389.465–389.650s| `1fa7738233aa2fad137ef26b474d28bed8404fa50c23b261f8ce953533bfb698` |
| `/tmp/ac-sound-research/indoor_step_d.wav` |389.819–390.004s| `f6ac206b2abd2b9dda59605e90ceecc15a65facc55dfa5247525509b1d02ea3c` |

The first two contacts' above-floor energy starts at388.908s and389.178s. Manually inspected source frames388.933s and389.200s show consecutive alternating shoe contacts during the upward traverse, within one encoded30fps frame of those audio onsets. Projection and hidden soles prevent assigning a recovered skeletal-left identity from these frames. Keep ordering and one event per contact; do not invent a fixed audio timer detached from the rendered feet. The next two clips occur while turning/settling. Original gait state and controller pressure were not recovered.

These files total32,810bytes. A common playback gain can make the small capture levels audible without changing their relative levels; record that gain in runtime provenance. Their peaks are.01251/.03369/.02304/.02130, so avoid individual peak normalization, which would erase source differences. The stillness baseline is approximately38dB below the louder step windows. The runtime adapter should retain the existing gait/contact scheduling and use these original recordings for the captured floor profile. Other terrain banks and special action sounds remain separately identified work.

An additional **540ms captured house closing cue**, `/tmp/ac-sound-research/house_door_close.wav`, spans386.490–387.030s. SHA-256 `3deaff721523a6afac064042e0e8fc76405b1ceb7e836200222dc8dc7d45811a`;23,858bytes. Frame-by-frame review shows the exterior door close before the iris transition. Independent native review corrected the dominant slam peak to386.5204s (attack begins about386.514s) and decays to near-silence by387.0s. Outdoor music is fading during this transition; a faint residual bed near the first10–20ms is not independently removed. This is a useful attributed closing recording, **not** an isolated soundbank master or the complete four-stage house-door sequence. The music/dialogue-contaminated opening portion was not promoted.

All crop receipts are `/tmp/ac-sound-research/house-candidates.json`; their reproducible crop script is `extract-house.py`. Contact/door inspection sheets are `malo-contact-388p8.jpg` and `malo-door-close.jpg`. Only the parent may copy the accepted clips into the runtime asset package and bind them to its provenance; this worker changed only this research note.

A second fingerprint scan used the clean house windows with100 playback ratios, a250–8000Hz band-pass and all short decoded samples. A further401-ratio refinement of15 candidate files per window did **not** recover a stable master: the best scores were.723 over28ms and.790 over32ms, with different candidate WAVs and ratios. No archive file was relabeled as a footstep. The captured original-recording route is the supported implementation input; numeric sample identification stops here.


## Follow-up: captured outdoor stone contacts

Visual review corrects an earlier working label: the retained [EmuRetroGameplays footage at 10:05](https://www.youtube.com/watch?v=Fd0g57lSedA&t=605s) shows the player following Tom Nook along **stone paving**, not grass. Both visible characters stay on that surface across the selected contacts. The original recorded audio is `image-work/character-pilot/live-demo/audio-reference/emu-601-611.m4a` in the prototype worktree: 162,459 bytes; SHA-256 `14335a4cade66866c85f8614a4fe85a95d956387d302be30a0f8fc3456de7722`. No further download was needed for this recovery.

The opening escort has several near-silent gaps. At 602.200–602.300, 605.200–605.290, 605.440–605.540, 605.700–605.800, and 606.000–606.080 seconds, decoded mono RMS is 0.000037–0.000041. Three consecutive stone-contact recordings have a single approximately 90 ms attack/body/tail, followed by that quiet floor. Their last 30 ms RMS is 0.000029–0.000038. Later audio after approximately 607.4 seconds includes additional sound and was excluded. This supports a practically music-free captured cue, with AAC/capture artifacts retained; it does not establish a pristine soundbank master.

| Raw scratch WAV | Source interval | Above-floor onset offset | Peak | SHA-256 |
| --- | --- | --- | --- | --- |
| `/tmp/ac-sound-research/stone_escort_step_a.wav` | 605.015–605.200 s | 24.85 ms | 0.09039 | `4bb97ffea4d3e2e92d0efb203930583c9c45f614ca323e1c7d3eb4b346ecfb9e` |
| `/tmp/ac-sound-research/stone_escort_step_b.wav` | 605.288–605.473 s | 22.77 ms | 0.07294 | `ab7f44cef959067e9bd1bc2228bcadc100451579a3219a36fda9aea51e31828c` |
| `/tmp/ac-sound-research/stone_escort_step_c.wav` | 605.542–605.727 s | 27.30 ms | 0.08856 | `6bf5a2fb187e257c5697ad6b43654fdd9f54f791eca457210829e5c8f5e224e3` |

Onsets use a 5 ms RMS envelope threshold of 0.001. Each file is 185 ms, mono PCM16 at 22,050 Hz; together they total **24,608 bytes**. There is no filtering, denoising, normalization, pitch change or synthesis. The raw captured levels differ and should be retained. If contact synchronization trims the leading padding, record that trim and update the runtime hashes. Do not assign indoor gain to these outdoor recordings merely to make their peaks match.

The first and third events have normalized full-window waveform correlation **0.992** over 140 ms after a 0.59 ms alignment adjustment, without pitch fitting or filtering. That agreement covers the body and tail, unlike the earlier misleading 12–32 ms archive matches. The intervening event differs; its exact original bank variation is not recovered. This is evidence of a repeating cue family in the source footage, not a decoded-archive sample identification.

The inspected 30 fps contact sheet `emu-stone-605-contacts.jpg` covers 604.950–605.750 seconds. The alternating player shoe poses align with the selected audio onsets within the encoded frame interval. Nook is also walking in front; anatomical side and exclusive player-versus-NPC emitter identity remain unassigned. Each selected audio window contains one dominant attack, a complete decay and quiet trailing padding, without a second attack like the rejected overlapping passage around 606.1 seconds.

Original NPC sound code obtains the actual terrain attribute and selects its walk label before dispatch. `Na_NpcWalkSe` calls the same `Sou_WalkSe` function used for player steps, with outdoor gain 0.68 and no added reverb. NPC presence therefore does not justify calling these grass cues or altering their pitch; it does prevent claiming that the source levels recover the player's gait gains. [NPC terrain selection](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/ac_npc_sound.c_inc#L6-L16), [NPC sound dispatch](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L2110-L2121).

Use the explicit provenance label **captured stone-paving escort footsteps**, with exact ordinary-left/right/DASH variant IDs unassigned. These files are ready for the parent's audible comparison and runtime review; this worker has not listened. Reproducible crops, hashes and numerical evidence are `extract-stone.py` and `stone-candidates.json` under `/tmp/ac-sound-research`. Runtime promotion is the parent's work, outside this research-note edit.

## Next clean-source window; skid remains unpromoted

The original background-music controller explicitly suppresses hourly background music between **XX:59:52 and XX:00:16**, except during the New Year event. It still schedules the town-tune melody at XX:00:00. Therefore the pre-hour eight seconds, or an independently verified quiet gap after the melody, is a grounded target for recording grass contacts and a dash turn without denoising. Ambient water, weather, NPCs and the chime still need checking; the silence condition alone does not isolate every effect. [Pinned original hourly silence and melody controller](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_bgm.c#L682-L726).

This pass did **not** recover a clean grass, soil, wood, DASH or skid master. The short loud event at the indoor exit around Malo 393.228 seconds coincides with a doorway/threshold transition; it is insufficient evidence of a dash skid and is not promoted. The original skid cue ID and animation trigger are known, but a captured sound must still show that trigger and a clean complete cue. Reusing a generic scrape or treating a musical transient as `0x4129` would defeat the user's requirement.

A bounded 30-second excerpt from [jvgsjeff's 2008 creator montage](https://www.youtube.com/watch?v=wWpTYdHZCDk), *What if Mario Games Sounded Like Animal Crossing?*, was also inspected. Its uploader attributes the music and effects to GameCube Animal Crossing, but the edited Mario footage does not establish which original gameplay action produced a sound. It is retained as a lead, not a verified footstep/skid bank or runtime asset. The compressed excerpt is approximately 1.9 MB; this follow-up stayed far below the 30 MB additional-media limit and used no paid calls or ROM downloads.


## Browser timing check

The audio-thread tap preserves continuous stereo output independently of canvas recording. Source-waveform comparisons exposed 10–78 ms cue-to-output delay in the default Web preview, with starts quantized by the Web mixing buffer. [Godot 4.7 ProjectSettings](https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html) defaults `audio/driver/output_latency.web` to 50 ms, versus 15 ms natively. The preview now requests 10 ms on Web and is measured again; this is a preview setting, not an unverified change to the museum composition. No recording is time shifted to make cues appear aligned.

## Contact cadence and Web recording follow-up (#235/#236)

The museum adapter measured real sole returns in the accepted walk clip rather than assuming phases 0/.5. A 120-frame native Run probe found 17 missed/mistimed events in the old fixed-phase playtest schedule. The playtest now reuses rigid sole vertices and dispatches sound/dust after a lifted sole plants. The accepted Run profile has an approximately 40 mm secondary toe roll; 35 mm rearming generated extra same-foot cues. The regression check first failed on that case; a 50 mm lift threshold in every gait ignores it, and all plant at 10 mm (scaled with the model). The independent steady-cycle check guards cadence. The rig, animation files and movement model are unchanged.

The browser proof retains both request and output clocks. Direct `performance.now()` at cue dispatch avoids inferring it from a later bridge snapshot. Godot's Web `SampleNode.connectPositionWorklet()` awaits its position-worklet promise before calling start, so request time and actual `AudioBufferSourceNode.start()` time remain distinct. A screenshot during capture can delay that continuation and distort the timing test. Comparison captures therefore take thumbnails outside the measured interval, preserve stereo PCM on an AudioWorklet, and mux canvas frames offline without shifting timestamps. [Godot Web audio sample implementation](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/js/libs/library_godot_audio.js), [polyphonic sample dispatch](https://github.com/godotengine/godot/blob/4.7.2-stable/scene/resources/audio_stream_polyphonic.cpp#L199-L248).

The final standalone export uses Godot's native threaded Web export with `audio/general/default_playback_type.web=0` (Stream), `audio/driver/output_latency.web=10`, and the host's cross-origin isolation headers. Single-thread stream playback was tested and rejected because source bodies broke up; the default Web sample path also delayed starts after rendering. Threaded stream playback preserves the complete mixed output without a custom audio implementation. These are measured standalone results, not evidence that the museum's existing host already supplies the required headers. [Godot Web export requirements](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html), [project audio settings](https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html).

Recording exposed a second clock issue: a single wall-clock/audio-clock pairing can drift enough to falsely report a sound before its dispatch. The final recorder observes AudioContext time at the exact unchanged `performance.now()` call used by each cue and timestamps native WebCodecs frames from that same AudioContext. Stereo PCM is preserved independently on the audio thread, then muxed with those frame timestamps. House, Stone and Adapted captures pass complete-waveform alignment within 24.81 ms, with all expected playback gains and no clipping. The smallest overlap-corrected source correlation is 0.9734. Encoded packet continuity and decoded duration are checked separately; no ad hoc timing correction is applied. The measurements and raw cue clocks are in `docs/evidence/character-235/`.

Round-3 review found the gait-dependent threshold still cued Run toe rolls during slowdown: the state label becomes Walk before the Run pose finishes blending. The minimal correction is the same 50 mm rearming bar in every gait. The new native contact check measures the actual soles independently, keeps physical swing history across gait changes, covers 322 phase-offset transitions plus three steady gaits, and catches the defect on the old build. Inherited dash-to-run re-plants are genuine visual swings from disagreeing clip phases and are documented separately; this sound-only change preserves the accepted motion.
