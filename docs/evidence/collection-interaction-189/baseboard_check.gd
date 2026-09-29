extends SceneTree
func _initialize():
 call_deferred("run")
func run():
 root.size=Vector2i(720,480)
 var scene=load("res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn").instantiate()
 root.add_child(scene)
 var label="after" if "--after" in OS.get_cmdline_user_args() else "before"
 var minimum=1.0
 for side in [-1,1]:
  scene.camera.position=Vector3(side*2.5,0.7,-10)
  scene.camera.look_at(Vector3(side*4.88,0.14,-12))
  for frame in 8:await process_frame
  var shot=root.get_texture().get_image()
  var p: Vector2=scene.camera.unproject_position(Vector3(side*4.88,0.12,-12))
  var value=shot.get_pixelv(Vector2i(p)).get_luminance()
  minimum=minf(minimum,value)
  print("BASEBOARD side=",side," luminance=",value)
  shot.save_png("res://docs/evidence/collection-interaction-189/baseboard-%s-%s.png" % [label,side])
 print("BASEBOARD ","PASS" if minimum>0.5 else "FAIL")
 quit(0 if minimum>0.5 else 1)
