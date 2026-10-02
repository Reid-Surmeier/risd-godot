# Accepted character replacement package (#235)

Owner-selected horned character from [the accepted prototype](https://github.com/Reid-Surmeier/risd-godot/issues/231), source commit `9a76b8f997d1b8243c2f5f6275a5c2a92e22d888`. The six GLBs share one 24-bone skin/rest rig and the corrected hand atlas. Their bytes are unchanged. The demo preserves the quiet idle, walk/run/dash/skid, tool grips, blink, physical jump transitions, contact correction and effects that were reviewed.

## Run and verify

From the repository root:

```sh
python3 scripts/character_package.py
```

This imports only this package in `build/character-package/project`, runs native movement/pose/contact/audio/appearance checks and exports `build/character-package/site`. No image-work trials, provider downloads or paid calls are required. The Web preview uses Godot's threaded export, stream playback (`audio/general/default_playback_type.web=0`) and a 10 ms mixer buffer. This avoids delayed sample starts after rendering. Run `python3 scripts/character_package.py --serve` and publish port 9863 with the share skill; the server supplies the required cross-origin isolation headers. Verify this audio/export/hosting combination when composing the museum replacement. Dense 240 FPS animation imports have their optimizer disabled; keep the tracked import receipts when using the GLBs in another project.

In the full repository, open `res://modules/shell/character/playtest.tscn` for the same playtest. WASD/arrows move; Shift sprints; Ctrl walks slowly; Space jumps; E interacts. The review controls select surfaces, tools and camera views. **Sound: original house** uses captured original GameCube house footsteps and closing audio. Click it to audition **Sound: original stone**, three clean station-paving captures, then **Sound: adapted surfaces**, the previous synthesis. The captured checkerboard floor is unidentified; the capture profiles are explicit auditions applied uniformly to the selected test surface; they do not claim a recovered grass or soil bank. Skid, jump/landing and door opening remain authored.

## Replacement handoff

The package is stored in the Shell that owns the current Collection visitor. The current museum still loads its earlier `visitor159` implementation. This package does not change the museum composition automatically: its playtest scene contains the test arena/camera/UI. Use the package's model/animation/material logic when replacing that private adapter, preserve the museum's navigation/collision/camera and test the complete composed build before activating it. Do not mount the entire test arena into the Collection Page.

All runtime inputs are local to this folder. `provenance.json` binds their hashes to the accepted prototype. `PROVENANCE.md` records providers, acquisition, sound identification and remaining fidelity limits. The Blender source and provider originals remain on the accepted prototype branch rather than becoming runtime dependencies.

## Known limits

Approval is for the prototype's visible result. It does not establish an exact original-game reconstruction. The inherited dash-entry head bounce, faceted mittens, unmipmapped hand sampler and edge/capsule landing behavior remain documented in the original review. General jumping is an added interaction; original code has jump/landing sound IDs, but that does not establish the prototype's jump as an original player ability. Sound, ambience, voices and reverb require their own evidence.

The scoped sound package is approved by Claude Opus 5.5 max in `docs/evidence/character-235/review-round4.md`. Wider checks found rare double taps on short-run stops and silent small first lifts under50mm. The requested10ms Web buffer can lose cue bodies under severe CPU contention. Use the packager as the check entrypoint: it rejects script errors in the native logs; the standalone contact probe's exit status and summary booleans alone do not establish a pass. Museum composition, browser/device coverage and its final mix still need integrated verification.
