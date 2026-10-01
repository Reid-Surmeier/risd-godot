extends SceneTree
func _initialize():call_deferred("run")
func run():
 var demo=load("res://demo.gd").new();root.add_child(demo);demo.set_physics_process(false)
 await process_frame
 var runs := [];var worst := 0.0
 for delay in range(0,9):
  demo.reset();demo.tool="None"
  for action in ["down","up","left","right","slow","sprint"]:Input.action_release(action)
  for tick in 30:demo._physics_process(1.0/60)
  demo.jump()
  var land_tick := -1;var positions := [];var rows := [];var jerk := 0.0
  for tick in 100:
   if demo.jump_landed:land_tick+=1
   if land_tick==delay:Input.action_press("down")
   demo._physics_process(1.0/60)
   var head:Vector3=demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone("Head")).origin-demo.body.global_position
   positions.append(head)
   if land_tick>=0 and land_tick<=18 and positions.size()>=3:
    var acceleration:Vector3=positions[-1]-2*positions[-2]+positions[-3]
    jerk=maxf(jerk,absf(acceleration.y))
   rows.append({"tick":tick,"land_tick":land_tick,"state":demo.state,"head_y":head.y,"root_y":demo.model.position.y,"drop":demo.last_landing_drop,"carried":demo.landing_carried_drop,"age":demo.landing_carried_age})
  worst=maxf(worst,jerk);runs.append({"delay":delay,"vertical_head_acceleration":jerk,"rows":rows})
  Input.action_release("down")
 var out:="/tmp/character-land-followup/baseline.json"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
 FileAccess.open(out,FileAccess.WRITE).store_string(JSON.stringify({"worst_vertical_head_acceleration":worst,"runs":runs},"  "))
 print("LANDING JERK ",worst)
 if worst>.033:push_error("Post-contact movement jerks head vertically: "+str(worst))
 quit(0 if worst<=.033 else 1)
