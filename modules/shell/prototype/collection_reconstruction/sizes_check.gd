## Every registered work's built size beside its catalogue size (#266). For each work a visitor
## can click: the picture (the sheet carrying the work's own image, inside any frame or mat) and
## the whole outer size without its label card, in metres, measured on the built scene along the
## work's own wall (x across, y up, z through), against the museum's dimensions string
## (objects.json for the rooms, image-work/grand-gallery-v4/canvas/works.json for the Hall), read
## as height x width x depth. A framed or matted work is held by its picture, anything else by its
## outer size. A height or width off by more than 3 % or 2 cm, whichever is larger, is a fault;
## depth is listed. A flat stand-in has no third figure, and one lying down is held to the two
## figures in its plane. Where the catalogue does not say which horizontal figure faces the
## visitor, the closer pairing is taken, so a work turned a quarter turn is not caught here; a
## work shown leaning or on edge is flagged though its size may be right.
## A photograph card that records its object's share of the photograph (meta object_fill) is held
## by the object, not by the whole photograph.
## The Hall is measured on the nodes walk4.gd builds from works.json; what a visitor sees there
## is the saved bake of those nodes (gallery_walk4/baked/room.tscn).
## godot --headless --path . --script res://modules/shell/prototype/collection_reconstruction/sizes_check.gd -- out.md
extends SceneTree

const HALL_CATALOGUE := "res://image-work/grand-gallery-v4/canvas/works.json"
const REL := 0.03
const ABS := 0.02
const FLAT := 0.015  # thinner than this is a flat picture of the work, not a measured side


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(960, 640)
	root.add_child(walk)
	for i in 240:
		await process_frame
	if walk._rooms == null and walk._rooms_path != "":
		walk._attach_rooms(walk._rooms_path)
		for settle in 6:
			await process_frame
	var rows: Array = []
	var hall_dims := {}
	for r in JSON.parse_string(FileAccess.get_file_as_string(HALL_CATALOGUE)):
		hall_dims[r.tag] = str(r.dims)
	for thing in walk._paintings:
		for node in walk._vp.get_children():
			if node is Node3D and node.global_position.distance_to(thing.center) < 0.001:
				# Without the shadow, lamp pool and caption plate walk4.gd hangs on each painting.
				var built: Array = node.get_children().filter(func(c: Node) -> bool: return c is MeshInstance3D and c.mesh is ArrayMesh)
				rows.append(row(str(thing.rec.acc), "Grand Gallery", node, built, hall_dims.get(thing.tag, "")))
				break
	for thing in walk._objects:
		var parts: Array = thing.node.find_children("*", "GeometryInstance3D", true, false)
		if thing.node is GeometryInstance3D:
			parts.append(thing.node)
		rows.append(row(str(thing.tag).get_slice("#", 0), walk._plan[thing.room].label, thing.node, parts, str(thing.rec.dimensions)))
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.error > b.error)
	var text := "| # | Work | Room | Kind | Built picture W x H (m) | Built outer W x H x D (m) | Catalogue | dH | dW | dD | Fault |\n|---|---|---|---|---|---|---|---|---|---|---|\n"
	for i in rows.size():
		var r: Dictionary = rows[i]
		text += "| %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n" % [i + 1, r.key, r.room, r.kind, "%.3f x %.3f" % [r.picture.x, r.picture.y] if r.kind == "framed" else "", "%.3f x %.3f x %.3f" % [r.outer.x, r.outer.y, r.outer.z], r.dimensions, off(r, "h"), off(r, "w"), off(r, "d"), r.fault]
	var out := OS.get_cmdline_user_args()
	if not out.is_empty():
		FileAccess.open(out[0], FileAccess.WRITE).store_string(text)
	var count := func(word: String) -> int: return rows.filter(func(r: Dictionary) -> bool: return r.fault == word).size()
	print("SIZES_CHECK ", JSON.stringify({"works": rows.size(), "faults": count.call("FAULT"), "not_comparable": count.call("not comparable")}))
	quit(0)


func texture_file(part: Node) -> String:
	var material = part.get("material_override")
	if material == null:
		return ""
	var texture = material.albedo_texture if material is BaseMaterial3D else material.get_shader_parameter("albedo")
	return texture.resource_path.get_file() if texture is Texture2D else ""


## The parts' size along the node's wall: x across, y up (world), z through, in metres.
func extent(node: Node3D, parts: Array) -> Vector3:
	var across: Vector3 = node.global_transform.basis.x
	var frame := Transform3D(Basis(Vector3.UP, atan2(-across.z, across.x)), node.global_position).affine_inverse()
	var box := AABB()
	for i in parts.size():
		var reach: AABB = (frame * parts[i].global_transform) * parts[i].get_aabb()
		box = reach if i == 0 else box.merge(reach)
	return box.size


## The catalogue's leading metric group in metres, at most three figures; empty when it has none
## or gives only a base.
func catalogue(text: String) -> Array:
	var rx := RegEx.new()
	rx.compile("([0-9.]+(?:[a-z ]*[x×]\\s*[0-9.]+)*)\\s*(cm|mm)?")
	var found := rx.search(text)
	if found == null or text.begins_with("Base"):
		return []
	var unit := 0.001 if found.get_string(2) == "mm" else 0.01
	var numbers: Array = []
	for piece in found.get_string(1).replace("×", "x").split("x"):
		numbers.append(piece.to_float() * unit)
	return numbers.slice(0, 3)


func row(key: String, room: String, node: Node3D, all_parts: Array, dimensions: String) -> Dictionary:
	# A blank label card (0.30 x 0.17 or 0.15 x 0.11 m, untextured) hangs on many works' nodes.
	var parts: Array = all_parts.filter(func(p: Node) -> bool:
		var size: Vector3 = p.get_aabb().size
		var thin: float = minf(size.x, minf(size.y, size.z))
		var long: float = maxf(size.x, maxf(size.y, size.z))
		return texture_file(p) != "" or not ((is_equal_approx(long, 0.30) and thin < 0.005) or (is_equal_approx(long, 0.15) and thin < 0.003)))
	var textured: Array = parts.filter(func(p: Node) -> bool: return texture_file(p) != "")
	var script: Script = node.get_script()
	var sheets: Array = []
	var painted: bool = script != null and script.resource_path.ends_with("painting_asset.gd")
	if textured.is_empty():
		sheets = parts
	elif painted:
		# painting_asset.gd builds the frame first and the canvas last, each from its own texture.
		sheets = textured.filter(func(p: Node) -> bool: return texture_file(p) != texture_file(textured[0]))
	else:
		var plain: Array = textured.filter(func(p: Node) -> bool: return not "frame" in texture_file(p))
		sheets = plain.filter(func(p: Node) -> bool: return key in texture_file(p) or key.replace(".", "") in texture_file(p))
		if sheets.is_empty():
			sheets = plain
	if sheets.is_empty():
		sheets = textured
	var outer := extent(node, parts)
	var picture := extent(node, sheets)
	var sheet: bool = minf(picture.x, minf(picture.y, picture.z)) < FLAT
	var inside: bool = sheet and (maxf(picture.x, picture.z) < maxf(outer.x, outer.z) - 0.01 or picture.y < outer.y - 0.01)
	var kind := "mesh" if node.has_meta("placed_mesh") else "framed" if inside else "single"
	var cat := catalogue(dimensions)
	var lower := dimensions.to_lower()
	var held := outer if kind != "framed" or "frame" in lower else picture
	if node.has_meta("object_fill"):
		# A photograph card (european_east_additions.gd): the object is this share of the slab.
		var fill: Vector2 = node.get_meta("object_fill")
		held = Vector3(held.x * fill.x, held.y * fill.y, held.z) if held.y >= FLAT else Vector3(held.x * fill.x, held.y, held.z * fill.y)
	if texture_file(sheets[0]).begins_with("framed-"):
		kind = "photograph with its frame"
		cat = []  # the sheet is the work in its frame; the catalogue's figure is the work alone
	var pairs := {}  # "h" | "w" | "d" -> [built, catalogue]
	if cat.size() == 1:
		pairs["h" if "height" in lower else "w"] = [held.y if "height" in lower else maxf(held.x, maxf(held.y, held.z)), cat[0]]
	elif cat.size() > 1:
		var level: Array = [held.x, held.z].filter(func(n: float) -> bool: return n >= FLAT)
		if painted and held.y >= FLAT:
			level = [held.x]  # a hung painting_asset.gd slab: its edge is not a measured side
		var wanted: Array = cat.slice(1)
		if held.y < FLAT:
			wanted = cat.slice(-2)  # lying flat: the two figures that lie in the plane
		else:
			pairs["h"] = [held.y, cat[0]]
		if level.size() == 1 or wanted.size() == 1:
			pairs["w"] = [level.max(), wanted[0]]
		elif absf(level[0] - wanted[0]) + absf(level[1] - wanted[1]) <= absf(level[1] - wanted[0]) + absf(level[0] - wanted[1]):
			pairs = pairs.merged({"w": [level[0], wanted[0]], "d": [level[1], wanted[1]]})
		else:
			pairs = pairs.merged({"w": [level[1], wanted[0]], "d": [level[0], wanted[1]]})
	var error := 0.0
	var fault := "not comparable" if pairs.is_empty() else ""
	for side in ["h", "w"]:
		if pairs.has(side):
			error = maxf(error, absf(pairs[side][0] / pairs[side][1] - 1.0))
			if absf(pairs[side][0] - pairs[side][1]) > maxf(ABS, REL * pairs[side][1]):
				fault = "FAULT"
	return {"key": key, "room": room, "kind": kind, "picture": picture, "outer": outer, "dimensions": dimensions, "pairs": pairs, "error": error, "fault": fault}


func off(r: Dictionary, side: String) -> String:
	return "%+.1f %% (%+.3f m)" % [(r.pairs[side][0] / r.pairs[side][1] - 1.0) * 100.0, r.pairs[side][0] - r.pairs[side][1]] if r.pairs.has(side) else ""
