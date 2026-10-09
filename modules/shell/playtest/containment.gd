## #173 host transform regression, including touch/gesture and exterior drag release.
extends SceneTree


class Probe:
	extends Node
	var events: Array[InputEvent] = []

	func _input(event: InputEvent) -> void:
		events.append(event)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := preload("res://modules/shell/demo.tscn").instantiate()
	root.add_child(stage)
	await process_frame
	var probe := Probe.new()
	stage.get_node("Desktop").add_child(probe)
	for extent in [
		Vector2i(1080, 1080),
		Vector2i(1920, 1080),
		Vector2i(1080, 1920),
		Vector2i(720, 486),
		Vector2i(486, 720)
	]:
		root.size = extent
		await process_frame
		await process_frame
		var side: float = mini(extent.x, extent.y)
		assert(
			(
				stage.stage_rect
				== Rect2((Vector2(extent) - Vector2.ONE * side) / 2.0, Vector2.ONE * side)
			)
		)
		var at: Vector2 = stage.stage_rect.get_center()
		for event in [
			InputEventMouseMotion.new(),
			InputEventScreenTouch.new(),
			InputEventScreenDrag.new(),
			InputEventPanGesture.new(),
			InputEventMagnifyGesture.new()
		]:
			event.position = at
			probe.events.clear()
			stage._input(event)
			assert(not probe.events.is_empty(), "mapped input delivered")
			assert(probe.events.back().position.distance_to(Vector2(540, 540)) < 0.01)
		var press := InputEventMouseButton.new()
		press.position = at
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		stage._input(press)
		var release := press.duplicate()
		release.position = Vector2(-5, -5)
		release.pressed = false
		probe.events.clear()
		stage._input(release)
		assert(
			probe.events.size() == 1 and not probe.events[0].pressed,
			"outside release ends captured press"
		)
		probe.events.clear()
		press.position = Vector2(-5, -5)
		stage._input(press)
		assert(probe.events.is_empty(), "outside press ignored")
	print("PASS: five square fits; mouse, touch, drag, pan, magnify mapping; exterior release")
	quit()
