extends RefCounted
## Prototype adaptation of pinned GameCube controller formulas; units remain calibrated.
var heading := 0.0
var shape_heading := 0.0
var velocity := 0.0
var phase := 0.0
var phase_step := 0.22
var gait := "Idle"
var lean := 0.0
var skidding := false
var skid_target := 0.0
var travel_gain := 3.15/4.875

func turn(current: float, target: float, magnitude: float, ticks: float) -> float:
	var error := wrapf(target-current,-PI,PI)
	var modifier := 0.01 if magnitude<=0.05 else 0.01+0.5157895*(magnitude-0.05)
	var fraction := 1.0-sqrt(1.0-modifier)
	var step := clampf(absf(error)*fraction,50.0*TAU/65536,2500.0*TAU/65536)*ticks
	return current+signf(error)*minf(absf(error),step)

func step(input: Vector2, sprint: bool, delta: float, obstruction := 1.0) -> Vector3:
	var ticks := delta*60.0
	var magnitude := minf(1,input.length())
	var desired := atan2(input.x,input.y) if magnitude>0.01 else heading
	var error := wrapf(desired-heading,-PI,PI)
	if not skidding and gait=="Dash" and magnitude>0.1 and absf(error)>18204.0*TAU/65536:
		skidding = true
		skid_target = desired
	if skidding:
		# Source TURN_DASH captures its target and uses the positive wrapped angle helper.
		var remaining := fposmod(skid_target-shape_heading,TAU)
		var amount := clampf(remaining*(1-sqrt(.5)),50.0*TAU/65536,2500.0*TAU/65536)*ticks
		shape_heading += minf(remaining,amount)
		velocity = move_toward(velocity,0,0.261*ticks)
		gait = "Skid"
		if velocity==0 and absf(wrapf(skid_target-shape_heading,-PI,PI))<0.001:
			heading = shape_heading
			skidding = false
			gait = "Idle"
	else:
		if magnitude>0.01: heading = turn(heading,desired,magnitude,ticks)
		shape_heading = heading
		var alignment := maxf(0,cos(wrapf(desired-heading,-PI,PI)))
		var target := (7.5 if sprint else 4.875)*magnitude*alignment
		velocity = move_toward(velocity,target,(0.60899997 if target>velocity else 0.32625002)*ticks)
		var constrained := velocity*clampf(obstruction,0,1)
		phase_step = maxf(0.22,0.59999996*sqrt(constrained/7.5))
		gait = "Idle" if velocity<0.001 else ("Walk" if constrained<3.525 else ("Dash" if sprint and constrained>=4.875 else "Run"))
	if gait!="Idle" and gait!="Skid": phase = fposmod(phase+phase_step*ticks/16.0,1)
	var target_lean := minf(20,20*pow(phase_step*phase_step/.36,6)) if gait not in ["Idle","Skid"] else 0.0
	lean = lerpf(lean,deg_to_rad(target_lean),1-pow(0.8,ticks))
	return Vector3(sin(heading),0,cos(heading))*velocity*travel_gain

func reset() -> void:
	heading=0;shape_heading=0;velocity=0;phase=0;lean=0;gait="Idle";skidding=false
