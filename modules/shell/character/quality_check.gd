extends SceneTree
## Checks exported wrist motion and actual audio waveforms, independent of receipts.
var demo: Node3D
var rig_mesh: MeshInstance3D
func _initialize() -> void:
	create_timer(120).timeout.connect(func():quit(1))
	call_deferred("run")
func run() -> void:
	demo=load("res://modules/shell/character/demo.gd").new();root.add_child(demo);demo.set_physics_process(false)
	await process_frame
	var palms := {"Left":[],"Right":[]}
	for mesh in demo.model.find_children("*","MeshInstance3D",true,false):
		if mesh.skin==null:continue
		rig_mesh=mesh
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array=mesh.mesh.surface_get_arrays(surface)
			for v in arrays[Mesh.ARRAY_VERTEX].size():
				for influence in 4:
					if arrays[Mesh.ARRAY_WEIGHTS][v*4+influence]<=.5:continue
					var bind: int=arrays[Mesh.ARRAY_BONES][v*4+influence]
					var bone: int=mesh.skin.get_bind_bone(bind)
					if bone<0:bone=demo.skeleton.find_bone(mesh.skin.get_bind_name(bind))
					for side in palms:
						if demo.skeleton.get_bone_name(bone)==side+"Hand":
							var local: Vector3=mesh.skin.get_bind_pose(bind)*arrays[Mesh.ARRAY_VERTEX][v]
							var scale: Vector3=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_rest(bone)).basis.get_scale()
							palms[side].append(local*scale)
	var shapes := {}
	for side in palms:
		var tip := -INF
		var thumb := INF
		var edge := INF
		for p in palms[side]:
			tip=maxf(tip,p.y)
			if p.y>.02 and p.y<.06:thumb=minf(thumb,p.z)
			if p.y>.08 and p.y<.13:edge=minf(edge,p.z)
		assert(palms[side].size()>200 and absf(tip-.145)<.001 and absf(thumb+.12)<.001 and edge-thumb>.035,"Palm shape "+side)
		shapes[side]={"vertices":palms[side].size(),"reach_m":tip,"thumb_projection_m":edge-thumb}
	# Compare actual FK motion with the untouched imported idle, not generated receipts.
	var original_model: Node3D=load("res://modules/shell/character/walk.glb").instantiate();root.add_child(original_model)
	var original_player: AnimationPlayer=original_model.find_children("*","AnimationPlayer",true,false)[0]
	var original_rig: Skeleton3D=original_model.find_children("*","Skeleton3D",true,false)[0]
	original_player.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	original_player.play("idle");demo.player.play("idle")
	var idle_ranges := {"source":{"hip":[],"head":[]},"current":{"hip":[],"head":[]}}
	for tick in 65:
		var time: float=original_player.get_animation("idle").length*tick/64.0
		original_player.seek(time,true);demo.player.seek(time,true)
		for entry in [["source",original_rig],["current",demo.skeleton]]:
			var rig: Skeleton3D=entry[1];rig.force_update_all_bone_transforms()
			for part in ["hip","head"]:
				var bone: int=rig.find_bone("Hips" if part=="hip" else "Head")
				idle_ranges[entry[0]][part].append(rig.get_bone_global_pose(bone).origin.y*.01)
	var quieter_idle := {}
	for part in ["hip","head"]:
		var source_range: float=idle_ranges.source[part].max()-idle_ranges.source[part].min()
		var actual_range: float=idle_ranges.current[part].max()-idle_ranges.current[part].min()
		assert(source_range>.005 and actual_range/source_range>.40 and actual_range/source_range<.65,"Idle rocking not reduced: "+part)
		quieter_idle[part]={"source_range":source_range,"current_range":actual_range,"ratio":actual_range/source_range}
	original_model.free()
	var wrists := {}
	for clip in ["idle","walk","run","dash","skid","jump"]:
		demo.player.play(clip)
		var maximum := 0.0
		for i in 65:
			demo.player.seek(demo.player.get_animation(clip).length*i/64.0,true)
			demo.skeleton.force_update_all_bone_transforms()
			maximum=maxf(maximum,wrist_error())
		assert(maximum<.1,"Wrist counter-rotation: "+clip+" "+str(maximum))
		wrists[clip]={"samples":65,"relative_wrist_error_degrees":maximum}
	demo.player.play("idle");demo.player.seek(0,true)
	var clearance := arm_clearance()
	assert(clearance.interior_vertices==0 and clearance.minimum_gap>.005,"Idle forearm/palm enters body: "+str(clearance))
	var stop_clearance := []
	for mode in ["walk","run","dash"]:
		demo.reset()
		if mode=="walk":Input.action_press("slow")
		if mode=="dash":Input.action_press("sprint")
		Input.action_press("down")
		for tick in 30:demo._physics_process(1.0/60)
		Input.action_release("down");Input.action_release("sprint");Input.action_release("slow")
		for tick in 46:
			demo._physics_process(1.0/60)
			if tick in [0,6,12,29,45]:
				var sample := arm_clearance()
				assert(sample.interior_vertices==0,"Forearm/palm enters body when stopping: "+mode+" "+str(tick))
				stop_clearance.append({"gait":mode,"tick":tick,"clearance":sample})
	var transitions := {}
	demo.reset()
	var tool_clearance := {}
	for tool in ["Axe","Net"]:
		demo.tool=tool
		for tick in 30:demo._physics_process(1.0/60)
		var sample := arm_clearance()
		assert(sample.interior_vertices==0,"Tool forearm/palm enters body: "+tool+" "+str(sample))
		tool_clearance[tool]=sample
	demo.reset()
	for tool in ["None","Axe","Net","None"]:
		demo.tool=tool
		var maximum := 0.0
		var states := []
		var arm_maximum := 0.0
		var stable_ticks := 0
		var previous_clip := ""
		for input in [Vector2.ZERO,Vector2(0,.45),Vector2.DOWN,Vector2.UP,Vector2.ZERO]:
			Input.action_release("sprint")
			if input.length()>.99:Input.action_press("sprint")
			Input.action_release("down");Input.action_release("up")
			if input.y>0:Input.action_press("down",input.y)
			if input.y<0:Input.action_press("up",-input.y)
			for tick in 30:
				demo._physics_process(1.0/60)
				maximum=maxf(maximum,wrist_error())
				stable_ticks=stable_ticks+1 if previous_clip==demo.player.current_animation else 0
				previous_clip=demo.player.current_animation
				if tool=="None" and stable_ticks>=20:
					arm_maximum=maxf(arm_maximum,arm_animation_error())
				if demo.state not in states:states.append(demo.state)
		assert(maximum<.1,"Blended wrist counter-rotation: "+tool+" "+str(maximum))
		assert(arm_maximum<.1,"Stale base arm pose after clip/tool transition: "+str(arm_maximum))
		transitions[tool]={"updates":150,"relative_wrist_error_degrees":maximum,"states":states,"settled_base_arm_error_degrees":arm_maximum}
	demo.reset();demo.tool="None"
	for tick in 3:demo._physics_process(1.0/60)
	demo.jump()
	var jump_maximum := 0.0
	var pose_trace := []
	var hip: int=demo.skeleton.find_bone("Hips")
	var jump_foot: int=demo.skeleton.find_bone("LeftFoot")
	var hand: int=demo.skeleton.find_bone("LeftHand")
	var neutral_hip: float=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(hip)).origin.y-demo.body.position.y
	var neutral_foot: float=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(jump_foot)).origin.y-demo.body.position.y
	var neutral_hand: Vector3=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(hand)).origin-demo.body.position
	var crouch := 0.0;var impact := 0.0;var tuck := 0.0;var arm_drive := 0.0
	var contact_tick := -1;var stages := [];var knee_forward := 0.0
	var bone_step := 0.0;var plant_drift := 0.0;var root_correction := 0.0
	var previous_bones := bone_positions()
	var audio_start: int=demo.audio_history.size()
	for tick in 100:
		demo._physics_process(1.0/60)
		check_knees()
		jump_maximum=maxf(jump_maximum,wrist_error())
		var current_bones := bone_positions()
		for b in current_bones:bone_step=maxf(bone_step,current_bones[b].distance_to(previous_bones[b]))
		previous_bones=current_bones
		if demo.jump_stage in ["Anticipate","Land"]:
			root_correction=maxf(root_correction,absf(demo.model.position.y))
			for side in demo.planted_feet:
				var actual: Transform3D=demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone(side+"Foot"))
				plant_drift=maxf(plant_drift,Vector2(actual.origin.x-demo.planted_feet[side].origin.x,actual.origin.z-demo.planted_feet[side].origin.z).length())
		var pelvis: float=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(hip)).origin.y-demo.body.position.y
		var ankle: float=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(jump_foot)).origin.y-demo.body.position.y
		var palm: Vector3=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(hand)).origin-demo.body.position
		if demo.jump_stage=="Anticipate":
			crouch=maxf(crouch,neutral_hip-pelvis)
			if neutral_hip-pelvis>.03:
				var knee: Vector3=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone("LeftLeg"))).origin
				var ankle_point: Vector3=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(jump_foot)).origin
				knee_forward=(knee-ankle_point).dot(demo.model.global_basis.z.normalized())
				assert(knee_forward>.005,"Grounded crouch knee bends backwards")
		if demo.jump_stage=="Land":impact=maxf(impact,neutral_hip-pelvis)
		if not demo.body.is_on_floor():
			tuck=maxf(tuck,ankle-neutral_foot);arm_drive=maxf(arm_drive,palm.distance_to(neutral_hand))
			assert(demo.model.position.y>=-.00001 and demo.model.position.y<=.04,"Airborne floor clearance overrides posing")
		if demo.jump_landed and contact_tick<0:contact_tick=tick
		if demo.jump_stage not in stages:stages.append(demo.jump_stage)
		pose_trace.append({"tick":tick,"phase":demo.jump_stage,"body_y":demo.body.position.y,"velocity_y":demo.body.velocity.y,"floor":demo.body.is_on_floor(),"clip_time":demo.player.current_animation_position,"pelvis_y":pelvis,"ankle_y":ankle,"arm_displacement":palm.distance_to(neutral_hand)})
	assert(jump_maximum<.1,"Jump transition wrist alignment")
	assert(bone_step<=.06,"Standing jump pose pops: "+str(bone_step))
	assert(plant_drift<=.01 and root_correction<=.005,"Standing footplant/root compensation: "+str([plant_drift,root_correction]))
	var jump_cues: Array=demo.audio_history.slice(audio_start).filter(func(cue):return cue.bank in ["Jump","Landing"])
	assert(jump_cues.size()==2 and jump_cues[0].bank=="Jump" and jump_cues[1].bank=="Landing","Missing/duplicate jump event cues")
	assert(jump_cues[1].gain>0 and jump_cues[1].gain<=1)
	assert(crouch>.02 and impact>.04 and impact<.12,"Missing anticipation/landing compression: "+str([crouch,impact]))
	assert(arm_drive>.20 and demo.actor_shadow!=null,"Jump only translates the body: "+str([tuck,arm_drive]))
	assert(stages==["Anticipate","Ascend","Descend","Land","Ground"] and contact_tick>0 and demo.jump_time<0,"Jump phase/contact/recovery sequence")
	FileAccess.open("res://jump-pose-check.json",FileAccess.WRITE).store_string(JSON.stringify({"maximum_bone_step":bone_step,"planted_horizontal_drift":plant_drift,"maximum_planted_root_correction":root_correction,"jump_audio":jump_cues,"knee_forward_of_ankle":knee_forward,"grounded_compression":crouch,"landing_compression":impact,"airborne_ankle_lift":tuck,"arm_drive":arm_drive,"contact_tick":contact_tick,"stages":stages,"trace":pose_trace},"  "))
	var moving_jump := {}
	for tool in ["None","Axe","Net"]:
		demo.reset();demo.tool=tool;Input.action_press("down")
		for tick in 40:demo._physics_process(1.0/60)
		demo.jump()
		var speed_step := 0.0;var palm_step := 0.0
		var previous_speed: float=Vector2(demo.body.velocity.x,demo.body.velocity.z).length()
		var previous_palm: Vector3=demo.skeleton.get_bone_global_pose(hand).origin*.01
		var launch_tick := -1
		for tick in 100:
			demo._physics_process(1.0/60)
			var speed: float=Vector2(demo.body.velocity.x,demo.body.velocity.z).length()
			speed_step=maxf(speed_step,absf(speed-previous_speed));previous_speed=speed
			var point: Vector3=demo.skeleton.get_bone_global_pose(hand).origin*.01
			if tool!="None" and tick==0:palm_step=point.distance_to(previous_palm)
			previous_palm=point
			if demo.jump_launched and launch_tick<0:launch_tick=tick
			check_knees()
		Input.action_release("down")
		assert(speed_step<=.6,"Moving jump loses momentum: "+tool+" "+str(speed_step))
		assert(launch_tick<=2,"Moving jump delays input")
		assert(palm_step<.10,"Tool arm pops on jump entry: "+tool+" "+str(palm_step))
		assert(demo.jump_time<0 and demo.state=="Run","Moving jump did not recover")
		moving_jump[tool]={"updates":100,"maximum_horizontal_speed_change":speed_step,"launch_tick":launch_tick,"first_update_palm_displacement":palm_step,"recovered_gait":demo.state}
	# Regression cases from the independent review: input can change throughout a hop.
	var landing_continuity := []
	for delay in range(9):
		demo.reset();demo.tool="None"
		for action in ["down","up","left","right","slow","sprint"]:Input.action_release(action)
		for tick in 30:demo._physics_process(1.0/60)
		demo.jump()
		var land_tick := -1;var heads := [];var maximum_jerk := 0.0
		for tick in 100:
			if demo.jump_landed:land_tick+=1
			if land_tick==delay:Input.action_press("down")
			demo._physics_process(1.0/60)
			var head: Vector3=demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone("Head")).origin-demo.body.global_position
			heads.append(head)
			if land_tick>=0 and land_tick<=18 and heads.size()>=3:
				var acceleration: Vector3=heads[-1]-2*heads[-2]+heads[-3]
				maximum_jerk=maxf(maximum_jerk,absf(acceleration.y))
		assert(maximum_jerk<=.033,"Landing gait change jerks head: "+str(delay)+" "+str(maximum_jerk))
		landing_continuity.append({"input_delay_ticks":delay,"maximum_vertical_head_acceleration":maximum_jerk})
		Input.action_release("down")
	demo.reset();demo.body.position=Vector3(.21,0,-.47)
	for tick in 30:demo._physics_process(1.0/60)
	for action in ["slow","up","left"]:Input.action_press(action)
	demo.jump()
	var contact_depth := INF;var contact_seen := false
	for tick in 100:
		demo._physics_process(1.0/60)
		if demo.jump_landed and demo.jump_landing_time<=2.0/60+.000001:
			contact_seen=true;contact_depth=minf(contact_depth,demo.body.position.y)
	for action in ["slow","up","left"]:Input.action_release(action)
	assert(contact_seen and contact_depth>=-.0025,"Floor snap drove shoes below the surface: "+str(contact_depth))
	var mixed_input := {}
	for mode in ["press","apex","contact"]:
		demo.reset();demo.tool="None"
		for tick in 30:demo._physics_process(1.0/60)
		demo.jump()
		var changed := false;var drop := 0.0;var step := 0.0
		var initial: float=bone_positions()[hip].y
		var last := bone_positions()
		var last_stage: String=demo.jump_stage;var last_pose: float=demo.jump_pose_time
		var hand_step := 0.0
		for tick in 100:
			if not changed and (mode=="press" or mode=="apex" and demo.jump_launched and demo.body.velocity.y<=0 or mode=="contact" and demo.jump_landed):
				Input.action_press("down");changed=true
			demo._physics_process(1.0/60)
			var now := bone_positions()
			if demo.jump_stage=="Descend" and last_stage=="Descend":assert(demo.jump_pose_time+.00001>=last_pose,"Descent pose rewound before contact: "+mode)
			if demo.jump_stage in ["Descend","Land"]:
				for name in ["LeftHand","RightHand"]:
					var bone: int=demo.skeleton.find_bone(name)
					hand_step=maxf(hand_step,now[bone].distance_to(last[bone]))
			last_stage=demo.jump_stage;last_pose=demo.jump_pose_time
			if demo.jump_stage=="Land":
				assert(demo.jump_impact>.8,"Flat hop lost impact velocity at contact: "+mode)
				drop=maxf(drop,initial-now[hip].y)
				assert(Vector2(demo.body.velocity.x,demo.body.velocity.z).length()<=.2 or demo.jump_moving,"Moving body retains planted landing")
			if demo.jump_landed:
				for bone in [hip,demo.skeleton.find_bone("Head")]:step=maxf(step,now[bone].distance_to(last[bone]))
			last=now;check_knees()
		Input.action_release("down")
		assert(changed and drop<=.10 and step<=.06 and hand_step<=.07,"Mixed-input landing collapse/pop: "+mode+" "+str([drop,step,hand_step]))
		mixed_input[mode]={"maximum_landing_drop":drop,"maximum_head_hips_step":step,"maximum_descent_land_hand_step":hand_step,"flat_hop_impact":demo.jump_impact,"descent_pose_monotonic":true}
	demo.reset();Input.action_press("down");Input.action_press("sprint")
	for tick in 40:demo._physics_process(1.0/60)
	var last_head: Vector3=bone_positions()[demo.skeleton.find_bone("Head")]
	var last_lean: float=demo.model.rotation.x
	var lean_step := 0.0;var head_step := 0.0
	demo.jump()
	for tick in 90:
		demo._physics_process(1.0/60)
		var point: Vector3=bone_positions()[demo.skeleton.find_bone("Head")]
		lean_step=maxf(lean_step,absf(demo.model.rotation.x-last_lean));last_lean=demo.model.rotation.x
		head_step=maxf(head_step,point.distance_to(last_head));last_head=point
	Input.action_release("down");Input.action_release("sprint")
	assert(rad_to_deg(lean_step)<=3.001 and head_step<=.059,"Sprint jump lean pop: "+str([rad_to_deg(lean_step),head_step]))
	demo.reset();var repeat_start: int=demo.jumps;var repeat_landings: int=demo.landings
	demo.jump();var queued := false
	for tick in 120:
		demo._physics_process(1.0/60)
		if demo.jump_landed and not queued:demo.jump();queued=true
	assert(queued and demo.jumps==repeat_start+2 and demo.landings==repeat_landings+2,"Landing jump press was lost: "+str([demo.jumps-repeat_start,demo.landings-repeat_landings,demo.jump_buffer,demo.jump_stage]))
	# The historical surface-wave tests remain a check of the labeled authored fallback.
	demo.sounds.recorded_house=false
	var audio := {}
	var samples := []
	for ground in ["Grass","Path","Snow","Sand","Water","Leaves","Indoor"]:
		var cue: Dictionary=demo.sounds.step(ground,"Run","Right",ground=="Indoor")
		assert(cue.pitch==1.0 and is_equal_approx(cue.gain,.72 if ground=="Indoor" else .8))
		var wav: AudioStreamWAV=cue.stream
		assert(wav.mix_rate==22050 and wav.data.size()>3000)
		assert(wav.data!=demo.sounds.streams[demo.sounds.key(ground,true,cue.variant)].data)
		for other in samples:assert(wav.data!=other,"Terrain banks share waveform")
		samples.append(wav.data)
		var peak := 0
		var tail := 0
		for i in wav.data.size()/2:
			var value: int=absi(wav.data.decode_s16(i*2));peak=maxi(peak,value)
			if i>wav.data.size()/2-100:tail=maxi(tail,value)
		assert(peak>5000 and peak<31000 and tail<peak*.1)
		wav.save_to_wav("res://audio-"+ground.to_lower()+".wav")
		audio[ground]={"id":cue.id,"gain":cue.gain,"peak":peak,"tail":tail,"samples":wav.data.size()/2}
	for foot in ["Left","Right"]:
		for gait in ["Walk","Run","Dash"]:
			for i in 32:
				var cue: Dictionary=demo.sounds.step("Grass",gait,foot,false)
				assert(cue.id==0x4201+(40 if gait=="Dash" else 0)+(10 if foot=="Left" else 0)+(20 if cue.variant>=2 else 0))
	var start: int=demo.audio_history.size();demo.state="Idle";demo.footstep("Right")
	assert(demo.audio_history.size()==start)
	demo.sounds.streams[demo.sounds.key("Skid",false,0)].save_to_wav("res://audio-skid.wav")
	FileAccess.open("res://quality-check.json",FileAccess.WRITE).store_string(JSON.stringify({"landing_continuity":landing_continuity,"contact_depth":{"minimum_root_y":contact_depth},"quieter_idle":quieter_idle,"palms":shapes,"wrists":wrists,"transitions":transitions,"arm_clearance":clearance,"tool_clearance":tool_clearance,"stop_clearance":stop_clearance,"moving_jump":moving_jump,"mixed_input":mixed_input,"sprint_jump":{"maximum_lean_step_degrees":rad_to_deg(lean_step),"maximum_head_step":head_step},"jump_transition":{"updates":100,"relative_wrist_error_degrees":jump_maximum},"audio":audio,"idle_silent":true,"exact_original_waveforms":false},"  "))
	print("PASS exported wrist alignment and distinct audio banks/variants/gains/envelopes/idle silence")
	demo.free();demo=null
	# Fixed simulation frames do not advance the mixer wall clock. Drain its stop request.
	OS.delay_msec(100)
	quit()

func wrist_error() -> float:
	demo.skeleton.force_update_all_bone_transforms()
	var maximum := 0.0
	for side in ["Left","Right"]:
		var fore: int=demo.skeleton.find_bone(side+"ForeArm")
		var hand: int=demo.skeleton.find_bone(side+"Hand")
		var actual: Basis=demo.skeleton.get_bone_global_pose(fore).basis.inverse()*demo.skeleton.get_bone_global_pose(hand).basis
		var rest: Basis=demo.skeleton.get_bone_global_rest(fore).basis.inverse()*demo.skeleton.get_bone_global_rest(hand).basis
		maximum=maxf(maximum,rad_to_deg(actual.orthonormalized().get_rotation_quaternion().angle_to(rest.orthonormalized().get_rotation_quaternion())))
	return maximum

func arm_animation_error() -> float:
	var animation: Animation=demo.player.get_animation(demo.player.current_animation)
	var maximum := 0.0
	for bone in demo.tool_rotations.Axe:
		var expected: Quaternion=demo.skeleton.get_bone_rest(bone).basis.orthonormalized().get_rotation_quaternion()
		for track in animation.get_track_count():
			if animation.track_get_type(track)==Animation.TYPE_ROTATION_3D and str(animation.track_get_path(track)).split(":")[-1]==demo.skeleton.get_bone_name(bone):
				expected=animation.rotation_track_interpolate(track,demo.player.current_animation_position)
		maximum=maxf(maximum,rad_to_deg(expected.normalized().angle_to(demo.skeleton.get_bone_pose_rotation(bone).normalized())))
	return maximum

func arm_clearance() -> Dictionary:
	# Four model-space directions against the exported LBS surface; independent of actor heading.
	demo.skeleton.force_update_all_bone_transforms()
	var arrays: Array=rig_mesh.mesh.surface_get_arrays(0)
	var skin: Skin=rig_mesh.skin
	var maps := [];var matrices := []
	for bind in skin.get_bind_count():
		var bone: int=skin.get_bind_bone(bind)
		if bone<0:bone=demo.skeleton.find_bone(skin.get_bind_name(bind))
		maps.append(bone);matrices.append(demo.model.global_transform.affine_inverse()*demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(bone)*skin.get_bind_pose(bind))
	var body := [];var arms := [];var points := PackedVector3Array()
	for vertex in arrays[Mesh.ARRAY_VERTEX].size():
		var body_weight := 0.0;var arm_weight := 0.0;var point := Vector3.ZERO
		for i in 4:
			var bind: int=arrays[Mesh.ARRAY_BONES][vertex*4+i];var weight: float=arrays[Mesh.ARRAY_WEIGHTS][vertex*4+i]
			var name: String=demo.skeleton.get_bone_name(maps[bind])
			if name in ["Hips","Spine","Spine01","Spine02","LeftUpLeg","RightUpLeg"]:body_weight+=weight
			if name.ends_with("ForeArm") or name.ends_with("Hand"):arm_weight+=weight
			point+=matrices[bind]*arrays[Mesh.ARRAY_VERTEX][vertex]*weight
		points.append(point);body.append(body_weight>.5)
		if arm_weight>.9:arms.append(vertex)
	var faces := [];var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
	for i in range(0,indices.size(),3):
		if body[indices[i]] and body[indices[i+1]] and body[indices[i+2]]:faces.append([indices[i],indices[i+1],indices[i+2]])
	var inside := 0;var gap := INF;var penetration := 0.0;var hits := 0
	for vertex in arms:
		var point: Vector3=points[vertex]
		var depth := INF;var exterior_gap := 0.0
		for axis in [0,2]:
			var origin := point;origin[axis]=-3
			var direction := Vector3.ZERO;direction[axis]=1
			var lo := INF;var hi := -INF
			for face in faces:
				var hit: Variant=Geometry3D.ray_intersects_triangle(origin,direction,points[face[0]],points[face[1]],points[face[2]])
				if hit!=null:lo=minf(lo,hit[axis]);hi=maxf(hi,hit[axis]);hits+=1
			if not is_finite(lo):depth=-INF;continue
			depth=minf(depth,minf(point[axis]-lo,hi-point[axis]))
			exterior_gap=maxf(exterior_gap,maxf(lo-point[axis],point[axis]-hi))
		if depth>.001:inside+=1;penetration=maxf(penetration,depth)
		if exterior_gap>0:gap=minf(gap,exterior_gap)
	assert(arms.size()>1000 and faces.size()>500,"Clearance query has no body/arm geometry")
	return {"distal_vertices":arms.size(),"body_triangles":faces.size(),"interior_vertices":inside,"model_space_surface_hits":hits,"minimum_gap":gap if is_finite(gap) else null,"maximum_penetration":penetration}

func check_knees() -> void:
	for side in ["Left","Right"]:
		var h: Vector3=demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone(side+"UpLeg")).origin*.01
		var k: Vector3=demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone(side+"Leg")).origin*.01
		var a: Vector3=demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone(side+"Foot")).origin*.01
		var flex := 180-rad_to_deg((h-k).angle_to(a-k))
		var line := (a-h).normalized()
		var offset := (k-h)-line*(k-h).dot(line)
		assert(flex<10 or offset.z>=.005,"Backwards knee in "+demo.jump_stage+" "+side+" "+str([flex,offset.z]))

func bone_positions() -> Dictionary:
	var positions := {}
	for bone in demo.skeleton.get_bone_count():
		positions[bone]=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(bone)).origin-demo.body.position
	return positions
