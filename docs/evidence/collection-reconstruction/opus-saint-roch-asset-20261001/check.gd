## One runnable check for saint_roch_asset.gd, in a disposable copy of this folder (CPU, software GL):
##   godot --headless --editor --import --path <copy>
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <copy> --rendering-method gl_compatibility --script check.gd
## Every solid must be closed, non-degenerate, outward-facing and thicker than a card; the hat top must be at the
## catalogue height; rear faces must read the REAR panel, front faces the FRONT panel, and nothing the rejected
## LEFT SIDE panel. It also renders the views. Passing says nothing about likeness: that is judged by eye.
## Exit 0 pass, 1 failures, 2 run() did not finish.
extends SceneTree
const R = preload("res://saint_roch_asset.gd")
const S = preload("res://seated_woman_asset.gd")
var failures := []

func _initialize() -> void:
	create_timer(180).timeout.connect(func():
		print("ROCH_CHECK aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func volume(shell: PackedVector3Array) -> float:
	var sum := 0.0
	for i in range(0, shell.size(), 3):
		sum += shell[i].dot(shell[i + 2].cross(shell[i + 1]))
	return sum / 6

func run() -> void:
	assert(volume(S.box(Vector3.ZERO, Vector3.ONE)) > 0, "winding convention of the reused helper changed")
	var low := Vector3.ONE * INF
	var high := -Vector3.ONE * INF
	var triangles := 0
	var per_group := {}
	var names := []
	var solid_m3 := 0.0
	for part in R.parts():
		var key: String = part[0]
		var shell: PackedVector3Array = part[2]
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
				# Directed: a closed, consistently wound shell uses each edge once in each direction.
				edges[from + "/" + to] = edges.get(from + "/" + to, 0) + 1
		for edge in edges:
			var pair: PackedStringArray = edge.split("/")
			if edges[edge] != 1 or edges.get(pair[1] + "/" + pair[0], 0) != 1:
				failures.append("%s: open, doubled or inconsistently wound edge" % key)
				break
		if volume(shell) <= 1e-9:
			failures.append("%s: shell is inside out or has no volume (%s m3)" % [key, volume(shell)])
		solid_m3 += volume(shell)
		for point in shell:
			a = a.min(point)
			b = b.max(point)
		# No card standing in for a solid: the thinnest part here is the 7 mm bag strap.
		if (b - a)[(b - a).min_axis_index()] < .005:
			failures.append("%s: thinner than 5 mm" % key)
		low = low.min(a)
		high = high.max(b)
	if abs(high.y - R.HEIGHT) > .000001 or abs(low.y) > .000001 or abs(R.HEIGHT - 1.054) > 1e-9:
		failures.append("catalogue height mismatch: %s .. %s" % [low.y, high.y])
	var image := Image.load_from_file("res://muse-sheet-padded.webp")
	var plain: Node3D = R.build()
	var figure: Node3D = R.build(ImageTexture.create_from_image(image))
	for flag in ["visual_fidelity_accepted", "rear_fidelity_accepted", "placement_accepted", "survey_metres_accepted"]:
		if figure.get_meta(flag, true):
			failures.append("helper must not mark %s" % flag)
	# Which sheet panel each face reads, from the built mesh itself.
	var panels := {"front": 0, "right": 0, "rear": 0, "rejected_left": 0, "flat_sample": 0}
	for child in figure.get_children():
		var arrays: Array = child.mesh.surface_get_arrays(0)
		var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		for i in range(0, uv.size(), 3):
			# From the stored vertices, as the asset does: the mesh's own normals are compressed and lose the sign of a zero.
			var n := (v[i + 2] - v[i]).cross(v[i + 1] - v[i]).normalized()
			var x := (uv[i].x + uv[i + 1].x + uv[i + 2].x) / 3 * R.SHEET_PX.x
			var panel := "front" if x < 575 else "right" if x < 880 else "rejected_left" if x < 1200 else "rear"
			if uv[i] == uv[i + 1] and uv[i] == uv[i + 2]:
				panels.flat_sample += 1
				if panel != ("front" if n.z >= 0 else "rear"):
					failures.append("%s: a flat sample reads the %s panel" % [child.name, panel])
			else:
				panels[panel] += 1
				var wanted := "right" if abs(n.x) > abs(n.z) else "front" if n.z >= 0 else "rear"
				if panel != wanted:
					failures.append("%s: a face turned %s reads the %s panel" % [child.name, wanted, panel])
	var world := Node3D.new()
	root.add_child(world)
	world.add_child(figure)
	world.add_child(plain)
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
	camera.size = 1.2
	world.add_child(camera)
	camera.current = true
	var light := DirectionalLight3D.new()
	light.light_energy = .7
	world.add_child(light)
	var middle := Vector3(0, R.HEIGHT / 2, 0)
	# RIGHT is the saint's right side, LEFT his left (the dog's). The quarter views turn 30 degrees like photographs 1 and 3.
	for view in [["front", Vector3(0, 0, 2)], ["rear", Vector3(0, 0, -2)], ["right", Vector3(-2, 0, 0)], ["left", Vector3(2, 0, 0)],
			["quarter-left", Vector3(1, 0, 1.732)], ["quarter-right", Vector3(-1, 0, 1.732)], ["rear-quarter-left", Vector3(1.4, .5, -1.4)], ["high", Vector3(1, 1.6, 1.4)]]:
		camera.position = middle + view[1]
		camera.look_at(middle)
		# Key light over the camera's left shoulder, so every view is lit from its own front.
		light.global_transform = camera.global_transform.rotated_local(Vector3.UP, .6).rotated_local(Vector3.RIGHT, -.6)
		for pass_ in [["", figure, plain], ["flat-", plain, figure]]:
			pass_[1].visible = true
			pass_[2].visible = false
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://" + pass_[0] + view[0] + ".png")
	var size := high - low
	var result := {"closed_parts": names.size(), "part_names": names, "parts_per_group": per_group, "triangles": triangles, "solid_volume_m3": solid_m3,
		"height_m": high.y, "width_m_provisional": size.x, "depth_m_provisional": size.z, "x_range_m": [low.x, high.x], "z_range_m": [low.z, high.z],
		"sheet_faces": panels, "failures": failures,
		"visual_fidelity_accepted": false, "rear_accepted": false, "placement_accepted": false, "survey_metres_accepted": false}
	var file := FileAccess.open("res://checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "  ") + "\n")
	file.close()
	print("ROCH_CHECK ", JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)
