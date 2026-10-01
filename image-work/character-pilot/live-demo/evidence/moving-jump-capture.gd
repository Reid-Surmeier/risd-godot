extends SceneTree
## Review-only capture; run against the immutable candidate's native project.
## godot --fixed-fps 60 --path <project> --script <this-file> -- --out=<temp-folder>
func _initialize():call_deferred("run")
func run():
 var out := "/tmp/character-moving-jump"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
 DirAccess.make_dir_recursive_absolute(out)
 root.size=Vector2i(960,720)
 var d=load("res://demo.gd").new();root.add_child(d);d.set_physics_process(false)
 await process_frame
 var trace := [];var frame := 0
 for tool in ["None","Axe","Net"]:
  for view in ["game","side"]:
   # Hide only tree canopies in the inspection camera; retain actual rig/physics.
   for child in d.get_children():
    if child is MeshInstance3D and child.mesh is SphereMesh:child.visible=view=="game"
   d.reset();d.tool=tool;Input.action_press("down")
   for tick in 40:d._physics_process(1.0/60)
   d.jump()
   for i in 60:
    for tick in 2:d._physics_process(1.0/60)
    if view=="side":
     var focus: Vector3=d.body.position+Vector3.UP*1.1
     focus.y=1.1
     d.camera.position=focus+Vector3(10,.6,0);d.camera.look_at(focus)
    await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/frame-%03d.png"%frame)
    trace.append({"frame":frame,"tool":tool,"view":view,"stage":d.jump_stage,"body":[d.body.position.x,d.body.position.y,d.body.position.z],"state":d.state})
    frame+=1
   Input.action_release("down")
 FileAccess.open(out+"/trace.json",FileAccess.WRITE).store_string(JSON.stringify({"fps":30,"engine_fixed_fps":60,"whole_viewport":true,"frames":trace},"  "))
 print("PASS captured normal-speed moving jumps, all tools, game and side views")
 quit()
