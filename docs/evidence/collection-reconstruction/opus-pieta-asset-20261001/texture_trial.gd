## Optional texture trial, evidence only: is root's Muse FRONT panel better than the flat source palette?
## Not part of pieta_asset.gd. Run in the same disposable copy as check.gd, with the edge-padded sheet beside it:
##   python3 <saint roch evidence>/pad_sheet.py trial/pieta-original.webp <copy>/muse-sheet-padded.webp
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <copy> --rendering-method gl_compatibility --script texture_trial.gd
## "projected": faces turned to the viewer read the FRONT panel per vertex, every other face one sample at its centre.
## "facet": every face reads one sample at its centre, so no face carries a stretched picture.
## The mesh is laid over the panel's own outline box (172..695 x 34..680 px of 1760 x 1440).
extends SceneTree
const P = preload("res://pieta_asset.gd")
const S = preload("res://seated_woman_asset.gd")

func _initialize() -> void:
	create_timer(180).timeout.connect(func(): quit(2))
	call_deferred("run")

func uv(p: Vector3) -> Vector2:
	return Vector2(lerpf(172, 695, p.x / P.SIZE.x + .5) / 1760, lerpf(680, 34, p.y / P.SIZE.y) / 1440)

func build(per_vertex: bool, m: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part in P.parts():
		var s: PackedVector3Array = part[2]
		for i in range(0, s.size(), 3):
			var n: Vector3 = (s[i + 2] - s[i]).cross(s[i + 1] - s[i]).normalized()
			st.set_normal(n)
			for j in 3:
				st.set_uv(uv(s[i + j] if per_vertex and n.z > .5 else (s[i] + s[i + 1] + s[i + 2]) / 3))
				st.add_vertex(s[i + j])
	var visual := MeshInstance3D.new()
	visual.mesh = st.commit()
	visual.material_override = m
	return visual

func run() -> void:
	var skin: StandardMaterial3D = S.flat(Color.WHITE)
	skin.albedo_texture = ImageTexture.create_from_image(Image.load_from_file("res://muse-sheet-padded.webp"))
	skin.texture_repeat = false
	var world := Node3D.new()
	root.add_child(world)
	var variants := {"projected": build(true, skin), "facet": build(false, skin)}
	for key in variants:
		world.add_child(variants[key])
	var environment := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("b9b5ad")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = .7
	environment.environment = e
	world.add_child(environment)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = .55
	world.add_child(camera)
	camera.current = true
	var light := DirectionalLight3D.new()
	light.light_energy = .7
	world.add_child(light)
	var middle := Vector3(0, P.SIZE.y / 2, 0)
	for view in [["front", Vector3(0, 0, 2)], ["quarter-left", Vector3(-1.147, 0, 1.638)], ["quarter-right", Vector3(1.147, 0, 1.638)], ["above-front", Vector3(0, 1.2, 1.6)]]:
		camera.position = middle + view[1]
		camera.look_at(middle)
		light.global_transform = camera.global_transform.rotated_local(Vector3.UP, .6).rotated_local(Vector3.RIGHT, -.6)
		for key in variants:
			for other in variants:
				variants[other].visible = other == key
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://trial-%s-%s.png" % [key, view[0]])
	print("PIETA_TEXTURE_TRIAL done")
	quit(0)
