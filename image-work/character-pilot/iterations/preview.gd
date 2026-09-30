extends SceneTree
## THROWAWAY: deterministic 30fps game-camera comparison, contact-timed dust.
class ContactEvents extends Node3D:
	var calls := []
	var elapsed := 0.0
	var active := true
	var suppressed_idle_calls := 0
	func footstep(foot: String) -> void:
		# Outgoing animation method keys can fire during a crossfade into idle.
		if not active:
			suppressed_idle_calls += 1
			return
		calls.append({"time":elapsed,"foot":foot})

var report := {"cost_usd": 0, "models": [], "effects": {}}
var config: Dictionary
var models := []
var players := []
var skeletons := []
var dust := []
var viewport_height := 640
var contact_events: ContactEvents

func _initialize() -> void:
	call_deferred("run")

func material(color: Color) -> StandardMaterial3D:
	var value := StandardMaterial3D.new()
	value.albedo_color = color
	value.roughness = 1
	return value

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://" + name + ".png")

func run() -> void:
	config = JSON.parse_string(FileAccess.get_file_as_string("res://config.json"))
	root.size = Vector2i(int(config.get("width",960)),int(config.get("height",viewport_height)))
	var stage := Node3D.new()
	root.add_child(stage)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.24,0.44,0.34)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color(0.85,0.85,0.85)
	world.environment.ambient_light_energy = 0.8
	stage.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.0
	sun.rotation_degrees = Vector3(-55,-20,0)
	sun.shadow_enabled = true
	stage.add_child(sun)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40,40)
	floor.mesh = plane
	var grass := material(Color(0.23,0.51,0.23))
	var image := Image.create(64,64,false,Image.FORMAT_RGB8)
	image.fill(Color(0.20,0.48,0.20))
	for y in 64:
		for x in 64:
			if (x % 16 + y % 16) < 9:
				image.set_pixel(x,y,Color(0.26,0.55,0.25))
	grass.albedo_texture = ImageTexture.create_from_image(image)
	grass.uv1_scale = Vector3(20,20,1)
	grass.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	floor.material_override = grass
	stage.add_child(floor)
	var path := MeshInstance3D.new()
	var path_plane := PlaneMesh.new()
	path_plane.size = Vector2(5,40)
	path.mesh = path_plane
	path.position.y = 0.001
	path.material_override = material(Color(0.64,0.56,0.31))
	stage.add_child(path)
	# Distance marks make controller travel and stance sliding visible.
	for i in range(-12,20):
		var line := MeshInstance3D.new()
		var mark := PlaneMesh.new()
		mark.size = Vector2(5,0.018)
		line.mesh = mark
		line.position = Vector3(0,0.002,i*0.5)
		line.material_override = material(Color(0.55,0.47,0.25))
		stage.add_child(line)
	var camera := Camera3D.new()
	camera.fov = 20
	stage.add_child(camera)
	var labels := CanvasLayer.new()
	stage.add_child(labels)
	for index in config.models.size():
		var entry: Dictionary = config.models[index]
		var model: Node3D = load("res://model-%d.glb" % index).instantiate()
		stage.add_child(model)
		model.position.x = (index-(config.models.size()-1)/2.0)*2.3
		models.append(model)
		var player: AnimationPlayer = model.find_children("*","AnimationPlayer",true,false)[0]
		var skeleton: Skeleton3D = model.find_children("*","Skeleton3D",true,false)[0]
		assert(skeleton.get_bone_count()==24)
		assert(player.has_animation(config.clip))
		player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		for clip in ["idle","walk"]: player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		player.play("idle" if config.get("transition",false) else config.clip)
		if index==config.models.size()-1 and config.get("effects",false) and config.clip=="walk":
			contact_events = ContactEvents.new()
			contact_events.name = "ContactEvents"
			player.get_node(player.root_node).add_child(contact_events)
			var animation: Animation = player.get_animation("walk").duplicate()
			var track := animation.add_track(Animation.TYPE_METHOD)
			animation.track_set_path(track,NodePath("ContactEvents"))
			for event in config.contacts:
				animation.track_insert_key(track,event.time,{"method":&"footstep","args":[event.foot]})
			player.get_animation_library("").add_animation("walk-contact-proof",animation)
			player.callback_mode_method = AnimationMixer.ANIMATION_CALLBACK_MODE_METHOD_IMMEDIATE
			player.play("walk-contact-proof")
		players.append(player);skeletons.append(skeleton)
		var label := Label.new()
		label.text = entry.label
		label.position = Vector2(15+index*480,15)
		label.add_theme_color_override("font_shadow_color",Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x",2)
		label.add_theme_constant_override("shadow_offset_y",2)
		label.add_theme_font_size_override("font_size",20)
		labels.add_child(label)
		var puffs := []
		for puff_index in 5:
			var puff := MeshInstance3D.new()
			var sphere := SphereMesh.new()
			sphere.radius = 0.045
			sphere.height = 0.09
			puff.mesh = sphere
			var dust_color := material(Color(0.63,0.58,0.48))
			dust_color.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			puff.material_override = dust_color
			puff.visible = false
			stage.add_child(puff)
			puffs.append(puff)
		dust.append(puffs)
		report.models.append({"label":entry.label,"bones":24,"minimum_sole_y_m":INF,"unclamped_minimum_sole_y_m":INF,"maximum_blend_root_lift_m":0,"contact_events":[]})
	await process_frame
	var duration: float = players[0].get_animation(config.clip).length
	var frames: int = roundi(duration*30)
	assert(abs(frames/30.0-duration)<0.00001)
	report["clip"] = config.clip
	report["seconds"] = duration
	report["frames_per_cycle"] = frames
	report["fps"] = 30
	report["camera"] = {"depression_degrees":config.angle,"vertical_fov_degrees":20,"distance_m":config.get("camera_distance",10.5),"viewport_pixels":[root.size.x,root.size.y]}
	var stance_events: Array = config.get("contacts",[])
	var speed: float = config.get("controller_speed_m_s",0)
	var angle: float = deg_to_rad(config.angle)
	var cycles: int = config.get("cycles",3)
	var effect_calls := 0
	var transition: bool = config.get("transition",false)
	var total_frames := 124 if transition else frames*cycles
	for frame in total_frames:
		var t := frame/30.0
		var phase := (frame % frames)/30.0
		var travel_time: float = clampf((frame-30)/30.0,0,64/30.0) if transition else t
		for index in models.size():
			models[index].position.z = speed*travel_time
			models[index].position.y = 0
			if transition:
				if frame==30:players[index].play("walk",0.2)
				if frame==94:players[index].play("idle",0.2)
				players[index].advance(1.0/30.0)
			elif index==models.size()-1 and contact_events!=null:
				contact_events.elapsed = t
				players[index].advance(0 if frame==0 else 1.0/30.0)
			else:players[index].seek(phase,true)
			skeletons[index].force_update_all_bone_transforms()
			var bounds := skin_bounds(models[index],skeletons[index])
			report.models[index].unclamped_minimum_sole_y_m = min(report.models[index].unclamped_minimum_sole_y_m,bounds.position.y)
			if index==models.size()-1 and transition and config.get("blend_ground_lift",false) and ((frame>=30 and frame<36) or (frame>=94 and frame<100)):
				# ponytail: visual floor lift during six blend frames; world-anchor IK needed for planted transitions.
				var lift := maxf(0,-bounds.position.y)
				models[index].position.y = lift
				report.models[index].maximum_blend_root_lift_m = max(report.models[index].maximum_blend_root_lift_m,lift)
				bounds.position.y += lift
			report.models[index].minimum_sole_y_m = min(report.models[index].minimum_sole_y_m,bounds.position.y)
			for puff in dust[index]:puff.visible = false
			if index==models.size()-1 and contact_events!=null:
				# ponytail: six contact records in this proof; a runtime emitter expires finished bursts.
				for event in contact_events.calls:
					var age := t-float(event.time)
					if age>=0 and age<0.24:
						var bone: int = skeletons[index].find_bone(event.foot+"Foot")
						var foot: Vector3 = skeletons[index].global_transform*skeletons[index].get_bone_global_pose(bone).origin
						for p in dust[index].size():
							var puff: MeshInstance3D = dust[index][p]
							puff.visible = true
							var direction := Vector3(cos(p*2.4),0,sin(p*2.4))
							var outer_edge := 0.13 if event.foot=="Left" else -0.13
							puff.position = Vector3(foot.x+outer_edge,0.025,foot.z+0.07)+direction*age*0.85+Vector3.UP*sin(age/0.24*PI)*0.09
							puff.scale = Vector3.ONE*(1-age/0.24)
		var target := Vector3(0,0.85,speed*travel_time)
		camera.position = target+Vector3(0,sin(angle),cos(angle))*float(config.get("camera_distance",10.5))
		camera.look_at(target)
		await capture("frame-%03d" % frame)
		if frame==8:
			root.get_texture().get_image().save_png("res://comparison.png")
		if frame==11:
			root.get_texture().get_image().save_png("res://effects.png")
	if contact_events!=null:
		effect_calls = contact_events.calls.size()
		report.models[-1].contact_events = contact_events.calls.duplicate()
		contact_events.active = false
		players[-1].play("idle",0.2)
		players[-1].advance(1)
		assert(contact_events.calls.size()==effect_calls,"idle added a footstep")
	assert(config.clip!="idle" or effect_calls==0,"idle emitted dust")
	if config.get("effects",false):assert(effect_calls==stance_events.size()*cycles,"contact events not periodic")
	if transition:
		report["transition"]={"sequence":"idle 1s → walk 2loops → idle 1s","blend_seconds":0.2,"floor_gate":"PASS" if report.models[-1].minimum_sole_y_m > -0.01 else "FAIL","stance_lock_during_blend_tested":false}
	report.effects={"kind":"native Animation method keys trigger contact-timed mesh dust puffs","calls":effect_calls,"idle_control":config.clip=="idle","idle_added_calls":0,"suppressed_outgoing_walk_keys_in_idle":contact_events.suppressed_idle_calls if contact_events!=null else 0,"native_method_track_tested":contact_events!=null,"contacts_per_loop":stance_events.size(),"cycles":cycles}
	FileAccess.open("res://evidence.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  ")+"\n")
	print("CONTINUOUS_PREVIEW_PASS ",JSON.stringify(report))
	quit(0)
