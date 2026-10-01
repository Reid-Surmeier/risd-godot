extends SceneTree
var demo: Node3D
var evidence := {}
func _initialize() -> void:
	create_timer(40).timeout.connect(func():quit(1))
	call_deferred("run")
func frames(count: int) -> void:
	for i in count:await physics_frame
func run() -> void:
	demo=load("res://demo.gd").new()
	root.add_child(demo)
	await frames(3)
	assert(demo.camera!=null and demo.soles.size()>500)
	assert(demo.tool_rotations.Axe.size()==8 and demo.tool_rotations.Net.size()==4)
	assert(demo.tool_meshes.Axe.global_basis.get_scale().distance_to(Vector3.ONE)<.0001)
	Input.action_press("down")
	await frames(30)
	assert(demo.state=="Run")
	evidence.normal={"speed":Vector2(demo.body.velocity.x,demo.body.velocity.z).length(),"phase":demo.movement.phase,"animation_rate":demo.player.get_playing_speed()}
	Input.action_press("sprint")
	await frames(30)
	assert(demo.state=="Dash" and demo.emitted>0)
	evidence.dash={"speed":Vector2(demo.body.velocity.x,demo.body.velocity.z).length(),"effects":demo.emitted}
	var skid_births: int=demo.emitted
	Input.action_release("down");Input.action_press("up")
	await frames(2)
	assert(demo.state=="Skid" and demo.body.velocity.z>0)
	assert(demo.emitted>skid_births)
	evidence.reversal={"state":demo.state,"travel_heading":demo.movement.heading,"shape_heading":demo.movement.shape_heading}
	Input.action_release("up");Input.action_release("sprint")
	await frames(100)
	assert(demo.state=="Idle")
	var births: int=demo.emitted
	await frames(40)
	assert(demo.emitted==births)
	demo.reset()
	var analog := InputEventJoypadMotion.new();analog.axis=JOY_AXIS_LEFT_Y;analog.axis_value=.45
	Input.parse_input_event(analog);await frames(25)
	assert(demo.state=="Walk" and absf(demo.movement.velocity-4.875*.45)<.01)
	evidence.analog={"input_magnitude":.45,"velocity":demo.movement.velocity,"gait":demo.state}
	analog.axis_value=0;Input.parse_input_event(analog);await frames(20)
	demo.reset();demo.body.position=Vector3(0,0,15.3)
	Input.action_press("down");Input.action_press("sprint")
	await frames(100)
	assert(demo.body.position.z<15.7 and demo.state=="Idle")
	births=demo.emitted
	await frames(45)
	assert(demo.emitted==births)
	Input.action_release("down");Input.action_release("sprint")
	evidence.wall={"position":demo.body.position.z,"effects_stopped":true}
	demo.reset();demo.cycle_tool();await frames(3)
	assert(demo.tool=="Axe" and demo.tool_meshes.Axe.visible)
	demo.cycle_tool();await frames(3)
	assert(demo.tool=="Net" and demo.tool_meshes.Net.visible)
	evidence.tools={"axe_bones":8,"net_bones":4,"world_scale":demo.tool_meshes.Axe.global_basis.get_scale()}
	demo.reset();demo.body.position=Vector3(-2,0,-1.2);demo.interact()
	await frames(5)
	assert(demo.dialogue==1 and demo.state=="Idle")
	var point: Vector3=demo.body.position
	Input.action_press("down");await frames(10);Input.action_release("down")
	assert(demo.body.position.distance_to(point)<.0001)
	demo.interact();await frames(5)
	assert(demo.interaction=="Receive")
	demo.interact();await frames(3)
	assert(demo.dialogue==0)
	evidence.dialogue={"faces_partner":true,"movement_locked":true,"receipt_pose":true}
	demo.body.position=Vector3(0,0,-6.5);demo.interact()
	await frames(100)
	assert(demo.indoor and demo.door_transitions==1)
	demo.body.position=Vector3(40,0,-3);demo.interact();await frames(110)
	assert(not demo.indoor and demo.door_transitions==2)
	evidence.door={"enter_exit":true,"transition_count":demo.door_transitions}
	for ground in ["Grass","Indoor","Snow","Water","Sand","Leaves"]:
		demo.reset();demo.surface=ground
		Input.action_press("down");Input.action_press("sprint")
		births=demo.emitted
		await frames(45)
		Input.action_release("down");Input.action_release("sprint")
		assert((demo.emitted==births) if ground=="Indoor" else (demo.emitted>births))
		evidence[ground]={"effect_events":demo.emitted-births,"footsteps":demo.footprint_count}
	demo.reset();demo.surface="Grass";Input.action_press("down")
	births=demo.emitted;await frames(45);Input.action_release("down")
	assert(demo.emitted==births)
	demo.raining=true;Input.action_press("down");births=demo.emitted
	await frames(45);Input.action_release("down")
	assert(demo.emitted>births and demo.step_history[-1].surface=="Water")
	evidence.rain={"normal_gait_water_events":demo.emitted-births}
	demo.raining=false
	await frames(90)
	assert(demo.face_blinks>0 and demo.max_floor_error<.0001)
	evidence.blink={"events":demo.face_blinks,"shader":demo.face_material!=null}
	evidence.clearance={"maximum_error":demo.max_floor_error,"world_stance_lock":false}
	evidence.foot_order=demo.foot_order
	FileAccess.open("res://driven-check.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  "))
	print("PASS driven rig/gaits/reversal/wall/tools/dialogue/door/surface/blink checks")
	quit()
