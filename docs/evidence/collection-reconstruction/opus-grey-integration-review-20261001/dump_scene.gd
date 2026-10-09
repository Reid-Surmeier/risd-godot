## Review tool, headless CPU:
##   godot --headless --fixed-fps 60 --path <prepared Hall-retained project> -s dump_scene.gd -- --report=<out.json> [--walk]
## Writes what the built room scene actually contains, for comparison between two builds and against the
## source plan: every authored mesh and collision body with its world box, every floor triangle's facing,
## the retained Hall counts, and (with --walk) the result of every walk trial in geometry.json.
## It asserts nothing; compare_builds.py does the judging. Exit 0 written, 2 run() did not finish.
extends SceneTree

func _initialize() -> void:
	create_timer(1200).timeout.connect(func():
		print("DUMP aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func box(b: AABB) -> Array:
	return [snappedf(b.position.x, .0001), snappedf(b.position.y, .0001), snappedf(b.position.z, .0001), snappedf(b.end.x, .0001), snappedf(b.end.y, .0001), snappedf(b.end.z, .0001)]

func look_of(m: Material) -> String:
	if m is ShaderMaterial:
		var t = m.get_shader_parameter("albedo")
		return m.shader.resource_path.get_file() + ("|" + t.resource_path.get_file() if t is Texture2D else "")
	if m is StandardMaterial3D:
		return m.albedo_color.to_html() + ("|" + m.albedo_texture.resource_path.get_file() if m.albedo_texture else "")
	return ""

func run() -> void:
	var out := ""
	var walk := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="):
			out = arg.trim_prefix("--report=")
		walk = walk or arg == "--walk"
	var geometry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	var scene: Node3D = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var nodes := []
	var floors := {"meshes": 0, "triangles": 0, "front_faces_down": 0, "stored_normal_down": 0, "no_normals": 0, "down_examples": []}
	var hall := {"retained_meshes": 0, "script": scene.get_script().resource_path}
	var canvases := {}
	for node in scene.find_children("*", "Node3D", true, false):
		if scene.visitor.is_ancestor_of(node) or node == scene.visitor:
			continue
		if node.has_meta("retained_main_hall"):
			hall.retained_meshes += 1
			var paint = node.material_override.get("albedo_texture") if node.material_override is StandardMaterial3D else (node.material_override.get_shader_parameter("albedo") if node.material_override is ShaderMaterial else null)
			# A Hall work is a canvas in canvas/ inside a frame from frames/ (one work, W6, is a single shaped frame image).
			if paint is Texture2D and ("/canvas/" in paint.resource_path or "/frames/" in paint.resource_path):
				var work: String = paint.resource_path.get_file().get_basename().trim_suffix("-shaped")
				canvases[work] = canvases.get(work, 0) + 1
			continue
		if node is MeshInstance3D and node.mesh != null and node.mesh.get_surface_count() > 0:
			var m: MeshInstance3D = node
			var world: AABB = m.global_transform * m.mesh.get_aabb()
			var row := {"kind": "mesh", "box": box(world), "look": look_of(m.material_override), "tag": "", "collide": m.get_parent() is StaticBody3D}
			for key in ["catalogue_asset", "catalogue_accession", "modern_window", "opaque_ceiling"]:
				if m.has_meta(key):
					row.tag = key + "=" + str(m.get_meta(key))
			var owner_wall: Node = m.get_parent()
			if owner_wall is StaticBody3D and owner_wall.has_meta("room_wall"):
				row.tag = "wall=" + owner_wall.get_meta("room_wall")
			nodes.append(row)
			if m.material_override is ShaderMaterial and m.material_override.shader.resource_path.ends_with("floor_oak.gdshader"):
				floors.meshes += 1
				var arrays: Array = m.mesh.surface_get_arrays(0)
				var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var n = arrays[Mesh.ARRAY_NORMAL]
				var index = arrays[Mesh.ARRAY_INDEX]
				var count: int = index.size() if index != null and index.size() > 0 else v.size()
				if n == null or n.size() == 0:
					floors.no_normals += 1
				for i in range(0, count, 3):
					var ids := [i, i + 1, i + 2] if index == null or index.size() == 0 else [index[i], index[i + 1], index[i + 2]]
					floors.triangles += 1
					# Godot's front face is clockwise: its normal is (c - a) x (b - a).
					var front: Vector3 = (m.global_transform.basis * (v[ids[2]] - v[ids[0]])).cross(m.global_transform.basis * (v[ids[1]] - v[ids[0]]))
					var stored_down: bool = n != null and n.size() > 0 and (m.global_transform.basis * n[ids[0]]).y <= 0
					if front.y <= 0:
						floors.front_faces_down += 1
					if stored_down:
						floors.stored_normal_down += 1
					if (front.y <= 0 or stored_down) and floors.down_examples.size() < 6:
						floors.down_examples.append(box(world))
		elif node is StaticBody3D and node.get_child_count() > 0 and node.get_child(0) is CollisionShape3D and node.get_child(0).shape is BoxShape3D:
			var shape: CollisionShape3D = node.get_child(0)
			var world: AABB = shape.global_transform * AABB(-shape.shape.size / 2, shape.shape.size)
			nodes.append({"kind": "body", "box": box(world), "look": "", "tag": "wall=" + str(node.get_meta("room_wall")) if node.has_meta("room_wall") else str(node.name) if not str(node.name).begins_with("@") else "", "collide": true, "in_cutaway_list": node in scene.casings})
		elif node is Label3D:
			nodes.append({"kind": "label", "box": box(AABB(node.global_position, Vector3.ZERO)), "look": node.text, "tag": "", "collide": false})
	var hall_node: Node3D = scene.get_node_or_null("ConnectedHall")
	var tags := canvases.keys()
	tags.sort()
	hall["retained_work_tags"] = tags
	var works = JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/prototype/gallery_walk4/works.json"))
	var listed: Array = (works if works is Array else []).map(func(w): return str(w.tag))
	listed.sort()
	hall["works_json_tags"] = listed
	hall["position"] = [hall_node.position.x, hall_node.position.y, hall_node.position.z] if hall_node else []
	hall["inventory"] = {"main_hall_rebuilt": scene.inventory.get("main_hall_rebuilt"), "main_hall_verified_paintings": scene.inventory.get("main_hall_verified_paintings"), "main_hall_native_meshes_retained": scene.inventory.get("main_hall_native_meshes_retained")}
	if FileAccess.file_exists("res://main-build-source.json"):
		var main: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://main-build-source.json"))
		var kept: Array = main.source_sha256.keys().filter(func(path): return not path.ends_with(".import"))
		hall["source_tip"] = main.source_tip
		hall["files_listed"] = main.source_sha256.size()
		hall["non_import_files_hash_equal"] = kept.filter(func(path): return FileAccess.get_sha256("res://" + path) == main.source_sha256[path]).size()
		hall["non_import_files"] = kept.size()
	# Review cameras: every named view in the project's own remodel_review.gd, moved by that file's own moved().
	var views := []
	var source := FileAccess.get_file_as_string("res://remodel_review.gd")
	var helper_script := GDScript.new()
	helper_script.source_code = "extends RefCounted\n" + source.substr(source.find("func moved("))
	if helper_script.reload() == OK:
		var helper = helper_script.new()
		var pattern := RegEx.new()
		pattern.compile("\\[\"([a-z0-9-]+)\",Vector3\\(([^)]*)\\)(?:,Vector3\\(([^)]*)\\))?\\]")
		var space := scene.get_world_3d().direct_space_state
		for hit in pattern.search_all(source):
			var numbers: Array = Array(hit.get_string(2).split(",")).map(func(t): return float(t))
			var eye: Vector3 = helper.moved(hit.get_string(1), Vector3(numbers[0], numbers[1], numbers[2]))
			var row := {"name": hit.get_string(1), "eye": [eye.x, eye.y, eye.z], "walk_start": hit.get_string(3).is_empty()}
			var point := PhysicsPointQueryParameters3D.new()
			point.position = eye + (Vector3(0, .7, 0) if row.walk_start else Vector3.ZERO)
			point.exclude = [scene.body.get_rid()]
			row["eye_inside_bodies"] = space.intersect_point(point).map(func(h): return str(h.collider.get_meta("room_wall", h.collider.name)))
			if not row.walk_start:
				numbers = Array(hit.get_string(3).split(",")).map(func(t): return float(t))
				var target: Vector3 = helper.moved(hit.get_string(1), Vector3(numbers[0], numbers[1], numbers[2]))
				row["target"] = [target.x, target.y, target.z]
				var ray := PhysicsRayQueryParameters3D.create(eye, target)
				ray.exclude = [scene.body.get_rid()]  # the visitor is hidden in these views
				var first := space.intersect_ray(ray)
				row["first_hit_fraction"] = snappedf(eye.distance_to(first.position) / eye.distance_to(target), .001) if not first.is_empty() else 1.0
				row["first_hit"] = str(first.collider.get_meta("room_wall", first.collider.name)) if not first.is_empty() else ""
			views.append(row)
	# Sight lines from the delivery's own two "source" cameras to points along the grey west wall at picture
	# height. In IMG_6380 38.3 s and IMG_6381 91.0 s every one of these points is in plain view.
	var sight := []
	var wall_points := {"south-west corner return": 1.65, "door south jamb": 1.42, "door centre": .58, "door north jamb": -.26, "barn painting place": -1.45,
		"Courbet south frame edge": -2.57, "Courbet centre": -3.06, "Courbet north frame edge": -3.55, "wall between Courbet and north-west corner": -3.9, "north-west corner": -4.13}
	for view in views:
		if view.name in ["grey-west-wall-source", "grey-west-wall-stair"]:
			var eye := Vector3(view.eye[0], view.eye[1], view.eye[2])
			for label in wall_points:
				var goal := Vector3(3.93, 1.7, wall_points[label])
				var ray := PhysicsRayQueryParameters3D.create(eye, goal)
				ray.exclude = [scene.body.get_rid()]
				var first := scene.get_world_3d().direct_space_state.intersect_ray(ray)
				var blocker := ""
				if not first.is_empty() and eye.distance_to(first.position) < eye.distance_to(goal) - .12:
					var shape = first.collider.get_child(0).shape if first.collider.get_child_count() > 0 and first.collider.get_child(0) is CollisionShape3D else null
					blocker = "%s size %s at %s" % [first.collider.get_meta("room_wall", first.collider.name), shape.size if shape is BoxShape3D else "", first.collider.global_position.snapped(Vector3.ONE * .01)]
				sight.append({"view": view.name, "eye": view.eye, "wall_point": label, "z": wall_points[label], "blocked_by": blocker})
	var report := {"views": views, "sight_lines": sight, "project": ProjectSettings.globalize_path("res://"), "godot": Engine.get_version_info().string, "rooms": geometry.rooms, "start": geometry.start,
		"grey_register": geometry.get("grey_register"), "nodes": nodes, "floors": floors, "hall": hall, "inventory": scene.inventory, "walk": {}}
	if walk:
		var names: Array = scene.trials.map(func(t): return t[0])
		report["trial_rows"] = scene.trials.map(func(t): return [t[0], [t[1].x, t[1].y, t[1].z], [t[2].x, t[2].y, t[2].z], t[3]])
		scene.trials.append(["hold", scene.trials[0][1], scene.trials[0][1], false])
		scene.phase = 0
		scene.elapsed = 0
		scene.results = {}
		scene.samples = []
		scene.reset(scene.trials[0][1])
		scene.qa = true
		while scene.phase < names.size():
			await physics_frame
		scene.qa = false
		report.walk = {"results": scene.results, "samples": scene.samples}
	FileAccess.open(out, FileAccess.WRITE).store_string(JSON.stringify(report, " ") + "\n")
	print("DUMP ", JSON.stringify({"nodes": nodes.size(), "floors": floors, "hall": hall, "trials": report.walk.get("results", {}).size()}))
	quit(0)
