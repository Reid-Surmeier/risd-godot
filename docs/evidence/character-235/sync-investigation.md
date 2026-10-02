# Sound synchronization reopened

The owner reports that sound is not synchronized to movement. Package approval
did not establish physical audiovisual synchronization: its 13–25 ms measurement
was dispatch to the audio graph, rather than the displayed landing to audible output.

Three new standalone browser captures use per-cue AudioContext clocks,
stereo waveform matching, getOutputTimestamp and RAF callback completion.
The unmodified build still has 13–16 ms mixer delay but estimates 115–160 ms
from dispatch to audible output on this WSL/Chrome test machine. Normal landing
frames complete substantially earlier. Neither requesting 48 kHz nor a 1 ms
browser latency hint removes the estimated output lag. Neither experiment was
applied to runtime code.

Run `python3 scripts/character_sync_check.py`: the unmodified capture fails
the estimated output-versus-frame check. Input and measurements are in
`sync-investigation.json`. Long frames and ambiguous waveform matches are
excluded from that check, not counted as successful synchronized steps.

This is a browser estimate, not a microphone or physical display measurement.
WSL audio buffering does not establish the owner's device latency. The museum
has a separate phase-driven player and a different export configuration; these
standalone measurements do not verify it. The pending question identifies which
demo the owner observed. No runtime synchronization fix or new approval is claimed.

The accepted motion, rig and sound assets remain unchanged. Additional generation
spend: $0. New evidence is bounded; no new gameplay videos were downloaded.

## Stale standalone links corrected

After the owner confirmed standalone testing, a live HTTP hash check found that
`character-walk-01a0f3a2` and `character-validation-01a0f3a2` still served prototype
PCK `21367f7df48b636a8aa26a5fa597d3bfdaf669cffcae6fdf2469d087dc71750b`.
Its source `image-work/character-pilot/live-demo/demo.gd` triggers at phases
0 and 0.5, rather than actual sole planting, and uses the older playback path.

Both existing links now serve port 9863 through the share skill. All three
standalone links return current PCK
`7951713bf47a4eb9b71779bb1256020cb06d006c30766c32571b259180562245`, with
COOP `same-origin` and COEP `require-corp`. This removes an obsolete deployment
path; it does not establish that the owner used that path or that their device's
output latency is fixed. The owner's browser/audio-device question remains pending.
