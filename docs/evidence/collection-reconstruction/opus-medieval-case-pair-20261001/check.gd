## CPU only. Run through run_check.sh, which builds the scratch project from root helper copies and starts Mesa llvmpipe.
## Closure, winding, catalogue extents and anatomy for medieval_ceramic_ivory_assets.gd, then native Godot views.
## Writes checks.json and views-*.png into the folder named after `--`. With `--no-views` it only checks.
extends SceneTree

# RISD API records 1557221 and 1197491, typed here so the asset's own constants cannot vouch for themselves.
const QUEENS := Vector3(.16, .33, .16)
const CHRIST_WIDTH := .064
const CHRIST_HEIGHT := .159
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
	var args := OS.get_cmdline_user_args()
	var out: String = args[0]
	var Asset = load("res://medieval_ceramic_ivory_assets.gd")
	var report := {"asset": "modules/shell/prototype/collection_reconstruction/medieval_ceramic_ivory_assets.gd", "godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_video_adapter_name(), "objects": {}}
	var all := {}
	for key in ["queens", "christ", "christ_wedge"]:
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
		expect(abs(b.position.y) < 1e-6, "%s does not stand on its origin" % key)
		expect(abs(b.get_center().x) < .0005 and abs(b.get_center().z) < .0005, "%s is not centred on its origin" % key)

	# God Save the Queens: exact catalogue box; separate lid, ring, ceramic body, skirt and four feet.
	var q: Array = all.queens
	var qb := bounds(q.map(func(p): return p[2]))
	report.objects.queens["catalogue_m"] = [QUEENS.x, QUEENS.y, QUEENS.z]
	var off: Vector3 = (qb.size - QUEENS).abs()
	expect(max(off.x, off.y, off.z) < .0005, "queens bounds %s differ from catalogue 16 x 33 x 16 cm" % qb.size)
	var feet := named(q, "foot")
	expect(feet.size() == 4, "queens needs four feet, has %d" % feet.size())
	var quadrants := {}
	for f in feet:
		var fb := bounds([f])
		expect(abs(fb.position.y) < 1e-6 and fb.end.y >= bounds(named(q, "skirt")).position.y, "each foot must run from the deck up to the skirt")
		var pad := bounds([PackedVector3Array(Array(f).filter(func(p): return is_zero_approx(p.y)))]).get_center()
		var toe := Vector2(pad.x, pad.z)
		expect(toe.length() > .065 and toe.length() < .08, "toe must sit near the skirt edge: %s" % toe.length())
		quadrants[[signf(toe.x), signf(toe.y)]] = true
	expect(quadrants.size() == 4, "feet must stand in four different quadrants")
	var body := bounds(named(q, "body"))
	var skirt := bounds(named(q, "skirt"))
	var lid: PackedVector3Array = named(q, "lid")[0]
	var lid_box := bounds([lid])
	expect(named(q, "body").size() == 3 and body.size.y > .14 and body.size.y < .17 and abs(body.size.x - body.size.z) < 1e-4, "ceramic body must be one straight cylinder about 15 cm tall")
	for band in named(q, "body"):
		expect(is_equal_approx(bounds([band]).size.x, body.size.x), "ceramic body must keep one radius")
	expect(skirt.size.x > body.size.x * 1.1 and skirt.end.y <= body.position.y and is_equal_approx(skirt.size.x, QUEENS.x), "skirt must flare wider than the body, below it, to the catalogue width")
	expect(is_equal_approx(lid_box.position.y, body.end.y) and lid_box.size.x >= body.size.x and lid_box.size.y > .04, "lid must sit on the body and cover it")
	expect(inside(lid, Vector3(.05, lid_box.position.y + .012, 0)) and not inside(lid, Vector3(.05, lid_box.position.y + .04, 0)) and inside(lid, Vector3(.005, lid_box.end.y - .01, 0)),
		"lid must be a dome drawn up to a narrow top")
	var ring := named(q, "ring")
	var rb := bounds(ring)
	expect(ring.size() == 8 and is_equal_approx(rb.end.y, QUEENS.y) and rb.position.y >= lid_box.end.y - .003 and rb.size.z < rb.size.x * .5, "ring finial stands on the lid, facing front, and tops the object")
	for segment in ring:
		expect(not inside(segment, rb.get_center()), "ring must have a hole")
	expect(q.filter(func(p): return p[1] == "chrome").size() == 4 and q.filter(func(p): return p[1] == "cast").size() == 12, "lid, collar, neck and skirt are chrome; feet and ring are cast")

	# Christ in Majesty: catalogue height and width, depth declared provisional, relief masses of real depth on thin backing.
	var c: Array = all.christ
	var cb := bounds(c.map(func(p): return p[2]))
	report.objects.christ["catalogue_m"] = [CHRIST_WIDTH, CHRIST_HEIGHT, "not listed"]
	report.objects.christ["depth_m_provisional"] = cb.size.z
	expect(abs(cb.size.x - CHRIST_WIDTH) < .0005 and abs(cb.size.y - CHRIST_HEIGHT) < .0005, "christ bounds %s differ from catalogue 6.4 x 15.9 cm" % cb.size)
	expect(Asset.OBJECTS.christ.identity == "probable" and Asset.OBJECTS.christ.size.z == 0, "christ identity must stay probable and its depth unlisted")
	expect(is_equal_approx(cb.size.z, Asset.CHRIST_DEPTH * .01) and cb.size.z < cb.size.x * .4, "relief must be thin and match its declared provisional depth")
	var halo := bounds(named(c, "halo"))
	var head := bounds(named(c, "head"))
	var torso := bounds(named(c, "torso"))
	var lap := bounds(named(c, "lap"))
	var stool := bounds(named(c, "footstool"))
	var book := bounds(named(c, "book"))
	var backing := bounds(named(c, "halo") + named(c, "body plate"))
	expect(is_equal_approx(halo.end.y, cb.end.y) and halo.size.x > head.size.x * 1.5 and halo.grow(.001).encloses(AABB(head.position, Vector3(head.size.x, head.size.y, 0))), "halo disc behind and around the head, topping the plaque")
	expect(head.position.y >= torso.end.y - .004 and head.end.z > halo.end.z + .003 and torso.end.z > backing.end.z + .003, "head and torso must stand proud of the backing")
	expect(is_equal_approx(lap.end.z, cb.end.z) or is_equal_approx(book.end.z, cb.end.z), "the seated lap or the book is the deepest relief")
	expect(lap.position.y >= stool.end.y - 1e-6 and lap.end.y < torso.end.y and lap.size.x > torso.size.x, "seated: wide lap between footstool and chest")
	expect(book.get_center().x > 0 and book.position.y > lap.position.y and book.end.y < torso.position.y + .01 and bounds(named(c, "book hand")).position.y >= bounds([named(c, "book")[0]]).end.y - 1e-6, "book on his left knee under the hand")
	expect(bounds(named(c, "blessing hand")).get_center().x < 0 and bounds(named(c, "blessing hand")).end.y > bounds(named(c, "book hand")).end.y, "blessing hand raised on the other side")
	var soles := named(c, "foot left") + named(c, "foot right")
	expect(soles.size() == 2 and bounds(soles).end.y < lap.position.y + .001 and bounds(soles).position.y > 0 and bounds(soles).end.z > stool.end.z, "two feet on the footstool")
	expect(is_zero_approx(stool.position.y) and backing.size.z < cb.size.z * .4, "footstool on the origin, backing thin")
	expect(not c.any(func(p): return p[1] == "mount") and all.christ_wedge.size() == 1, "the wedge is not a part of the ivory")
	var wedge := bounds(named(all.christ_wedge, "wedge"))
	expect(not inside(all.christ_wedge[0][2], Vector3(0, wedge.end.y * .9, wedge.end.z * .8)) and inside(all.christ_wedge[0][2], Vector3(0, wedge.end.y * .9, wedge.position.z * .9)), "wedge must slope down toward +Z")

	# Built nodes carry the checked triangles, a normal on every vertex, lit metal, no emission, and their flags.
	for key in ["queens", "christ"]:
		var node: Node3D = Asset.build(key)
		var built := 0
		for visual in node.get_children():
			var arrays: Array = visual.mesh.surface_get_arrays(0)
			built += arrays[Mesh.ARRAY_VERTEX].size() / 3
			expect(arrays[Mesh.ARRAY_NORMAL].size() == arrays[Mesh.ARRAY_VERTEX].size(), "%s: every vertex needs a normal" % key)
			var material: StandardMaterial3D = visual.material_override
			expect(not material.emission_enabled and material.shading_mode == BaseMaterial3D.SHADING_MODE_PER_PIXEL and material.albedo_texture == null, "%s / %s must be lit flat colour, not emissive" % [key, visual.name])
			expect((material.metallic > 0) == (String(visual.name) in Asset.METALS), "%s / %s metal flag" % [key, visual.name])
		expect(built == report.objects[key].triangles, "%s: built node does not carry the checked triangles" % key)
		expect(node.get_meta("catalogue_accession") == Asset.OBJECTS[key].accession and not String(node.get_meta("catalogue_unresolved")).is_empty(), "%s accession and unresolved tags" % key)
		report.objects[key]["identity"] = node.get_meta("catalogue_identity")
		report.objects[key]["unresolved"] = node.get_meta("catalogue_unresolved")
		node.free()
	expect(report.objects.queens.identity == "matched", "queens identity")

	# Optional decals: the two Muse view crops become three lit patches just outside the ceramic; the west face stays plain.
	var plain: Node3D = Asset.build("queens")
	expect(plain.get_children().all(func(n): return not String(n.name).begins_with("decal")), "no decals unless asked")
	expect("+Z" in String(plain.get_meta("catalogue_front")) and "-X" in String(plain.get_meta("catalogue_boat")), "front and boat axes must be recorded")
	plain.free()
	var textures := {}
	for face in ["roundel", "boat"]:
		textures[face] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path("res://decal-queens-%s.png" % face)))
	var dressed: Node3D = Asset.build("queens", textures)
	var patches := dressed.get_children().filter(func(n): return String(n.name).begins_with("decal"))
	expect(patches.map(func(n): return String(n.name)) == ["decal roundel front", "decal roundel rear copy", "decal boat east"], "decal patches: %s" % [patches.map(func(n): return n.name)])
	for patch in patches:
		var arrays: Array = patch.mesh.surface_get_arrays(0)
		var material: StandardMaterial3D = patch.material_override
		expect(material.albedo_texture != null and not material.emission_enabled and material.shading_mode == BaseMaterial3D.SHADING_MODE_PER_PIXEL, "%s must be a lit texture" % patch.name)
		var box: AABB = patch.get_aabb()
		expect(is_equal_approx(box.position.y, body.position.y) and is_equal_approx(box.end.y, body.end.y), "%s must cover the ceramic height only" % patch.name)
		for i in arrays[Mesh.ARRAY_VERTEX].size():
			var v: Vector3 = arrays[Mesh.ARRAY_VERTEX][i]
			var flat_v := Vector3(v.x, 0, v.z)
			expect(flat_v.length() > body.size.x / 2 and flat_v.length() < body.size.x / 2 + .001, "%s must sit just outside the body" % patch.name)
			expect(arrays[Mesh.ARRAY_NORMAL][i].dot(flat_v) > 0, "%s must face outward" % patch.name)
			var uv: Vector2 = arrays[Mesh.ARRAY_TEX_UV][i]
			expect(uv.x >= 0 and uv.x <= 1 and uv.y >= 0 and uv.y <= 1, "%s uv outside the crop" % patch.name)
		for i in range(0, arrays[Mesh.ARRAY_VERTEX].size(), 3):
			var a: Vector3 = arrays[Mesh.ARRAY_VERTEX][i]
			expect((arrays[Mesh.ARRAY_VERTEX][i + 2] - a).cross(arrays[Mesh.ARRAY_VERTEX][i + 1] - a).dot(a * Vector3(1, 0, 1)) > 0, "%s is wound inside out" % patch.name)
	expect(patches.size() == 3 and patches[0].get_aabb().get_center().z > 0 and patches[1].get_aabb().get_center().z < 0 and patches[2].get_aabb().get_center().x < 0, "roundels on +Z and -Z, boat on -X")
	report.objects.queens["decals"] = {"patches": patches.map(func(n): return String(n.name)), "triangles_each": 16, "west_face": "plain, never seen"}
	dressed.free()

	# The ivory on its wedge: every vertex on or above the slope, the back plane resting on it, nothing below the deck.
	var laid: Node3D = Asset.christ_on_wedge()
	var object: Node3D = laid.get_node("Christ")
	var low := Vector3(0, Asset.WEDGE_LOW, Asset.WEDGE.z / 2) * .01
	var normal := (Vector3(0, Asset.WEDGE.y, -Asset.WEDGE.z / 2) * .01 - low).normalized().cross(Vector3.LEFT)
	var nearest := INF
	var lowest := INF
	for p in c:
		for v in p[2]:
			var w: Vector3 = object.transform * v
			nearest = min(nearest, (w - low).dot(normal))
			lowest = min(lowest, w.y)
			expect(abs(w.x) < Asset.WEDGE.x * .005 and abs(w.z) < Asset.WEDGE.z * .005, "ivory must lie within the wedge top")
	expect(abs(nearest) < 1e-5 and lowest > Asset.WEDGE_LOW * .01, "ivory must rest on the slope, not in it: gap %s" % nearest)
	expect(laid.get_child_count() == 2 and laid.get_child(0).name == &"mount", "wedge mesh and ivory node are separate children")
	report.objects["christ_on_wedge"] = {"slope_deg": 90 - rad_to_deg(-object.rotation.x), "gap_m": nearest}
	laid.free()

	# The check itself must be able to fail.
	var sample: PackedVector3Array = named(q, "skirt")[0]
	var flipped := sample.duplicate()
	flipped[1] = sample[2]
	flipped[2] = sample[1]
	var inverted := sample.duplicate()
	inverted.reverse()
	var flat := sample.duplicate()
	flat[1] = flat[0]
	report["negative_controls"] = {"opened": problems(sample.slice(0, sample.size() - 3)), "flipped": problems(flipped), "inverted": problems(inverted), "collapsed": problems(flat)}
	for control in report.negative_controls:
		expect(not report.negative_controls[control].is_empty(), "negative control %s was not caught" % control)

	if not "--no-views" in args:
		expect("llvmpipe" in report.renderer, "renderer is not Mesa llvmpipe: %s" % report.renderer)
		await views(Asset, out)
	report["failures"] = failures
	report["passed"] = failures.is_empty()
	FileAccess.open(out.path_join("checks.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print(JSON.stringify(report, "  "))
	quit(0 if failures.is_empty() else 1)

## Front, object's left side (+X), rear, right side (-X) and a raised three-quarter view of each object, lit, on a plain grey ground.
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
	var textures := {}
	for face in ["roundel", "boat"]:
		textures[face] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path("res://decal-queens-%s.png" % face)))
	for key in ["queens", "queens_decals", "christ", "christ_on_wedge"]:
		var node: Node3D = Asset.christ_on_wedge() if key == "christ_on_wedge" else Asset.build("queens", textures) if key == "queens_decals" else Asset.build(key)
		root.add_child(node)
		var b := AABB()
		for visual in node.find_children("*", "MeshInstance3D", true, false):
			b = b.merge(visual.global_transform * visual.get_aabb()) if b.has_volume() else visual.global_transform * visual.get_aabb()
		var sheet := Image.create(VIEW.x * 5, VIEW.y, false, Image.FORMAT_RGB8)
		var directions := [Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(-.55, .42, .72).normalized()]
		for i in directions.size():
			camera.projection = Camera3D.PROJECTION_ORTHOGONAL if i < 4 else Camera3D.PROJECTION_PERSPECTIVE
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
		root.remove_child(node)
		node.free()
	print("views written: front, left side (+X), rear, right side (-X), three-quarter")
