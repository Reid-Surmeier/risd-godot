## Throwaway standalone complete-loop prototype. Generation and explosion art are fixtures.
extends Control

const PHOTO = preload("assets/photo-fixture.png")
const PORTRAIT = preload("assets/sample-portrait.webp")
const CAMERA_FRAME = preload("assets/camera-frame.png")
const GLOVES = preload("assets/glove-frame-reference.png")
const LOADING_SHADER = preload("assets/loading.gdshader")

var state := "camera"
var source := "none"
var elapsed := 0.0
var frame_clock := 0.0
var live_texture: ImageTexture
var captured: Texture2D
var background: TextureRect
var picture: TextureRect
var caption: Label
var capture_button: Button
var fixture_button: Button
var camera_button: Button
var cancel_button: Button
var countdown: ProgressBar
var loader: ColorRect
var entered_at := 0.0


func _ready() -> void:
	entered_at = _now()
	background = _picture(CAMERA_FRAME, Rect2(0, 0, 1024, 650))
	picture = _picture(null, Rect2(135, 235, 755, 285))
	loader = ColorRect.new()
	loader.size = Vector2(1024, 650)
	loader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loader.material = ShaderMaterial.new()
	loader.material.shader = LOADING_SHADER
	add_child(loader)
	caption = Label.new()
	caption.position = Vector2(30, 653)
	caption.size = Vector2(964, 42)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_color_override("font_color", Color(0.18, 0.18, 0.18))
	add_child(caption)
	camera_button = _button("Enable camera", Vector2(245, 590), _enable_camera)
	fixture_button = _button("Try sample photo", Vector2(420, 590), _use_fixture)
	capture_button = _button("Take picture", Vector2(620, 590), capture)
	cancel_button = _button("Return to camera", Vector2(790, 590), reset)
	countdown = ProgressBar.new()
	countdown.position = Vector2(160, 550)
	countdown.size = Vector2(704, 18)
	countdown.show_percentage = false
	add_child(countdown)
	_sync()


func _picture(texture: Texture2D, rect: Rect2) -> TextureRect:
	var view := TextureRect.new()
	view.texture = texture
	view.position = rect.position
	view.size = rect.size
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(view)
	return view


func _button(text: String, pos: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(165, 38)
	button.pressed.connect(action)
	add_child(button)
	return button


func _enable_camera() -> void:
	if not OS.has_feature("web"):
		caption.text = "Open the Web build to enable your camera, or try the sample photo."
		return
	picture.texture = null
	live_texture = null
	source = "requesting"
	JavaScriptBridge.eval("window.booth.start()")
	_sync()


func _use_fixture() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.booth.stop()")
	source = "fixture"
	picture.texture = PHOTO
	_sync()


func capture() -> void:
	if state != "camera" or source not in ["fixture", "camera"] or picture.texture == null:
		return
	captured = picture.texture
	state = "loading"
	entered_at = _now()
	elapsed = 0.0
	_sync()


func reset() -> void:
	state = "camera"
	entered_at = _now()
	elapsed = 0.0
	captured = null
	picture.texture = PHOTO if source == "fixture" else live_texture
	_sync()


func _process(delta: float) -> void:
	elapsed = _now() - entered_at
	loader.material.set_shader_parameter("progress", minf(elapsed / 4.0, 1.0))
	if state == "loading" and elapsed >= 4.0:
		state = "portrait"
		entered_at = _now()
		elapsed = 0.0
		picture.texture = PORTRAIT
		_sync()
	elif state == "portrait":
		countdown.value = maxf(0.0, 100.0 * (1.0 - elapsed / 10.0))
		if elapsed >= 10.0:
			state = "explosion"
			entered_at = _now()
			elapsed = 0.0
			picture.texture = null
			captured = null
			_sync()
	elif state == "explosion" and elapsed >= 0.6:
		reset()
	if state == "camera" and OS.has_feature("web") and source in ["requesting", "camera"]:
		frame_clock += delta
		if frame_clock >= 0.1:
			frame_clock = 0.0
			_poll_camera()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.boothState = %s" % JSON.stringify({"state": state, "source": source, "elapsed": elapsed, "has_capture": captured != null, "fixture_generation": true}))



func _poll_camera() -> void:
	var status = JSON.parse_string(JavaScriptBridge.eval("window.booth.status()"))
	if status.mode == "none":
		source = "none"
		live_texture = null
		picture.texture = null
		_sync()
	elif status.mode == "denied":
		source = "denied"
		live_texture = null
		picture.texture = null
		_sync()
		caption.text = "Camera unavailable (%s). Try again or use the sample photo." % status.error
	elif status.mode == "camera":
		var encoded = JavaScriptBridge.eval("window.booth.frame()")
		if encoded is String and not encoded.is_empty():
			var image := Image.new()
			if image.load_jpg_from_buffer(Marshalls.base64_to_raw(encoded)) == OK:
				if live_texture == null:
					live_texture = ImageTexture.create_from_image(image)
				else:
					live_texture.update(image)
				picture.texture = live_texture
				source = "camera"
				_sync()


func _sync() -> void:
	var camera := state == "camera"
	loader.visible = state == "loading"
	camera_button.visible = camera
	fixture_button.visible = camera
	capture_button.visible = camera
	capture_button.disabled = source not in ["fixture", "camera"] or picture.texture == null
	cancel_button.visible = not camera
	countdown.visible = state == "portrait"
	background.visible = state not in ["loading", "explosion"]
	background.texture = CAMERA_FRAME if camera else GLOVES
	picture.visible = state not in ["loading", "explosion"]
	picture.position = Vector2(135, 235) if camera else Vector2(235, 95)
	picture.size = Vector2(755, 285) if camera else Vector2(550, 410)
	caption.text = "Sample preview — generated portrait and explosion artwork are pending."
	if source == "none":
		caption.text = "Enable your camera or try the sample photo."
	elif source == "requesting":
		caption.text = "Waiting for camera permission…"
	if state == "loading":
		caption.text = "Preparing the sample portrait…"
	elif state == "portrait":
		countdown.value = 100.0
		caption.text = "Sample-photo portrait — live captures are not generated yet."
	elif state == "explosion":
		caption.text = "Poof! Returning to camera… (animation pending)"


func _now() -> float:
	if OS.has_feature("web"):
		return float(JavaScriptBridge.eval("performance.now()")) / 1000.0
	return float(Time.get_ticks_msec()) / 1000.0
