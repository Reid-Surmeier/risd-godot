## Review run on a private copy of root's frozen full app v50m: views and traces root's set does not include.
extends SceneTree

var walk
var output: String

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
	walk._path.clear()
	walk._pos = at
	walk._last_pos = at
	walk._kid.position = at
	walk._update_camera(1.0)

func layer8() -> Dictionary:
	var entries: Array = walk._cutaway_materials.get(8, [])
	var original := 0
	for entry in entries:
		if entry.mesh.material_override == entry.original:
			original += 1
	return {"alpha": float(walk._cutaway_alpha[8]), "meshes": entries.size(), "with_original_material": original}

func trace(name: String, space: String, at: Vector3, key: String, stop_z: float, toward_positive: bool) -> Dictionary:
	place(space, 0, 0.0, at)
	walk._held[key] = 0.0
	var spaces := [space]
	var worst_step := 0.0
	var worst_flash := 0.0
	var before: Vector3 = walk._pos
	var frames := 0
	for i in 240:
		walk._process(1.0 / 30.0)
		frames += 1
		worst_step = maxf(worst_step, walk._pos.distance_to(before))
		before = walk._pos
		worst_flash = maxf(worst_flash, walk._portal_flash.modulate.a)
		if walk._space != spaces[-1]:
			spaces.append(walk._space)
		if (toward_positive and walk._pos.z >= stop_z) or (not toward_positive and walk._pos.z <= stop_z):
			break
	var row := {"name": name, "start": [at.x, at.z], "end": [walk._pos.x, walk._pos.z], "frames": frames, "spaces": spaces,
		"largest_step_m": worst_step, "step_limit_m": walk.WALK_MPS / 30.0, "largest_flash_alpha": worst_flash,
		"view_yaw_end": walk.view_yaw, "held_at_end": walk._held.keys(), "reached": (walk._pos.z >= stop_z) if toward_positive else (walk._pos.z <= stop_z)}
	walk._held.clear()
	return row

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
	var proof := {"views": [], "traces": [], "plinth": {}}
	# name, position (Hall metres), space, view mode, heading, optional earlier state to pass through first
	for row in [
		["grey-follow-south-after-facing-north", Vector3(0, 0, -30.5), "far", 2, PI, [Vector3(0, 0, -25.5), "gallery", 0, 0.0]],
		["grey-follow-south-fresh", Vector3(0, 0, -30.5), "far", 2, PI, [Vector3(0, 0, -25.5), "gallery", 0, PI]],
		["connector-dollhouse-south", Vector3(-2.6, 0, -27.8), "far", 0, PI, null],
		["rockefeller-dollhouse-south", Vector3(-7.0, 0, -29.3), "far", 0, PI, [Vector3(0, 0, -25.5), "gallery", 0, 0.0]],
		["rockefeller-gallery-view-east", Vector3(-7.0, 0, -29.3), "far", 1, -PI / 2, null],
		["west-gallery-dollhouse-north", Vector3(-8.05, 0, -24.3), "arch", 0, 0.0, null],
		["roch-dollhouse-west", Vector3(-9.0, 0, 3.85), "arch", 0, PI / 2, null],
		["roch-dollhouse-north", Vector3(-9.0, 0, 3.85), "arch", 0, 0.0, null],
		["roch-dollhouse-south", Vector3(-9.0, 0, 3.85), "arch", 0, PI, null],
		["roch-gallery-view-west", Vector3(-9.0, 0, 3.85), "arch", 1, PI / 2, null],
		["roch-follow-west", Vector3(-8.2, 0, 3.85), "arch", 2, PI / 2, null],
		["roch-follow-northwest", Vector3(-7.4, 0, 5.3), "arch", 2, PI / 4, null],
	]:
		if row[5] != null:
			place(row[5][1], row[5][2], row[5][3], row[5][0])
			for i in 4: await process_frame
		place(row[2], row[3], row[4], row[1])
		for i in 6: await process_frame
		await RenderingServer.frame_post_draw
		assert(walk._vp.get_texture().get_image().save_png(output.path_join("native-" + row[0] + ".png")) == OK)
		proof.views.append({"name": row[0], "space": walk._space, "view_mode": walk.view_mode, "heading": row[4],
			"position": [walk._pos.x, walk._pos.z], "cull_mask": walk._cam.cull_mask, "layer8": layer8(),
			"hall_field_on": walk._baked_room.get_node("Lightmap").visible,
			"addition_field_on": walk._rooms.get_node("BakedRoom/Lightmap").visible})
	# Held-key walks through the two kinds of doorway, stepped by hand at 30 frames a second.
	proof.traces.append(trace("rockefeller-to-west-gallery", "far", Vector3(-8.05, 0, -27.5), "down", -25.0, true))
	proof.traces.append(trace("west-gallery-to-rockefeller", "arch", Vector3(-8.05, 0, -25.0), "up", -27.5, false))
	proof.traces.append(trace("hall-to-grey", "gallery", Vector3(0, 0, -25.0), "up", -27.5, false))
	proof.traces.append(trace("grey-to-hall", "far", Vector3(0, 0, -27.5), "down", -25.0, true))
	# The plinth: where may the visitor stand, and where does a held key stop it.
	place("arch", 0, 0.0, Vector3(-9.0, 0, 3.85))
	var samples := {}
	for x in [-10.41, -9.96, -9.80, -9.70, -9.0]:
		samples[str(x)] = walk._walkable(Vector3(x, 0, 3.85))
	walk._held["left"] = 0.0
	for i in 150: walk._process(1.0 / 30.0)
	walk._held.clear()
	proof.plinth = {"centre_x": -10.41, "east_face_x": -10.06, "walkable_at_x_on_z_3.85": samples, "held_left_from_x_-9.0_stops_at": [walk._pos.x, walk._pos.z]}
	var room = walk._rooms
	proof["inventory_saint_roch"] = room.inventory.get("saint_roch")
	for node in room.find_children("SaintRoch21398", "Node3D", true, false):
		proof["saint_roch_node"] = {"world": [node.global_position.x, node.global_position.y, node.global_position.z], "yaw_deg": rad_to_deg(node.global_rotation.y),
			"visual_fidelity_accepted": node.get_meta("visual_fidelity_accepted"), "placement_accepted": node.get_meta("placement_accepted"),
			"rear_fidelity_accepted": node.get_meta("rear_fidelity_accepted"), "survey_metres_accepted": node.get_meta("survey_metres_accepted"),
			"parent_has_collision": node.get_parent() is StaticBody3D, "mesh_children": node.get_child_count()}
	var flags := {}
	for key in room.inventory:
		if str(key).ends_with("accepted") or str(key).ends_with("complete"):
			flags[key] = room.inventory[key]
	proof["top_level_flags"] = flags
	FileAccess.open(output.path_join("native-review-v50m.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	print("REVIEW_V50M_OK")
	quit()
