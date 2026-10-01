extends Node3D
## THROWAWAY #231: source-informed movement and interaction review.
# Travel gain remains a playtest calibration, not recovered game meters.
const Locomotion = preload("res://locomotion.gd")
var movement := Locomotion.new()
var body: CharacterBody3D
var model: Node3D
var player: AnimationPlayer
var skeleton: Skeleton3D
var camera: Camera3D
var status: Label
var state := "Idle"
var camera_view := 0
var dust := []
var emitted := 0
var bridge_time := 0.0
var soles := []
var obstruction := 1.0
var tool := "None"
var tool_rotations := {}
var previous_arm_pose := {}
var overlay_from := {}
var last_overlay := "None"
var overlay_time := 1.0
var tool_attachment: BoneAttachment3D
var tool_meshes := {}
var surface := "Path"
var raining := false
var indoor := false
var dialogue := 0
var interaction := ""
var interaction_timer := 0.0
var npc_point := Vector3(-2,0,-3)
var door_point := Vector3(0,0,-8)
var fade: ColorRect
var message: Label
var face_material: ShaderMaterial
var blink_clock := 1.4
var blink_index := -1
var blink_repeat := 0
var blink_updates := 0.0
var random := RandomNumberGenerator.new()
var footprint_count := 0
var foot_audio: AudioStreamPlayer
var dust_texture: ImageTexture
var calibration := 0
var slow := false
var step_history := []
var foot_order := {}
var face_blinks := 0
var door_transitions := 0
var max_floor_error := 0.0
var ground_material: StandardMaterial3D
var path_nodes := []

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 1
	return result

func block(position: Vector3, size: Vector3, color: Color, solid := false) -> Node3D:
	var node := StaticBody3D.new() if solid else Node3D.new()
	node.position = position
	add_child(node)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material(color)
	node.add_child(mesh)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		node.add_child(collision)
	return node

func _ready() -> void:
	var keys: Dictionary = {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"sprint":[KEY_SHIFT],"slow":[KEY_CTRL],"interact":[KEY_E]}
	for action in keys:
		InputMap.add_action(action)
		for key in keys[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action,event)
	for item in [["left",JOY_AXIS_LEFT_X,-1],["right",JOY_AXIS_LEFT_X,1],["up",JOY_AXIS_LEFT_Y,-1],["down",JOY_AXIS_LEFT_Y,1]]:
		var event := InputEventJoypadMotion.new();event.axis=item[1];event.axis_value=item[2]
		InputMap.action_add_event(item[0],event)
	for key in [JOY_BUTTON_B,JOY_BUTTON_LEFT_SHOULDER,JOY_BUTTON_RIGHT_SHOULDER]:
		var event := InputEventJoypadButton.new();event.button_index=key
		InputMap.action_add_event("sprint",event)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("8fc3b0")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.45
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-20,0)
	sun.shadow_enabled = true
	sun.light_energy = 0.65
	add_child(sun)
	var ground := block(Vector3(0,-0.1,0),Vector3(32,0.2,32),Color("50914a"),true)
	ground_material=ground.get_child(0).material_override
	path_nodes.append(block(Vector3(0,0.002,0),Vector3(5,0.006,32),Color("c8b775")))
	for i in range(-15,16):
		path_nodes.append(block(Vector3(0,0.008,i),Vector3(5,0.004,0.025),Color("ad9b62")))
	for x in [-16,16]: block(Vector3(x,0.5,0),Vector3(0.4,1,32),Color("577541"),true)
	for z in [-16,16]: block(Vector3(0,0.5,z),Vector3(32,1,0.4),Color("577541"),true)
	for point in [Vector3(-4,0,-4),Vector3(4,0,3),Vector3(-6,0,5),Vector3(6,0,-6)]:
		block(point+Vector3.UP*0.5,Vector3(0.5,1,0.5),Color("976647"),true)
		var tree := MeshInstance3D.new()
		var crown := SphereMesh.new()
		crown.radius = 1.0
		crown.height = 2.4
		tree.mesh = crown
		tree.position = point+Vector3.UP*2
		tree.material_override = material(Color("326842"))
		add_child(tree)
	body = CharacterBody3D.new()
	add_child(body)
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.24
	capsule.height = 1.4
	collision.shape = capsule
	collision.position.y = 0.7
	body.add_child(collision)
	model = load("res://walk.glb").instantiate()
	body.add_child(model)
	player = model.find_children("*","AnimationPlayer",true,false)[0]
	skeleton = model.find_children("*","Skeleton3D",true,false)[0]
	assert(skeleton.get_bone_count()==24)
	for name in ["run","dash","skid","axe","net"]:
		var source: Node3D = load("res://"+name+".glb").instantiate()
		var source_player: AnimationPlayer = source.find_children("*","AnimationPlayer",true,false)[0]
		var animation: Animation = source_player.get_animation("walk").duplicate()
		if name in ["axe","net"]:
			tool_rotations[name.capitalize()] = {}
			for track in animation.get_track_count():
				if animation.track_get_type(track)!=Animation.TYPE_ROTATION_3D: continue
				var bone_name := str(animation.track_get_path(track)).split(":")[-1]
				if bone_name in (["RightShoulder","RightArm","RightForeArm","RightHand"] if name=="net" else ["LeftShoulder","LeftArm","LeftForeArm","LeftHand","RightShoulder","RightArm","RightForeArm","RightHand"]):
					tool_rotations[name.capitalize()][skeleton.find_bone(bone_name)] = animation.rotation_track_interpolate(track,0)
		else: player.get_animation_library("").add_animation(name,animation)
		source.free()
	for clip in ["idle","walk","run","dash","skid"]: player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play("idle")
	player.advance(0)
	make_tools()
	make_face()
	make_interactions()
	make_effects()
	# Cache only rigid Foot vertices using the existing proof's skin calculation.
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		if mesh.skin==null:continue
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				for influence in 4:
					if arrays[Mesh.ARRAY_WEIGHTS][vertex*4+influence]<0.9999: continue
					var bind: int = arrays[Mesh.ARRAY_BONES][vertex*4+influence]
					var bone: int = mesh.skin.get_bind_bone(bind)
					if bone<0: bone = skeleton.find_bone(mesh.skin.get_bind_name(bind))
					if skeleton.get_bone_name(bone) in ["LeftFoot","RightFoot"]:
						soles.append({"bone":bone,"point":mesh.skin.get_bind_pose(bind)*arrays[Mesh.ARRAY_VERTEX][vertex]})
	assert(soles.size()>500)
	for clip in ["walk","run","dash"]:
		foot_order[clip.capitalize()]=[]
		player.play(clip)
		for phase in [0.0,.5]:
			player.seek(player.get_animation(clip).length*phase,true)
			skeleton.force_update_all_bone_transforms()
			var floors := {"Left":INF,"Right":INF}
			for sole in soles:
				var side := "Left" if skeleton.get_bone_name(sole.bone)=="LeftFoot" else "Right"
				floors[side]=minf(floors[side],(skeleton.global_transform*(skeleton.get_bone_global_pose(sole.bone)*sole.point)).y)
			foot_order[clip.capitalize()].append("Left" if floors.Left<floors.Right else "Right")
	player.play("idle")
	player.advance(0)
	camera = Camera3D.new()
	camera.fov = 20
	add_child(camera)
	make_ui()
	print("CHARACTER_PLAYTEST_READY")

func make_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(14,14)
	layer.add_child(panel)
	var lines := VBoxContainer.new()
	panel.add_child(lines)
	status = Label.new()
	status.text = "Character playtest · Idle"
	lines.add_child(status)
	var hint := Label.new()
	hint.text = "WASD / arrows · Shift sprint · Ctrl walk\nE interact · R reset · touch arrows + Sprint"
	lines.add_child(hint)
	var controls := HBoxContainer.new()
	lines.add_child(controls)
	for title in ["View","Reset","Interact"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		controls.add_child(button)
		if title=="Reset": button.pressed.connect(reset)
		elif title=="Interact": button.pressed.connect(interact)
		else: button.pressed.connect(func(): camera_view = (camera_view+1)%3)
	var options := HBoxContainer.new()
	lines.add_child(options)
	for title in ["Tool","Surface","Rain"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		options.add_child(button)
		if title=="Tool": button.pressed.connect(cycle_tool)
		elif title=="Surface": button.pressed.connect(cycle_surface)
		else: button.pressed.connect(func(): raining = not raining)
	var tuning := HBoxContainer.new()
	lines.add_child(tuning)
	for title in ["Walk / Run","Speed"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		tuning.add_child(button)
		if title=="Walk / Run": button.pressed.connect(func(): slow = not slow)
		else: button.pressed.connect(func(): calibration = (calibration+1)%3;movement.travel_gain = [3.15,4.725,6.867][calibration]/4.875)
	message = Label.new()
	message.text = "E near the neighbour or house door"
	message.add_theme_font_size_override("font_size",13)
	lines.add_child(message)
	fade = ColorRect.new()
	var iris := Shader.new()
	iris.code="""shader_type canvas_item;
uniform float amount=0.0;
void fragment(){
 vec2 size=1.0/SCREEN_PIXEL_SIZE;
 vec2 p=(UV-vec2(.5))*vec2(size.x/size.y,1.0);
 float radius=(1.0-amount)*length(vec2(size.x/size.y,1.0))*.51;
 COLOR=vec4(0.0,0.0,0.0,smoothstep(radius-.006,radius,length(p)));
}"""
	var iris_material := ShaderMaterial.new();iris_material.shader=iris
	fade.material=iris_material
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(fade)
	var touch := Node2D.new()
	layer.add_child(touch)
	var texture := Image.create(62,62,false,Image.FORMAT_RGBA8)
	texture.fill(Color(0.12,0.25,0.19,0.85))
	for item in [["left","<",Vector2(0,64)],["up","^",Vector2(64,0)],["down","v",Vector2(64,128)],["right",">",Vector2(128,64)],["sprint","Sprint",Vector2(218,128)]]:
		var button := TouchScreenButton.new()
		button.action = item[0]
		button.texture_normal = ImageTexture.create_from_image(texture)
		button.position = item[2]
		touch.add_child(button)
		var label := Label.new()
		label.text = item[1]
		label.position = Vector2(3,15)
		label.size = Vector2(56,32)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if item[0]!="sprint": label.add_theme_font_size_override("font_size",26)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)
	get_viewport().size_changed.connect(func(): touch.position = Vector2(14,get_viewport().get_visible_rect().size.y-212))
	touch.position = Vector2(14,get_viewport().get_visible_rect().size.y-212)

func reset() -> void:
	body.position = Vector3.ZERO
	body.velocity = Vector3.ZERO
	movement.reset()
	model.rotation = Vector3.ZERO
	state = "Idle"
	player.play("idle",0.15)
	dialogue = 0
	interaction = ""
	indoor = false
	obstruction = 1
	if fade: fade.material.set_shader_parameter("amount",0)
	if message: message.text = "E near the neighbour or house door"
	for puff in dust: puff.node.queue_free()
	dust.clear()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_R: reset()
		elif event.physical_keycode==KEY_E: interact()

func cycle_tool() -> void:
	tool = ["None","Axe","Net"][( ["None","Axe","Net"].find(tool)+1)%3]

func cycle_surface() -> void:
	var choices := ["Path","Grass","Sand","Water","Snow","Leaves","Indoor"]
	surface = choices[(choices.find(surface)+1)%choices.size()]

func primitive(parent: Node3D, shape: Mesh, position: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.position = position
	node.material_override = material(color)
	parent.add_child(node)
	return node

func make_tools() -> void:
	tool_attachment = BoneAttachment3D.new()
	tool_attachment.bone_name = "RightHand"
	skeleton.add_child(tool_attachment)
	for name in ["Axe","Net"]:
		var prop := Node3D.new()
		tool_attachment.add_child(prop)
		prop.scale = Vector3.ONE*100 # BoneAttachment resets its transform; compensate on the prop.
		tool_meshes[name] = prop
		var shaft := CylinderMesh.new()
		shaft.top_radius=.022;shaft.bottom_radius=.022;shaft.height=.65
		primitive(prop,shaft,Vector3(0,.25,0),Color("94613b"))
		if name=="Axe":
			var blade := BoxMesh.new();blade.size=Vector3(.28,.19,.04)
			primitive(prop,blade,Vector3(.09,.56,0),Color("434b5b"))
		else:
			var rim := TorusMesh.new();rim.inner_radius=.16;rim.outer_radius=.18
			var node := primitive(prop,rim,Vector3(0,.68,0),Color("a9947f"))
			node.rotation_degrees.x=90
			for offset in [-.1,0,.1]:
				var strand := BoxMesh.new();strand.size=Vector3(.29,.006,.006)
				primitive(prop,strand,Vector3(0,.68+offset,0),Color("e4d5c0"))
		prop.rotation_degrees=Vector3(0,0,-90)

func make_face() -> void:
	random.seed=231
	var shader := Shader.new()
	shader.code = """shader_type spatial;
render_mode unshaded;
uniform sampler2D atlas : source_color, filter_nearest;
uniform float blink=0.0;
void fragment(){
 ALBEDO=texture(atlas,UV).rgb;
 vec2 centers[4]=vec2[4](vec2(.578,.564),vec2(.736,.564),vec2(.18,.086),vec2(.869,.094));
 for(int i=0;i<4;i++){
  vec2 d=(UV-centers[i])/vec2(.042,.04);
  if(blink>0.0 && dot(d,d)<1.0 && d.y<(-1.0+2.0*blink)){
   ALBEDO=texture(atlas,vec2(.64,.55)).rgb;
   if(blink>.9 && abs(d.y)<.08 && abs(d.x)<.72)ALBEDO=vec3(.24,.16,.12);
  }
 }
}"""
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		for index in mesh.mesh.get_surface_count():
			var source: Material = mesh.get_active_material(index)
			if source is StandardMaterial3D and source.albedo_texture:
				face_material = ShaderMaterial.new()
				face_material.shader=shader
				face_material.set_shader_parameter("atlas",source.albedo_texture)
				mesh.set_surface_override_material(index,face_material)

func make_interactions() -> void:
	block(door_point+Vector3(0,1.7,-.5),Vector3(4,3.4,1),Color("bd9565"),true)
	block(door_point+Vector3(0,.85,.05),Vector3(1.25,1.7,.04),Color("665642"))
	block(Vector3(40,-.1,0),Vector3(10,.2,10),Color("a48665"),true)
	for x in [35,45]:block(Vector3(x,1.5,0),Vector3(.2,3,10),Color("e3cda8"),true)
	for z in [-5,5]:block(Vector3(40,1.5,z),Vector3(10,3,.2),Color("e3cda8"),true)
	block(Vector3(40,.7,-4.9),Vector3(1.3,1.4,.03),Color("665642"))
	var npc := Node3D.new();npc.position=npc_point;add_child(npc)
	var sphere := SphereMesh.new();sphere.radius=.3;sphere.height=.6
	primitive(npc,sphere,Vector3.UP*1.25,Color("d7ae72"))
	var torso := CapsuleMesh.new();torso.radius=.25;torso.height=.8
	primitive(npc,torso,Vector3.UP*.6,Color("657ab4"))

func interact() -> void:
	if interaction in ["Door","DoorApproach"]:return
	if dialogue>0:
		dialogue+=1
		if dialogue==2:
			message.text="A gift for you! · E to continue"
			interaction="Receive";interaction_timer=.7
		elif dialogue>=3:
			dialogue=0;interaction="";message.text="See you around!"
		return
	if indoor and body.position.distance_to(Vector3(40,0,-4))<2.5 or not indoor and body.position.distance_to(door_point)<2.5:
		interaction="DoorApproach";interaction_timer=0;movement.velocity=0
	elif not indoor and body.position.distance_to(npc_point)<2.5:
		dialogue=1;interaction="Talk";movement.velocity=0
		movement.heading=atan2(npc_point.x-body.position.x,npc_point.z-body.position.z)
		movement.shape_heading=movement.heading
		message.text="Hello, neighbour! · E to continue"
	else:message.text="Move closer to the neighbour or door"

func make_effects() -> void:
	foot_audio=AudioStreamPlayer.new();foot_audio.volume_db=-18;add_child(foot_audio)
	var stream := AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=16000
	var samples := PackedByteArray();samples.resize(1280*2)
	for i in 1280:
		var value := int(random.randf_range(-1,1)*pow(1-i/1280.0,3)*5000)
		samples.encode_s16(i*2,value)
	stream.data=samples;foot_audio.stream=stream
	var texture := Image.create(32,32,false,Image.FORMAT_RGBA8)
	for y in 32:
		for x in 32:
			var distance := Vector2(x-15.5,y-15.5).length()/15.5
			texture.set_pixel(x,y,Color(1,1,1,clampf(1-distance*distance,0,1)))
	dust_texture=ImageTexture.create_from_image(texture)

func footstep(foot: String) -> void:
	if state=="Idle" or dialogue>0 or interaction=="Door" or Vector2(body.velocity.x,body.velocity.z).length()<.08:return
	skeleton.force_update_all_bone_transforms()
	var ankle := skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone(foot+"Foot")).origin
	footprint_count+=1
	foot_audio.pitch_scale=.7 if state=="Skid" else {"Water":1.3,"Snow":.8,"Sand":.85,"Leaves":1.2,"Indoor":.9}.get(surface,1.0)
	foot_audio.play()
	var ground := "Indoor" if indoor else ("Water" if raining and surface!="Indoor" else surface)
	step_history.append({"foot":foot,"surface":ground,"position":[ankle.x,body.position.y,ankle.z],"phase":movement.phase})
	if step_history.size()>24:step_history.pop_front()
	if ground=="Indoor" or (state!="Dash" and state!="Skid" and ground in ["Grass","Path","Sand"]):return
	var colors := {"Path":Color("f5f7ff"),"Grass":Color("f5f7ff"),"Sand":Color("d9c698"),"Water":Color("b9dbea"),"Snow":Color.WHITE,"Leaves":Color("588936")}
	for i in 3:
		var puff := MeshInstance3D.new()
		var quad := QuadMesh.new();quad.size=Vector2(.16,.16)
		puff.mesh=quad
		var mat := material(colors.get(ground,Color.WHITE));mat.albedo_texture=dust_texture
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;mat.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED;mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		puff.material_override=mat
		add_child(puff)
		var origin := Vector3(ankle.x,body.position.y+.04,ankle.z)
		var backward := -Vector3(sin(movement.heading),0,cos(movement.heading))
		dust.append({"node":puff,"age":0.0,"origin":origin,"direction":backward*(.3+i*.15)+Vector3((i-1)*.15,0,0)})
	emitted+=1

func _physics_process(delta: float) -> void:
	if player==null:return
	ground_material.albedo_color={"Path":Color("50914a"),"Grass":Color("50914a"),"Sand":Color("bdae82"),"Water":Color("397d99"),"Snow":Color("dedfdf"),"Leaves":Color("796936"),"Indoor":Color("a48665")}[surface]
	for node in path_nodes:node.visible=surface=="Path"
	var input := Input.get_vector("left","right","up","down",0)
	if input.length()<=9.899495/61:input=Vector2.ZERO
	if slow or Input.is_action_pressed("slow"):input*=.45
	var yaw: float=[0.0,PI/2,0.0][camera_view]
	input=input.rotated(-yaw)
	if interaction=="DoorApproach":
		var approach := (Vector3(40,0,-4.2) if indoor else Vector3(0,0,-7.2))-body.position
		if Vector2(approach.x,approach.z).length()<.08:
			interaction="Door";interaction_timer=0;movement.velocity=0;input=Vector2.ZERO
		else:input=Vector2(approach.x,approach.z).normalized()*.45
	if dialogue>0 or interaction=="Door":input=Vector2.ZERO
	var before := body.position
	var commanded: Vector3=movement.step(input,Input.is_action_pressed("sprint"),delta,obstruction)
	body.velocity=Vector3(commanded.x,body.velocity.y-9.8*delta,commanded.z)
	body.move_and_slide()
	var actual := Vector2(body.position.x-before.x,body.position.z-before.z).length()/delta
	obstruction=clampf(actual/maxf(commanded.length(),.001),0,1)
	model.rotation.y=movement.shape_heading
	model.rotation.x=movement.lean
	var previous_phase := movement.phase-movement.phase_step*delta*60/16
	var target_state: String=movement.gait
	if commanded.length()>.1 and actual<.02 and not movement.skidding:target_state="Idle"
	if dialogue>0 or interaction=="Door":target_state="Idle"
	var clip: String={"Idle":"idle","Walk":"walk","Run":"run","Dash":"dash","Skid":"skid"}[target_state]
	var entered_skid := target_state=="Skid" and state!="Skid"
	if target_state!=state:
		state=target_state
		player.play(clip,.167)
		if state!="Idle":player.seek(fposmod(previous_phase,1)*player.get_animation(clip).length,true)
	player.speed_scale=1 if state=="Idle" else (0 if state=="Skid" else player.get_animation(clip).length*movement.phase_step*60/16)
	player.advance(delta)
	var overlay := "Net" if interaction=="Receive" else tool
	if overlay!=last_overlay:
		overlay_from=previous_arm_pose.duplicate();overlay_time=0;last_overlay=overlay
	overlay_time=minf(.167,overlay_time+delta)
	for bone in tool_rotations.Axe:
		var animated := skeleton.get_bone_pose_rotation(bone)
		var desired: Quaternion=tool_rotations[overlay].get(bone,animated) if overlay!="None" else animated
		var start: Quaternion=overlay_from.get(bone,animated)
		skeleton.set_bone_pose_rotation(bone,start.slerp(desired,overlay_time/.167))
		previous_arm_pose[bone]=skeleton.get_bone_pose_rotation(bone)
	for name in tool_meshes:tool_meshes[name].visible=name==tool
	skeleton.force_update_all_bone_transforms()
	model.position.y=0
	# Correct the complete visual root after lean/blends; this is floor clearance, not stance IK.
	var low := INF
	for sole in soles:low=minf(low,(skeleton.global_transform*(skeleton.get_bone_global_pose(sole.bone)*sole.point)).y-body.position.y)
	model.position.y=-low
	max_floor_error=maxf(max_floor_error,absf(low+model.position.y))
	if entered_skid and actual>.08:footstep("Right")
	if state in ["Walk","Run","Dash"] and actual>.08:
		var current := movement.phase
		for offset in [0.0,.5]:
			if floor((previous_phase-offset)*2)<floor((current-offset)*2) or previous_phase<0 and current<.1:
				# Emit once per half cycle; both phases use target sole-derived contact assignment.
				var foot: String=foot_order[state][0 if offset==0 else 1]
				if offset==0 and current>=.5 or offset==.5 and current<.5:continue
				footstep(foot)
	for i in range(dust.size()-1,-1,-1):
		var puff: Dictionary=dust[i];puff.age+=delta
		if puff.age>=.3:puff.node.queue_free();dust.remove_at(i)
		else:
			puff.node.position=puff.origin+puff.direction*puff.age+Vector3.UP*(.8*puff.age-1.5*puff.age*puff.age)
			puff.node.scale=Vector3.ONE*(1+puff.age)
			puff.node.material_override.albedo_color.a=1-puff.age/.3
	blink_clock-=delta
	if blink_index<0 and blink_clock<=0:
		blink_index=15;blink_updates=0;blink_repeat=random.randi_range(0,3);face_blinks+=1
	if blink_index>=0:
		blink_updates+=delta*60
		while blink_updates>=1 and blink_index>=0:
			blink_updates-=1;blink_index-=1
		if blink_index<0:
			if blink_repeat>0:blink_repeat-=1;blink_index=15
			else:blink_clock=random.randf_range(1,2)
	if face_material:face_material.set_shader_parameter("blink",[0,0,0,0,.5,.5,1,1,1,1,1,1,.5,.5,0,0][blink_index] if blink_index>=0 else 0)
	if interaction=="Receive":
		interaction_timer-=delta
		if interaction_timer<=0:interaction="Talk"
	elif interaction=="Door":
		interaction_timer+=delta
		fade.material.set_shader_parameter("amount",clampf(1-absf(interaction_timer-.35)/.35,0,1))
		if interaction_timer>=.35 and interaction_timer-delta<.35:
			indoor=not indoor;body.position=Vector3(40,0,-2.5) if indoor else Vector3(0,0,-6)
			body.velocity=Vector3.ZERO;movement.reset();door_transitions+=1
		if interaction_timer>=.7:interaction="";fade.material.set_shader_parameter("amount",0)
	var target := body.position+Vector3.UP*.85
	var angle := deg_to_rad(25 if camera_view==2 else 45)
	camera.position=target+Vector3(sin(yaw)*cos(angle),sin(angle),cos(yaw)*cos(angle))*(19 if dialogue>0 else (22 if camera_view==0 else 17))
	camera.look_at(target)
	status.text=state+" · "+("Indoor" if indoor else surface)+" · "+tool+" · speed ×"+str([1,1.5,2.18][calibration])
	bridge_time+=delta
	if OS.has_feature("web") and bridge_time>.1:
		bridge_time=0
		JavaScriptBridge.eval("window.characterPlaytest="+JSON.stringify({"state":state,"x":body.position.x,"z":body.position.z,"yaw":model.rotation.y,"travel_heading":movement.heading,"lean":movement.lean,"phase":movement.phase,"phase_step":movement.phase_step,"effects":emitted,"view":camera_view,"bones":skeleton.get_bone_count(),"physics_time":Time.get_ticks_msec()/1000.0,"speed_mps":actual,"source_velocity":movement.velocity,"animation_rate":player.get_playing_speed(),"tool":tool,"surface":surface,"rain":raining,"indoor":indoor,"dialogue":dialogue,"interaction":interaction,"footsteps":footprint_count,"steps":step_history,"blinks":face_blinks,"blink_index":blink_index,"door_transitions":door_transitions,"floor_error":max_floor_error}))
