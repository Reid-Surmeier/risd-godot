extends SceneTree
func _initialize() -> void:
 call_deferred("_run")
func _run() -> void:
 root.size=Vector2i(720,486)
 var main=load("res://modules/shell/demo.tscn").instantiate()
 root.add_child(main)
 await create_timer(5).timeout
 var walk=main.find_child("GalleryWalk",true,false)
 walk.set_process(false)
 walk._entrance_waiting=false
 walk._entrance_active=false
 walk._held.clear()
 walk._pos=Vector3(-4.45,0,-2.56)
 walk._target=null
 walk._path.clear()
 walk._portal_flash.modulate.a=0
 walk._view_turn_remaining=0
 walk.view_mode=0
 walk.view_yaw=2.65
 walk._update_camera(1)
 for i in 3: await process_frame
 var out="/tmp/gallery-triangle-proof"
 DirAccess.make_dir_recursive_absolute(out)
 root.get_texture().get_image().save_png(out+"/control.png")
 var env=walk._vp.find_children("*","WorldEnvironment",true,false)[0].environment
 var previous=env.background_color
 env.background_color=Color.MAGENTA
 for i in 3: await process_frame
 root.get_texture().get_image().save_png(out+"/sentinel-background.png")
 env.background_color=previous
 print("TRIANGLE camera=",walk._cam.global_transform," cull=",walk._cam.cull_mask)
 for p in [Vector3(-5,6,0),Vector3(5,6,0),Vector3(-5,6,-26.3),Vector3(5,6,-26.3)]:
  print("WALL_TOP world=",p," screen=",walk._cam.unproject_position(p))
 for mi in walk._baked_room.get_children():
  if mi is MeshInstance3D and mi.layers & walk._cam.cull_mask:
   var aabb=mi.global_transform*mi.mesh.get_aabb()
   if aabb.size.y>5: print("VISIBLE_WALL ",mi.name," layer=",mi.layers," bounds=",aabb)
 quit()
