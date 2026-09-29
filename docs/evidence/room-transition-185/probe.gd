extends SceneTree
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 root.size = Vector2i(1152, 766)
 var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
 walk.size = Vector2(1152, 766)
 root.add_child(walk)
 walk.set_process(false)
 walk._new_action()
 walk._entrance_active = false
 walk._entrance_waiting = false
 walk._target = null
 var rows: Array = []
 for yaw in [0.0, PI]:
  walk.view_yaw = yaw
  walk.view_mode = 0
  walk._space = "gallery"
  walk._pos = Vector3(0, 0, -0.02)
  walk._update_camera(1)
  var before: int = walk._cam.cull_mask
  for side in ["before", "after", "passage"]:
   if side != "before":
    walk._pos.z = 0.02 if side == "after" else 2.0
    walk._enter_space("arch")
   walk._update_camera(1)
   for frame in 8:
    await process_frame
   var label := "%s-%s" % ["toward" if yaw == PI else "back", side]
   root.get_texture().get_image().save_png("res://docs/evidence/room-transition-185/" + label + ".png")
   rows.append({"pose":label,"z":walk._pos.z,"space":walk._space,"mask":walk._cam.cull_mask,"camera":str(walk._cam.position),"fov":walk._cam.fov,"cover_alpha":walk._portal_flash.modulate.a})
  assert(before != int(rows[-2].mask), "probe no longer reproduces abrupt doorway mask switch")
  assert(rows[-2].cover_alpha == 0.0, "probe no longer reproduces uncovered switch")
 var file := FileAccess.open("res://docs/evidence/room-transition-185/states.json", FileAccess.WRITE)
 file.store_string(JSON.stringify(rows,"\t"))
 print("REPRODUCED: 4 cm crossing changes cutaway mask with zero transition cover in both directions")
 quit()
