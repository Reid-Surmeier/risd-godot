## Headless, no GPU:
##   godot --headless --fixed-fps 60 --path <prepared Hall-retained project> -s check_landing.gd [-- --report=<file.json>]
## Holds the emitted geometry.json and the built scene to the coordinator's two corrections, then walks them:
##   D1 landing wall order: medieval WEST, modern door + lion NORTH, white sculpture EAST, no south opening,
##      accepted modern interior turned with its pan order intact.
##   D2 door axis: stair door, tall case and tracery doorway on z 31.765; apostles keep their door offsets;
##      the draft stair block follows the door and the void begins after it.
##   Cutaway: wall-hung work is owned by its wall's visual, so a cut-away wall never leaves it floating.
## Expectations are written out here, not read from the patched scripts.
## Exit 0 pass, 1 assertion failures, 2 run() did not finish (script error or stall).
extends SceneTree

const LANDING := "lion stair landing"
const MODERN := "modern painting gallery"
const MEDIEVAL := "dark medieval room"
const WHITE := "white sculpture gallery threshold study limit"
const STUB := "modern adjoining gallery threshold study limit"
const OPPOSITE := {"west": "east", "east": "west", "north": "south", "south": "north"}
const AXIS := 31.765
# Official museum bytes, hashed from image-work/collection-room-remodel/inventory-catalogue.
const OFFICIAL := {
	"lion-panel-official.jpg": "d6ef49da8416c5f31c53e709f145c0aad01eb2cdb5419931daeb9b8c5360b85b",
	"painting-48.248.jpg": "336f9ed4d44691659bb7c617eaf1317b325f3099a398f6baab448f836917891b",
	"painting-43.255.jpg": "ef45f40a93125cf93a16f949895f88b01322e1ac57f602a797cb3d59afad3b53",
	"painting-1995.043.jpg": "f58e32e3d4ec8d0418ed8b53d9ce372a93e53b617a6582fdff28027679e82a32",
	"painting-57.037.jpg": "3b97b91cb16583c249dd3dad085be42431cdec131170c562fa377e2b2811dcb8",
	"villon-official-original.jpg": "b272d80d04182e6d67ef36ae8ba6a229cd9f8e7330bab0c9a0e116621fe62509",
}
# accession: [position, direction it must face (into the room), owning wall]
const ART := {
	"1995.043": [Vector3(10.78, 1.65, 24.75), Vector3.RIGHT, "modern painting gallery:west"],
	"57.037": [Vector3(12.0, 1.65, 22.38), Vector3.BACK, "modern painting gallery:north"],
	"43.255": [Vector3(13.65, 1.65, 22.38), Vector3.BACK, "modern painting gallery:north"],
	# Braque and Villon back onto the lion wall: its taller landing face is the one the walking camera cuts.
	"48.248": [Vector3(14.2, 1.65, 28.02), Vector3.FORWARD, "lion stair landing:north"],
	"70.058": [Vector3(15.55, 1.65, 28.02), Vector3.FORWARD, "lion stair landing:north"],
}
# The accepted interior pan, clockwise in plan. A turn of the room must not change it.
const PAN := ["1995.043", "57.037", "43.255", "doorway", "window", "case", "window", "70.058", "48.248", "entry"]
var failures := []

func expect(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)

func same(a: Array, b: Array) -> bool:
	return a.size() == b.size() and range(a.size()).all(func(i): return abs(a[i] - b[i]) < 1e-6)

func box_at(scene: Node3D, size: Vector3, at: Vector3) -> Array:
	return scene.casings.filter(func(c): return (c.get_child(0) is CollisionShape3D and c.get_child(0).shape is BoxShape3D
		and c.get_child(0).shape.size.distance_to(size) < 1e-4 and c.global_position.distance_to(at) < 1e-4))

func boxes(scene: Node3D, size: Vector3) -> Array:
	return scene.find_children("*", "MeshInstance3D", true, false).filter(func(m): return m.mesh is BoxMesh and m.mesh.size.distance_to(size) < 1e-4)

func _initialize() -> void:
	# A script error stops run() without stopping the tree; never let that look like a pass or hang a caller.
	create_timer(300).timeout.connect(func():
		print("LANDING_REFIT_CHECK aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func run() -> void:
	var out: String = get_script().resource_path.get_base_dir().path_join("checks.json")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): # not --out=: doorway_walk.gd takes that as a screenshot folder
			out = arg.trim_prefix("--report=")
	var geometry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	var rooms := {}
	for room in geometry.rooms:
		rooms[room.label] = room

	# 1. Emitted plan: the rooms, every opening paired across a shared wall line, no overlaps, one door axis.
	for spec in [[LANDING, [10.55, 16.15, 28.1, 37.615], {"west": [30.915, 32.615], "north": [11.0, 12.7], "east": [29.5, 31.5]}],
			[MEDIEVAL, [.55, 10.55, 28.1, 34.2], {"west": [31.2, 32.33], "north": [3.4355, 7.6645], "east": [30.915, 32.615]}],
			[MODERN, [10.70, 16.70, 22.30, 28.10], {"south": [11.0, 12.7], "north": [15.10, 16.40]}],
			[WHITE, [16.15, 17.65, 29.5, 31.5], {"west": [29.5, 31.5]}],
			[STUB, [15.10, 16.40, 20.70, 22.30], {"south": [15.10, 16.40]}],
			["Grand Gallery", [.55, 10.55, 1.8, 28.1], {"north": [4.55, 6.55], "south": [3.4355, 7.6645]}]]:
		var got: Dictionary = rooms.get(spec[0], {"bounds": [], "openings": {}})
		expect(same(got.bounds, spec[1]), "%s bounds %s, expected %s" % [spec[0], got.bounds, spec[1]])
		expect(got.openings.keys().size() == spec[2].size() and spec[2].keys().all(func(side): return same(got.openings.get(side, []), spec[2][side])),
			"%s openings %s, expected %s" % [spec[0], got.openings, spec[2]])
	var m: Dictionary = rooms[MEDIEVAL].openings
	expect(abs((m.west[0] + m.west[1]) / 2 - AXIS) < 1e-6 and abs((m.east[0] + m.east[1]) / 2 - AXIS) < 1e-6, "tracery doorway and stair door are not on one axis")
	expect(rooms[MODERN].get("boards_across", false) == false, "modern boards must not run across after the turn")
	var void_box: Array = rooms[LANDING].get("floor_void", [0, 0, 0, 0])
	expect(same(void_box, [10.55, 13.55, 33.715, 37.615]) and void_box[2] - rooms[LANDING].openings.get("west", [0, 0])[1] >= .9, "stair void must begin a leaf's length after the stair door's south edge")
	var edge := {"west": 0, "east": 1, "north": 2, "south": 3}
	var pairs := []
	for room in geometry.rooms:
		for side in room.openings:
			var partners: Array = geometry.rooms.filter(func(other): return (other != room and other.openings.has(OPPOSITE[side])
				and abs(other.bounds[edge[OPPOSITE[side]]] - room.bounds[edge[side]]) < 1e-6 and same(other.openings[OPPOSITE[side]], room.openings[side])))
			expect(partners.size() == 1, "%s %s opening %s has %d partners" % [room.label, side, room.openings[side], partners.size()])
			if partners.size() == 1 and room.label < partners[0].label:
				pairs.append([room.label, side, partners[0].label, room.openings[side]])
	for i in geometry.rooms.size():
		for j in range(i + 1, geometry.rooms.size()):
			var p: Array = geometry.rooms[i].bounds
			var q: Array = geometry.rooms[j].bounds
			expect(min(p[1], q[1]) - max(p[0], q[0]) < 1e-8 or min(p[3], q[3]) - max(p[2], q[2]) < 1e-8, "rooms overlap: %s / %s" % [geometry.rooms[i].label, geometry.rooms[j].label])
	var layout: Dictionary = geometry.lion_modern_layout
	expect(layout.get("metric_accepted") == false and layout.get("stair_curve_and_destinations_complete") == false, "no metre or stair destination may be accepted here")
	# The draft flights keep their shape (1.1 m wide, 3.8 m run, 3.2 m rise up and down); only their start moves.
	var stairs: Array = geometry.patches.filter(func(patch): return patch.label.ends_with("stair study")).map(func(patch): return patch.vertices.reduce(func(flat, v): return flat + v, []))
	expect(stairs.size() == 2 and same(stairs[0], [10.7, 0, 33.715, 11.8, 0, 33.715, 11.8, 3.2, 37.515, 10.7, 3.2, 37.515]) and same(stairs[1], [12.2, 0, 33.715, 13.3, 0, 33.715, 13.3, -3.2, 37.515, 12.2, -3.2, 37.515]), "draft stair flights changed shape or are not translated with the door")

	# 2. Official bytes, catalogue metres, and the scratch inventory rows.
	for name in OFFICIAL:
		expect(FileAccess.get_sha256("res://assets/" + name) == OFFICIAL[name], "official bytes changed: " + name)
	var catalogue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/catalogue-objects.json"))
	expect(same(catalogue.meshes["lion-panel"].size_m, [2.286, 1.041, .08]), "lion catalogue metres changed")
	var rows := {}
	for row in catalogue.instances:
		rows[row.asset] = row
	expect(same(rows["apostle-41046"].position, [12.33, 1.04, 30.465]) and same(rows["apostle-41045"].position, [12.33, 1.04, 33.215]) and same(rows["apostle-41046"].size_m, [.267, .826, .12])
		and same(rows["apostle-41045"].size_m, [.254, .864, .12]), "apostle inventory rows are not the two-row patch (z 30.465 and 33.215, catalogue sizes kept)")

	# 3. Built scene, with the coordinator's retained Hall.
	var scene: Node3D = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var built := {}
	var main: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://main-build-source.json"))
	var hall: Node3D = scene.get_node_or_null("ConnectedHall")
	var kept: Array = main.source_sha256.keys().filter(func(path): return not path.ends_with(".import"))
	expect(scene.get_script().resource_path == "res://retained_hall_room.gd" and hall != null and hall.position == Vector3(5.55, 0, 28.1)
		and hall.find_children("*", "MeshInstance3D", true, false).filter(func(mesh): return mesh.has_meta("retained_main_hall")).size() == 139
		and scene.inventory.get("main_hall_rebuilt") == false and scene.inventory.get("main_hall_verified_paintings") == 23, "original Hall is not the retained main-build Hall")
	expect(kept.size() > 100 and kept.all(func(path): return FileAccess.get_sha256("res://" + path) == main.source_sha256[path]), "a retained Main Hall source file changed")
	built["hall"] = {"script": scene.get_script().resource_path, "source_tip": main.source_tip, "unchanged_source_files": kept.size()}
	var owners := {}
	for wall in scene.casings:
		var tag: String = wall.get_meta("room_wall", "")
		if tag.ends_with(":header") or (tag in [LANDING + ":north", MODERN + ":south"] and wall.position.x < 12.7) or (tag == MODERN + ":north" and wall.position.x > 15.1):
			continue
		owners[tag] = wall.get_child(1)
	var meshes: Array = scene.find_children("*", "MeshInstance3D", true, false)
	# Lion: catalogue slab on the landing north wall, facing south, right of the modern door, clear of the corner.
	var lions: Array = meshes.filter(func(node): return node.get_meta("catalogue_asset", "") == "lion-panel")
	var lion_wall: Node3D = owners.get(LANDING + ":north")
	var hung := []
	expect(lions.size() == 1 and lion_wall != null, "expected one lion panel on one north wall span, found %d" % lions.size())
	if lions.size() == 1 and lion_wall != null:
		var lion: MeshInstance3D = lions[0]
		var box: AABB = lion.global_transform * lion.mesh.get_aabb()
		expect(lion.global_position.distance_to(Vector3(14.6, 1.18, 28.18)) < 1e-4, "lion is at %s" % lion.global_position)
		expect(lion.global_transform.basis.z.distance_to(Vector3.BACK) < 1e-4 and lion.global_transform.basis.x.distance_to(Vector3.RIGHT) < 1e-4, "lion must face south into the landing, unmirrored")
		expect(box.size.distance_to(Vector3(2.286, 1.041, .08)) < 1e-4 and abs(box.get_center().y - 1.7005) < 1e-4, "lion catalogue front 2.286 x 1.041 m or centre height changed")
		expect(box.position.x > 12.7 + .3 and box.end.x < 16.15 - .3 and box.position.z >= 28.16 - 1e-4, "lion must sit right of the modern door with label/corner margin, proud of the wall")
		var mount: Array = box_at(scene, Vector3(2.446, 1.201, .035), Vector3(14.6, 1.7005, 28.158))
		var vents: Array = boxes(scene, Vector3(1.65, .18, .03))
		var strips: Array = boxes(scene, Vector3(2.446, .08, .045)) + boxes(scene, Vector3(.08, 1.201, .045))
		expect(mount.size() == 1 and vents.size() == 1 and vents[0].global_position.distance_to(Vector3(14.6, 3.32, 28.19)) < 1e-4 and vents[0].get_child_count() == 7 and strips.size() == 4, "lion mount, four frame strips or vent are not with the lion")
		hung = [lion] + mount + vents + strips
		expect(hung.all(func(node): return node.get_parent() == lion_wall), "lion, mount, frame strips and vent must be owned by the landing north wall visual")
		built["lion"] = {"position": [lion.global_position.x, lion.global_position.y, lion.global_position.z], "faces": "south", "x_span": [box.position.x, box.end.x],
			"margin_to_door_m": box.position.x - 12.7, "margin_to_corner_m": 16.15 - box.end.x}
	# Door leaves: medieval pair on the axis, modern pair on the north wall, white pair on the east wall.
	var leaves: Array = scene.casings.filter(func(c): return (c.global_position.x > 10.5 and c.global_position.z > 27 and c.get_child(0) is CollisionShape3D and c.get_child(0).shape is BoxShape3D
		and c.get_child(0).shape.size.distance_to(Vector3(.90, 2.70, .065)) < 1e-4))
	built["leaves"] = leaves.map(func(c): return [c.global_position.x, c.global_position.z, abs(c.global_transform.basis.x.z) > .5])
	for want in [[11.0, 27.65, true], [12.7, 27.65, true], [16.6, 29.5, false], [16.6, 31.5, false], [11.0, 30.915, false], [11.0, 32.615, false]]:
		expect(built.leaves.any(func(leaf): return abs(leaf[0] - want[0]) < 1e-4 and abs(leaf[1] - want[1]) < 1e-4 and leaf[2] == want[2]), "no door leaf at %s" % [want])
	expect(leaves.size() == 6 and leaves.all(func(c): return c.find_children("*", "MeshInstance3D", true, false).filter(func(bar): return bar.mesh is BoxMesh and bar.mesh.size.distance_to(Vector3(.66, .045, .04)) < 1e-4).size() == 2),
		"expected six landing leaves (medieval, modern, white), each with two push bars; found %d" % leaves.size())
	# D2: EXIT sign, tall case and apostles on or about the axis; the low case stays where it was.
	var signs: Array = boxes(scene, Vector3(.05, .17, .40))
	expect(signs.size() == 1 and signs[0].global_position.distance_to(Vector3(10.45, 3.17, AXIS)) < 1e-4, "EXIT sign is not over the stair door")
	var tall: Array = box_at(scene, Vector3(1.05, .88, .90), Vector3(8.05, .44, AXIS))
	var low: Array = box_at(scene, Vector3(2.0, .88, 1.15), Vector3(5.45, .44, 31.95))
	expect(tall.size() == 1 and low.size() == 1, "tall case is not on the door axis, or the low case moved")
	built["cases"] = {"tall_x": [8.05 - .525, 8.05 + .525], "tall_z": [AXIS - .45, AXIS + .45], "low_x": [4.45, 6.45], "low_z": [31.375, 32.525], "aisle_between_m": 8.05 - .525 - 6.45, "tall_to_stair_door_m": 10.55 - 8.05 - .525}
	built["apostles"] = {}
	for spec in [["apostle-41046", 30.465, 30.915 - 30.465], ["apostle-41045", 33.215, 33.215 - 32.615]]:
		var found: Array = meshes.filter(func(node): return node.get_meta("catalogue_asset", "") == spec[0])
		expect(found.size() == 1 and found[0].global_position.distance_to(Vector3(10.38, 1.04, spec[1])) < 1e-4 and box_at(scene, Vector3(.32, .18, .36), Vector3(10.42, .95, spec[1])).size() == 1
			and boxes(scene, Vector3(.025, 1.52, .42)).any(func(plate): return abs(plate.global_position.z - spec[1]) < 1e-4), "%s, its bracket or backplate is not at z %s" % [spec[0], spec[1]])
		built.apostles[spec[0]] = {"z": spec[1], "to_door_edge_m": spec[2], "to_room_corner_m": min(spec[1] - 28.1, 34.2 - spec[1])}
	# Stair block: 36 treads and the guard, translated; floor in front of the moved door; nothing over the void.
	var treads: Array = boxes(scene, Vector3(1.1, .06, 3.8 / 18 + .015))
	var tread_z: Array = treads.map(func(t): return t.global_position.z)
	expect(treads.size() == 36 and tread_z.min() > 33.715 and tread_z.max() < 37.515 and box_at(scene, Vector3(.09, 1.04, 3.9), Vector3(13.52, .52, 35.665)).size() == 1, "draft flights or guard are not translated with the door")
	var landing_floor: Array = scene.get_children().filter(func(f): return (f is MeshInstance3D and f.material_override is ShaderMaterial and f.material_override.shader.resource_path.ends_with("floor_oak.gdshader")
		and f.mesh.get_aabb().get_center().x > 10.55 and f.mesh.get_aabb().get_center().x < 13.55 and f.mesh.get_aabb().get_center().z > 28.1 and f.mesh.get_aabb().get_center().z < 37.615))
	expect(landing_floor.any(func(f): return f.mesh.get_aabb().get_center().z > 32.7) and landing_floor.all(func(f): return f.mesh.get_aabb().end.z < 33.715 + 1e-4), "landing floor must reach past the moved door and stop at the void")
	built["void"] = {"starts_z": void_box[2], "door_south_edge_z": 32.615, "gap_m": void_box[2] - 32.615, "basis": "authored 1.1 m gap kept; draft shape, not a measurement"}
	# Art: transform, facing, owning wall.
	var b: Array = rooms[MODERN].bounds
	var centre := Vector2((b[0] + b[1]) / 2, (b[2] + b[3]) / 2)
	var around := {"doorway": [], "entry": [], "window": [], "case": []}
	var works := {}
	built["paintings"] = {}
	for accession in ART:
		var found: Array = scene.find_children("*", "Node3D", true, false).filter(func(node): return node.get_meta("catalogue_accession", "") == accession)
		expect(found.size() == 1, "%s: expected one painting, found %d" % [accession, found.size()])
		if found.size() != 1:
			continue
		var work: Node3D = found[0]
		works[accession] = work
		expect(work.global_position.distance_to(ART[accession][0]) < 1e-4, "%s is at %s" % [accession, work.global_position])
		expect(work.global_transform.basis.z.distance_to(ART[accession][1]) < 1e-4, accession + " does not face into the room")
		expect(owners.has(ART[accession][2]) and work.get_parent() == owners[ART[accession][2]], "%s is not owned by the %s visual" % [accession, ART[accession][2]])
		around[accession] = [Vector2(work.global_position.x, work.global_position.z)]
		built.paintings[accession] = {"position": [work.global_position.x, work.global_position.y, work.global_position.z], "faces": [ART[accession][1].x, ART[accession][1].z], "outer_m": [work.outer.x, work.outer.y]}
	# Windows: exactly two, on the east wall, owned by that wall's visual so its cutaway hides them.
	var east: Array = scene.casings.filter(func(wall): return wall.get_meta("room_wall", "") == MODERN + ":east")
	var windows: Array = meshes.filter(func(node): return node.has_meta("modern_window"))
	windows.sort_custom(func(l, r): return l.global_position.z < r.global_position.z)
	expect(east.size() == 1 and windows.size() == 2, "expected two windows on one unbroken east wall, found %d on %d" % [windows.size(), east.size()])
	built["windows"] = windows.map(func(w): return [w.global_position.x, w.global_position.y, w.global_position.z])
	around.window = windows.map(func(w): return Vector2(w.global_position.x, w.global_position.z))
	var radiators := []
	if east.size() == 1 and windows.size() == 2:
		for i in 2:
			var window: MeshInstance3D = windows[i]
			expect(window.global_position.distance_to(Vector3(16.624, 1.98, [23.45, 26.75][i])) < 1e-4 and window.get_parent() == east[0].get_child(1), "window %d is off the east wall or not owned by its visual" % i)
			var pane: AABB = window.global_transform * window.mesh.get_aabb()
			var own: Array = window.get_children().filter(func(node): return node is StaticBody3D and node in scene.casings)
			expect(pane.size.distance_to(Vector3(.018, 1.78, 1.20)) < 1e-4 and own.size() == 1 and abs(own[0].global_position.z - window.global_position.z) < 1e-4
				and abs(own[0].global_position.x - 16.58) < 1e-4, "window %d pane or radiator cover is not turned to the east wall" % i)
			radiators += own
		east[0].get_child(1).visible = false
		expect(not windows[0].is_visible_in_tree() and not windows[1].is_visible_in_tree(), "east wall cutaway must hide its windows")
		# What update_baked_visibility reads for a casing nested under a wall visual.
		expect(radiators.all(func(r): return not r.get_child(1).is_visible_in_tree()), "baked rule input: radiator covers must read hidden with their wall")
		east[0].get_child(1).visible = true
	# Case and figure.
	var seated: StaticBody3D = scene.get_node_or_null("SeatedWomanCase")
	expect(seated != null and seated in scene.casings, "Seated Woman case missing or outside the cutaway list")
	if seated != null:
		var figure: MeshInstance3D = seated.get_child(3)
		var surface = figure.material_override.get("albedo_texture")
		expect(seated.position.distance_to(Vector3(16.64, 0, 24.85)) < 1e-5 and abs(seated.rotation.y + PI / 2) < 1e-5, "case is at %s yaw %s" % [seated.position, seated.rotation.y])
		expect(figure.get_meta("catalogue_accession", "") == "67.089" and figure.mesh.get_aabb().size.distance_to(Vector3(.203, .711, .241)) < .0005, "figure is not the catalogue-bounded 67.089")
		expect(figure.global_transform.basis.z.distance_to(Vector3.LEFT) < 1e-5 and figure.global_transform.basis.x.distance_to(Vector3.BACK) < 1e-5, "figure must face west into the room, as turned from the accepted layout")
		expect(surface != null and surface.resource_path == "res://assets/seated-woman-bronze.webp", "Muse bronze surface was not kept")
		around.case.append(Vector2(seated.position.x, seated.position.z))
		built["case"] = {"position": [seated.position.x, seated.position.y, seated.position.z], "yaw": seated.rotation.y}
	# Pan order: bearings about the room centre, clockwise in plan from the large painting.
	for side in rooms[MODERN].openings:
		var mid: float = (rooms[MODERN].openings[side][0] + rooms[MODERN].openings[side][1]) / 2
		var at := Vector2(mid, b[edge[side]]) if side in ["north", "south"] else Vector2(b[edge[side]], mid)
		around["doorway" if rooms.has(STUB) and rooms[STUB].openings.has(OPPOSITE[side]) else "entry"].append(at)
	var ring := []
	for key in around:
		for at in around[key]:
			ring.append([atan2(at.x - centre.x, centre.y - at.y), key])
	var start: Array = ring.filter(func(item): return item[1] == PAN[0])
	if start.size() == 1:
		ring.sort_custom(func(l, r): return fposmod(l[0] - start[0][0], TAU) < fposmod(r[0] - start[0][0], TAU))
	built["pan_clockwise"] = ring.map(func(item): return item[1])
	expect(built.pan_clockwise == PAN, "interior pan order changed: %s" % [built.pan_clockwise])
	# Bench, tracks, ceiling, boards, wall spans, and nothing left where the old modern room was.
	var bench: Array = box_at(scene, Vector3(.80, .13, 2.20), Vector3(13.7, .40, 25.35))
	expect(bench.size() == 1 and bench[0].get_child_count() == 6, "bench with four legs is not turned along the large-painting wall")
	var tracks: Array = scene.ceiling_details.filter(func(t): return t.mesh is BoxMesh and t.mesh.size.distance_to(Vector3(.025, .025, 5.0)) < 1e-4)
	expect(same(tracks.map(func(t): return t.position.x), [12.2, 13.7, 15.2]) and tracks.all(func(t): return (abs(t.position.z - 25.2) < 1e-4 and t.get_child_count() == 4
		and t.get_children().all(func(f): return f.global_position.z > b[2] and f.global_position.z < b[3]))), "three ceiling tracks must run along the large-painting wall inside the room")
	var ceiling: Array = scene.ceiling_details.filter(func(c): return c.get_meta("opaque_ceiling", "") == MODERN)
	expect(ceiling.size() == 1 and ceiling[0].position.distance_to(Vector3(centre.x, 3.52, centre.y)) < 1e-4 and ceiling[0].mesh.size.distance_to(Vector3(6, .04, 5.8)) < 1e-4, "modern ceiling does not cover the turned room")
	var boards: Array = scene.get_children().filter(func(f): return (f is MeshInstance3D and f.material_override is ShaderMaterial and f.material_override.shader.resource_path.ends_with("floor_oak.gdshader")
		and f.mesh.get_aabb().get_center().x > b[0] and f.mesh.get_aabb().get_center().x < b[1] and f.mesh.get_aabb().get_center().z > b[2] and f.mesh.get_aabb().get_center().z < b[3]))
	expect(boards.size() > 100 and boards.all(func(f): return f.mesh.get_aabb().size.x < .15), "modern boards must run north-south, away from the entry")
	var spans := {}
	for wall in scene.casings:
		var tag: String = wall.get_meta("room_wall", "")
		if (tag.begins_with(MODERN) or tag.begins_with(LANDING)) and not tag.ends_with(":header"):
			spans[tag] = spans.get(tag, 0) + 1
	built["wall_spans"] = spans
	expect(spans == {LANDING + ":west": 2, LANDING + ":north": 2, LANDING + ":east": 2, LANDING + ":south": 1, MODERN + ":south": 2, MODERN + ":north": 2, MODERN + ":west": 1, MODERN + ":east": 1}, "wall spans %s" % spans)
	var stale := []
	for node in scene.find_children("*", "Node3D", true, false):
		if not (node is MeshInstance3D or node is StaticBody3D) or scene.visitor.is_ancestor_of(node) or node.has_meta("retained_main_hall"):
			continue
		var p: Vector3 = node.global_position
		if (p.x > 17.8 and p.z > 28.3) or (p.x > 16.3 and p.z > 31.7) or p.z > 37.8:
			stale.append("%s %s" % [node.name, p])
	expect(stale.is_empty(), "%d authored nodes remain in the old modern footprint or beyond the landing, e.g. %s" % [stale.size(), stale.slice(0, 4)])
	var listed: Dictionary = scene.inventory.get("modern_gallery", {})
	expect(listed.get("entry_wall") == "south" and listed.get("window_wall") == "east" and listed.get("large_painting_wall") == "west" and listed.get("placement_accepted") == false, "inventory wall names or acceptance flag are wrong")
	# Bake mapping, when remodel_bake.gd has been run on this project: every baked surface names one live mesh,
	# and the re-parented lion and paintings are among them at their live transforms.
	if ResourceLoader.exists("res://addition_baked/room.tscn"):
		var by_name := {}
		for mesh in meshes:
			if not scene.visitor.is_ancestor_of(mesh):
				by_name[mesh.name] = by_name.get(mesh.name, []) + [mesh]
		var baked: Node = load("res://addition_baked/room.tscn").instantiate()
		var sources := {}
		for surface in baked.get_children():
			if surface is MeshInstance3D and surface.has_meta("source_path"):
				sources[surface.get_meta("source_path")] = surface
		var hung_meshes: Array = hung.filter(func(node): return node is MeshInstance3D)
		for accession in works:
			hung_meshes += works[accession].find_children("*", "MeshInstance3D", true, false)
		expect(sources.keys().all(func(key): return by_name.get(key, []).size() == 1), "a baked surface does not name exactly one live mesh")
		expect(hung_meshes.size() > 10 and hung_meshes.all(func(mesh): return sources.has(mesh.name) and sources[mesh.name].transform.is_equal_approx(mesh.global_transform)), "a re-parented lion or painting mesh is missing from the bake sources or baked at another transform")
		built["bake_mapping"] = {"baked_surfaces": sources.size(), "reparented_meshes_matched": hung_meshes.size(), "note": "UV2 prepare only; no lightmap baked, baked cutaway not exercised"}
		baked.free()
	else:
		built["bake_mapping"] = "addition_baked/room.tscn not present; not checked"

	# 4. Walk: the moved stair door each way, the cases, both new landing openings each way, the far doorway,
	# bench and stair void blocked, the old stair-door position and the south wall closed.
	scene.trials = scene.trials.filter(func(t): return t[0].contains("modern") or t[0].contains("landing") or t[0].begins_with("stairs_door") or t[0].begins_with("medieval_"))
	scene.trials.append(["old_stair_door_position_closed", Vector3(9.75, .25, 30.05), Vector3(11.3, 0, 30.05), true])
	scene.trials.append(["landing_south_wall_closed", Vector3(14.9, .25, 36.4), Vector3(14.9, 0, 38.4), true])
	scene.trials.append(["aisle_between_cases", Vector3(6.85, .25, 33.0), Vector3(6.85, 0, 30.8), false])
	# Two authored walks end inside the retained Hall's portal guard (x 6.5..7.64, z 28.54..30.31) with or
	# without this patch; they are recorded, and the aisle between the cases is walked short of the guard instead.
	var guarded := ["medieval_between_cases_clear", "medieval_stairs_aisle_clear"]
	var names: Array = scene.trials.map(func(t): return t[0])
	for name in ["stairs_door_out", "stairs_door_back", "medieval_tall_case_blocked", "medieval_low_case_blocked", "medieval_between_cases_clear", "medieval_stairs_aisle_clear", "landing_to_modern", "modern_to_landing",
			"landing_white_out", "landing_white_back", "modern_far_opening_out", "modern_far_opening_back", "modern_bench_blocked", "landing_guard_blocked"]:
		expect(name in names, "trial missing from geometry.json: " + name)
	for want in [["stairs_door_out", Vector3(9.75, .25, AXIS), Vector3(11.3, 0, AXIS), false], ["medieval_tall_case_blocked", Vector3(8.05, .25, 30.565), Vector3(8.05, 0, 32.115), true],
			["landing_to_modern", Vector3(11.85, .25, 29.75), Vector3(11.85, 0, 26.55), false], ["landing_white_out", Vector3(14.95, .25, 30.5), Vector3(17.0, 0, 30.5), false],
			["landing_guard_blocked", Vector3(13.9, .25, 35.415), Vector3(12.9, 0, 35.415), true]]:
		expect(scene.trials.any(func(t): return t[0] == want[0] and t[1].distance_to(want[1]) < 1e-5 and t[2].distance_to(want[2]) < 1e-5 and t[3] == want[3]), want[0] + " is not the expected walk")
	# A last row the runner never finishes, so it cannot quit the tree before this report is written.
	scene.trials.append(["hold", scene.trials[0][1], scene.trials[0][1], false])
	scene.phase = 0
	scene.elapsed = 0
	scene.results = {}
	scene.samples = []
	scene.reset(scene.trials[0][1])
	scene.qa = true
	while scene.phase < names.size():
		await physics_frame
	scene.qa = false
	for name in names:
		expect(name in guarded or scene.results.get(name, false), "walk trial failed: " + name)
	built["walks_not_judged"] = {"trials": guarded, "reason": "blocked by retained_hall_room.gd portal guard, also on BASE"}

	# 5. Cutaway, as the 35-degree walking camera computes it (unbaked). Stand the visitor on a grid and ask,
	# after the scene's own ray pass: is any wall-hung work drawn while the wall the camera looks through is cut?
	if lions.size() == 1 and lion_wall != null and works.size() == 5 and owners.has(MODERN + ":south") and owners.has(MODERN + ":north"):
		var south_wall: Node3D = owners[MODERN + ":south"]
		var north_wall: Node3D = owners[MODERN + ":north"]
		var sweep := {"samples": 0, "landing_north_wall_cut": 0, "modern_south_wall_cut": 0, "modern_north_wall_cut": 0, "lion_wall_cut_while_modern_south_drawn": 0, "modern_south_cut_while_lion_wall_drawn": 0,
			"lion_floating": [], "reverse_art_exposed": [], "front_art_floating": []}
		var spots := []
		for x in [11.85, 12.9, 14.6, 15.8]:
			for i in 50:
				spots.append(Vector3(x, .25, 22.8 + i * .1))
		for x in [15.35, 15.75]:
			for i in 12:
				spots.append(Vector3(x, .25, 20.95 + i * .1))
		for spot in spots:
			if abs(spot.x - 13.7) < .7 and abs(spot.z - 25.35) < 1.4: # inside the bench
				continue
			scene.reset(spot)
			for i in 2:
				await physics_frame
			sweep.samples += 1
			sweep.landing_north_wall_cut += int(not lion_wall.visible)
			sweep.modern_south_wall_cut += int(not south_wall.visible)
			sweep.modern_north_wall_cut += int(not north_wall.visible)
			sweep.lion_wall_cut_while_modern_south_drawn += int(not lion_wall.visible and south_wall.visible)
			sweep.modern_south_cut_while_lion_wall_drawn += int(lion_wall.visible and not south_wall.visible)
			if not lion_wall.visible and hung.any(func(node): return (node.get_child(1) if node is StaticBody3D else node).is_visible_in_tree()):
				sweep.lion_floating.append([spot.x, spot.z])
			if not lion_wall.visible and (works["48.248"].is_visible_in_tree() or works["70.058"].is_visible_in_tree()):
				sweep.reverse_art_exposed.append([spot.x, spot.z])
			if not north_wall.visible and (works["57.037"].is_visible_in_tree() or works["43.255"].is_visible_in_tree()):
				sweep.front_art_floating.append([spot.x, spot.z])
		expect(sweep.landing_north_wall_cut > 20 and sweep.lion_wall_cut_while_modern_south_drawn > 0, "sweep did not exercise the lion-wall cutaway: %s cuts" % sweep.landing_north_wall_cut)
		expect(sweep.lion_floating.is_empty(), "lion, mount, frame or vent drawn over a cut-away wall at %d positions" % sweep.lion_floating.size())
		expect(sweep.reverse_art_exposed.is_empty(), "Braque or Villon drawn from behind through the cut-away lion wall at %d positions" % sweep.reverse_art_exposed.size())
		expect(sweep.front_art_floating.is_empty(), "Matisse or Cezanne drawn over a cut-away north wall at %d positions" % sweep.front_art_floating.size())
		scene.reset(Vector3(14.6, .25, 30.5))
		for i in 2:
			await physics_frame
		expect(lion_wall.visible and lions[0].is_visible_in_tree(), "lion must be drawn for a visitor standing in the landing")
		built["cutaway_sweep"] = sweep
	var report := {
		"project": ProjectSettings.globalize_path("res://"), "godot": Engine.get_version_info().string, "gpu_used": false,
		"renderer": "headless dummy; camera-clear flags from the walk are recorded, not judged",
		"rooms": {LANDING: rooms.get(LANDING), MEDIEVAL: rooms.get(MEDIEVAL), MODERN: rooms.get(MODERN), WHITE: rooms.get(WHITE), STUB: rooms.get(STUB)}, "opening_pairs": pairs,
		"inventory_rows": {"apostle-41046": rows["apostle-41046"].position, "apostle-41045": rows["apostle-41045"].position, "lion-panel": rows["lion-panel"].position},
		"built": built, "walk_trials": scene.results, "trial_samples": scene.samples,
		"native_review_bake_browser": "not run here: no renderer; root owns them",
		"failures": failures, "passed": failures.is_empty(),
	}
	FileAccess.open(out, FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print("LANDING_REFIT_CHECK " + JSON.stringify({"passed": failures.is_empty(), "failures": failures, "walk_trials": scene.results}))
	quit(0 if failures.is_empty() else 1)
