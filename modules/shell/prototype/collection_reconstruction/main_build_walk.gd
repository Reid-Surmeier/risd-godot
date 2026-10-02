## PROTOTYPE (#178, #182): the live Main Hall walk with the reconstructed rooms attached.
## Extends the unchanged gallery_walk4/walk4.gd. Inside the Hall every rule is the parent's:
## its geometry, saved bake, visitor, camera, orbit, finish, _open and detail_changed.
## The authored room scene (remodel_room.tscn running retained_hall_room.gd) is added to the
## parent's viewport and its own Hall copy, visitor, camera, light rig and input are removed.
## Rooms on the portal side share the parent's "arch" space; rooms behind the far door take
## the parent's "far" space, with the obsolete demo tunnel hidden and the Hall visible through
## its doorway. The loop does not yet close in metres. Outside the Hall the visitor is held
## to geometry.json's rooms and openings; there is no physics body.
## Without a room scene in the project this script behaves exactly as walk4.gd.
extends "res://modules/shell/prototype/gallery_walk4/walk4.gd"

# A full-app copy keeps the room project under collection_rooms/; root's own project has it at res://.
const ROOM_SCENES := ["res://collection_rooms/remodel_room.tscn", "res://remodel_room.tscn"]
# The room scene's Hall slot (remodel_room.gd build_connected_hall), as an offset to Hall-local metres.
const ATTACH := Vector3(-5.55, 0, -28.1)
const HALL_ROOM := "Grand Gallery"
# geometry.json rooms reached through the Hall's far door. Every other room hangs off the portal.
const FAR_ROOMS := [
	"Rockefeller",
	"purple elevator-5 connector",
	"grey French gallery",
	"Ionic marble-stair threshold study limit",
	"piano-stair threshold study limit",
	# The thickness of the wall those rooms share with the Hall and the European gallery.
	"Grand Gallery reveal threshold",
	"Rockefeller reveal threshold",
]
# Render layers above the parent's own (1..32 Hall, 64..1024 its far space).
const NEAR_LAYER := 2048
const FAR_LAYER := 4096
const PORTAL_MOUTH := 2.2  # walk4._clamp: where the visitor leaves the stone passage
const PORTAL_SIDE := 2.4  # the portal's stone sides end at 2.09 (Surface004), plus the visitor
# ponytail: clearances tuned to root's 0.22 m capsule trials, not surveyed. Recheck after a room fit.
const WALL_CLEAR := 0.35
const DOOR_CLEAR := 0.25
const BODY_CLEAR := 0.3
const SWAP_DEPTH := 0.3  # how far into the other room group before the space changes
const GRID := 0.25  # click-route search cell, metres
const SIDES := {
	"west": Vector3.LEFT, "east": Vector3.RIGHT, "north": Vector3.FORWARD, "south": Vector3.BACK
}

var _rooms: Node3D
var _plan: Array = []  # {label, b: [x0, x1, z0, z1] Hall-local, openings: {side: [lo, hi]}, far}
var _blocks: Array[Rect2] = []  # furniture, cases, door leaves and floor voids, in x/z
var _walls: Array = []  # {body, box, layers}: what the camera may cut away
var _grid: AStarGrid2D  # click routes; built on the first click that needs one
# Every catalogued work in the added rooms, in walk4's painting-record shape plus
# {object: true, node, room, layers, image}; clicked, approached and opened like a Hall painting.
var _objects: Array = []
var _caption: Label


func _build_test_room() -> void:
	super()
	for path in ROOM_SCENES:
		if ResourceLoader.exists(path):
			_attach_rooms(path)
			return


func _attach_rooms(path: String) -> void:
	var plan = JSON.parse_string(
		FileAccess.get_file_as_string(path.get_base_dir().path_join("geometry.json"))
	)
	if not (plan is Dictionary and plan.has("rooms")):
		push_error("Collection rooms: geometry.json missing beside " + path)
		return
	for area in plan.rooms:
		if area.label == HALL_ROOM:
			continue
		var b: Array = area.bounds
		var openings := {}
		for side in area.openings:
			var shift: float = ATTACH.z if side in ["west", "east"] else ATTACH.x
			openings[side] = [area.openings[side][0] + shift, area.openings[side][1] + shift]
		_plan.append(
			{
				"label": area.label,
				"b": [b[0] + ATTACH.x, b[1] + ATTACH.x, b[2] + ATTACH.z, b[3] + ATTACH.z],
				"openings": openings,
				"far": area.label in FAR_ROOMS
			}
		)
		if area.has("floor_void"):
			var v: Array = area.floor_void
			_blocks.append(Rect2(v[0] + ATTACH.x, v[2] + ATTACH.z, v[1] - v[0], v[3] - v[2]))
	_rooms = load(path).instantiate()
	_rooms.set_meta("main_build_host", true)
	# The room scene builds itself in its own metres (its Hall-footprint tests are absolute),
	# so it enters the tree at the origin and only then moves onto the real Hall.
	_vp.add_child(_rooms)
	_rooms.position = ATTACH
	# walk4 owns the visitor, camera, environment and input.
	_rooms.set_physics_process(false)
	_rooms.set_process(false)
	_rooms.set_process_unhandled_key_input(false)
	var label = _rooms.get("label")
	for own in [
		_rooms.get("camera"),
		_rooms.get("visitor"),
		_rooms.get("body"),
		label.get_parent() if is_instance_valid(label) else null,
		_rooms.get("contact_shadow"),
		_rooms.get_node_or_null("ConnectedHall")  # the room scene's copy of the Hall
	]:
		if is_instance_valid(own):
			own.free()
	var ceilings = _rooms.get("ceiling_details")
	if ceilings is Array:
		for i in range(ceilings.size() - 1, -1, -1):
			if not is_instance_valid(ceilings[i]):
				ceilings.remove_at(i)
	var baked: bool = (_rooms.get("inventory") as Dictionary).has("native_lightmap_users")
	for child in _rooms.get_children():
		if child is WorldEnvironment or (baked and child is DirectionalLight3D):
			child.free()
	if not baked:
		# Draft only: the room scene's unbaked light, kept off the Hall by its cull mask.
		var fill := DirectionalLight3D.new()
		fill.rotation_degrees = Vector3(-35, 150, 0)
		fill.light_energy = 0.45
		fill.light_color = Color("fff0d9")
		_rooms.add_child(fill)
	for item in _rooms.find_children("*", "VisualInstance3D", true, false):
		if item is GeometryInstance3D:
			# load_bake parks baked-over source meshes on layer 2, which is a Hall wall layer here.
			item.layers = 0 if item.layers == 2 else _layers_of(item)
		else:
			item.layers = 1 | 64 | NEAR_LAYER | FAR_LAYER
			if item is Light3D:
				item.light_cull_mask = NEAR_LAYER | FAR_LAYER
	# floor_oak.gdshader clips by world z, and the added floors' limits were authored in the room
	# scene's own metres. Only materials under the room scene move; the Hall's are not touched.
	var floors := {}
	for mesh in _rooms.find_children("*", "MeshInstance3D", true, false):
		var material := mesh.material_override as ShaderMaterial
		if material == null or mesh.mesh == null:
			continue
		if not floors.has(material):
			var limits = material.get_shader_parameter("floor_z_limits")
			floors[material] = limits is Vector2
			if limits is Vector2:
				material.set_shader_parameter("floor_z_limits", limits + Vector2(ATTACH.z, ATTACH.z))
		if floors[material]:
			var clip: Vector2 = material.get_shader_parameter("floor_z_limits")
			var reach: AABB = mesh.global_transform * mesh.mesh.get_aabb()
			assert(
				reach.position.z >= clip.x - 0.01 and reach.end.z <= clip.y + 0.01,
				"Added floor lies outside its clip limits after attachment"
			)
	for body in _rooms.get("casings"):
		if (
			not is_instance_valid(body)
			or body.get_child_count() < 2
			or str(body.get_meta("room_wall", "")).begins_with(HALL_ROOM + ":")
		):
			continue  # the room scene keeps the Hall's walls only as its own collision
		var collider := body.get_child(0) as CollisionShape3D
		var visual := body.get_child(1) as GeometryInstance3D
		if collider == null or visual == null:
			continue
		var shape := collider.shape
		var local := visual.get_aabb()
		if shape is BoxShape3D:
			local = AABB(-shape.size / 2.0, shape.size)
		elif shape is CylinderShape3D:
			local = AABB(
				Vector3(-shape.radius, -shape.height / 2.0, -shape.radius),
				Vector3(shape.radius * 2.0, shape.height, shape.radius * 2.0)
			)
		var box: AABB = body.global_transform * (collider.transform * local)
		var boxes:Array[AABB]=[box]
		# Jambs belong to the header, whose collision box is above the doorway.
		# Test their separate boxes so the empty opening still stays visible head-on.
		if str(body.get_meta("room_wall","")).ends_with(":header"):
			for part in body.get_children():
				if part is MeshInstance3D and part.mesh!=null:
					boxes.append(part.global_transform*part.get_aabb())
		_walls.append({"body": body, "box": box, "boxes":boxes, "layers": _layers_of(visual)})
		if (
			not body.has_meta("room_wall")
			and (shape is BoxShape3D or shape is CylinderShape3D)
			and box.position.y < 1.2
		):
			_blocks.append(Rect2(box.position.x, box.position.z, box.size.x, box.size.z))
	# The parent's white test room shares the far space's layers.
	for child in _vp.get_children():
		if child is MeshInstance3D and child.layers >= 64 and child.layers <= 1024:
			child.hide()
	_collect_objects()
	print("MAIN_BUILD_ROOMS ", JSON.stringify(state()))


## What the checks read: counts only, no behaviour.
func state() -> Dictionary:
	return {
		"attached": _rooms != null,
		"rooms": _plan.size(),
		"blocks": _blocks.size(),
		"cutaway_bodies": _walls.size(),
		"objects": _objects.size(),
		"space": _space
	}


func _collect_objects() -> void:
	# Titles, makers and the picture to show, keyed by accession number or asset name.
	var captions = JSON.parse_string(
		FileAccess.get_file_as_string(ROOM_SCENES[0].get_base_dir().path_join("objects.json"))
	)
	if not captions is Dictionary:
		captions = {}
	var found: Array = []
	for node in _rooms.find_children("*", "Node3D", true, false):
		if not (node.has_meta("catalogue_accession") or node.has_meta("catalogue_asset")):
			continue
		var nested := false
		for other in found:
			nested = nested or other.is_ancestor_of(node)
		if not nested:
			found.append(node)
	for node in found:
		var box := AABB()
		var first := true
		var image: Texture2D = null
		var parts: Array = node.find_children("*", "GeometryInstance3D", true, false)
		if node is GeometryInstance3D:
			parts.append(node)
		for part in parts:
			var reach: AABB = part.global_transform * part.get_aabb()
			box = reach if first else box.merge(reach)
			first = false
			# Unbaked rooms use the PS1 shader; a loaded bake swaps in standard materials.
			var material = part.get("material_override")
			if material != null:
				var texture = (
					material.albedo_texture
					if material is BaseMaterial3D
					else material.get_shader_parameter("albedo")
				)
				if texture is Texture2D and (
					image == null
					or texture.get_width() * texture.get_height() > image.get_width() * image.get_height()
				):
					image = texture
		if first or image == null:
			continue
		var centre := box.get_center()
		var room := _room_at(Vector3(centre.x, 0, centre.z))
		if room < 0:
			continue
		# A work on or against a wall is viewed from the room side; anything else from where
		# the visitor already is (normal stays zero until it is clicked).
		var b: Array = _plan[room].b
		var normal := Vector3.ZERO
		var nearest := 0.45
		for side in SIDES:
			var gap: float = (
				box.position.x - b[0]
				if side == "west"
				else b[1] - box.end.x if side == "east" else box.position.z - b[2] if side == "north" else b[3] - box.end.z
			)
			if gap < nearest:
				nearest = gap
				normal = -SIDES[side]
		var corners := []
		for i in 8:
			corners.append(box.get_endpoint(i))
		var accession := str(node.get_meta("catalogue_accession", ""))
		var key := accession if accession != "" else str(node.get_meta("catalogue_asset", node.name))
		var rec: Dictionary = {"acc": accession, "title": str(node.get_meta("catalogue_title", key))}
		if captions.has(key):
			var row: Dictionary = captions[key]
			rec = {
				"acc": str(row.get("accession", accession)),
				"title": str(row.get("title", rec.title)),
				"artist": ", ".join(
					[str(row.get("maker", "")), str(row.get("date", ""))].filter(
						func(text: String) -> bool: return text != ""
					)
				),
				"medium": str(row.get("medium", ""))
			}
			if ResourceLoader.exists(str(row.get("image", ""))):
				image = load(row.image)
		_objects.append(
			{
				"object": true,
				"tag": "%s#%d" % [key, _objects.size()],
				"rec": rec,
				"node": node,
				"room": room,
				"layers": FAR_LAYER if _plan[room].far else NEAR_LAYER,
				"image": image,
				"center": centre,
				"normal": normal,
				"corners": corners,
				"outer": Vector2(maxf(box.size.x, box.size.z), box.size.y)
			}
		)


func _painting_at(pt: Vector2) -> Dictionary:
	var best: Dictionary = super(pt)
	# Among the works under the pointer the smallest on screen wins: a cup in front of a
	# cabinet, a plate inside a case.
	var smallest := INF
	var here := _room_at(_pos)
	for thing in _objects:
		if thing.room != here or (_cam.cull_mask & thing.layers) == 0:
			continue
		var points := PackedVector2Array()
		for corner in thing.corners:
			if _cam.is_position_behind(corner):
				points.clear()
				break
			points.append(_to_screen(corner))
		if points.size() < 8:
			continue
		var hull := Geometry2D.convex_hull(points)
		var middle := Vector2.ZERO
		for q in hull:
			middle += q / hull.size()
		for i in hull.size():
			hull[i] += (hull[i] - middle).normalized() * 5.0
		var area := 0.0
		for i in hull.size():
			var a: Vector2 = hull[i]
			var c: Vector2 = hull[(i + 1) % hull.size()]
			area += a.x * c.y - c.x * a.y
		area = absf(area) / 2.0
		if area < smallest and Geometry2D.is_point_in_polygon(pt, hull):
			smallest = area
			best = thing
	return best


# An added-room work: walk to the nearest free spot in front of it, face it, open it.
func _approach(p: Dictionary) -> void:
	if not p.has("object"):
		super(p)
		return
	var normal: Vector3 = p.normal
	if normal == Vector3.ZERO:
		normal = Vector3(_pos.x - p.center.x, 0, _pos.z - p.center.z).normalized()
	var reach: float = p.outer.x / 2.0 + clampf(p.outer.y * 1.1, 1.0, 2.6)
	var cell := _cell(Vector3(p.center.x, 0, p.center.z) + normal * reach)
	if not _route_grid().is_in_boundsv(cell):
		return
	var stand := Vector3(cell.x * GRID, 0, cell.y * GRID)
	_route_to(stand)
	var mine := _action
	while _target != null or not _path.is_empty():
		await get_tree().process_frame
		if _action != mine or not _open.is_empty():
			return
	if _pos.distance_to(stand) > 0.6:
		return
	var to := Vector3(p.center.x - _pos.x, 0, p.center.z - _pos.z).normalized()
	_motion_heading = to
	_target_yaw = atan2(-to.x, -to.z)
	while absf(wrapf(_kid.rotation.y - atan2(to.x, to.z), -PI, PI)) > 0.015:
		_kid.pose(get_process_delta_time(), false, 0.0, to, view_yaw if view_mode != 2 else _yaw)
		await get_tree().process_frame
		if _action != mine or not _open.is_empty():
			return
	_open_detail(p)


func _open_detail(p: Dictionary) -> void:
	super(p)
	# The work comes forward instead of snapping on.
	_detail.modulate.a = 0.0
	_zoom_root.pivot_offset = _zoom_root.size / 2.0
	_zoom_root.scale = Vector2(0.92, 0.92)
	var tween := create_tween().set_parallel()
	tween.tween_property(_detail, "modulate:a", 1.0, 0.18)
	tween.tween_property(_zoom_root, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void: _zoom_root.pivot_offset = Vector2.ZERO)


func _fit_detail() -> void:
	if _open.is_empty() or _zoom_root == null:
		return
	if _open.has("object"):
		var pic: TextureRect = _zoom_root.get_node("Painting")
		(_zoom_root.get_node("Frame") as NinePatchRect).visible = false
		var tex: Texture2D = _open.image
		pic.texture = tex
		var aspect := float(tex.get_width()) / tex.get_height()
		var ph := minf(size.y * 0.74, size.x * 0.66 / aspect)
		pic.size = Vector2(ph * aspect, ph)
		pic.position = Vector2.ZERO
		_zoom_root.size = pic.size
		_zoom = 1.0
		_zoom_root.scale = Vector2.ONE
		_zoom_root.position = (size - pic.size) / 2.0
	else:
		super()
	if _caption == null:
		_caption = Label.new()
		_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_caption.add_theme_color_override("font_color", Color("2a2622"))
		_detail.add_child(_caption)
	var rec: Dictionary = _open.rec
	var lines := PackedStringArray([str(rec.get("title", ""))])
	for field in ["artist", "medium"]:
		if str(rec.get(field, "")) != "":
			lines.append(str(rec[field]))
	if str(rec.get("acc", "")) != "":
		lines.append("RISD Museum " + str(rec.acc))
	_caption.text = "\n".join(lines)
	_caption.size = Vector2(size.x, 0)
	# Along the foot of the panel: a framed Hall painting reaches below its own picture.
	_caption.position = Vector2(0, size.y - 22.0 * lines.size() - 12.0)


# A wall belongs to its room; anything else to every room group its footprint reaches.
func _layers_of(item: GeometryInstance3D) -> int:
	var node: Node = item
	while node != null and node != _rooms:
		var wall: String = node.get_meta("room_wall", "")
		if wall != "":
			return FAR_LAYER if wall.get_slice(":", 0) in FAR_ROOMS else NEAR_LAYER
		node = node.get_parent()
	var box: AABB = item.global_transform * item.get_aabb()
	var flat := Rect2(box.position.x, box.position.z, box.size.x, box.size.z)
	var bits := 0
	var nearest := NEAR_LAYER
	var best := INF
	for room in _plan:
		var b: Array = room.b
		var inner := Rect2(b[0], b[2], b[1] - b[0], b[3] - b[2]).grow(-0.2)
		var bit: int = FAR_LAYER if room.far else NEAR_LAYER
		if inner.intersects(flat, true):
			bits |= bit
		var d := inner.get_center().distance_squared_to(flat.get_center())
		if d < best:
			best = d
			nearest = bit
	return bits if bits != 0 else nearest


func _set_lighting(enabled: bool) -> void:
	super(enabled)
	if _rooms == null:
		return
	# The stand-in room behind the portal gives way to the authored medieval room: hidden at
	# runtime, never edited. Everything that reaches past the portal front; the portal stays.
	var hall: Array = _source_meshes.duplicate()
	if _baked_room:
		hall += _baked_room.find_children("*", "MeshInstance3D", true, false)
	var changed := false
	for mesh in hall:
		if not is_instance_valid(mesh) or mesh.mesh == null:
			continue
		var box: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		if box.position.z >= -0.001 and box.end.z > 2.3:
			mesh.hide()
		var floor: ShaderMaterial = mesh.material_override as ShaderMaterial
		if floor != null and floor.get_shader_parameter("floor_z_limits") is Vector2:
			continue # Native planks are already clipped per pixel; keep whole plank quads.
		if box.position.z < -L - 0.19 and not mesh.has_meta("far_fixture_clipped"):
			# 6380 100/107s shows the open grey/Hall connection. Remove only the old
			# demo's geometry beyond the Hall plane; keep Hall-side trim and native UV2.
			var clipped := ArrayMesh.new()
			clipped.lightmap_size_hint = mesh.mesh.lightmap_size_hint
			var removed := 0
			for surface in mesh.mesh.get_surface_count():
				var arrays: Array = mesh.mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(vertices.size()))
				if indices.is_empty():
					indices = PackedInt32Array(range(vertices.size()))
				var kept := PackedInt32Array()
				for i in range(0, indices.size(), 3):
					var triangle := indices.slice(i, i + 3)
					var outside := false
					for vertex in triangle:
						outside = outside or (mesh.global_transform * vertices[vertex]).z < -L - 0.19
					if outside:
						removed += 1
					else:
						kept.append_array(triangle)
				if kept.is_empty():
					continue
				arrays[Mesh.ARRAY_INDEX] = kept
				clipped.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
				clipped.surface_set_material(clipped.get_surface_count() - 1, mesh.mesh.surface_get_material(surface))
			mesh.mesh = clipped
			mesh.set_meta("far_fixture_clipped", removed)
			changed = true
	if changed and _baked_room:
		# A changed mesh loses its renderer lightmap binding. Reassign the saved users.
		var lightmap = _baked_room.get_node("Lightmap")
		var saved = lightmap.light_data
		lightmap.light_data = null
		lightmap.light_data = saved


func _enter_space(next: String) -> void:
	if _rooms == null:
		super(next)
		return
	var previous := _space
	# walk4 sends any "arch" visitor with z < 0 back into the Hall. Outside the stone passage
	# that is the long west gallery, not the Hall.
	if previous == "arch" and next == "gallery" and absf(_pos.x) > DOORS.arch.size.x / 2.0:
		return
	if (previous in ["gallery", "far"] and next in ["gallery", "far"]) or (previous in ["arch", "far"] and next in ["arch", "far"]):
		# Added-room doorways are contiguous, unlike walk4's separate test rooms.
		# Keep position, camera heading and held input when crossing either way.
		_space = next
		get_node("OtherWall").visible = next == "gallery"
		for node in _vp.get_children():
			if node is WorldEnvironment:
				node.environment.background_color = Color("#20242a")
				node.environment.ambient_light_energy = 0.6 if next != "far" and not _baked_lighting else 0.0
		_update_camera(1.0)
		print("NAV_SPACE ", previous, " -> ", next)
		return
	super(next)
	_update_camera(1.0)


func _process(delta: float) -> void:
	super(delta)
	if _rooms == null or not _open.is_empty() or _entrance_active:
		return
	if _space == "far" and _pos.z > -L and absf(_pos.x) < DOORS.far.size.x / 2.0:
		_enter_space("gallery")  # out through the grey gallery's Hall door
	elif _space == "arch" or _space == "far":
		var here := _room_at(_pos)
		if (
			here >= 0
			and _plan[here].far != (_space == "far")
			and _depth(here, _pos) >= SWAP_DEPTH
		):
			_enter_space("far" if _plan[here].far else "arch")


# A floor target in the adjoining room uses the real doorway, then the Hall's own bench planner.
# ponytail: only the evidenced Hall/grey-gallery connection; other rooms still use their existing planner.
func _walk_to(p: Vector3) -> void:
	if _rooms == null:
		super(p)
		return
	var from_hall := _space == "gallery" and p.z < -L
	var to_hall := _space == "far" and p.z > -L and p.z <= 0.0 and absf(p.x) <= W / 2.0
	var grey := _room_at(p if from_hall else _pos)
	if _space not in ["gallery", "far"] or (not from_hall and not to_hall) or grey < 0 or _plan[grey].label not in ["grey French gallery", "Grand Gallery reveal threshold"]:
		# Inside the Hall the parent's bench planner stands. Anywhere else a click is routed
		# round cases, benches and walls, and through as many doorways as it takes.
		if _space == "gallery" and _room_at(p) < 0 and p.z <= 0.0 and p.z >= -L:
			super(p)
		else:
			_route_to(p)
		return
	var hall_entry := Vector3(0, 0, -L + .6)
	var grey_entry := Vector3(0, 0, -L - 1.25)
	# A visitor or target already inside the passage need not walk back out of it.
	var near: Vector3 = _pos if from_hall else p
	if absf(near.x) <= .4 and near.z < hall_entry.z:
		hall_entry = Vector3(near.x, 0, near.z)
	near = p if from_hall else _pos
	if absf(near.x) <= .4 and near.z > grey_entry.z:
		grey_entry = Vector3(near.x, 0, near.z)
	if from_hall:
		if not _walkable(p):
			_route_to(p)
			return
		super(hall_entry)
		_path.append(_target)
		_path.append(grey_entry)
		_target = Vector3(p.x, 0, p.z)
	else:
		# Plan the Hall leg from its doorway without changing the visitor's actual position or camera.
		var previous := _pos
		_pos = hall_entry
		_space = "gallery"
		super(p)
		_space = "far"
		_pos = previous
		_path.push_front(hall_entry)
		_path.push_front(grey_entry)


# Where a visitor may stand anywhere in the museum: walk4's Hall margins, benches and two
# doorways, then the added rooms' own rule.
func _free(p: Vector3) -> bool:
	if absf(p.x) <= W / 2.0 - 0.55 and p.z <= -0.55 and p.z >= -L + 0.55:
		for bz in BENCHES:
			if absf(p.x) < BENCH_CLEAR.x and absf(p.z - bz) < BENCH_CLEAR.y:
				return false
		return true
	if absf(p.x) <= 0.4 and (
		(p.z > -0.55 and p.z < PORTAL_MOUTH) or (p.z > -L - WALL_CLEAR and p.z < -L + 0.55)
	):
		return true
	return _walkable(p)


func _route_grid() -> AStarGrid2D:
	if _grid != null:
		return _grid
	var reach := Rect2(-W / 2.0, -L, W, L + PORTAL_MOUTH)
	for room in _plan:
		reach = reach.merge(Rect2(room.b[0], room.b[2], room.b[1] - room.b[0], room.b[3] - room.b[2]))
	_grid = AStarGrid2D.new()
	_grid.cell_size = Vector2(GRID, GRID)
	_grid.region = Rect2i(
		Vector2i((reach.position / GRID).floor()), Vector2i((reach.size / GRID).ceil()) + Vector2i.ONE
	)
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_grid.update()
	for x in range(_grid.region.position.x, _grid.region.end.x):
		for z in range(_grid.region.position.y, _grid.region.end.y):
			if not _free(Vector3(x * GRID, 0, z * GRID)):
				_grid.set_point_solid(Vector2i(x, z))
	return _grid


# The free grid cell nearest p; one outside the grid when there is none within 2 m.
func _cell(p: Vector3) -> Vector2i:
	var grid := _route_grid()
	var home := Vector2i(roundi(p.x / GRID), roundi(p.z / GRID))
	var best := Vector2i(-9999, -9999)
	var nearest := INF
	for dx in range(-8, 9):
		for dz in range(-8, 9):
			var id := home + Vector2i(dx, dz)
			if not grid.is_in_boundsv(id) or grid.is_point_solid(id):
				continue
			var d := Vector2(id.x * GRID - p.x, id.y * GRID - p.z).length_squared()
			if d < nearest:
				nearest = d
				best = id
	return best


func _clear_line(a: Vector3, b: Vector3) -> bool:
	var steps := maxi(1, ceili(a.distance_to(b) / 0.1))
	for i in steps + 1:
		if not _free(a.lerp(b, float(i) / steps)):
			return false
	return true


func _route_to(p: Vector3) -> void:
	_velocity = Vector3.ZERO
	_new_action()
	_target = null
	var from := _cell(_pos)
	var to := _cell(p)
	var grid := _route_grid()
	if not grid.is_in_boundsv(from) or not grid.is_in_boundsv(to):
		return  # a click on nothing reachable: stay
	var points: Array = [Vector3(_pos.x, 0, _pos.z)]
	for cell in grid.get_point_path(from, to):
		points.append(Vector3(cell.x, 0, cell.y))
	if points.size() < 2:
		return
	if _free(Vector3(p.x, 0, p.z)):
		points.append(Vector3(p.x, 0, p.z))
	# Straighten the grid's staircase: keep only the corners the walls force.
	var pulled: Array = []
	var anchor := 0
	while anchor < points.size() - 1:
		var next := points.size() - 1
		while next > anchor + 1 and not _clear_line(points[anchor], points[next]):
			next -= 1
		pulled.append(points[next])
		anchor = next
	_target = pulled.pop_back()
	_path = pulled


# Inside the Hall and its stone passage: the parent's rule, untouched. Outside: the room plan.
func _clamp(p: Vector3) -> Vector3:
	if _rooms == null:
		return super(p)
	# A tap/click can target the other side before the per-frame step changes space.
	# Validate that target through the same doorway, rather than an obsolete room box.
	if _space in ["gallery", "far"] and (_pos.z + L) * (p.z + L) < 0.0:
		var cross_x := lerpf(_pos.x, p.x, (-L - _pos.z) / (p.z - _pos.z))
		if absf(cross_x) <= .4:
			if _space == "gallery":
				return _slide(p)
			# Reuse the Hall's own walls and benches. This synchronous call has no input or camera work.
			if p.z < -L + .55:
				p.x = clampf(p.x, -.399, .399)
			_space = "gallery"
			var target: Vector3 = super(p)
			_space = "far"
			return target
	if _space == "gallery":
		# Keep lateral movement inside the doorway until clear of the north jambs.
		# Otherwise walk4's wide-room clamp jumps z forward by its 0.55m wall margin.
		if _pos.z < -L + .55 and absf(_pos.x) <= .4 and p.z < -L + .55:
			# A Vector3 rounds .4 above the parent's exact .4 doorway test.
			p.x=clampf(p.x,-.399,.399)
		return super(p)
	p.y = 0.0
	if _space == "arch":
		if _pos.z < PORTAL_MOUTH and absf(_pos.x) <= DOORS.arch.size.x / 2.0:
			var q: Vector3 = super(p)
			return q if q.z < PORTAL_MOUTH else _slide(q)
		if p.z < PORTAL_MOUTH and absf(_pos.x) < PORTAL_SIDE and _pos.z >= PORTAL_MOUTH:
			var cross_x := lerpf(_pos.x, p.x, (PORTAL_MOUTH - _pos.z) / (p.z - _pos.z))
			if absf(cross_x) <= 0.4:
				return super(p)
	return _slide(p)


func _slide(p: Vector3) -> Vector3:
	var from := Vector3(_pos.x, 0, _pos.z)
	if not _walkable(from):
		return _into_room(p)
	if _walkable(p):
		return p
	if from.distance_to(p) > STEP_M + 0.01:
		return _into_room(p)  # a clicked point: the nearest place in a room, or stay
	for q in [Vector3(p.x, 0, from.z), Vector3(from.x, 0, p.z)]:
		if _walkable(q):
			return q
	return from


func _into_room(p: Vector3) -> Vector3:
	var nearest := Vector3(_pos.x, 0, _pos.z)
	var best := INF
	for room in _plan:
		var b: Array = room.b
		var c := Vector3(
			clampf(p.x, b[0] + WALL_CLEAR, b[1] - WALL_CLEAR),
			0,
			clampf(p.z, b[2] + WALL_CLEAR, b[3] - WALL_CLEAR)
		)
		var d := c.distance_squared_to(p)
		if d < best and _walkable(c):
			best = d
			nearest = c
	return nearest


func _depth(index: int, p: Vector3) -> float:
	var b: Array = _plan[index].b
	return minf(minf(p.x - b[0], b[1] - p.x), minf(p.z - b[2], b[3] - p.z))


# The added room that holds p, or -1 in the Hall, the stone passage or a wall.
func _room_at(p: Vector3) -> int:
	var found := -1
	var deepest := -INF
	for i in _plan.size():
		var d := _depth(i, p)
		if d >= 0.0 and d > deepest:
			found = i
			deepest = d
	return found


func _walkable(p: Vector3) -> bool:
	# The grey gallery's Hall door, as walk4's own doorway strip.
	if _space in ["gallery", "far"] and absf(p.x) <= 0.4 and p.z > -L - WALL_CLEAR and p.z <= -L + .55:
		return true
	# The portal and the ground between its stone sides are the parent's.
	if absf(p.x) < PORTAL_SIDE and p.z > -L and p.z < PORTAL_MOUTH:
		return false
	var index := _room_at(p)
	if index < 0:
		return false
	var b: Array = _plan[index].b
	for side in SIDES:
		var gap: float = (
			p.x - b[0]
			if side == "west"
			else b[1] - p.x if side == "east" else p.z - b[2] if side == "north" else b[3] - p.z
		)
		if gap >= WALL_CLEAR:
			continue
		# This close to a wall is only a doorway that leads into another added room.
		var door: Array = _plan[index].openings.get(side, [])
		var along := p.z if side in ["west", "east"] else p.x
		if door.is_empty() or along < door[0] + DOOR_CLEAR or along > door[1] - DOOR_CLEAR:
			return false
		if _room_at(p + SIDES[side] * (gap + WALL_CLEAR + 0.05)) < 0:
			return false
	for block in _blocks:
		if block.grow(BODY_CLEAR).has_point(Vector2(p.x, p.z)):
			return false
	return true


func _update_camera(k: float) -> void:
	super(k)
	if _rooms == null:
		return
	var added := _room_at(_pos) >= 0
	if _baked_room:
		_baked_room.get_node("Lightmap").visible = not added
	var capture := _rooms.get_node_or_null("BakedRoom/Lightmap")
	if capture:
		capture.visible = added
	if _white_capture:
		_white_capture.visible = false # The attached rooms carry their own native probe field.
	if view_mode == 2 and _room_at(_pos) >= 0:
		# walk4's follow camera is boxed into its stand-in rooms; in an added room it just follows.
		var forward := _fwd()
		_cam.fov = 58.0
		_cam.position = _pos - forward * 3.1 + Vector3(0, 2.45, 0)
		_cam.look_at(_pos + forward * 2.0 + Vector3(0, 1.1, 0))
	var shown: int = NEAR_LAYER | FAR_LAYER # Both adjoining room interiors are visible through their doors.
	_cam.cull_mask |= shown
	var here := _room_at(_pos)
	if _space == "gallery":
		_cam.cull_mask |= FAR_LAYER
	elif _space == "far" and here >= 0:
		# The parent's far-space rule leaves the Hall's last wall fade untouched.
		_cutaway_alpha[8] = 1.0
		for entry in _cutaway_materials.get(8, []):
			entry.mesh.material_override = entry.original
		if _portal_floor_material:
			_portal_floor_material.set_shader_parameter("cutaway", 0.0)
		var toward := _fwd() if view_mode == 2 else Vector3(-sin(view_yaw), 0, -cos(view_yaw))
		var hidden := (4 if toward.x < -0.2 else 2 if toward.x > 0.2 else 0) | (16 if toward.z < -0.2 else 0)
		_cam.cull_mask |= 63 if view_mode == 2 else 31 & ~hidden
	# Same intent as the room scene's ray test, without physics: a body that stands between the
	# camera and the visitor loses its visual, and its trim goes with it.
	var eye := _cam.global_position
	var across := _cam.global_transform.basis.x
	across.y = 0.0
	for wall in _walls:
		var clear := true
		if wall.layers & shown:
			for offset in [-0.45, 0.0, 0.45]:
				for height in [0.5, 1.5]:
					var subject: Vector3 = _pos + across * offset + Vector3(0, height, 0)
					for section in wall.boxes:
						if (section as AABB).intersects_segment(eye, subject) != null:
							clear = false
		var body: Node = wall.body
		for i in range(1, body.get_child_count()):
			body.get_child(i).visible = clear
	# The room scene's own rule for ceilings and baked copies, read from walk4's camera.
	if _rooms.has_method("update_baked_visibility"):
		_rooms.set("camera", _cam)
		_rooms.update_baked_visibility()
