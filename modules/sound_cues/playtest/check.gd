extends SceneTree

const SoundCues := preload("res://modules/sound_cues/interface.gd")


class CueEmitter:
	extends Node
	signal sound_cue_requested(cue: String)


var failures := 0


func check(condition: bool, label: String) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var created := SoundCues.create()
	check(created.ok, "canonical streams load")
	if not created.ok:
		quit(1)
		return
	var manager: Node = created.value
	root.add_child(manager)
	var fixture := Control.new()
	root.add_child(fixture)
	var generic := Button.new()
	fixture.add_child(generic)
	var close := Button.new()
	close.set_meta("sound_cue", SoundCues.CLOSE)
	fixture.add_child(close)
	var deferred := Button.new()
	deferred.set_meta("sound_cue", "none")
	fixture.add_child(deferred)
	var emitter := CueEmitter.new()
	fixture.add_child(emitter)
	check(SoundCues.attach(manager, fixture).ok, "manager attaches")

	generic.pressed.emit()
	close.pressed.emit()
	deferred.pressed.emit()
	emitter.sound_cue_requested.emit(SoundCues.REFILL)
	emitter.sound_cue_requested.emit(SoundCues.MIXING)
	emitter.sound_cue_requested.emit(SoundCues.SAVE)
	var state: Dictionary = SoundCues.state(manager).value
	check(state.play_count == 5, "specific cues replace generic cues")
	check(
		state.counts == {"button": 1, "refill": 1, "mixing": 1, "save": 1, "close": 1},
		"all applicable mappings play once"
	)
	check(state.mappings.button.ends_with("fill_stop5.wav.res"), "generic mapping")
	check(state.mappings.refill.ends_with("fill_stop3.wav.res"), "refill mapping")
	check(
		state.mappings.mixing.ends_with(
			"UIMisc_Percussive bubbly cute UI elements_RogueWaves_KawaiiUI2_03.wav.res"
		),
		"mixing mapping"
	)
	check(state.mappings.save.ends_with("screenshot7.wav.res"), "save mapping")
	check(state.mappings.close.ends_with("stop_fill_spacebar.wav.res"), "close mapping")
	check(state.not_applicable == ["splash", "sculpture_save"], "absent events stay not applicable")

	var dynamic := Button.new()
	fixture.add_child(dynamic)
	dynamic.pressed.emit()
	state = SoundCues.state(manager).value
	check(state.counts.button == 2, "new buttons are bound")
	var unknown := SoundCues.play(manager, "unknown")
	check(
		not unknown.ok and unknown.error.code == "sound_cues.unknown_cue", "unknown cue is an error"
	)
	quit(1 if failures else 0)
