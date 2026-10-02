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
 ["medieval-tallcase",Vector3(3.2,0,2.9),"arch",0,PI],
 ["medieval-lowcase",Vector3(-.1,0,4.6),"arch",0,0.0],
 ["hall",Vector3(1.45,0,-13),"gallery",0,PI],
 ["medieval",Vector3(0,0,3.0),"arch",0,PI],
 ["modern-layout",Vector3(7.3,0,-1.35),"arch",0,PI],
 ["modern-case",Vector3(9.8,0,-3.25),"arch",0,PI],
 ["landing",Vector3(8.6,0,3.6),"arch",0,PI],
 ["grey",Vector3(0,0,-30.1),"far",0,PI],
 ["grey-columns-west",Vector3(3.0,0,-29.3),"far",1,-PI/2],
 ["connector-black",Vector3(-2.6,0,-27.8),"far",1,PI],
 ["grey-courbet",Vector3(0,0,-30.1),"far",1,PI/2],
 ["hall-grey-reciprocal",Vector3(0,0,-24.5),"gallery",1,0.0],
 ["hall-lower",Vector3(0,0,-6.5),"gallery",1,PI],
 ["grey-hall-doorway",Vector3(-.5,0,-29),"far",1,PI],
 ["grey-north-facing",Vector3(0,0,-30.1),"far",1,0.0],
 ["saint-roch-room",Vector3(-9.35,0,3.85),"arch",1,PI/2],
 ["saint-roch-overhead",Vector3(-9.35,0,3.85),"arch",0,PI/2],
 ["pieta-room",Vector3(-9.1,0,1.7),"arch",1,PI/2],
 ["triptych-room",Vector3(-10.05,0,1.4),"arch",1,0.0],
 ["renaissance-room",Vector3(-8.3,0,2.5),"arch",0,PI]
]:
		if row[2]=="far":row[1].z-=.76
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
		proof.append({"name":row[0],"space":walk._space,"position":[walk._pos.x,walk._pos.y,walk._pos.z],"cull_mask":walk._cam.cull_mask,"state":walk.state()})
	FileAccess.open(output.path_join("native-views.json"),FileAccess.WRITE).store_string(JSON.stringify(proof,"\t")+"\n")
	print("FULLAPP_NATIVE_CAPTURE_OK: actual Collection factory and main-build controls; preview only")
	quit()
