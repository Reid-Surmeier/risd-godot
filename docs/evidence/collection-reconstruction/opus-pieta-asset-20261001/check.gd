## One runnable check for pieta_asset.gd, in a disposable copy of this folder (CPU, software GL):
##   godot --headless --editor --import --path <copy>
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <copy> --rendering-method gl_compatibility --script check.gd
## Every solid must be closed (each edge used exactly once in each direction), non-degenerate, outward-facing, finite
## and thicker than a card; the whole must fill the catalogue width, height and depth exactly; the built node must
## carry outward normals and leave every accepted flag false. It also renders the views.
## Negative control: add `-- open` to drop one triangle from the base; the check must then exit 1.
## Passing says nothing about likeness: that is judged by eye. Exit 0 pass, 1 failures, 2 run() did not finish.
extends SceneTree
const P = preload("res://pieta_asset.gd")
const S = preload("res://seated_woman_asset.gd")
const FLAGS := ["visual_fidelity_accepted", "rear_fidelity_accepted", "placement_accepted", "survey_metres_accepted", "whole_room_complete"]
var failures := []

func _initialize() -> void:
	create_timer(180).timeout.connect(func():
		print("PIETA_CHECK aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func volume(shell: PackedVector3Array) -> float:
	var sum := 0.0
	for i in range(0, shell.size(), 3):
		sum += shell[i].dot(shell[i + 2].cross(shell[i + 1]))
	return sum / 6

func run() -> void:
	assert(volume(S.box(Vector3.ZERO, Vector3.ONE)) > 0, "winding convention of the reused helper changed")
	var open := "open" in OS.get_cmdline_user_args()
	var low := Vector3.ONE * INF
	var high := -Vector3.ONE * INF
	var triangles := 0
	var edge_pairs := 0
	var per_group := {}
	var names := []
	var solid_m3 := 0.0
	var thinnest := INF
	for part in P.parts():
		var key: String = part[0]
		var shell: PackedVector3Array = part[2]
		if open and key == "base":
			shell = shell.slice(3)
		names.append(key)
		per_group[part[1]] = per_group.get(part[1], 0) + 1
		var edges := {}
		var a := Vector3.ONE * INF
		var b := -Vector3.ONE * INF
		if shell.size() < 12 or shell.size() % 3 != 0:
			failures.append("%s: not a triangle shell" % key)
		for i in range(0, shell.size() - 2, 3):
			triangles += 1
			if (shell[i + 1] - shell[i]).cross(shell[i + 2] - shell[i]).length() < 1e-9:
				failures.append("%s: degenerate triangle" % key)
			for j in 3:
				var from := str(shell[i + j].snapped(Vector3.ONE * .000001))
				var to := str(shell[i + (j + 1) % 3].snapped(Vector3.ONE * .000001))
				edges[from + "/" + to] = edges.get(from + "/" + to, 0) + 1
		# Edge pair 2: a closed, consistently wound shell uses each edge once in each direction.
		for edge in edges:
			var pair: PackedStringArray = edge.split("/")
			if edges[edge] != 1 or edges.get(pair[1] + "/" + pair[0], 0) != 1:
				failures.append("%s: open, doubled or inconsistently wound edge" % key)
				break
		edge_pairs += edges.size() / 2
		if volume(shell) <= 1e-9:
			failures.append("%s: shell is inside out or has no volume (%s m3)" % [key, volume(shell)])
		solid_m3 += volume(shell)
		for point in shell:
			if not point.is_finite():
				failures.append("%s: non-finite vertex" % key)
			a = a.min(point)
			b = b.max(point)
		thinnest = min(thinnest, (b - a)[(b - a).min_axis_index()])
		# No card standing in for a solid.
		if (b - a)[(b - a).min_axis_index()] < .005:
			failures.append("%s: thinner than 5 mm" % key)
		low = low.min(a)
		high = high.max(b)
	if not (high - low).is_equal_approx(P.SIZE) or abs(low.y) > 1e-6 or abs(low.x + high.x) > 1e-6 or abs(low.z + high.z) > 1e-6:
		failures.append("catalogue bounds mismatch: %s .. %s" % [low, high])
	if not P.SIZE.is_equal_approx(Vector3(.381, .457, .132)):
		failures.append("SIZE is not the catalogue 38.1 x 45.7 x 13.2 cm")
	# How far the photograph reading had to be scaled on each axis to meet the catalogue.
	var raw_low := Vector3.ONE * INF
	var raw_high := -Vector3.ONE * INF
	for part in P.photo_cm():
		for point in part[2]:
			raw_low = raw_low.min(point)
			raw_high = raw_high.max(point)
	var fit: Vector3 = P.SIZE * 100 / (raw_high - raw_low)
	var figure: Node3D = P.build()
	for flag in FLAGS:
		if figure.get_meta(flag, true):
			failures.append("helper must not mark %s" % flag)
	# The built meshes: every stored normal must be the outward normal of its own triangle.
	var mesh_triangles := 0
	for child in figure.get_children():
		var arrays: Array = child.mesh.surface_get_arrays(0)
		var p: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var n: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		mesh_triangles += p.size() / 3
		for i in range(0, p.size(), 3):
			if n[i].dot((p[i + 2] - p[i]).cross(p[i + 1] - p[i]).normalized()) < .99:
				failures.append("%s: a stored normal does not face out of its triangle" % child.name)
				break
	if mesh_triangles != triangles and not open:
		failures.append("built meshes carry %s triangles, the shells %s" % [mesh_triangles, triangles])
	var world := Node3D.new()
	root.add_child(world)
	world.add_child(figure)
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
	# Quarter views turn 35 degrees. "above-front" is the walking camera's kind of angle; "rear" is the plain back.
	for view in [["front", Vector3(0, 0, 2)], ["quarter-left", Vector3(-1.147, 0, 1.638)], ["quarter-right", Vector3(1.147, 0, 1.638)],
			["above-front", Vector3(0, 1.2, 1.6)], ["above-quarter-left", Vector3(-1, 1.2, 1.3)], ["above-quarter-right", Vector3(1, 1.2, 1.3)],
			["rear", Vector3(0, 0, -2)], ["rear-quarter", Vector3(1.4, .5, -1.4)], ["left", Vector3(-2, 0, 0)], ["right", Vector3(2, 0, 0)],
			["top", Vector3(0, 2, 0)]]:
		camera.position = middle + view[1]
		camera.look_at(middle, Vector3.FORWARD if view[0] == "top" else Vector3.UP)
		# Key light over the camera's left shoulder, so every view is lit from its own front.
		light.global_transform = camera.global_transform.rotated_local(Vector3.UP, .6).rotated_local(Vector3.RIGHT, -.6)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://" + view[0] + ".png")
	var result := {"closed_parts": names.size(), "part_names": names, "parts_per_group": per_group, "triangles": triangles, "edge_pairs": edge_pairs,
		"solid_volume_m3": solid_m3, "thinnest_part_m": thinnest, "size_m": [high.x - low.x, high.y - low.y, high.z - low.z],
		"x_range_m": [low.x, high.x], "y_range_m": [low.y, high.y], "z_range_m": [low.z, high.z],
		"photo_cm_span": [raw_high.x - raw_low.x, raw_high.y - raw_low.y, raw_high.z - raw_low.z], "photo_cm_to_catalogue_scale": [fit.x, fit.y, fit.z],
		"negative_control_open_base": open, "failures": failures,
		"visual_fidelity_accepted": false, "rear_fidelity_accepted": false, "placement_accepted": false, "survey_metres_accepted": false,
		"whole_room_complete": false}
	if not open:
		var file := FileAccess.open("res://checks.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(result, "  ") + "\n")
		file.close()
	print("PIETA_CHECK ", JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)
