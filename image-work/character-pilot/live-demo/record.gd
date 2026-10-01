extends SceneTree
## Fixed engine timestep; whole viewport frames, no following crop or per-frame warp.
var demo: Node3D
var trace := []
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(960,720)
	demo=load("res://demo.gd").new();root.add_child(demo)
	demo.set_physics_process(false)
	await process_frame
	var walk_reference := "--walk-reference" in OS.get_cmdline_user_args()
	if walk_reference:
		demo.slow=true
		demo.calibration=2
		demo.movement.travel_gain=6.867/4.875
	Input.action_press("down")
	for frame in (60 if walk_reference else 240):
		if frame==60:Input.action_press("sprint")
		if frame==90:Input.action_release("down");Input.action_press("up")
		if frame==120:Input.action_release("up");Input.action_release("sprint");demo.reset();demo.cycle_tool()
		if frame==135:demo.cycle_tool()
		if frame==150:demo.reset();demo.body.position=Vector3(0,0,-6.5);demo.interact()
		for tick in 2:demo._physics_process(1.0/60)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://record-%03d.png"%frame)
		trace.append({"time":frame/30.0,"x":demo.body.position.x,"z":demo.body.position.z,"phase":demo.movement.phase,"state":demo.state,"lean":demo.movement.lean,"footsteps":demo.footprint_count,"effects":demo.emitted,"blink":demo.blink_index,"door":demo.interaction})
	FileAccess.open("res://record.json",FileAccess.WRITE).store_string(JSON.stringify({"fps":30,"engine_fixed_fps":60,"frames":trace,"whole_viewport":true,"camera_game_distance":22,"camera_angle":45,"fov":20,"no_frame_registration_warp":true,"reference_gait":"WALK partial input, speed x2.18" if walk_reference else "RUN normal input"},"  "))
	print("RECORDED whole-viewport run/dash/reversal/tool/iris sequence")
	quit()
