extends SceneTree
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var args := OS.get_cmdline_user_args()
 var path := args[0] if not args.is_empty() else "res://modules/shell/prototype/gallery_walk4/baked/room.tscn"
 var room = load(path).instantiate()
 var rows := []
 for mesh in room.find_children("*", "MeshInstance3D", true, false):
  var material = mesh.material_override
  if not material is ShaderMaterial or not material.shader.resource_path.ends_with("/oak.gdshader"):
   continue
  var limits = material.get_shader_parameter("floor_z_limits")
  if limits.x != 0:
   continue
  var vertices: PackedVector3Array = mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
  var edges := {}
  for triangle in range(0, vertices.size(), 3):
   for side in 3:
    var a := Vector3i((vertices[triangle + side] * 100000.0).round())
    var b := Vector3i((vertices[triangle + (side + 1) % 3] * 100000.0).round())
    var midpoint := Vector3(a + b) / 200000.0
    if absf(midpoint.x) >= 2.9 or midpoint.z <= 0.1 or midpoint.z >= limits.y - 0.1:
     continue
    var key := str(a) + str(b) if a < b else str(b) + str(a)
    edges[key] = edges.get(key, 0) + 1
  var unmatched := 0
  for key in edges:
   if edges[key] != 2:
    unmatched += 1
    if unmatched <= 12: print("UNMATCHED ", key, " count=", edges[key])
  rows.append({"mesh":mesh.name,"limits":str(limits),"vertices":vertices.size(),"unmatched_interior_edges":unmatched})
 print(JSON.stringify(rows))
 var valid := not rows.is_empty()
 for row in rows:
  if row.unmatched_interior_edges != 0: valid = false
 room.free()
 quit(0 if valid else 1)
