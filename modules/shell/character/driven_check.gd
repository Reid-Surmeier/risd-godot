extends SceneTree
var demo: Node3D
var evidence := {}


func _initialize() -> void:
	create_timer(40).timeout.connect(func(): quit(1))
	call_deferred("run")


func frames(count: int) -> void:
	for i in count:
		await physics_frame


func run() -> void:
	demo = load("res://modules/shell/character/demo.gd").new()
	root.add_child(demo)
	await frames(3)
	assert(demo.camera != null and demo.soles.size() > 500)
	assert(demo.tool_rotations.Axe.size() == 8 and demo.tool_rotations.Net.size() == 4)
	assert(demo.tool_meshes.Axe.global_basis.get_scale().distance_to(Vector3.ONE) < .0001)
	assert(demo.has_method("jump"), "Missing playable jump animation")
	var steps_before: int = demo.footprint_count
	demo.jump()
	await frames(22)
	assert(demo.body.position.y > .4 and not demo.body.is_on_floor())
	var jumps_before: int = demo.jumps
	demo.jump()
	assert(demo.jumps == jumps_before, "Midair jump repeated")
	assert(demo.footprint_count == steps_before)
	await frames(60)
	assert(demo.body.is_on_floor() and demo.jump_time < 0 and demo.landings == 1)
	evidence.jump = {
		"grounded_launch": true,
		"midair_retrigger_blocked": true,
		"airborne_steps": 0,
		"landings": demo.landings,
		"authored_adaptation": true
	}
	# Change floor height: landing posing must follow contact rather than the original clip clock.
	var platform: Node3D = demo.block(Vector3(0, .4, 0), Vector3(2, .8, 2), Color("809769"), true)
	demo.reset()
	demo.body.position = Vector3(0, .8, 0)
	await frames(4)
	assert(demo.body.is_on_floor())
	demo.jump()
	await frames(22)
	demo.body.position.x = 3
	assert(not demo.body.is_on_floor() and demo.landings == 1)
	await frames(60)
	assert(
		demo.body.is_on_floor() and demo.body.position.y < .005 and demo.landings == 2,
		"Landing did not follow lower floor contact"
	)
	await frames(30)
	assert(demo.jump_time < 0 and demo.jump_stage == "Ground")
	evidence.jump.different_height_landing = true
	platform.queue_free()
	await frames(2)
	demo.reset()
	var raised: Node3D = demo.block(
		Vector3(0, .225, 2.5), Vector3(3, .45, 1.8), Color("809769"), true
	)
	Input.action_press("down")
	await frames(20)
	demo.jump()
	var contacted := false
	for tick in 70:
		await frames(1)
		if demo.jump_landed and demo.body.position.y > .4:
			contacted = true
	Input.action_release("down")
	assert(contacted, "Missing elevated-platform contact")
	evidence.jump.elevated_contact = true
	raised.queue_free()
	await frames(2)
	demo.set_physics_process(false)
	demo.reset()
	demo.surface = "Grass"
	demo.state = "Dash"
	demo.body.velocity = Vector3(0, 0, 1)
	demo.footstep("Right")
	assert(demo.dust.size() == 1, "Dry DASH must emit one puff per foot")
	var puff: Dictionary = demo.dust[0]
	assert(puff.node.mesh.size == Vector2(.75, .75) and demo.dust_textures[0].get_width() == 16)
	for i in 8:
		demo._physics_process(1.0 / 60)
	assert(is_equal_approx(puff.node.material_override.albedo_color.a, 200 / 255.0))
	assert(puff.node.scale == Vector3.ONE)
	var expected: Vector3 = (
		puff.origin + (puff.velocity * 8 + puff.acceleration * 36) * puff.source_unit
	)
	assert(
		puff.node.position.distance_to(expected) < .00001,
		"Dust motion must use source update order"
	)
	for i in 8:
		demo._physics_process(1.0 / 60)
	assert(puff.node.material_override.albedo_color.a == 0)
	for i in 2:
		demo._physics_process(1.0 / 60)
	assert(demo.dust.is_empty(), "Dust persists after 18 updates")
	var payloads := []
	for ground in ["Water", "Leaves", "Snow", "Sand"]:
		var bytes: PackedByteArray = demo.surface_textures[ground].get_image().get_data()
		for other in payloads:
			assert(bytes != other, "Terrain effect silhouettes reused")
		payloads.append(bytes)
	evidence.dust = {
		"puffs_per_dry_contact": 1,
		"duration_updates": 18,
		"invisible_at_update": 16,
		"source_motion_and_alpha": true,
		"authored_masks": true,
		"distinct_terrain_payloads": 4,
		"quad_size_m": .75
	}
	demo.reset()
	demo.set_physics_process(true)

	Input.action_press("down")
	await frames(30)
	assert(demo.state == "Run")
	evidence.normal = {
		"speed": Vector2(demo.body.velocity.x, demo.body.velocity.z).length(),
		"phase": demo.movement.phase,
		"animation_rate": demo.player.get_playing_speed()
	}
	Input.action_press("sprint")
	await frames(30)
	assert(demo.state == "Dash" and demo.emitted > 0)
	evidence.dash = {
		"speed": Vector2(demo.body.velocity.x, demo.body.velocity.z).length(),
		"effects": demo.emitted
	}
	var skid_births: int = demo.emitted
	Input.action_release("down")
	Input.action_press("up")
	await frames(2)
	assert(demo.state == "Skid" and demo.body.velocity.z > 0)
	assert(demo.emitted > skid_births)
	assert(demo.audio_history[-1].id == 0x4129 and demo.audio_history[-1].bank == "Skid")
	evidence.reversal = {
		"state": demo.state,
		"travel_heading": demo.movement.heading,
		"shape_heading": demo.movement.shape_heading
	}
	Input.action_release("up")
	Input.action_release("sprint")
	await frames(100)
	assert(demo.state == "Idle")
	var births: int = demo.emitted
	var sounds: int = demo.audio_history.size()
	await frames(40)
	assert(demo.emitted == births and demo.audio_history.size() == sounds)
	demo.reset()
	var analog := InputEventJoypadMotion.new()
	analog.axis = JOY_AXIS_LEFT_Y
	analog.axis_value = .45
	Input.parse_input_event(analog)
	await frames(25)
	assert(demo.state == "Walk" and absf(demo.movement.velocity - 4.875 * .45) < .01)
	evidence.analog = {
		"input_magnitude": .45, "velocity": demo.movement.velocity, "gait": demo.state
	}
	analog.axis_value = 0
	Input.parse_input_event(analog)
	await frames(20)
	demo.reset()
	demo.body.position = Vector3(0, 0, 15.3)
	Input.action_press("down")
	Input.action_press("sprint")
	await frames(100)
	assert(demo.body.position.z < 15.7 and demo.state == "Idle")
	births = demo.emitted
	await frames(45)
	assert(demo.emitted == births)
	Input.action_release("down")
	Input.action_release("sprint")
	evidence.wall = {"position": demo.body.position.z, "effects_stopped": true}
	demo.reset()
	demo.cycle_tool()
	await frames(3)
	assert(demo.tool == "Axe" and demo.tool_meshes.Axe.visible)
	demo.cycle_tool()
	await frames(3)
	assert(demo.tool == "Net" and demo.tool_meshes.Net.visible)
	evidence.tools = {
		"axe_bones": 8, "net_bones": 4, "world_scale": demo.tool_meshes.Axe.global_basis.get_scale()
	}
	demo.reset()
	demo.body.position = Vector3(-2, 0, -1.2)
	demo.interact()
	await frames(5)
	assert(demo.dialogue == 1 and demo.state == "Idle")
	var point: Vector3 = demo.body.position
	Input.action_press("down")
	await frames(10)
	Input.action_release("down")
	assert(demo.body.position.distance_to(point) < .0001)
	demo.interact()
	await frames(5)
	assert(demo.interaction == "Receive")
	demo.interact()
	await frames(3)
	assert(demo.dialogue == 0)
	evidence.dialogue = {"faces_partner": true, "movement_locked": true, "receipt_pose": true}
	demo.body.position = Vector3(0, 0, -6.5)
	demo.interact()
	await frames(100)
	assert(demo.indoor and demo.door_transitions == 1)
	assert(demo.audio_history.slice(-4).map(func(cue): return cue.requested_id) == [6, 7, 8, 9])
	demo.body.position = Vector3(40, 0, -3)
	demo.interact()
	await frames(110)
	assert(not demo.indoor and demo.door_transitions == 2)
	assert(demo.audio_history.slice(-4).map(func(cue): return cue.requested_id) == [6, 7, 8, 9])
	evidence.door = {"enter_exit": true, "transition_count": demo.door_transitions}
	for ground in ["Grass", "Indoor", "Snow", "Water", "Sand", "Leaves"]:
		demo.reset()
		demo.surface = ground
		Input.action_press("down")
		Input.action_press("sprint")
		births = demo.emitted
		await frames(45)
		Input.action_release("down")
		Input.action_release("sprint")
		assert((demo.emitted == births) if ground == "Indoor" else (demo.emitted > births))
		evidence[ground] = {
			"effect_events": demo.emitted - births, "footsteps": demo.footprint_count
		}
	demo.reset()
	demo.surface = "Grass"
	Input.action_press("down")
	births = demo.emitted
	await frames(45)
	Input.action_release("down")
	assert(demo.emitted == births)
	demo.raining = true
	Input.action_press("down")
	births = demo.emitted
	await frames(45)
	Input.action_release("down")
	assert(demo.emitted > births and demo.step_history[-1].surface == "Water")
	evidence.rain = {"normal_gait_water_events": demo.emitted - births}
	demo.raining = false
	await frames(90)
	assert(demo.face_blinks > 0 and demo.max_floor_error < .0001)
	evidence.blink = {"events": demo.face_blinks, "shader": demo.face_material != null}
	evidence.clearance = {"maximum_error": demo.max_floor_error, "world_stance_lock": false}
	FileAccess.open("res://driven-check.json", FileAccess.WRITE).store_string(
		JSON.stringify(evidence, "  ")
	)
	print("PASS driven rig/gaits/reversal/wall/tools/dialogue/door/surface/blink checks")
	demo.free()
	demo = null
	# Fixed simulation frames do not advance the mixer wall clock. Drain its stop request.
	OS.delay_msec(100)
	quit()
