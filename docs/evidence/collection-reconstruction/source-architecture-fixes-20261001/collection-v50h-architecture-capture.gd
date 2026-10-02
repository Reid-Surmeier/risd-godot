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
	for row in [["grey-columns-west",Vector3(3.0,0,-29.3),"far"],["connector-black",Vector3(-2.6,0,-27.8),"far"],["grey-courbet",Vector3(0,0,-30.1),"far"],["grey-doorway",Vector3(-4.0,0,-29.0),"far"],["hall",Vector3(0,0,-6.5),"gallery"]]:
		walk._space=row[2]
		walk.view_mode=1
		walk.view_yaw=-PI/2 if row[0]=="grey-columns-west" else PI/2 if row[0]=="grey-courbet" else -2.2 if row[0]=="grey-doorway" else PI
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
