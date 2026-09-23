## The game's loading screen, rendered by Godot so it can be degraded the way analog video is
## (the owner's reference: a VHS-style capture, 2026-09-22). The four noise-driven dots and the
## progress bar are drawn into a small SubViewport (real pixel reduction); every tape frame is
## JPEG-compressed and decoded back (real block artifacts); tape_screen.gdshader adds the colour
## bleed, the edge halo and the cool light flashes that change with each hold.
##
## It is the project's main scene. On the Web the boot pack holds only this scene: it downloads
## the game pack beside the page (<build>.game.pck.gz, see scripts/export-web.sh), mounts it, then
## loads MAIN_SCENE; on desktop the game is already in res:// and only the load runs. The game is
## put under the loading screen, the dots fly out to the four corners while the white fades, and
## the loading screen frees itself. web/loading_shell.html covers the engine download before this
## scene exists and hands over its clock and progress (window.loaderHandoff).
extends Control

const MAIN_SCENE := "res://modules/shell/demo.tscn"
const TapeShader := preload("res://modules/shell/tape_screen.gdshader")
const COLORS := [Color(0.98, 0.92, 0.58), Color(0.99, 0.65, 0.63), Color(0.67, 0.79, 0.96), Color(0.83, 0.93, 0.63)]
const WHITE := Color(0.996, 0.996, 0.996)
const EXIT_SECONDS := 1.1
const MIN_SECONDS := 4.0  # the bar fills at a steady pace, never faster than empty-to-full in this
                          # long, so a quick load still reads as loading (same pace as the HTML page)

@export var pixel_reduction := 4.0  # the tape is the window divided by this
@export var tape_fps := 12.0        # how often a new compressed frame is taken
@export var jpeg_quality := 0.4     # 0..1, lower = blockier
@export var hold_seconds := 0.33    # the reference's holds: the light changes on this beat
@export var flash_chance := 0.3     # per hold, chance of a warm or cool light flash

var clock := 0.0          # seconds, continued from the HTML loader
var progress := 0.0       # 0..1 shown by the bar (eases toward target)
var target := 0.0
var exit := -1.0          # < 0 while loading, then 0..1
var exit_clock := 0.0
var stage_rect := Rect2()
var tape: SubViewport
var stage: Node2D
var screen: TextureRect
var tape_texture := ImageTexture.new()
var ring: ImageTexture  # one dot's soft ring, white with the falloff in alpha
var noise := FastNoiseLite.new()
var download: HTTPRequest
var loading_path := ""
var game: Node  # loaded and under the loading screen; the exit waits for the bar to be full
var since_tape := 0.0
var since_hold := 0.0


func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 1.0
	ring = _bake_ring()
	var start_progress := 0.0
	if OS.has_feature("web"):
		var handoff = JSON.parse_string(str(JavaScriptBridge.eval("JSON.stringify(window.loaderHandoff || {})")))
		if handoff is Dictionary:
			clock = float(handoff.get("t", 0.0))
			start_progress = float(handoff.get("progress", 0.0))
	progress = start_progress
	target = start_progress

	tape = SubViewport.new()
	tape.transparent_bg = false
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
	screen.texture = tape_texture
	layer.add_child(screen)
	get_viewport().size_changed.connect(_fit_tape)
	_fit_tape()
	_take_tape_frame()

	if OS.has_feature("web") and not ResourceLoader.exists(MAIN_SCENE):
		_download_game(start_progress)
	else:
		_load_game(start_progress)


func _fit_tape() -> void:
	var window := get_viewport().get_visible_rect().size
	tape.size = Vector2i((window / pixel_reduction).max(Vector2(64, 36)).round())
	stage_rect = Rect2(Vector2.ZERO, Vector2(tape.size))


func _process(delta: float) -> void:
	clock += delta
	progress = move_toward(progress, target, delta / MIN_SECONDS)
	if download != null and download.get_body_size() > 0:
		target = maxf(target, lerpf(download.get_meta("from"), 0.85, float(download.get_downloaded_bytes()) / download.get_body_size()))
	if loading_path != "":
		_poll_load()
	if game != null and exit < 0.0 and progress >= 1.0:
		_begin_exit()
	if exit >= 0.0:
		exit = minf(1.0, (clock - exit_clock) / EXIT_SECONDS)
		if exit >= 1.0:
			queue_free()
			return
	stage.queue_redraw()
	since_tape += delta
	since_hold += delta
	if exit < 0.0 and since_tape >= 1.0 / tape_fps:
		since_tape = 0.0
		_take_tape_frame()
	if since_hold >= hold_seconds:
		since_hold = 0.0
		_new_hold()


## The dots and the bar in "st" units: (0, 0) the middle, 1.0 the tape's height, y up.
func _to_px(st: Vector2) -> Vector2:
	return stage_rect.size * 0.5 + Vector2(st.x, -st.y) * stage_rect.size.y


func _noise01(x: float) -> float:
	return noise.get_noise_1d(x) * 0.5 + 0.5


func _draw_stage() -> void:
	var h := stage_rect.size.y
	var fade := 1.0 - smoothstep(0.15, 0.85, maxf(exit, 0.0))
	var fly := pow(maxf(exit, 0.0), 3.0)
	stage.draw_rect(stage_rect, Color(WHITE, fade))
	var corner := Vector2(0.5 * stage_rect.size.x / h, 0.5) * 1.3
	for i in 4:
		var t := clock * 0.8 + i * 10.0
		var angle := clock * 1.5 + i * PI / 2.0 + (_noise01(t) - 0.5) * 1.5
		var radius := 0.066 + (_noise01(t + 50.0) - 0.5) * 0.04
		var pos := Vector2(0.0, 0.064) + radius * Vector2(cos(angle), sin(angle))
		if exit >= 0.0:  # each dot leaves toward the corner of the orbit slot it held when the exit began
			var q := int(fposmod(exit_clock * 1.5 + i * PI / 2.0, TAU) / (PI / 2.0))
			pos = pos.lerp(Vector2(1.0 if q == 0 or q == 3 else -1.0, 1.0 if q < 2 else -1.0) * corner, fly)
		_draw_dot(_to_px(pos), h, COLORS[i])
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
	stage.draw_style_box(fill, Rect2(bar.position, Vector2(bar.size.x * lerpf(0.04, 1.0, progress), bar.size.y)))


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


## A tape frame: what the stage shows now, JPEG-compressed and decoded back. During the exit the
## screen shows the live stage instead (JPEG has no transparency and the game shows through).
func _take_tape_frame() -> void:
	if DisplayServer.get_name() == "headless":  # nothing is drawn, nothing to read back
		return
	var image := tape.get_texture().get_image()
	if image == null or image.is_empty():
		return
	var compressed := Image.new()
	if compressed.load_jpg_from_buffer(image.save_jpg_to_buffer(jpeg_quality)) != OK:
		return
	if tape_texture.get_size() == Vector2(compressed.get_size()):
		tape_texture.update(compressed)
	else:
		tape_texture.set_image(compressed)


## Each hold the light may change: a cool blue cast with a brightness jump, or none.
func _new_hold() -> void:
	var tint := Color.WHITE
	var gain := 0.0
	if randf() < flash_chance:  # cool only: the owner dropped the yellow ones (2026-09-22)
		tint = Color(randf_range(0.94, 0.97), randf_range(0.97, 0.99), 1.0)
		gain = randf_range(-0.03, 0.02)
	screen.material.set_shader_parameter("flash", Vector3(tint.r, tint.g, tint.b))
	screen.material.set_shader_parameter("flash_gain", gain)


func _download_game(from: float) -> void:
	download = HTTPRequest.new()
	download.download_chunk_size = 4 << 20  # the default 64 KB per frame took ~20 s to hand over 40 MB
	download.set_meta("from", from)
	download.request_completed.connect(_on_game_downloaded)
	add_child(download)
	var url: String = JavaScriptBridge.eval("new URL(location.pathname.split('/').pop().replace(/\\.html$/, '.game.pck.gz'), location.href).href")
	if download.request(url) != OK:
		push_error("boot_loader: could not request %s" % url)


func _on_game_downloaded(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	download.queue_free()
	download = null
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		push_error("boot_loader: game pack download failed (result %d, HTTP %d)" % [result, code])
		return
	var pack := body.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	var path := "/tmp/game.pck"  # memory filesystem: not persisted into the browser's storage
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("boot_loader: cannot write %s (%d)" % [path, FileAccess.get_open_error()])
		return
	file.store_buffer(pack)
	file.close()
	if not ProjectSettings.load_resource_pack(path):
		push_error("boot_loader: cannot mount the game pack")
		return
	_load_game(0.85)


func _load_game(from: float) -> void:
	target = maxf(target, from)
	loading_path = MAIN_SCENE
	ResourceLoader.load_threaded_request(MAIN_SCENE)
	set_meta("load_from", target)


func _poll_load() -> void:
	var fraction := []
	var status := ResourceLoader.load_threaded_get_status(loading_path, fraction)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		target = maxf(target, lerpf(get_meta("load_from"), 1.0, float(fraction[0]) * 0.95))
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		loading_path = ""
		target = 1.0
		game = (ResourceLoader.load_threaded_get(MAIN_SCENE) as PackedScene).instantiate()
		get_tree().root.add_child(game)
		get_tree().root.move_child(game, get_index())  # under the loading screen
		get_tree().current_scene = game
	else:
		loading_path = ""
		push_error("boot_loader: loading %s failed (%d)" % [MAIN_SCENE, status])


func _begin_exit() -> void:
	exit_clock = clock
	exit = 0.0
	tape.transparent_bg = true
	screen.texture = tape.get_texture()  # live and transparent from here: the game shows through
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
