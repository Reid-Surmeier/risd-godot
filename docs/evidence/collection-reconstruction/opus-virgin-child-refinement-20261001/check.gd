## One runnable check for virgin_child_asset.gd, in a disposable copy of this folder (CPU, software GL):
##   godot --headless --editor --import --path <copy>
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <copy> --rendering-method gl_compatibility --script check.gd
## Every shell must be closed, non-degenerate and outward-facing, and the crown must be at the catalogue height.
## It also renders the five native views. Passing says nothing about likeness: that is judged by eye.
## Exit 0 pass, 1 failures, 2 run() did not finish.
extends SceneTree
const V = preload("res://virgin_child_asset.gd")
const S = preload("res://seated_woman_asset.gd")
var failures := []

func _initialize() -> void:
	create_timer(120).timeout.connect(func():
		print("VIRGIN_CHECK aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func volume(shell: PackedVector3Array) -> float:
	var sum := 0.0
	for i in range(0, shell.size(), 3):
		sum += shell[i].dot(shell[i + 2].cross(shell[i + 1]))
	return sum / 6

func run() -> void:
	assert(volume(S.box(Vector3.ZERO, Vector3.ONE)) > 0, "winding convention of the reused helper changed")
	var geometry: Dictionary = V.parts()
	var low := Vector3.ONE * INF
	var high := -Vector3.ONE * INF
	var triangles := 0
	var count := 0
	var per_group := {}
	for key in geometry:
		per_group[key] = geometry[key].size()
		for shell in geometry[key]:
			count += 1
			var edges := {}
			if shell.size() < 12 or shell.size() % 3 != 0:
				failures.append("%s: not a triangle shell" % key)
			for i in range(0, shell.size() - 2, 3):
				triangles += 1
				if (shell[i + 1] - shell[i]).cross(shell[i + 2] - shell[i]).length() < 1e-9:
					failures.append("%s: degenerate triangle" % key)
				for j in 3:
					var a := str(shell[i + j].snapped(Vector3.ONE * .000001))
					var b := str(shell[i + (j + 1) % 3].snapped(Vector3.ONE * .000001))
					# Directed: a closed, consistently wound shell uses each edge once in each direction.
					edges[a + "/" + b] = edges.get(a + "/" + b, 0) + 1
			for edge in edges:
				var pair: PackedStringArray = edge.split("/")
				if edges[edge] != 1 or edges.get(pair[1] + "/" + pair[0], 0) != 1:
					failures.append("%s: open, doubled or inconsistently wound edge" % key)
					break
			if volume(shell) <= 1e-9:
				failures.append("%s: shell is inside out or has no volume (%s m3)" % [key, volume(shell)])
			for point in shell:
				low = low.min(point)
				high = high.max(point)
	if abs(high.y - V.HEIGHT) > .000001 or abs(low.y) > .000001 or abs(V.HEIGHT - .394) > 1e-9:
		failures.append("catalogue height mismatch: %s .. %s" % [low.y, high.y])
	var world := Node3D.new()
	root.add_child(world)
	var figure: Node3D = V.build()
	world.add_child(figure)
	if figure.get_meta("visual_fidelity_accepted", true) or figure.get_meta("rear_fidelity_accepted", true) or figure.get_meta("placement_accepted", true):
		failures.append("helper must not mark itself accepted")
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
	camera.size = .47
	world.add_child(camera)
	camera.current = true
	var light := DirectionalLight3D.new()
	light.light_energy = .7
	world.add_child(light)
	# Named as the Muse sheet names them: RIGHT is Mary's right side (the child's), LEFT her left.
	for view in [["front", Vector3(0, .197, .8)], ["right", Vector3(-.8, .197, 0)], ["left", Vector3(.8, .197, 0)], ["rear", Vector3(0, .197, -.8)],
			["oblique", Vector3(.5, .37, .65)], ["oblique-child", Vector3(-.6, .37, .6)],
			# The official photographs look down about 12 degrees; these three are for laying beside them.
			["front-high", Vector3(0, .37, .8)], ["right-high", Vector3(-.8, .37, 0)], ["left-high", Vector3(.8, .37, 0)]]:
		camera.position = view[1]
		camera.look_at(Vector3(0, .197, 0))
		# Key light over the camera's left shoulder, so every view is lit from its own front.
		light.global_transform = camera.global_transform.rotated_local(Vector3.UP, .6).rotated_local(Vector3.RIGHT, -.6)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://" + view[0] + ".png")
	var size := high - low
	var result := {"closed_parts": count, "parts_per_material": per_group, "triangles": triangles, "height_m": high.y, "width_m_provisional": size.x, "depth_m_provisional": size.z,
		"failures": failures, "visual_fidelity_accepted": false, "rear_accepted": false, "placement_accepted": false}
	var file := FileAccess.open("res://checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "  ") + "\n")
	file.close()
	print("VIRGIN_CHECK ", JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)
