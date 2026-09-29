## #161 private replay regression for the selected rig.
extends SceneTree
func _initialize():
 call_deferred("run")
func run():
 var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
 walk.size = Vector2(720,720)
 root.add_child(walk)
 walk.set_process(false)
 var probe = load("res://modules/shell/prototype/gallery_walk4/render_diagnostics.gd").new()
 probe.view = walk
 var first = []
 var first_trace = []
 for repeat in 2:
  probe._pose("warm")
  var poses = []
  for bone in walk._kid.target.get_bone_count():
   poses.append(walk._kid.target.get_bone_pose(bone))
  if repeat == 0: first = poses
  else: assert(first == poses, "matched replay reset changed visitor pose")
  walk._held["right"] = 0.0
  var trace = []
  for frame in 120:
   walk._process(1.0/60.0)
   var tick_pose = []
   for bone in walk._kid.target.get_bone_count(): tick_pose.append(walk._kid.target.get_bone_pose(bone))
   trace.append([walk._pos,walk._kid.rotation.y,hash(tick_pose)])
  if repeat == 0: first_trace = trace
  else: assert(first_trace == trace, "matched replay movement pose changed")
 probe._pose("white")
 assert(walk._space == "far", "white fixture landed in gallery")
 print("DISPLAY_REPLAY Hair36 reset pose parity and white room PASS")
 probe.free()
 walk.free()
 call_deferred("quit")
