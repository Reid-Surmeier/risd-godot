extends Control

const Shell := preload("res://modules/shell/interface.gd")

var enabled := true
var _qa_elapsed := 0.0
var _mouse_inside := false
@onready var crt_material: ShaderMaterial = $Screen.material

func _ready() -> void:
	$Screen.texture = $Desktop.get_texture()
	crt_material.set_shader_parameter("tex", $Desktop.get_texture())
	resized.connect(_resize_desktop)
	_resize_desktop()
	get_window().mouse_exited.connect(_mouse_exited)
	if OS.has_feature("web"):
		enabled = not JavaScriptBridge.eval("new URLSearchParams(location.search).get('crt') === '0' || new URLSearchParams(location.search).has('qa-viewer')")
	_publish_state()
	set_process(OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa-crt')"))

func _resize_desktop() -> void:
	# Scale the logical desktop uniformly to fill every browser shape, without bars.
	var factor := maxf(1.0, maxf(1440.0 / maxf(size.x, 1.0), 900.0 / maxf(size.y, 1.0)))
	$Desktop.size = Vector2i((size * factor).round())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		enabled = not enabled
		_publish_state()
	else:
		var mapped := event.duplicate()
		if event is InputEventMouse:
			if not _mouse_inside:
				$Desktop.notify_mouse_entered()
				_mouse_inside = true
			mapped.position = _screen_to_desktop(event.position)
			mapped.global_position = mapped.position
			if event is InputEventMouseMotion:
				mapped.relative = mapped.position - _screen_to_desktop(event.position - event.relative)
		elif event is InputEventScreenTouch or event is InputEventScreenDrag:
			mapped.position = _screen_to_desktop(event.position)
			if event is InputEventScreenDrag:
				mapped.relative = mapped.position - _screen_to_desktop(event.position - event.relative)
		$Desktop.push_input(mapped, true)
	get_viewport().set_input_as_handled()

func _screen_to_desktop(point: Vector2) -> Vector2:
	var logical_size := Vector2($Desktop.size)
	if not enabled:
		return point / size * logical_size
	# Same display-to-source warp as crt_luminance.gdshader.
	var uv := (point / size - Vector2(0.5, 0.5)) / float(crt_material.get_shader_parameter("screen_scale"))
	var aspect := logical_size.y / logical_size.x
	uv.x /= aspect
	var curve: float = crt_material.get_shader_parameter("curve")
	uv /= 1.0 - (uv.length_squared() - 0.25) * curve
	uv.x *= aspect
	return (uv + Vector2(0.5, 0.5)) * logical_size

func _publish_state() -> void:
	$Screen.material = crt_material if enabled else null
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.crtQaState = " + JSON.stringify({"enabled": enabled, "curve": crt_material.get_shader_parameter("curve"), "screen_scale": crt_material.get_shader_parameter("screen_scale")}))

# Browser-only evidence uses the existing module interfaces; it does not control the game.
func _process(delta: float) -> void:
	_qa_elapsed += delta
	if _qa_elapsed < 0.25:
		return
	_qa_elapsed = 0.0
	var shell: Control = $Desktop/Content.get_node_or_null("Shell")
	if shell == null:
		return
	var state: Dictionary = Shell.state(shell).value
	for tab in state.tabs:
		var rect: Rect2 = tab.rect
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
	JavaScriptBridge.eval("window.shellCrtQa = " + JSON.stringify({"shell": state, "tenant": tenant,
			"logical_size": [$Desktop.size.x, $Desktop.size.y], "display_size": [size.x, size.y]}))

func _mouse_exited() -> void:
	if _mouse_inside:
		$Desktop.notify_mouse_exited()
		_mouse_inside = false
