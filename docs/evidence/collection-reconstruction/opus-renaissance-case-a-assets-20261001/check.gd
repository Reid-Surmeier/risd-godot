## One runnable check for renaissance_case_a_assets.gd, in a disposable copy of this folder (CPU, software GL):
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <copy> --rendering-method gl_compatibility --script check.gd
## Every solid must be closed (each edge used once in each direction), non-degenerate, outward-facing, finite and
## thicker than a card; each object must meet its catalogue size; every built node must carry outward normals, leave
## every acceptance flag false and use only the listed source files, each official one matching its inventory hash.
## It also renders the views into renders/.
## Negative control: add `-- open` to drop one triangle from the first solid of every object; the check must then exit 1.
## Passing says nothing about likeness: that is judged by eye. Exit 0 pass, 1 failures, 2 run() did not finish.
extends SceneTree
const A = preload("res://renaissance_case_a_assets.gd")
const S = preload("res://seated_woman_asset.gd")
const SIX := ["cleric", "woman", "diptych", "bookcover", "emblem", "albarello"]
const FURNITURE := ["diptych_mount", "emblem_cradle"]
# Where each stands in the grouped views: source-relative order read from 41.2s, for the picture only. Not a placement.
const GROUP := {"cleric": Vector3(-.20, .39, 0), "woman": Vector3(.21, .40, 0), "diptych": Vector3(-.29, 0, .24), "bookcover": Vector3(-.03, 0, .24),
	"emblem": Vector3(.20, 0, .16), "albarello": Vector3(.44, 0, .20)}
var failures := []

func _initialize() -> void:
	create_timer(540).timeout.connect(func():
		print("CASE_A_CHECK aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func bounds(shells: Array) -> AABB:
	var low := Vector3.ONE * INF
	var high := -Vector3.ONE * INF
	for shell in shells:
		for p in shell:
			low = low.min(p)
			high = high.max(p)
	return AABB(low, high - low)

func near(a: float, b: float) -> bool:
	return abs(a - b) < 1e-5

## Closure, winding, finiteness and thickness of every solid of one object. Returns its counts.
func solids(key: String, open: bool) -> Dictionary:
	var out := {"closed_parts": 0, "triangles": 0, "edge_pairs": 0, "solid_volume_m3": 0.0, "thinnest_part_m": INF}
	var first := true
	for part in A.parts(key).parts:
		var name: String = key + "/" + part[0]
		var shell: PackedVector3Array = part[2]
		if open and first:
			shell = shell.slice(3)
		first = false
		var edges := {}
		if shell.size() < 12 or shell.size() % 3 != 0:
			failures.append("%s: not a triangle shell" % name)
		for i in range(0, shell.size() - 2, 3):
			out.triangles += 1
			if (shell[i + 1] - shell[i]).cross(shell[i + 2] - shell[i]).length() < 1e-10:
				failures.append("%s: degenerate triangle" % name)
			for j in 3:
				var from := str(shell[i + j].snapped(Vector3.ONE * .000001))
				var to := str(shell[i + (j + 1) % 3].snapped(Vector3.ONE * .000001))
				edges[from + "/" + to] = edges.get(from + "/" + to, 0) + 1
		# A closed, consistently wound shell uses each edge once in each direction.
		for edge in edges:
			var pair: PackedStringArray = edge.split("/")
			if edges[edge] != 1 or edges.get(pair[1] + "/" + pair[0], 0) != 1:
				failures.append("%s: open, doubled or inconsistently wound edge" % name)
				break
		out.edge_pairs += edges.size() / 2
		if A.volume(shell) <= 1e-10:
			failures.append("%s: shell is inside out or has no volume (%s m3)" % [name, A.volume(shell)])
		out.solid_volume_m3 += A.volume(shell)
		for point in shell:
			if not point.is_finite():
				failures.append("%s: non-finite vertex" % name)
		var box := bounds([shell])
		var thin: float = box.size[box.size.min_axis_index()]
		out.thinnest_part_m = min(out.thinnest_part_m, thin)
		# No card standing in for a solid: 2 mm is under the thinnest real thing here, a chain.
		if thin < .002:
			failures.append("%s: thinner than 2 mm" % name)
		out.closed_parts += 1
	return out

func named(key: String, prefix: String) -> Array:
	return A.parts(key).parts.filter(func(p): return p[0].begins_with(prefix)).map(func(p): return p[2])

## Each object against the catalogue sizes it is known by.
func catalogue() -> Dictionary:
	var sizes := {}
	var expect := {"cleric": Vector3(.146, .222, .057), "woman": Vector3(.248, .362, 0), "diptych": Vector3(.133, .241, 0),
		"bookcover": Vector3(.086, .14, .051), "emblem": Vector3(.147, .197, 0), "albarello": Vector3(.13, .241, .13)}
	for key in expect:
		if not A.OBJECTS[key].size.is_equal_approx(expect[key]):
			failures.append("%s: OBJECTS size is not the catalogue's" % key)
	# Cleric: the painted panel is 14.6 x 22.2 cm and the whole reaches the catalogue depth.
	var box := bounds(named("cleric", "panel"))
	sizes["cleric_panel_m"] = [box.size.x, box.size.y]
	sizes["cleric_depth_m"] = bounds(named("cleric", "")).end.z
	if not (near(box.size.x, .146) and near(box.size.y, .222) and near(sizes.cleric_depth_m, .057) and near(bounds(named("cleric", "")).position.z, 0)):
		failures.append("cleric: panel or depth is not the catalogue's")
	var framed := bounds(named("cleric", ""))
	sizes["cleric_framed_m"] = [framed.size.x, framed.size.y]
	# Woman: the arched panel with its engaged frame fills 24.8 x 36.2 cm.
	box = bounds(named("woman", ""))
	sizes["woman_m"] = [box.size.x, box.size.y, box.size.z]
	if not (near(box.size.x, .248) and near(box.size.y, .362) and near(box.position.z, 0)):
		failures.append("woman: outline is not the catalogue's")
	# Diptych: each leaf plate is 13.3 x 24.1 cm.
	for side in ["left", "right"]:
		box = bounds(named("diptych", side + " plate"))
		sizes["diptych_%s_leaf_m" % side] = [box.size.x, box.size.y]
		if not (near(box.size.x, .133) and near(box.size.y, .241)):
			failures.append("diptych: %s leaf is not the catalogue's" % side)
		var whole := bounds(named("diptych", side))
		if not (near(whole.size.x, .133) and near(whole.size.y, .241)):
			failures.append("diptych: %s relief overhangs its leaf" % side)
	sizes["diptych_thickness_m"] = bounds(named("diptych", "")).size.z
	# Book cover: spine 5.1 wide by 14 high; each board is a rigid 8.6 x 14 x 0.45 cm slab, so its volume says its length.
	box = bounds(named("bookcover", "spine"))
	sizes["bookcover_spine_m"] = [box.size.x, box.size.y]
	if not (near(box.size.x, .051) and near(box.size.y, .14) and near(box.position.y, 0)):
		failures.append("bookcover: spine is not the catalogue's")
	for side in ["left", "right"]:
		var board: PackedVector3Array = named("bookcover", "board " + side)[0]
		sizes["bookcover_board_%s_length_m" % side] = A.volume(board) / (.14 * .0045)
		if not (near(A.volume(board) / (.14 * .0045), .086) and near(bounds([board]).size.y, .14)):
			failures.append("bookcover: %s board is not the catalogue's" % side)
	sizes["bookcover_as_displayed_m"] = [bounds(named("bookcover", "")).size.x, bounds(named("bookcover", "")).size.y, bounds(named("bookcover", "")).size.z]
	# Emblem book: each block is a rigid page-sized slab, so its volume over its thickness is the page area.
	for side in [["left", A.BOOK_LEFT], ["right", A.BOOK_RIGHT]]:
		var block: PackedVector3Array = named("emblem", side[0] + " block")[0]
		sizes["emblem_%s_page_area_m2" % side[0]] = A.volume(block) / side[1]
		if abs(A.volume(block) / side[1] - .147 * .197) > 1e-6:
			failures.append("emblem: %s page is not the catalogue's" % side[0])
	box = bounds(named("emblem", "") + named("emblem_cradle", ""))
	sizes["emblem_as_displayed_m"] = [box.size.x, box.size.y, box.size.z]
	if not near(box.position.y, 0):
		failures.append("emblem: book and cradle do not stand on the deck")
	# Albarello: 13 cm across both ways and 24.1 cm high, standing on the origin.
	box = bounds(named("albarello", ""))
	sizes["albarello_m"] = [box.size.x, box.size.y, box.size.z]
	if not (box.size.is_equal_approx(Vector3(.13, .241, .13)) and near(box.position.y, 0)):
		failures.append("albarello: bounds are not the catalogue's")
	return sizes

## Flags, sources and stored normals of the built nodes.
func nodes(images: Dictionary, painted: Callable) -> Dictionary:
	var out := {}
	for key in SIX:
		var node: Node3D = A.build(key, images, painted)
		for flag in A.FLAGS:
			if node.get_meta(flag, true):
				failures.append("%s: helper must not mark %s" % [key, flag])
		if node.get_meta("catalogue_identity", "") != "confirmed":
			failures.append("%s: identity is not the inventory's" % key)
		var triangles := 0
		for child in node.get_children():
			var arrays: Array = child.mesh.surface_get_arrays(0)
			var p: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var n: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			triangles += p.size() / 3
			for i in range(0, p.size(), 3):
				if n[i].dot((p[i + 2] - p[i]).cross(p[i + 1] - p[i]).normalized()) < .99:
					failures.append("%s/%s: a stored normal does not face out of its triangle" % [key, child.name])
					break
		out[key] = {"mesh_triangles": triangles, "source_images": node.get_meta("source_images"), "flags": {}}
		for field in A.OBJECTS[key].flags:
			out[key].flags[field] = node.get_meta(field)
		node.free()
	if out.emblem.flags.get("comparative_copy_used", true) or out.emblem.flags.get("museum_photograph_available", true):
		failures.append("emblem: must not claim a museum photograph or use the comparative copy")
	return out

## Every listed source file is present, is not the Glasgow copy, and each official one is the inventory's own bytes.
func sources() -> Dictionary:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://textures/manifest.json"))
	var known := {}
	for group in manifest:
		if manifest[group] is Dictionary:
			for name in manifest[group]:
				known[manifest[group][name].file] = manifest[group][name].sha256
	var out := {}
	for key in A.TEXTURES:
		var file: String = A.TEXTURES[key]
		var hash := FileAccess.get_sha256("res://" + file)
		out[key] = {"file": file, "sha256": hash}
		if "glasgow" in file.to_lower() or "sm772" in file.to_lower():
			failures.append("%s: the comparative library copy must not be a texture" % key)
		if hash == "" or known.get(file, "") != hash:
			failures.append("%s: %s is missing or is not the file prepare_textures.py recorded" % [key, file])
	return out

func shot(camera: Camera3D, light: DirectionalLight3D, from: Vector3, to: Vector3, file: String) -> void:
	camera.position = from
	camera.look_at(to, Vector3.FORWARD if abs((to - from).normalized().y) > .99 else Vector3.UP)
	# Key light over the camera's left shoulder, so every view is lit from its own front.
	light.global_transform = camera.global_transform.rotated_local(Vector3.UP, .6).rotated_local(Vector3.RIGHT, -.6)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://renders/" + file + ".png")

func run() -> void:
	assert(A.volume(S.box(Vector3.ZERO, Vector3.ONE)) > 0, "winding convention of the reused helper changed")
	var open := "open" in OS.get_cmdline_user_args()
	var counts := {}
	for key in SIX + FURNITURE:
		counts[key] = solids(key, open)
	var sizes := catalogue()
	var files := sources()
	var images: Dictionary = A.textures("res://")
	if images.size() != A.TEXTURES.size():
		failures.append("only %d of %d source images loaded" % [images.size(), A.TEXTURES.size()])
	var painted := Callable(load("res://modules/shell/prototype/gallery_walk4/painting_asset.gd"), "mat")
	var built := nodes(images, painted)
	for key in SIX:
		if built[key].mesh_triangles != counts[key].triangles and not open:
			failures.append("%s: built meshes carry %s triangles, the shells %s" % [key, built[key].mesh_triangles, counts[key].triangles])
		if built[key].source_images.is_empty():
			failures.append("%s: no source image reached the built node" % key)

	if not open:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://renders"))
		var world := Node3D.new()
		root.add_child(world)
		var environment := WorldEnvironment.new()
		var e := Environment.new()
		e.background_mode = Environment.BG_COLOR
		e.background_color = Color("b9b5ad")
		e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		e.ambient_light_color = Color.WHITE
		e.ambient_light_energy = .75
		environment.environment = e
		world.add_child(environment)
		var camera := Camera3D.new()
		world.add_child(camera)
		camera.current = true
		var light := DirectionalLight3D.new()
		light.light_energy = .6
		world.add_child(light)
		# Each object alone: front, quarter, above and rear, orthographic. The book keeps its cradle; the diptych stands
		# upright so its faces and backs can be seen (it lies on its mount in the grouped views).
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		for key in SIX:
			var node: Node3D = A.build(key, images, painted) if key == "diptych" else A.on_display(key, images, painted)
			world.add_child(node)
			var box := bounds(named(key, ""))
			if key == "emblem":
				box = bounds(named("emblem", "") + named("emblem_cradle", ""))
			var middle := box.get_center()
			camera.size = box.get_longest_axis_size() * 1.35
			for view in [["front", Vector3(0, 0, 2)], ["quarter", Vector3(1.147, .5, 1.638)], ["above", Vector3(0, 1.4, 1.4)], ["rear", Vector3(0, 0, -2)]]:
				await shot(camera, light, middle + view[1], middle, key + "-" + view[0])
			world.remove_child(node)
			node.free()
		# All six together, with and without their source images, on a plain white back and deck.
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		camera.fov = 38
		for pass_name in ["grouped", "grouped-flat"]:
			var group := Node3D.new()
			world.add_child(group)
			group.add_child(S.mesh([S.box(Vector3(-.55, -.03, -.02), Vector3(.65, 0, .42)), S.box(Vector3(-.55, -.03, -.02), Vector3(.65, .72, 0))], S.flat(Color("efede8"))))
			for key in SIX:
				var node: Node3D = A.on_display(key, images if pass_name == "grouped" else {}, painted)
				node.position = GROUP[key]
				group.add_child(node)
			var target := Vector3(.05, .22, .1)
			var views := [["front", Vector3(.05, .3, 1.75)], ["left-above", Vector3(-.75, .75, 1.3)], ["right-above", Vector3(.95, .8, 1.15)],
				["top", Vector3(.05, 2.1, .2)], ["low-quarter", Vector3(-.9, .12, 1.25)],
				# Roughly where the film stands at 49.8s and 46.4s: close, above, looking down at each end of the case.
				["close-left", Vector3(-.12, .62, .95), Vector3(-.16, .2, .1)], ["close-right", Vector3(.3, .62, .9), Vector3(.3, .2, .1)]]
			for view in views if pass_name == "grouped" else [views[1]]:
				await shot(camera, light, view[1], view[2] if view.size() > 2 else (Vector3(.05, 0, .2) if view[0] == "top" else target), pass_name + "-" + view[0])
			world.remove_child(group)
			group.free()

	var result := {"objects": counts, "catalogue_sizes_m": sizes, "built": built, "source_files": files, "negative_control_open": open, "failures": failures}
	for flag in A.FLAGS:
		result[flag] = false
	if not open:
		var file := FileAccess.open("res://checks.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(result, "  ") + "\n")
		file.close()
	print("CASE_A_CHECK ", JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)
