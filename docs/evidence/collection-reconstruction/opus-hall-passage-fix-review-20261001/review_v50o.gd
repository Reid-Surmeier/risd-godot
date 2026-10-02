## Review run on a private copy of root's frozen full app v50o: the two wall passages, the cutaway
## owners, the new Renaissance cases and the visitor's light. Reads the app; changes nothing in it.
extends SceneTree

var walk
var output: String
var proof := {"views": [], "traces": [], "free_views": [], "visitor_light": []}

func _initialize() -> void:
	call_deferred("run")

func place(space: String, mode: int, heading: float, at: Vector3) -> void:
	walk._space = space
	walk.view_mode = mode
	walk.view_yaw = heading
	walk._yaw = heading
	walk._view_turn_remaining = 0.0
	walk._velocity = Vector3.ZERO
	walk._held.clear()
	walk._target = null
	walk._target_yaw = null
	walk._path.clear()
	walk._pos = at
	walk._last_pos = at
	walk._kid.position = at
	walk._update_camera(1.0)

func save(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(walk._vp.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func box_of(body: Node3D) -> AABB:
	var shape = (body.get_child(0) as CollisionShape3D).shape
	return body.global_transform * AABB(-shape.size / 2.0, shape.size)

# Which standing things lie on the line from the camera to the visitor, and whether they are still drawn.
func between(bodies: Array) -> Array:
	var rows := []
	var eye: Vector3 = walk._cam.global_position
	for body in bodies:
		var hit := false
		for height in [0.5, 1.0, 1.5]:
			if box_of(body).intersects_segment(eye, walk._pos + Vector3(0, height, 0)) != null:
				hit = true
		if hit:
			rows.append({"tag": str(body.get_meta("room_wall", body.name)), "still_drawn": body.get_child(1).visible})
	return rows

func hidden_walls() -> Array:
	var rows := []
	for wall in walk._walls:
		if not wall.body.get_child(1).visible:
			rows.append(str(wall.body.get_meta("room_wall", wall.body.name)))
	return rows

func trace(name: String, space: String, mode: int, heading: float, at: Vector3, keys: Array, stop_z: float, toward_positive: bool, frames_max := 300) -> void:
	place(space, mode, heading, at)
	for key in keys:
		walk._held[key] = 0.0
	var spaces := [space]
	var swaps := []
	var worst_step := 0.0
	var worst_flash := 0.0
	var before: Vector3 = walk._pos
	var frames := 0
	var x_range := [at.x, at.x]
	var fields := {}
	for i in frames_max:
		walk._process(1.0 / 30.0)
		frames += 1
		worst_step = maxf(worst_step, walk._pos.distance_to(before))
		before = walk._pos
		worst_flash = maxf(worst_flash, walk._portal_flash.modulate.a)
		x_range = [minf(x_range[0], walk._pos.x), maxf(x_range[1], walk._pos.x)]
		if walk._space != spaces[-1]:
			spaces.append(walk._space)
			swaps.append([walk._pos.x, walk._pos.z])
		var field := "hall" if walk._baked_room.get_node("Lightmap").visible else ""
		field += "+addition" if walk._rooms.get_node("BakedRoom/Lightmap").visible else ""
		if not fields.has(field):
			fields[field] = [walk._pos.z, walk._pos.z]
		fields[field] = [minf(fields[field][0], walk._pos.z), maxf(fields[field][1], walk._pos.z)]
		if (toward_positive and walk._pos.z >= stop_z) or (not toward_positive and walk._pos.z <= stop_z):
			break
	proof.traces.append({"name": name, "view_mode": mode, "keys": keys, "start": [at.x, at.z], "end": [walk._pos.x, walk._pos.z], "frames": frames,
		"spaces": spaces, "swap_points": swaps, "largest_step_m": worst_step, "step_limit_m": walk.WALK_MPS / 30.0, "largest_flash_alpha": worst_flash,
		"x_range": x_range, "probe_field_by_z": fields, "heading_end": walk.view_yaw if mode != 2 else walk._yaw, "held_at_end": walk._held.keys(),
		"reached": (walk._pos.z >= stop_z) if toward_positive else (walk._pos.z <= stop_z)})
	walk._held.clear()

# A camera of my own, for the footage's eye-level poses. Every cutaway body is drawn.
func free_view(name: String, space: String, visitor: Vector3, eye: Vector3, target: Vector3, fov: float) -> void:
	place(space, 0, PI, visitor)
	for wall in walk._walls:
		for i in range(1, wall.body.get_child_count()):
			wall.body.get_child(i).visible = true
	walk._cam.global_position = eye
	walk._cam.look_at(target)
	walk._cam.fov = fov
	walk._cam.cull_mask = 0xFFFFF
	walk._rooms.update_baked_visibility()
	await save(name)
	proof.free_views.append({"name": name, "eye": [eye.x, eye.y, eye.z], "target": [target.x, target.y, target.z], "fov": fov})

func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(1440, 1000)
	var app = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150: await process_frame
	walk = app.find_child("GalleryWalk", true, false)
	assert(walk != null and walk.state().attached)
	walk.set_process(false)
	walk._entrance_waiting = false
	walk._entrance_active = false
	walk._target_yaw = null
	walk._set_lighting(true)
	var room = walk._rooms
	proof["state"] = walk.state()
	proof["probes"] = room.get_node("BakedRoom/Lightmap").light_data.get("probe_data").points.size()

	# 1. Who owns the new pieces for the camera cutaway.
	var in_walls := {}
	for wall in walk._walls:
		in_walls[wall.body] = true
	var leaves := []
	var linings := []
	var pieces := []
	for body in room.casings:
		if not is_instance_valid(body):
			continue
		var tag := str(body.get_meta("room_wall", ""))
		if body.has_meta("hall_reveal_leaf") or tag.begins_with("Rockefeller reveal threshold:"):
			var box := box_of(body)
			var blocked := false
			for block in walk._blocks:
				if block.intersects(Rect2(box.position.x, box.position.z, box.size.x, box.size.z)):
					blocked = true
			var row := {"tag": tag, "cutaway_body": in_walls.has(body), "children": body.get_child_count(), "layers": body.get_child(1).layers,
				"box_min": [box.position.x, box.position.y, box.position.z], "box_max": [box.end.x, box.end.y, box.end.z], "walk_block": blocked}
			pieces.append(row)
			if body.has_meta("hall_reveal_leaf"):
				leaves.append(body)
			else:
				linings.append(body)
	proof["reveal_pieces"] = pieces

	# 2. The wall cases against their walls.
	var cases := {}
	for key in ["triptych_wall_case", "pieta_wall_case", "saint_roch_installation"]:
		for body in room.casings:
			if is_instance_valid(body) and body.has_meta(key):
				var box := box_of(body)
				var extent := box
				for child in body.find_children("*", "MeshInstance3D", true, false):
					if child.mesh != null and child.mesh.get_surface_count() > 0:
						extent = extent.merge(child.global_transform * child.mesh.get_aabb())
				var parent: Node = body.get_parent()
				var row := {"shelf_min": [box.position.x, box.position.y, box.position.z], "shelf_max": [box.end.x, box.end.y, box.end.z],
					"all_min": [extent.position.x, extent.position.y, extent.position.z], "all_max": [extent.end.x, extent.end.y, extent.end.z],
					"owner": str(parent.get_meta("room_wall", parent.name)), "owner_is_cutaway_body": in_walls.has(parent), "own_cutaway_body": in_walls.has(body)}
				if parent is StaticBody3D:
					var face: AABB = parent.get_child(1).global_transform * parent.get_child(1).mesh.get_aabb()
					row["owner_face_min"] = [face.position.x, face.position.y, face.position.z]
					row["owner_face_max"] = [face.end.x, face.end.y, face.end.z]
				cases[key] = row
	proof["cases"] = cases
	var flags := {}
	for key in room.inventory:
		if str(key).ends_with("accepted") or str(key).ends_with("complete"):
			flags[key] = room.inventory[key]
	proof["top_level_flags"] = flags
	for key in ["hall_reveal", "saint_roch", "renaissance_triptych", "renaissance_pieta"]:
		proof["inventory_" + key] = room.inventory.get(key)

	# 3. The game's own cameras. name, position (Hall metres), space, view mode, heading.
	var hall_mid := Vector3(0, 0, -26.68)
	var rock_mid := Vector3(-8.05, 0, -26.68)
	for row in [
		["hall-passage-dollhouse-north", hall_mid, "far", 0, 0.0],
		["hall-passage-dollhouse-west", hall_mid, "far", 0, PI / 2],
		["hall-passage-dollhouse-south", hall_mid, "far", 0, PI],
		["hall-passage-dollhouse-east", hall_mid, "far", 0, -PI / 2],
		["hall-passage-gallery-west", hall_mid, "far", 1, PI / 2],
		["hall-passage-gallery-east", hall_mid, "far", 1, -PI / 2],
		["hall-passage-follow-north", hall_mid, "far", 2, 0.0],
		["hall-passage-follow-south", hall_mid, "far", 2, PI],
		["hall-side-of-door-dollhouse-north", Vector3(0, 0, -25.4), "gallery", 0, 0.0],
		["hall-side-of-door-follow-north", Vector3(0, 0, -24.6), "gallery", 2, 0.0],
		["grey-side-of-door-dollhouse-south", Vector3(0, 0, -28.2), "far", 0, PI],
		["grey-side-of-door-dollhouse-north", Vector3(0, 0, -28.2), "far", 0, 0.0],
		["grey-side-of-door-follow-south", Vector3(0, 0, -29.6), "far", 2, PI],
		["grey-near-south-wall-follow-north", Vector3(2.0, 0, -28.0), "far", 2, 0.0],
		["grey-near-south-wall-dollhouse-west", Vector3(2.4, 0, -27.6), "far", 0, PI / 2],
		["rockefeller-passage-dollhouse-north", rock_mid, "far", 0, 0.0],
		["rockefeller-passage-dollhouse-west", rock_mid, "far", 0, PI / 2],
		["rockefeller-passage-dollhouse-south", rock_mid, "far", 0, PI],
		["rockefeller-passage-dollhouse-east", rock_mid, "far", 0, -PI / 2],
		["rockefeller-passage-gallery-east", rock_mid, "far", 1, -PI / 2],
		["rockefeller-passage-follow-north", rock_mid, "far", 2, 0.0],
		["rockefeller-passage-follow-south", rock_mid, "far", 2, PI],
		["west-gallery-side-of-door-dollhouse-north", Vector3(-8.05, 0, -25.2), "arch", 0, 0.0],
		["rockefeller-side-of-door-dollhouse-south", Vector3(-8.05, 0, -28.2), "far", 0, PI],
		["rockefeller-side-of-door-follow-south", Vector3(-8.05, 0, -29.4), "far", 2, PI],
		["west-gallery-side-of-door-follow-north", Vector3(-8.05, 0, -23.6), "arch", 2, 0.0],
		["renaissance-dollhouse-north", Vector3(-8.6, 0, 2.6), "arch", 0, 0.0],
		["renaissance-dollhouse-west", Vector3(-9.2, 0, 2.2), "arch", 0, PI / 2],
		["renaissance-dollhouse-south", Vector3(-9.6, 0, 1.6), "arch", 0, PI],
		["renaissance-dollhouse-east", Vector3(-9.6, 0, 1.9), "arch", 0, -PI / 2],
		["renaissance-gallery-west", Vector3(-9.2, 0, 2.2), "arch", 1, PI / 2],
		["renaissance-gallery-north", Vector3(-9.4, 0, 2.0), "arch", 1, 0.0],
		["renaissance-follow-northwest", Vector3(-8.3, 0, 3.4), "arch", 2, PI / 4],
		["renaissance-follow-north", Vector3(-9.4, 0, 2.9), "arch", 2, 0.0],
		["renaissance-follow-east-camera-behind-west-wall", Vector3(-10.25, 0, 1.7), "arch", 2, -PI / 2],
		["renaissance-follow-south-camera-behind-north-wall", Vector3(-10.05, 0, 1.3), "arch", 2, PI],
	]:
		place(row[2], row[3], row[4], row[1])
		await save("game-" + row[0])
		proof.views.append({"name": row[0], "space": walk._space, "view_mode": row[3], "heading": row[4], "position": [walk._pos.x, walk._pos.z],
			"camera": [walk._cam.global_position.x, walk._cam.global_position.y, walk._cam.global_position.z], "cull_mask": walk._cam.cull_mask,
			"leaf_or_lining_between_camera_and_visitor": between(leaves + linings), "hidden_cutaway_bodies": hidden_walls(),
			"hall_field_on": walk._baked_room.get_node("Lightmap").visible, "addition_field_on": room.get_node("BakedRoom/Lightmap").visible})

	# 4. Camera history across the new passage: dollhouse facing north in the Hall, then follow south from the grey side.
	place("gallery", 0, 0.0, Vector3(0, 0, -25.5))
	for i in 4: await process_frame
	place("far", 2, PI, Vector3(0, 0, -27.6))
	await save("game-grey-follow-south-after-hall-north")
	var entries: Array = walk._cutaway_materials.get(8, [])
	var original := 0
	for entry in entries:
		if entry.mesh.material_override == entry.original:
			original += 1
	proof["history_after_hall_north"] = {"layer8_alpha": float(walk._cutaway_alpha[8]), "end_wall_meshes": entries.size(), "on_original_material": original, "cull_mask": walk._cam.cull_mask}

	# 5. Held-key walks, stepped by hand at 30 frames a second. Dollhouse "up" is north at heading 0.
	trace("hall-to-grey", "gallery", 0, 0.0, Vector3(0, 0, -25.0), ["up"], -28.3, false)
	trace("grey-to-hall", "far", 0, 0.0, Vector3(0, 0, -28.3), ["down"], -25.0, true)
	trace("west-gallery-to-rockefeller", "arch", 0, 0.0, Vector3(-8.05, 0, -25.0), ["up"], -28.3, false)
	trace("rockefeller-to-west-gallery", "far", 0, 0.0, Vector3(-8.05, 0, -28.3), ["down"], -25.0, true)
	trace("grey-to-hall-off-axis-0.55", "far", 0, 0.0, Vector3(0.55, 0, -28.3), ["down"], -25.0, true, 200)
	trace("grey-to-hall-off-axis-0.70", "far", 0, 0.0, Vector3(0.70, 0, -28.3), ["down"], -25.0, true, 200)
	trace("grey-to-hall-diagonal-from-east", "far", 0, 0.0, Vector3(1.6, 0, -28.6), ["down", "left"], -25.0, true)
	trace("hall-to-grey-diagonal", "gallery", 0, 0.0, Vector3(-0.3, 0, -25.0), ["up", "right"], -28.3, false)
	trace("rockefeller-to-west-off-axis-0.6", "far", 0, 0.0, Vector3(-7.45, 0, -28.3), ["down"], -25.0, true, 200)
	trace("west-to-rockefeller-diagonal", "arch", 0, 0.0, Vector3(-8.6, 0, -25.0), ["up", "right"], -28.3, false)
	trace("follow-hall-to-grey", "gallery", 2, 0.0, Vector3(0, 0, -25.0), ["up"], -28.3, false)
	trace("follow-grey-to-hall", "far", 2, PI, Vector3(0, 0, -28.3), ["up"], -25.0, true)
	trace("follow-west-gallery-to-rockefeller", "arch", 2, 0.0, Vector3(-8.05, 0, -25.0), ["up"], -28.3, false)
	trace("follow-rockefeller-to-west-gallery", "far", 2, PI, Vector3(-8.05, 0, -28.3), ["up"], -25.0, true)
	# Walking straight at a leaf from inside the passage.
	trace("passage-into-east-leaf", "far", 0, 0.0, hall_mid, ["right"], 99.0, true, 60)
	trace("passage-into-west-lining", "far", 0, 0.0, rock_mid, ["left"], 99.0, true, 60)

	# 6. The visitor's own light along both passages: a close camera on its back, 1.7 m south, all layers on.
	for line in [["hall", 0.0], ["rockefeller", -8.05]]:
		for z in [-24.8, -25.6, -26.1, -26.28, -26.32, -26.5, -26.68, -26.9, -27.04, -27.08, -27.4, -28.2, -29.5]:
			var space := "far"
			if z > -26.3:
				space = "gallery" if line[0] == "hall" else "arch"
			var at := Vector3(line[1], 0, z)
			place(space, 0, 0.0, at)
			walk._kid.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
			for wall in walk._walls:
				for i in range(1, wall.body.get_child_count()):
					wall.body.get_child(i).visible = true
			walk._cam.global_position = at + Vector3(0, 1.25, 1.7)
			walk._cam.look_at(at + Vector3(0, 1.0, 0))
			walk._cam.fov = 40.0
			walk._cam.cull_mask = 0xFFFFF
			room.update_baked_visibility()
			var name := "light-%s-%.2f" % [line[0], -z]
			await save(name)
			proof.visitor_light.append({"line": line[0], "z": z, "space": space, "file": name + ".png", "room": walk._plan[walk._room_at(at)].label if walk._room_at(at) >= 0 else "Hall or stone passage",
				"hall_field_on": walk._baked_room.get_node("Lightmap").visible, "addition_field_on": room.get_node("BakedRoom/Lightmap").visible})

	# 7. The footage's poses, eye level.
	var away_far := Vector3(3.0, 0, -31.0)
	var away_ren := Vector3(-6.6, 0, 5.2)
	await free_view("pose-6343-0.5s-hall-door-from-grey", "far", away_far, Vector3(0.1, 1.5, -32.2), Vector3(0, 1.45, -27.0), 62.0)
	await free_view("pose-6343-35s-hall-door-oblique", "far", away_far, Vector3(-2.2, 1.5, -31.6), Vector3(0.6, 1.4, -27.0), 62.0)
	await free_view("pose-6380-106s-hall-door-close", "far", away_far, Vector3(-1.5, 1.45, -28.7), Vector3(0.35, 1.35, -26.7), 70.0)
	await free_view("pose-6344-25s-door-from-hall", "gallery", Vector3(2.5, 0, -18.0), Vector3(0.0, 1.5, -22.6), Vector3(0, 1.45, -26.6), 50.0)
	await free_view("pose-hall-door-inside-passage-east-leaf", "far", away_far, Vector3(-0.55, 1.45, -27.5), Vector3(0.93, 1.35, -26.7), 70.0)
	await free_view("pose-6385-1s-rockefeller-door-from-west-gallery", "arch", Vector3(-9.6, 0, -20.0), Vector3(-9.5, 1.5, -24.9), Vector3(-7.4, 1.45, -26.7), 70.0)
	await free_view("pose-rockefeller-door-from-rockefeller", "far", Vector3(-6.0, 0, -31.0), Vector3(-8.3, 1.5, -29.6), Vector3(-8.05, 1.4, -26.7), 62.0)
	await free_view("pose-6383-62s-west-wall-and-corner", "arch", away_ren, Vector3(-6.2, 1.55, 5.3), Vector3(-10.6, 1.35, 1.5), 74.0)
	await free_view("pose-6383-63.9s-north-wall", "arch", away_ren, Vector3(-8.3, 1.55, 5.5), Vector3(-8.7, 1.5, 0.0), 74.0)
	await free_view("pose-6383-71.9s-triptych-from-east", "arch", away_ren, Vector3(-8.2, 1.5, 2.3), Vector3(-10.05, 1.4, 0.35), 60.0)
	await free_view("pose-6383-30.2s-triptych-close", "arch", away_ren, Vector3(-10.05, 1.45, 1.55), Vector3(-10.05, 1.4, 0.3), 50.0)
	await free_view("pose-6383-24.6s-pieta-close", "arch", away_ren, Vector3(-9.75, 1.42, 1.72), Vector3(-10.8, 1.3, 1.7), 50.0)
	await free_view("pose-6383-18.3s-saint-roch", "arch", away_ren, Vector3(-9.35, 1.25, 4.75), Vector3(-10.41, 1.25, 3.85), 62.0)
	await free_view("check-triptych-case-against-wall-side", "arch", away_ren, Vector3(-9.0, 1.5, 0.75), Vector3(-10.4, 1.45, 0.25), 45.0)
	await free_view("check-triptych-rear-from-wall-side", "arch", away_ren, Vector3(-9.3, 1.75, 0.09), Vector3(-10.05, 1.45, 0.3), 60.0)
	await free_view("check-pieta-case-against-wall-side", "arch", away_ren, Vector3(-10.2, 1.5, 3.0), Vector3(-11.0, 1.45, 1.7), 45.0)
	await free_view("check-wall-thickness-from-above", "far", away_far, Vector3(-3.5, 9.5, -22.0), Vector3(-3.5, 0.0, -26.7), 55.0)

	FileAccess.open(output.path_join("native-review-v50o.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	print("REVIEW_V50O_OK")
	quit()
