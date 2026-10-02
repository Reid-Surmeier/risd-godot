extends SceneTree
## Exercise actual contact dispatch and the native mixer, rather than receipt strings.
var demo: Node3D
var capture: AudioEffectCapture
var events := []
var silent := 0
var sample_peak := 0.0
var raised := {"Left": false, "Right": false}
var swing_peak := {"Left": 0.0, "Right": 0.0}


func _initialize() -> void:
	call_deferred("run")


func tick() -> void:
	var prior: int = demo.audio_history.size()
	demo._physics_process(1.0 / 60)
	var fresh: Array = demo.audio_history.slice(prior)
	if demo.state in ["Walk", "Run", "Dash"] and demo.body.is_on_floor():
		var expected := []
		for side in ["Left", "Right"]:
			var clearance := INF
			for sole in demo.soles:
				if demo.skeleton.get_bone_name(sole.bone) == side + "Foot":
					clearance = minf(
						clearance,
						(
							(
								(
									demo.skeleton.global_transform
									* (demo.skeleton.get_bone_global_pose(sole.bone) * sole.point)
								)
								. y
							)
							- demo.body.position.y
						)
					)
			swing_peak[side] = maxf(swing_peak[side], clearance)
			# Independently require every substantial swing to sound when it plants.
			if clearance > .06:
				raised[side] = true
			elif raised[side] and clearance <= .01:
				raised[side] = false
				if demo.jump_time < 0 or demo.jump_landed and demo.jump_landing_time >= 4.0 / 60:
					expected.append(side)
			if fresh.any(func(cue): return cue.get("foot", "") == side):
				assert(clearance <= .0101 and swing_peak[side] >= .05, "Toe roll cued as a stride")
				swing_peak[side] = 0.0
		var heard: Array = (
			fresh.filter(func(cue): return cue.has("foot")).map(func(cue): return cue.foot)
		)
		for side in expected:
			assert(side in heard, "Substantial foot swing landed without sound")
	else:
		raised = {"Left": false, "Right": false}
		swing_peak = {"Left": 0.0, "Right": 0.0}
	events.append_array(fresh)
	await create_timer(1.0 / 60).timeout
	var frames: int = capture.get_frames_available()
	if frames > 0:
		for frame in capture.get_buffer(frames):
			sample_peak = maxf(sample_peak, maxf(absf(frame.x), absf(frame.y)))


func run() -> void:
	capture = AudioEffectCapture.new()
	capture.buffer_length = 1.0
	AudioServer.add_bus_effect(0, capture)
	demo = load("res://modules/shell/character/demo.gd").new()
	root.add_child(demo)
	demo.set_physics_process(false)
	for frame in 5:
		await tick()
	var count: int = demo.audio_history.size()
	demo.footstep("Left")
	demo.footstep("Right")
	assert(demo.audio_history.size() == count, "Idle emits footsteps")
	Input.action_press("down")
	for frame in 90:
		await tick()
	demo.jump()
	for frame in 56:
		await tick()
	Input.action_press("sprint")
	for frame in 22:
		await tick()
	Input.action_release("down")
	Input.action_press("up")
	for frame in 28:
		await tick()
	Input.action_release("up")
	Input.action_release("sprint")
	for frame in 20:
		await tick()
	var steps := events.filter(func(cue): return cue.has("foot"))
	assert(steps.size() >= 6, "No contact sounds")
	for cue in steps:
		assert(
			cue.on_floor and cue.stage in ["Ground", "Land"] and cue.pitch == 1.0,
			"Airborne/pitched contact"
		)
		assert(cue.playback_id >= 0, "Audio mixer dropped contact")
		assert(
			cue.bank == "CapturedHouse" and cue.id == -1 and cue.source.begins_with("indoor_step_"),
			"Unidentified floor presented as a recovered terrain bank"
		)
	var launches := events.filter(func(cue): return cue.bank == "Jump")
	var landings := events.filter(func(cue): return cue.bank == "Landing")
	assert(launches.size() == 1 and landings.size() == 1, "Jump cues duplicated or absent")
	assert(launches[0].stage == "Ascend" and landings[0].stage == "Land")
	assert(
		events.filter(func(cue): return cue.bank == "Skid").size() == 1,
		"Skid entry duplicated or absent"
	)
	# A detached actor must retain its sound data and restart its native playback.
	root.remove_child(demo)
	root.add_child(demo)
	assert(demo.sounds.recorded_steps.size() == 4 and demo.sounds.streams.size() == 128)
	assert(demo.audio_playback != null and demo.foot_audio.playing)
	demo.effect_sound("Jump", -1)
	assert(demo.audio_history.back().playback_id >= 0, "Remount lost action audio")
	Input.action_press("down")
	var after_mount: int = demo.audio_history.size()
	for frame in 24:
		await tick()
	Input.action_release("down")
	assert(
		demo.audio_history.slice(after_mount).any(
			func(cue): return cue.has("foot") and cue.playback_id >= 0
		),
		"Remount lost footsteps"
	)
	# Audition the verified outdoor stone captures through the same contact dispatcher.
	demo.reset()
	raised = {"Left": false, "Right": false}
	demo.sounds.captured_profile = "Stone"
	var stone_start: int = demo.audio_history.size()
	Input.action_press("down")
	for frame in 90:
		await tick()
	Input.action_release("down")
	var stone_steps: Array = demo.audio_history.slice(stone_start).filter(
		func(cue): return cue.has("foot")
	)
	assert(stone_steps.size() >= 4, "No original stone contacts")
	for cue in stone_steps:
		assert(
			(
				cue.bank == "CapturedStone"
				and cue.id == -1
				and cue.pitch == 1.0
				and cue.playback_id >= 0
			)
		)
		assert(cue.source.begins_with("stone_escort_step_"))
	for index in 3:
		var stream: AudioStreamWAV = demo.sounds.recorded_stone[index]
		assert(stream.format == AudioStreamWAV.FORMAT_16_BITS)
		var peak := 0
		var retained := 0
		var begin: int = int([.023, .021, .025][index] * stream.mix_rate)
		for frame in stream.data.size() / 2:
			var value: int = absi(stream.data.decode_s16(frame * 2))
			peak = maxi(peak, value)
			if frame >= begin:
				retained = maxi(retained, value)
		assert(absi(stream.data.decode_s16(begin * 2)) <= peak * .02 and retained == peak)
	demo.sounds.captured_profile = "House"
	var close: AudioStreamWAV = demo.sounds.recorded_close
	assert(close.format == AudioStreamWAV.FORMAT_16_BITS, "Lossy sound import")
	var close_peak := 0
	for frame in close.data.size() / 2:
		close_peak = maxi(close_peak, absi(close.data.decode_s16(frame * 2)))
	var first: int = absi(close.data.decode_s16(int(.024 * close.mix_rate) * 2))
	var remaining_peak := 0
	for frame in range(int(.024 * close.mix_rate), close.data.size() / 2):
		remaining_peak = maxi(remaining_peak, absi(close.data.decode_s16(frame * 2)))
	assert(
		first <= close_peak * .05 and remaining_peak == close_peak, "Door attack/peak was trimmed"
	)
	# A new different-stream cue must leave the preceding cue playing.
	demo.effect_sound("DoorCreak", 7)
	var creak: int = demo.audio_history.back().playback_id
	demo.effect_sound("DoorShut", 8)
	var shut: int = demo.audio_history.back().playback_id
	assert(
		(
			creak != shut
			and demo.audio_playback.is_stream_playing(creak)
			and demo.audio_playback.is_stream_playing(shut)
		),
		"New cue cuts preceding tail"
	)
	await create_timer(.15).timeout
	for frame in capture.get_buffer(capture.get_frames_available()):
		sample_peak = maxf(sample_peak, maxf(absf(frame.x), absf(frame.y)))
	assert(sample_peak > .001 and sample_peak < 1, "Mixer silent or clipping: " + str(sample_peak))
	FileAccess.open("res://audio-check.json", FileAccess.WRITE).store_string(
		JSON.stringify(
			{
				"events": events,
				"contacts": steps.size(),
				"launches": launches.size(),
				"landings": landings.size(),
				"overlap": true,
				"stone_contacts": stone_steps.size(),
				"lossless_stone_attacks_and_peaks": true,
				"mixer_peak": sample_peak
			},
			"  "
		)
	)
	AudioServer.remove_bus_effect(0, AudioServer.get_bus_effect_count(0) - 1)
	print("PASS native mixer, contact-only steps, one launch/landing/skid and overlapping tails")
	demo.free()
	demo = null
	# Fixed simulation frames do not advance the mixer wall clock. Drain its stop request.
	OS.delay_msec(100)
	quit()
