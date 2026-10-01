extends SceneTree
func _initialize():call_deferred("run")
func run():
	var out:String=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out)
	root.size=Vector2i(1440,1000)
	var app=load("res://modules/shell/demo.tscn").instantiate();root.add_child(app)
	for i in 150:await process_frame
	var walk=app.find_child("GalleryWalk",true,false);assert(walk!=null)
	walk.set_process(false);walk._entrance_active=false;walk._entrance_waiting=false;walk._target=null;walk._target_yaw=null;walk._path.clear()
	walk._space="gallery";walk._pos=Vector3(1.45,0,-13);walk._kid.position=walk._pos
	for row in [["east",0.0],["west",PI]]:
		walk.view_mode=0;walk.view_yaw=row[1];walk._view_turn_remaining=0.0;walk._set_lighting(true);walk._update_camera(1.0)
		for i in 5:await process_frame
		await RenderingServer.frame_post_draw
		walk._vp.get_texture().get_image().save_png(out.path_join("hall-"+row[0]+".png"))
	print("MAIN_HALL_BOTH_SIDES_CAPTURED");quit()
