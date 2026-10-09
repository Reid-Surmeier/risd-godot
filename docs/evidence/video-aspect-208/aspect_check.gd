extends "res://testing/harness_base.gd"
const Shell := preload("res://modules/shell/interface.gd")
var stage: Control
var shell: Control
var player: Control
var failures := 0
var observations: Array = []
func _initialize() -> void:
	call_deferred("run")
func screen(point: Vector2) -> Vector2:
	return stage.stage_rect.position + point / 1080.0 * stage.stage_rect.size
func movie_rect() -> Rect2:
	# Inspect the actual native movie-drawing Control; old VideoStreamPlayer expands directly.
	var image = player.find_child("movie-image", true, false)
	return (
		image.get_global_rect()
		if image else Shell.tenant_state(shell, "video_player").value.video_rect
	)
func check_aspect(label: String) -> void:
	var source: Vector2 = player.find_child("video", true, false).get_video_texture().get_size()
	var rect := movie_rect()
	var ratio_ok: bool = (
		source.x > 0 and source.y > 0 and abs(rect.size.aspect() - source.aspect()) < 0.002
	)
	var state: Dictionary = Shell.tenant_state(shell, "video_player").value
	observations.append({
		"label": label, "pass": ratio_ok, "source": source, "image_rect": rect, "state": state
	})
	print("PASS " if ratio_ok else "FAIL ", label, " image=", rect, " source=", source)
	if not ratio_ok: failures += 1
func run() -> void:
	stage = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(stage, Vector2i(1080,1080), "/tmp/risd-aspect-208")
	stage.enabled = false
	stage.squiggle.visible = false
	stage.haze.visible = false
	await create_timer(1.5).timeout
	shell = stage.get_node("Desktop/Content/Shell")
	var chrome = stage.find_child("SquareChrome", true, false)
	await _click(screen(chrome.tab_buttons[3].get_global_rect().get_center()), "mouse select Video")
	await create_timer(0.8).timeout
	player = stage.find_child("VideoPlayer", true, false)
	for index in 5:
		await _key(KEY_1 + index, "select source movie")
		await create_timer(0.6).timeout
		check_aspect("source-%d-window" % index)
		await _key(KEY_F, "fullscreen source movie")
		await _frames(3)
		check_aspect("source-%d-fullscreen" % index)
		await _key(KEY_F, "restore source movie")
	await _key(KEY_1, "select Observer for captures")
	await create_timer(0.7).timeout
	for i in 4: await _key(KEY_RIGHT, "seek actual movie")
	await create_timer(0.5).timeout
	await _key(KEY_SPACE, "pause actual movie")
	await _shot(out,"window.png")
	await _key(KEY_F, "fullscreen actual movie")
	await _frames(3)
	await _shot(out,"fullscreen.png")
	for shape in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(486,720)]:
		get_root().size = shape
		await _frames(4)
		check_aspect("fullscreen-fit-%dx%d" % [shape.x,shape.y])
		await _shot(out,"fullscreen-%dx%d.png" % [shape.x,shape.y])
	await _key(KEY_F, "return after resized fullscreen")
	check_aspect("window-return")
	await _shot(out,"window-return.png")
	FileAccess.open(out.path_join("observations.json"),FileAccess.WRITE).store_string(
		JSON.stringify(observations,"  ")
	)
	print("ASPECT208 failures=",failures)
	quit(1 if failures else 0)
