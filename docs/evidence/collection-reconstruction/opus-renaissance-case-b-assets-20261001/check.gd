## CPU only. Run through run_check.sh, which builds the scratch project and starts Mesa llvmpipe.
## Closure, finite bounds, catalogue size, texture mapping and the not-accepted flags for renaissance_case_b_assets.gd, then native Godot views.
## Writes checks.json and views-*.png into the first folder after `--`; the second is the textures folder.
extends SceneTree

# Source order in native IMG_6383 56.0s. RISD API records 1494506, 1264011, 1228756, 1442936, 1246991: width and height in metres,
# typed here so the asset's own constants cannot vouch for themselves.
const CATALOGUE := {"plate_46391": Vector2(.225, .225), "plate_57302": Vector2(.232, .232), "roundel_51105": Vector2(.111, .111),
	"glass_201729": Vector2(.19, .19), "plaque_34024": Vector2(.107, .129)}
const ACCESSION := {"plate_46391": "46.391", "plate_57302": "57.302", "roundel_51105": "51.105", "glass_201729": "2017.29", "plaque_34024": "34.024"}
# Official photographs of the back exist for these three only.
const REAR_PHOTOGRAPHED := ["plate_57302", "roundel_51105", "glass_201729"]
const FLAGS := ["rear_accepted", "thickness_accepted", "mount_accepted", "placement_accepted", "fine_fidelity_accepted", "whole_room_accepted"]
# Schematic source order for the group views only: plates above, deck objects below. Not a placement.
const GROUP := {"plate_46391": Vector3(-.14, .30, 0), "plate_57302": Vector3(.16, .29, 0), "roundel_51105": Vector3(-.2, .0555, 0),
	"glass_201729": Vector3(.03, .095, 0), "plaque_34024": Vector3(.24, .0645, 0)}
# A photograph may only lie on faces within 60 degrees of facing it.
const WEDGE := .5
const VIEW := Vector2i(560, 560)

var failures := []

func expect(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)

## Problems with one shell: finite vertices, every directed edge once and its reverse once, no collapsed triangle, positive Godot-wound volume.
func problems(s: PackedVector3Array) -> Array:
	var out := []
	var edges := {}
	var volume := 0.0
	for p in s:
		if not p.is_finite() or p.length() > 1:
			out.append("vertex not finite or beyond one metre")
			return out
	for i in range(0, s.size(), 3):
		if (s[i + 1] - s[i]).cross(s[i + 2] - s[i]).length() < 1e-10:
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
			break
	if volume <= 0:
		out.append("inside-out or empty")
	return out

func bounds(shells: Array) -> AABB:
	var b := AABB(shells[0][0], Vector3.ZERO)
	for s in shells:
		for p in s:
			b = b.expand(p)
	return b

func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	var textures: String = OS.get_cmdline_user_args()[1]
	var Asset = load("res://modules/shell/prototype/collection_reconstruction/renaissance_case_b_assets.gd")
	var report := {"asset": "renaissance_case_b_assets.gd", "godot": Engine.get_version_info().string, "renderer": RenderingServer.get_video_adapter_name(), "objects": {}}
	expect("llvmpipe" in report.renderer, "renderer is not Mesa llvmpipe: %s" % report.renderer)
	expect(Asset.OBJECTS.keys() == CATALOGUE.keys(), "five objects in source order, no more")
	var main: PackedVector3Array
	for key in CATALOGUE:
		var object: Dictionary = Asset.OBJECTS[key]
		var parts: Array = Asset.parts(key)
		var triangles := 0
		for p in parts:
			for problem in problems(p[1]):
				expect(false, "%s / %s: %s" % [key, p[0], problem])
			triangles += p[1].size() / 3
		# Catalogue size is the object without hardware, exact to a hundredth of a millimetre; it sits on its origin plane, centred.
		main = parts.filter(func(p): return p[0] == "main")[0][1]
		var b := bounds([main])
		expect(abs(b.size.x - CATALOGUE[key].x) < 1e-5 and abs(b.size.y - CATALOGUE[key].y) < 1e-5, "%s is %s, catalogue says %s" % [key, b.size, CATALOGUE[key]])
		expect(abs(b.get_center().x) < 1e-6 and abs(b.get_center().y) < 1e-6 and abs(b.position.z) < 1e-7, "%s is not centred on its rear plane" % key)
		expect(b.size.z > .002 and b.size.z < .06 and abs(b.size.z - object.depth) < 1e-6, "%s depth %s must be finite and equal its declared guess %s" % [key, b.size.z, object.depth])
		# The built node: checked triangles, normals, flags all false, identity and rear honesty.
		var node: Node3D = Asset.build(key, textures)
		var built := 0
		var faces := {}
		for visual in node.get_children():
			var arrays: Array = visual.mesh.surface_get_arrays(0)
			var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			built += points.size() / 3
			faces[String(visual.name)] = points.size() / 3
			expect(normals.size() == points.size(), "%s / %s: every vertex needs a normal" % [key, visual.name])
			var material: Material = visual.material_override
			var see_through: bool = material is StandardMaterial3D and material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA
			if visual.name == "body":
				expect(not see_through and material.get_shader_parameter("albedo") == null, "%s body must be plain and opaque" % key)
				continue
			# Photograph faces: square to the photograph (no wedge), every texture coordinate inside the photographed outline (no backdrop).
			expect(see_through == (key == "glass_201729"), "%s / %s: only the glass panes are see-through" % [key, visual.name])
			if see_through:
				expect(material.blend_mode == BaseMaterial3D.BLEND_MODE_MUL and material.albedo_texture != null, "glass panes must filter the light behind them")
			var spec: Dictionary = object[String(visual.name)]
			var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			var steepest := 1.0
			var furthest := 0.0
			for i in points.size():
				steepest = min(steepest, normals[i].z * (1 if visual.name == "front" else -1))
				var px: Vector2 = uvs[i] * spec.px
				expect(uvs[i].x >= 0 and uvs[i].x <= 1 and uvs[i].y >= 0 and uvs[i].y <= 1, "%s / %s: texture coordinate leaves the texture" % [key, visual.name])
				if spec.has("radii"):
					furthest = max(furthest, ((px - spec.centre) / spec.radii).length())
				else:
					furthest = max(furthest, 1.0 if Geometry2D.is_point_in_polygon(px, PackedVector2Array(spec.corners)) or spec.corners.any(func(c): return c.distance_to(px) < .01) else 2.0)
			expect(steepest > WEDGE, "%s / %s: a face %s from square carries the photograph" % [key, visual.name, steepest])
			expect(furthest <= 1.0001, "%s / %s: texture coordinate %s outside the photographed outline" % [key, visual.name, furthest])
			var size: Vector2 = (material.albedo_texture if see_through else material.get_shader_parameter("albedo")).get_size()
			expect(size == spec.px, "%s / %s: texture is %s, mapping expects %s" % [key, visual.name, size, spec.px])
		expect(built == triangles, "%s: built node does not carry the checked triangles" % key)
		expect(faces.has("front") and faces.has("rear") == (key in REAR_PHOTOGRAPHED), "%s: a rear photograph may be shown only where one exists" % key)
		expect(node.get_meta("source_rear_observed") == (key in REAR_PHOTOGRAPHED), "%s: source_rear_observed" % key)
		expect(node.get_meta("catalogue_accession") == ACCESSION[key] and node.get_meta("catalogue_size") == CATALOGUE[key], "%s catalogue tags" % key)
		expect(node.get_meta("catalogue_identity") == ("probable" if key == "plaque_34024" else "matched"), "%s identity: the plaque stays probable, the rest matched" % key)
		for flag in FLAGS:
			expect(node.get_meta(flag) == false, "%s: %s must be false" % [key, flag])
		report.objects[key] = {"accession": ACCESSION[key], "identity": node.get_meta("catalogue_identity"), "catalogue_size_m": [CATALOGUE[key].x, CATALOGUE[key].y],
			"bounds_m": [b.size.x, b.size.y, b.size.z], "depth_provisional_m": object.depth, "closed_shells": parts.size(), "triangles": triangles, "mesh_triangles": faces,
			"source_rear_observed": node.get_meta("source_rear_observed"), "flags": FLAGS.map(func(f): return [f, node.get_meta(f)])}
		node.free()
	expect(Asset.FLAGS == FLAGS, "the asset must carry exactly the six not-accepted flags")

	# The check itself must be able to fail: an opened surface above all, then an inside-out and a non-finite one.
	var opened := main.slice(0, main.size() - 3)
	var inverted := main.duplicate()
	inverted.reverse()
	var broken := main.duplicate()
	broken[0] = Vector3(NAN, 0, 0)
	report["negative_controls"] = {"opened": problems(opened), "inverted": problems(inverted), "not_finite": problems(broken)}
	expect("open edge" in report.negative_controls.opened, "negative control: an open surface was not caught")
	expect(not report.negative_controls.inverted.is_empty() and not report.negative_controls.not_finite.is_empty(), "negative control: inverted or non-finite shell was not caught")

	await views(Asset, textures, out)
	report["failures"] = failures
	report["passed"] = failures.is_empty()
	FileAccess.open(out.path_join("checks.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print(JSON.stringify(report, "  "))
	quit(0 if failures.is_empty() else 1)

## Front, quarter, rear and from above for each object and for the five together, unlit as in the room, on a plain light ground.
func views(Asset, textures: String, out: String) -> void:
	await process_frame
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("d6d4cf")
	root.add_child(world)
	var camera := Camera3D.new()
	root.add_child(camera)
	var directions := [Vector3(0, 0, 1), Vector3(.62, .28, .73).normalized(), Vector3(0, 0, -1), Vector3(0, .9, .44).normalized()]
	for key in CATALOGUE.keys() + ["group"]:
		var node := Node3D.new()
		for k in (CATALOGUE.keys() if key == "group" else [key]):
			var object: Node3D = Asset.build(k, textures)
			object.position = GROUP[k] if key == "group" else Vector3.ZERO
			node.add_child(object)
		root.add_child(node)
		var b := AABB()
		for visual in node.find_children("*", "MeshInstance3D", true, false):
			b = b.merge(visual.global_transform * visual.get_aabb()) if b.has_volume() else visual.global_transform * visual.get_aabb()
		var tile := Vector2i(960, 720) if key == "group" else VIEW
		root.size = tile
		var sheet := Image.create(tile.x * 4, tile.y, false, Image.FORMAT_RGB8)
		for i in directions.size():
			camera.projection = Camera3D.PROJECTION_ORTHOGONAL if i % 2 == 0 else Camera3D.PROJECTION_PERSPECTIVE
			camera.size = max(b.size.y, b.size.x * tile.y / tile.x) * 1.12
			camera.fov = 24
			camera.near = .01
			camera.position = b.get_center() + directions[i] * (b.size.length() * 2.7)
			camera.look_at(b.get_center())
			await process_frame
			await RenderingServer.frame_post_draw
			var shot := root.get_texture().get_image()
			shot.convert(Image.FORMAT_RGB8)
			sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, tile), Vector2i(tile.x * i, 0))
		sheet.save_png(out.path_join("views-%s.png" % key.replace("_", "-")))
		root.remove_child(node)
		node.free()
	print("views: front, quarter, rear, above")
