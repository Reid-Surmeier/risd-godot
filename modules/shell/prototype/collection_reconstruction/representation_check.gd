## The built museum against modules/shell/collection_rooms/representation.json: every work a
## visitor can click is declared there under its key, in the room it stands in, and a work is
## declared a mesh exactly when the room placed it with place_mesh(). The floor itself (which
## declarations are allowed) is scripts/check_museum_records.py; this is the half that needs the scene.
## godot --headless --path . --script res://modules/shell/prototype/collection_reconstruction/representation_check.gd
extends SceneTree

const MANIFEST := "res://modules/shell/collection_rooms/representation.json"
const HALL := "Grand Gallery"
const MESHES := ["mesh", "stand_in_mesh"]


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(960, 640)
	root.add_child(walk)
	for i in 240:
		await process_frame
	var declared: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST)).objects
	var failures: Array = []
	var built := {}
	var registered: Array = []
	for thing in walk._paintings:
		built[str(thing.rec.acc)] = {"room": HALL, "placed": false}
	for thing in walk._objects:
		registered.append(thing.node)
		built[str(thing.tag).get_slice("#", 0)] = {"room": walk._plan[thing.room].label, "placed": thing.node.has_meta("placed_mesh")}
	for key in built:
		if not declared.has(key):
			failures.append("%s (%s) is in the build and not declared" % [key, built[key].room])
			continue
		var row: Dictionary = declared[key]
		if row.room != built[key].room:
			failures.append("%s is declared in %s and stands in %s" % [key, row.room, built[key].room])
		if (row.as in MESHES) != built[key].placed:
			failures.append("%s is declared as %s but %s" % [key, row.as, "was placed with place_mesh()" if built[key].placed else "no place_mesh() put it there"])
	for key in declared:
		if not built.has(key):
			failures.append(key + " is declared and not in the build")
	# Catalogued in the room code but never registered: no visitor can click them, and nothing
	# here declares them. Reported so the number is seen; registering them is its own work.
	var unregistered: Array = []
	for node in walk._rooms.find_children("*", "Node3D", true, false):
		if not (node.has_meta("catalogue_accession") or node.has_meta("catalogue_asset")):
			continue
		var covered := false
		for other in registered:
			covered = covered or other == node or other.is_ancestor_of(node) or node.is_ancestor_of(other)
		if not covered:
			unregistered.append(str(node.get_meta("catalogue_accession", node.get_meta("catalogue_asset", ""))))
	unregistered.sort()
	print("REPRESENTATION_CHECK ", JSON.stringify({"built": built.size(), "declared": declared.size(), "unregistered": unregistered, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
