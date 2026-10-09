extends SceneTree
func _initialize():call_deferred("run")
func run():
 var out := "/tmp/idle-rocking-proof";DirAccess.make_dir_recursive_absolute(out);root.size=Vector2i(960,720)
 var d=load("res://demo.gd").new();root.add_child(d);d.set_physics_process(false);await process_frame
 for layer in d.find_children("*","CanvasLayer",true,false):layer.visible=false
 var quieter: Animation=d.player.get_animation("idle").duplicate()
 var source: Node3D=load("res://walk.glb").instantiate()
 var original: Animation=source.find_children("*","AnimationPlayer",true,false)[0].get_animation("idle").duplicate();source.free()
 var hud:=CanvasLayer.new();root.add_child(hud);var title:=Label.new();title.position=Vector2(12,12);title.add_theme_font_size_override("font_size",24);hud.add_child(title)
 var frames := [];var idx := 0
 for version in ["before","after"]:
  d.player.stop();d.player.get_animation_library("").add_animation("idle",original if version=="before" else quieter)
  for view in ["gamezoom","side","front"]:
   d.reset();d.tool="None";d.player.seek(0,true)
   for tick in 30:d._physics_process(1.0/60)
   for frame in 60:
    for tick in 2:d._physics_process(1.0/60)
    d.face_material.set_shader_parameter("blink",0)
    var offsets := {"gamezoom":Vector3(0,sin(PI/4),cos(PI/4))*9,"side":Vector3(9,1.3,0),"front":Vector3(0,1.3,9)}
    d.camera.position=offsets[view];d.camera.look_at(Vector3.UP*1.1)
    title.text=("Before: source idle" if version=="before" else "After: half idle movement")+" / "+view
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/"+version+"-%03d.png"%frame if false else out+"/frame-%04d.png"%idx)
    frames.append({"frame":idx,"version":version,"view":view,"head_y":d.skeleton.get_bone_global_pose(d.skeleton.find_bone("Head")).origin.y*.01,"hip_y":d.skeleton.get_bone_global_pose(d.skeleton.find_bone("Hips")).origin.y*.01});idx+=1
 FileAccess.open(out+"/trace.json",FileAccess.WRITE).store_string(JSON.stringify(frames));print("PASS idle before/after ",idx);quit()
