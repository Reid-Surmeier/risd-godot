## #176 private source geometry regression, before static merging hides metadata.
extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk._vp = SubViewport.new()
	root.add_child(walk._vp)
	walk._build_room()
	walk._build_paintings()
	var legs := 0
	var vents := 0
	var captions := 0
	var cushions := 0
	for mesh in walk._vp.find_children("*", "MeshInstance3D", true, false):
		legs += int(mesh.get_meta("bench_leg", false))
		vents += int(mesh.get_meta("wall_vent", false))
		captions += int(mesh.get_meta("caption_plate", false))
		if mesh.get_meta("bench_cushion", false):
			cushions += 1
			var bounds: AABB = mesh.mesh.get_aabb()
			assert(bounds.size.y > 0.20 and bounds.end.y <= 0.461, "thin or oversized cushion")
	assert(legs == 16 and vents == 6 and captions == 23 and cushions == 2)
	assert(walk._paintings.size() == 23)
	walk._vp.free()
	walk.free()
	print("WORLD176 source: 16 turned supports, 2 thick cushions, 6 vents, 23 caption plates PASS")
	quit()
