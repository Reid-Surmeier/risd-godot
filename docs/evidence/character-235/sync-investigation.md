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
