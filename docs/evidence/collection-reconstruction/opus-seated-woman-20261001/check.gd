## Headless, no GPU: godot --headless --path <any empty project> -s check.gd
## Closure, winding, catalogue bounds, pose relations and case relations for seated_woman_asset.gd.
## Writes checks.json, seated-woman.obj and seated-woman-case.obj beside this file.
extends SceneTree

var failures := []
var report := {}

func expect(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)

func bounds(shells: Array) -> AABB:
	var b := AABB(shells[0][0], Vector3.ZERO)
	for s in shells:
		for p in s:
			b = b.expand(p)
	return b

## Every directed edge once and its reverse once, no collapsed triangle, positive Godot-wound volume.
func closed(s: PackedVector3Array, label: String) -> float:
	var edges := {}
	var volume := 0.0
	for i in range(0, s.size(), 3):
		expect((s[i + 1] - s[i]).cross(s[i + 2] - s[i]).length() > 1e-9, label + ": collapsed triangle")
		volume += s[i].dot(s[i + 2].cross(s[i + 1])) / 6
		for j in 3:
			var key := [s[i + j].snappedf(1e-6), s[i + (j + 1) % 3].snappedf(1e-6)]
			expect(not edges.has(key), label + ": repeated directed edge")
			edges[key] = true
	for key in edges:
		expect(edges.has([key[1], key[0]]), label + ": open edge")
	expect(volume > 0, label + ": inside-out or empty")
	return volume

func obj(path: String, groups: Dictionary) -> void:
	var text := "# metres, +Y up; written by check.gd from seated_woman_asset.gd\n"
	var count := 0
	for name in groups:
		text += "o %s\n" % name
		for s in groups[name]:
			for p in s:
				text += "v %.5f %.5f %.5f\n" % [p.x, p.y, p.z]
			for i in range(0, s.size(), 3):
				text += "f %d %d %d\n" % [count + i + 1, count + i + 2, count + i + 3]
			count += s.size()
	FileAccess.open(path, FileAccess.WRITE).store_string(text)

func _initialize() -> void:
	var here: String = get_script().resource_path.get_base_dir()
	var Asset = load(here.path_join("../../../../modules/shell/prototype/collection_reconstruction/seated_woman_asset.gd").simplify_path())
	var figure: Array = Asset.figure_shells()
	var names := ["base", "base step", "seat post", "torso", "left upper arm", "left forearm", "right arm",
		"crossing thigh", "crossing shin", "hanging foot", "lower thigh", "lower shin", "tiptoe foot", "head"]
	expect(figure.size() == names.size(), "figure part count")
	var triangles := 0
	var parts := {}
	for i in figure.size():
		var volume := closed(figure[i], names[i])
		triangles += figure[i].size() / 3
		parts[names[i]] = {"triangles": figure[i].size() / 3, "volume_cm3": snappedf(volume * 1e6, .1)}
	var b := bounds(figure)
	# RISD API 1552686, typed here so the asset's own constant cannot vouch for itself.
	var catalogue := Vector3(.203, .711, .241)
	var off: Vector3 = (b.size - catalogue).abs()
	expect(max(off.x, off.y, off.z) < .0005, "figure bounds differ from catalogue 71.1 x 20.3 x 24.1 cm: %s" % b.size)
	expect(abs(b.position.y) < 1e-6 and abs(b.get_center().x) < .0005 and abs(b.get_center().z) < .0005, "figure not seated on its origin")
	# Pose relations read from the photographs, so a box or a standing figure cannot pass.
	var seat_top: float = bounds([figure[2]]).end.y
	var torso := bounds([figure[3]])
	var crossing := bounds([figure[7]])
	var lower := bounds([figure[10]])
	var head := bounds([figure[13]])
	expect(torso.position.y <= seat_top and torso.end.y > seat_top + .2, "hips do not rest on the seat post")
	expect(crossing.end.y > lower.end.y and crossing.get_center().x > lower.get_center().x, "crossing knee must be the higher one, on the figure's left")
	expect(crossing.end.z > torso.end.z + .05 and lower.end.z > crossing.end.z, "knees must project in front of the torso, the lower one furthest")
	expect(crossing.end.y < torso.end.y - .1 and lower.position.y > seat_top - .06, "raised knees sit between the seat and the shoulders")
	expect(abs(bounds([figure[12]]).position.y - bounds([figure[1]]).end.y) < .002, "tiptoe foot must reach the base step")
	expect(bounds([figure[9]]).position.y > bounds([figure[1]]).end.y + .1, "crossing foot must hang clear of the base")
	expect(abs(bounds([figure[6]]).position.y - seat_top) < .09, "right hand must hang to about seat height")
	expect(is_equal_approx(head.end.y, b.end.y) and head.get_center().z > torso.get_center().z, "bowed head must be the highest mass, forward of the torso")
	expect(b.size.y / max(b.size.x, b.size.z) > 2.5, "figure must stay a tall narrow mass")

	var case: Dictionary = Asset.case_shells()
	var case_triangles := 0
	for kind in case:
		for i in case[kind].size():
			closed(case[kind][i], "%s %d" % [kind, i])
			case_triangles += case[kind][i].size() / 3
	var all_case: Array = case.body + case.trim + case.glass
	var cb := bounds(all_case)
	var hood := bounds(case.glass)
	var deck_top := bounds([case.trim[2]])
	var placed := AABB(b.position + Vector3(0, Asset.DECK_Y, Asset.FIGURE_Z), b.size)
	expect(abs(cb.position.z) < 1e-6 and abs(bounds(case.body).position.z) < 1e-6 and abs(hood.position.z) < 1e-6, "plinth and hood must meet the wall plane")
	expect(abs(cb.position.y) < 1e-6, "plinth foot must reach the floor (source: it does, 63.5s)")
	expect(is_equal_approx(deck_top.end.y, Asset.DECK_Y), "deck top height")
	expect(hood.grow(-.012).encloses(placed), "hood must enclose the figure")
	expect(hood.end.y - placed.end.y > .03 and hood.end.y - placed.end.y < .15, "hood top sits just above the head (51.25s)")
	var flat_deck := bounds([PackedVector3Array(Array(case.trim[2]).filter(func(p): return is_equal_approx(p.y, Asset.DECK_Y)))])
	expect(flat_deck.grow(.001).encloses(AABB(placed.position, Vector3(placed.size.x, 0, placed.size.z))), "base must stand inside the flat deck")
	expect(cb.size.x < .8, "case must fit between the authored radiator covers (0.80 m)")

	var node: StaticBody3D = Asset.build()
	var meshes := node.find_children("*", "MeshInstance3D", true, false)
	var built := 0
	for m in meshes:
		built += m.mesh.get_faces().size() / 3
		expect(m.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL].size() == m.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size(), "every vertex needs a normal for the bake unwrap")
	expect(meshes.size() == 4 and built == triangles + case_triangles, "built node does not carry the checked triangles")
	expect(node.get_child(0) is CollisionShape3D, "case needs collision")
	expect(meshes[3].material_override.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA, "hood must be alpha so remodel_bake.gd skips it")
	expect(node.get_node("SeatedWoman").get_meta("catalogue_accession") == "67.089", "accession tag")
	node.free()

	obj(here.path_join("seated-woman.obj"), {"seated_woman_67_089": figure})
	obj(here.path_join("seated-woman-case.obj"), {"body": case.body, "trim": case.trim, "glass": case.glass,
		"seated_woman_67_089": figure.map(func(s): return PackedVector3Array(Array(s).map(func(p): return p + Vector3(0, Asset.DECK_Y, Asset.FIGURE_Z))))})
	report = {
		"asset": "modules/shell/prototype/collection_reconstruction/seated_woman_asset.gd",
		"godot": Engine.get_version_info().string,
		"gpu_used": false,
		"figure": {"closed_shells": figure.size(), "triangles": triangles, "bounds_m": [b.size.x, b.size.y, b.size.z],
			"catalogue_m": [catalogue.x, catalogue.y, catalogue.z], "parts": parts},
		"case": {"closed_shells": all_case.size(), "triangles": case_triangles, "bounds_m": [cb.size.x, cb.size.y, cb.size.z],
			"deck_top_m": Asset.DECK_Y, "hood_top_m": Asset.HOOD_TOP, "head_top_m": placed.end.y, "meets_wall": true, "reaches_floor": true},
		"failures": failures,
		"passed": failures.is_empty(),
	}
	FileAccess.open(here.path_join("checks.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print(JSON.stringify(report, "  "))
	quit(0 if failures.is_empty() else 1)
