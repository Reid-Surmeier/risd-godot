## CPU only. Run through run_check.sh, which builds the scratch project and starts Mesa llvmpipe.
## Closure, finite bounds, catalogue size, hardware fit, texture mapping and the not-accepted flags for renaissance_wall_assets.gd, then native Godot views.
## Writes checks.json and views-*.png into the first folder after `--`; the second is the textures folder.
extends SceneTree

# RISD API records 1202276, 1201986, 1591076: width and height in metres, typed here so the asset's own constants cannot vouch for themselves.
# The velvet's record gives "127 cm (50 inches) (length)" and no width: 0 means not catalogued.
const CATALOGUE := {"velvet_23307x": Vector2(0, 1.27), "woodcutters_29280": Vector2(.94, 1.524), "madonna_58196": Vector2(.87, .914)}
const ACCESSION := {"velvet_23307x": "23.307X", "woodcutters_29280": "29.280", "madonna_58196": "58.196"}
const FLAGS := ["rear_accepted", "thickness_accepted", "mount_accepted", "frame_accepted", "placement_accepted", "fine_fidelity_accepted", "metric_accepted",
	"dimension_conflict_resolved", "whole_room_accepted"]
# The velvet's catalogue page carries an official photograph of its back. Nothing shows the back of the other two.
const REAR_PHOTOGRAPHED := ["velvet_23307x"]
const MESHES := {"velvet_23307x": ["edge", "front", "hardware rear", "mount", "rear"], "woodcutters_29280": ["edge", "front", "rear"],
	"madonna_58196": ["edge", "frame bottom", "frame edge", "frame left", "frame right", "frame top", "front", "hardware rear", "rear"]}
# The velvet's width has no catalogue value. The photograph's proportion gives it; two weak video fits against the tapestry gave .48 and .53 m.
const VELVET_WIDTH := [.45, .55]
const WEDGE := .5
const VIEW := Vector2i(640, 760)

var failures := []

func expect(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)

## Problems with one shell: finite vertices, every directed edge once and its reverse once, no collapsed triangle, positive Godot-wound volume.
func problems(s: PackedVector3Array) -> Array:
	var out := []
	var edges := {}
	var volume := 0.0
	if s.is_empty():
		return ["no triangles"]
	for p in s:
		if not p.is_finite() or p.length() > 2:
			return ["vertex not finite or beyond two metres"]
	for i in range(0, s.size(), 3):
		if (s[i + 1] - s[i]).cross(s[i + 2] - s[i]).length() < 1e-12:
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

## What is wrong with an artwork's bounds against its catalogue record. Exact to a hundredth of a millimetre.
func size_problems(key: String, b: AABB, declared_width: float) -> Array:
	var out := []
	var want: Vector2 = CATALOGUE[key]
	if abs(b.size.y - want.y) > 1e-5:
		out.append("%s is %.5f m tall, catalogue says %.3f" % [key, b.size.y, want.y])
	if want.x > 0 and abs(b.size.x - want.x) > 1e-5:
		out.append("%s is %.5f m wide, catalogue says %.3f" % [key, b.size.x, want.x])
	if want.x == 0 and (abs(b.size.x - declared_width) > 1e-4 or b.size.x < VELVET_WIDTH[0] or b.size.x > VELVET_WIDTH[1]):
		out.append("%s width %.4f m must equal its declared photograph proportion %.4f and lie in the video's range" % [key, b.size.x, declared_width])
	if abs(b.get_center().x) > 1e-5 or abs(b.get_center().y) > 1e-5 or abs(b.position.z) > 1e-7:
		out.append("%s is not centred on its back plane" % key)
	return out

## Flags a node claims as accepted. Nothing in this study may be.
func accepted(node: Node) -> Array:
	return FLAGS.filter(func(f): return node.get_meta(f, true) != false)

func image(path: String) -> Image:
	var out := Image.new()
	out.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	return out

func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	var textures: String = OS.get_cmdline_user_args()[1]
	var Asset = load("res://modules/shell/prototype/collection_reconstruction/renaissance_wall_assets.gd")
	var geometry: Dictionary = Asset.geometry(textures)
	var report := {"asset": "renaissance_wall_assets.gd", "godot": Engine.get_version_info().string, "renderer": RenderingServer.get_video_adapter_name(), "objects": {}}
	expect("llvmpipe" in report.renderer, "renderer is not Mesa llvmpipe: %s" % report.renderer)
	expect(Asset.OBJECTS.keys() == CATALOGUE.keys() and geometry.keys() == CATALOGUE.keys(), "three objects in wall order, no more")
	expect(Asset.FLAGS == FLAGS, "the asset must carry exactly the nine not-accepted flags")
	var main: PackedVector3Array
	for key in CATALOGUE:
		var object: Dictionary = Asset.OBJECTS[key]
		var g: Dictionary = geometry[key]
		var parts: Array = Asset.parts(key, g)
		var triangles := 0
		for p in parts:
			for problem in problems(p[1]):
				expect(false, "%s / %s: %s" % [key, p[0], problem])
			triangles += p[1].size() / 3
		expect(object.size == CATALOGUE[key], "%s: the asset's catalogue size %s is not the record's %s" % [key, object.size, CATALOGUE[key]])
		var mains := parts.filter(func(p): return p[0].begins_with("main")).map(func(p): return p[1])
		main = mains[0]
		var b := bounds(mains)
		for problem in size_problems(key, b, g.size_m[0]):
			expect(false, problem)
		expect(b.size.z > .001 and b.size.z < .03 and abs(b.size.z - object.depth) < 1e-6, "%s depth %s must be finite and equal its declared guess %s" % [key, b.size.z, object.depth])

		# Hardware sits where the video shows it and never covers what it should not.
		var hardware := {}
		if key == "velvet_23307x":
			var board := bounds(parts.filter(func(p): return p[0] == "mount").map(func(p): return p[1]))
			expect(abs(board.end.z) < 1e-7 and abs(board.size.z - Asset.MOUNT_DEPTH) < 1e-6, "the board's face must be the textile's back plane")
			expect(board.position.x < b.position.x - .15 and board.end.x > b.end.x + .15 and board.position.y < b.position.y - .05 and board.end.y > b.end.y + .05, "the board must show round the whole textile")
			expect(abs(board.size.x - g.mount.size_m[0]) < 1e-4 and abs(board.size.y - g.mount.size_m[1]) < 1e-4, "the board must be the size read from the video")
			hardware = {"mount_m": [board.size.x, board.size.y, board.size.z], "textile_margin_m": [b.position.x - board.position.x, board.end.x - b.end.x, board.end.y - b.end.y, b.position.y - board.position.y]}
		if key == "madonna_58196":
			var extent: Array = Asset.frame_extent(g)
			var sight: Vector2 = extent[0]
			var frame := bounds(parts.filter(func(p): return p[0].begins_with("frame")).map(func(p): return p[1]))
			var band: float = g.frame.bands_m[0] + g.frame.bands_m[1] + g.frame.bands_m[2]
			expect(abs(Asset.FRAME_SECTION[-1][0] - band) < 1e-6, "the frame section must be as wide as the bands measured from the video")
			expect(abs(frame.size.x / 2 - extent[1].x) < 1e-5 and abs(frame.size.y / 2 - extent[1].y) < 1e-5 and abs(frame.get_center().x) < 1e-5 and abs(frame.get_center().y) < 1e-5, "frame outer size")
			expect(abs(frame.position.z + Asset.PANEL_FROM_WALL) < 1e-7 and frame.end.z > b.end.z + .01 and frame.end.z < .08, "the frame stands on the wall and proud of the panel")
			# The sight edge covers a little of the photograph on every side and none of the plain margins shows.
			expect(sight.x < g.photo_m[0] / 2 and sight.x > g.photo_m[0] / 2 - .01 and sight.y < g.photo_m[1] / 2 and sight.y > g.photo_m[1] / 2 - .01, "the sight edge must lap the photograph by under a centimetre")
			for p in parts:
				if p[0].begins_with("frame"):
					for v in p[1]:
						expect(abs(v.x) > sight.x - 1e-6 or abs(v.y) > sight.y - 1e-6, "a frame vertex lies inside the sight opening")
			hardware = {"frame_outer_m": [frame.size.x, frame.size.y, frame.size.z], "sight_m": [sight.x * 2, sight.y * 2], "band_m": band,
				"photograph_m": g.photo_m, "panel_margin_not_in_photograph_m": (CATALOGUE[key].x - g.photo_m[0]) / 2}
		if key == "woodcutters_29280":
			expect(parts.size() == 1, "the tapestry hangs bare: no hardware")

		# The built node: checked triangles, normals, materials, flags all false, nothing claimed for the back.
		var node: Node3D = Asset.build(key, textures)
		var built := 0
		var faces := {}
		for visual in node.get_children():
			var arrays: Array = visual.mesh.surface_get_arrays(0)
			var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var face := String(visual.name)
			built += points.size() / 3
			faces[face] = points.size() / 3
			expect(normals.size() == points.size(), "%s / %s: every vertex needs a normal" % [key, face])
			var material: ShaderMaterial = visual.material_override
			var picture: Texture2D = material.get_shader_parameter("albedo")
			if face in ["edge", "mount", "frame edge", "hardware rear"] or (face == "rear" and not g.has("outline_texture") and not g.has("rear")):
				expect(picture == null and material.get_shader_parameter("use_texture") == false, "%s / %s must be plain" % [key, face])
				expect(not face.ends_with("rear") or material.get_shader_parameter("tint") == Asset.NEUTRAL, "%s / %s: an unobserved back must be the neutral colour" % [key, face])
				continue
			var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			var steepest := 1.0
			for i in points.size():
				steepest = min(steepest, normals[i].z * (-1 if face == "rear" else 1))
				expect(uvs[i].x >= -1e-6 and uvs[i].x <= 1 + 1e-6 and uvs[i].y >= -1e-6 and uvs[i].y <= 1 + 1e-6, "%s / %s: texture coordinate %s leaves the texture" % [key, face, uvs[i]])
			expect(steepest > WEDGE, "%s / %s: a face %s from square carries a picture" % [key, face, steepest])
			if face == "front":
				expect(Vector2(picture.get_size()) == Vector2(g.px[0], g.px[1]), "%s front texture is %s, mapping expects %s" % [key, picture.get_size(), g.px])
				expect((material.get_shader_parameter("alpha_cut") > 0) == g.has("outline_px"), "%s: backdrop is cut from the textiles only" % key)
			elif face == "rear" and key in REAR_PHOTOGRAPHED:
				expect(Vector2(picture.get_size()) == Vector2(g.rear.px[0], g.rear.px[1]) and material.get_shader_parameter("alpha_cut") > 0, "%s back must be its own photograph with the backdrop cut" % key)
			elif face == "rear":
				# The back is the outline mask in one plain colour: every texel white, tinted neutral. No photograph, no invented surface.
				var mask := image(textures + g.outline_texture)
				var white := true
				for y in range(0, mask.get_height(), 7):
					for x in range(0, mask.get_width(), 7):
						white = white and mask.get_pixel(x, y).r == 1 and mask.get_pixel(x, y).g == 1 and mask.get_pixel(x, y).b == 1
				expect(white and material.get_shader_parameter("tint") == Asset.NEUTRAL and material.get_shader_parameter("alpha_cut") > 0, "%s back must be the plain outline mask" % key)
			else:
				expect(Vector2(picture.get_size()) == Vector2(g.frame.strip_px[0], g.frame.strip_px[1]), "%s / %s: strip size" % [key, face])
		expect(built == triangles, "%s: built node does not carry the checked triangles" % key)
		var names := faces.keys()
		names.sort()
		expect(names == MESHES[key], "%s meshes are %s" % [key, names])
		expect(node.get_meta("source_rear_observed") == (key in REAR_PHOTOGRAPHED) and g.has("rear") == (key in REAR_PHOTOGRAPHED), "%s: a back may be shown only where a photograph of it exists" % key)
		expect(node.get_meta("catalogue_accession") == ACCESSION[key] and node.get_meta("width_from_catalogue") == (CATALOGUE[key].x > 0), "%s catalogue tags" % key)
		expect(accepted(node).is_empty(), "%s claims %s" % [key, accepted(node)])
		expect(not node.get_meta("dimension_conflicts").is_empty(), "%s must carry its catalogue and source conflicts" % key)
		report.objects[key] = {"accession": ACCESSION[key], "catalogue_dimensions": node.get_meta("catalogue_dimensions"), "catalogue_size_m": [CATALOGUE[key].x, CATALOGUE[key].y],
			"bounds_m": [b.size.x, b.size.y, b.size.z], "width_from_catalogue": CATALOGUE[key].x > 0, "depth_provisional_m": object.depth, "closed_shells": parts.size(),
			"triangles": triangles, "mesh_triangles": faces, "hardware": hardware, "source_rear_observed": key in REAR_PHOTOGRAPHED, "dimension_conflicts": node.get_meta("dimension_conflicts"), "flags": FLAGS.map(func(f): return [f, node.get_meta(f)])}
		node.free()

	# The check itself must be able to fail: an opened surface above all, then an inside-out and a non-finite one,
	# a wrong catalogue size, and a node that claims acceptance.
	var opened := main.slice(0, main.size() - 3)
	var inverted := main.duplicate()
	inverted.reverse()
	var broken := main.duplicate()
	broken[0] = Vector3(NAN, 0, 0)
	var stretched := AABB(Vector3(-.4437, -.457, 0), Vector3(.8874, .914, .01)) # the painting made 2% too wide
	var claimant: Node3D = Asset.build("woodcutters_29280", textures)
	claimant.set_meta("rear_accepted", true)
	report["negative_controls"] = {"opened": problems(opened), "inverted": problems(inverted), "not_finite": problems(broken),
		"wrong_size": size_problems("madonna_58196", stretched, 0), "false_acceptance": accepted(claimant)}
	claimant.free()
	expect("open edge" in report.negative_controls.opened, "negative control: an open surface was not caught")
	expect(not report.negative_controls.inverted.is_empty() and not report.negative_controls.not_finite.is_empty(), "negative control: inverted or non-finite shell was not caught")
	expect(report.negative_controls.wrong_size.size() == 1, "negative control: a 2% size error was not caught")
	expect(report.negative_controls.false_acceptance == ["rear_accepted"], "negative control: a claimed acceptance was not caught")

	await views(Asset, textures, out)
	report["failures"] = failures
	report["passed"] = failures.is_empty()
	FileAccess.open(out.path_join("checks.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print(JSON.stringify(report, "  "))
	quit(0 if failures.is_empty() else 1)

## Front, quarter, rear and from above for each object, unlit as in the room, on a wall-grey ground.
## The velvet's rear view leaves out its mount board.
func views(Asset, textures: String, out: String) -> void:
	await process_frame
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("b9b8b8")
	root.add_child(world)
	var camera := Camera3D.new()
	root.add_child(camera)
	root.size = VIEW
	var directions := [Vector3(0, 0, 1), Vector3(.62, .28, .73).normalized(), Vector3(0, 0, -1), Vector3(0, .9, .44).normalized()]
	for key in CATALOGUE:
		var node: Node3D = Asset.build(key, textures)
		root.add_child(node)
		var b := AABB()
		for visual in node.find_children("*", "MeshInstance3D", true, false):
			b = b.merge(visual.global_transform * visual.get_aabb()) if b.has_volume() else visual.global_transform * visual.get_aabb()
		var sheet := Image.create(VIEW.x * 4, VIEW.y, false, Image.FORMAT_RGB8)
		for i in directions.size():
			camera.projection = Camera3D.PROJECTION_ORTHOGONAL if i % 2 == 0 else Camera3D.PROJECTION_PERSPECTIVE
			camera.size = max(b.size.y, b.size.x * VIEW.y / VIEW.x) * 1.08
			camera.fov = 26
			camera.near = .01
			camera.position = b.get_center() + directions[i] * (b.size.length() * 2.5)
			camera.look_at(b.get_center())
			# The velvet's board hides its back: the rear view is taken with the board lifted away, so the photographed lining can be judged.
			for visual in node.get_children():
				visual.visible = not (i == 2 and key in REAR_PHOTOGRAPHED and visual.name in ["mount", "hardware rear"])
			await process_frame
			await RenderingServer.frame_post_draw
			var shot := root.get_texture().get_image()
			shot.convert(Image.FORMAT_RGB8)
			sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, VIEW), Vector2i(VIEW.x * i, 0))
		sheet.save_png(out.path_join("views-%s.png" % key.replace("_", "-")))
		root.remove_child(node)
		node.free()
	print("views: front, quarter, rear, above")
