extends Control

const Shell := preload("res://modules/shell/interface.gd")
const SquiggleShader := preload("res://modules/shell/squiggle_screen.gdshader")
const HazeShader := preload("res://modules/shell/haze_screen.gdshader")

var enabled := true
var squiggle_enabled := true  # owner restored the CRT + Squigglevision presentation
var _qa_elapsed := 0.0
var _qa_enabled := false
var _mouse_inside := false
var stage_rect := Rect2()
var pointer_buttons := {}
var touches := {}
var squiggle: ColorRect
var haze: ColorRect  # F10 or ?haze=0 turns it off, to compare
@onready var crt_material: ShaderMaterial = $Screen.material


func _ready() -> void:
	if not OS.has_feature("web"):
		get_window().size = Vector2i(1080, 1080)
	$Screen.texture = $Desktop.get_texture()
	crt_material.set_shader_parameter("tex", $Desktop.get_texture())
	_create_squiggle()
	_create_haze()
	resized.connect(_resize_desktop)
	_resize_desktop()
	get_window().mouse_exited.connect(_mouse_exited)
	if OS.has_feature("web"):
		enabled = not (
			JavaScriptBridge
			. eval(
				"new URLSearchParams(location.search).get('crt') === '0' || new URLSearchParams(location.search).has('qa-viewer')"
			)
		)
	_publish_state()
	_publish_squiggle_state()
	_qa_enabled = (
		OS.has_feature("web")
		and JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa-crt')")
	)


func _create_squiggle() -> void:
	var layer := CanvasLayer.new()
	layer.name = "SquiggleLayer"
	layer.layer = 10
	add_child(layer)
	squiggle = ColorRect.new()
	squiggle.name = "Squiggle"
	squiggle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	squiggle.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var material := ShaderMaterial.new()
	material.shader = SquiggleShader
	var noise := NoiseTexture2D.new()
	noise.width = 256
	noise.height = 256
	noise.seamless = true
	noise.seamless_blend_skirt = 1.0
	noise.noise = FastNoiseLite.new()
	material.set_shader_parameter("noise", noise)
	squiggle.material = material
	squiggle.visible = squiggle_enabled
	layer.add_child(squiggle)


func _create_haze() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HazeLayer"
	layer.layer = 11  # after Squigglevision: the very last pass
	add_child(layer)
	haze = ColorRect.new()
	haze.name = "Haze"
	haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	haze.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	haze.material = ShaderMaterial.new()
	haze.material.shader = HazeShader
	haze.visible = not (
		OS.has_feature("web")
		and JavaScriptBridge.eval("new URLSearchParams(location.search).get('haze') === '0'")
	)
	layer.add_child(haze)


func _resize_desktop() -> void:
	# One uniform fit for pixels, effects and every pointer event.
	$Desktop.size = Vector2i(1080, 1080)
	var side := minf(size.x, size.y)
	stage_rect = Rect2((size - Vector2.ONE * side) / 2.0, Vector2.ONE * side)
	for surface in [$Screen, squiggle, haze]:
		surface.position = stage_rect.position
		surface.size = stage_rect.size
	_publish_state()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		enabled = not enabled
		_publish_state()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		squiggle_enabled = not squiggle_enabled
		squiggle.visible = squiggle_enabled
		_publish_squiggle_state()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		haze.visible = not haze.visible
	else:
		if (
			event is InputEventMouse
			or event is InputEventGesture
			or event is InputEventScreenTouch
			or event is InputEventScreenDrag
		):
			var inside := stage_rect.has_point(event.position)
			var finishing := false
			if event is InputEventMouseButton:
				finishing = not event.pressed and pointer_buttons.has(event.button_index)
				if inside and event.pressed:
					pointer_buttons[event.button_index] = true
				elif not event.pressed:
					pointer_buttons.erase(event.button_index)
			elif event is InputEventScreenTouch:
				finishing = not event.pressed and touches.has(event.index)
				if inside and event.pressed:
					touches[event.index] = true
				elif not event.pressed:
					touches.erase(event.index)
			if not inside:
				_mouse_exited()
				# A drag started inside still needs its release, even in the white margin.
				if not finishing:
					return
		var mapped := event.duplicate()
		if event is InputEventMouse:
			if not _mouse_inside and stage_rect.has_point(event.position):
				$Desktop.notify_mouse_entered()
				_mouse_inside = true
			mapped.position = _screen_to_desktop(event.position)
			mapped.global_position = mapped.position
			if event is InputEventMouseMotion:
				mapped.relative = (
					mapped.position - _screen_to_desktop(event.position - event.relative)
				)
		elif event is InputEventGesture:
			mapped.position = _screen_to_desktop(event.position)
			if event is InputEventPanGesture:
				mapped.delta = mapped.position - _screen_to_desktop(event.position - event.delta)
		elif event is InputEventScreenTouch or event is InputEventScreenDrag:
			mapped.position = _screen_to_desktop(event.position)
			if event is InputEventScreenDrag:
				mapped.relative = (
					mapped.position - _screen_to_desktop(event.position - event.relative)
				)
		$Desktop.push_input(mapped, true)
	get_viewport().set_input_as_handled()


func _screen_to_desktop(point: Vector2) -> Vector2:
	point = (point - stage_rect.position) / stage_rect.size
	var logical_size := Vector2($Desktop.size)
	if not enabled:
		return point * logical_size
	# Same display-to-source warp as crt_luminance.gdshader.
	var uv := (point - Vector2(0.5, 0.5)) / float(crt_material.get_shader_parameter("screen_scale"))
	var aspect := logical_size.y / logical_size.x
	uv.x /= aspect
	var curve: float = crt_material.get_shader_parameter("curve")
	uv /= 1.0 - (uv.length_squared() - 0.25) * curve
	uv.x *= aspect
	return (uv + Vector2(0.5, 0.5)) * logical_size


func _publish_state() -> void:
	$Screen.material = crt_material if enabled else null
	if OS.has_feature("web"):
		JavaScriptBridge.eval(
			(
				"window.crtQaState = "
				+ JSON.stringify(
					{
						"enabled": enabled,
						"curve": crt_material.get_shader_parameter("curve"),
						"screen_scale": crt_material.get_shader_parameter("screen_scale"),
						"stage_rect":
						[
							stage_rect.position.x,
							stage_rect.position.y,
							stage_rect.size.x,
							stage_rect.size.y
						]
					}
				)
			)
		)


func _publish_squiggle_state() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(
			(
				"window.squiggleQaState = "
				+ JSON.stringify({"enabled": squiggle_enabled, "strength_pixels": 0.45, "fps": 3.0})
			)
		)


# Keep render coordinates current; only browser evidence is throttled.
func _process(delta: float) -> void:
	var quiet := Vector4.ZERO
	for view in get_tree().get_nodes_in_group("soft_render_view"):
		if view.is_visible_in_tree():
			var rect: Rect2 = view.get_global_rect()
			var extent := Vector2($Desktop.size)
			quiet = Vector4(
				rect.position.x / extent.x,
				rect.position.y / extent.y,
				rect.end.x / extent.x,
				rect.end.y / extent.y
			)
			break
	crt_material.set_shader_parameter("quiet_rect", Vector4.ZERO)  # keep CRT present over the gallery too
	haze.material.set_shader_parameter("quiet_rect", quiet)
	haze.material.set_shader_parameter(
		"desktop_aspect", float($Desktop.size.y) / float($Desktop.size.x)
	)
	haze.material.set_shader_parameter(
		"desktop_curve", crt_material.get_shader_parameter("curve") if enabled else 0.0
	)
	haze.material.set_shader_parameter(
		"desktop_scale", crt_material.get_shader_parameter("screen_scale") if enabled else 1.0
	)
	if not _qa_enabled:
		return
	_qa_elapsed += delta
	if _qa_elapsed < 0.25:
		return
	_qa_elapsed = 0.0
	var shell: Control = $Desktop/Content.get_node_or_null("Shell")
	if shell == null:
		return
	var state: Dictionary = Shell.state(shell).value
	var chrome: Control = $Desktop/Content.get_node("SquareChrome")
	for i in state.tabs.size():
		var tab: Dictionary = state.tabs[i]
		var rect: Rect2 = chrome.tab_buttons[i].get_global_rect() if i < 7 else tab.rect
		tab.rect = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	var tenant := {}
	if state.active >= 0 and state.active < state.tabs.size():
		var result := Shell.tenant_state(shell, state.tabs[state.active].key)
		if result.ok:
			tenant = result.value.duplicate()
			for key in tenant:
				if tenant[key] is Rect2:
					var rect: Rect2 = tenant[key]
					tenant[key] = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	var window_grips := []
	for grip in find_children("ProportionalResize", "Control", true, false):
		if not grip.is_visible_in_tree():
			continue
		var window: Control = grip.get_parent()
		var r: Rect2 = window.get_global_rect()
		var g: Rect2 = grip.get_global_rect()
		window_grips.append(
			{
				"name": str(window.name),
				"rect": [r.position.x, r.position.y, r.size.x, r.size.y],
				"grip": [g.position.x, g.position.y, g.size.x, g.size.y],
				"scale": [window.scale.x, window.scale.y]
			}
		)
	JavaScriptBridge.eval(
		(
			"window.shellCrtQa = "
			+ JSON.stringify(
				{
					"shell": state,
					"tenant": tenant,
					"window_grips": window_grips,
					"logical_size": [$Desktop.size.x, $Desktop.size.y],
					"display_size": [size.x, size.y],
					"stage_rect":
					[
						stage_rect.position.x,
						stage_rect.position.y,
						stage_rect.size.x,
						stage_rect.size.y
					]
				}
			)
		)
	)


func _mouse_exited() -> void:
	if _mouse_inside:
		$Desktop.notify_mouse_exited()
		_mouse_inside = false
