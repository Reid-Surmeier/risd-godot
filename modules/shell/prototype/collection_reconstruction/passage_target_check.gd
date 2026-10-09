## Short key taps and floor-walk targets across both connected Hall doors.
extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var output:String=OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1440,1000)
	var app=load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150:await process_frame
	var walk=app.find_child("GalleryWalk",true,false)
	assert(walk!=null and walk.state().attached)
	walk.set_process(false)
	var rows:=[]
	var failures:=[]
	for kind in ["tap","floor-target"]:
		for test in [["grey-hall-near",0.0,-26.38,"far","gallery",1.0],["grey-hall-edge",0.0,-26.74,"far","gallery",1.0],["grey-hall-deep",0.0,-28.3,"far","gallery",1.0],["hall-grey",0.0,-25.0,"gallery","far",-1.0],["rockefeller-west",-8.05,-28.3,"far","arch",1.0],["west-rockefeller",-8.05,-25.0,"arch","far",-1.0]]:
			walk._entrance_waiting=false
			walk._entrance_active=false
			walk._held.clear()
			walk._velocity=Vector3.ZERO
			walk._target=null
			walk._target_yaw=null
			walk._path.clear()
			walk._stall_t=0.0
			walk._space=test[3]
			walk._pos=Vector3(test[1],0,test[2])
			walk._last_pos=walk._pos
			walk._kid.position=walk._pos
			walk.view_mode=2
			walk._yaw=PI if test[5]>0 else 0.0
			walk._view_turn_remaining=0.0
			walk._portal_flash.modulate.a=0.0
			walk._update_camera(1.0)
			var step:=0.0
			var swaps:=0
			var delivered:=true
			var released:=true
			var before:Vector3=walk._pos
			var space:String=walk._space
			for attempt in 6 if kind=="tap" else 1:
				if kind=="tap":
					key(true)
					await process_frame
					delivered=delivered and walk._held.has("up")
					walk._process(1.0/30.0)
					step=maxf(step,walk._pos.distance_to(before));before=walk._pos
					swaps+=int(space!=walk._space);space=walk._space
					key(false)
					await process_frame
					released=released and walk._held.is_empty()
				else:
					# The floor click handler passes this ray intersection to the native planner.
					walk._walk_to(Vector3(test[1],0,-24.5 if test[5]>0 else -29.1))
				for frame in 160:
					walk._process(1.0/30.0)
					step=maxf(step,walk._pos.distance_to(before));before=walk._pos
					swaps+=int(space!=walk._space);space=walk._space
					if walk._target==null and walk._path.is_empty():break
				if walk._space==test[4] and test[5]*(walk._pos.z+walk.L)>.65:break
			var passed:bool=walk._space==test[4] and test[5]*(walk._pos.z+walk.L)>.65 and step<=.08 and swaps==1 and delivered and released
			var name:String=kind+"-"+test[0]
			rows.append({"name":name,"passed":passed,"space":walk._space,"position":[walk._pos.x,walk._pos.z],"max_step_m":step,"space_changes":swaps,"key_delivered":delivered,"key_released":released,"input": "real root key events" if kind=="tap" else "floor-click target planner"})
			if not passed:failures.append(name)
			await RenderingServer.frame_post_draw
			assert(walk._vp.get_texture().get_image().save_png(output.path_join(name+".png"))==OK)
	FileAccess.open(output.path_join("target-check.json"),FileAccess.WRITE).store_string(JSON.stringify({"rows":rows,"failures":failures},"\t")+"\n")
	print("PASSAGE_TARGET_CHECK ",JSON.stringify({"tests":rows.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
func key(pressed:bool) -> void:
	var event:=InputEventKey.new()
	event.keycode=KEY_UP;event.physical_keycode=KEY_UP;event.pressed=pressed
	Input.parse_input_event(event)
