## The project's main scene: loads the game, puts it underneath, and shows every tab once so its
## first real click is instant (the Shell creates a Tab's Tenant on its first show).
##
## On the Web the page draws the loading screen (web/loading_shell.html, in a Web Worker so it keeps
## moving while this thread is busy building tabs) and has already downloaded the game pack into
## /tmp/game.pck; this scene mounts it, loads and warms the game, reports progress to the page
## (window.loaderSetProgress) and says when it is done (window.loaderDone). The boot pack holds
## only this scene.
##
## On desktop there is no page, so this scene draws the same loading screen itself: the four
## noise-driven dots and the bar in a SubViewport slightly smaller than the window (a subtle pixel
## reduction), tape_screen.gdshader for a light colour bleed and edge halo; at the end the dots drift
## slowly outward and fade with the white.
extends Control

const MAIN_SCENE := "res://modules/shell/demo.tscn"
const TapeShader := preload("res://modules/shell/tape_screen.gdshader")
const COLORS := [
	Color(0.98, 0.92, 0.58),
	Color(0.99, 0.65, 0.63),
	Color(0.67, 0.79, 0.96),
	Color(0.83, 0.93, 0.63)
]
const WHITE := Color(0.996, 0.996, 0.996)
const EXIT_SECONDS := 1.8
const GAME_PACK := "/tmp/game.pck"  # written by web/loading_shell.html (engine.preloadFile)
# loaded after the pack is mounted: not in the boot pack
const SHELL_INTERFACE := "res://modules/shell/interface.gd"
const MIN_SECONDS := 4.0  # the bar fills at a steady pace, never faster than empty-to-full in this
# long, so a quick load still reads as loading (same pace as the HTML page)

@export var pixel_reduction := 1.25  # the tape is the window divided by this (same in the page)

var drawing := not OS.has_feature("web")  # on the Web the page draws the loading screen
var clock := 0.0
var progress := 0.0  # 0..1 shown by the bar (eases toward target)
var target := 0.0
var exit := -1.0  # < 0 while loading, then 0..1
var exit_clock := 0.0
var stage_rect := Rect2()
var tape: SubViewport
var stage: Node2D
var screen: TextureRect
var ring: ImageTexture  # one dot's soft ring, white with the falloff in alpha
var noise := FastNoiseLite.new()
var loading_path := ""
var game: Node  # loaded and under the loading screen; the exit waits for the bar to be full
var warm := false  # every tab has been shown once


func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 1.0
	ring = _bake_ring()
	_mark("godot-ready")
	# the page's downloads are the first 85%
	var start_progress := 0.85 if OS.has_feature("web") else 0.0
	progress = start_progress
	target = start_progress
	if drawing:
		_build_screen()

	if OS.has_feature("web") and not ResourceLoader.exists(MAIN_SCENE):
		if not ProjectSettings.load_resource_pack(GAME_PACK):
			push_error("boot_loader: cannot mount %s" % GAME_PACK)
			return
		_mark("pack-mounted")
	_load_game(start_progress)


func _build_screen() -> void:
	tape = SubViewport.new()
	tape.transparent_bg = true  # the stage draws its own white, which fades out at the exit
	tape.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(tape)
	stage = Node2D.new()
	stage.draw.connect(_draw_stage)
	tape.add_child(stage)

	var layer := CanvasLayer.new()
	layer.layer = 100  # above the Shell's Squigglevision (10) and haze (11) passes
	add_child(layer)
	screen = TextureRect.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.stretch_mode = TextureRect.STRETCH_SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # the soft upscale of a low-res signal
	screen.material = ShaderMaterial.new()
	screen.material.shader = TapeShader
	screen.mouse_filter = Control.MOUSE_FILTER_STOP  # the game underneath waits until the exit
	screen.texture = tape.get_texture()
	layer.add_child(screen)
	get_viewport().size_changed.connect(_fit_tape)
	_fit_tape()


## For modules/shell/playtest/perf_web.py: a named moment of the load, and the bar's value.
func _mark(name: String) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(
			(
				"(window.loadPerf = window.loadPerf || []).push({name: '%s', t: performance.now()})"
				% name
			)
		)


func _fit_tape() -> void:
	var window := get_viewport().get_visible_rect().size
	tape.size = Vector2i((window / pixel_reduction).max(Vector2(64, 36)).round())
	stage_rect = Rect2(Vector2.ZERO, Vector2(tape.size))


func _process(delta: float) -> void:
	clock += delta
	progress = move_toward(progress, target, delta / MIN_SECONDS)
	if loading_path != "":
		_poll_load()
	if warm and not drawing:  # the page runs the exit
		JavaScriptBridge.eval("window.loaderDone && window.loaderDone()")
		queue_free()
		return
	if warm and exit < 0.0 and progress >= 1.0:
		_begin_exit()
	if exit >= 0.0:
		exit = minf(1.0, (clock - exit_clock) / EXIT_SECONDS)
		if exit >= 1.0:
			queue_free()
			return
	if drawing:
		stage.queue_redraw()


## The dots and the bar in "st" units: (0, 0) the middle, 1.0 the tape's height, y up.
func _to_px(st: Vector2) -> Vector2:
	return stage_rect.size * 0.5 + Vector2(st.x, -st.y) * stage_rect.size.y


func _noise01(x: float) -> float:
	return noise.get_noise_1d(x) * 0.5 + 0.5


func _draw_stage() -> void:
	var h := stage_rect.size.y
	var fade := 1.0 - smoothstep(0.15, 0.85, maxf(exit, 0.0))
	# ease-out: the orbit slowly widens
	var spread := 1.0 + 2.2 * (1.0 - pow(1.0 - maxf(exit, 0.0), 2.0))
	var dot_alpha := 1.0 - smoothstep(0.2, 1.0, maxf(exit, 0.0))
	stage.draw_rect(stage_rect, Color(WHITE, fade))
	var center := Vector2(0.0, 0.064)
	for i in 4:
		var t := clock * 0.8 + i * 10.0
		var angle := clock * 1.5 + i * PI / 2.0 + (_noise01(t) - 0.5) * 1.5
		var radius := 0.066 + (_noise01(t + 50.0) - 0.5) * 0.04
		var pos := center + radius * spread * Vector2(cos(angle), sin(angle))
		_draw_dot(_to_px(pos), h, Color(COLORS[i], dot_alpha))
	var bar := Rect2(_to_px(Vector2(-0.080, -0.4025)), Vector2(0.14, 0.015) * h)
	var round_px := int(round(bar.size.y * 0.5))
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.975, 0.975, 0.975, fade)
	track.border_color = Color(0.92, 0.92, 0.92, fade)
	track.set_border_width_all(1)
	track.set_corner_radius_all(round_px)
	track.anti_aliasing = false  # stepped edges, like the reference's reduced pixels
	stage.draw_style_box(track, bar)
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = Color(0.885, 0.885, 0.885, fade)
	fill.set_border_width_all(0)
	stage.draw_style_box(
		fill, Rect2(bar.position, Vector2(bar.size.x * lerpf(0.04, 1.0, progress), bar.size.y))
	)


## One soft ring, the HTML loader's profile: strongest at 0.0096 of the height, paler in the
## middle, blurry out to 0.036. Baked once at 64 px, drawn small (the tape's resolution) and tinted.
func _bake_ring() -> ImageTexture:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in 64:
		for x in 64:
			var d := Vector2(x + 0.5 - 32.0, y + 0.5 - 32.0).length() / 32.0 * 0.036
			image.set_pixel(x, y, Color(1, 1, 1, exp(-pow((d - 0.0096) / 0.0112, 2.0))))
	return ImageTexture.create_from_image(image)


func _draw_dot(center: Vector2, h: float, color: Color) -> void:
	var r := 0.036 * h
	stage.draw_texture_rect(ring, Rect2(center - Vector2(r, r), Vector2(r, r) * 2.0), false, color)


## The bar's goal; on the Web the page's bar is told (it keeps the steady pace itself).
func _set_target(value: float) -> void:
	if value <= target:
		return
	target = value
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.loaderSetProgress && window.loaderSetProgress(%f)" % target)


func _load_game(from: float) -> void:
	_set_target(from)
	loading_path = MAIN_SCENE
	ResourceLoader.load_threaded_request(MAIN_SCENE)
	set_meta("load_from", target)


func _poll_load() -> void:
	var fraction := []
	var status := ResourceLoader.load_threaded_get_status(loading_path, fraction)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		_set_target(lerpf(get_meta("load_from"), 0.9, float(fraction[0])))
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		loading_path = ""
		_set_target(0.9)
		_mark("game-loaded")
		game = (ResourceLoader.load_threaded_get(MAIN_SCENE) as PackedScene).instantiate()
		get_tree().root.add_child(game)
		get_tree().root.move_child(game, get_index())  # under the loading screen
		get_tree().current_scene = game
		_mark("game-instanced")
		_warm_up()
	else:
		loading_path = ""
		push_error("boot_loader: loading %s failed (%d)" % [MAIN_SCENE, status])


## Show every tab once under the loading screen, then return to the launch tab: the Shell creates a
## Tab's Tenant (and the renderer compiles its shaders) on its first show, which froze the first
## click on Sketchbook for 1.8 s and on the 3D Viewer for 1.1 s (perf_web.py, 2026-09-23).
func _warm_up() -> void:
	var Shell: Script = load(SHELL_INTERFACE)
	var shell: Control = game.get_node_or_null("Desktop/Content/Shell")
	# headless draws nothing: nothing to warm
	if shell == null or DisplayServer.get_name() == "headless":
		warm = true
		_set_target(1.0)
		return
	_mark("warmup-start")
	var launch := -1
	for _i in 300:  # the launch: the Collection tab grows in and its page fades in
		await get_tree().process_frame
		var s: Dictionary = Shell.state(shell).value
		if s.active >= 0 and not s.switching and not s.opening:
			launch = s.active
			break
	_mark("launch-settled")
	var order := []
	for i in 6:
		if i != launch:
			order.append(i)
	order.append(launch)
	for n in order.size():
		_mark("tab-%d-start" % order[n])
		if Shell.select_tab(shell, order[n]).ok:
			_mark("tab-%d-selected" % order[n])
			for _i in 120:  # its cross-fade, then two frames drawn with it on screen
				await get_tree().process_frame
				if not Shell.state(shell).value.switching:
					break
			await get_tree().process_frame
			await get_tree().process_frame
		_mark("tab-%d-drawn" % order[n])
		_set_target(lerpf(0.9, 1.0, float(n + 1) / order.size()))
	_mark("tabs-warm")
	warm = true


func _begin_exit() -> void:
	exit_clock = clock
	exit = 0.0
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
