## #281: the room scene built in one call and built a step a frame must be the same scene.
## Builds it both ways under main_build_walk's conditions and compares the node count and a
## hash over every node's class, name, global transform and, for a mesh, its surfaces, layers
## and visibility.
## source ~/promo-lab/gpu-env.sh; DISPLAY=:99 godot --path . --script \
##   res://modules/shell/prototype/collection_reconstruction/stepped_build_check.gd \
##   --display-driver x11 --rendering-driver opengl3
extends SceneTree

const ROOMS := "res://modules/shell/collection_rooms/remodel_room.tscn"

signal gate


func _initialize() -> void:
	call_deferred("_run")


func _line(node: Node, out: PackedStringArray, counters: RegEx) -> void:
	var where := ""
	if node is Node3D:
		var t: Transform3D = node.global_transform
		var grain := Vector3.ONE * 0.001
		where = "%s %s %s %s" % [
			t.origin.snapped(grain), t.basis.x.snapped(grain), t.basis.y.snapped(grain), t.basis.z.snapped(grain)
		]
	var extra := ""
	if node is MeshInstance3D and node.mesh != null:
		extra = " surfaces=%d layers=%d shown=%s" % [node.mesh.get_surface_count(), node.layers, node.visible]
	# The engine numbers unnamed nodes as it makes them; the numbers differ from run to run.
	out.append("%s|%s|%s%s" % [node.get_class(), counters.sub(str(node.name), "@#", true), where, extra])
	for child in node.get_children():
		_line(child, out, counters)


func _build(stepped: bool) -> Dictionary:
	var rooms: Node3D = load(ROOMS).instantiate()
	rooms.set_meta("main_build_host", true)
	var steps := 0
	if stepped:
		rooms.set_meta("build_gate", gate)
	root.add_child(rooms)
	# As main_build_walk does: the room scene's own walking and cut-away do not run.
	rooms.set_physics_process(false)
	rooms.set_process(false)
	rooms.set_process_unhandled_key_input(false)
	if stepped:
		rooms.visible = false
		while not rooms.has_meta("build_done"):
			await process_frame
			rooms.visible = true
			gate.emit()
			rooms.visible = false
			steps += 1
		rooms.visible = true
		rooms.remove_meta("build_gate")
		rooms.remove_meta("build_done")
	# What main_build_walk frees on putting the rooms in place is left out; the scene's own
	# visitor is animated and never the same twice.
	var label = rooms.get("label")
	for own in [
		rooms.get("camera"),
		rooms.get("visitor"),
		rooms.get("body"),
		label.get_parent() if is_instance_valid(label) else null,
		rooms.get("contact_shadow")
	]:
		if is_instance_valid(own):
			own.free()
	for settle in 3:
		await process_frame
	var counters := RegEx.new()
	counters.compile("@(\\d+)")
	var out := PackedStringArray()
	_line(rooms, out, counters)
	var result := {
		"steps": steps,
		"nodes": out.size(),
		"hash": "\n".join(out).sha256_text().substr(0, 16),
		"inventory": str(rooms.get("inventory")).sha256_text().substr(0, 12)
	}
	rooms.free()
	for settle in 3:
		await process_frame
	return result


func _run() -> void:
	root.size = Vector2i(960, 640)
	# Each build in a process of its own: a second build in the same process is given other
	# names by the engine, which says nothing about the build.
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--one="):
			var one: Dictionary = await _build(arg == "--one=steps")
			print("STEPPED_BUILD_ONE ", JSON.stringify(one))
			quit()
			return
	var results := []
	for mode in ["whole", "steps"]:
		var output := []
		OS.execute(
			OS.get_executable_path(),
			[
				"--path", ProjectSettings.globalize_path("res://"), "--script", (get_script() as Script).resource_path,
				"--display-driver", DisplayServer.get_name().to_lower(), "--rendering-driver", "opengl3", "--", "--one=" + mode
			],
			output,
			true
		)
		var found := {}
		for line in str(output[0]).split("\n"):
			if line.begins_with("STEPPED_BUILD_ONE "):
				found = JSON.parse_string(line.trim_prefix("STEPPED_BUILD_ONE "))
		if found.is_empty():
			print("STEPPED_BUILD_CHECK the ", mode, " build printed no result: ", str(output[0]).right(400))
		results.append(found)
	var whole: Dictionary = results[0]
	var in_steps: Dictionary = results[1]
	var same: bool = (
		not whole.is_empty()
		and whole.get("nodes") == in_steps.get("nodes")
		and whole.get("hash") == in_steps.get("hash")
		and whole.get("inventory") == in_steps.get("inventory")
	)
	print("STEPPED_BUILD_CHECK ", JSON.stringify({"same": same, "in_one_call": whole, "in_steps": in_steps}))
	quit(0 if same and int(in_steps.get("steps", 0)) > 10 else 1)
