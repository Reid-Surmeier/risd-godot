## #277: IMG_6343 84–228s. Source measurements and the fixed-door fit are in
## docs/evidence/impressionist-277/NOTES.md; missing works keep their walls bare.
extends RefCounted

const PASSAGE := "Impressionist passage"
const RETURN := "Impressionist passage return"
const A := "Impressionist gallery A"
const B := "Impressionist gallery B"
const YAW := {"north": 0.0, "south": PI, "west": PI / 2, "east": -PI / 2}

var room


func build(target) -> void:
	room = target
	for spec in [[PASSAGE, 3.2, "b4b1a9"], [RETURN, 3.2, "b4b1a9"], [A, 3.69, "a8a9a8"], [B, 3.5, "a8a9a8"]]:
		finish_shell(spec[0], spec[1], Color(spec[2]))
	# 89.5s: grey stone at the stair sill, then straight oak. Floor collision is the plan patch.
	var stone: Material = room.look(Color("bdbcb8"))
	room.solid(Vector3(18.85, .012, -1.96), Vector3(2.0, .012, 1.10), stone)
	room.inventory["impressionist"] = {
		"rooms": [PASSAGE, RETURN, A, B], "filmed_works": 17, "hung_works": 0,
		"metric_accepted": false, "lighting_complete": false,
		"physical_museum_plan_accepted": false
	}


func finish_shell(label: String, height: float, tone: Color) -> void:
	var paint: StandardMaterial3D = room.look(tone, "res://presentation/neutral-plaster.png")
	paint.cull_mode = BaseMaterial3D.CULL_BACK
	for wall in room.casings:
		if str(wall.get_meta("room_wall", "")).begins_with(label + ":"):
			wall.get_child(1).material_override = paint
	var b: Array = room.room_bounds(label)
	var ceiling: MeshInstance3D = room.solid(
		Vector3((b[0] + b[1]) / 2, height + .02, (b[2] + b[3]) / 2),
		Vector3(b[1] - b[0], .04, b[3] - b[2]),
		room.look(Color("ebe9e3"), "res://presentation/neutral-plaster.png")
	)
	ceiling.set_meta("opaque_ceiling", label)
	room.ceiling_details.append(ceiling)
	# Reuse the white kit without changing its profile or the other rooms' trim.
	for spec in [["north", b[1] - b[0]], ["south", b[1] - b[0]], ["west", b[3] - b[2]], ["east", b[3] - b[2]]]:
		var cornice: MeshInstance3D = room.moulding(spec[1], .20, "door-architrave", false)
		cornice.position = room.wall_point(label, spec[0], spec[1] / 2, height - .10, .065)
		cornice.rotation.y = YAW[spec[0]]
		cornice.set_meta("opaque_ceiling", label)
		room.ceiling_details.append(cornice)
