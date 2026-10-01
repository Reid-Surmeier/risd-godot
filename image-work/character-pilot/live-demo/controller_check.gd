extends SceneTree
func _initialize() -> void:
	var controller=load("res://locomotion.gd").new()
	var trace=[]
	for i in 9:
		controller.step(Vector2.DOWN,false,1.0/60)
		trace.append(controller.velocity)
	assert(absf(controller.velocity-4.875)<0.0001)
	assert(controller.gait=="Run")
	assert(absf(16.0/(60*controller.phase_step)-.551266)<.00001)
	var phase=controller.phase
	controller.step(Vector2.DOWN,true,1.0/60)
	assert(absf(controller.phase-phase)<.05) # No gait-switch phase reset.
	for i in 12: controller.step(Vector2.DOWN,true,1.0/60)
	assert(controller.gait=="Dash" and absf(controller.velocity-7.5)<.0001)
	var velocity=controller.step(Vector2.UP,true,1.0/60)
	assert(controller.skidding and controller.gait=="Skid")
	assert(velocity.z>0 and absf(velocity.x)<.0001) # Brake along old heading.
	var captured=controller.skid_target
	for i in 5:controller.step(Vector2.ZERO,false,1.0/60)
	assert(controller.skid_target==captured and controller.shape_heading>0)
	for i in 120: controller.step(Vector2.UP,true,1.0/60)
	assert(not controller.skidding and controller.gait=="Dash")
	controller.reset()
	for i in 9: controller.step(Vector2.DOWN,false,1.0/60)
	for i in 14: controller.step(Vector2.ZERO,false,1.0/60)
	assert(controller.velocity>0)
	controller.step(Vector2.ZERO,false,1.0/60)
	assert(controller.velocity==0 and controller.gait=="Idle")
	controller.reset()
	for i in 20:controller.step(Vector2.DOWN*.45,false,1.0/60)
	assert(controller.gait=="Walk")
	controller.step(Vector2.DOWN,false,1.0/60,0)
	assert(controller.phase_step==.22 and controller.gait=="Walk")
	FileAccess.open("res://controller-check.json",FileAccess.WRITE).store_string(JSON.stringify({"normal_acceleration_trace":trace,"normal_cycle_seconds":.551266,"dash_cycle_seconds":.444444,"phase_preserved":true,"reversal_skid":true,"normal_braking_updates":15,"partial_input_walk":true,"blocked_phase_feedback":true},"  "))
	print("PASS source-informed speed/gait/phase/braking/reversal/collision controller")
	quit()
