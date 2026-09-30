extends "res://testing/harness_base.gd"
var walk: Control
var failures := 0


func require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(1152, 720)
	walk.set_process(false)
	var out := await _mount(walk, Vector2i(1152, 720), "/tmp/gallery-rig-render")
	walk.set_process(false)
	walk._new_action()
	walk._target = null
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk.view_yaw = PI / 2
	var samples := {}
	for label in ["raw", "warm", "cool", "disabled"]:
		if walk._kid.body.material_override:
			walk._kid.body.material_override.albedo_color = (
				Color.WHITE if label == "raw" else Color(1.6, 1.6, 1.6)
			)
		walk._pos = Vector3(-3.4, 0, -12.0) if label != "cool" else Vector3(1.4, 0, -5.0)
		walk._update_camera(1.0)
		walk._kid.reset_contacts()
		walk._kid.pose(0.0, false, 0.0, Vector3.RIGHT, 0)
		walk._kid.pose(0.2, false, 0.0, Vector3.RIGHT, 0)
		walk._kid.body.gi_mode = (
			GeometryInstance3D.GI_MODE_DISABLED
			if label == "disabled"
			else GeometryInstance3D.GI_MODE_DYNAMIC
		)
		await create_timer(0.6).timeout
		await _shot(out, label + ".png")
		var mesh: MeshInstance3D = walk._kid.body
		mesh.layers = 2048
		walk._cam.cull_mask = 2048
		await create_timer(0.5).timeout
		var img: Image = walk._vp.get_texture().get_image()
		img.save_png(out + "/" + label + "-isolated.png")
		var center: Vector2i = Vector2i(walk._cam.unproject_position(walk._pos + Vector3.UP * 1.35))
		var color: Color = img.get_pixelv(center)
		samples[label] = Vector3(color.r, color.g, color.b)
		print("RIG_LIGHT ", label, " head=", color)
		require(
			color.r > 0.04 if label != "disabled" else color.r < 0.03,
			"probe capture negative control did not distinguish lit geometry: " + label
		)
		mesh.layers = 1
	require(
		samples.warm.distance_to(samples.cool) > 0.04,
		"moving lit mesh did not change with spatial capture"
	)
	walk._kid.body.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
	walk._update_camera(1.0)
	walk._set_lighting(false)
	await _shot(out, "original-lighting.png")
	var fallback_image: Image = walk._vp.get_texture().get_image()
	var fallback_pixel := fallback_image.get_pixelv(
		Vector2i(walk._cam.unproject_position(walk._pos + Vector3.UP * 1.35))
	)
	require(fallback_pixel.r > 0.1, "original lighting UI left rig black")
	print("RIG_ORIGINAL_AMBIENT head=", fallback_pixel)
	walk._set_lighting(true)
	walk._kid.play_gesture("look")
	walk._kid.pose(0.65, false, 0, Vector3.RIGHT, 0)
	await _shot(out, "head-look.png")
	walk._kid.play_gesture("wave")
	walk._kid.pose(0.6, false, 0, Vector3.RIGHT, 0)
	await _shot(out, "hand-interact.png")
	for i in 96:
		var heading := (
			Vector3.FORWARD
			if i < 24
			else (
				Vector3(1, 0, -1).normalized()
				if i < 48
				else (Vector3.RIGHT if i < 72 else Vector3.BACK)
			)
		)
		walk._pos += heading * 1.2 / 24.0
		walk._kid.position = walk._pos
		walk._kid.pose(1.0 / 24.0, true, 0, heading, 0)
		walk._update_camera(1.0)
		await _shot(out, "walk-%02d.png" % i)
	walk._enter_space("arch")
	await create_timer(0.6).timeout
	await _shot(out, "white-room.png")
	require(
		walk._white_capture != null and walk._white_capture.visible,
		"white room has no separate probe field"
	)
	require(
		not walk._baked_room.get_node("Lightmap").visible, "gallery probes leak into white room"
	)
	print("RIG_RENDER_FAILURES ", failures)
	quit(1 if failures else 0)
