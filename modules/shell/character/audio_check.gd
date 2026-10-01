extends SceneTree
## Exercise actual contact dispatch and the native mixer, rather than receipt strings.
var demo: Node3D
var capture: AudioEffectCapture
var events := []
var silent := 0
var sample_peak := 0.0
func _initialize() -> void:call_deferred("run")
func tick() -> void:
	var prior: int=demo.audio_history.size()
	demo._physics_process(1.0/60)
	if demo.audio_history.size()>prior:events.append_array(demo.audio_history.slice(prior))
	await create_timer(1.0/60).timeout
	var frames: int=capture.get_frames_available()
	if frames>0:
		for frame in capture.get_buffer(frames):sample_peak=maxf(sample_peak,maxf(absf(frame.x),absf(frame.y)))
func run() -> void:
	capture=AudioEffectCapture.new();capture.buffer_length=1.0
	AudioServer.add_bus_effect(0,capture)
	demo=load("res://modules/shell/character/demo.gd").new();root.add_child(demo)
	demo.set_physics_process(false)
	for frame in 5:await tick()
	var count: int=demo.audio_history.size()
	demo.footstep("Left");demo.footstep("Right")
	assert(demo.audio_history.size()==count,"Idle emits footsteps")
	Input.action_press("down")
	for frame in 90:await tick()
	demo.jump()
	for frame in 56:await tick()
	Input.action_press("sprint")
	for frame in 22:await tick()
	Input.action_release("down");Input.action_press("up")
	for frame in 28:await tick()
	Input.action_release("up");Input.action_release("sprint")
	for frame in 20:await tick()
	var steps := events.filter(func(cue):return cue.has("foot"))
	assert(steps.size()>=6,"No contact sounds")
	for cue in steps:
		assert(cue.on_floor and cue.stage in ["Ground","Land"] and cue.pitch==1.0,"Airborne/pitched contact")
		assert(cue.playback_id>=0,"Audio mixer dropped contact")
		assert(cue.bank=="CapturedHouse" and cue.id==-1 and cue.source.begins_with("indoor_step_"),"Unidentified floor presented as a recovered terrain bank")
	var launches := events.filter(func(cue):return cue.bank=="Jump")
	var landings := events.filter(func(cue):return cue.bank=="Landing")
	assert(launches.size()==1 and landings.size()==1,"Jump cues duplicated or absent")
	assert(launches[0].stage=="Ascend" and landings[0].stage=="Land")
	assert(events.filter(func(cue):return cue.bank=="Skid").size()==1,"Skid entry duplicated or absent")
	# A new different-stream cue must leave the preceding cue playing.
	demo.effect_sound("DoorCreak",7)
	var creak: int=demo.audio_history.back().playback_id
	demo.effect_sound("DoorShut",8)
	var shut: int=demo.audio_history.back().playback_id
	assert(creak!=shut and demo.audio_playback.is_stream_playing(creak) and demo.audio_playback.is_stream_playing(shut),"New cue cuts preceding tail")
	await create_timer(.15).timeout
	for frame in capture.get_buffer(capture.get_frames_available()):sample_peak=maxf(sample_peak,maxf(absf(frame.x),absf(frame.y)))
	assert(sample_peak>.001 and sample_peak<1,"Mixer silent or clipping: "+str(sample_peak))
	FileAccess.open("res://audio-check.json",FileAccess.WRITE).store_string(JSON.stringify({"events":events,"contacts":steps.size(),"launches":launches.size(),"landings":landings.size(),"overlap":true,"mixer_peak":sample_peak},"  "))
	AudioServer.remove_bus_effect(0,AudioServer.get_bus_effect_count(0)-1)
	print("PASS native mixer, contact-only steps, one launch/landing/skid and overlapping tails")
	demo.free();demo=null
	# Fixed simulation frames do not advance the mixer wall clock. Drain its stop request.
	OS.delay_msec(100)
	quit()
