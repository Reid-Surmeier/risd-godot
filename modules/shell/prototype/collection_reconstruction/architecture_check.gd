## Run against a prepared extension: godot --path PROJECT -s THIS_SCRIPT.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	var failures: Array = []
	var lifts := 0
	var casings := 0
	var leaves := 0
	var roch := 0
	var grilles := 0
	for node in scene.find_children("*", "Node3D", true, false):
		if node.has_meta("renaissance_north_grille"):
			grilles += 1
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:north:header" or not node.global_position.is_equal_approx(Vector3(-2.5,3.20,28.19)) or node.get_child_count()!=5:
				failures.append("Renaissance north grille/slats lost their wall owner or source pose")
		if node.has_meta("saint_roch_installation"):
			roch += 1
			var figure = node.find_child("SaintRoch21398", true, false)
			if not node is StaticBody3D or not node.get_child(0) is CollisionShape3D or figure == null:
				failures.append("Saint Roch lacks its figure or colliding plinth")
			elif not figure.global_position.is_equal_approx(Vector3(-4.86, .68, 31.95)) or figure.get_meta("height_m") != 1.054:
				failures.append("Saint Roch lost its catalogue height or provisional window placement")
			if figure != null:
				for flag in ["visual_fidelity_accepted", "rear_fidelity_accepted", "placement_accepted", "survey_metres_accepted"]:
					if figure.get_meta(flag, true):
						failures.append("Saint Roch prematurely accepted: " + flag)
			var hood := 0
			for pane in node.get_children():
				if pane is MeshInstance3D and pane.material_override is StandardMaterial3D and pane.material_override.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA:
					hood += 1
			if hood != 5:
				failures.append("Saint Roch needs four transparent panes and a lid")
		if node.has_meta("lift_panel") or (node is Label3D and node.text == "5"):
			lifts += 1
			if node.get_parent().get_meta("room_wall", "") != "purple elevator-5 connector:north":
				failures.append("Lift feature has no north-wall cutaway owner")
		if node.has_meta("source_casing_width"):
			var room: String = str(node.get_meta("room_wall")).get_slice(":", 0)
			if room == "Grand Gallery":
				continue # Its trial visuals are emptied when the real Hall is retained.
			casings += 1
			var slim := room in ["grey French gallery", "purple elevator-5 connector", "piano-stair threshold study limit"]
			var expected := .10 if slim else .16
			var faces := 0
			for child in node.get_children():
				if child is MeshInstance3D and child.material_override is StandardMaterial3D:
					var texture = child.material_override.albedo_texture
					if texture != null and texture.resource_path.ends_with("/door-architrave.png"):
						faces += 1
						if not is_equal_approx(child.mesh.get_aabb().size.x, expected):
							failures.append("Wrong casing geometry for " + room)
			if faces != 3 or not is_equal_approx(float(node.get_meta("source_casing_width")), expected):
				failures.append("Casing width unsupported for " + room)
		if node is StaticBody3D and node.get_child_count() > 0 and node.get_child(0) is CollisionShape3D:
			var shape = node.get_child(0).shape
			if shape is BoxShape3D and shape.size.is_equal_approx(Vector3(.06, 2.7, .95)):
				leaves += 1
				if node.get_parent().get_meta("room_wall", "") != "piano-stair threshold study limit:south:header":
					failures.append("Piano leaf has no threshold cutaway owner")
				if node.get_child_count() != 8 or not node.global_position.is_equal_approx(Vector3(6.59, 1.35, -4.65)):
					failures.append("Piano panels lost their leaf or source placement")
	if lifts != 3 or leaves != 1 or casings < 10 or roch != 1 or grilles != 1:
		failures.append("Missing lift, leaf or casing coverage")
	print("ARCHITECTURE_CHECK ", JSON.stringify({"lift_features": lifts, "leaf": leaves, "casings": casings, "saint_roch": roch, "grilles": grilles, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
