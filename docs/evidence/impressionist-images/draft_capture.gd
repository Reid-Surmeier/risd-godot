## #277 twelve-picture review only: run in the --draft extension, never in the shipped game.
## timeout 8m godot --path <extension> --script <this absolute path>
## -- --walk=<main_build_walk.gd absolute path> --out=<scratch absolute path>
extends SceneTree

const SIZE := Vector2i(1100, 760)
const ATTACH := Vector3(-5.55, 0, -28.1)
const VIEWS := [
	["B-north", Vector3(13.5, 0, 16.7), 0.0, Vector3(13.5, 1.65, 16.7), Vector3(13.5, 1.65, 12.70)],
	["A-north", Vector3(13.4, 0, 6.7), 0.0, Vector3(13.6, 1.65, 6.7), Vector3(13.6, 1.65, 3.04)],
	["A-west", Vector3(15.4, 0, 7.85), PI / 2, Vector3(16.0, 1.65, 7.85), Vector3(10.55, 1.65, 7.85)],
	["A-south", Vector3(12.8, 0, 8.5), PI, Vector3(13.25, 1.65, 8.5), Vector3(13.25, 1.65, 12.70)],
	["A-east", Vector3(11.3, 0, 7.65), -PI / 2, Vector3(11.1, 1.65, 7.65), Vector3(16.70, 1.65, 7.65)],
	["B-west", Vector3(15.4, 0, 18.05), PI / 2, Vector3(15.8, 1.65, 18.05), Vector3(10.55, 1.65, 18.05)],
	["B-south", Vector3(13.3, 0, 18.15), PI, Vector3(13.3, 1.65, 18.15), Vector3(13.3, 1.65, 22.30)],
	["B-east-north", Vector3(11.7, 0, 15.3), -PI / 2, Vector3(11.7, 1.65, 15.3), Vector3(16.70, 1.65, 15.3)],
	["B-east-south", Vector3(11.7, 0, 20.0), -PI / 2, Vector3(11.7, 1.65, 20.0), Vector3(16.70, 1.65, 20.0)],
	["42.190", Vector3(14.55, 0, 5.04), 0.0, Vector3(14.55, 1.62, 4.65), Vector3(14.55, 1.62, 3.04)],
	["2007.68", Vector3(13.35, 0, 5.04), 0.0, Vector3(13.35, 1.65, 5.04), Vector3(13.35, 1.65, 3.04)],
	["57.236", Vector3(12.6, 0, 8.44), PI / 2, Vector3(12.6, 1.65, 8.44), Vector3(10.55, 1.65, 8.44)],
	["59.027", Vector3(12.8, 0, 9.6), PI, Vector3(12.8, 1.59, 9.6), Vector3(12.8, 1.59, 12.70)],
	["23.072", Vector3(14.7, 0, 8.24), -PI / 2, Vector3(14.7, 1.64, 8.24), Vector3(16.7, 1.64, 8.24)],
	["72.096", Vector3(12.6, 0, 17.85), PI / 2, Vector3(12.6, 1.64, 17.85), Vector3(10.55, 1.64, 17.85)],
	["1999.3", Vector3(12.6, 0, 20.65), PI / 2, Vector3(12.6, 1.64, 20.65), Vector3(10.55, 1.64, 20.65)],
	["33.053", Vector3(11.7, 0, 20.3), PI, Vector3(11.7, 1.65, 20.3), Vector3(11.7, 1.65, 22.3)],
	["2021.101", Vector3(14.7, 0, 13.63), -PI / 2, Vector3(15.5, 1.64, 13.63), Vector3(16.7, 1.64, 13.63)],
	["2010.57", Vector3(14.7, 0, 15.06), -PI / 2, Vector3(14.7, 1.65, 15.06), Vector3(16.7, 1.65, 15.06)],
	["35.770", Vector3(14.7, 0, 16.36), -PI / 2, Vector3(15.1, 1.65, 16.36), Vector3(16.7, 1.65, 16.36)],
	["60.095", Vector3(14.7, 0, 19.50), -PI / 2, Vector3(14.7, 1.65, 19.50), Vector3(16.7, 1.65, 19.50)]
]

func _initialize() -> void:
	call_deferred("run")


func arg(name: String) -> String:
	for value in OS.get_cmdline_user_args():
		if value.begins_with("--" + name + "="):
			return value.get_slice("=", 1)
	return ""


func run() -> void:
	for dependency in ["res://modules/shell/character/visitor.gd", "res://modules/tab_strip/assets/icon_close.png", "res://modules/tab_strip/assets/icon_close_pressed.png", "res://modules/shell/collection_rooms/objects.json", "res://modules/shell/collection_rooms/representation.json"]:
		if not FileAccess.file_exists(dependency):
			push_error("Draft capture needs its unchanged dependency copy: " + dependency)
			quit(1)
			return
	DirAccess.make_dir_recursive_absolute(arg("out"))
	root.size = SIZE
	var walk = load(arg("walk")).new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	await process_frame
	if walk._rooms == null and walk._rooms_path != "":
		walk._attach_rooms(walk._rooms_path)
	for i in 30:
		await process_frame
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	var failures := []
	var trials := []
	for row in data.trials:
		if not str(row[0]).begins_with("impressionist_") and not str(row[0]).begins_with("modern_far_opening_"):
			continue
		if row[3]:
			continue
		var a := Vector3(row[1][0], 0, row[1][2]) + ATTACH
		var b := Vector3(row[2][0], 0, row[2][2]) + ATTACH
		var clear := true
		for j in range(41):
			clear = walk._free(a.lerp(b, j / 40.0)) and clear
		trials.append({"trial": row[0], "clear": clear})
		if not clear:
			failures.append(row[0])
	print("IMPRESSIONIST_DRAFT_ROUTE ", JSON.stringify({"trials": trials, "failures": failures}))
	for view in VIEWS:
		if not arg("views").is_empty() and view[0] not in arg("views").split(","):
			continue
		for node in walk._vp.get_children():
			if node is WorldEnvironment:
				node.environment.ambient_light_energy = 0.0
		walk.set_process(true)
		walk._cut_state = 0
		walk._floor_mask_stage = -2
		walk._new_action()
		walk._target = null
		walk._held.clear()
		walk._velocity = Vector3.ZERO
		walk._pos = view[1] + ATTACH
		walk._last_pos = walk._pos
		walk._kid.position = walk._pos
		var index: int = walk._room_at(walk._pos)
		walk._space = "far" if walk._plan[index].far else "arch"
		walk.view_mode = 0
		walk.view_yaw = view[2]
		walk._yaw = view[2]
		for i in 40:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(arg("out").path_join(view[0] + "-game.png"))
		walk.set_process(false)
		walk._kid.hide()
		walk._shadow.hide()
		walk._cam.fov = 60.0 if view[0] == "service-leaf" else 55.0
		walk._cam.global_transform = Transform3D(Basis(), view[3] + ATTACH).looking_at(view[4] + ATTACH, Vector3.UP)
		# Close geometry review shows the neighbours too; the game's stage view is above.
		walk._floor_mask.hide()
		walk._cam.cull_mask |= 2048 | 4096
		# Geometry photographs need the draft's .55 ambient: the actual adapter expects
		# a bake and sets far-room ambient to zero. Game photographs retain that zero.
		# This review-only fill is not a source lamp edit or a finished-lighting claim.
		for node in walk._vp.get_children():
			if node is WorldEnvironment:
				node.environment.ambient_light_energy = .55
		for part in walk._parts:
			part.node.visible = part.shown
		for wall in walk._walls:
			for j in range(1, wall.body.get_child_count()):
				wall.body.get_child(j).show()
		for ceiling in walk._rooms.ceiling_details:
			if is_instance_valid(ceiling) and ceiling.has_meta("opaque_ceiling"):
				ceiling.show()
		for i in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(arg("out").path_join(view[0] + "-close.png"))
		walk._kid.show()
		walk._shadow.show()
	print("IMPRESSIONIST_DRAFT_CAPTURE_DONE")
	quit(0 if failures.is_empty() else 1)
