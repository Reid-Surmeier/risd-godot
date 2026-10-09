extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://remodel_room.tscn").instantiate();root.add_child(scene)
 var black:=0;var beams:=0;var pilasters:=0;var labels:=0;var leaves:=[];var unsupported_leaf:=false;var black_trim:=0;var purple_trim:=0
 for n in scene.find_children("*","Node3D",true,false):
  if n.has_meta("connector_baseboard"):
   if n.get_meta("connector_baseboard")=="south":
    black_trim+=1
    assert(n.material_override.albedo_color==Color("15151b"))
   else:
    purple_trim+=1
    assert(n.material_override.albedo_texture.resource_path=="res://presentation/purple-plaster.png")
  if n.has_meta("continuous_black_connector"):
   black+=1
   assert(n.get_parent().get_meta("room_wall","")=="purple elevator-5 connector:south")
  if n.has_meta("column_beam"):beams+=1
  if n.has_meta("column_end_pilaster"):pilasters+=1
  if n.has_meta("artwork_label_proxy"):labels+=1
  if n is StaticBody3D and n.get_child_count()>0 and n.get_child(0) is CollisionShape3D:
   var shape=n.get_child(0).shape
   if shape is BoxShape3D and shape.size.is_equal_approx(Vector3(.06,2.7,.95)):
    leaves.append([n.global_position.x,n.global_position.z])
    if abs(n.global_position.x-4.51)<.01 and n.global_position.z<0:unsupported_leaf=true
 var passed:bool=black==1 and beams==1 and pilasters==2 and labels==3 and leaves.size()==1 and not unsupported_leaf and abs(leaves[0][1]+4.65)<.01 and black_trim==1 and purple_trim==1
 passed=passed and not scene.inventory.get("grey_gallery_hall_reveal_leaves_built",true)
 assert(not scene.inventory.grey_gallery_metric_accepted and not scene.inventory.grey_gallery_objects_complete)
 print("SOURCE_STYLE_CHECK ",JSON.stringify({"black_wall":black,"beam":beams,"end_pilasters":pilasters,"labels":labels,"door_leaves":leaves,"metric_accepted":false}))
 quit(0 if passed else 1)
