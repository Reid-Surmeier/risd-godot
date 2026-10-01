extends SceneTree
func _initialize():call_deferred("run")
func run():
 var out := "/tmp/pose-capture";var label := "candidate"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
  if arg.begins_with("--label="):label=arg.trim_prefix("--label=")
 DirAccess.make_dir_recursive_absolute(out);root.size=Vector2i(960,720)
 var d=load("res://demo.gd").new();root.add_child(d);d.set_physics_process(false)
 await process_frame
 for layer in d.find_children("*","CanvasLayer",true,false):layer.visible=false
 var hud := CanvasLayer.new();root.add_child(hud)
 var title := Label.new();title.position=Vector2(12,12);title.add_theme_font_size_override("font_size",24);hud.add_child(title)
 var lines := []
 for side in ["Left","Right"]:
  var line := Line2D.new();line.width=2;line.default_color=Color.CYAN if side=="Left" else Color.YELLOW;hud.add_child(line);lines.append(line)
 var trace := [];var frame := 0
 for scenario in ["standing","running","axe","platform","dash","steer","net","lower"]:
  for view in ["game","gamezoom","side","front"]:
   for child in d.get_children():
    if child is MeshInstance3D and child.mesh is SphereMesh:child.visible=view=="game"
    if child is StaticBody3D and child.get_child(0) is MeshInstance3D and child.get_child(0).mesh is BoxMesh and child.get_child(0).mesh.size==Vector3(.5,1,.5):child.get_child(0).visible=view=="game"
   d.reset();d.tool="Axe" if scenario=="axe" else ("Net" if scenario=="net" else "None")
   Input.action_release("down");Input.action_release("sprint")
   if scenario=="dash":Input.action_press("sprint")
   if scenario in ["running","platform","dash","lower"]:Input.action_press("down")
   var platform: Node3D
   if scenario=="platform":platform=d.block(Vector3(0,.225,2.5),Vector3(3,.45,1.8),Color("8a8a8a"),true)
   if scenario=="lower":
    platform=d.block(Vector3(0,.225,0),Vector3(3,.45,3),Color("8a8a8a"),true);d.body.position=Vector3(0,.47,0)
   for tick in (20 if scenario=="platform" else (8 if scenario=="lower" else 40)):d._physics_process(1.0/60)
   d.jump()
   for i in 60:
    for tick in 2:
     if scenario=="steer" and d.jump_launched and d.body.velocity.y<=0:Input.action_press("down")
     d._physics_process(1.0/60)
    var b: Vector3=d.body.position;var floor_center := Vector3(b.x,0,b.z)
    var offsets := {"game":Vector3(0,sin(PI/4),cos(PI/4))*22,"gamezoom":Vector3(0,sin(PI/4),cos(PI/4))*9,"side":Vector3(9,1.3,.2),"front":Vector3(0,1.3,9)}
    d.camera.position=floor_center+offsets[view];d.camera.look_at(floor_center+Vector3.UP*(.85 if view=="game" else 1.1))
    title.text=label+" · "+scenario+" · "+view+" · "+str(d.get("jump_stage"))
    for side_index in 2:
     var side: String=["Left","Right"][side_index];lines[side_index].clear_points()
     for part in ["UpLeg","Leg","Foot"]:
      var p: Vector3=d.skeleton.global_transform*d.skeleton.get_bone_global_pose(d.skeleton.find_bone(side+part)).origin
      lines[side_index].add_point(d.camera.unproject_position(p))
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/frame-%04d.png"%frame)
    trace.append({"frame":frame,"scenario":scenario,"view":view,"stage":d.get("jump_stage"),"body":[b.x,b.y,b.z],"state":d.state})
    frame+=1
   if platform:platform.free()
   Input.action_release("down")
 FileAccess.open(out+"/trace.json",FileAccess.WRITE).store_string(JSON.stringify({"fps":30,"engine_fixed_fps":60,"inspection_hides_tree_canopies_and_trunk_meshes_only":true,"whole_viewport":true,"frames":trace},"  "))
 print("PASS pose comparison capture ",label," frames ",frame);quit()
