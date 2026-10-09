extends Node3D


func _ready() -> void:
	var room = load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate()
	add_child(room)
	for mesh in room.find_children("*", "MeshInstance3D", true, false):
		var material = mesh.material_override
		if (
			material is StandardMaterial3D
			and material.albedo_texture
			and material.albedo_texture.resource_path.ends_with("/door-arch.jpg")
		):
			mesh.hide()
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("#20242a")
	world.environment.ambient_light_energy = 0.0
	if (
		OS.has_feature("web")
		and JavaScriptBridge.eval(
			"new URLSearchParams(location.search).get('background') === 'magenta'"
		)
	):
		world.environment.background_color = Color.MAGENTA
	add_child(world)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 2.1, 6.5)
	camera.fov = 54
	add_child(camera)
	camera.look_at(Vector3(0, 2.1, 1.6))
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.passageReady=true")
