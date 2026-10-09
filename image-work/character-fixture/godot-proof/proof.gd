extends SceneTree
## THROWAWAY fixture230: isolated GLB import, real clip evaluation and keyed dust.
class DustEvent extends Node3D:
	var calls := 0
	var skeleton: Skeleton3D
	var foot := -1
	var dust: CPUParticles3D
	var shoe_point := Vector3.ZERO
	func footstep() -> void:
		calls += 1
		shoe_point = skeleton.global_transform * skeleton.get_bone_global_pose(foot).origin
		dust.global_position = Vector3(shoe_point.x + 0.16, 0.08, shoe_point.z + 0.12)
		dust.restart()
		dust.emitting = true

var results := {"cost_usd": 0, "browser_tested": false, "visual_acceptance": "pending"}

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://" + name + ".png")

func run() -> void:
	root.size = Vector2i(512, 512)
	var stage := Node3D.new()
	root.add_child(stage)
	var model = load("res://fixture.glb").instantiate()
	stage.add_child(model)
	await process_frame
	var skeleton: Skeleton3D = model.find_children("*", "Skeleton3D", true, false)[0]
	var player: AnimationPlayer = model.find_children("*", "AnimationPlayer", true, false)[0]
	assert(skeleton.get_bone_count() == 41)
	assert(player.get_animation_list().size() == 76)
	assert(player.has_animation("Idle") and player.has_animation("Walking_A"))
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.callback_mode_method = AnimationMixer.ANIMATION_CALLBACK_MODE_METHOD_IMMEDIATE
	var foot := skeleton.find_bone("foot.l")
	assert(foot >= 0)
	results["godot"] = Engine.get_version_info().string
	results["bones"] = skeleton.get_bone_count()
	results["imported_animations"] = player.get_animation_list().size()
	results["idle_seconds"] = player.get_animation("Idle").length
	results["walk_seconds"] = player.get_animation("Walking_A").length
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12,12)
	floor.mesh = plane
	floor.position.y = -0.02
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.43, 0.4, 0.34)
	floor.material_override = material
	stage.add_child(floor)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.7
	stage.add_child(camera)
	camera.position = Vector3(-2.5, 2.5, 5.5)
	camera.look_at(Vector3(0,1.02,0))
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.3
	sun.rotation_degrees = Vector3(-45, -25, 0)
	stage.add_child(sun)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.17,0.2,0.24)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color(0.7,0.7,0.7)
	world.environment.ambient_light_energy = 0.6
	stage.add_child(world)
	player.play("Idle")
	player.advance(0.25)
	skeleton.force_update_all_bone_transforms()
	var idle_foot := skeleton.get_bone_global_pose(foot)
	await capture("idle")
	player.play("Walking_A")
	player.advance(0.1)
	skeleton.force_update_all_bone_transforms()
	var first := skeleton.get_bone_global_pose(foot)
	player.advance(0.3)
	skeleton.force_update_all_bone_transforms()
	var second := skeleton.get_bone_global_pose(foot)
	assert(not first.is_equal_approx(second), "Walking_A left foot stayed static")
	assert(not idle_foot.is_equal_approx(second), "walk pose equals idle")
	results["walk_changes_foot"] = true
	results["idle_to_walk_changes_foot"] = true
	await capture("walk")
	# Author a single effect key after sampling the clip's low ankle position.
	# This demonstrates an event, not measured world-space stance/ground contact.
	var event_time := 0.0
	var low := INF
	for index in range(1,31):
		var t := index / 30.0
		player.seek(t, true)
		skeleton.force_update_all_bone_transforms()
		var y := skeleton.get_bone_global_pose(foot).origin.y
		if y < low:
			low = y
			event_time = t
	player.seek(event_time + 0.01, true)
	await capture("dust-control")
	var event := DustEvent.new()
	event.name = "DustEvent"
	event.skeleton = skeleton
	event.foot = foot
	player.get_node(player.root_node).add_child(event)
	var dust := CPUParticles3D.new()
	dust.amount = 10
	dust.lifetime = 0.8
	dust.one_shot = true
	dust.explosiveness = 1.0
	dust.emitting = false
	dust.local_coords = false
	dust.direction = Vector3.UP
	dust.spread = 70
	dust.initial_velocity_min = 0.12
	dust.initial_velocity_max = 0.35
	dust.gravity = Vector3(0,-0.3,0)
	var puff := SphereMesh.new()
	puff.radius = 0.04
	puff.height = 0.08
	dust.mesh = puff
	var dust_material := StandardMaterial3D.new()
	dust_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dust_material.albedo_color = Color(0.95,0.83,0.61)
	dust.material_override = dust_material
	stage.add_child(dust)
	event.dust = dust
	var animated: Animation = player.get_animation("Walking_A").duplicate()
	animated.loop_mode = Animation.LOOP_NONE
	var track := animated.add_track(Animation.TYPE_METHOD)
	animated.track_set_path(track, NodePath("DustEvent"))
	animated.track_insert_key(track, event_time, {"method": &"footstep", "args": []})
	player.get_animation_library("").add_animation("WalkDustProof", animated)
	player.play("WalkDustProof")
	player.advance(0)
	# Step across the key once; then hold the keyed pose for the particle capture.
	while player.current_animation_position < event_time + 0.01:
		player.advance(1.0/60.0)
		await process_frame
	assert(event.calls == 1, "effect key did not fire exactly once")
	assert(dust.emitting, "particle burst did not emit")
	assert(Vector2(dust.global_position.x-event.shoe_point.x,dust.global_position.z-event.shoe_point.z).length() < 0.21)
	await create_timer(0.15).timeout
	await capture("dust")
	player.advance(1.0)
	assert(event.calls == 1, "single clip effect fired again")
	player.play("Idle")
	player.advance(0.3)
	assert(event.calls == 1, "idle emitted a footstep")
	results["effect_event_seconds"] = event_time
	results["effect_event_calls"] = event.calls
	results["effect_idle_control_calls"] = event.calls
	results["effect_shoe_point"] = str(event.shoe_point)
	results["effect_kind"] = "one authored method key emits a one-shot CPUParticles3D burst"
	results["contact_quality_tested"] = false
	FileAccess.open("res://evidence.json",FileAccess.WRITE).store_string(JSON.stringify(results,"  ") + "\n")
	print("GODOT_FIXTURE_PROOF ",JSON.stringify(results))
	quit(0)
