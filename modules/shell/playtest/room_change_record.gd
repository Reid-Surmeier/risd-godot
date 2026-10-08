## #260 room-change recorder: walks the visitor through doorways with held keys, both ways, and
## saves ten pictures a second of the whole view. It judges nothing; museum_playtest.gd does.
## source ~/promo-lab/gpu-env.sh; DISPLAY=:99 godot --fixed-fps 60 --path . \
##   --script res://modules/shell/playtest/room_change_record.gd \
##   --display-driver x11 --rendering-driver opengl3 -- --out-dir=res://build/room-change [--doors=0,3]
## With --no-pictures and without --fixed-fps it times instead (#281): each leg's longest frame
## in real milliseconds, which is what the first entry into a room costs.
## Door 0 is the Main Hall's stone portal into the dark medieval room; the rest follow _plan.
extends SceneTree

const SIZE := Vector2i(960, 640)
const RUN_UP := 2.2  # metres walked on each side of the wall

var walk
var out := "res://build/room-change"
var pictures := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var only := []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out-dir="):
			out = arg.get_slice("=", 1)
		if arg == "--no-pictures":
			pictures = false
		if arg.begins_with("--doors="):
			only = Array(arg.get_slice("=", 1).split(","))
	root.size = SIZE
	walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	for i in 240:
		await process_frame
	walk._new_action()
	var doors := [[Vector3(0, 0, -RUN_UP), Vector3(0, 0, RUN_UP)]]
	for room in walk._plan:
		var b: Array = room.b
		for side in ["north", "west"]:  # each shared wall once
			if not room.openings.has(side):
				continue
			var door: Array = room.openings[side]
			var mid: float = (door[0] + door[1]) / 2.0
			var on_wall := Vector3(b[0] if side == "west" else mid, 0, b[2] if side == "north" else mid)
			var outward: Vector3 = walk.SIDES[side]
			# As far back on each side as the visitor can stand, straight through the door.
			var ends := []
			for way in [-1.0, 1.0]:
				var end: Vector3 = on_wall + outward * way * 0.9
				for depth in [RUN_UP, 1.8, 1.4, 1.1, 0.9]:
					if walk._free(on_wall + outward * way * depth):
						end = on_wall + outward * way * depth
						break
				ends.append(end)
			doors.append(ends)
	for index in doors.size():
		if not only.is_empty() and str(index) not in only:
			continue
		await _leg("%02d-a" % index, doors[index][0], doors[index][1])
		await _leg("%02d-b" % index, doors[index][1], doors[index][0])
	quit()


func _leg(name: String, from: Vector3, to: Vector3) -> void:
	var dir: String = out.path_join(name)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	walk._new_action()
	walk._target = null
	walk._held.clear()
	walk._velocity = Vector3.ZERO
	walk._pos = from
	walk._last_pos = from
	walk._space = "gallery" if from.z <= 0.0 and from.z >= -walk.L and absf(from.x) <= 5.0 else "arch"
	var at: int = walk._room_at(from)
	if at >= 0:
		walk._space = "far" if walk._plan[at].far else "arch"
	walk.view_mode = 0
	walk.view_yaw = 0.0
	walk._yaw = 0.0
	walk._kid.position = from
	walk._kid.reset_contacts()
	walk._update_camera(1.0)
	for settle in 30:
		await process_frame
	var frame := 0
	var log := FileAccess.open(dir.path_join("log.csv"), FileAccess.WRITE)
	log.store_line("frame,x,z,space,room")
	var rest := 0
	var longest := 0
	var slow := 0
	var tick := Time.get_ticks_msec()
	var from_stage: int = walk._stage
	while frame < 60 * 9 and rest < 48:
		var left: Vector3 = to - walk._pos
		var held := {}
		if left.length() > 0.25 and rest == 0:
			if absf(left.z) > 0.12:
				held["up" if left.z < 0 else "down"] = 1.0
			if absf(left.x) > 0.12:
				held["right" if left.x > 0 else "left"] = 1.0
		else:
			rest += 1
		walk._held = held
		await process_frame
		var now := Time.get_ticks_msec()
		longest = maxi(longest, now - tick)
		slow += int(now - tick > 50)
		tick = now
		if pictures and frame % 6 == 0:
			await RenderingServer.frame_post_draw
			var image: Image = root.get_texture().get_image()
			image.resize(480, 320, Image.INTERPOLATE_BILINEAR)
			image.save_jpg(dir.path_join("%03d.jpg" % (frame / 6)), 0.82)
		log.store_line(
			"%d,%.3f,%.3f,%s,%d"
			% [frame, walk._pos.x, walk._pos.z, walk._space, walk._room_at(walk._pos)]
		)
		frame += 1
	walk._held = {}
	print(
		"ROOM_CHANGE_LEG ", name, " frames=", frame, " ended=", walk._pos, " stage ", from_stage,
		" -> ", walk._stage, " longest_frame_ms=", longest, " frames_over_50ms=", slow
	)
