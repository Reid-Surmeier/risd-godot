---
name: sound_cues
purpose: Canonical shared audio feedback for controls, paint, saves, and menu closing
interface: modules/sound_cues/interface.gd
errors: modules/sound_cues/errors.gd
tests: modules/sound_cues/playtest/check.gd
depends-on: []
---

# sound_cues

## Interface

`interface.gd` creates one shared audio manager, attaches it to the Shell tree, plays an explicit cue, and reports test state. Public calls return `{ ok, value, error }`; errors are declared in `errors.gd`.

## Behavior

Issue #108 fixes the mapping: generic activation uses `fill_stop5`, pigment refill uses `fill_stop3`, palette mixing uses `UIMisc_Percussive bubbly cute UI elements_RogueWaves_KawaiiUI2_03`, successful artwork save uses `screenshot7`, and close-menu uses `stop_fill_spacebar`. Mixing plays when a tray drag begins and repeats every 1.4 seconds while the brush stays down. The canonical `AudioStreamWAV` resources are loaded directly from `prototype/mr-baby-paint-audio/sounds/`; they are never copied or transcoded. The current game has no splash screen or sculpture-save action, so those are reported as not applicable rather than invented.

The manager binds existing and newly-added `BaseButton`s. A specific event replaces the generic button cue. Modules request a non-button or deferred cue with `sound_cue_requested(cue)`; controls drawn without a `BaseButton`, such as tabs, opt into generic activation with `sound_cue_on_gui_activate` metadata.

## Acceptance

`playtest/check.gd` exercises generic and dynamically-added controls, the refill, save, and close overrides, unknown-cue errors, canonical resource paths, and the one-event/one-cue rule. Run it with Godot 4.7.2 using `--headless --path . --script res://modules/sound_cues/playtest/check.gd`.
