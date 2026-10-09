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
	var triptych_panels := 0
	var pieta_cases := 0
	var case_rails := 0
	var east_cases := 0
	var east_objects := {}
	var wall_objects := {}
	var hood_panes := 0
	var textile_labels := 0
	var textile_platforms := 0
	var west_blinds := 0
	var west_sills := 0
	var hall_leaves := 0
	var linings := 0
	var landing_stairs := 0
	var landing_guards := 0
	var reveal: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json")).hall_reveal
	for node in scene.find_children("*", "Node3D", true, false):
		if node.has_meta("renaissance_west_blind") or node.has_meta("renaissance_west_sill"):
			var is_blind:bool=node.has_meta("renaissance_west_blind")
			west_blinds+=int(is_blind)
			west_sills+=int(not is_blind)
			var mesh:MeshInstance3D=node
			var box:AABB=mesh.global_transform*mesh.mesh.get_aabb()
			var low:float=.63 if is_blind else .51
			var high:float=3.0 if is_blind else .63
			if absf(box.position.y-low)>.001 or absf(box.end.y-high)>.001 or node.get_parent().get_meta("room_wall", "")!="light Renaissance room:west":
				failures.append("Renaissance window height or west-wall cutaway owner differs from source fit")
		if node.has_meta("renaissance_wall_object"):
			var key:String=node.get_meta("renaissance_wall_object")
			wall_objects[key]=wall_objects.get(key,0)+1
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:"+str(node.get_meta("wall_side")):
				failures.append("Wall artwork lost its cutaway owner: "+key)
			for flag in ["placement_accepted","metric_accepted","frame_accepted","fine_fidelity_accepted","whole_room_accepted"]:
				if not node.has_meta(flag):failures.append("Wall artwork lost its acceptance flag: "+key+"."+flag)
			# Independent Opus source-plane fits: native6383 6.1/68.4/68.5/15.1s, ±6cm.
			var bottom:=INF
			for mesh in node.get_children():
				if not mesh is MeshInstance3D:continue
				if key=="velvet_23307x" and mesh.get_meta("velvet_hood_pane",false):continue
				for vertex in mesh.mesh.get_faces():bottom=minf(bottom,(mesh.global_transform*vertex).y)
			var gap:float=bottom-.16
			# madonna_58196 (#266): panel bottom 1.07 m at 6383 15.0s (427 matches) and 1.075 m in the 1 Oct audit, so the frame's foot is .99, not the first fit's .71.
			var expected:float=.41 if key=="velvet_23307x" else .43 if key=="woodcutters_29280" else .83 if key=="madonna_58196" else .55
			if absf(gap-expected)>.06:failures.append("Wall artwork height disagrees with source-plane fit: "+key)
		if node.has_meta("velvet_hood_pane"):hood_panes+=1
		if node.has_meta("renaissance_textile_label"):textile_labels+=1
		if node.has_meta("renaissance_textile_platform"):
			textile_platforms+=1
			if not node is StaticBody3D or not node.get_child(0).shape.size.is_equal_approx(Vector3(4.30,.16,.95)):
				failures.append("Textile platform lost its low footprint or collision")
		if node.has_meta("renaissance_wall_case"):
			east_cases += 1
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:east" or not node is StaticBody3D:
				failures.append("East case lost its wall cutaway owner or collision")
		if node.has_meta("renaissance_case_object"):
			var key:String=node.get_meta("renaissance_case_object")
			east_objects[key]=east_objects.get(key,0)+1
			var owner:Node=node.get_parent()
			while owner!=null and not owner.has_meta("renaissance_wall_case"):owner=owner.get_parent()
			if owner==null:failures.append("Renaissance object lost case owner: "+key)
		if node.has_meta("wall_case_top_rail"):
			case_rails += 1
			var case:Node=node.get_parent()
			while case!=null and not (case.has_meta("pieta_wall_case") or case.has_meta("triptych_wall_case") or case.has_meta("renaissance_wall_case")):case=case.get_parent()
			if case==null:failures.append("Case rail lost its wall-case cutaway owner")
		if node.has_meta("pieta_wall_case"):
			pieta_cases += 1
			var figure = node.find_child("Pieta59128", true, false)
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:west" or not node is StaticBody3D or not node.get_child(0) is CollisionShape3D or figure == null:
				failures.append("Pietà case lost its west-wall owner, collision or figure")
			elif not figure.global_position.is_equal_approx(Vector3(-5.29,1.18,29.80)) or not figure.get_meta("catalogue_size_m").is_equal_approx(Vector3(.381,.457,.132)):
				failures.append("Pietà lost its catalogue bounds or window-relative placement")
			if figure != null:
				for flag in ["visual_fidelity_accepted","rear_fidelity_accepted","placement_accepted","survey_metres_accepted","whole_room_complete"]:
					if not figure.has_meta(flag):failures.append("Pietà lost its acceptance flag: "+flag)
		if node.has_meta("triptych_wall_case"):
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:north":
				failures.append("Triptych case lost its north-wall cutaway owner")
		if node.has_meta("triptych_panel"):
			triptych_panels += 1
			if "--open-triptych-negative-control" in OS.get_cmdline_user_args():
				node.remove_child(node.get_child(2))
			var edges := {}
			for surface in node.get_children():
				if not surface is MeshInstance3D:continue
				var faces:PackedVector3Array=surface.mesh.get_faces()
				for i in range(0,faces.size(),3):
					for side in 3:
						var a:=Vector3i((faces[i+side]*1000000).round())
						var b:=Vector3i((faces[i+(side+1)%3]*1000000).round())
						var pair:=[str(a),str(b)]
						pair.sort()
						var edge:String=pair[0]+pair[1]
						edges[edge]=edges.get(edge,0)+1
			if edges.is_empty() or not edges.values().all(func(n):return n==2):
				failures.append("Triptych panel has an open edge: "+str(node.get_meta("triptych_panel")))
			for flag in ["placement_accepted","metric_accepted","fine_fidelity_accepted"]:
				if not node.get_parent().has_meta(flag):
					failures.append("Triptych lost its acceptance flag: "+flag)
		if node.has_meta("renaissance_north_grille"):
			grilles += 1
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:north:header" or not node.global_position.is_equal_approx(Vector3(-2.5,3.20,28.19)) or node.get_child_count()!=5:
				failures.append("Renaissance north grille/slats lost their wall owner or source pose")
		if node.has_meta("hall_reveal_leaf"):
			hall_leaves += 1
			var west: bool = str(node.get_meta("room_wall")).ends_with(":west")
			# Folded flat inside the wall: one leaf deep, free edge on the Hall's own wall plane, not beyond it.
			if not str(node.get_meta("room_wall")).begins_with("Grand Gallery reveal threshold:") or not node.global_position.is_equal_approx(Vector3(4.6225 if west else 6.4775, 1.37, 1.8 - reveal.leaf_m / 2)) or node.get_child_count() != 9:
				failures.append("Hall reveal leaf lost its owner, folded pose, six panel faces or knob")
		if str(node.get_meta("room_wall", "")).begins_with("Rockefeller reveal threshold:"):
			linings += 1
		if node.has_meta("landing_guard"):
			landing_guards += 1
		if node.has_meta("landing_stair"):
			# One storey of risers reaches the floor below, and the stair fills its well wall to wall.
			landing_stairs += 1
			var spec: Dictionary = node.get_meta("landing_stair")
			var reach: AABB = node.global_transform * node.mesh.get_aabb()
			var count := 0
			for n in spec.risers:
				count += int(n)
			var well: Array = scene.room_bounds("lion stair landing")
			if not is_equal_approx(spec.storey_m, spec.rise_m * count) or absf(reach.position.y + spec.storey_m) > .3 or reach.size.x < well[1] - well[0] - .2 or reach.end.z < well[3] - .1 or not spec.has("metric_accepted"):
				failures.append("Landing stair does not fill its well, reach the floor below, or lost its acceptance flag")
		if node.has_meta("saint_roch_installation"):
			roch += 1
			var figure = node.find_child("SaintRoch21398", true, false)
			if not node is StaticBody3D or not node.get_child(0) is CollisionShape3D or figure == null:
				failures.append("Saint Roch lacks its figure or colliding plinth")
			elif not figure.global_position.is_equal_approx(Vector3(-4.86, .48, 31.95)) or figure.get_meta("height_m") != 1.054:
				failures.append("Saint Roch lost its catalogue height or provisional window placement")
			if figure != null:
				for flag in ["visual_fidelity_accepted", "rear_fidelity_accepted", "placement_accepted", "survey_metres_accepted"]:
					if not figure.has_meta(flag):
						failures.append("Saint Roch lost its acceptance flag: " + flag)
			var hood := 0
			for pane in node.get_children():
				if pane is MeshInstance3D and pane.material_override is StandardMaterial3D and pane.material_override.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA:
					hood += 1
			if hood != 5:
				failures.append("Saint Roch needs four transparent panes and a lid")
			var steps := 0
			var label := false
			var lid_y := 0.0
			for part in node.get_children():
				if part.has_meta("saint_roch_plinth_step"):
					steps += 1
				if part.has_meta("artwork_label_proxy"):
					label = true
				if part is MeshInstance3D and part.material_override is StandardMaterial3D and part.material_override.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA:
					lid_y = maxf(lid_y, part.global_position.y)
			if steps != 3 or not label or not is_equal_approx(lid_y, 1.89):
				failures.append("Saint Roch source-guided hood/plinth steps/label missing")
		if node.has_meta("lift_panel") or (node is Label3D and node.text == "5"):
			lifts += 1
			if node.get_parent().get_meta("room_wall", "") != "purple elevator-5 connector:north":
				failures.append("Lift feature has no north-wall cutaway owner")
		if node.has_meta("source_casing_width"):
			var room: String = str(node.get_meta("room_wall")).get_slice(":", 0)
			if room == "Grand Gallery":
				continue # Its trial visuals are emptied when the real Hall is retained.
			casings += 1
			var slim := room in ["grey French gallery", "purple elevator-5 connector", "Skylight Gallery"]
			var expected := .10 if slim else .16
			# The trim kit's casing: a left, a head and a right mesh, each the room's casing width.
			var faces := 0
			for child in node.get_children():
				if child is MeshInstance3D and child.has_meta("door_casing"):
					faces += 1
					if not is_equal_approx(float(child.get_meta("door_casing")), expected) or child.mesh.get_faces().size() < 3 * 2 * 18:
						failures.append("Wrong casing geometry for " + room)
			if faces != 3 or not is_equal_approx(float(node.get_meta("source_casing_width")), expected):
				failures.append("Casing width unsupported for " + room)
		if node.has_meta("skylight_reveal_leaf"):
			leaves += 1
			if not node is StaticBody3D or not str(node.get_meta("room_wall", "")).begins_with("Skylight Gallery reveal threshold:") or node.has_meta("hall_reveal_leaf"):
				failures.append("Skylight door leaf lost its reveal owner or collision")
	if lifts != 3 or leaves != 2 or casings < 10 or roch != 1 or grilles != 1 or hall_leaves != 2 or linings != 2:
		failures.append("Missing lift, leaf, reveal or casing coverage")
	for flag in ["depth_measured", "rockefeller_leaf_built"]:
		if scene.inventory.hall_reveal.get(flag, true):
			failures.append("Hall reveal claims what is not built or measured: " + flag)
	for flag in ["opening_metres_accepted", "leaf_fidelity_accepted"]:
		if not scene.inventory.hall_reveal.has(flag):
			failures.append("Hall reveal lost its acceptance flag: " + flag)
	if landing_stairs != 1 or landing_guards != 1:
		failures.append("Landing needs one open-well stair and one guard across its edge")
	if triptych_panels!=3:failures.append("Triptych needs three closed source panels")
	if pieta_cases!=1:failures.append("Pietà needs one colliding source-ordered wall case")
	if east_cases!=2:failures.append("Expected two Renaissance east-wall cases")
	if east_objects.size()!=11 or not east_objects.values().all(func(n):return n==1):failures.append("Expected each of eleven Renaissance case objects once")
	if wall_objects.size()!=3 or not wall_objects.values().all(func(n):return n==1):failures.append("Expected each of three Renaissance wall objects once")
	if hood_panes!=5 or textile_labels!=2 or textile_platforms!=1:failures.append("Textile hood, low platform or blank label stands missing")
	if west_blinds!=1 or west_sills!=1:failures.append("Renaissance west window missing")
	print("RENAISSANCE_WALL_CHECK ",JSON.stringify({"objects":wall_objects,"hood_panes":hood_panes,"platforms":textile_platforms,"label_stands":textile_labels}))
	if case_rails!=16:failures.append("The four Renaissance wall cases need their sixteen narrow source top rails")
	# Acceptance: a flag ending in _accepted may be true only with a record in acceptance.json
	# under "<subject>.<flag>" (what was measured, from what, the evidence file, the reviewer and
	# the commit; scripts/check_museum_records.py checks the record itself). A record whose flag
	# is not true is stale.
	var flags := {}
	_flags_in("inventory", scene.inventory, flags)
	for node in scene.find_children("*", "Node", true, false):
		var subject := str(node.name)
		for key in ["renaissance_case_object", "renaissance_wall_object", "catalogue_asset", "catalogue_accession"]:
			if node.has_meta(key):
				subject = str(node.get_meta(key))
		for meta in node.get_meta_list():
			var value = node.get_meta(meta)
			if str(meta).ends_with("_accepted"):
				flags[subject + "." + meta] = flags.get(subject + "." + meta, false) or value == true
			elif value is Dictionary:
				_flags_in(subject + "." + meta, value, flags)
	var records: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://acceptance.json")).records
	var accepted: Array = []
	for key in flags:
		if not flags[key]:
			continue
		accepted.append(key)
		if key.begins_with("@"):
			failures.append("Accepted on an unnamed node; name it or give it an accession first: " + key)
		elif not records.has(key):
			failures.append("Accepted without a record in acceptance.json: " + key)
	for key in records:
		if not flags.get(key, false):
			failures.append("Acceptance record without a true flag in the room code: " + key)
	accepted.sort()
	print("ACCEPTANCE_CHECK ", JSON.stringify({"flags": flags.size(), "accepted": accepted, "records": records.size()}))
	print("ARCHITECTURE_CHECK ", JSON.stringify({"lift_features": lifts, "leaf": leaves, "hall_reveal_leaves": hall_leaves, "rockefeller_linings": linings, "casings": casings, "saint_roch": roch, "grilles": grilles, "triptych_panels": triptych_panels, "pieta_cases": pieta_cases, "case_rails":case_rails,"east_cases":east_cases,"east_objects":east_objects, "failures": failures}))
	quit(0 if failures.is_empty() else 1)

## Every key ending in _accepted inside `data`, however deep, as "<prefix>.<key>" -> is it true.
func _flags_in(prefix: String, data: Dictionary, flags: Dictionary) -> void:
	for key in data:
		var value = data[key]
		if value is Dictionary:
			_flags_in(prefix + "." + str(key), value, flags)
		elif str(key).ends_with("_accepted"):
			flags[prefix + "." + str(key)] = flags.get(prefix + "." + str(key), false) or value == true
