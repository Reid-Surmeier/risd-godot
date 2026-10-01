extends SceneTree
## Checks exported wrist motion and actual audio waveforms, independent of receipts.
var demo: Node3D
func _initialize() -> void:
	create_timer(15).timeout.connect(func():quit(1))
	call_deferred("run")
func run() -> void:
	demo=load("res://demo.gd").new();root.add_child(demo);demo.set_physics_process(false)
	await process_frame
	var palms := {"Left":[],"Right":[]}
	for mesh in demo.model.find_children("*","MeshInstance3D",true,false):
		if mesh.skin==null:continue
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
	var wrists := {}
	for clip in ["walk","run","dash","skid"]:
		demo.player.play(clip)
		var maximum := 0.0
		for i in 65:
			demo.player.seek(demo.player.get_animation(clip).length*i/64.0,true)
			demo.skeleton.force_update_all_bone_transforms()
			for side in ["Left","Right"]:
				var fore: int=demo.skeleton.find_bone(side+"ForeArm")
				var hand: int=demo.skeleton.find_bone(side+"Hand")
				var actual: Basis=demo.skeleton.get_bone_global_pose(fore).basis.inverse()*demo.skeleton.get_bone_global_pose(hand).basis
				var rest: Basis=demo.skeleton.get_bone_global_rest(fore).basis.inverse()*demo.skeleton.get_bone_global_rest(hand).basis
				maximum=maxf(maximum,rad_to_deg(actual.orthonormalized().get_rotation_quaternion().angle_to(rest.orthonormalized().get_rotation_quaternion())))
		assert(maximum<.1,"Wrist counter-rotation: "+clip+" "+str(maximum))
		wrists[clip]={"samples":65,"relative_wrist_error_degrees":maximum}
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
	FileAccess.open("res://quality-check.json",FileAccess.WRITE).store_string(JSON.stringify({"palms":shapes,"wrists":wrists,"audio":audio,"idle_silent":true,"exact_original_waveforms":false},"  "))
	print("PASS exported wrist alignment and distinct audio banks/variants/gains/envelopes/idle silence")
	quit()
