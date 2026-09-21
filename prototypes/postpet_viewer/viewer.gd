## The small, self-contained scan viewer used only by the PostPet layout study.
extends Control

const SIZE := Vector2(800, 680)
const MODEL := "res://prototypes/postpet_viewer/assets/assets/models/proton-buddha-3124123123.glb"
const TEXTURE := "res://prototypes/postpet_viewer/assets/assets/models/3124123123.jpg"

var yaw := -132.48
var pitch := -8.0
var distance := 8.7
var camera: Camera3D
var dragging := false
var last_pointer := Vector2.ZERO


func _ready() -> void:
	size = SIZE
	var plate := TextureRect.new()
	plate.texture = load("res://prototypes/postpet_viewer/assets/assets/clean-ui/background.png")
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.size = SIZE
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)
	var viewport_container := SubViewportContainer.new()
	viewport_container.position = Vector2(134, 78)
	viewport_container.size = Vector2(529, 486)
	viewport_container.gui_input.connect(_viewport_input)
	add_child(viewport_container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(529, 486)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	viewport_container.add_child(viewport)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#f8f8fa")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9e1e7")
	environment.ambient_light_energy = 0.82
	var world := WorldEnvironment.new()
	world.environment = environment
	viewport.add_child(world)
	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-42, -28, 0)
	key_light.light_energy = 1.15
	key_light.shadow_enabled = true
	key_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	viewport.add_child(key_light)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-3.5, 2.5, 4.0)
	fill.light_color = Color("#dcebf4")
	fill.light_energy = 0.52
	fill.omni_range = 10.0
	viewport.add_child(fill)
	var sculpture := Node3D.new()
	sculpture.rotation_degrees.y = -144.0
	viewport.add_child(sculpture)
	var scene := load(MODEL) as PackedScene
	if scene != null:
		var model := scene.instantiate()
		sculpture.add_child(model)
		var material := StandardMaterial3D.new()
		material.albedo_texture = load(TEXTURE)
		material.metallic = 0.32
		material.roughness = 0.38
		_apply_material(model, material)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(7, 7)
	floor.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("#f7f7f9")
	floor_material.roughness = 0.9
	floor.material_override = floor_material
	viewport.add_child(floor)
	camera = Camera3D.new()
	camera.fov = 36
	viewport.add_child(camera)
	_update_camera()


func _apply_material(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child in node.get_children():
		_apply_material(child, material)


func _viewport_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_pointer = event.position
			if event.double_click:
				yaw = -132.48
				pitch = -8.0
				distance = 8.7
				_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(2.8, distance - 0.45)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(10.5, distance + 0.45)
			_update_camera()
	elif event is InputEventMouseMotion and dragging:
		var movement: Vector2 = event.position - last_pointer
		last_pointer = event.position
		yaw += movement.x * 0.35
		pitch = clampf(pitch + movement.y * 0.25, -55, 45)
		_update_camera()


func _update_camera() -> void:
	if camera == null:
		return
	var rotation := Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(yaw), 0))
	camera.position = Vector3(0, 2.25, 0) + rotation * Vector3(0, 0, distance)
	camera.look_at(Vector3(0, 2.25, 0))
