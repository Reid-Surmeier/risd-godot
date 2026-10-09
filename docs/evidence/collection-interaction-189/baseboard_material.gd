## Apply the same local plaster fill used by bake/prepare.gd, without moving geometry/UVs.
extends SceneTree
func _initialize():
 var path="res://modules/shell/prototype/gallery_walk4/baked/room.tscn"
 var scene=load(path).instantiate()
 var changed=0
 for node in scene.get_children():
  if not node is MeshInstance3D:continue
  var bounds=node.mesh.get_aabb()
  if bounds.size.z>26.0 and bounds.end.y<0.4 and bounds.size.y>0.1 and bounds.size.x<0.2:
   node.material_override=node.material_override.duplicate()
   node.material_override.emission_enabled=true
   node.material_override.emission=Color(0.55,0.55,0.55)
   changed+=1
 assert(changed==2,"expected both long-wall baseboards")
 var packed=PackedScene.new()
 assert(packed.pack(scene)==OK)
 assert(ResourceSaver.save(packed,path)==OK)
 scene.free()
 print("BASEBOARD_MATERIAL updated both long-wall boards; geometry and lightmap retained")
 quit()
