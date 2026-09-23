extends Node

const Errors := preload("res://modules/sound_cues/errors.gd")
const ROOT := "res://modules/sound_cues/assets/"
const MAPPINGS := {
	"button": ROOT + "fill_stop5.wav.res",
	"refill": ROOT + "fill_stop3.wav.res",
	"save": ROOT + "screenshot7.wav.res",
	"close": ROOT + "stop_fill_spacebar.wav.res",
	"splash": ROOT + "splash_screen.wav.res",
}

var player := AudioStreamPlayer.new()
var streams := {}
var last_cue := ""
var last_path := ""
var play_count := 0
var counts := {"button": 0, "refill": 0, "save": 0, "close": 0}


static func create() -> Dictionary:
	var manager = load("res://modules/sound_cues/sound_cues.gd").new()
	for cue in MAPPINGS:
		var path: String = MAPPINGS[cue]
		var stream = load(path)
		if not stream is AudioStream:
			return Errors.err(Errors.ASSET_MISSING, path)
		manager.streams[cue] = stream
	manager.name = "SoundCues"
	manager.add_child(manager.player)
	return Errors.ok(manager)


func attach(root: Node) -> Dictionary:
	_watch(root)
	return Errors.ok()


func play_cue(cue: String) -> Dictionary:
	if not streams.has(cue):
		return Errors.err(Errors.UNKNOWN_CUE, cue)
	player.stop()
	player.stream = streams[cue]
	player.play()
	last_cue = cue
	last_path = MAPPINGS[cue]
	play_count += 1
	if counts.has(cue):
		counts[cue] += 1
	return Errors.ok(cue)


func state() -> Dictionary:
	return Errors.ok({
		"last_cue": last_cue,
		"last_path": last_path,
		"play_count": play_count,
		"counts": counts.duplicate(),
		"mappings": MAPPINGS.duplicate(),
		"applicable": ["button", "refill", "save", "close"],
		"not_applicable": ["splash", "sculpture_save"],
	})


func _watch(node: Node) -> void:
	var entered := Callable(self, "_watch")
	if not node.child_entered_tree.is_connected(entered):
		node.child_entered_tree.connect(entered)
	if node is BaseButton:
		var pressed := Callable(self, "_button_pressed").bind(node)
		if not node.pressed.is_connected(pressed):
			node.pressed.connect(pressed)
	if node is Control and node.has_meta("sound_cue_on_gui_activate"):
		var activated := Callable(self, "_control_activated").bind(node)
		if not node.gui_input.is_connected(activated):
			node.gui_input.connect(activated)
	if node.has_signal("sound_cue_requested"):
		var requested := Callable(self, "_cue_requested")
		if not node.is_connected("sound_cue_requested", requested):
			node.connect("sound_cue_requested", requested)
	for child in node.get_children():
		_watch(child)


func _button_pressed(button: BaseButton) -> void:
	var cue := String(button.get_meta("sound_cue", "button"))
	if cue != "none":
		play_cue(cue)


func _control_activated(event: InputEvent, control: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		play_cue(String(control.get_meta("sound_cue_on_gui_activate", "button")))


func _cue_requested(cue: String) -> void:
	play_cue(cue)


func _exit_tree() -> void:
	player.stop()
	player.stream = null
	streams.clear()
