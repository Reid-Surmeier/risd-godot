# Original GameCube character audio — 2026-10-01

Follow-up to the owner's request to find original clips and engineer them into the approved animation. Scope is [character replacement issue 235](https://github.com/Reid-Surmeier/risd-godot/issues/235). This pass does not change the approved prototype's sound implementation or provenance. No paid calls, disc images, full gameplay videos, or new dependencies were used.

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

Footstep selection adds decimal40 for DASH and decimal10 for ordinary left-foot variation; occasional alternate variants add decimal20/30. Normal outdoor WALK/RUN/DASH gains are `.6/.8/1.0`; indoor `.54/.72/.9`. Frequency scale remains1.0 at this game-level dispatch, which does **not** mean the sample's underlying instrument tuning is1.0. Full contact/final-step, material, door-frame and variant details are already captured in [the earlier source audit](character-audio-correction-2026-09-30.md), including its direct source links.

Jump/landing and tool constants are verified in [audio_defs.h](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/audio_defs.h#L260-L283); the [player sound functions](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_sound.c_inc#L86-L157) call them separately. Finding these cues does not establish that the prototype's general-purpose standing/moving jump is the original game's action behavior.

## Avoid substituting the wrong game

[Cory Martin's firsthand sample-pack description](https://corymartin.net/misc/) identifies instrument samples selected from the **Animal Forest N64 ROM** and converted into musical soundfonts. It does not supply GameCube gameplay cue identities; it is unsuitable as proof of an exact GameCube footstep.

The readily found [New Horizons Footsteps archive](https://sounds.spriters-resource.com/nintendo_switch/animalcrossingnewhorizons/asset/449654/) explicitly belongs to the Nintendo Switch game. Filenames such as `Pl_Footstep_Hard_Grass_Walk_00_Ac.wav` are attractive but must not replace the original GameCube bank. The similarly named DS voices and Japanese N64 Animalese archives are separate versions.

## Quantitative matching and its current limit

The existing [bounded gameplay references](../../image-work/character-pilot/live-demo/audio-reference/references.json) include EmuRetro601–611s, MaloDogfish645–653s, and Nintendo Utopia1501–1507s. They contain music; the Utopia segment is a shop exit, not an identified house-door waveform.

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

An additional **540ms captured house closing cue**, `/tmp/ac-sound-research/house_door_close.wav`, spans386.490–387.030s. SHA-256 `3deaff721523a6afac064042e0e8fc76405b1ceb7e836200222dc8dc7d45811a`;23,858bytes. Frame-by-frame review shows the exterior door close before the iris transition. The dominant slam peaks at386.524s and decays to near-silence by387.0s. Outdoor music is fading during this transition; a faint residual bed near the first10–20ms is not independently removed. This is a useful attributed closing recording, **not** an isolated soundbank master or the complete four-stage house-door sequence. The music/dialogue-contaminated opening portion was not promoted.

All crop receipts are `/tmp/ac-sound-research/house-candidates.json`; their reproducible crop script is `extract-house.py`. Contact/door inspection sheets are `malo-contact-388p8.jpg` and `malo-door-close.jpg`. Only the parent may copy the accepted clips into the runtime asset package and bind them to its provenance; this worker changed only this research note.

A second fingerprint scan used the clean house windows with100 playback ratios, a250–8000Hz band-pass and all short decoded samples. A further401-ratio refinement of15 candidate files per window did **not** recover a stable master: the best scores were.723 over28ms and.790 over32ms, with different candidate WAVs and ratios. No archive file was relabeled as a footstep. The captured original-recording route is the supported implementation input; numeric sample identification stops here.
