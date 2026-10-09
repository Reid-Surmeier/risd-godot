extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(960,720)
 var out := "/tmp/character-land-followup/visual";DirAccess.make_dir_recursive_absolute(out)
 for variant in ["before","after"]:
  for view in ["game","side"]:
   var d=load("res://before.gd" if variant=="before" else "res://demo.gd").new();root.add_child(d);d.set_physics_process(false)
   await process_frame
   for layer in d.find_children("*","CanvasLayer",true,false):layer.visible=false
   if view=="side":
    for child in d.get_children():
     if child is MeshInstance3D and child.mesh is SphereMesh:child.visible=false
     if child is StaticBody3D and child.get_child(0) is MeshInstance3D and child.get_child(0).mesh is BoxMesh and child.get_child(0).mesh.size==Vector3(.5,1,.5):child.get_child(0).visible=false
   d.reset();d.tool="None";Input.action_release("down")
   for t in 30:d._physics_process(1.0/60)
   d.jump();var land_tick := -1
   for tick in 100:
    if d.jump_landed:land_tick+=1
    if land_tick==3:Input.action_press("down")
    d._physics_process(1.0/60)
    if view=="side":
     var target:Vector3=d.body.position+Vector3.UP*1.1
     d.camera.position=target+Vector3(8,0,0);d.camera.look_at(target)
    if tick%2==0:
     await process_frame;await RenderingServer.frame_post_draw
     root.get_texture().get_image().save_png(out+"/"+variant+"-"+view+"-%03d.png"%(tick/2))
   Input.action_release("down");d.free();await process_frame
 print("LANDING VISUAL DONE");quit()
