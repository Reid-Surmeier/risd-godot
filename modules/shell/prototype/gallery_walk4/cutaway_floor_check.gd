## Private #167 regression: cutaway masonry must not leave black floor footprints.
extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	root.size = Vector2i(720, 540)
	var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(720, 540)
	root.add_child(walk)
	walk.set_process(false)
	walk._set_lighting(true)
	walk._space = "arch"
	walk._pos = Vector3(0, 0, 0.6)
	walk.view_mode = 0
	walk.view_yaw = PI
	walk._update_camera(1)
	assert(
		walk._portal_floor_material.get_shader_parameter("cutaway"),
		"Hidden stone retained baked floor shadows"
	)
	for frame in 8:
		await process_frame
	var picture: Image = walk._vp.get_texture().get_image()
	for x in [-1.2, 1.2]:
		var pixel := Vector2i(walk._cam.unproject_position(Vector3(x, -0.002, 1.0)))
		var color := picture.get_pixelv(pixel)
		print("CUTAWAY_FLOOR sample=", pixel, " color=", color)
		assert(maxf(color.r, color.g) > 0.15, "Black footprint beside passage")
	walk.view_yaw = 0
	walk._update_camera(1)
	assert(
		not walk._portal_floor_material.get_shader_parameter("cutaway"),
		"Intact stone lost baked floor lighting"
	)
	walk.view_mode = 2
	walk._update_camera(1)
	assert(
		not walk._portal_floor_material.get_shader_parameter("cutaway"),
		"Follow view lost baked floor lighting"
	)
	var transitioning: int = walk._cutaway_mask(23, 0.25)
	assert(transitioning & 8, "Wall disappeared before fading")
	assert(is_equal_approx(walk._cutaway_alpha[8], 0.75), "Wall fade jumped")
	assert(
		is_equal_approx(walk._portal_floor_material.get_shader_parameter("cutaway"), 0.25),
		"Floor lighting did not follow wall fade"
	)
	walk._view_turn_remaining = 0.5
	assert((walk._cutaway_mask(23, 0.1) & 8) == 0, "Orbit left a ghost wall")
	walk.view_mode = 0
	walk.view_yaw = PI / 2
	walk._update_camera(1)
	assert((walk._cam.cull_mask & 8) == 0, "Side view restored occluding doorway")
	# Inspect rendered coverage, not just the opacity value: Alpha Hash silently
	# darkened an opaque wall on Compatibility while all numeric checks passed.
	walk._view_turn_remaining = 0.0
	walk.view_yaw = PI
	walk._update_camera(1)
	var frames: Array[Image] = []
	for opacity in [1.0, 0.5, 0.0]:
		walk._cutaway_alpha[8] = opacity
		walk._cam.cull_mask = walk._cutaway_mask(23, 0.0)
		walk._portal_floor_material.set_shader_parameter("cutaway", 0.5)
		for frame in 4:
			await process_frame
		frames.append(walk._vp.get_texture().get_image())
	var changed := 0
	var revealed := 0
	for y in range(40, 300, 2):
		for x in range(40, 680, 2):
			var before := Vector3(
				frames[0].get_pixel(x, y).r,
				frames[0].get_pixel(x, y).g,
				frames[0].get_pixel(x, y).b
			)
			var after := Vector3(
				frames[2].get_pixel(x, y).r,
				frames[2].get_pixel(x, y).g,
				frames[2].get_pixel(x, y).b
			)
			if before.distance_to(after) < 0.2:
				continue
			changed += 1
			var middle := Vector3(
				frames[1].get_pixel(x, y).r,
				frames[1].get_pixel(x, y).g,
				frames[1].get_pixel(x, y).b
			)
			if middle.distance_to(after) < middle.distance_to(before):
				revealed += 1
	var coverage := float(revealed) / maxf(1, changed)
	print("CUTAWAY_COVERAGE changed=", changed, " revealed=", coverage)
	assert(
		changed > 1000 and coverage > 0.25 and coverage < 0.75,
		"Half fade did not reveal half the background"
	)
	print("CUTAWAY_FLOOR PASS")
	quit()
