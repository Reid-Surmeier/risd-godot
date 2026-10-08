## #277 review only: run in the --draft extension, never in the shipped game.
## timeout 8m godot --path <extension> --script <this absolute path>
## -- --walk=<main_build_walk.gd absolute path> --out=<scratch absolute path>
extends SceneTree

const SIZE := Vector2i(1100, 760)
const ATTACH := Vector3(-5.55, 0, -28.1)
const VIEWS := [
	["stair-door", Vector3(16.7, 0, -1.96), -PI / 2, Vector3(16.7, 1.65, -1.96), Vector3(20.45, 1.45, -1.96)],
	["passage", Vector3(15.75, 0, 2.20), PI, Vector3(15.75, 1.65, 2.15), Vector3(13.25, 1.5, 11.9)],
	["A-entry", Vector3(15.75, 0, 4.20), PI, Vector3(15.45, 1.65, 3.70), Vector3(13.5, 1.55, 12.70)],
	["A-windows", Vector3(13.0, 0, 7.50), -PI / 2, Vector3(11.85, 1.65, 6.3), Vector3(16.7, 1.6, 8.6)],
	["A-end-door", Vector3(15.75, 0, 11.50), PI, Vector3(14.75, 1.65, 10.40), Vector3(15.75, 1.50, 13.8)],
	["B-entry", Vector3(15.75, 0, 13.85), PI, Vector3(15.6, 1.65, 13.35), Vector3(12.65, 1.55, 21.5)],
	["B-windows", Vector3(13.6, 0, 18.50), -PI / 2, Vector3(11.65, 1.65, 17.15), Vector3(16.7, 1.6, 19.4)],
	["B-modern", Vector3(15.75, 0, 20.80), PI, Vector3(15.75, 1.65, 20.65), Vector3(15.75, 1.50, 25.6)],
	["modern-B", Vector3(15.75, 0, 23.25), 0.0, Vector3(15.75, 1.65, 24.05), Vector3(15.75, 1.5, 20.2)],
	["passage-panels", Vector3(17.90, 0, 2.04), PI, Vector3(17.90, 1.65, 1.65), Vector3(16.70, 1.45, 3.04)],
	["A-case", Vector3(14.85, 0, 9.20), PI, Vector3(15.45, 1.65, 9.10), Vector3(14.10, 1.05, 10.55)],
	["B-bench", Vector3(13.25, 0, 16.20), PI, Vector3(13.65, 1.40, 15.45), Vector3(12.0, .25, 17.70)],
	["A-Monet", Vector3(12.40, 0, 11.09), PI / 2, Vector3(12.50, 1.65, 11.09), Vector3(10.55, 1.65, 11.09)],
	["A-Cezanne", Vector3(14.90, 0, 4.39), -PI / 2, Vector3(14.90, 1.62, 4.39), Vector3(16.70, 1.62, 4.39)]
]


func _initialize() -> void:
	call_deferred("run")


func arg(name: String) -> String:
	for value in OS.get_cmdline_user_args():
		if value.begins_with("--" + name + "="):
			return value.get_slice("=", 1)
	return ""


func run() -> void:
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
		walk._cam.fov = 55.0
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
