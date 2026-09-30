## Standalone ephemeral booth composition.
extends "interface.gd"

const CAMERA_FRAME = preload("assets/camera-frame.png")
const GLOVES = preload("assets/glove-frame.png")
const MOTION = preload("assets/fuse-explosion.ogv")
const MATTE_SHADER = preload("assets/matte.gdshader")
const EXPRESSION_SHADER = preload("assets/expression.gdshader")
const LOADING_SHADER = preload("assets/loading.gdshader")
const FRAME_SHADER = preload("assets/camera-frame.gdshader")

var state := "camera"
var source := "none"
var elapsed := 0.0
var frame_clock := 0.0
var live_texture: ImageTexture
var captured: Texture2D
var background: TextureRect
var picture: TextureRect
var caption: Label
var camera_button: TextureButton
var frame_material: ShaderMaterial
var matte_material: ShaderMaterial
var cancel_button: Button
var loader: ColorRect
var motion: VideoStreamPlayer
var expression_material: ShaderMaterial
var expression_value := Vector4.ZERO
var pose_value := Vector3.ZERO
var tracking_mode := "idle"
var entered_at := 0.0
var generation_error := ""
var loading_completed := 0


func _ready() -> void:
	entered_at = _now()
	picture = _picture(null, Rect2(113, 65, 805, 438))
	background = _picture(CAMERA_FRAME, Rect2(0, 0, 1024, 650))
	frame_material = ShaderMaterial.new()
	frame_material.shader = FRAME_SHADER
	matte_material = ShaderMaterial.new()
	matte_material.shader = MATTE_SHADER
	expression_material = ShaderMaterial.new()
	expression_material.shader = EXPRESSION_SHADER
	loader = ColorRect.new()
	loader.size = Vector2(1024, 650)
	loader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loader.material = ShaderMaterial.new()
	loader.material.shader = LOADING_SHADER
	add_child(loader)
	motion = VideoStreamPlayer.new()
	motion.stream = MOTION
	motion.position = Vector2.ZERO
	motion.size = Vector2(1024, 650)
	motion.expand = true
	motion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	motion.material = matte_material
	motion.finished.connect(reset)
	add_child(motion)
	caption = Label.new()
	caption.position = Vector2(30, 653)
	caption.size = Vector2(964, 42)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_color_override("font_color", Color(0.18, 0.18, 0.18))
	add_child(caption)
	camera_button = TextureButton.new()
	var icon := AtlasTexture.new()
	icon.atlas = CAMERA_FRAME
	icon.region = Rect2(491, 536, 48, 49)
	camera_button.texture_normal = icon
	camera_button.position = Vector2(491, 536)
	camera_button.pressed.connect(func():
		if source == "camera":
			capture()
		else:
			_enable_camera()
	)
	add_child(camera_button)
	cancel_button = _button("Return to camera", Vector2(790, 590), reset)
	if OS.has_feature("web"):
		source = "requesting"
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
	generation_error = ""
	if not OS.has_feature("web"):
		caption.text = "Open the Web build to enable your camera."
		return
	picture.texture = null
	live_texture = null
	source = "requesting"
	JavaScriptBridge.eval("window.booth.start()")
	_sync()


func capture() -> Dictionary:
	if state != "camera" or source != "camera" or picture.texture == null:
		return {"ok": false, "value": null, "error": "invalid_capture"}
	captured = picture.texture
	generation_error = ""
	if source == "camera" and OS.has_feature("web"):
		var encoded := "data:image/png;base64," + Marshalls.raw_to_base64(captured.get_image().save_png_to_buffer())
		JavaScriptBridge.eval("window.booth.generate(%s)" % JSON.stringify(encoded))
	loading_completed = 0
	state = "loading"
	entered_at = _now()
	elapsed = 0.0
	_sync()
	return {"ok": true, "value": null, "error": null}


func reset() -> Dictionary:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.booth.cancelGeneration(); window.booth.stopTracking()")
	tracking_mode = "idle"
	expression_value = Vector4.ZERO
	pose_value = Vector3.ZERO
	picture.material = null
	motion.stop()
	state = "camera"
	entered_at = _now()
	elapsed = 0.0
	captured = null
	picture.texture = live_texture
	_sync()
	return {"ok": true, "value": null, "error": null}


func _process(delta: float) -> void:
	if OS.has_feature("web"):
		var action = JavaScriptBridge.eval("window.booth.consumeAction()")
		match action:
			"camera":
				_enable_camera()
			"capture":
				capture()
			"reset":
				reset()
	elapsed = _now() - entered_at
	if state == "loading":
		if source == "camera" and OS.has_feature("web"):
			var result = JSON.parse_string(JavaScriptBridge.eval("window.booth.generated()"))
			loading_completed = clampi(int(result.get("completed", 0)), 0, 4)
			loader.material.set_shader_parameter("progress", float(loading_completed) / 4.0)
			if result.mode == "idle":
				reset()
			elif result.mode == "ready":
				var image := Image.new()
				var bytes := Marshalls.base64_to_raw(result.image.split(",")[1])
				var code := image.load_webp_from_buffer(bytes) if result.image.begins_with("data:image/webp") else image.load_png_from_buffer(bytes)
				if code == OK:
					_show_portrait(ImageTexture.create_from_image(image))
				else:
					generation_error = "The portrait could not be displayed. Take another picture."
					reset()
			elif result.mode == "error":
				generation_error = result.error
				reset()
				caption.text = generation_error
	elif state == "portrait":
		_update_expression(delta)
		if motion.stream_position >= 10.0:
			if OS.has_feature("web"):
				JavaScriptBridge.eval("window.booth.stopTracking()")
			state = "explosion"
			entered_at = _now()
			elapsed = 0.0
			picture.texture = null
			captured = null
			_sync()
	if state == "camera" and OS.has_feature("web") and source in ["requesting", "camera"]:
		frame_clock += delta
		if frame_clock >= 0.1:
			frame_clock = 0.0
			_poll_camera()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.boothState = %s" % JSON.stringify({"state": state, "source": source, "elapsed": elapsed, "has_capture": captured != null, "loading_completed": loading_completed, "motion_time": motion.stream_position, "motion_playing": motion.is_playing(), "message": caption.text, "tracking": tracking_mode, "expression": [expression_value.x, expression_value.y, expression_value.z, expression_value.w]}))



func _show_portrait(texture: Texture2D) -> void:
	state = "portrait"
	picture.texture = texture
	expression_value = Vector4.ZERO
	pose_value = Vector3.ZERO
	picture.material = expression_material
	expression_material.set_shader_parameter("expression", expression_value)
	expression_material.set_shader_parameter("pose", pose_value)
	if OS.has_feature("web"):
		var image := texture.get_image()
		if image.is_compressed():
			image.decompress()
		var encoded := "data:image/png;base64," + Marshalls.raw_to_base64(image.save_png_to_buffer())
		JavaScriptBridge.eval("window.booth.startTracking(%s)" % JSON.stringify(encoded))
	motion.play()
	entered_at = _now()
	elapsed = 0.0
	_sync()


func _update_expression(delta: float) -> void:
	if not OS.has_feature("web"):
		return
	var result = JSON.parse_string(JavaScriptBridge.eval("window.booth.tracking()"))
	tracking_mode = result.mode
	var target := Vector4.ZERO
	var pose_target := Vector3.ZERO
	if result.mode == "ready" and result.has("anchors"):
		var anchors = result.anchors
		expression_material.set_shader_parameter("eye_left", Vector2(anchors.left[0], anchors.left[1]))
		expression_material.set_shader_parameter("eye_right", Vector2(anchors.right[0], anchors.right[1]))
		expression_material.set_shader_parameter("mouth", Vector2(anchors.mouth[0], anchors.mouth[1]))
		expression_material.set_shader_parameter("mouth_width", anchors.mouthWidth)
		if result.face and result.has("values"):
			var values = result.values
			target = Vector4(values.blinkL, values.blinkR, values.smile, values.jaw)
			pose_target = Vector3(result.pose.x, result.pose.y, result.pose.angle)
	expression_value = expression_value.lerp(target, minf(delta * 12.0, 1.0))
	pose_value = pose_value.lerp(pose_target, minf(delta * 12.0, 1.0))
	expression_material.set_shader_parameter("expression", expression_value)
	expression_material.set_shader_parameter("pose", pose_value)
	if source == "camera":
		caption.text = "Your portrait — smile or blink. Ten seconds."
		if tracking_mode == "unavailable":
			caption.text = "Your portrait — ten seconds. Animation unavailable."


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
		caption.text = "Camera unavailable (%s). Try again." % status.error
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
	var native := not OS.has_feature("web")
	caption.visible = native
	loader.visible = state == "loading"
	camera_button.visible = camera and native
	camera_button.disabled = source == "requesting"
	cancel_button.visible = not camera and native
	motion.visible = state in ["portrait", "explosion"]
	background.visible = state not in ["loading", "explosion"]
	background.texture = CAMERA_FRAME if camera else GLOVES
	background.material = frame_material if camera else matte_material
	picture.visible = state not in ["loading", "explosion"]
	picture.position = Vector2(113, 65) if camera else Vector2(283, 124)
	picture.size = Vector2(805, 438) if camera else Vector2(448, 409)
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if camera else TextureRect.STRETCH_SCALE
	if camera:
		picture.material = null
	caption.text = "Compose your picture, then press the blue button."
	if source == "none":
		caption.text = "Press the blue button to enable your camera."
	elif source == "requesting":
		caption.text = "Waiting for camera permission…"
	if camera and not generation_error.is_empty():
		caption.text = generation_error
	if state == "loading":
		caption.text = "Creating your portrait…"
	elif state == "portrait":
		caption.text = "Your portrait — ten seconds."
	elif state == "explosion":
		caption.text = "Poof! Returning to camera…"


func _now() -> float:
	if OS.has_feature("web"):
		return float(JavaScriptBridge.eval("performance.now()")) / 1000.0
	return float(Time.get_ticks_msec()) / 1000.0
