# Opus 5.5 max: synchronization diagnosis

Same continuous reviewer session `ab7b9a74-77e4-47fd-8fb1-f1b2919f372a`, requested model `claude-opus-5-5`, effort `max`. No generation calls. This is a diagnosis, not approval of a new timing fix.

**Verdict: not diagnosed to one cause yet — do not ship a sync "fix" until the owner does the 30-second test below. Reject visual delay and footstep prediction.**

**What I checked (no files or git touched)**
- `demo.gd`/`sound.gd` are unchanged since round 4; PCK is still `7951713b…`.
- All three standalone links (`character-walk`, `character-validation`, `character-sound-live`) now proxy to that same build, so an old link is not the cause today.
- Your 120.8 ms is this WSL host's audio sink: Chrome reports `outputLatency` 104–136 ms here, and in my round-3 captures the same estimate drifted from about 130 to 360 ms. It says nothing about the owner's device.
- `character_sync_check.py` compares audio at the output device with frame submission, so it ignores display latency and will stay red on WSL regardless of the build.

**Two live causes, in my order of likelihood**
1. **Missed footfalls at starts and stops (confirmed in this build, device-independent).** From round 4:
   - The first footfall is silent on 18–23 of 44 warm starts, so the first sound comes about 0.1–0.17 s late.
   - The foot still in the air when the character stops lands silently in 44 of 111 stop phases.
   - Dash→stop sounds the same foot twice.
   
   Mid-run, each cue is on its contact tick and reaches the audio graph 13–25 ms later. I left the first two as "owner's call by ear" in round 4; this may be that call.
2. **Output-path latency on the owner's device (unknown).** Bluetooth or a TV adds roughly 150–300 ms to every sound. No game fix exists for that.

**Minimum test (owner, live link, no code)**
1. Stand still and press Space. Does the landing thud match the feet?
2. Hold a direction for 3+ seconds. Do mid-run steps match?
3. Say which audio output is in use (built-in, wired, Bluetooth, TV).

If the thud is late too, it is the device: change nothing in the runtime. If the thud and mid-run match but starts and stops feel wrong, it is cause 1.

**If cause 1: smallest candidate, untested**
- Count a lift as a step if it exceeds 50 mm, or if the sole stays off the floor for 9+ ticks with a peak of 35 mm or more. In round 4, bounces lasted 3–4 ticks, stop hops 6–8, and real first steps mostly 9–13.
- Let a foot already airborne at the stop sound when it lands, with no re-arming while idle.
- Gate it with my round-4 suites (322 gait changes, 340 short runs, 132 warm starts, steady gaits, motion hash) and update `contact_check.gd` to the new rule. My quick first-lift variant in round 4 caused dash-start doubles, so this needs the full run before approval.

**Why I reject delay and prediction:** delaying visuals adds input lag to everything. Predicting plants produces ghost steps whenever the player stops, turns or jumps before the foot lands.

## Root follow-up

The older standalone endpoints have been updated through the share skill. Their previous PCK was `21367f7d…`; all three now stream `7951713b…` with the required isolation headers. A browser capture through the updated character-walk URL loaded the 24-bone rig, dispatched 16 cues, reported no page errors and matched output waveforms with 99.0% explained energy. Mixer delay was 13.2ms; physical device/display synchronization remains unverified.

A preliminary replay of the reviewer’s 35mm/9-tick suggestion against retained independently measured sole trajectories restored some early cues, but produced 13 same-foot close pairs in 44 dash starts (the original startup set had one). This replay is a screening experiment, not a native runtime result. The candidate was rejected before editing or publishing runtime code.

The owner confirmed standalone testing. Browser/audio-device and whether jump/steady steps also lag are pending. No artificial visual delay or predictive footsteps were added.
