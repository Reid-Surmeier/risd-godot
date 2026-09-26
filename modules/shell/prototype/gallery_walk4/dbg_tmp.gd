extends "res://testing/harness_base.gd"
func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(main, Vector2i(1920, 1080), "/tmp/claude-1000/shdbg")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	walk._pos = Vector3(-2.2, 0, -6.0); walk._yaw = deg_to_rad(-120); walk._update_camera(1.0)
	var lights := []
	for c in walk._vp.get_children():
		if c is DirectionalLight3D: lights.append(c)
	print("lights ", lights.size())
	await create_timer(0.4).timeout
	await _shot(out, "a-default.png")
	for l in lights:
		l.shadow_normal_bias = 1.0; l.shadow_bias = 0.1; l.light_energy = 1.0
	await create_timer(0.4).timeout
	await _shot(out, "b-bias-energy.png")
	for l in lights:
		l.light_cull_mask = 0xFFFFF
	await create_timer(0.4).timeout
	await _shot(out, "c-mask-all.png")
	for m in walk._vp.get_children():
		if m is MeshInstance3D and m.mesh is BoxMesh:
			var sm := StandardMaterial3D.new(); sm.albedo_color = Color(0.2,0.25,0.35); m.material_override = sm
	await create_timer(0.4).timeout
	await _shot(out, "d-standard-boxes.png")
	quit(0)
