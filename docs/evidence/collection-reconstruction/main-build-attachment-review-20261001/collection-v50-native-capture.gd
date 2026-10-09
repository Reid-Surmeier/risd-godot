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
	for row in [["hall",Vector3(1.45,0,-13),"gallery"],["medieval",Vector3(0,0,3.0),"arch"],["modern-old-layout",Vector3(12.4,0,1.7),"arch"],["grey",Vector3(0,0,-30.1),"far"]]:
		walk._space=row[2]
		walk._pos=row[1]
		walk._kid.position=row[1]
		walk._set_lighting(true)
		walk._update_camera(1.0)
		for i in 6:await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(row[0]+"-fullapp.png"))==OK)
		assert(walk._vp.get_texture().get_image().save_png(output.path_join(row[0]+"-collection.png"))==OK)
		proof.append({"name":row[0],"space":walk._space,"position":[walk._pos.x,walk._pos.y,walk._pos.z],"cull_mask":walk._cam.cull_mask,"state":walk.state()})
	FileAccess.open(output.path_join("native-views.json"),FileAccess.WRITE).store_string(JSON.stringify(proof,"\t")+"\n")
	print("FULLAPP_NATIVE_CAPTURE_OK: actual Collection factory and main-build controls; preview only")
	quit()
