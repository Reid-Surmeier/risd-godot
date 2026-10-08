## The fixture of placed_mesh_check.gd: one mesh placed with place_mesh() on clear floor in the
## grey French gallery. It is the visitor's own model, already in the repository, standing in for
## a work 1.8 m tall: over 1.6 m the camera may cut a body away, which is the case that once hid
## a mesh from its own inspection. No shipped room builds it: remodel_room.gd loads this only when
## the run was started with --placed-mesh-fixture.
extends RefCounted

const KEY := "placed-mesh-fixture"
const HEIGHT := 1.8

func build(room) -> void:
	var at: Vector3 = room.wall_point("grey French gallery", "north", 2.85, 0, 2.85)
	var node: Node3D = room.place_mesh("res://modules/shell/character/walk.glb", at, 0.0, Vector3(0, HEIGHT, 0), KEY)
	node.set_meta("catalogue_title", "Placed mesh fixture")
