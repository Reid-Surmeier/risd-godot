## Throwaway #182 physical traversal. Coloured edges are study limits, not walls.
extends Node3D

var body: CharacterBody3D
var visitor: Node3D
var camera: Camera3D
var label: Label
var qa := false
var phase := 0
var elapsed := 0.0
var samples: Array = []
var results: Dictionary = {}
var out_dir := ""
var frame_times: Array = []
var casings: Array[StaticBody3D] = []
var camera_clear := true
var casing_contact := false
var trials := [
	["forward", Vector3(0.55, 0.25, 0.75), Vector3(0, 0, -1.3), false],
	["reverse", Vector3(0, 0.25, -1.3), Vector3(0.55, 0, 0.75), false],
	["right_near_blocked", Vector3(0.93, 0.25, 0.75), Vector3(0.93, 0, -0.5), true],
	["left_near_blocked", Vector3(-0.82, 0.25, 0.34), Vector3(-0.82, 0, -0.5), true],
	["right_far_blocked", Vector3(0.5, 0.25, -0.4), Vector3(1.09, 0, -0.06), true],
	["left_far_blocked", Vector3(-0.82, 0.25, -0.35), Vector3(-0.82, 0, 0.4), true],
	["left_clearance_forward", Vector3(-0.5, 0.25, 0.32), Vector3(-0.5, 0, -0.8), false],
	["left_clearance_reverse", Vector3(-0.5, 0.25, -0.8), Vector3(-0.5, 0, 0.32), false],
	["right_clearance_forward", Vector3(0.5, 0.25, 0.32), Vector3(0.5, 0, -0.8), false],
	["right_clearance_reverse", Vector3(0.5, 0.25, -0.8), Vector3(0.5, 0, 0.32), false],
	["outer_toe_floor_forward", Vector3(-0.8, 0.25, 0.4), Vector3(-0.8, 0, 0.5), false],
	["outer_toe_floor_reverse", Vector3(-0.8, 0.25, 0.5), Vector3(-0.8, 0, 0.4), false],
]

func _ready() -> void:
	qa = "--selfcheck" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
	if OS.has_feature("web"):
		qa = JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa')")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	for patch in data.patches:
		var mesh := ArrayMesh.new()
		var vertices := PackedVector3Array()
		for i in range(1, patch.vertices.size() - 1):
			var triangle := [vec(patch.vertices[0]), vec(patch.vertices[i]), vec(patch.vertices[i + 1])]
			if (triangle[1] - triangle[0]).cross(triangle[2] - triangle[0]).y < 0:
				triangle.reverse()
			# Godot front faces wind clockwise.
			triangle.reverse()
			vertices.append_array(PackedVector3Array(triangle))
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var instance := MeshInstance3D.new()
		instance.mesh = mesh
		instance.material_override = material(Color(patch.color))
		add_child(instance)
		instance.create_trimesh_collision()
	for i in 2:
		var bottom := vec(data.aperture[i])
		var top := vec(data.aperture[i + 2])
		box((bottom + top) * 0.5 + Vector3(-0.11 if i == 0 else 0.11, 0, 0), Vector3(0.22, top.y - bottom.y, 0.18))
	box((vec(data.aperture[2]) + vec(data.aperture[3])) * 0.5 + Vector3(0, 0.10, 0), Vector3(2.1, 0.20, 0.18))
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("202934")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.8
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	add_child(light)
	body = CharacterBody3D.new()
	body.floor_snap_length = 0.18
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.22
	capsule.height = 1.9
	collider.shape = capsule
	collider.position.y = 0.95
	body.add_child(collider)
	add_child(body)
	visitor = load("res://modules/shell/prototype/gallery_walk4/rig/visitor.gd").new()
	visitor.identity = true
	visitor.world_height = 1.75 * 1.17
	add_child(visitor)
	camera = Camera3D.new()
	camera.fov = 30
	add_child(camera)
	camera.current = true
	var layer := CanvasLayer.new()
	add_child(layer)
	label = Label.new()
	label.position = Vector2(20, 18)
	label.add_theme_font_size_override("font_size", 18)
	layer.add_child(label)
	reset(Vector3(0.55, 0.25, 0.75))

func vec(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.cull_mode = BaseMaterial3D.CULL_DISABLED
	return result

func box(at: Vector3, size: Vector3) -> void:
	var node := StaticBody3D.new()
	node.position = at
	var shape := CollisionShape3D.new()
	var cube := BoxShape3D.new()
	cube.size = size
	shape.shape = cube
	node.add_child(shape)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.material_override = material(Color("e6dfcd"))
	node.add_child(visual)
	add_child(node)
	casings.append(node)

func reset(at: Vector3) -> void:
	body.position = at
	body.velocity = Vector3.ZERO
	visitor.position = at
	visitor.reset_contacts()

func _physics_process(delta: float) -> void:
	elapsed += delta
	var direction := Vector3.ZERO
	if qa and phase < trials.size():
		var trial: Array = trials[phase]
		var target: Vector3 = trial[2]
		if elapsed > 0.5:
			direction = target - body.position
			direction.y = 0
			if direction.length() > 0.04:
				direction = direction.normalized()
			else:
				direction = Vector3.ZERO
		if elapsed > 3.0:
			var same_side: bool = body.position.z * trial[1].z > 0.0
			var distance := Vector2(body.position.x - target.x, body.position.z - target.z).length()
			results[trial[0]] = (same_side and distance > 0.2 and casing_contact if trial[3] else distance < 0.06) and body.is_on_floor()
			results[trial[0] + "_camera"] = camera_clear
			samples.append({"trial": trial[0], "position": [body.position.x, body.position.y, body.position.z], "on_floor": body.is_on_floor(), "casing_contact": casing_contact, "camera_clear": camera_clear, "hidden_casings": casings.filter(func(c): return not c.get_child(1).visible).size()})
			capture("phase-%s.png" % phase)
			phase += 1
			elapsed = 0
			if phase < trials.size():
				reset(trials[phase][1])
				camera_clear = true
				casing_contact = false
			else:
				finish()
	elif not qa:
		direction = Vector3(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), 0, float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))).normalized()
		if Input.is_physical_key_pressed(KEY_SPACE):
			reset(Vector3(0.55, 0.25, 0.75))
	body.velocity.x = direction.x * 1.25
	body.velocity.z = direction.z * 1.25
	body.velocity.y -= 9.8 * delta
	body.move_and_slide()
	if qa:
		for i in body.get_slide_collision_count():
			casing_contact = casing_contact or body.get_slide_collision(i).get_collider() in casings
	visitor.position = body.position
	visitor.pose(delta, direction.length() > 0.01, 0.0, direction if direction.length() > 0.01 else Vector3.FORWARD, 0.0)
	var center := body.position + Vector3(0, 1.55, -0.7)
	camera.position = center + Vector3(0, 9.3 * sin(deg_to_rad(35)), 9.3 * cos(deg_to_rad(35)))
	camera.look_at(center)
	# Same cutaway intent as the gallery camera: keep collision, hide the
	# casing visual when it blocks the visitor's centre or shoulder rays.
	for casing in casings:
		casing.get_child(1).visible = true
	for offset in [-0.45, -0.225, 0.0, 0.225, 0.45]:
		for height in [0.5, 1.0, 1.5, 2.0]:
			var subject := body.position + Vector3(offset, height, 0)
			if qa and elapsed > 0.5:
				camera_clear = camera_clear and not camera.is_position_behind(subject) and get_viewport().get_visible_rect().has_point(camera.unproject_position(subject))
			var ray := PhysicsRayQueryParameters3D.create(camera.position, subject)
			ray.exclude = [body.get_rid()]
			for i in 3:
				var hit := get_world_3d().direct_space_state.intersect_ray(ray)
				if hit.is_empty() or hit.collider not in casings:
					if qa and elapsed > 0.5 and not hit.is_empty():
						camera_clear = false
					break
				hit.collider.get_child(1).visible = false
				var excluded := ray.exclude
				excluded.append(hit.rid)
				ray.exclude = excluded
	label.text = "Collection doorway study · WASD move · Space reset\nProvisional scale/floors; patch edges are study limits.\nExisting visitor / 35° gallery camera. No final bake.\n" + (str(phase) + "/" + str(trials.size()) + " checks" if qa else "")
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.doorwayState=" + JSON.stringify({"position": [body.position.x, body.position.y, body.position.z], "on_floor": body.is_on_floor(), "phase": phase, "elapsed": elapsed}))
	if body.position.y < -2 and not qa:
		reset(Vector3(0.55, 0.25, 0.75))

func _process(delta: float) -> void:
	if qa and phase < trials.size():
		frame_times.append(delta * 1000.0)

func capture(filename: String) -> void:
	if not out_dir.is_empty():
		get_viewport().get_texture().get_image().save_png(out_dir.path_join(filename))

func finish() -> void:
	frame_times.sort()
	var report := {"checks": results, "samples": samples, "render_frames": frame_times.size(), "frame_time_p50_ms": frame_times[frame_times.size() / 2], "frame_time_p95_ms": frame_times[int(frame_times.size() * 0.95)], "renderer": RenderingServer.get_video_adapter_name(), "navigation_accepted": false}
	print("DOORWAY_RESULT " + JSON.stringify(report))
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.doorwayResult=" + JSON.stringify(report))
	if not out_dir.is_empty():
		FileAccess.open(out_dir.path_join("walk-result.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
	if not OS.has_feature("web"):
		get_tree().quit(0 if results.values().all(func(p): return p) else 1)
