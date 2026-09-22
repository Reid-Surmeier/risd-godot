## The shared Mr. Baby Paint sound-cue seam. Frozen by Issue #108.
##
## One manager attaches to the game root and plays the canonical cue for BaseButton activations.
## A button may set `sound_cue` metadata to `close`, or to `none` when its owning module emits
## `sound_cue_requested(cue: String)` after a specific event succeeds. A non-button Control may set
## `sound_cue_on_gui_activate` to play one generic cue for a left-click activation.
class_name SoundCuesInterface
extends RefCounted

const Errors := preload("res://modules/sound_cues/errors.gd")
const _Impl := preload("res://modules/sound_cues/sound_cues.gd")

const BUTTON := "button"
const REFILL := "refill"
const SAVE := "save"
const CLOSE := "close"
const SPLASH := "splash"


## Build the single sound manager. Returns err(ASSET_MISSING) when a canonical stream is absent.
static func create() -> Dictionary:
	return _Impl.create()


## Attach the manager to `root`, including controls and cue requesters added later.
static func attach(manager: Node, root: Node) -> Dictionary:
	return manager.attach(root)


## Play exactly one canonical cue for `cue`; a new cue replaces a cue still playing.
static func play(manager: Node, cue: String) -> Dictionary:
	return manager.play_cue(cue)


## Returns ok({last_cue, last_path, play_count, counts, mappings, applicable, not_applicable}).
static func state(manager: Node) -> Dictionary:
	return manager.state()
