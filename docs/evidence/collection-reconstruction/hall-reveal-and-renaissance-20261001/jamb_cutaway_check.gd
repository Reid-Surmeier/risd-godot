extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var output:String=OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1440,1000)
	var app=load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150:await process_frame
	var walk=app.find_child("GalleryWalk",true,false)
	assert(walk!=null and walk.state().attached,"Real Collection factory must mount room adapter")
	walk.set_process(false)
	walk._entrance_active=false
	walk._target=null
	walk._target_yaw=null
	walk._path.clear()
	var proof:=[]
	for row in [
 ["hall-jamb-west",Vector3(0,0,-26.4),"far",0,PI/2],
 ["hall-jamb-east",Vector3(0,0,-26.4),"far",0,-PI/2],
 ["hall-door-front",Vector3(0,0,-29.96),"far",0,PI],
 ["rockefeller-jamb-west",Vector3(-8.05,0,-26.4),"far",0,PI/2],
 ["rockefeller-jamb-east",Vector3(-8.05,0,-26.4),"far",0,-PI/2],
 ["rockefeller-door-front",Vector3(-8.05,0,-29.96),"far",0,PI]
]:
		walk._space=row[2]
		walk.view_mode=row[3]
		walk.view_yaw=row[4]
		walk._pos=row[1]
		walk._kid.position=row[1]
		walk._set_lighting(true)
		walk._update_camera(1.0)
		for i in 6:await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(row[0]+"-fullapp.png"))==OK)
		assert(walk._vp.get_texture().get_image().save_png(output.path_join(row[0]+"-collection.png"))==OK)
		var jamb_hits := []
		var header_sections := 0
		for wall in walk._walls:
			if not str(wall.body.get_meta("room_wall","")).ends_with(":header"):continue
			for part in wall.body.get_children():
				if not part is MeshInstance3D or part.mesh==null:continue
				var box:AABB=part.global_transform*part.get_aabb()
				if wall.has("boxes"):assert(box in wall.boxes,"Header child absent from camera ray boxes")
				header_sections+=1
				var hit:bool=box.intersects_segment(walk._cam.global_position,walk._pos+Vector3(0,1.0,0))!=null
				var old_hit:bool=(wall.box as AABB).intersects_segment(walk._cam.global_position,walk._pos+Vector3(0,1.0,0))!=null
				if hit and not old_hit:
					jamb_hits.append({"wall":str(wall.body.get_meta("room_wall","")),"still_drawn":part.visible})
		proof.append({"name":row[0],"space":walk._space,"position":[walk._pos.x,walk._pos.y,walk._pos.z],"cull_mask":walk._cam.cull_mask,"state":walk.state(),"jamb_hits":jamb_hits,"header_sections":header_sections})
	FileAccess.open(output.path_join("native-views.json"),FileAccess.WRITE).store_string(JSON.stringify(proof,"\t")+"\n")
	var hits := 0
	var drawn := 0
	for view in proof:
		for hit in view.jamb_hits:
			hits+=1
			if hit.still_drawn:drawn+=1
	if hits==0 or drawn!=0:
		print("JAMB_CUTAWAY_FAILED ",JSON.stringify({"actual_jamb_hits":hits,"still_drawn":drawn}))
		quit(1)
		return
	print("FULLAPP_NATIVE_CAPTURE_OK: actual Collection factory and main-build controls; preview only")
	quit()
