## #140 opt-in browser evidence adapter. Never mounted without ?render_qa=1.
## Fixed-step replay drives the real gallery process/navigation; pose is fixture setup.
extends Node

var view: Control
var _callback: JavaScriptObject
var _window: JavaScriptObject
var _replay := false
var _tick := 0
var _scene := "warm"
var _mode := "current"
const MODES := {"current": [2, 0.5], "copy-none": [2, 0.0], "copy-full": [2, 1.0], "rgb6-plain": [1, 0.5], "bypass": [0, 0.0]}

func _ready() -> void:
	view = get_parent()
	_window = JavaScriptBridge.get_interface("window")
	_callback = JavaScriptBridge.create_callback(_command)
	_window.galleryRenderCommand = _callback
	set_process(false)
	_publish()

func _command(args: Array) -> void:
	var request = JSON.parse_string(str(args[0]))
	if not request is Dictionary:
		return
	match request.get("action", "state"):
		"mode":
			var wanted := str(request.get("mode", "current"))
			if MODES.has(wanted):
				_mode = wanted
				var material: ShaderMaterial = view.get_child(0).material
				material.set_shader_parameter("quantization_mode", MODES[wanted][0])
				material.set_shader_parameter("copy_filter", MODES[wanted][1])
		"pose":
			_replay = false
			set_process(false)
			_pose(str(request.get("scene", "warm")))
		"replay":
			_pose(str(request.get("scene", "warm")))
			_tick = 0
			_replay = true
			set_process(true)
		"release":
			_replay = false
			set_process(false)
			view.set_process(true)
	_publish()

func _pose(scene: String) -> void:
	_scene = scene
	view.set_process(false)
	view._entrance_waiting = false
	view._entrance_active = false
	view._detail.hide()
	view._open.clear()
	view._view_panel.hide()
	view._enter_space("arch" if scene == "white" else "gallery")
	view._portal_flash.modulate.a = 0.0
	view._target = null
	view._path.clear()
	view._held.clear()
	view._velocity = Vector3.ZERO
	view._kid_t = 0.0
	view._view_turn_remaining = 0.0
	view.view_mode = 0
	view.view_yaw = PI / 2.0 if scene == "art" else PI
	view._yaw = view.view_yaw
	view._pos = {"entry": Vector3(0, 0, -0.35), "warm": Vector3(2.0, 0, -4.0), "art": Vector3(-3.3, 0, -12.0), "white": Vector3(0, 0, -1.0)}.get(scene, Vector3(2.0, 0, -4.0))
	view._last_pos = view._pos
	view._motion_heading = Vector3.FORWARD
	view._process(0.0)
	view._update_camera(1.0)

func _process(_delta: float) -> void:
	if not _replay:
		return
	# All modes replay the same 8-second input schedule at 60 simulation ticks/s.
	if _tick == 0:
		view._held["down" if _scene == "entry" else "up" if _scene == "white" else "right"] = 0.0
	if _tick == 120:
		view._held.clear()
	if _tick == 180:
		view._view_turn_remaining = 0.5
	if _tick == 240:
		view._held["up" if _scene == "entry" else "down" if _scene == "white" else "left"] = 0.0
	if _tick == 360:
		view._held.clear()
	view._process(1.0 / 60.0)
	_tick += 1
	if _tick >= 480:
		_replay = false
		set_process(false)
	_publish()

func _publish() -> void:
	var camera: Camera3D = view._cam
	var transform := camera.global_transform
	var values := []
	for column in [transform.basis.x, transform.basis.y, transform.basis.z, transform.origin]:
		values.append([column.x, column.y, column.z])
	var state := {"mode": _mode, "scene": _scene, "tick": _tick, "replaying": _replay,
		"viewport": [view._vp.size.x, view._vp.size.y], "msaa_3d": view._vp.msaa_3d,
		"backend": RenderingServer.get_current_rendering_method(), "engine": Engine.get_version_info().string,
		"container": [view.size.x, view.size.y], "space": view._space,
		"position": [view._pos.x, view._pos.y, view._pos.z], "camera_transform": values,
		"camera_fov": camera.fov, "camera_yaw": view.view_yaw, "paintings": view._paintings.size()}
	JavaScriptBridge.eval("window.galleryRenderState = " + JSON.stringify(state))
