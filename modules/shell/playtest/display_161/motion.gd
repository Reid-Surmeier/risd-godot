## Throwaway #161: matched native moving frames for the current finish and bypass.
extends "res://testing/harness_base.gd"

const Scene := preload("res://modules/shell/demo.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage: Control = Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/risd-display-161-motion")
	await _frames(90)
	var chrome: Control = stage.get_node("Desktop/Content/SquareChrome")
	chrome.tab_buttons[4].pressed.emit()
	await _frames(90)
	var walk: Control = stage.find_child("GalleryWalk", true, false)
	assert(walk != null and walk._paintings.size() == 23)
	assert(chrome.pages.size == Vector2(1080, 972))
	var finish: ShaderMaterial = walk._vp.get_parent().material
	assert(finish.shader.resource_path.ends_with("gamecube.gdshader"))
	var timings := {}
	var traces := {}
	for mode in ["A", "B"]:
		finish.set_shader_parameter("quantization_mode", 2 if mode == "A" else 0)
		finish.set_shader_parameter("copy_filter", 0.5 if mode == "A" else 0.0)
		walk.set_process(false)
		walk._entrance_active = false
		walk._entrance_waiting = false
		walk._target = null
		walk._path.clear()
		walk._held.clear()
		walk._velocity = Vector3.ZERO
		walk._view_turn_remaining = 0.0
		walk._pos = Vector3(0, 0, -8.0)
		walk._last_pos = walk._pos
		walk._motion_heading = Vector3.FORWARD
		walk._yaw = PI
		walk.view_mode = 0
		walk.view_yaw = PI
		walk._kid_t = 0.0
		walk._kid.reset_contacts()
		walk._kid.phase = 0.12
		walk._kid._time = 0.0
		walk._kid.gesture = ""
		walk._kid.gesture_time = 0.0
		walk._update_camera(1.0)
		await _frames(10)
		var frame_ms := []
		var states := []
		DirAccess.make_dir_recursive_absolute(out.path_join(mode))
		for frame in 60:
			walk._held.clear()
			if frame < 35:
				walk._held["up"] = 0.0
			elif frame < 48:
				walk._view_turn_remaining = 0.5
			var start := Time.get_ticks_usec()
			walk._process(1.0 / 30.0)
			states.append([walk._pos.x, walk._pos.z, walk.view_yaw])
			await process_frame
			frame_ms.append((Time.get_ticks_usec() - start) / 1000.0)
			get_root().get_texture().get_image().save_png(out.path_join("%s/%03d.png" % [mode, frame]))
		timings[mode] = frame_ms
		traces[mode] = states
	assert(traces["A"] == traces["B"], "modes followed different gallery paths")
	var fh := FileAccess.open(out.path_join("timings.json"), FileAccess.WRITE)
	fh.store_string(JSON.stringify(timings))
	fh.close()
	print("PASS: matched native motion modes; 23 paintings; 60 frames each")
	_finish(out)
