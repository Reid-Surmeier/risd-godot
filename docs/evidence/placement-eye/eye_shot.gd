extends SceneTree
# Photographs the unbaked draft room project from absolute room-scene points (x east, y up, z south).
# godot --path <draft>/extension --display-driver x11 --rendering-method gl_compatibility --script eye_shot.gd -- <shot> ...
# shot = <out.png>:<camera x,y,z>:<aim x,y,z>[:<fov>[:<w>x<h>]]   or   plan:<out.png>:<x,z centre>:<metres across>:<cut height>[:<w>x<h>]
# list:<x0,x1,z0,z1> prints every catalogued work standing inside that rectangle.
func _initialize() -> void:
	call_deferred("run")
func v(text: String) -> Vector3:
	var p := text.split_floats(",")
	return Vector3(p[0], p[1], p[2])
func run() -> void:
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false) # it would cut walls away for the game's own camera
	var hidden := {} # what the build itself hides (the Hall's spare surfaces) stays hidden
	for node in scene.find_children("*", "Node3D", true, false):
		if not node.visible:
			hidden[node] = true
	for i in 10:
		await process_frame
	for node in scene.find_children("*", "Node3D", true, false):
		node.visible = not hidden.has(node)
	for node in scene.find_children("*", "CanvasItem", true, false):
		node.visible = false
	var cam: Camera3D = scene.camera
	for shot in OS.get_cmdline_user_args():
		var part: PackedStringArray = shot.split(":")
		if part[0] == "probe":
			var a := v(part[1])
			var b2 := v(part[2])
			for node in scene.find_children("*", "MeshInstance3D", true, false):
				var box: AABB = node.global_transform * node.get_aabb()
				if box.intersects_segment(a, b2):
					print("EYE_PROBE %s parent=%s was_hidden=%s box=%s metas=%s" % [node.name, node.get_parent().name, hidden.has(node) or hidden.has(node.get_parent()), box, node.get_parent().get_meta_list()])
			continue
		if part[0] == "list":
			var b := part[1].split_floats(",")
			for node in scene.find_children("*", "Node3D", true, false):
				var p: Vector3 = node.global_position
				if p.x < b[0] or p.x > b[1] or p.z < b[2] or p.z > b[3]:
					continue
				var tag := ""
				for key in node.get_meta_list():
					if key in ["catalogue_accession", "catalogue_title", "accession", "furniture", "inventory_asset"]:
						tag += " %s=%s" % [key, node.get_meta(key)]
				if tag != "":
					print("EYE_LIST %s (%.2f, %.2f, %.2f) yaw %.0f%s" % [node.name, p.x, p.y, p.z, rad_to_deg(node.global_rotation.y), tag])
			continue
		var size := Vector2i(540, 960)
		if part[0] == "plan":
			var c := part[2].split_floats(",")
			if part.size() > 5:
				size = Vector2i(int(part[5].get_slice("x", 0)), int(part[5].get_slice("x", 1)))
			root.size = size
			cam.projection = Camera3D.PROJECTION_ORTHOGONAL
			cam.size = float(part[3])
			cam.keep_aspect = Camera3D.KEEP_WIDTH
			cam.near = 0.01
			cam.global_transform = Transform3D(Basis(), Vector3(c[0], float(part[4]), c[1])).looking_at(Vector3(c[0], 0, c[1]), Vector3(0, 0, -1))
		else:
			if part.size() > 4:
				size = Vector2i(int(part[4].get_slice("x", 0)), int(part[4].get_slice("x", 1)))
			root.size = size
			cam.projection = Camera3D.PROJECTION_PERSPECTIVE
			cam.fov = float(part[3]) if part.size() > 3 else 70.0
			cam.global_transform = Transform3D(Basis(), v(part[1])).looking_at(v(part[2]), Vector3.UP)
		for i in 6:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(part[1] if part[0] == "plan" else part[0])
	print("EYE_SHOT done")
	quit(0)
