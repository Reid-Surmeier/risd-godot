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
var _render_viewports: Array[Viewport] = []
var _frame_delta_ms := 0.0
var _measure_gpu := false
var _last_draw_us := 0
var _draw_interval_ms := 0.0
var _chart: TextureRect
const MODES := {
	"current": [2, 0.5],
	"copy-none": [2, 0.0],
	"copy-full": [2, 1.0],
	"rgb6-plain": [1, 0.5],
	"bypass": [0, 0.0]
}


func _ready() -> void:
	view = get_parent()
	_window = JavaScriptBridge.get_interface("window")
	_callback = JavaScriptBridge.create_callback(_command)
	_window.galleryRenderCommand = _callback
	_measure_gpu = JavaScriptBridge.eval(
		"new URLSearchParams(location.search).has('render_gpu_times')"
	)
	if _measure_gpu:
		for viewport: Viewport in [view._vp, view.get_viewport(), get_tree().root]:
			if viewport not in _render_viewports:
				_render_viewports.append(viewport)
				RenderingServer.viewport_set_measure_render_time(viewport.get_viewport_rid(), true)
	RenderingServer.frame_post_draw.connect(_drawn)
	set_process(false)
	_publish()


func _drawn() -> void:
	var now := Time.get_ticks_usec()
	if _last_draw_us:
		_draw_interval_ms = (now - _last_draw_us) / 1000.0
	_last_draw_us = now


func _command(args: Array) -> void:
	var request = JSON.parse_string(str(args[0]))
	if not request is Dictionary:
		return
	match request.get("action", "state"):
		"mode":
			var wanted := str(request.get("mode", "current"))
			if MODES.has(wanted):
				_mode = wanted
				var material: ShaderMaterial = view._vp.get_parent().material
				material.set_shader_parameter("quantization_mode", MODES[wanted][0])
				material.set_shader_parameter("copy_filter", MODES[wanted][1])
		"chart":
			_chart_visible(bool(request.get("visible", false)))
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


func _chart_visible(enabled: bool) -> void:
	if _chart == null:
		var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		for y in 64:
			for x in 64:
				image.set_pixel(
					x, y, Color(float(x) / 63.0, float(y % 8) / 7.0, float((x + y) % 16) / 15.0)
				)
		_chart = TextureRect.new()
		_chart.texture = ImageTexture.create_from_image(image)
		_chart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_chart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		view._vp.add_child(_chart)
	_chart.size = Vector2(view._vp.size)
	_chart.visible = enabled


func _pose(scene: String) -> void:
	_scene = scene
	view.set_process(false)
	view._entrance_waiting = false
	view._entrance_active = false
	view._close_detail()
	view._view_panel.hide()
	view._enter_space("far" if scene == "white" else "gallery")
	view._portal_flash.modulate.a = 0.0
	view._target = null
	view._target_yaw = null
	view._path.clear()
	view._held.clear()
	view._velocity = Vector3.ZERO
	view._kid_t = 0.0
	view._view_turn_remaining = 0.0
	view.view_mode = 0
	view.view_yaw = PI / 2.0 if scene == "art" else PI
	view._yaw = view.view_yaw
	view._pos = (
		{
			"entry": Vector3(0, 0, -0.35),
			"warm": Vector3(2.0, 0, -4.0),
			"art": Vector3(-3.3, 0, -12.0),
			"white": Vector3(0, 0, -3.0)
		}
		. get(scene, Vector3(2.0, 0, -4.0))
	)
	view._last_pos = view._pos
	view._motion_heading = Vector3.FORWARD
	# #161 reset the selected Hair36 rig before every matched replay.
	view._kid.reset_contacts()
	view._kid._clock = 0.0
	view._kid._gait = 0.0
	view._kid._clip = "Idle"
	view._kid._blend_start = -1.0
	view._kid._from.clear()
	view._kid._stationary_weight = 1.0
	view._kid.rotation.y = 0.0
	view._kid.target.reset_bone_poses()
	view._process(0.0)
	view._update_camera(1.0)

	# #162 close-detail evidence inside the actual framed Collection viewport.
	var details := {
		"bench": [Vector3(2.5, 2.2, -6.3), Vector3(0, 0.24, -9), 48.0],
		"skylight": [Vector3(0, 1.8, -12), Vector3(0, 5.8, -19), 66.0],
		"wall": [Vector3(1.4, 1.7, -12), Vector3(-5, 2.4, -14), 62.0],
		"portal": [Vector3(0, 2.1, 6.5), Vector3(0, 2.1, 1.6), 54.0],
		"floor": [Vector3(0.8, 1.75, -14), Vector3(0.2, 0, -18.5), 55.0],
	}
	if details.has(scene):
		view._cam.cull_mask = view._cutaway_mask(63, 1.0)
		view._cam.position = details[scene][0]
		view._cam.look_at(details[scene][1])
		view._cam.fov = details[scene][2]


func _process(_delta: float) -> void:
	_frame_delta_ms = _delta * 1000.0
	if not _replay:
		return
	# All modes replay the same 8-second input schedule at 60 simulation ticks/s.
	if _tick == 0:
		view._held["down" if _scene == "entry" else "right"] = 0.0
	if _tick == 120:
		view._held.clear()
	if _tick == 180:
		view._view_turn_remaining = 0.5
	if _tick == 240:
		view._held["up" if _scene == "entry" else "left"] = 0.0
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
	var timings := []
	for viewport in _render_viewports:
		var rid := viewport.get_viewport_rid()
		timings.append(
			{
				"viewport": str(viewport.get_path()),
				"cpu_ms": RenderingServer.viewport_get_measured_render_time_cpu(rid),
				"gpu_ms": RenderingServer.viewport_get_measured_render_time_gpu(rid)
			}
		)
	var state := {
		"mode": _mode,
		"scene": _scene,
		"tick": _tick,
		"replaying": _replay,
		"viewport": [view._vp.size.x, view._vp.size.y],
		"msaa_3d": view._vp.msaa_3d,
		"backend": RenderingServer.get_current_rendering_method(),
		"engine": Engine.get_version_info().string,
		"container": [view.size.x, view.size.y],
		"space": view._space,
		"position": [view._pos.x, view._pos.y, view._pos.z],
		"camera_transform": values,
		"camera_fov": camera.fov,
		"camera_yaw": view.view_yaw,
		"paintings": view._paintings.size()
	}
	var box: SubViewportContainer = view._vp.get_parent()
	var finish: ShaderMaterial = box.material
	var display_rect: Rect2 = view.get_global_rect()
	var desktop_size: Vector2 = Vector2(view.get_viewport().size)
	state["display_rect_normalized"] = [
		display_rect.position.x / desktop_size.x,
		display_rect.position.y / desktop_size.y,
		display_rect.end.x / desktop_size.x,
		display_rect.end.y / desktop_size.y
	]
	state["display_material"] = {
		"node": str(box.get_path()),
		"class": box.get_class(),
		"visible": box.is_visible_in_tree(),
		"use_parent_material": box.use_parent_material,
		"instance": finish.get_instance_id(),
		"shader": finish.shader.resource_path,
		"copy_filter": finish.get_shader_parameter("copy_filter"),
		"quantization_mode": finish.get_shader_parameter("quantization_mode")
	}
	var poses := []
	for bone in view._kid.target.get_bone_count():
		poses.append(view._kid.target.get_bone_pose(bone))
	state["visitor"] = {
		"identity": "Hair36",
		"phase": view._kid.phase,
		"idle_time": view._kid._clock,
		"yaw": view._kid.rotation.y,
		"pose_hash": hash(poses)
	}
	state["preview"] = {
		"tag": view._open.get("tag", ""),
		"visible": view._detail.visible,
		"zoom": view._zoom,
		"pan": [view._zoom_root.position.x, view._zoom_root.position.y],
		"outer_frame_visible":
		view.get_parent() is TextureRect and view.get_parent().self_modulate.a > 0.0
	}
	var picture: TextureRect = view._zoom_root.get_node("Painting")
	state["preview"]["picture_size"] = [picture.size.x, picture.size.y]
	state["preview"]["source_size"] = (
		[picture.texture.get_width(), picture.texture.get_height()] if picture.texture else [0, 0]
	)
	var close_rect: Rect2 = view._detail.get_node("Close").get_global_rect()
	state["preview"]["close"] = [
		close_rect.get_center().x / desktop_size.x, close_rect.get_center().y / desktop_size.y
	]
	var targets := []
	for painting in view._paintings:
		if not view._painting_shown(painting):
			continue
		var outline: PackedVector2Array = view._visible_outline(painting.corners)
		var clipped := Geometry2D.intersect_polygons(
			outline,
			PackedVector2Array(
				[Vector2.ZERO, Vector2(view.size.x, 0), view.size, Vector2(0, view.size.y)]
			)
		)
		if clipped.is_empty():
			continue
		outline = clipped[0]
		if outline.size() < 3:
			continue
		var point := Vector2.ZERO
		for vertex in outline:
			point += vertex / outline.size()
		point = (view.global_position + point) / desktop_size
		targets.append({"tag": painting.tag, "point": [point.x, point.y]})
	state["visible_paintings"] = targets
	state["godot_delta_ms"] = _frame_delta_ms
	state["godot_process_ms"] = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	state["godot_post_draw_interval_ms"] = _draw_interval_ms
	state["gpu_timing_enabled"] = _measure_gpu
	state["render_setup_cpu_ms"] = RenderingServer.get_frame_setup_time_cpu()
	state["viewport_render_timings"] = timings
	JavaScriptBridge.eval("window.galleryRenderState = " + JSON.stringify(state))
