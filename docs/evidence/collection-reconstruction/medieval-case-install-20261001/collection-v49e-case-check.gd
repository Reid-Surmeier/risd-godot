extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://remodel_room.tscn").instantiate();root.add_child(scene)
 var rows:=[]
 var papers:=0
 var fail:=[]
 for n in scene.find_children("*","Node3D",true,false):
  if n.has_meta("unidentified_paper_slot"):papers+=1
  if not n.has_meta("medieval_case_object"):continue
  var bounds:AABB
  var first:=true
  for m in n.find_children("*","MeshInstance3D",true,false):
   if first:bounds=m.global_transform*m.mesh.get_aabb();first=false
   else:bounds=bounds.merge(m.global_transform*m.mesh.get_aabb())
  var inside:=bounds.position.x>7.525 and bounds.end.x<8.575 and bounds.position.z>31.315 and bounds.end.z<32.215 and bounds.position.y>=.929 and bounds.end.y<1.98
  if not inside:fail.append(str(n.name))
  rows.append({"name":str(n.name),"position":str(n.global_position),"bounds":str(bounds),"inside_case":inside})
 var flags=scene.inventory.medieval_case_object_prototypes
 var passed:bool=rows.size()==7 and papers==2 and fail.is_empty() and not flags.placement_accepted and not flags.fine_fidelity_accepted and not scene.inventory.medieval_case_contents_complete
 var report={"objects":rows,"paper_mounts":papers,"failures":fail,"passed":passed}
 FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE).store_string(JSON.stringify(report,"\t")+"\n")
 print("CASE_INSTALL_CHECK ",JSON.stringify(report));quit(0 if passed else 1)
