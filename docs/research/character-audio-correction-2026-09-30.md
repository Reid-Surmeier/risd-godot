# Character audio correction — 2026-09-30

Research for [issue 231](https://github.com/Reid-Surmeier/risd-godot/issues/231), following the owner's report that prototype sound differs from original GameCube Animal Crossing. Public controller/audio source is pinned to ACreTeam/ac-decomp `09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c`. This pass captured only 24 seconds of mixed gameplay audio and four small candidate windows, **465,713 audio bytes total**, with no ROM, paid call, full-video download or dependency install. No runtime implementation or provenance file was changed by this research task.

## Verified problem and source dispatch

The audited demo creates one 80 ms white-noise burst, then changes pitch to represent different terrain or skidding. That does not reproduce the original selection mechanism. Original footsteps use distinct surface banks, alternating left/right samples and occasional variants, while `freqScale` stays **1.0**. DASH selects a separate bank by adding decimal 40 to the surface base. A pitched copy of one sample cannot establish source timbre fidelity. [Sound dispatch](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L2014-L2049), [audited demo](../../image-work/character-pilot/live-demo/demo.gd).

| Surface | Base ID | DASH bank base, before left/right variation |
| --- | --- | --- |
| Grass, nonwinter | `0x4201` | `0x4229` |
| Soil/path/default | `0x4202` | `0x422A` |
| Stone | `0x4203` | `0x422B` |
| Wood | `0x4204` | `0x422C` |
| Bush/leaves | `0x4205` | `0x422D` |
| Snow, including winter grass | `0x4206` | `0x422E` |
| Sand | `0x4208` | `0x4230` |
| Wave/water | `0x4209` | `0x4231` |
| Bridge override | `0x420A` | `0x4232` |

Surface constants are consecutive after `SE_ECHO(0x200)=0x4200`; index 7 has an unnamed sound and must not be silently assigned a terrain. Attribute selection groups grass0/1/2, switches them to snow in winter, groups soil0/1/2, and defaults to soil. The player adds a bridge override after querying its position. [Constants](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/audio_defs.h#L340-L350), [surface mapping](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/audio.c#L314-L351), [bridge/floor dispatch](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_sound.c_inc#L48-L78).

After the DASH offset, ordinary right-foot events use bank offset0; ordinary left-foot events add decimal 10 (`0xA`). The random value 3 selects occasional right +20 (`0x14`) or left +30 (`0x1E`) variants only when neither preceding side carries the special-variant flag. The source alternates its counter globally; do not equate that counter alone to a recovered skeletal foot identity. Outdoor gain is WALK **.6**, RUN **.8**, DASH **1.0**, and indoor **.54/.72/.9**. Indoor floors use `0x42E6+SE_FLOOR_DATA[floor_index]`; fallback uses wood. Indoor reverb values are 5 generally or 50 for two special scene modes, which are engine values rather than directly transferable Godot percentages. [Bank variations/gains](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L2014-L2105), [floor lookup](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L192-L219).

Player sound status comes from the actual gait state and normalized phase speed. Footstep emission occurs through footprint/contact handling; WALK settling into WAIT can also emit a final step depending on phase. These details matter when start/stop sounds feel wrong even with a better waveform. [Status](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_sound.c_inc#L8-L39), [contact sound](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_common.c_inc#L6010-L6016), [settle step](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_walk.c_inc#L62-L75).

## Skid, doors and voice are separate cues

Skid starts **`0x4129`**, triggered on entering TURN_DASH or SLIP_NET. It is not a slowed footstep. House-door audio uses IDs **`0x6/0x7/0x8/0x9`** at door-animation frames **2/8/33/40 entering**, **10/14/35/50 leaving**. Door knocks use **`0x14A`** at player-animation frames 13/20. Convenience-store doors use **`0x44B` opening**, **`0x44C` closing**; furniture doors have different IDs again. Frame schedules are source frame values, not immediate seconds without animation-rate evaluation. [Skid trigger](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_sound.c_inc#L207-L209), [TURN_DASH entry](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_turn_dash.c_inc#L16-L32), [house timing](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/actor/ac_house_move.c_inc#L39-L65), [knock timing](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_knock_door.c_inc#L58-L66), [store timing](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/actor/ac_conveni_move.c_inc#L314-L319).

Voice has Animalese, click and silent modes. `Na_VoiceSe` processes neighboring character codes, phonetic connection rules, character/voice identity and scaling, rather than one generic beeping pitch. A synthesized interaction chirp must be described as an adaptation unless it reproduces that behavior and its timbre is compared. [Voice modes](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/audio_defs.h#L10-L12), [phonetic route](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L2598-L2810).

## Bounded gameplay evidence and measured candidate windows

Original-game capture uploaders are primary footage evidence, but their hardware/emulator settings and button input are unknown. These audio files include music and other sounds. This model's audio input was unavailable, so no candidate is claimed to be isolated or verified by listening. The parent can listen to these specific files rather than extrapolating from silence or invented waveforms. Hashes, ranges and numeric analysis are in [references.json](../../image-work/character-pilot/live-demo/audio-reference/references.json).

| Source and interval | File | Observation supported by existing video review |
| --- | --- | --- |
| [EmuRetro601–611 s](https://www.youtube.com/watch?v=Fd0g57lSedA&t=601s) | [10 s audio](../../image-work/character-pilot/live-demo/audio-reference/emu-601-611.m4a) | Outdoor traverse, then Tom Nook dialogue; guided gait/input uncertain |
| [MaloDogfish645–653 s](https://www.youtube.com/watch?v=o7pRJ3Vhu7s&t=645s) | [8 s audio](../../image-work/character-pilot/live-demo/audio-reference/malo-movement-645-653.m4a) | Ramp/lower-ground movement; gait/input uncertain |
| [Nintendo Utopia1501–1507 s](https://www.youtube.com/watch?v=OUMNiEiR1As&t=1501s) | [6 s audio](../../image-work/character-pilot/live-demo/audio-reference/utopia-door-1501-1507.m4a) | Shop exit and snow outdoor movement; uploader is independent, not official Nintendo |

| Candidate, still mixed | Original timestamp | Window length | Mixed spectral peak / centroid |
| --- | --- | ---: | ---: |
| [Emu step](../../image-work/character-pilot/live-demo/audio-reference/emu-grass-candidate.wav) | 601.79–602.01 s | .22 s | 355 / 1221 Hz |
| [Malo step](../../image-work/character-pilot/live-demo/audio-reference/malo-step-candidate.wav) | 645.42–645.65 s | .23 s | 183 / 1406 Hz |
| [Shop-exit transient](../../image-work/character-pilot/live-demo/audio-reference/utopia-door-candidate.wav) | 1501.10–1501.60 s | .50 s | 1276 / 1389 Hz |
| [Dialogue candidate](../../image-work/character-pilot/live-demo/audio-reference/emu-voice-candidate.wav) | 609.0–609.6 s | .60 s | 253 / 789 Hz |

Spectra use mono 22050 Hz, mean removal, Hann window, and exclude bins below 40 Hz. A separate 512-sample,110-hop high-band envelope (2500–7500 Hz) gives roughly **27–36 ms half-prominence widths** for the first walking-transient candidates. This measures a transient's high-frequency core, **not the complete footstep lifetime**. Music may supply the dominant spectral peak. Do not copy these peak frequencies as an original footstep oscillator or call a high-pass version isolated: neither background subtraction nor reliable separation was established. No input-labelled DASH cue or clean skid cue was identified in this bounded capture.

## Implementation consequence

Implement and test the verified bank selection, left/right variations, gait gain, final-step handling and separate skid/door events first. Distinct low-pitched body transients plus short band-limited surface detail are a more grounded provisional synthesis than one white-noise sample with terrain pitch shifts, but the exact oscillators/envelopes remain listening-calibrated choices. Keep candidate audio for comparison, not automatically as runtime assets. A correct dispatch table is measurable progress; an exact sound match still requires a verified clean reference or an owner-reviewed listening comparison.

The smallest evidence check is:

```python
from pathlib import Path
import json, hashlib, wave
root = Path("image-work/character-pilot/live-demo/audio-reference")
receipt = json.loads((root / "references.json").read_text())
rows = receipt["clips"] + receipt["cue_candidates"]
for row in rows:
    payload = (root / row["path"]).read_bytes()
    assert hashlib.sha256(payload).hexdigest() == row["sha256"]
    assert len(payload) == row["bytes"]
    if row["path"].endswith(".wav"):
        with wave.open(str(root / row["path"]), "rb") as stream:
            assert stream.getframerate() == 22050 and stream.getnchannels() == 1
assert sum(row["bytes"] for row in rows) < 5_000_000
assert 0x4201 + 40 == 0x4229 and 0x4209 + 40 == 0x4231
print("bounded audio reference hashes, formats and bank calculations passed")
```

## Additional source and prototype limits

Bando describes recording many separate natural effects, including his own footsteps and waterfront sandals. Totaka describes stone footsteps as crisp and grass as soft. This supports distinct material transients rather than pitching one noise burst. The English page is a translation of Nintendo Online Monthly interviews; the original linked Nintendo page is no longer available at its historical URL. [Developer interview translation](https://shmuplations.com/animalcrossing/).

The new `live-demo/sound.gd` uses the verified bank offsets, repeat suppression and gait gains. Its waveforms are deterministic local synthesis, not recovered Nintendo samples or an isolated version of the mixed references. Indoor uses the documented wood fallback, with no claim to have identified the review room’s original floor-data index. Door cue times preserve the four source-frame proportions within the prototype’s .7-second transition; they are not a recovered original animation duration. Voice, background ambience and original reverb remain unimplemented. The source dispatch and waveform integrity are regression-tested; an exact listening match is still open.
