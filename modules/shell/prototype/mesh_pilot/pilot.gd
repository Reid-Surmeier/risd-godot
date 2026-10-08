## PROTOTYPE #263: one generated mesh in the game's light, camera and display, beside the visitor.
## Standalone on purpose: the room pipeline is not touched (#264 gives rooms a way to place a mesh).
##   godot --path . --rendering-driver opengl3 --resolution 960x642 res://modules/shell/prototype/mesh_pilot/pilot.tscn -- <mesh.glb> <setting> <view> <out.png>
##   mesh.glb: a res:// path      setting: wall | plinth      view: game | front | threequarter | side
## "game" is the game's own camera through its 480 px display; the other three stand closer and are not shrunk.
extends Control

# where it stands; where the visitor stands; what it stands on [centre, size, colour] or []
const SETTINGS := {
	"wall": {"at": Vector3(0, 0, 0), "visitor": Vector3(1.75, 0, 1.0), "stand": []},
	# rockefeller_additions.gd vincennes(): the central pedestal is 1.1 x 1.1 x .65, the group .24 off its centre
	"plinth": {"at": Vector3(-.24, 1.1, 1.2), "visitor": Vector3(.85, 0, 1.3), "stand": [Vector3(0, .55, 1.2), Vector3(1.1, 1.1, .65), Color("ecebe6")]},
}
## Ticket #263 asks for "the 0.9 m visitor"; remodel_room.gd make_visitor() on this branch still says 1.75.
const VISITOR_HEIGHT := 0.9
var world: Node3D
var visitor: Node3D
var out := ""
var frames := 0

func look(color: Color) -> StandardMaterial3D:  # remodel_room.gd look()
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = .95
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m

func box(at: Vector3, size: Vector3, color: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.mesh = BoxMesh.new()
	visual.mesh.size = size
	visual.material_override = look(color)
	visual.position = at
	world.add_child(visual)

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var spec: Dictionary = SETTINGS[args[1]]
	var view: String = args[2]
	out = args[3]
	# remodel_presenter.gd: the game is a SubViewport about 480 px wide, enlarged through the GameCube copy filter.
	var game := SubViewportContainer.new()
	game.size = size
	game.stretch = true
	game.stretch_shrink = maxi(1, roundi(size.x / 480.0)) if view == "game" else 1  # the closer looks are not shrunk, so the form can be judged
	game.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	game.material = ShaderMaterial.new()
	game.material.shader = load("res://modules/shell/collection_rooms/presentation/gamecube.gdshader")
	add_child(game)
	var port := SubViewport.new()
	port.own_world_3d = true
	port.msaa_3d = Viewport.MSAA_2X
	game.add_child(port)
	world = Node3D.new()
	port.add_child(world)
	# remodel_room.gd _ready(): the rooms' light before the bake replaces it.
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("e4e0d5")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("fff0d9")
	environment.environment.ambient_light_energy = .55
	world.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_color = Color("fff1d9")
	light.light_energy = .65
	world.add_child(light)
	box(Vector3(0, -.05, 2), Vector3(12, .1, 10), Color("e4e1d8"))  # marble_hall_additions.gd MarbleFloorLight
	box(Vector3(0, 2.25, -.05), Vector3(12, 4.5, .1), Color("e2dfd6"))  # its plaster wall
	if not spec.stand.is_empty():
		box(spec.stand[0], spec.stand[1], spec.stand[2])
	var mesh: Node3D = load(args[0]).instantiate()
	mesh.position = spec.at
	world.add_child(mesh)
	var bounds := AABB()
	var triangles := 0
	for part in mesh.find_children("*", "MeshInstance3D", true, false):
		for i in part.mesh.get_surface_count():
			var m: BaseMaterial3D = part.mesh.surface_get_material(i).duplicate()
			m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED  # the rooms' look()
			part.set_surface_override_material(i, m)
			triangles += part.mesh.surface_get_array_len(i) if part.mesh.surface_get_array_index_len(i) == 0 else part.mesh.surface_get_array_index_len(i) / 3
			print("material metallic ", m.metallic, " roughness ", m.roughness, " texture ", m.albedo_texture.get_size() if m.albedo_texture else null)
		bounds = part.global_transform * part.mesh.get_aabb()
	print("mesh triangles ", triangles, " size ", bounds.size, " at ", bounds.position)
	visitor = load("res://modules/shell/character/visitor.gd").new()  # the accepted visitor of the owner's screenshots
	visitor.world_height = VISITOR_HEIGHT
	visitor.position = spec.visitor
	world.add_child(visitor)
	var camera := Camera3D.new()
	camera.fov = 30  # doorway_walk.gd
	world.add_child(camera)
	camera.current = true
	if view == "game":  # doorway_walk.gd _physics_process(): 9.3 m back, 35 degrees up, aimed over the visitor's head
		var centre: Vector3 = spec.visitor + Vector3(0, 1.55, -.7)
		camera.position = centre + Vector3(0, 9.3 * sin(deg_to_rad(35)), 9.3 * cos(deg_to_rad(35)))
		camera.look_at(centre)
	else:  # a closer look round the object, level with it, same light and display
		var yaw: float = {"front": 0.0, "threequarter": 50.0, "side": 88.0}[view]
		var centre := bounds.get_center()
		var reach := maxf(bounds.size.y, bounds.size.x) * 2.4 + .3
		camera.position = centre + Vector3(sin(deg_to_rad(yaw)), .22, cos(deg_to_rad(yaw))).normalized() * reach
		camera.look_at(centre)

func _physics_process(delta: float) -> void:
	visitor.pose(delta, false, 0.0, Vector3.BACK, 0.0)

func _process(_delta: float) -> void:
	frames += 1
	if frames == 30:
		get_viewport().get_texture().get_image().save_png(out)
		print("saved ", out)
		get_tree().quit()
