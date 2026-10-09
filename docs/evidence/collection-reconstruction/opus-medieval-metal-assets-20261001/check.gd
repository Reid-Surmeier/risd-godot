## CPU only. Run through run_check.sh, which builds the scratch project and starts Mesa llvmpipe.
## Closure, winding, catalogue bounds and anatomy for medieval_metal_assets.gd, then native Godot views.
## Writes checks.json and views-*.png into the folder named after `--`.
extends SceneTree

const KEYS := ["monstrance", "beaker", "pyx", "pax"]
# RISD API records 1443596, 1550551, 1230716, 1211626, typed here so the asset's own constants cannot vouch for themselves.
const CATALOGUE_HEIGHT := {"monstrance": .464, "beaker": .14, "pyx": .089, "pax": .121}
const PAX_WIDTH := .089
const PAX_DEPTH := .022
const VIEW := Vector2i(560, 760)

var failures := []

func expect(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)

func bounds(shells: Array) -> AABB:
	var b := AABB(shells[0][0], Vector3.ZERO)
	for s in shells:
		for p in s:
			b = b.expand(p)
	return b

## Problems with one shell: every directed edge once and its reverse once, no collapsed triangle, positive Godot-wound volume.
func problems(s: PackedVector3Array) -> Array:
	var out := []
	var edges := {}
	var volume := 0.0
	for i in range(0, s.size(), 3):
		if (s[i + 1] - s[i]).cross(s[i + 2] - s[i]).length() < 1e-9:
			out.append("collapsed triangle")
		volume += s[i].dot(s[i + 2].cross(s[i + 1])) / 6
		for j in 3:
			var key := [s[i + j].snappedf(1e-6), s[i + (j + 1) % 3].snappedf(1e-6)]
			if edges.has(key):
				out.append("repeated directed edge")
			edges[key] = true
	for key in edges:
		if not edges.has([key[1], key[0]]):
			out.append("open edge")
	if volume <= 0:
		out.append("inside-out or empty")
	return out

## Parity of triangle crossings on a skewed upward ray: true when the point is inside the solid.
func inside(s: PackedVector3Array, point: Vector3) -> bool:
	var hits := 0
	for i in range(0, s.size(), 3):
		if Geometry3D.ray_intersects_triangle(point, Vector3(.211, .957, .199), s[i], s[i + 1], s[i + 2]) != null:
			hits += 1
	return hits % 2 == 1

func named(parts: Array, prefix: String) -> Array:
	return parts.filter(func(p): return p[0].begins_with(prefix)).map(func(p): return p[2])

func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	var Asset = load("res://medieval_metal_assets.gd")
	var report := {"asset": "modules/shell/prototype/collection_reconstruction/medieval_metal_assets.gd", "godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_video_adapter_name(), "objects": {}}
	expect("llvmpipe" in report.renderer, "renderer is not Mesa llvmpipe: %s" % report.renderer)
	var all := {}
	for key in KEYS + ["pax_stand"]:
		var parts: Array = Asset.parts(key)
		all[key] = parts
		var triangles := 0
		var names := {}
		for p in parts:
			for problem in problems(p[2]):
				expect(false, "%s / %s: %s" % [key, p[0], problem])
			triangles += p[2].size() / 3
			names[p[0]] = p[2].size() / 3
		var b := bounds(parts.map(func(p): return p[2]))
		report.objects[key] = {"closed_shells": parts.size(), "triangles": triangles, "bounds_m": [b.size.x, b.size.y, b.size.z], "part_triangles": names}
		if key in KEYS:
			# Catalogue bounds leave the pax handle out, as the record does.
			var c := bounds(parts.filter(func(p): return p[0] != "handle").map(func(p): return p[2]))
			report.objects[key]["catalogue_height_m"] = CATALOGUE_HEIGHT[key]
			report.objects[key]["checked_bounds_m"] = [c.size.x, c.size.y, c.size.z]
			report.objects[key]["identity"] = Asset.OBJECTS[key].identity
			expect(abs(c.size.y - CATALOGUE_HEIGHT[key]) < .0005, "%s height %s differs from catalogue %s" % [key, c.size.y, CATALOGUE_HEIGHT[key]])
			expect(abs(b.position.y) < 1e-6, "%s does not stand on its origin" % key)
			expect(abs(c.get_center().x) < .001, "%s is not centred on X" % key)
	expect(Asset.OBJECTS.beaker.identity == "probable" and Asset.OBJECTS.pyx.identity == "probable", "beaker and pyx identities must stay probable")

	# Monstrance: lobed foot widest, knopped stem, open chamber, pinnacles, spire on top.
	var m: Array = all.monstrance
	var foot := bounds(named(m, "foot"))
	var stem: PackedVector3Array = named(m, "stem")[0]
	expect(abs(bounds(m.map(func(p): return p[2])).get_center().z) < .001, "monstrance is not centred on Z")
	expect(foot.size.x > .16 and foot.size.x < .19 and foot.size.z < foot.size.x * .8, "foot must be the long lobed foot, about 17.6 x 12.4 cm")
	var radii := {}
	for p in named(m, "foot")[0]:
		if is_equal_approx(p.y, .012):
			radii[snappedf(Vector2(p.x / 9.25, p.z / 6.2).length() * 100, .001)] = true
	expect(radii.size() == 2, "foot rim must alternate lobes and valleys")
	var widths := []
	for y in [.056, .078, .103, .13]:
		var w := 0.0
		for i in range(0, stem.size(), 3):
			for j in 3:
				var a: Vector3 = stem[i + j]
				var c2: Vector3 = stem[i + (j + 1) % 3]
				if (a.y - y) * (c2.y - y) < 0:
					w = max(w, abs(a.lerp(c2, (y - a.y) / (c2.y - a.y)).x))
		widths.append(w)
	expect(widths[0] > widths[1] * 1.8 and widths[2] > widths[1] * 1.8 and widths[2] > widths[3] * 1.8, "stem must carry two knops wider than the shaft: %s" % [widths])
	expect(named(m, "lower post").size() == 6 and named(m, "upper post").size() == 6 and named(m, "pinnacle").size() == 6, "six posts per storey and six pinnacles")
	for point in [Vector3(0, .23, 0), Vector3(0, .31, 0)]:
		for p in m:
			expect(not inside(p[2], point), "chamber must be open at %s, filled by %s" % [point, p[0]])
	expect(inside(named(m, "cornice")[0], Vector3(0, .39, 0)) and bounds(named(m, "finial")).end.y > bounds(named(m, "cornice")).end.y, "solid spire under the finial")

	# Beaker: one shell, real mouth, lip wider than the collar, collar wider than the body above it, spreading foot.
	var cup: PackedVector3Array = all.beaker[0][2]
	expect(not inside(cup, Vector3(0, .10, 0)) and inside(cup, Vector3(0, .02, 0)), "beaker must be hollow above a solid foot")
	var cb := bounds([cup])
	expect(abs(cb.get_center().z) < .001 and cb.size.x > .09 and cb.size.x < .1, "beaker lip about 9.5 cm across")
	expect(inside(cup, Vector3(.0295, .028, 0)) and not inside(cup, Vector3(.0295, .045, 0)) and inside(cup, Vector3(.034, .002, 0)), "rope collar and foot must stand out from the body")

	# Pyx: cylinder, cone, knob, cross on top; hinge behind, clasp in front.
	var x: Array = all.pyx
	var body := bounds(named(x, "body"))
	expect(abs(body.get_center().x) < 1e-4 and abs(body.get_center().z) < 1e-4 and body.size.y < .04, "pyx body is a low cylinder on the origin")
	expect(bounds(named(x, "cross arms")).end.y < bounds(named(x, "cross upright")).end.y and bounds(named(x, "cross arms")).size.x > bounds(named(x, "cross upright")).size.x * 3, "cross finial")
	expect(bounds(named(x, "lid top")).size.x < bounds(named(x, "lid")).size.x * .5, "lid must be a cone")
	expect(bounds(named(x, "hinge")).end.z < body.position.z + .001 and bounds(named(x, "clasp")).end.z > body.end.z, "hinge behind, clasp in front")

	# Pax: catalogue width and depth without the handle, gable apex, relief proud of the ground, handle behind, stand apart.
	var p2: Array = all.pax
	var pb := bounds(p2.filter(func(p): return p[0] != "handle").map(func(p): return p[2]))
	expect(abs(pb.size.x - PAX_WIDTH) < .0005 and abs(pb.size.z - PAX_DEPTH) < .0005 and abs(pb.get_center().z) < .0005, "pax bounds without handle must be 8.9 x 2.2 cm: %s" % pb.size)
	var mount: PackedVector3Array = named(p2, "mount")[0]
	var apex := 0
	var eaves := 0.0
	for p in mount:
		if is_equal_approx(p.y, pb.end.y):
			apex += 1
			expect(abs(p.x) < 1e-6, "apex must be on the centre line")
		elif p.y > .09:
			eaves = max(eaves, abs(p.x))
	expect(apex > 0 and eaves < PAX_WIDTH / 2 * .7, "pax must rise to a gable narrower than its foot")
	var ground := bounds(named(p2, "shell ground"))
	for mass in ["angel", "virgin", "canopy"]:
		var r := bounds(named(p2, mass))
		expect(r.end.z > ground.end.z and r.end.z <= pb.end.z + 1e-6 and r.position.z > bounds([mount]).end.z, "%s mass must stand proud of the shell ground, inside the catalogue depth" % mass)
	expect(bounds(named(p2, "angel")).get_center().x < 0 and bounds(named(p2, "virgin")).get_center().x > 0, "angel left, Virgin right")
	expect(bounds(named(p2, "handle")).position.z < pb.position.z - .005 and bounds(named(p2, "handle")).end.z <= pb.position.z + .001, "handle stands off the back only")
	expect(not p2.any(func(p): return p[1] == "stand") and all.pax_stand.size() == 1, "stand rod is not a part of the pax")

	# Built nodes carry the checked triangles, a normal on every vertex, lit metal and no emission.
	for key in KEYS:
		var node: Node3D = Asset.build(key)
		var built := 0
		for visual in node.get_children():
			var arrays: Array = visual.mesh.surface_get_arrays(0)
			built += arrays[Mesh.ARRAY_VERTEX].size() / 3
			expect(arrays[Mesh.ARRAY_NORMAL].size() == arrays[Mesh.ARRAY_VERTEX].size(), "%s: every vertex needs a normal" % key)
			var material: StandardMaterial3D = visual.material_override
			expect(not material.emission_enabled and material.shading_mode == BaseMaterial3D.SHADING_MODE_PER_PIXEL, "%s / %s must be lit, not emissive" % [key, visual.name])
			expect((material.metallic > 0) == (String(visual.name) in Asset.METALS), "%s / %s metal flag" % [key, visual.name])
		expect(built == report.objects[key].triangles, "%s: built node does not carry the checked triangles" % key)
		expect(node.get_meta("catalogue_accession") == Asset.OBJECTS[key].accession, "%s accession tag" % key)
		node.free()

	# The check itself must be able to fail.
	var opened := cup.slice(0, cup.size() - 3)
	var flipped := cup.duplicate()
	flipped[1] = cup[2]
	flipped[2] = cup[1]
	var inverted := cup.duplicate()
	inverted.reverse()
	var flat := cup.duplicate()
	flat[1] = flat[0]
	report["negative_controls"] = {"opened": problems(opened), "flipped": problems(flipped), "inverted": problems(inverted), "collapsed": problems(flat)}
	for control in report.negative_controls:
		expect(not report.negative_controls[control].is_empty(), "negative control %s was not caught" % control)

	await views(Asset, out)
	report["failures"] = failures
	report["passed"] = failures.is_empty()
	FileAccess.open(out.path_join("checks.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print(JSON.stringify(report, "  "))
	quit(0 if failures.is_empty() else 1)

## Front, object's left side, rear and a raised three-quarter view of each object, lit, on a plain grey ground.
func views(Asset, out: String) -> void:
	await process_frame
	root.size = VIEW
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("8c8f92")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = .45
	root.add_child(world)
	var camera := Camera3D.new()
	root.add_child(camera)
	var key_light := DirectionalLight3D.new()
	key_light.light_energy = 1.3
	camera.add_child(key_light)
	key_light.rotation = Vector3(-.5, .6, 0)
	var shots := {}
	for key in KEYS + ["pax_on_stand"]:
		var node: Node3D = Asset.pax_on_stand() if key == "pax_on_stand" else Asset.build(key)
		root.add_child(node)
		var b := AABB()
		for visual in node.find_children("*", "MeshInstance3D", true, false):
			b = b.merge(visual.global_transform * visual.get_aabb()) if b.has_volume() else visual.global_transform * visual.get_aabb()
		var sheet := Image.create(VIEW.x * 4, VIEW.y, false, Image.FORMAT_RGB8)
		var directions := [Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(.55, .42, .72).normalized()]
		for i in directions.size():
			camera.projection = Camera3D.PROJECTION_ORTHOGONAL if i < 3 else Camera3D.PROJECTION_PERSPECTIVE
			camera.size = max(b.size.y, max(b.size.x, b.size.z) * VIEW.y / VIEW.x) * 1.12
			camera.fov = 24
			camera.near = .01
			camera.position = b.get_center() + directions[i] * (b.size.length() * 2.6)
			camera.look_at(b.get_center())
			await process_frame
			await RenderingServer.frame_post_draw
			var shot := root.get_texture().get_image()
			shot.convert(Image.FORMAT_RGB8)
			sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, VIEW), Vector2i(VIEW.x * i, 0))
		sheet.save_png(out.path_join("views-%s.png" % key.replace("_", "-")))
		shots[key] = "views-%s.png" % key.replace("_", "-")
		root.remove_child(node)
		node.free()
	print("views: front, left side, rear, three-quarter: ", shots)
