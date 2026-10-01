extends SceneTree
## Round-4 reviewer sweep of the descent velocity cap: does the root park on the floor without contact (flight pose
## regresses, impact lost)? Stand jumps steered at varied times/directions/start points; gait jumps with turns.
## Writes /tmp/root5-cap/cap.json. Run with --fixed-fps 60.
var demo: Node3D
var rows := []
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/root5-cap/");create_timer(2400).timeout.connect(func():quit(2));call_deferred("run")
func release_all() -> void:
	for a in ["down","up","left","right","sprint","slow"]:Input.action_release(a)
func run() -> void:
	demo=load("res://demo.gd").new();root.add_child(demo);demo.set_physics_process(false)
	await process_frame
	var dirs := [["down"],["up"],["left"],["right"],["down","left"],["down","right"],["up","left"],["up","right"]]
	for start in [Vector3(0,0,0),Vector3(.37,0,.11),Vector3(-.53,0,.29),Vector3(.21,0,-.47)]:
		for d in dirs:
			for when in ["apex","apex+6","pre5","none_slow"]:
				one("stand",start,"",d,when)
	for g in ["walk","run","dash"]:
		for lead in [30,33,36,39,42,45]:
			for d in [["right"],["left"],["up"],[]]:
				one(g,Vector3.ZERO,g,d,"apex" if d.size()>0 else "none",lead)
	FileAccess.open("/tmp/root5-cap/cap.json",FileAccess.WRITE).store_string(JSON.stringify(rows))
	var bad := rows.filter(func(r):return r.cap_nocontact>0)
	print("ROOT5CAP DONE runs=",rows.size()," cap_without_contact_runs=",bad.size())
	quit()
func one(kind: String, start: Vector3, gait: String, d: Array, when: String, lead:=40) -> void:
	release_all();demo.reset();demo.tool="None";demo.body.position=start
	for t in 30:demo._physics_process(1.0/60)
	if gait!="":
		if gait=="walk":Input.action_press("slow")
		if gait=="dash":Input.action_press("sprint")
		Input.action_press("down")
		for t in lead:demo._physics_process(1.0/60)
	if when=="none_slow":Input.action_press("slow");Input.action_press(d[0])
	demo.jump()
	var apex := -1;var prev_vy := 0.0;var prev_t := -1.0;var prev_clip := "";var capnc := 0;var back := 0;var back_size := 0.0;var land := -1;var impact := -1.0;var gain := -1.0;var air_hand_steps := [];var air_pose_steps := [];var contact_hand_step := 0.0;var contact_pose_step := 0.0;var air_at_floor := 0;var contact_y := INF;var contact_vy := INF
	var air := 0
	for t in 120:
		if apex<0 and demo.jump_launched and demo.body.velocity.y<=0:apex=t
		if when=="apex" and t==apex:
			if gait!="":Input.action_release("down")
			for a in d:Input.action_press(a)
		if when=="apex+6" and apex>=0 and t==apex+6:
			for a in d:Input.action_press(a)
		if when=="pre5" and apex>=0 and t==apex+16:
			for a in d:Input.action_press(a)
		var pose_before := pose_hand_positions()
		var hands_before := hand_positions()
		var landed_before: bool=demo.jump_landed
		demo._physics_process(1.0/60)
		var pose_now := pose_hand_positions()
		var pose_step: float=maxf(pose_now[0].distance_to(pose_before[0]),pose_now[1].distance_to(pose_before[1]))
		var hands_now := hand_positions()
		var hand_step: float=maxf(hands_now[0].distance_to(hands_before[0]),hands_now[1].distance_to(hands_before[1]))
		if demo.jump_launched and not demo.jump_landed:
			air_pose_steps.append(pose_step)
			if demo.body.position.y<=.003:air_at_floor+=1
			air_hand_steps.append(hand_step)
			air+=1
			if prev_vy<0 and demo.body.velocity.y>prev_vy+1e-6:capnc+=1
			if prev_clip=="flight" and demo.player.current_animation=="flight" and demo.player.current_animation_position<prev_t-1e-6:back+=1;back_size=maxf(back_size,prev_t-demo.player.current_animation_position)
		if demo.jump_landed and not landed_before:
			land=t;impact=demo.jump_impact;contact_hand_step=hand_step;contact_pose_step=pose_step;contact_y=demo.body.position.y;contact_vy=demo.body.velocity.y
			if demo.audio_history.size()>0 and demo.audio_history[-1].get("bank")=="Landing":gain=demo.audio_history[-1].get("gain",-1)
		prev_vy=demo.body.velocity.y;prev_t=demo.player.current_animation_position;prev_clip=demo.player.current_animation
		if land>=0 and t>land+3:break
	rows.append({"kind":kind,"start":[start.x,start.z],"gait":gait,"dir":d,"when":when,"lead":lead,"apex":apex,"land":land,"air":air,"impact":impact,"gain":gain,"cap_nocontact":capnc,"flight_back":back,"flight_back_size":back_size,"last_three_air_hand_step":air_hand_steps.slice(maxi(0,air_hand_steps.size()-3)).max(),"contact_hand_step":contact_hand_step,"last_three_air_pose_step":air_pose_steps.slice(maxi(0,air_pose_steps.size()-3)).max(),"contact_pose_step":contact_pose_step,"air_at_floor":air_at_floor,"contact_y":contact_y,"contact_vy":contact_vy})
	release_all()

func hand_positions() -> Array:
	var points := []
	for side in ["Left","Right"]:
		points.append((demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone(side+"Hand"))).origin-demo.body.position)
	return points

func pose_hand_positions() -> Array:
	# Remove intentional whole-actor steering; retain root correction and animated pose in metres.
	var points := []
	for point in hand_positions():points.append(demo.model.global_basis.orthonormalized().inverse()*point)
	return points
