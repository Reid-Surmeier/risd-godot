## Real Collection key delivery: follow-mode and diagonal passage regressions (Opus F4/F5).
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
	var tests:Array=[]
	for backward in [false,true]:
		for row in [["grey-hall",0.0,-1.25,"far","gallery",1.0],["hall-grey",0.0,1.25,"gallery","far",-1.0],["rockefeller-west",-8.05,-1.25,"far","arch",1.0],["west-rockefeller",-8.05,1.25,"arch","far",-1.0]]:
			var yaw:float=PI if row[5]>0 else 0.0
			tests.append({"name":row[0]+("-backward" if backward else "-forward"),"at":Vector3(row[1],0,-walk.L+row[2]),"space":row[3],"next":row[4],"sign":row[5],"keys":[KEY_DOWN if backward else KEY_UP],"mode":2,"yaw":yaw+(PI if backward else 0.0),"reach":.7})
	for mode in [0,1]:
		for side in [-1,1]:
			for sign in [-1,1]:
				tests.append({"name":"diagonal-%s-%s-%s"%[mode,side,sign],"at":Vector3(side*.35,0,-walk.L-sign*.18),"space":"far" if sign>0 else "gallery","next":"gallery" if sign>0 else "far","sign":sign,"keys":[KEY_DOWN if sign>0 else KEY_UP,KEY_RIGHT if side>0 else KEY_LEFT],"mode":mode,"yaw":0.0,"reach":.65})
	var rows:Array=[]
	var failures:Array=[]
	for test in tests:
		walk._entrance_waiting=false
		walk._entrance_active=false
		walk._target=null
		walk._target_yaw=null
		walk._path.clear()
		walk._velocity=Vector3.ZERO
		walk._held.clear()
		walk._space=test.space
		walk._pos=test.at
		walk._last_pos=walk._pos
		walk._kid.position=walk._pos
		walk.view_mode=test.mode
		walk._yaw=test.yaw
		walk.view_yaw=0.0
		walk._view_turn_remaining=0.0
		walk._portal_flash.modulate.a=0.0
		walk._update_camera(1.0)
		for key in test.keys:send_key(key,true)
		await process_frame
		var delivered:bool=walk._held.size()==test.keys.size()
		var step:=0.0
		var changes:=0
		var flash:=0.0
		var reached:=false
		for i in 300:
			var before:Vector3=walk._pos
			var space:String=walk._space
			walk._process(1.0/30.0)
			step=maxf(step,walk._pos.distance_to(before))
			changes+=int(space!=walk._space)
			flash=maxf(flash,walk._portal_flash.modulate.a)
			if test.sign*(walk._pos.z+walk.L)>=test.reach and walk._space==test.next:
				reached=true
				break
		for key in test.keys:send_key(key,false)
		await process_frame
		var released:bool=walk._held.is_empty()
		var passed:bool=delivered and released and reached and step<=.08 and changes==1 and flash==0.0
		rows.append({"test":test.name,"mode":test.mode,"key_delivered":delivered,"key_released":released,"reached":reached,"max_step_m":step,"space_changes":changes,"flash":flash,"position":[walk._pos.x,walk._pos.z],"passed":passed})
		if not passed:failures.append(test.name)
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(test.name+".png"))==OK)
	FileAccess.open(output.path_join("passage-keys.json"),FileAccess.WRITE).store_string(JSON.stringify({"rows":rows,"failures":failures},"\t")+"\n")
	print("PASSAGE_KEYBOARD_CHECK ",JSON.stringify({"tests":rows.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
func send_key(key:int,pressed:bool) -> void:
	var event:=InputEventKey.new()
	event.keycode=key
	event.physical_keycode=key
	event.pressed=pressed
	Input.parse_input_event(event)
