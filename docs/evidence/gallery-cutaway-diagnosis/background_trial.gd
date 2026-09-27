## Diagnostic only: one constant gallery background candidate; no shipping edits.
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
 walk._target=null
 walk._path.clear()
 walk._view_turn_remaining=0
 walk.view_mode=0
 var env=walk._vp.find_children("*","WorldEnvironment",true,false)[0].environment
 var out="/tmp/gallery-background-trial"
 DirAccess.make_dir_recursive_absolute(out)
 var poses={"corner":Vector3(-4.45,0,-2.56),"warm":Vector3(2,0,-4),"art":Vector3(-3.3,0,-12),"white":Vector3(0,0,-3)}
 var timings=[]
 for label in ["control","candidate"]:
  for scene in poses:
   walk._enter_space("arch" if scene=="white" else "gallery")
   walk._portal_flash.modulate.a=0
   walk._pos=poses[scene]
   walk._motion_heading=Vector3.FORWARD
   walk._kid.reset_contacts()
   walk._kid.phase=0.12
   walk._kid._time=0.0
   walk._kid.gesture=""
   walk._kid.gesture_time=0.0
   env.background_color=Color("#ece9e2") if scene=="white" else Color("#20242a" if label=="control" else "#343935")
   for i in 8:
    walk.view_yaw=i*PI/4.0
    walk._yaw=walk.view_yaw
    walk._process(0.0)
    walk._update_camera(1)
    await process_frame
    await process_frame
    root.get_texture().get_image().save_png(out+"/%s-%s-%s.png"%[label,scene,i])
   if scene=="corner":
    walk.view_yaw=2.65
    walk._yaw=walk.view_yaw
    walk._process(0.0)
    walk._update_camera(1)
    await process_frame
    await process_frame
    root.get_texture().get_image().save_png(out+"/%s-corner-exact.png"%label)
  print("BACKGROUND_TRIAL ",label," live_lights=",walk._vp.find_children("*","Light3D",true,false).size())
 quit()
