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

# A full-app copy keeps the room project under modules/shell/collection_rooms/; root's own project has it at res://.
const ROOM_SCENES := ["res://modules/shell/collection_rooms/remodel_room.tscn", "res://remodel_room.tscn"]
# The room scene's Hall slot (remodel_room.gd build_connected_hall), as an offset to Hall-local metres.
const ATTACH := Vector3(-5.55, 0, -28.1)
const HALL_ROOM := "Grand Gallery"
# geometry.json rooms reached through the Hall's far door. Every other room hangs off the portal.
const FAR_ROOMS := [
	"Rockefeller",
	"purple elevator-5 connector",
	"grey French gallery",
	"marble stair hall",
	"Impressionist passage",
	"Impressionist passage return",
	"Impressionist gallery A",
	"Impressionist gallery B",
	"Skylight Gallery",
	"Skylight Gallery reveal threshold",
	# The thickness of the wall those rooms share with the Hall and the European gallery.
	"Grand Gallery reveal threshold",
	"Rockefeller reveal threshold",
]
# Render layers above the parent's own (1..32 Hall, 64..1024 its far space).
const NEAR_LAYER := 2048
const FAR_LAYER := 4096
const VISITOR_LAYER := 1 << 19  # visitor.gd's own layer (its FILL_LAYER)
# PORTAL_MOUTH, where the visitor leaves the stone passage, is walk4's own constant.
const PORTAL_SIDE := 2.4  # in x: the stone's sides end at 2.09 (Surface004), plus the visitor
# ponytail: clearances tuned to root's 0.22 m capsule trials, not surveyed. Recheck after a room fit.
const WALL_CLEAR := 0.35
const DOOR_CLEAR := 0.25
const LENS_CLEAR := 0.25  # the follow lens this near a wall of the visitor's room: the wall goes
const BODY_CLEAR := 0.3
const SWAP_DEPTH := 0.3  # how far into the other room group before the space changes
const GRID := 0.25  # click-route search cell, metres
# The lowest wall top in geometry.json's rooms: a sight line above it at a stage's edge has gone
# over a wall, not through a door (no door head is higher except the portal's, which is walk4's).
const DOOR_TOP := 3.5
const CROWD := 0.08  # the most of an inspection picture the visitor's body may take
const SIDES := {
	"west": Vector3.LEFT, "east": Vector3.RIGHT, "north": Vector3.FORWARD, "south": Vector3.BACK
}

var _rooms: Node3D
var _plan: Array = []  # {label, b: [x0, x1, z0, z1] Hall-local, openings: {side: [lo, hi]}, far}
var _blocks: Array[Rect2] = []  # furniture, cases, door leaves and floor voids, in x/z
var _skylight_surfaces: Array = []  # #275: the same landing / ramps / lower-floor patches as the built room
var _skylight_structure: Array = []  # #275: decks / treads that can cover the lower visitor
var _skylight_hidden_decks: Array[String] = []
var _walls: Array = []  # {body, box, boxes, layers, room, side}: what the camera may cut away
var _parts: Array = []  # {node, room, side, shown}: everything else in the rooms; side set if it hangs on a wall
var _cut_state := 0
var _grid: AStarGrid2D  # click routes; built on the first click that needs one
# Every catalogued work in the added rooms, in walk4's painting-record shape plus
# {object: true, node, room, layers, image}; clicked, approached and opened like a Hall painting.
var _objects: Array = []
var _caption: Label
# Looking at a work in the room, as the New Horizons museum does: the camera glides to a low
# shot behind the visitor and a text panel pages through the catalogue entry. A second click
# on the work opens walk4's zoom page.
var _inspect := {}
var _inspect_t := 0.0  # 0 the walking view, 1 the inspection shot
var _inspect_page := 0
var _inspect_tween: Tween
var _inspect_panel: PanelContainer
var _inspect_from = null  # the last inspection shot, held while the camera glides back
var _inspect_fov := 23.0
var _glide_from := Transform3D()
var _glide_fov := 23.0
var _glide_t := 1.0  # 0 the camera before a view change, 1 the new view
var _hovering := false  # _painting_at is being asked by the hover cursor, not by a click
# PROTOTYPE (#260): one stage is drawn at a time and a doorway changes it under a round wipe,
# timed from docs/research/2026-10-08-acnh-room-change-and-landing.md. A stage is one area of
# geometry.json plus the wall thicknesses and stubs JOINED to it; the Hall is stage -1.
const WIPE_CLOSE := 1.333  # radius 1.19 half-diagonals -> 0; the last 0.93 s is on screen
const WIPE_HOLD := 0.5
const WIPE_OPEN := 0.889
const WIPE_BACK := 0.6  # into the opening, the keys come back
const WIPE_RADIUS := 1.19
# What lies beyond the stage (fog doorways): never black. One warm umber for the whole museum,
# VOID_NEAR where the ground meets the room and VOID far off, which is also the background.
const VOID := Color(0.145, 0.097, 0.064)
const VOID_NEAR := Color(0.27, 0.18, 0.115)
const VOID_FALL := 3.2  # metres from the stage over which the ground loses most of its warmth
const VOID_LAYER := 16384  # the ground beyond the stage and the doorways' light: drawn in every stage
# The ground beyond the stage, shared by everything that has to meet it without a seam. An
# unshaded surface's colour reaches the screen as it is written (measured: 0.2 in, 0.196 out,
# with the darkest twentieth crushed), so colours are mixed as the screen shows them, and
# dithered: a dark gradient this wide bands otherwise.
const VOID_GLSL := """
uniform vec4 rooms[8]; // the stage's areas: centre x, z and half sizes
uniform int room_count = 0;
uniform vec3 void_near;
uniform vec3 void_far;
uniform float void_fall = 3.2;
varying vec3 world;
float outside(vec2 p) {
	float d = 1.0e6;
	for (int i = 0; i < room_count; i++) {
		d = min(d, length(max(abs(p - rooms[i].xy) - rooms[i].zw, vec2(0.0))));
	}
	return d;
}
vec3 ground(vec2 p) {
	return mix(void_far, void_near, exp(-outside(p) / void_fall));
}
vec3 dither(vec2 pixel) {
	return vec3(fract(sin(dot(pixel, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0 / 255.0;
}
"""
const PORTAL_LAYER := 8192  # the stone portal stands in the medieval room but is the Hall's mesh
const PORTAL_ROOM := "dark medieval room"
const NO_STAGE := -2
const JOINED := {
	"Grand Gallery reveal threshold": "grey French gallery",
	"purple elevator-5 connector": "grey French gallery",
	"marble stair hall": "grey French gallery",  # open to it along its whole side
	"Rockefeller reveal threshold": "Rockefeller",
	"Skylight Gallery reveal threshold": "Skylight Gallery",
	"white sculpture gallery threshold study limit": "lion stair landing",
	"Impressionist passage": "Impressionist gallery A",
	"Impressionist passage return": "Impressionist gallery A",
}
# A doorway onto another stage shows that stage's light through haze, not the void: unshaded
# gradient geometry beyond the opening, seen only through the opening itself, and a fan of the
# same light on this stage's floor. No bake, no texture.
const DOOR_GLOW := Color(1.0, 0.74, 0.46)  # the light at the sill
# The room change closes to the doorways' haze. Kept clear of the void's own two colours, so the
# doors pass (museum_playtest.gd _void_share) never reads the wipe as the outside of a room.
const WIPE_VEIL := Color(0.78, 0.57, 0.36)
const WIPE_HEART := Color(0.46, 0.32, 0.2)
const WIPE_RIM := Color(0.33, 0.225, 0.14)
const WALL_SHADE := 0.13  # what a wall the bake left unlit still shows of its own colour
var _doors: Array = []  # {stage, node, at, header, hall_layer}: one per doorway onto another stage
var _stage := NO_STAGE  # the stage drawn
var _stage_ids: Array[int] = []  # _plan index -> its stage
var _stage_pos := Vector3.ZERO  # the visitor at the last camera update; a jump means it was placed
var _floor_mask: MeshInstance3D
var _floor_mask_stage := NO_STAGE
var _wipe: ColorRect
var _wipe_t := -1.0  # seconds into a change; negative when none is under way
var _wipe_dir := Vector3.ZERO
var _wipe_cam := Transform3D()  # the view held while the wipe closes
var _wipe_fov := 23.0
var _wipe_mask := 0
var _seen_cam := Transform3D()  # the last view drawn
var _seen_fov := 23.0
var _seen_mask := 0
var _wipe_fill := 0.65
var _wipe_fade: Tween
var _rooms_path := ""  # the room scene still to be built; empty once it is, or when there is none
var _wipe_space := ""  # the space the first doorway leads to, entered once the rooms exist
var _wipe_wait := 0
var _wipe_mark: Control
var _wipe_spin := 0.0  # the mark turns a little between one build step and the next
# The rooms build themselves a step at a time (#281): remodel_room.gd waits at each "build_gate"
# for this signal. Steps run while the visitor stands still in the Hall, and in the black of
# the wipe if a doorway is reached first.
signal build_gate
const ROOMS_AT_LAUNCH := true  # the fallback: the whole museum behind the loading screen
const BUILD_AFTER := 2.0  # seconds the Hall is on screen before the rooms begin
const BUILD_SHARE_MS := 60  # short steps share one frame up to this long
const ARRIVAL_WALL := 6.0  # metres: a wall further off than this shows no works in the picture
# The rooms' baked scene is 11.6 MB of text and the one step that cannot be cut up: 2 s in the
# engine. Read behind the loading screen, it is already in memory when the build asks for it.
const BAKE_AT_LAUNCH := false
var _bake_held: Resource
var _building: Node3D  # the room scene while it builds; hidden between steps
var _build_clock := 0.0
var _build_ms := 0  # what the steps have cost so far, and the longest of them
# Each area is drawn once, small and out of sight, after the rooms are in place: the first
# drawing of a room compiles its shaders, and that was one long frame as the first room opened.
var _warm_left: Array = []
var _warm_vp: SubViewport
var _warm_cam: Camera3D
var _wipe_warm := 0  # frames the wipe has been drawn at launch
var _build_longest := 0
var _wipe_routed := false  # the change began on a clicked route, which keeps its own destination


# The launch reads only the plan (#281). The room scene itself, half the launch's work, is
# built the first time the visitor leaves the Hall, behind the room-change wipe's black.
func _build_test_room() -> void:
	super()
	for path in ROOM_SCENES:
		if ResourceLoader.exists(path):
			if _read_plan(path):
				_rooms_path = path
				_build_stages()
				# Headless nothing is drawn and there is no first picture to hurry: the checks
				# that run there get the whole museum at once, as before.
				if DisplayServer.get_name() == "headless" or ROOMS_AT_LAUNCH:
					_attach_rooms(path)
				elif BAKE_AT_LAUNCH:
					var bake: String = str(path).get_base_dir().path_join("addition_baked/room.tscn")
					if ResourceLoader.exists(bake):
						_bake_held = load(bake)
			return


func _read_plan(path: String) -> bool:
	var plan = JSON.parse_string(
		FileAccess.get_file_as_string(path.get_base_dir().path_join("geometry.json"))
	)
	if not (plan is Dictionary and plan.has("rooms")):
		push_error("Collection rooms: geometry.json missing beside " + path)
		return false
	for area in plan.rooms:
		if area.label == HALL_ROOM:
			continue
		var b: Array = area.bounds
		var openings := {}
		var heads := {}  # how high each doorway is clear, by remodel_room.gd build_rooms' own rule
		for side in area.openings:
			var shift: float = ATTACH.z if side in ["west", "east"] else ATTACH.x
			openings[side] = [area.openings[side][0] + shift, area.openings[side][1] + shift]
			var stone: bool = side in area.get("stone_sides", [])
			heads[side] = float(
				area.get("clear_heights", {}).get(
					side, ((3.342 if side in ["west", "east"] else 3.861) if stone else 2.74)
				)
			)
		_plan.append(
			{
				"label": area.label,
				"b": [b[0] + ATTACH.x, b[1] + ATTACH.x, b[2] + ATTACH.z, b[3] + ATTACH.z],
				"openings": openings,
				"heads": heads,
				"far": area.label in FAR_ROOMS
			}
		)
		if area.has("floor_void"):
			# #276: the lion stair's west landing ear leaves two rectangular voids.
			var holes: Array = area.get("floor_voids", [area.floor_void])
			for v: Array in holes:
				_blocks.append(Rect2(v[0] + ATTACH.x, v[2] + ATTACH.z, v[1] - v[0], v[3] - v[2]))
	# #275 only: floor height follows the built collision patches. Rails keep the
	# planner on the three runs; there is no straight shortcut off the landing.
	for patch in plan.get("skylight_walk", {}).get("surfaces", []):
		var vertices: Array = patch.vertices.map(func(v): return Vector3(v[0], v[1], v[2]) + ATTACH)
		var a: Vector3 = vertices[0]
		var normal: Vector3 = (vertices[1] - a).cross(vertices[3] - a)
		var rect := Rect2(a.x, a.z, 0, 0)
		for vertex in vertices:
			rect = rect.expand(Vector2(vertex.x, vertex.z))
		_skylight_surfaces.append({"b": rect, "at": a, "normal": normal, "label": patch.label})
	for guard in plan.get("skylight_walk", {}).get("guards", []):
		var a: Array = guard.ends[0]
		var b: Array = guard.ends[1]
		_blocks.append(Rect2(minf(a[0], b[0]) + ATTACH.x - .025, minf(a[2], b[2]) + ATTACH.z - .025, absf(b[0] - a[0]) + .05, absf(b[2] - a[2]) + .05))
	return true


func _skylight_height(p: Vector3) -> float:
	var height := -INF
	for patch in _skylight_surfaces:
		if patch.b.grow(.001).has_point(Vector2(p.x, p.z)):
			var n: Vector3 = patch.normal
			var a: Vector3 = patch.at
			height = maxf(height, a.y - (n.x * (p.x - a.x) + n.z * (p.z - a.z)) / n.y)
	return height


func _skylight_step(p: Vector3) -> Vector3:
	var height := _skylight_height(p)
	if height == -INF:
		return p
	# A floor or ramp supports each step. An edge a storey above the next patch
	# cannot be crossed by keys, a click route or a jump animation.
	if absf(height - _pos.y) > .30 and Vector2(p.x - _pos.x, p.z - _pos.z).length() < .50:
		return _pos
	p.y = height
	return p


## The rooms, whole, before this returns: for the checks, for a visitor put straight into a
## room, and for the launch when ROOMS_AT_LAUNCH. A build already under way is finished.
func _attach_rooms(path: String) -> void:
	var began := Time.get_ticks_msec()
	if _building == null:
		_building = load(path).instantiate()
		_building.set_meta("main_build_host", true)
		_vp.add_child(_building)  # no gate: built in this one call
	else:
		_building.visible = true
		while not _building.has_meta("build_done"):
			build_gate.emit()
	_build_ms += Time.get_ticks_msec() - began
	_install_rooms()


# The first step of a build in steps. Between steps the half-built scene is hidden, so none of
# it is seen from the Hall; it is shown again while a step runs, because the builders ask what
# is visible. (A viewport of its own made every step slower: 13.7 s in all against 9.9 s.)
func _begin_rooms() -> void:
	var began := Time.get_ticks_msec()
	_building = load(_rooms_path).instantiate()
	_building.set_meta("main_build_host", true)
	_building.set_meta("build_gate", build_gate)
	_vp.add_child(_building)  # runs as far as the first gate
	# The room scene makes its own camera the picture's as it enters the tree. Built in one
	# call that camera is freed before a frame is drawn; built in steps it showed the Hall as
	# black with the visitor huge for as long as the build lasted.
	_cam.make_current()
	_building.set_physics_process(false)
	_building.set_process(false)
	_building.set_process_unhandled_key_input(false)
	# Its sky would compete with the Hall's for as long as the build lasts.
	for child in _building.get_children():
		if child is WorldEnvironment:
			child.free()
	_building.visible = false
	_build_ms += Time.get_ticks_msec() - began
	_build_longest = Time.get_ticks_msec() - began


# More steps, until one has taken the frame's share; then the rooms are put in place.
# `shown` leaves the scene visible afterwards: under the wipe's black there is nothing to hide,
# and showing and hiding this many nodes costs a third again on top of the build.
func _pump_rooms(share_ms: int, shown := false) -> void:
	var began := Time.get_ticks_msec()
	_building.visible = true
	while true:
		if _building.has_meta("build_done"):
			_build_ms += Time.get_ticks_msec() - began
			_install_rooms()
			return
		var step := Time.get_ticks_msec()
		build_gate.emit()
		_build_longest = maxi(_build_longest, Time.get_ticks_msec() - step)
		if Time.get_ticks_msec() - began >= share_ms:
			break
	_building.visible = shown
	_build_ms += Time.get_ticks_msec() - began


# Not walking, not on a route, not turning the view: a hitch now is least seen.
func _standing_still() -> bool:
	return (
		_held.is_empty()
		and _target == null
		and _path.is_empty()
		and _velocity.length() < 0.01
		and absf(_view_turn_remaining) < 0.001
		and not _orbit_dragged
		and not _entrance_active
		and _glide_t >= 1.0
	)


# One area drawn once, from above, into a viewport nobody sees; or with `all`, every area
# still owed in the one draw.
func _warm_step(all := false) -> void:
	if _warm_vp == null:
		_warm_vp = SubViewport.new()
		_warm_vp.size = Vector2i(64, 64)
		_warm_vp.world_3d = _vp.find_world_3d()
		_warm_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		add_child(_warm_vp)
		_warm_cam = Camera3D.new()
		_warm_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		_warm_cam.cull_mask = NEAR_LAYER | FAR_LAYER | VISITOR_LAYER
		_warm_cam.near = 0.5
		_warm_cam.far = 80.0
		_warm_cam.rotation_degrees = Vector3(-90, 0, 0)
		_warm_vp.add_child(_warm_cam)
	# A room is drawn with its light map on, and the Hall with its own: a mesh's shader is
	# compiled again for the light map, so a draw without it warmed nothing.
	var capture := _rooms.get_node_or_null("BakedRoom/Lightmap")
	if capture:
		capture.visible = true
	# The visitor's lamp too, as _mask_floor leaves it: with a sun in the picture every mesh
	# has a different shader again.
	var fill = _kid.get("_fill")
	if fill is Light3D:
		fill.layers |= VISITOR_LAYER
	var area := _room_rect(_warm_left.pop_back())
	if all:
		for index in _warm_left:
			area = area.merge(_room_rect(index))
		_warm_left.clear()
	_warm_cam.size = maxf(area.size.x, area.size.y) + 2.0
	_warm_cam.position = Vector3(area.get_center().x, 40.0, area.get_center().y)
	_warm_vp.render_target_update_mode = SubViewport.UPDATE_ONCE


func _install_rooms() -> void:
	var began := Time.get_ticks_msec()
	_rooms_path = ""
	_rooms = _building
	_building = null
	# The room scene builds itself in its own metres (its Hall-footprint tests are absolute),
	# so it enters the tree at the origin and only then moves onto the real Hall.
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
			# ps1.gdshader carries the same limits and clips by them only where it draws plank seams.
			floors[material] = limits is Vector2 and material.get_shader_parameter("plank_seams") != false
			if limits is Vector2:
				material.set_shader_parameter("floor_z_limits", limits + Vector2(ATTACH.z, ATTACH.z))
		if floors[material]:
			var clip: Vector2 = material.get_shader_parameter("floor_z_limits")
			var reach: AABB = mesh.global_transform * mesh.mesh.get_aabb()
			assert(
				reach.position.z >= clip.x - 0.01 and reach.end.z <= clip.y + 0.01,
				"Added floor %s (z %.2f to %.2f) lies outside its clip limits %s after attachment" % [mesh.get_path(), reach.position.z, reach.end.z, clip]
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
		var owner_room := -1
		var tag := str(body.get_meta("room_wall", ""))
		for i in _plan.size():
			if _plan[i].label == tag.get_slice(":", 0):
				owner_room = i
		_walls.append({
			"body": body, "box": box, "boxes": boxes, "layers": _layers_of(visual),
			"room": owner_room if tag.get_slice(":", 1) in SIDES else -1, "side": tag.get_slice(":", 1)
		})
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
	_collect_parts()
	for wall in _walls:
		wall["at"] = wall.room if wall.room >= 0 else _room_of(wall.box)
	_link_doors()
	_shade_walls()
	_grid = null  # a route planned in the Hall before now knew no furniture (#280)
	_warm_left = range(_plan.size())
	_build_ms += Time.get_ticks_msec() - began
	_build_longest = maxi(_build_longest, Time.get_ticks_msec() - began)
	print(
		"MAIN_BUILD_ROOMS ", JSON.stringify(state()), " ms=", _build_ms,
		" longest_step_ms=", _build_longest
	)


## What the checks read: counts only, no behaviour.
func state() -> Dictionary:
	return {
		"attached": _rooms != null,
		"pending": _rooms_path != "",
		"rooms": _plan.size(),
		"blocks": _blocks.size(),
		"cutaway_bodies": _walls.size(),
		"objects": _objects.size(),
		"space": _space
	}


# Everything in the room scene that is not part of a wall body, with the room it stands in and,
# if it hangs clear of the floor within 0.45 m of a wall, that wall.
func _collect_parts() -> void:
	var baked := _rooms.get_node_or_null("BakedRoom")
	for node in _rooms.find_children("*", "GeometryInstance3D", true, false):
		if baked != null and baked.is_ancestor_of(node):
			continue
		var in_wall := false
		var up: Node = node.get_parent()
		while up != null and up != _rooms:
			in_wall = in_wall or up.has_meta("room_wall")
			up = up.get_parent()
		if in_wall or node.has_meta("room_wall"):
			continue
		var box: AABB = node.global_transform * node.get_aabb()
		var centre := box.get_center()
		var room := _room_of(box)
		var side := ""
		if box.position.y > 0.25:
			var b: Array = _plan[room].b
			var nearest := 0.45
			for name in SIDES:
				var gap: float = (
					box.position.x - b[0]
					if name == "west"
					else b[1] - box.end.x if name == "east" else box.position.z - b[2] if name == "north" else b[3] - box.end.z
				)
				if gap < nearest:
					nearest = gap
					side = name
		var part := {"node": node, "room": room, "side": side, "shown": node.visible}
		_parts.append(part)
		if node.has_meta("skylight_landing") or node.has_meta("skylight_stair_tread") or node.has_meta("skylight_step_nosing"):
			part["box"] = box
			_skylight_structure.append(part)


# The room a thing reaches furthest into: a work on a shared wall belongs to the side it
# faces. Failing any overlap, the room whose middle is nearest.
func _room_of(box: AABB) -> int:
	var flat := Rect2(box.position.x, box.position.z, box.size.x, box.size.z).grow(0.05)
	var room := -1
	var most := 0.0
	for i in _plan.size():
		var share := _room_rect(i).intersection(flat).get_area()
		if share > most:
			most = share
			room = i
	if room < 0:
		var best := INF
		for i in _plan.size():
			var d := _room_rect(i).get_center().distance_squared_to(flat.get_center())
			if d < best:
				best = d
				room = i
	return room


func _collect_objects() -> void:
	# Titles, makers and the picture to show, keyed by accession number or asset name.
	var captions = JSON.parse_string(
		FileAccess.get_file_as_string(ROOM_SCENES[0].get_base_dir().path_join("objects.json"))
	)
	if not captions is Dictionary:
		captions = {}
	var found: Array = []
	for node in _rooms.find_children("*", "Node3D", true, false):
		# Catalogued by metadata, or a framed painting, which only shows its accession number
		# in its canvas file name (assets/painting-<accession>.jpg).
		var script: Script = node.get_script()
		var framed := script != null and script.resource_path.ends_with("painting_asset.gd")
		if not (node.has_meta("catalogue_accession") or node.has_meta("catalogue_asset") or framed):
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
		var canvas: Texture2D = null
		var face: GeometryInstance3D = null  # the part that carries the work's picture
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
				if texture is Texture2D:
					var file: String = texture.resource_path.get_file()
					if file.begins_with("painting-") or file.begins_with("wallpaper-"):
						canvas = texture
					if (
						image == null
						or texture.get_width() * texture.get_height() > image.get_width() * image.get_height()
					):
						image = texture
						face = part
		if canvas != null:
			image = canvas  # the picture itself, not its frame
		# A modelled work carries no picture; it is still a work when the catalogue has its row.
		if first or (image == null and not captions.has(str(node.get_meta("catalogue_accession", "")))):
			continue
		if not (node.has_meta("catalogue_accession") or node.has_meta("catalogue_asset")):
			if canvas == null:
				continue  # a mirror or a chair face: furniture, not a catalogued work
			node.set_meta("catalogue_accession", canvas.resource_path.get_file().get_basename().get_slice("-", 1))
		var centre := box.get_center()
		var room := _room_of(box)
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
		var rec: Dictionary = {
			"acc": accession,
			"title": str(node.get_meta("catalogue_title", key)),
			"artist": ", ".join(
				[str(node.get_meta("catalogue_maker", "")), str(node.get_meta("catalogue_date", ""))].filter(
					func(text: String) -> bool: return text != ""
				)
			),
			"medium": str(node.get_meta("catalogue_medium", "")),
			"dimensions": str(node.get_meta("catalogue_dimensions", "")),
			"identified": bool(node.get_meta("catalogue_identified", true))
		}
		# The catalogue photograph is only for the zoom page, so it is loaded when that opens
		# (#281): 88 of them, 298 MB uncompressed, were being loaded with the rooms.
		var picture := ""
		if ResourceLoader.exists(str(node.get_meta("catalogue_image", ""))):
			picture = node.get_meta("catalogue_image")
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
				"medium": str(row.get("medium", "")),
				"dimensions": str(row.get("dimensions", "")),
				"identified": bool(row.get("identified", true))
			}
			if ResourceLoader.exists(str(row.get("image", ""))):
				picture = row.image
			elif picture == "" and str(row.get("image", "")) == "":
				image = null  # no photograph of it in the repo: a model's skin is not a zoom page
		_objects.append(
			{
				"object": true,
				"tag": "%s#%d" % [key, _objects.size()],
				"rec": rec,
				"node": node,
				"room": room,
				"layers": FAR_LAYER if _plan[room].far else NEAR_LAYER,
				"image": image,
				"picture": picture,
				"center": centre,
				"normal": normal,
				"corners": corners,
				"outer": Vector2(maxf(box.size.x, box.size.z), box.size.y),
				"flat": _flat_normal(node),
				"front": _front(face, centre)
			}
		)


func _painting_at(pt: Vector2) -> Dictionary:
	var best: Dictionary = super(pt)
	if (_cam.cull_mask & 63) == 0:
		best = {}  # the Hall is cut away: its paintings cannot be clicked through the gap
	# A work answers when its box is under the pointer. Under several boxes, the smallest on
	# screen: a cup in front of a cabinet, a plate inside a case.
	var smallest := INF
	var under: Array = []
	var here := _room_at(_pos)
	for thing in _objects:
		# The room the visitor stands in, plus the work being read: its viewing spot may lie
		# just through a doorway. Nothing the camera has cut away answers a click.
		var reading: bool = thing.tag == _inspect.get("tag", "")
		if not reading and (thing.room != here or (_cam.cull_mask & thing.layers) == 0 or not _drawn(thing.node)):
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
		if Geometry2D.is_point_in_polygon(pt, hull):
			if reading:
				return thing  # the work being read answers before a smaller neighbour in its case
			under.append(thing)
			if area < smallest:
				smallest = area
				best = thing
	# But a box is mostly air, and the box of a work standing behind another covers part of the
	# one in front (#280). So several boxes are settled by the works themselves: the nearest
	# one whose own meshes the pointer's ray meets. Where the ray meets none (the margin round
	# a small work) the smallest box stands.
	# ponytail: a mesh's first test reads it back from the renderer (27 ms measured natively,
	# a stall on the Web), because no room builder keeps its arrays. So this runs only for a
	# click on overlapping boxes, never for the hover cursor. Keep the arrays at build time and
	# make a TriangleMesh from them if a click's first test is ever felt.
	if under.size() > 1 and not _hovering:
		var vp_pt := pt / size * Vector2(_vp.size)
		var from := _cam.project_ray_origin(vp_pt)
		var toward := _cam.project_ray_normal(vp_pt)
		var nearest := INF
		for thing in under:
			var reach := _ray_reach(thing.node, from, toward)
			if reach < nearest:
				nearest = reach
				best = thing
	return best


# The resting pointer only chooses a cursor shape and a sound; it does not pay for the mesh test.
func _update_hover() -> void:
	_hovering = true
	super()
	_hovering = false


# How far along a ray a work's own drawn surface lies; INF where the ray misses the work.
func _ray_reach(node: Node3D, from: Vector3, toward: Vector3) -> float:
	var reach := INF
	var parts: Array = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		parts.append(node)
	for part in parts:
		if part.mesh == null or not part.is_visible_in_tree():
			continue
		var shape: TriangleMesh = part.mesh.generate_triangle_mesh()  # kept by the mesh
		if shape == null:
			continue
		var inward: Transform3D = part.global_transform.affine_inverse()
		var hit := shape.intersect_ray(inward * from, (inward.basis * toward).normalized())
		if not hit.is_empty():
			reach = minf(reach, from.distance_to(part.global_transform * hit.position))
	return reach


# The cut-away hides a work's meshes, not its root: drawn means some mesh of it still shows.
func _drawn(node: Node3D) -> bool:
	if node is GeometryInstance3D:
		return node.is_visible_in_tree()
	for mesh in node.find_children("*", "GeometryInstance3D", true, false):
		if mesh.is_visible_in_tree():
			return true
	return false


# Where a click on the ground sends the visitor (#280): to the drawn stage's own floor under
# the pointer, or, when the pointer is in a doorway of its edge, just through that door.
# walk4's ray alone runs on through a drawn wall, or over it, or on through the dark of a
# doorway, to the floor of whatever room lies behind, and the visitor was sent there.
func _floor_at(pt: Vector2):
	# #275: ray/patch intersections at both levels, rather than walk4's y=0 plane.
	if _stage >= 0 and _plan[_stage].label == "Skylight Gallery":
		var eye := _cam.project_ray_origin(pt)
		var direction := _cam.project_ray_normal(pt)
		var nearest := INF
		var hit = null
		for patch in _skylight_surfaces:
			if str(patch.label) in _skylight_hidden_decks:
				continue
			var n: Vector3 = patch.normal
			var denominator := n.dot(direction)
			if absf(denominator) < .00001:
				continue
			var distance: float = n.dot(patch.at - eye) / denominator
			var q := eye + direction * distance
			if distance > 0 and distance < nearest and patch.b.has_point(Vector2(q.x, q.z)):
				nearest = distance
				hit = q
		if hit != null:
			return hit
		# A click through the upper reveal uses the existing adjacent-room rule.
	var spot = super(pt)
	if spot == null or _plan.is_empty() or _on_stage(spot):
		return spot
	# Back along the sight line to where it leaves the stage: only a doorway lets a click out.
	var eye := _cam.global_position
	var far: Vector3 = eye + (spot - eye).limit_length(80.0)
	for step in range(1, ceili(eye.distance_to(far) / 0.1)):
		var q := far.move_toward(eye, step * 0.1)
		if not _on_stage(Vector3(q.x, 0, q.z)):
			continue
		if not _doorway(q):
			return null
		# The wall over a door, and the door's casing, are wall: its header stops the click.
		for wall in _walls:
			if str(wall.body.get_meta("room_wall", "")).ends_with(":header"):
				for box in wall.boxes:
					if (box as AABB).intersects_segment(q.move_toward(eye, 0.5), spot) != null:
						return null
		# A doorway shows only the dark: the visitor is sent through it by the door's own axis,
		# wherever the ray would have met the ground beyond, and a metre and a half past the far
		# side of the doorway's thickness, as far in as the keys carry it. Stopped on the
		# threshold, the room opened on a black band (round 5).
		var room := _room_at(Vector3(q.x, 0, q.z))
		var b: Array = _plan[room].b if room >= 0 else [-W / 2.0, W / 2.0, -L, 0.0]
		var gaps := [q.x - b[0], b[1] - q.x, q.z - b[2], b[3] - q.z]
		var out: Vector3 = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK][gaps.find(gaps.min())]
		var sill := Vector3(q.x, 0, q.z)
		for tenth in range(1, 41):
			var p: Vector3 = sill + out * tenth * 0.1
			if _free(p) and not _in_thickness(p):
				return p + out * 1.5
		return sill + out * 1.5
	return null


# Whether a floor point is still inside a doorway's thickness: the stone portal's passage, an
# area of the plan narrower than 1.2 m (a wall's reveal), or the Hall's own door strips.
func _in_thickness(p: Vector3) -> bool:
	if absf(p.x) < PORTAL_SIDE and p.z > -0.55 and p.z < PORTAL_MOUTH:
		return true
	var room := _room_at(p)
	if room >= 0:
		var b: Array = _plan[room].b
		return minf(b[1] - b[0], b[3] - b[2]) < 1.2
	return p.z > -0.55 or p.z < -L + 0.55


# Whether a floor point belongs to the stage being drawn: its areas, or the Hall itself.
func _on_stage(p: Vector3) -> bool:
	# Until the rooms are built (#281) the visitor is in the Hall and the Hall is what is drawn.
	var stage := _stage if _rooms != null else -1
	var room := _room_at(p)
	if room >= 0:
		return _stage_ids[room] == stage
	return stage == -1 and absf(p.x) <= W / 2.0 and p.z <= 0.0 and p.z >= -L


# Whether a sight line leaving the stage at q passes through a doorway: one of the Hall's two
# doors as walk4 builds them, or a gap in an added room's wall where a visitor may stand.
func _doorway(q: Vector3) -> bool:
	for door in DOORS.values():
		if absf(q.x) <= door.size.x / 2.0 and absf(q.z - door.z) < 0.6:
			return q.y <= door.size.y
	return q.y < DOOR_TOP and _free(Vector3(q.x, 0, q.z))


# Where a visitor stands to look at a work, and which way it faces from the wall.
# Beside the work rather than in front of its middle, so the inspection shot sees past the
# visitor: the side with free floor, the nearer one if both are free.
func _viewing(p: Dictionary) -> Dictionary:
	var normals: Array = [p.normal]
	if p.normal == Vector3.ZERO:
		normals = [Vector3(_pos.x - p.center.x, 0, _pos.z - p.center.z).normalized()]
	# A flat work standing up (a photo card, a cut-out) is looked at square on, from whichever
	# face has floor before it, whatever wall is nearest and wherever the visitor happens to
	# be (#272): seen along its edge it is a dark bar. One lying down is looked down on.
	var flat: Vector3 = p.get("flat", Vector3.ZERO)
	# A free-standing work with its picture on one face is seen from that face.
	if p.normal == Vector3.ZERO and p.get("front", Vector3.ZERO) != Vector3.ZERO:
		normals = [p.front]
		flat = Vector3.ZERO
	var turned: bool = (
		flat != Vector3.ZERO
		and flat.y == 0.0
		and (p.normal == Vector3.ZERO or absf(p.normal.dot(flat)) < 0.9)
	)
	if turned:
		normals = [flat, -flat]
	var foot := Vector3(p.center.x, 0, p.center.z)
	var small: bool = p.outer.y < 0.6 or p.normal == Vector3.ZERO
	var out: float = p.outer.x / 2.0 + 1.0 if small else clampf(p.outer.y * 0.9, 1.5, 2.5)
	# Clear of the work's edge by more than the visitor's half-width and one route-grid cell.
	var aside: float = p.outer.x / 2.0 + 0.75
	var best := {}
	var nearest := INF
	for normal in normals:
		var along: Vector3 = normal.cross(Vector3.UP)
		for side in [1.0, -1.0]:
			var wanted: Vector3 = foot + normal * out + along * side * aside
			var cell := _cell(wanted)
			if not _route_grid().is_in_boundsv(cell):
				continue
			var stand := Vector3(cell.x * GRID, 0, cell.y * GRID)
			# A face with a wall behind it has no floor of its own: its spot would be next door.
			if turned and _stage_of(_room_at(stand)) != _stage_of(p.room):
				continue
			# A side where a wall or a case pushes the spot back in front of the work loses.
			var d := stand.distance_to(_pos) + maxf(0.0, stand.distance_to(wanted) - 0.2) * 10.0
			# So does a face with another work standing in front of it, by how much it hides.
			if turned:
				d += _stood_before(p, normal) * 20.0
			if d < nearest:
				nearest = d
				best = {
					"normal": normal, "along": along, "side": side, "stand": stand, "small": small,
					"above": flat.y != 0.0
				}
	if best.is_empty():
		# No floor within reach before the work: it hangs over the Skylight Gallery's lower
		# storey (#275). The nearest floor of its own room that is before its face, then.
		var grid := _route_grid()
		var home: Vector3 = foot + normals[0] * out
		var least := INF
		for dx in range(-32, 33):
			for dz in range(-32, 33):
				var cell := Vector2i(roundi(home.x / GRID) + dx, roundi(home.z / GRID) + dz)
				if not grid.is_in_boundsv(cell) or grid.is_point_solid(cell):
					continue
				var stand := Vector3(cell.x * GRID, 0, cell.y * GRID)
				if (stand - foot).dot(normals[0]) < 0.5 or stand.distance_to(home) >= least:
					continue
				if _stage_of(_room_at(stand)) != _stage_of(p.get("room", -1)):
					continue
				least = stand.distance_to(home)
				var across: Vector3 = normals[0].cross(Vector3.UP)
				best = {
					"normal": normals[0], "along": across, "stand": stand, "small": small,
					"side": 1.0 if (stand - foot).dot(across) >= 0.0 else -1.0, "above": flat.y != 0.0
				}
		return best
	# The visitor stands beside the work and clear of the lens (#272). Where the usual spot
	# would fill more than CROWD of the picture (a hat across a quarter of it, at the Apostles)
	# it stands further aside, as far as the floor of the work's own room lets it.
	var kept = p.get("view")
	var lens_was := _inspect_fov
	p["view"] = best
	var shot := _inspect_shot(p)
	# Nothing drawn stands between the lens and the work (#272, round 5: Christ in Majesty was
	# read through the glass case that stands before it). Square on first; then from either
	# side, then nearer, taking the first place in the work's own room with a clear sight.
	if p.has("object") and _lens_blocked(p, shot.origin):
		for place in [[0.4, 1.0], [-0.4, 1.0], [0.65, 1.0], [-0.65, 1.0], [0.0, 0.6], [0.0, 0.4]]:
			best["lens"] = place
			var tried := _inspect_shot(p)
			var under := Vector3(tried.origin.x, 0, tried.origin.z)
			# In the work's own room, with the work still whole in the widest lens, and clear.
			if (
				_stage_of(_room_at(under)) == _stage_of(p.room)
				and _inspect_fov < 64.9
				and not _lens_blocked(p, tried.origin)
			):
				shot = tried
				break
			best.erase("lens")
	var lens := _inspect_fov
	for more in [1.0, 1.5, 2.0, 2.6, 3.3]:
		var wanted: Vector3 = foot + best.normal * out + best.along * best.side * aside * more
		var cell := _cell(wanted)
		if not _route_grid().is_in_boundsv(cell):
			continue
		var stand := Vector3(cell.x * GRID, 0, cell.y * GRID)
		if stand.distance_to(wanted) > 0.4 or _stage_of(_room_at(stand)) != _stage_of(p.get("room", -1)):
			continue
		if _visitor_fills(shot, lens, stand) <= CROWD:
			best.stand = stand
			break
	_inspect_fov = lens_was
	if kept == null:
		p.erase("view")
	else:
		p["view"] = kept
	return best


# Whether something drawn stands between a lens at `eye` and a work: another work's box, or the
# drawn hull of a case, plinth or pier that is not the work's own (one that holds the work, or
# whose hull its middle is inside). Room walls are the cut-away's to open. Three sight lines:
# to the work's middle and to a third of its width either side.
func _lens_blocked(p: Dictionary, eye: Vector3) -> bool:
	var across := Vector3(p.center.x - eye.x, 0, p.center.z - eye.z).normalized().cross(Vector3.UP)
	var marks: Array = [p.center, p.center + across * p.outer.x / 3.0, p.center - across * p.outer.x / 3.0]
	for other in _objects:
		if other.tag == p.tag or other.room != p.room:
			continue
		var box := AABB(other.corners[0], other.corners[7] - other.corners[0])
		if box.has_point(p.center):
			continue
		for mark in marks:
			if box.intersects_segment(eye, mark) != null:
				return true
	for wall in _walls:
		var body: Node3D = wall.body
		if wall.room >= 0 or body == p.node or body.is_ancestor_of(p.node):
			continue
		if not wall.has("hull"):
			# Its drawn parts, each by its own box: the collision box is only the plinth.
			var parts: Array[AABB] = []
			var hull := AABB(wall.box)
			for part in body.find_children("*", "GeometryInstance3D", true, false):
				parts.append(part.global_transform * part.get_aabb())
				hull = hull.merge(parts[-1])
			wall["hull"] = hull
			wall["parts"] = parts
		if (wall.hull as AABB).has_point(p.center):
			continue
		for part in wall.parts:
			for mark in marks:
				if (part as AABB).intersects_segment(eye, mark) != null:
					return true
	return false


# The share of the picture the visitor's body takes, standing at `at`, through a lens at `shot`:
# 0 out of the picture or behind the lens, 1 when the lens is inside it.
func _visitor_fills(shot: Transform3D, lens: float, at: Vector3) -> float:
	var inward := shot.affine_inverse()
	var up := tan(deg_to_rad(lens) / 2.0)
	var wide: float = up * size.x / maxf(size.y, 1.0)
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	var behind := 0
	for i in 8:
		var q: Vector3 = inward * (at + Vector3(0.4 if i & 1 else -0.4, 1.7 if i & 2 else 0.0, 0.4 if i & 4 else -0.4))
		if q.z > -0.1:
			behind += 1
			continue
		var on := Vector2(q.x / (-q.z * wide), q.y / (-q.z * up))
		low = low.min(on)
		high = high.max(on)
	if behind > 0:
		return 0.0 if behind == 8 else 1.0
	return Rect2(low, high - low).intersection(Rect2(-1, -1, 2, 2)).get_area() / 4.0


# How much of a work's face, seen from the side its normal points to, another work in its
# room stands in front of: 0 none, 1 all of it. By their boxes, within a metre of it.
func _stood_before(p: Dictionary, normal: Vector3) -> float:
	var along := normal.cross(Vector3.UP)
	var most := 0.0
	for other in _objects:
		if other.tag == p.tag or other.room != p.get("room", -1):
			continue
		var off: Vector3 = other.center - p.center
		var depth := off.dot(normal)
		if depth <= 0.02 or depth > 1.0:
			continue
		var reach: Vector3 = other.corners[7] - other.corners[0]
		var wide: float = absf(along.x) * reach.x + absf(along.z) * reach.z
		var across: float = (wide + p.outer.x) / 2.0 - absf(off.dot(along))
		var up: float = (reach.y + p.outer.y) / 2.0 - absf(off.y)
		most = maxf(
			most,
			clampf(across / maxf(p.outer.x, 0.01), 0.0, 1.0) * clampf(up / maxf(p.outer.y, 0.01), 0.0, 1.0)
		)
	return most


# The way a flat thing faces: the axis its meshes are thin along, taken in its own frame (a card
# may stand at any angle) and turned into the room's. UP for one lying down; zero for a thing
# in the round, which is anything not thinner than a fifth of its other two measures.
func _flat_normal(node: Node3D) -> Vector3:
	var parts: Array = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		parts.append(node)
	var inward := node.global_transform.affine_inverse()
	var box := AABB()
	var first := true
	for part in parts:
		if part.mesh == null:
			continue
		var reach: AABB = (inward * part.global_transform) * part.get_aabb()
		box = reach if first else box.merge(reach)
		first = false
	if first:
		return Vector3.ZERO
	var measures: Vector3 = box.size * node.global_transform.basis.get_scale()
	var thin := measures.min_axis_index()
	if (
		measures[thin] >= 0.2 * measures[(thin + 1) % 3]
		or measures[thin] >= 0.2 * measures[(thin + 2) % 3]
	):
		return Vector3.ZERO
	var axis := Vector3.ZERO
	axis[thin] = 1.0
	var way := (node.global_transform.basis * axis).normalized()
	if absf(way.y) > 0.7:
		return Vector3.UP
	return Vector3(way.x, 0, way.z).normalized()


# The side a work in the round is meant to be seen from, where its picture is a flat part set
# on one of its faces (the Writing Desk: a box with its photograph on the front): the way
# that part faces, out from the work's middle. Zero when it has no such part.
func _front(face: GeometryInstance3D, centre: Vector3) -> Vector3:
	if face == null:
		return Vector3.ZERO
	var way := _flat_normal(face)
	var off: float = ((face.global_transform * face.get_aabb()).get_center() - centre).dot(way)
	return way * signf(off) if way.y == 0.0 and absf(off) > 0.05 else Vector3.ZERO


# Any work, Hall painting or added-room object: walk to its viewing spot, face it, open it.
func _approach(p: Dictionary) -> void:
	if _plan.is_empty():
		super(p)
		return
	var view := _viewing(p)
	if view.is_empty():
		return
	p["view"] = view
	var stand: Vector3 = view.stand
	_route_to(stand)
	var mine := _action
	while _target != null or not _path.is_empty():
		await get_tree().process_frame
		if _action != mine or not _open.is_empty():
			return
	# On the plan: the spot is recorded at height 0 and the Skylight Gallery's lower floor is
	# 2.55 m under that, where a visitor on its spot never counted as arrived (#272).
	if Vector2(_pos.x - stand.x, _pos.z - stand.z).length() > 0.6:
		return
	var to := Vector3(p.center.x - _pos.x, 0, p.center.z - _pos.z).normalized()
	_motion_heading = to
	_target_yaw = atan2(-to.x, -to.z)
	while absf(wrapf(_kid.rotation.y - atan2(to.x, to.z), -PI, PI)) > 0.015:
		await get_tree().process_frame
		if _action != mine or not _open.is_empty():
			return
	_open_detail(p)


func _open_detail(p: Dictionary) -> void:
	if _inspect.get("tag", "") != p.tag:
		_begin_inspect(p)
		return
	if p.has("object") and p.image == null and str(p.picture) == "":
		return  # no photograph of it: the reading is all there is, a second click changes nothing
	# Already looking at it: the zoom page comes forward over the room.
	_end_inspect(true)
	if str(p.get("picture", "")) != "":
		p.image = load(p.picture)
	super(p)
	_detail.modulate.a = 0.0
	create_tween().tween_property(_detail, "modulate:a", 1.0, 0.25)


func _pages(p: Dictionary) -> Array:
	var rec: Dictionary = p.rec
	var first := PackedStringArray()
	if str(rec.get("artist", "")) != "":
		first.append(str(rec.artist))
	if str(rec.get("acc", "")) != "":
		first.append("RISD Museum " + str(rec.acc))
	var pages := [[str(rec.get("title", "")), "\n".join(first)]]
	var second := PackedStringArray()
	for field in ["medium", "dimensions"]:
		if str(rec.get(field, "")) != "":
			second.append(str(rec[field]))
	if not second.is_empty():
		pages.append([str(rec.get("title", "")), "\n".join(second)])
	return pages


func _begin_inspect(p: Dictionary) -> void:
	_inspect = p
	_inspect_page = 0
	_velocity = Vector3.ZERO
	_held.clear()
	if _inspect_panel == null:
		_inspect_panel = PanelContainer.new()
		var back := StyleBoxFlat.new()
		back.bg_color = Color(0.05, 0.06, 0.11, 0.62)
		back.set_corner_radius_all(14)
		back.set_content_margin_all(18)
		_inspect_panel.add_theme_stylebox_override("panel", back)
		_inspect_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var lines := VBoxContainer.new()
		lines.alignment = BoxContainer.ALIGNMENT_CENTER
		_inspect_panel.add_child(lines)
		for part in ["Title", "Body"]:
			var label := Label.new()
			label.name = part
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", Color("f4efe2"))
			lines.add_child(label)
		add_child(_inspect_panel)
	_inspect_panel.hide()
	if _inspect_tween:
		_inspect_tween.kill()
	_inspect_tween = create_tween()
	_inspect_tween.tween_property(self, "_inspect_t", 1.0, 0.73).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var mine := _action
	await get_tree().create_timer(0.13).timeout
	if _inspect.get("tag", "") != p.tag or _action != mine:
		return
	_show_page(false)
	await get_tree().create_timer(0.54).timeout
	if _inspect.get("tag", "") == p.tag and _action == mine:
		_show_page(true)


# The panel: bottom centre, 58% wide and 27.5% high, 8% up from the foot of the picture.
func _show_page(with_text: bool) -> void:
	_inspect_panel.size = Vector2(size.x * 0.58, size.y * 0.275)
	_inspect_panel.position = Vector2(size.x * 0.21, size.y * (1.0 - 0.08 - 0.275))
	var page: Array = _pages(_inspect)[_inspect_page]
	var title: Label = _inspect_panel.get_child(0).get_node("Title")
	var body: Label = _inspect_panel.get_child(0).get_node("Body")
	title.add_theme_font_size_override("font_size", maxi(12, roundi(size.y * 0.046)))
	body.add_theme_font_size_override("font_size", maxi(10, roundi(size.y * 0.032)))
	title.text = page[0] if with_text else ""
	body.text = page[1] if with_text else ""
	_inspect_panel.modulate.a = 1.0
	_inspect_panel.show()
	_inspect_panel.reset_size()
	var tall := maxf(size.y * 0.275, _inspect_panel.get_combined_minimum_size().y)
	_inspect_panel.size = Vector2(size.x * 0.58, tall)
	_inspect_panel.position.y = size.y * (1.0 - 0.08) - tall


func _next_page() -> void:
	if _inspect_page + 1 < _pages(_inspect).size():
		_inspect_page += 1
		_play("cursor")
		_show_page(true)
	else:
		_end_inspect(false)


func _end_inspect(to_zoom: bool) -> void:
	if _inspect.is_empty():
		return
	_inspect = {}
	if not to_zoom:
		_play("cursor")
	if _inspect_panel:
		var fade := create_tween()
		fade.tween_property(_inspect_panel, "modulate:a", 0.0, 0.2)
		fade.tween_callback(_inspect_panel.hide)
	if _inspect_tween:
		_inspect_tween.kill()
	_inspect_tween = create_tween()
	_inspect_tween.tween_property(self, "_inspect_t", 0.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# "Other wall" walks the visitor across the Hall and swings the view round. Neither the
# inspection shot (a work being read, the camera gliding back from it) nor a room change (the
# wipe holds its own view and walks the visitor itself) follows that, so through both the
# button is neither shown nor answers (#280).
func _other_wall_free() -> bool:
	return _inspect.is_empty() and _inspect_t <= 0.0 and _wipe_t < 0.0


func _other_wall() -> void:
	if _other_wall_free():
		super()


# How far down the picture the caption panel's top comes while a work is read, as a share of
# the picture's height: 0.645 for the usual panel, less where a long title makes it taller.
# Measured from the text as _show_page lays it out, before the panel is shown.
func _caption_top(p: Dictionary) -> float:
	var font := get_theme_default_font()
	var wide := size.x * 0.58 - 36.0
	var tall := 0.0
	for page in _pages(p):
		var title := font.get_multiline_string_size(
			page[0], HORIZONTAL_ALIGNMENT_CENTER, wide, maxi(12, roundi(size.y * 0.046))
		)
		var body := font.get_multiline_string_size(
			page[1], HORIZONTAL_ALIGNMENT_CENTER, wide, maxi(10, roundi(size.y * 0.032))
		)
		tall = maxf(tall, title.y + body.y + 40.0)
	return 1.0 - 0.08 - maxf(0.275, tall / size.y)


# Where the camera stands to look at a work: square on to it, 6 degrees down, far enough
# that the work fills its share of the picture, never outside the room it hangs in. When
# the room is too shallow for a 23-degree lens the lens widens instead.
func _inspect_shot(p: Dictionary) -> Transform3D:
	var view: Dictionary = p.get("view", {})
	if view.is_empty():
		view = _viewing(p)
		p["view"] = view
	# The lens stands square before the work unless something is in its way there (_viewing):
	# then turned about the work by lens[0] radians, or brought nearer by the share lens[1].
	var lens: Array = view.get("lens", [0.0, 1.0])
	var normal: Vector3 = (view.normal as Vector3).rotated(Vector3.UP, lens[0])
	var along: Vector3 = (view.along as Vector3).rotated(Vector3.UP, lens[0])
	var height: float = maxf(p.outer.y, 0.05)
	# The work stands in the band above the caption panel (#272): its top four hundredths of
	# the picture under the picture's, its foot three hundredths above the panel. A tall work
	# takes less of the picture than it used to (up to 0.68, which put its foot under the panel).
	if p.get("band_at") != size:
		p["band"] = _caption_top(p)
		p["band_at"] = size
	var band: float = p.band
	var share := minf(lerpf(0.43, 0.68, clampf((height - 1.0) / 2.0, 0.0, 1.0)), band - 0.07)
	var back := clampf(height / (share * 0.407), 4.5, 13.0)
	var tilt := deg_to_rad(6.0)
	if view.small:
		# A case object or a small panel: near it, almost level, a third of the picture high.
		share = 0.33
		# Near, but never so near that a tall free-standing work (the 3.5 m fireplace surround)
		# overflows the widest lens.
		back = clampf(height / (share * 0.407), 1.6, maxf(4.5, height * 2.2))
		tilt = deg_to_rad(3.0)
	if view.get("above", false):
		# Lying flat: looked down on at 55 degrees so that its face shows. What the face
		# measures across the lens stands in for its height in the sums below.
		tilt = deg_to_rad(55.0)
		height = maxf(p.outer.x, 0.05) * sin(tilt) * cos(tilt)
		share = 0.33
		back = clampf(height / (share * 0.407), 0.9, 4.5)
	var foot := Vector3(p.center.x, 0, p.center.z)
	var room := _room_at(foot + normal * 0.6)
	var bounds: Array = _plan[room].b if room >= 0 else [-W / 2.0, W / 2.0, -L, 0.0]
	var extent: float = absf(normal.x) * (bounds[1] - bounds[0]) + absf(normal.z) * (bounds[3] - bounds[2])
	back = maxf(1.4, minf(back, maxf(1.4, extent - 0.6)) * lens[1])
	var shift: float = -view.side * 0.35 if view.small else 0.0  # over the shoulder away from the visitor
	# The visitor never covers the work. Where furniture squeezed the viewing spot in front
	# of it, the visitor steps out of this one picture rather than the lens losing the work.
	var rel := Vector3(_pos.x, 0, _pos.z) - foot
	var depth := rel.dot(normal)
	var gap := absf(rel.dot(along) - shift * depth / back)
	p["covered"] = depth > 0.0 and depth < back and gap < 0.35 + p.outer.x / 2.0 * (1.0 - depth / back)
	_inspect_fov = clampf(rad_to_deg(2.0 * atan(height / share / 2.0 / back)), 23.0, 65.0)
	var eye: Vector3 = foot + normal * back + along * shift
	# The work's centre sits 40% down the picture, a tenth of the lens above its axis; higher
	# where it must be for the work's foot to clear the panel.
	var shown: float = height / (2.0 * back * tan(deg_to_rad(_inspect_fov) / 2.0))
	var centre := clampf(band - 0.03 - shown / 2.0, shown / 2.0 + 0.02, 0.4)
	var above := atan((0.5 - centre) * 2.0 * tan(deg_to_rad(_inspect_fov) / 2.0))  # of the lens's axis
	eye.y = p.center.y + back * tan(tilt - above)
	var aim := Vector3(p.center.x, eye.y, p.center.z) - eye
	var sight := (aim.normalized() * cos(tilt) + Vector3.DOWN * sin(tilt)).normalized()
	var shot := Transform3D(Basis.looking_at(sight, Vector3.UP), eye)
	# Nor does the visitor crowd the lens: where the floor left it no spot clear of the frame
	# it steps out of this one picture too.
	if _visitor_fills(shot, _inspect_fov, _pos) > CROWD:
		p["covered"] = true
	return shot


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
		_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	_caption.size = Vector2(size.x * 0.9, 0)
	_caption.size.y = _caption.get_minimum_size().y
	# The caption reads under the work, never across it (#271): the work, frame and all, is
	# made as much smaller as it takes for the two to share the page.
	var pic: TextureRect = _zoom_root.get_node("Painting")
	var frame: NinePatchRect = _zoom_root.get_node("Frame")
	var work := Rect2(Vector2.ZERO, pic.size)
	if frame.visible:
		work = work.merge(Rect2(frame.position, frame.size * frame.scale))
	var gap := 14.0
	var k := minf(1.0, (size.y - _caption.size.y - gap * 3.0) / work.size.y)
	pic.size *= k
	frame.scale *= k
	frame.position *= k
	_zoom_root.size *= k
	work = Rect2(work.position * k, work.size * k)
	var top := (size.y - work.size.y - gap - _caption.size.y) / 2.0
	_zoom_root.position = Vector2((size.x - _zoom_root.size.x) / 2.0, top - work.position.y)
	_caption.position = Vector2(size.x * 0.05, top + work.size.y + gap)
	_caption.show()


# Zoomed back out, the page is laid out again: walk4 alone would centre the picture on the caption.
# Magnified, the picture grows over where the caption was laid, so the caption is put away
# until the page is fitted again (#280, round 4).
func _zoom_at(point: Vector2, factor: float) -> void:
	super(point, factor)
	if is_equal_approx(_zoom, 1.0):
		_fit_detail()
	elif _caption:
		_caption.hide()


func _gui_input(event: InputEvent) -> void:
	# The room change is walking the visitor: a press now would cancel its route (walk4 clears
	# it on any press) and leave the visitor short of the room. Presses wait for the keys.
	if (
		event is InputEventMouseButton
		and _wipe_t >= 0.0
		and _wipe_t < WIPE_CLOSE + WIPE_HOLD + WIPE_BACK
	):
		accept_event()
		return
	if _inspect.is_empty() or not _open.is_empty():
		super(event)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if _painting_at(event.position).get("tag", "") == _inspect.tag:
				_open_detail(_inspect)  # a second click on the work: its zoom page
			else:
				_next_page()
		accept_event()


func _unhandled_key_input(event: InputEvent) -> void:
	if _inspect.is_empty() or not _open.is_empty() or not event.pressed or event.echo:
		super(event)
		return
	if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
		_next_page()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE:
		_end_inspect(false)
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_W, KEY_A, KEY_S, KEY_D]:
		_end_inspect(false)  # walking away closes it
		super(event)


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
	if _rooms == null and _rooms_path == "":
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
		if box.position.z >= -0.001 and box.end.z > PORTAL_MOUTH + 0.1:
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
	if _rooms == null and _rooms_path != "":
		# The first doorway out of the Hall: the wipe closes here and the rooms are built in its black.
		if next != "gallery" and _wipe_t < 0.0:
			_wipe_space = next
			_wipe_begin()
		return
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
				node.environment.background_color = VOID
				node.environment.ambient_light_energy = 0.6 if next != "far" and not _baked_lighting else 0.0
		_update_camera(1.0)
		print("NAV_SPACE ", previous, " -> ", next)
		return
	super(next)
	_update_camera(1.0)


func _process(delta: float) -> void:
	if _wipe_t >= 0.0:
		# The change walks the visitor itself; held keys wait until the room has opened.
		var kept := _held
		if _wipe_t < WIPE_CLOSE + WIPE_HOLD + WIPE_BACK:
			_held = {}
		if _rooms == null:
			# Until the rooms exist the Hall's own limit stops the visitor 0.2 m into the
			# doorway, and walk4 gives a route up after half a second against anything. A
			# clicked route waits there instead and goes on once the rooms are in place (#281).
			_stall_t = 0.0
		super(delta)
		_held = kept
		_wipe_step(delta)
	else:
		super(delta)
	if _rooms == null and _rooms_path != "" and _wipe_t < 0.0 and not _entrance_waiting:
		# The Hall is on screen. The rooms begin a moment later and go on whenever the visitor
		# stands still; a doorway reached first finishes them in the wipe's black (_wipe_step).
		_build_clock += delta
		if _build_clock >= BUILD_AFTER and _standing_still():
			if _building == null:
				_begin_rooms()
			else:
				_pump_rooms(BUILD_SHARE_MS)
	elif not _warm_left.is_empty() and _wipe_t < 0.0:
		if _entrance_waiting:
			# The rooms were built at launch (ROOMS_AT_LAUNCH) and the loading screen is still
			# up: every area in one draw, where one long frame is not seen.
			_warm_step(true)
		elif _stage >= 0:
			_warm_left.clear()  # put into a room: the other stages are hidden, nothing to draw
		elif _standing_still():
			_warm_step()
	if _wipe_warm < 4 and _wipe_t < 0.0 and is_visible_in_tree():
		_wipe_warm += 1
		# The same for the Hall's portal wall, which dissolves as the visitor steps into the
		# passage: its dissolve shader was first used, and compiled, as the first wipe began.
		# At full strength it draws the wall whole.
		for entry in _cutaway_materials.get(8, []):
			entry.material.set_shader_parameter("cutaway_opacity", 1.0)
			entry.mesh.material_override = entry.material
		if _wipe_warm == 4:
			_wipe.hide()
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
	# The plan is enough to route by: a doorway clicked from the Hall before the rooms are built
	# (#281) is walked through like any other, not stopped at walk4's own door strip (#280).
	if _plan.is_empty():
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
	return _skylight_step(_slide(p))


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
	if _plan[index].label == "Skylight Gallery" and _skylight_height(p) == -INF:
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
	_cam.cull_mask |= VOID_LAYER  # the parent sets the mask afresh; the void is in every picture
	if _floor_mask and _floor_mask_stage == NO_STAGE and _stage == NO_STAGE:
		_stage = -1  # only the Hall exists yet: its own ground beyond the walls
		_mask_floor()
		_stage = NO_STAGE
	# Set before anything below can return: a Hall painting is read at launch, when the rooms
	# are not built yet (#281).
	var other_wall := get_node_or_null("OtherWall") as Button
	if other_wall:
		other_wall.visible = _space == "gallery" and _open.is_empty() and _other_wall_free()
	# Put straight into an added room, with no wipe to hide behind. Clear of the Hall's own
	# edge: a walking visitor can land exactly on a doorway's line a frame before the wipe starts.
	var outside := _pos.z > 0.05 or _pos.z < -L - 0.05 or absf(_pos.x) > W / 2.0 + 0.05
	if _rooms == null and _rooms_path != "" and _wipe_t < 0.0 and outside and _room_at(_pos) >= 0:
		_attach_rooms(_rooms_path)
	if _rooms == null:
		# Only the Hall exists until the first doorway (#281); its paintings are read all the same.
		if _rooms_path != "" and _inspect_camera():
			_hall_walls_back(0)
		_light_doors()
		return
	var here := _room_at(_pos)
	# Further in one frame than walking covers: the visitor was put there. A long frame (the
	# first draw of a room) lets a walking visitor cover more, so the frame's length counts.
	var placed := _pos.distance_to(_stage_pos) > 0.6 + SPRINT_MPS * 2.0 * get_process_delta_time()
	_stage_pos = _pos
	if _stage == NO_STAGE or placed or _entrance_active or not _open.is_empty():
		_wipe_end()
		_stage = _stage_of(here)
	elif _stage_of(here) != _stage and _wipe_t < 0.0:
		_wipe_begin()
	var closing := _wipe_t >= 0.0 and _wipe_t < WIPE_CLOSE
	var added := _stage >= 0
	if _baked_room:
		_baked_room.get_node("Lightmap").visible = not added
	var capture := _rooms.get_node_or_null("BakedRoom/Lightmap")
	if capture:
		capture.visible = added
	if _white_capture:
		_white_capture.visible = false # The attached rooms carry their own native probe field.
	if view_mode == 2 and added:
		# walk4's follow camera is boxed into its stand-in rooms; in an added room it just follows.
		var forward := _fwd()
		_cam.fov = 58.0
		# It keeps its distance whatever the room's size. Pulled in to stay inside the visitor's
		# room, in a passage it closed to within half a metre of the head, which filled the
		# picture; the room is opened on the lens's side instead (below).
		_cam.position = _pos - forward * 3.1 + Vector3(0, 2.45, 0)
		_cam.look_at(_pos + forward * 2.0 + Vector3(0, 1.1, 0))
	var inspecting := _inspect_camera()
	var shown: int = NEAR_LAYER | FAR_LAYER # Both adjoining room interiors are visible through their doors.
	# The visitor and its shadows have a layer of their own, so hiding the Hall never hides them.
	_cam.cull_mask |= shown | VISITOR_LAYER
	_shadow.layers |= VISITOR_LAYER
	for patch in _sole_shadows:
		patch.layers |= VISITOR_LAYER
	if closing:
		# The old stage stays as it was drawn until the wipe has shut on it.
		_cam.global_transform = _wipe_cam
		_cam.fov = _wipe_fov
		_cam.cull_mask = _wipe_mask
		return
	if _space == "gallery":
		_cam.cull_mask |= FAR_LAYER
		if inspecting:
			_hall_walls_back(shown | VISITOR_LAYER)
	elif _space == "far" and added:
		# The parent's far-space rule leaves the Hall's last wall fade untouched.
		_cutaway_alpha[8] = 1.0
		for entry in _cutaway_materials.get(8, []):
			entry.mesh.material_override = entry.original
		if _portal_floor_material:
			_portal_floor_material.set_shader_parameter("cutaway", 0.0)
		var toward := _fwd() if view_mode == 2 else Vector3(-sin(view_yaw), 0, -cos(view_yaw))
		var hidden := (4 if toward.x < -0.2 else 2 if toward.x > 0.2 else 0) | (16 if toward.z < -0.2 else 0)
		_cam.cull_mask |= 63 if view_mode == 2 else 31 & ~hidden
	# A dollhouse: the room the visitor is in is an open set. Its walls on the camera's side,
	# what hangs on them, and every room that lies between the camera and it are not drawn.
	var eye := _cam.global_position
	var flat_eye := Vector2(eye.x, eye.z)
	var hall := Rect2(-W / 2.0, -L, W, L)
	var stage: Rect2 = _room_rect(here) if added else hall
	var lens := PackedVector2Array([flat_eye])
	var inner := stage.grow(-0.3)
	for corner in [inner.position, Vector2(inner.end.x, inner.position.y), inner.end, Vector2(inner.position.x, inner.end.y)]:
		lens.append(corner)
	lens = Geometry2D.convex_hull(lens)
	var cut := {}  # room index -> true (all of it) or a Dictionary of its sides
	# Only the dollhouse views open the set. The follow view and an inspection stand inside
	# the room, where every wall belongs in the picture.
	var open_set := view_mode != 2 and not inspecting
	# The follow lens, 3.1 m behind the visitor, is often outside the visitor's room: that one
	# room is opened on the lens's side all the same, from LENS_CLEAR before the lens reaches
	# the wall. The other rooms keep their walls: the lens follows through their doorways.
	# A work read from there is glided to from outside, so the side stays open until the lens is in.
	var own := here if view_mode == 2 and added else -1
	for i in _plan.size():
		var area := _room_rect(i)
		if added and _stage_ids[i] != _stage:
			cut[i] = true  # another stage
			continue
		# From the Hall a room between the camera and the visitor goes whole. Inside a stage no
		# area does: standing in a doorway's depth must not drop the room it belongs to.
		if open_set and not added and (area.has_point(flat_eye) or _overlap(lens, area.grow(-0.15))):
			cut[i] = true
			continue
		var b: Array = _plan[i].b
		var opens := open_set or i == own
		var near := LENS_CLEAR if i == own and not inspecting else 0.0
		cut[i] = {
			"west": opens and eye.x < b[0] + near,
			"east": opens and eye.x > b[1] - near,
			"north": opens and eye.z < b[2] + near,
			"south": opens and eye.z > b[3] - near
		}
	if open_set and added and (hall.has_point(flat_eye) or _overlap(lens, hall.grow(-0.15))):
		_cam.cull_mask &= ~63
	var state := hash([here, cut, eye.y > 3.4])
	if state != _cut_state:
		_cut_state = state
		for part in _parts:
			var rule = cut[part.room]
			part.node.visible = part.shown and not (rule is bool or (part.side != "" and rule[part.side]))
	# A wall also goes when it stands between the camera and the visitor, and its trim with it.
	var across := _cam.global_transform.basis.x
	across.y = 0.0
	var subject_heights: Array = [.5,1.5]
	if here >= 0 and _plan[here].label in ["Skylight Gallery","Skylight Gallery reveal threshold"]:
		subject_heights.append(1.85)  # #275: the casing above the lower visitor must clear its head too
	var doorway := _in_a_doorway(here)
	# The points a wall must not stand in front of: the visitor's middle and a margin to either
	# side. A margin point beyond a room's wall from the visitor is dropped: the visitor cannot
	# reach through a wall. In the corner beside the stair hall's chimneypiece return one lay
	# past that return, and the sight line to it took the whole chimneypiece wall away (round 5).
	var subjects: Array[Vector3] = []
	for height in subject_heights:
		var middle: Vector3 = _pos + Vector3(0, height, 0)
		subjects.append(middle)
		for offset in [-0.45, 0.45]:
			var margin: Vector3 = middle + across * offset
			var reached := true
			for wall in _walls:
				if wall.room < 0:
					continue
				for section in wall.boxes:
					if (section as AABB).grow(0.02).intersects_segment(middle, margin) != null:
						reached = false
			if reached:
				subjects.append(margin)
	for wall in _walls:
		var clear := true
		if wall.room >= 0:
			var rule = cut[wall.room]
			clear = not (rule is bool or rule[wall.side])
			if added and _stage_ids[wall.room] != _stage:
				clear = _edge_wall(wall.box, eye, open_set)
		elif added and _stage_ids[wall.at] != _stage:
			clear = false
		# A low case stays: hiding it would bare the unlit floor and the shadow baked under it.
		var low_top := 1.6
		if wall.at >= 0 and _plan[wall.at].label == "Skylight Gallery":
			var floor_y := _skylight_height(_pos)
			if floor_y != -INF:
				low_top = floor_y + 1.6  # #275: cases are low relative to the visitor's floor
		var low: bool = wall.room < 0 and (wall.box as AABB).end.y < low_top
		# The work being read never hides itself, nor does the case it stands in (#272: the
		# sight line to the Seated Woman always passes through her own case).
		var read = _inspect.get("node")
		var holds: bool = read is Node and (wall.body == read or wall.body.is_ancestor_of(read))
		# A room's wall is not "in the way" of a visitor standing in its own doorway: off the
		# doorway's centre line the sight line clips the wall beside the opening, and taking
		# that wall away took the room's whole side with it (round 5, the deep reveals).
		var foot := Rect2(wall.box.position.x, wall.box.position.z, wall.box.size.x, wall.box.size.z)
		var in_its_doorway: bool = (
			wall.room >= 0 and doorway and foot.grow(1.2).has_point(Vector2(_pos.x, _pos.z))
		)
		if clear and wall.layers & shown and not low and not holds and not in_its_doorway:
			for subject in subjects:
				for section in wall.boxes:
					if (section as AABB).intersects_segment(eye, subject) != null:
						clear = false
			if not _inspect.is_empty():
				for section in wall.boxes:
					if (section as AABB).intersects_segment(eye, _inspect.center + _inspect.normal * 0.15) != null:
						clear = false
		var body: Node = wall.body
		# The follow view's opened side takes what stands on it, piece by piece, whichever room
		# owns it: a doorway's reveal is the next room's and lines this one on both sides.
		var lines: bool = own >= 0 and wall.room >= 0 and wall.room != own and foot.intersects(_room_rect(own).grow(0.4))
		for i in range(1, body.get_child_count()):
			var piece := body.get_child(i) as Node3D
			var drawn := clear
			if drawn and lines:
				# A work hung on the wall is a plain node: it is judged by where it hangs.
				var where := AABB(piece.global_position, Vector3.ZERO)
				if piece is VisualInstance3D:
					where = piece.global_transform * (piece as VisualInstance3D).get_aabb()
				drawn = not _on_open_side(where, own, cut[own])
			piece.visible = drawn
	# #275: an upper deck must not cover a visitor walking beside its lower
	# enclosure. These are only this room's named floor / tread meshes.
	_skylight_hidden_decks.clear()
	for part in _skylight_structure:
		var rule = cut[part.room]
		var clear: bool = part.shown and not (rule is bool or (part.side != "" and rule[part.side]))
		var box: AABB = part.box
		if clear and _pos.y < box.position.y - .15:
			for offset in [-.45,0.0,.45]:
				for height in subject_heights:
					if box.intersects_segment(eye,_pos+across*offset+Vector3.UP*height) != null:
						clear = false
		part.node.visible = clear
		if not clear and part.node.has_meta("skylight_landing"):
			_skylight_hidden_decks.append(str(part.node.get_meta("skylight_landing")))
	# The room scene's own rule for ceilings and baked copies, read from walk4's camera.
	if _rooms.has_method("update_baked_visibility"):
		_rooms.set("camera", _cam)
		_rooms.update_baked_visibility()
		if _stage >= 0 and _plan[_stage].label == "Skylight Gallery":
			# #275: the draft ceiling callback can reshow adjacent-room tracks.
			# Keep this stage's visibility after it; lamp geometry is unchanged.
			for ceiling in _rooms.get("ceiling_details"):
				if ceiling is GeometryInstance3D:
					var owner := _room_of(ceiling.global_transform * ceiling.get_aabb())
					if owner >= 0 and _stage_ids[owner] != _stage:
						ceiling.hide()
	if _glide_t < 1.0:
		_cam.global_transform = _glide_from.interpolate_with(_cam.global_transform, _glide_t)
		_cam.fov = lerpf(_glide_fov, _cam.fov, _glide_t)
	# Only the stage: no added room from the Hall, no Hall from an added room.
	if _stage < 0:
		_cam.cull_mask &= ~(NEAR_LAYER | FAR_LAYER)
	else:
		_cam.cull_mask &= ~(63 | PORTAL_LAYER)
		if _plan[_stage].label == PORTAL_ROOM and float(_cutaway_alpha.get(8, 1.0)) > 0.0:
			_cam.cull_mask |= PORTAL_LAYER
	if _floor_mask_stage != _stage:
		_mask_floor()
	_light_doors()
	_seen_cam = _cam.global_transform
	_seen_fov = _cam.fov
	_seen_mask = _cam.cull_mask


# Standing in a doorway: in the depth of a reveal, or within a metre of an opening and in
# its span. The walls about a doorway are not cut away for a visitor who is in it.
func _in_a_doorway(here: int) -> bool:
	if here < 0:
		return absf(_pos.x) <= 1.2 and (_pos.z > -1.0 or _pos.z < -L + 1.0)
	var area: Dictionary = _plan[here]
	if "reveal threshold" in str(area.label):
		return true
	var b: Array = area.b
	for side in area.openings:
		var door: Array = area.openings[side]
		var along := _pos.z if side in ["west", "east"] else _pos.x
		var gap: float = (
			_pos.x - b[0]
			if side == "west"
			else b[1] - _pos.x if side == "east" else _pos.z - b[2] if side == "north" else b[3] - _pos.z
		)
		if along >= door[0] - 0.1 and along <= door[1] + 0.1 and gap < 1.0:
			return true
	return false


func _stage_of(room: int) -> int:
	return -1 if room < 0 else _stage_ids[room]


# A wall two rooms share belongs to one of them. Standing on this stage's edge it is this
# stage's wall as well, and goes only when it is on the camera's side.
func _edge_wall(box: AABB, eye: Vector3, open_set: bool) -> bool:
	var c := Vector2(box.get_center().x, box.get_center().z)
	for i in _plan.size():
		if _stage_ids[i] != _stage:
			continue
		var b: Array = _plan[i].b
		if c.y > b[2] - 0.1 and c.y < b[3] + 0.1:
			if absf(c.x - b[0]) < 0.35:
				return not (open_set and eye.x < b[0])
			if absf(c.x - b[1]) < 0.35:
				return not (open_set and eye.x > b[1])
		if c.x > b[0] - 0.1 and c.x < b[1] + 0.1:
			if absf(c.y - b[2]) < 0.35:
				return not (open_set and eye.z < b[2])
			if absf(c.y - b[3]) < 0.35:
				return not (open_set and eye.z > b[3])
	return false


# Whether a piece of wall stands on a side of room `i` that `rule`, its entry in the cut, has opened.
func _on_open_side(box: AABB, i: int, rule: Dictionary) -> bool:
	var b: Array = _plan[i].b
	var c := box.get_center()
	var in_x: bool = c.x > b[0] - 0.1 and c.x < b[1] + 0.1
	var in_z: bool = c.z > b[2] - 0.1 and c.z < b[3] + 0.1
	return (
		in_z and (rule.west and absf(c.x - b[0]) < 0.35 or rule.east and absf(c.x - b[1]) < 0.35)
		or in_x and (rule.north and absf(c.z - b[2]) < 0.35 or rule.south and absf(c.z - b[3]) < 0.35)
	)


func _build_stages() -> void:
	for i in _plan.size():
		var id := i
		for j in _plan.size():
			if _plan[j].label == JOINED.get(_plan[i].label, ""):
				id = j
		_stage_ids.append(id)
	for node in _vp.get_children():
		if node is WorldEnvironment:
			node.environment.background_color = VOID
	var ground := Shader.new()
	ground.code = (
		"shader_type spatial;\nrender_mode unshaded, cull_disabled, fog_disabled;\n"
		+ VOID_GLSL
		+ """
void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	ALBEDO = ground(world.xz) + dither(FRAGCOORD.xy);
}"""
	)
	_floor_mask = MeshInstance3D.new()
	_floor_mask.material_override = _void_material(ground)
	_floor_mask.layers = VOID_LAYER
	_floor_mask.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_vp.add_child(_floor_mask)
	var shader := Shader.new()
	# Drawn as warm haze, not as an iris of black: the same radius closes and opens it at the
	# same times, but its edge is feathered over more than half the picture and its colour is
	# the doorways' light in fog, thinner and brighter where it has only begun to gather.
	shader.code = """shader_type canvas_item;
uniform float radius = 2.0; // in half-diagonals of the picture
uniform float open_radius = 1.19;
uniform float feather = 0.7;
uniform vec2 reach = vec2(1.0);
uniform vec3 veil; // the haze where it is thin
uniform vec3 heart; // the picture shut, at its middle
uniform vec3 rim; // and at its corners
void fragment() {
	float d = length((UV - 0.5) * reach);
	// Nothing is covered at open_radius, everything at 0. Between, the edge is `feather` wide,
	// narrowing over the last of the way so the middle of the picture goes last, as it did.
	float open = clamp(radius / open_radius, 0.0, 1.0);
	float soft = feather * min(open * 2.5, 1.0);
	float inner = open * (1.0 + soft) - soft;
	float cover = open <= 0.0 ? 1.0 : smoothstep(inner, inner + soft + 0.0001, d);
	vec3 full = mix(heart, rim, smoothstep(0.0, 1.0, d));
	vec3 colour = mix(veil, full, cover * cover);
	colour += (fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0 / 255.0;
	COLOR = vec4(colour, cover);
}"""
	_wipe = ColorRect.new()
	_wipe.material = ShaderMaterial.new()
	_wipe.material.shader = shader
	_wipe.material.set_shader_parameter("open_radius", WIPE_RADIUS)
	_wipe.material.set_shader_parameter("veil", Vector3(WIPE_VEIL.r, WIPE_VEIL.g, WIPE_VEIL.b))
	_wipe.material.set_shader_parameter("heart", Vector3(WIPE_HEART.r, WIPE_HEART.g, WIPE_HEART.b))
	_wipe.material.set_shader_parameter("rim", Vector3(WIPE_RIM.r, WIPE_RIM.g, WIPE_RIM.b))
	_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe.z_index = 50  # over the view buttons, which are added after the rooms
	_wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Shown, fully open, for its first frames: its shader is compiled then, behind the loading
	# screen, and not in the frame the first wipe begins (0.3 s in the engine, more in a browser).
	add_child(_wipe)
	# What the long first hold shows: one still mark, lower right, as nothing can move while
	# the rooms are being built.
	_wipe_mark = Control.new()
	_wipe_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe_mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wipe_mark.draw.connect(
		func() -> void:
			# Middle of the picture, large and near white: round 5 missed a small grey ring
			# in the corner.
			var at := _wipe_mark.size / 2.0
			_wipe_mark.draw_arc(at, 34.0, 0.0, TAU, 48, Color(1, 1, 1, 0.28), 7.0, true)
			_wipe_mark.draw_arc(
				at, 34.0, _wipe_spin - PI / 2.0, _wipe_spin + PI / 2.0, 24, Color(1, 1, 1, 0.97), 7.0, true
			)
	)
	_wipe_mark.hide()
	_wipe.add_child(_wipe_mark)
	_build_doors()


func _build_doors() -> void:
	var beyond := Shader.new()
	beyond.code = (
		"shader_type spatial;\nrender_mode unshaded, cull_disabled, fog_disabled;\n"
		+ VOID_GLSL
		+ """
uniform vec3 sill; // the middle of the doorway's sill, on the wall's plane
uniform vec3 out_dir; // out of the room
uniform float half_width;
uniform float head;
uniform vec3 glow;
void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	// Only what is seen through the opening, from the room's side: never over a wall, never
	// from behind.
	vec3 eye = CAMERA_POSITION_WORLD;
	vec3 ray = world - eye;
	float to_plane = dot(sill - eye, out_dir);
	float along = dot(ray, out_dir);
	if (to_plane <= 0.0 || along <= 0.0001) {
		discard;
	}
	vec3 through = eye + ray * (to_plane / along);
	vec3 across = vec3(-out_dir.z, 0.0, out_dir.x);
	float aside = dot(through - sill, across);
	float up = through.y - sill.y;
	if (abs(aside) > half_width || up < 0.0 || up > head) {
		discard;
	}
	// Light lying on the next floor, brightest at the sill, and the haze it hangs in.
	float depth = max(dot(world - sill, out_dir), 0.0);
	float lateral = max(abs(dot(world - sill, across)) - half_width, 0.0);
	float height = max(world.y - sill.y, 0.0);
	float pool = exp(-depth / 2.4 - lateral / 1.6 - height / 1.4);
	float haze = exp(-up / (0.42 * head));
	ALBEDO = ground(world.xz) + glow * (0.42 * pool + 0.17 * haze) + dither(FRAGCOORD.xy);
}"""
	)
	var fan := Shader.new()
	fan.code = """shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled;
uniform vec3 sill;
uniform vec3 out_dir;
uniform float half_width;
uniform float reach;
uniform vec3 glow;
varying vec3 world;
void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	vec3 across = vec3(-out_dir.z, 0.0, out_dir.x);
	float inward = dot(sill - world, out_dir);
	float aside = abs(dot(world - sill, across));
	float edge = half_width + inward * 0.55;
	float spread = 1.0 - smoothstep(edge * 0.45, edge, aside);
	float fade = exp(-inward / 1.3) * (1.0 - smoothstep(reach * 0.6, reach, inward));
	ALBEDO = glow * 0.4 * spread * fade * step(0.0, inward);
}"""
	# The Hall's own two doorways: its far door and the stone portal.
	var far_door: Vector2 = DOORS.far.size
	var arch: Vector2 = DOORS.arch.size
	_add_door(beyond, fan, -1, Vector3(0, 0, -L), Vector3.FORWARD, far_door.x, far_door.y, far_door.x, 2.6, 16)
	_add_door(beyond, fan, -1, Vector3(0, 0, 0), Vector3.BACK, arch.x, arch.y, arch.x, 2.6, 8)
	var hall := Rect2(-W / 2.0, -L, W, L)
	for i in _plan.size():
		var area: Dictionary = _plan[i]
		var b: Array = area.b
		for side in area.openings:
			var door: Array = area.openings[side]
			var mid: float = (door[0] + door[1]) / 2.0
			var out: Vector3 = SIDES[side]
			var at := Vector3(
				b[0] if side == "west" else b[1] if side == "east" else mid,
				0,
				b[2] if side == "north" else b[3] if side == "south" else mid
			)
			var past := at + out * 0.35
			var next := _room_at(past)
			if next < 0 and not hall.has_point(Vector2(past.x, past.z)):
				continue  # a doorway nobody can go through
			if next >= 0 and _stage_ids[next] == _stage_ids[i]:
				continue  # into the same stage: the next area is drawn
			var floor_y := _skylight_height(at)
			at.y = maxf(floor_y, 0.0) if floor_y != -INF else 0.0
			var width: float = door[1] - door[0]
			var head: float = area.heads[side]
			# A wall's thickness takes the height of the doorway it lines.
			for parent in _plan:
				if parent.label == JOINED.get(area.label, "") and "reveal" in str(area.label):
					head = parent.heads.get(side, head)
			# The stone portal stands in the medieval room: its passage is 1.9 m of this opening.
			var portal: bool = area.label == PORTAL_ROOM and side == "north"
			_add_door(
				beyond, fan, _stage_ids[i], at, out, width, head,
				arch.x if portal else width, PORTAL_MOUTH + 2.6 if portal else 2.6, 0
			)


# One doorway's light: the floor and haze beyond it, and the fan on this side.
func _add_door(
	beyond: Shader, fan: Shader, stage: int, at: Vector3, out: Vector3, width: float, head: float,
	fan_width: float, reach: float, hall_layer: int
) -> void:
	var across := Vector3(-out.z, 0, out.x)
	var glow := Vector3(DOOR_GLOW.r, DOOR_GLOW.g, DOOR_GLOW.b)
	var node := Node3D.new()
	_vp.add_child(node)
	var far_floor := _void_material(beyond)
	var near_floor := ShaderMaterial.new()
	near_floor.shader = fan
	for material in [far_floor, near_floor]:
		material.set_shader_parameter("sill", at)
		material.set_shader_parameter("out_dir", out)
		material.set_shader_parameter("glow", glow)
	far_floor.set_shader_parameter("half_width", width / 2.0)
	far_floor.set_shader_parameter("head", head)
	near_floor.set_shader_parameter("half_width", fan_width / 2.0)
	near_floor.set_shader_parameter("reach", reach)
	# Beyond: the next floor for ten metres, and a wall of haze where it ends.
	var deep := 10.0
	var wide := width / 2.0 + 9.0
	var a := at + Vector3.UP * 0.008
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for quad in [
		[a - across * wide, a + across * wide, a + across * wide + out * deep, a - across * wide + out * deep],
		[
			a - across * wide + out * deep, a + across * wide + out * deep,
			a + across * wide + out * deep + Vector3.UP * 14.0, a - across * wide + out * deep + Vector3.UP * 14.0
		]
	]:
		for corner in [0, 1, 2, 0, 2, 3]:
			tool.add_vertex(quad[corner])
	var light := MeshInstance3D.new()
	light.mesh = tool.commit()
	light.material_override = far_floor
	# On this side: a fan on the floor, added to whatever the floor is.
	var spread := fan_width / 2.0 + reach * 0.55
	var f := at + Vector3.UP * 0.011
	tool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var corners := [f - across * spread, f + across * spread, f + across * spread - out * reach, f - across * spread - out * reach]
	for corner in [0, 1, 2, 0, 2, 3]:
		tool.add_vertex(corners[corner])
	var spill := MeshInstance3D.new()
	spill.mesh = tool.commit()
	spill.material_override = near_floor
	for mesh in [light, spill]:
		mesh.layers = VOID_LAYER
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.add_child(mesh)
	node.hide()
	_doors.append({"stage": stage, "node": node, "at": at, "header": null, "hall_layer": hall_layer, "ground": far_floor})


# Each doorway's light goes with the wall the doorway is in: the header above it, once the rooms
# are built. A doorway through a wall's thickness takes the header at the near end of it.
func _link_doors() -> void:
	for door in _doors:
		var best := 1.0
		for wall in _walls:
			if not str(wall.body.get_meta("room_wall", "")).ends_with(":header"):
				continue
			if wall.room < 0 or _stage_ids[wall.room] != door.stage:
				continue
			var c: Vector3 = (wall.box as AABB).get_center()
			var d := Vector2(c.x - door.at.x, c.z - door.at.z).length()
			if d < best:
				best = d
				door.header = wall.body


# A wall the lightmap left unlit was drawn black: the upper walls of the dark medieval room, the
# connector's dark wall. Every wall surface keeps a little of its own colour whatever the bake
# says, so it reads as that wall in shade.
func _shade_walls() -> void:
	var baked := _rooms.get_node_or_null("BakedRoom")
	if baked == null:
		return
	for surface in baked.get_children():
		if not surface is MeshInstance3D:
			continue
		# A baked surface stands for one authored mesh, or for several merged into it.
		var up: Node = null
		var merged: Array = surface.get_meta("source_paths", [])
		if surface.has_meta("live_cutaway"):
			up = surface.get_meta("live_cutaway")
		elif not merged.is_empty():
			up = _rooms.find_child(str(merged[0]), true, false)
		var wall := false
		while up != null and up != _rooms:
			wall = wall or up.has_meta("room_wall")
			up = up.get_parent()
		var material := surface.get_active_material(0) as StandardMaterial3D
		if (
			not wall
			or material == null
			or material.emission_enabled
			or material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED
		):
			continue
		var c := material.albedo_color
		var peak := maxf(c.r, maxf(c.g, c.b))
		if peak <= 0.0:
			continue
		material.emission_enabled = true
		material.emission = Color(c.r / peak, c.g / peak, c.b / peak) * WALL_SHADE
		# With its plaster where it has one; a bare colour has no texture to multiply by.
		material.emission_texture = material.albedo_texture
		material.emission_operator = (
			BaseMaterial3D.EMISSION_OP_MULTIPLY
			if material.albedo_texture
			else BaseMaterial3D.EMISSION_OP_ADD
		)


# A doorway's light is drawn when its stage is, and its wall is. Called once the walls are set.
func _light_doors() -> void:
	var stage := -1 if _stage == NO_STAGE else _stage
	for door in _doors:
		var seen: bool = door.stage == stage
		if seen and door.hall_layer == 8:
			seen = float(_cutaway_alpha.get(8, 1.0)) > 0.5
		elif seen and door.hall_layer != 0:
			seen = _cam.cull_mask & door.hall_layer != 0
		elif seen and is_instance_valid(door.header):
			seen = door.header.get_child(1).visible
		door.node.visible = seen


func _void_material(shader: Shader) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("void_near", Vector3(VOID_NEAR.r, VOID_NEAR.g, VOID_NEAR.b))
	material.set_shader_parameter("void_far", Vector3(VOID.r, VOID.g, VOID.b))
	material.set_shader_parameter("void_fall", VOID_FALL)
	return material


# The areas of a stage, in x/z. The Hall's is itself, the ground between the portal's stone
# sides and the sill of its far door, which are its own meshes.
func _stage_rects(stage: int) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if stage < 0:
		rects.append(Rect2(-W / 2.0, -L, W, L))
		rects.append(Rect2(-PORTAL_SIDE, 0.0, PORTAL_SIDE * 2.0, PORTAL_MOUTH))
		rects.append(Rect2(-DOORS.far.size.x / 2.0, -L - 0.19, DOORS.far.size.x, 0.19))
	else:
		for i in _plan.size():
			if _stage_ids[i] == stage:
				rects.append(_room_rect(i))
	return rects


# The floor is one mesh under every room. Quads the colour of the void lie over all of it outside
# the stage: warm where they meet the room, darker with distance, so the edge reads as depth.
func _mask_floor() -> void:
	_floor_mask_stage = _stage
	var keep := _stage_rects(_stage)
	var areas := PackedVector4Array()
	for rect in keep:
		var c := rect.get_center()
		areas.append(Vector4(c.x, c.y, rect.size.x / 2.0, rect.size.y / 2.0))
	areas.resize(8)
	for material in _void_materials():
		material.set_shader_parameter("rooms", areas)
		material.set_shader_parameter("room_count", mini(keep.size(), 8))
	_mask_mesh(keep)
	if _stage < 0:
		return
	# The Hall's layers are not drawn from an added room; the visitor's own lamp must still be.
	var fill = _kid.get("_fill")
	if fill is Light3D:
		fill.layers |= VISITOR_LAYER
	for mesh in _vp.find_children("*", "GeometryInstance3D", true, false):
		if (
			mesh.layers & 8
			and not _rooms.is_ancestor_of(mesh)
			and (mesh.global_transform * mesh.get_aabb()).position.z >= -0.01
		):
			mesh.layers |= PORTAL_LAYER


func _void_materials() -> Array:
	var materials := [_floor_mask.material_override]
	for door in _doors:
		materials.append(door.ground)
	return materials


func _mask_mesh(keep: Array[Rect2]) -> void:
	# #275: the stage's dark exterior meets the oak floor below the entry.
	# A y=0 mask would obscure the lower room from its dollhouse camera.
	var mask_y := .004
	if _stage >= 0 and _plan[_stage].label == "Skylight Gallery":
		for patch in _skylight_surfaces:
			mask_y = minf(mask_y, patch.at.y + .004)
	var xs := [-80.0, 80.0]
	var zs := [-100.0, 80.0]
	for rect in keep:
		xs.append_array([rect.position.x, rect.end.x])
		zs.append_array([rect.position.y, rect.end.y])
	xs.sort()
	zs.sort()
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for a in xs.size() - 1:
		for b in zs.size() - 1:
			var cell := Rect2(xs[a], zs[b], xs[a + 1] - xs[a], zs[b + 1] - zs[b])
			var inside := cell.size.x < 0.001 or cell.size.y < 0.001
			for rect in keep:
				inside = inside or rect.grow(0.01).has_point(cell.get_center())
			if inside:
				continue
			for corner in [[0, 0], [1, 0], [1, 1], [0, 0], [1, 1], [0, 1]]:
				tool.add_vertex(
					Vector3(
						cell.position.x + cell.size.x * corner[0],
						mask_y,
						cell.position.y + cell.size.y * corner[1]
					)
				)
	# Walls and a lid at the ground's limits: everything beyond the rooms is this one surface,
	# and the horizon has no seam against the viewport's clear colour.
	var x0: float = xs[0]
	var x1: float = xs[-1]
	var z0: float = zs[0]
	var z1: float = zs[-1]
	var top := 90.0
	for quad in [
		[Vector3(x0, mask_y, z0), Vector3(x1, mask_y, z0), Vector3(x1, top, z0), Vector3(x0, top, z0)],
		[Vector3(x0, mask_y, z1), Vector3(x1, mask_y, z1), Vector3(x1, top, z1), Vector3(x0, top, z1)],
		[Vector3(x0, mask_y, z0), Vector3(x0, mask_y, z1), Vector3(x0, top, z1), Vector3(x0, top, z0)],
		[Vector3(x1, mask_y, z0), Vector3(x1, mask_y, z1), Vector3(x1, top, z1), Vector3(x1, top, z0)],
		[Vector3(x0, top, z0), Vector3(x1, top, z0), Vector3(x1, top, z1), Vector3(x0, top, z1)]
	]:
		for corner in [0, 1, 2, 0, 2, 3]:
			tool.add_vertex(quad[corner])
	_floor_mask.mesh = tool.commit()


func _wipe_begin() -> void:
	_wipe_t = 0.0
	_wipe_cam = _seen_cam
	_wipe_fov = _seen_fov
	_wipe_mask = _seen_mask if _rooms != null else _cam.cull_mask
	_velocity = Vector3.ZERO
	# Straight in from the wall just crossed: the nearest edge of the area now stood in.
	var here := _room_at(_pos)
	var b: Array = _plan[here].b if here >= 0 else [-W / 2.0, W / 2.0, -L, 0.0]
	var gaps := [_pos.x - b[0], b[1] - _pos.x, _pos.z - b[2], b[3] - _pos.z]
	_wipe_dir = [Vector3.RIGHT, Vector3.LEFT, Vector3.BACK, Vector3.FORWARD][gaps.find(gaps.min())]
	# A clicked route carries on through the door and ends where it was clicked; held keys
	# become a short walk straight in, and a second one as the room opens.
	_wipe_routed = not (_path.is_empty() and _target == null)
	if not _wipe_routed:
		_target = _clamp(_pos + _wipe_dir * 1.0)
	var fill = _kid.get("_fill")
	if fill is Light3D:
		_wipe_fill = fill.light_energy
		_wipe_fade = create_tween()
		_wipe_fade.tween_property(fill, "light_energy", 0.0, 0.35)
	# Fully open before it is shown: a wipe that was cut short left its last radius behind.
	(_wipe.material as ShaderMaterial).set_shader_parameter("radius", WIPE_RADIUS)
	_wipe.show()
	print("ROOM_CHANGE ", _stage, " -> ", _stage_of(_room_at(_pos)))


func _wipe_step(delta: float) -> void:
	delta = minf(delta, 0.05)  # the frame after a load is long; the wipe does not skip ahead
	var owed := (_rooms == null and _rooms_path != "") or not _warm_left.is_empty()
	if owed and _wipe_t < WIPE_CLOSE and _wipe_t + delta >= WIPE_CLOSE:
		# The hold stretches while what is left of the rooms is built and drawn once: black,
		# then the mark, then one step a frame, so the mark is on screen through any long step
		# and turns between them.
		(_wipe.material as ShaderMaterial).set_shader_parameter("radius", 0.0)
		_wipe_mask = 0  # the picture is black: drawing the half-built rooms behind it doubled the wait
		_wipe_wait += 1
		if _wipe_wait < 2:
			return
		_wipe_spin += 0.7
		_wipe_mark.queue_redraw()
		_wipe_mark.show()
		if _wipe_wait < 4:
			return
		if _rooms == null:
			if _building == null:
				_begin_rooms()
				return
			_pump_rooms(BUILD_SHARE_MS, true)  # the next steps, or the putting in place after the last
			if _rooms == null:
				return
			_stage = -1  # the Hall is what the wipe closed on
			_stage_pos = _pos
			_enter_space(_wipe_space)
		if not _warm_left.is_empty():
			_warm_step()
			return
		_wipe_t = WIPE_CLOSE - delta
	var before := _wipe_t
	var open_at := WIPE_CLOSE + WIPE_HOLD
	_wipe_t += delta
	if before < WIPE_CLOSE and _wipe_t >= WIPE_CLOSE:
		# Black: the next stage is put up, lit, with the camera already settled.
		_relight()
		_stage = _stage_of(_room_at(_pos))
		_cut_state = 0
		_arrival_view()
		_update_camera(1.0)
	if before < open_at and _wipe_t >= open_at:
		_wipe_mark.hide()
		if not _wipe_routed and _target == null:
			_target = _clamp(_pos + _wipe_dir * 0.6)
	var radius := 0.0
	if _wipe_t < WIPE_CLOSE:
		radius = WIPE_RADIUS * (1.0 - smoothstep(0.0, 1.0, _wipe_t / WIPE_CLOSE))
	elif _wipe_t >= open_at:
		radius = WIPE_RADIUS * smoothstep(0.0, 1.0, (_wipe_t - open_at) / WIPE_OPEN)
	(_wipe.material as ShaderMaterial).set_shader_parameter("radius", radius)
	(_wipe.material as ShaderMaterial).set_shader_parameter("reach", size / (0.5 * size.length()))
	if _wipe_t >= open_at + WIPE_OPEN:
		_wipe_end()


# The arrival picture should show the room. If the wall the view faces is too far off to be
# in it (the Hall seen down its length is floor and a bench), the view turns, in the black, to
# the wall within reach that has the most works on it. Keys act on the picture, as always.
func _arrival_view() -> void:
	if view_mode == 2:
		return
	var here := _room_at(_pos)
	var b: Array = _plan[here].b if here >= 0 else [-W / 2.0, W / 2.0, -L, 0.0]
	var best := view_yaw
	var most := -1
	for turn in [0.0, PI / 2.0, -PI / 2.0, PI]:
		var yaw := wrapf(view_yaw + turn, -PI, PI)
		var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
		var to_wall: float = (
			(b[1] - _pos.x if ahead.x > 0 else _pos.x - b[0])
			if absf(ahead.x) > absf(ahead.z)
			else (b[3] - _pos.z if ahead.z > 0 else _pos.z - b[2])
		)
		if turn == 0.0 and to_wall <= ARRIVAL_WALL:
			return  # the wall it faces is in the picture already
		if to_wall > ARRIVAL_WALL or to_wall < 1.5:
			continue
		var works := 0
		for work in _objects if here >= 0 else _paintings:
			if (here < 0 or work.room == here) and (work.normal as Vector3).dot(ahead) < -0.7:
				works += 1
		if works > most:
			most = works
			best = yaw
	view_yaw = best
	_view_turn_remaining = 0.0


func _relight() -> void:
	if _wipe_fade:
		_wipe_fade.kill()
		_wipe_fade = null
		var fill = _kid.get("_fill")
		if fill is Light3D:
			fill.light_energy = _wipe_fill


func _wipe_end() -> void:
	if _wipe_t < 0.0:
		return
	_wipe_t = -1.0
	_wipe_wait = 0
	_relight()
	_wipe_mark.hide()
	_wipe.hide()


func _cutaway_mask(target: int, blend: float) -> int:
	if _wipe_t >= 0.0 and _wipe_t < WIPE_CLOSE:
		return _wipe_mask  # the Hall's walls keep their fade while the wipe closes
	if _stage >= 0 and _plan[_stage].label == PORTAL_ROOM:
		# The stone portal is the Hall's mesh and followed the Hall's rule, which shows its arch
		# wall only to a view facing north: seen from the east or west the medieval room's north
		# wall stood with a 4.2 m hole in it. There the portal goes with that wall instead: it
		# is cut away only for a dollhouse camera standing north of the room.
		var north_cut := view_mode != 2 and _inspect_t <= 0.0 and _cam.global_position.z < 0.0
		target = (target & ~8) | (0 if north_cut else 8)
	return super(target, blend)


func _click(pt: Vector2) -> void:
	if _wipe_t < 0.0:
		super(pt)


# The camera while a work is being read, and while it glides back from one: from the walking
# view to the inspection shot by _inspect_t. Returns whether it is in that glide or shot.
func _inspect_camera() -> bool:
	if _inspect_t <= 0.0 or (_inspect.is_empty() and _inspect_from == null):
		if _inspect_t <= 0.0:
			_inspect_from = null
		return false
	var shot: Transform3D = _inspect_from if _inspect.is_empty() else _inspect_shot(_inspect)
	if not _inspect.is_empty():
		_inspect_from = shot
	_cam.global_transform = _cam.global_transform.interpolate_with(shot, _inspect_t)
	var beside: bool = _inspect_t < 0.5 or not _inspect.get("covered", false)
	for body in [_kid, _shadow] + _sole_shadows:
		body.visible = beside
	_cam.fov = lerpf(_cam.fov, _inspect_fov, _inspect_t)
	return true


# Inside the Hall looking at a wall, every wall is back: no dollhouse cut-away. But only once
# the lens itself is inside (#280): the glide starts and ends at the walking view, outside the
# wall on the camera's side, and that wall brought back early filled the picture, about 24
# frames going in and 40 coming back.
func _hall_walls_back(also: int) -> void:
	var eye := _cam.global_position
	if Rect2(-W / 2.0, -L, W, L).grow(-0.3).has_point(Vector2(eye.x, eye.z)):
		_cam.cull_mask = _cutaway_mask(63, minf(0.2, get_process_delta_time() * 2.5)) | also | VOID_LAYER


# A change of view glides from where the camera was instead of cutting.
func _set_view(mode: int) -> void:
	_glide_from = _cam.global_transform
	_glide_fov = _cam.fov
	_glide_t = 0.0
	create_tween().tween_property(self, "_glide_t", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	super(mode)


func _room_rect(index: int) -> Rect2:
	var b: Array = _plan[index].b
	return Rect2(b[0], b[2], b[1] - b[0], b[3] - b[2])


func _overlap(shape: PackedVector2Array, area: Rect2) -> bool:
	var box := PackedVector2Array([
		area.position, Vector2(area.end.x, area.position.y), area.end, Vector2(area.position.x, area.end.y)
	])
	return not Geometry2D.intersect_polygons(shape, box).is_empty()
