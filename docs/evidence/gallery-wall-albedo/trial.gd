## Isolated still comparison: preserve bake, lift only textured gallery-wall albedo.
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
 walk._target=null
 walk._path.clear()
 walk._held.clear()
 walk._view_turn_remaining=0
 walk.view_mode=0
 var walls=[]
 for mesh in walk._baked_room.get_children():
  if not mesh is MeshInstance3D: continue
  var material=mesh.material_override
  if material is StandardMaterial3D and material.albedo_texture and material.albedo_texture.resource_path.ends_with("/textures/wall-muse.webp"):
   mesh.material_override=material.duplicate()
   walls.append(mesh)
 var out="/tmp/gallery-wall-albedo"
 DirAccess.make_dir_recursive_absolute(out)
 var poses={"corner":[Vector3(-4.45,0,-2.56),2.65],"warm":[Vector3(2,0,-4),PI],"art":[Vector3(-3.3,0,-12),PI/2.0],"white":[Vector3(0,0,-3),PI]}
 for label in ["control","lift"]:
  for mesh in walls: mesh.material_override.albedo_color=Color.WHITE if label=="control" else Color(1.12,1.12,1.12)
  for scene in poses:
   walk._enter_space("arch" if scene=="white" else "gallery")
   walk._portal_flash.modulate.a=0
   walk._pos=poses[scene][0]
   walk.view_yaw=poses[scene][1]
   walk._yaw=walk.view_yaw
   walk._motion_heading=Vector3.FORWARD
   walk._kid.reset_contacts()
   walk._kid.phase=0.12
   walk._kid._time=0.0
   walk._kid.gesture=""
   walk._kid.gesture_time=0.0
   walk._process(0.0)
   walk._update_camera(1)
   for i in 3: await process_frame
   root.get_texture().get_image().save_png(out+"/%s-%s-720.png"%[label,scene])
   print("WALL_ALBEDO ",label," scene=",scene," camera=",walk._cam.global_transform," walls=",walls.size()," live_lights=",walk._vp.find_children("*","Light3D",true,false).size())
 quit()
