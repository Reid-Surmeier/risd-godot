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
	assert(walk._portal_floor_material.get_shader_parameter("cutaway"), "Hidden stone retained baked floor shadows")
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
	assert(not walk._portal_floor_material.get_shader_parameter("cutaway"), "Intact stone lost baked floor lighting")
	walk.view_mode = 2
	walk._update_camera(1)
	assert(not walk._portal_floor_material.get_shader_parameter("cutaway"), "Follow view lost baked floor lighting")
	var transitioning: int = walk._cutaway_mask(23, 0.25)
	assert(transitioning & 8, "Wall disappeared before fading")
	assert(is_equal_approx(walk._cutaway_alpha[8], 0.75), "Wall fade jumped")
	assert(is_equal_approx(walk._portal_floor_material.get_shader_parameter("cutaway"), 0.25), "Floor lighting did not follow wall fade")
	print("CUTAWAY_FLOOR PASS")
	quit()
