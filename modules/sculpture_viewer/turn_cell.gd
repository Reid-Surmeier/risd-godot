## One cell of the setup panel's object grid that turns its museum object while the pointer is on it
## (Issue #110). Every frame is a Seedance take reduced into the cell (the museum-icon-hover-turn
## prototype); frame 0 is the approved icon. Entering drives the turn forward over TURN_SECONDS and
## holds the last frame; leaving plays it back from wherever it is to frame 0.
extends Control

const TURN_SECONDS := 0.7

var atlas: Texture2D
var frames := 1
var columns := 8
var tile := Vector2(216, 200)
var progress := 0.0
var target := 0.0
var frame := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_turn.bind(1.0))
	mouse_exited.connect(_turn.bind(0.0))
	set_process(false)


func _turn(to: float) -> void:
	target = to
	set_process(true)


func _process(delta: float) -> void:
	progress = move_toward(progress, target, delta / TURN_SECONDS)
	var next := roundi(progress * (frames - 1))
	if next != frame:
		frame = next
		queue_redraw()
	if progress == target:
		set_process(false)


func _draw() -> void:
	var source := Rect2(Vector2(frame % columns, frame / columns) * tile, tile)
	draw_texture_rect_region(atlas, Rect2(Vector2.ZERO, size), source)
