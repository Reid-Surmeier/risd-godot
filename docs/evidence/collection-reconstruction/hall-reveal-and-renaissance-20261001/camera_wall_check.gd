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
 ["grey-near-south-facing-north",Vector3(2,0,-28),"far",2,0.0],
 ["grey-near-south-west-facing-north",Vector3(-1,0,-28),"far",2,0.0],
 ["grey-door-facing-north",Vector3(0,0,-28),"far",2,0.0],
 ["renaissance-west-facing-east",Vector3(-10.25,0,1.7),"arch",2,-PI/2],
 ["renaissance-north-facing-south",Vector3(-10.05,0,1.3),"arch",2,PI],
 ["grey-interior-facing-north",Vector3(2,0,-31.5),"far",2,0.0]
]:
		walk._space=row[2]
		walk.view_mode=row[3]
		walk.view_yaw=row[4]
		walk._yaw=row[4]
		walk._view_turn_remaining=0.0
		walk._pos=row[1]
		walk._kid.position=row[1]
		walk._set_lighting(true)
		walk._update_camera(1.0)
		for i in 6:await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(row[0]+"-fullapp.png"))==OK)
		assert(walk._vp.get_texture().get_image().save_png(output.path_join(row[0]+"-collection.png"))==OK)
		var walls_between := []
		var head:Vector3=walk._pos+Vector3(0,1.3,0)
		for wall in walk._walls:
			if not wall.body.has_meta("room_wall"):continue
			for section in wall.boxes:
				if (section as AABB).intersects_segment(head,walk._cam.global_position)!=null:
					walls_between.append(str(wall.body.get_meta("room_wall")))
		proof.append({"name":row[0],"space":walk._space,"position":[walk._pos.x,walk._pos.y,walk._pos.z],"cull_mask":walk._cam.cull_mask,"state":walk.state(),"camera":[walk._cam.global_position.x,walk._cam.global_position.y,walk._cam.global_position.z],"opaque_walls_between_visitor_and_camera":walls_between})
	FileAccess.open(output.path_join("native-views.json"),FileAccess.WRITE).store_string(JSON.stringify(proof,"\t")+"\n")
	var failures:=[]
	for view in proof:
		if not view.opaque_walls_between_visitor_and_camera.is_empty():failures.append(view.name)
	print("CAMERA_WALL_CHECK ",JSON.stringify({"tests":proof.size(),"failures":failures}))
	if not failures.is_empty():
		quit(1)
		return
	print("FULLAPP_NATIVE_CAPTURE_OK: actual Collection factory and main-build controls; preview only")
	quit()
