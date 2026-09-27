extends SceneTree

## godot --rendering-method gl_compatibility --path . --script res://modules/shell/prototype/gallery_walk4/identity/native_render_check.gd
const HOME := "res://modules/shell/prototype/gallery_walk4/identity/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.7
	camera.position = Vector3(2.5, 2.8, 5.0)
	stage.add_child(camera)
	camera.look_at(Vector3(0, 1.0, 0))
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -25, 0)
	light.light_energy = 1.5
	stage.add_child(light)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.35, 0.33, 0.31)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.5, 0.45, 0.4)
	environment.environment.ambient_light_energy = 0.7
	stage.add_child(environment)
	var floor := MeshInstance3D.new()
	floor.mesh = PlaneMesh.new()
	floor.scale = Vector3(4, 1, 4)
	floor.position.y = -0.025
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.42, 0.32, 0.23)
	floor.material_override = floor_mat
	stage.add_child(floor)
	for source in ["visitor_identity.glb", "Rogue.source.glb"]:
		var character = load(HOME + source).instantiate()
		stage.add_child(character)
		var player: AnimationPlayer = character.find_children("*", "AnimationPlayer", true, false)[0]
		player.play("Idle")
		await process_frame
		await process_frame
		var image := root.get_viewport().get_texture().get_image()
		var output := "visitor_identity_godot.png" if source == "visitor_identity.glb" else "rogue_control_godot.png"
		image.save_png(ProjectSettings.globalize_path(HOME + output))
		print("RENDER ", source, " ", image.get_width(), "x", image.get_height())
		character.queue_free()
		await process_frame
	quit()
