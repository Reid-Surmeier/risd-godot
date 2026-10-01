extends Node3D
## THROWAWAY #231: source-informed movement and interaction review.
# Travel gain remains a playtest calibration, not recovered game meters.
const Locomotion = preload("res://locomotion.gd")
const Sounds = preload("res://sound.gd")
var movement := Locomotion.new()
var sounds := Sounds.new()
var audio_history := []
var effect_audio: AudioStreamPlayer
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
var animated_arm_pose := {}
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
var dust_textures := []
var surface_textures := {}
var calibration := 0
var slow := false
var jump_time := -1.0
var jump_launched := false
var jump_landed := false
var jumps := 0
var landings := 0
var step_history := []
var foot_order := {}
var face_blinks := 0
var door_transitions := 0
var door_entering := true
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
	var keys: Dictionary = {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"sprint":[KEY_SHIFT],"slow":[KEY_CTRL],"interact":[KEY_E],"jump":[KEY_SPACE]}
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
			# Constant rest channels can be omitted on import; retain the actual bone rest pose.
			for side in (["Right"] if name=="net" else ["Left","Right"]):
				for part in ["Shoulder","Arm","ForeArm","Hand"]:
					var bone: int=skeleton.find_bone(side+part)
					tool_rotations[name.capitalize()][bone]=skeleton.get_bone_rest(bone).basis.orthonormalized().get_rotation_quaternion()
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
	make_jump_animation()
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
	hint.text = "WASD / arrows · Shift sprint · Ctrl walk\nE interact · R reset · Space jump"
	lines.add_child(hint)
	var controls := HBoxContainer.new()
	lines.add_child(controls)
	for title in ["View","Reset","Interact","Jump"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		controls.add_child(button)
		if title=="Reset": button.pressed.connect(reset)
		elif title=="Interact": button.pressed.connect(interact)
		elif title=="Jump": button.pressed.connect(jump)
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
	for item in [["left","<",Vector2(0,64)],["up","^",Vector2(64,0)],["down","v",Vector2(64,128)],["right",">",Vector2(128,64)],["sprint","Sprint",Vector2(218,128)],["jump","Jump",Vector2(218,64)]]:
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
		if item[0] not in ["sprint","jump"]: label.add_theme_font_size_override("font_size",26)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)
	get_viewport().size_changed.connect(func(): touch.position = Vector2(14,get_viewport().get_visible_rect().size.y-212))
	touch.position = Vector2(14,get_viewport().get_visible_rect().size.y-212)

func reset() -> void:
	jump_time=-1; jump_launched=false; jump_landed=false
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
		# Preserve the source tool socket on the prop, without rotating the palm.
		# Offsets: original fitted tool Hand channel relative to the shared rest Hand.
		var socket: Quaternion={"Axe":Quaternion(-.248413606,.694114696,.202865733,.644469521),"Net":Quaternion(-.080665449,.360625453,-.301986787,.878775482)}[name]
		prop.quaternion=socket*Quaternion.from_euler(Vector3(0,0,-PI/2))

func make_face() -> void:
	random.seed=231
	var shader := Shader.new()
	shader.code = """shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform sampler2D atlas : source_color, filter_linear_mipmap;
uniform float blink=0.0;
void fragment(){
 ALBEDO=texture(atlas,UV).rgb;
 ROUGHNESS=1.0;
 SPECULAR=.5;
 vec2 centers[4]=vec2[4](vec2(.578,.564),vec2(.736,.564),vec2(.18,.086),vec2(.869,.094));
 // Atlas-specific skin patches; horizontal probes cross clothing/island edges.
 vec2 skin_top[4]=vec2[4](vec2(.578,.514),vec2(.736,.514),vec2(.18,.035),vec2(.869,.144));
 vec2 skin_bottom[4]=vec2[4](vec2(.578,.615),vec2(.736,.615),vec2(.18,.035),vec2(.869,.144));
 for(int i=0;i<4;i++){
  vec2 radius=vec2(.049,.047);
  vec2 d=(UV-centers[i])/radius;
  if(blink>0.0 && COLOR.a>.5 && dot(d,d)<1.0){
   float opening=max(.025,1.0-blink);
   vec3 lid=mix(textureLod(atlas,skin_top[i],0.0).rgb,textureLod(atlas,skin_bottom[i],0.0).rgb,clamp((d.y+1.0)*.5,0.0,1.0));
   vec2 iris_uv=centers[i]+vec2(d.x,clamp(d.y/opening,-1.0,1.0))*radius;
   float exposed=1.0-smoothstep(opening-.045,opening+.045,abs(d.y));
   vec3 closing=mix(lid,textureLod(atlas,iris_uv,0.0).rgb,exposed);
   float line=(1.0-smoothstep(.025,.075,abs(d.y-.08*d.x*d.x)))*(1.0-smoothstep(.65,.85,abs(d.x)))*smoothstep(.8,1.0,blink);
   closing=mix(closing,vec3(.15,.09,.07),line);
   ALBEDO=mix(ALBEDO,closing,(1.0-smoothstep(.97,1.0,length(d)))*smoothstep(0.0,.125,blink));
  }
 }
}"""
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		# Immutable skin assignment gates the face effect; UV islands alone overlap clothes.
		if mesh.skin==null:continue
		var face_mesh := ArrayMesh.new()
		for index in mesh.mesh.get_surface_count():
			var arrays: Array=mesh.mesh.surface_get_arrays(index)
			var colors := PackedColorArray()
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				var head_weight := 0.0
				for influence in 4:
					var bind: int=arrays[Mesh.ARRAY_BONES][vertex*4+influence]
					var bone: int=mesh.skin.get_bind_bone(bind)
					if bone<0:bone=skeleton.find_bone(mesh.skin.get_bind_name(bind))
					if skeleton.get_bone_name(bone)=="Head":head_weight+=arrays[Mesh.ARRAY_WEIGHTS][vertex*4+influence]
				colors.append(Color(1,1,1,1 if head_weight>.9 else 0))
			arrays[Mesh.ARRAY_COLOR]=colors
			face_mesh.add_surface_from_arrays(mesh.mesh.surface_get_primitive_type(index),arrays)
			face_mesh.surface_set_material(index,mesh.get_active_material(index))
		mesh.mesh=face_mesh
		for index in mesh.mesh.get_surface_count():
			var source: Material = mesh.get_active_material(index)
			if source is StandardMaterial3D and source.albedo_texture:
				face_material = ShaderMaterial.new()
				face_material.shader=shader
				face_material.set_shader_parameter("atlas",source.albedo_texture)
				mesh.set_surface_override_material(index,face_material)

func blink_amount() -> float:
	if blink_index<0:return 0.0
	var age := 15.0-blink_index+blink_updates
	return smoothstep(0.0,1.0,clampf(minf((age-1)/5.0,(15-age)/5.0),0,1))

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
	foot_audio=AudioStreamPlayer.new();add_child(foot_audio)
	effect_audio=AudioStreamPlayer.new();effect_audio.volume_db=-14;add_child(effect_audio)
	# Original masks are unavailable: four authored I4 cloud silhouettes, source timing.
	var masks := []
	for frame in 4:
		var image := Image.create(16,16,false,Image.FORMAT_RGBA8)
		for y in 16:
			for x in 16:
				var point := Vector2(x-7.5,y-8.5)
				var distance := INF
				for lobe in [[Vector2(-3,-1),3.1],[Vector2(0,-3),3.7],[Vector2(3,-1),3.0],[Vector2(0,1.7),3.6]]:
					var expansion: float=1+frame*.10
					distance=minf(distance,point.distance_to(lobe[0]*expansion)-lobe[1]*(1-frame*.07))
				var alpha := clampf(.75-distance,0,1)
				if frame>=2:alpha*=smoothstep(1.0,3.5,point.length())
				image.set_pixel(x,y,Color(1,1,1,roundf(alpha*15)/15))
		masks.append(image)
	for counter in 9:
		var pair: Array=[[0,0],[0,1],[1,1],[1,2],[2,2],[2,3],[3,3],[3,3],[3,3]][counter]
		var fraction: float=[0,128,255,128,0,128,255,128,0][counter]/255.0
		var image: Image=masks[pair[0]].duplicate()
		for y in 16:
			for x in 16:image.set_pixel(x,y,masks[pair[0]].get_pixel(x,y).lerp(masks[pair[1]].get_pixel(x,y),fraction))
		dust_textures.append(ImageTexture.create_from_image(image))
	# Separate authored payloads for splash droplets, leaf chips, snow and sand grains.
	for ground in ["Water","Leaves","Snow","Sand"]:
		var image := Image.create(16,16,false,Image.FORMAT_RGBA8)
		for y in 16:
			for x in 16:
				var point := Vector2(x-7.5,y-7.5)/7.5
				var radius := Vector2(point.x*1.8,point.y).length() if ground in ["Water","Leaves"] else point.length()
				var alpha := 1-smoothstep(.65,.95,radius)
				if ground=="Leaves":alpha*=1-smoothstep(.08,.22,absf(point.x+point.y*.35))*.35
				if ground=="Snow":alpha*=1-smoothstep(.25,.4,minf(absf(point.x),absf(point.y)))
				if ground=="Sand":alpha=1.0 if absf(point.x)<.45 and absf(point.y)<.45 else 0.0
				image.set_pixel(x,y,Color(1,1,1,alpha))
		surface_textures[ground]=ImageTexture.create_from_image(image)

func effect_sound(bank: String, source_id: int) -> void:
	effect_audio.stream=sounds.streams[sounds.key(bank,false,0)];effect_audio.play()
	audio_history.append({"bank":bank,"id":source_id,"pitch":1.0})
	if audio_history.size()>64:audio_history.pop_front()

func footstep(foot: String) -> void:
	if jump_time>=0 or not body.is_on_floor() or state=="Idle" or dialogue>0 or interaction=="Door" or Vector2(body.velocity.x,body.velocity.z).length()<.08:return
	skeleton.force_update_all_bone_transforms()
	var ankle := skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone(foot+"Foot")).origin
	footprint_count+=1
	var ground := "Indoor" if indoor else ("Water" if raining and surface!="Indoor" else surface)
	if state!="Skid":
		var cue := sounds.step(ground,state,foot,indoor or ground=="Indoor")
		foot_audio.stream=cue.stream;foot_audio.pitch_scale=1.0
		foot_audio.volume_db=-14+linear_to_db(cue.gain);foot_audio.play()
		cue.erase("stream");audio_history.append(cue)
		if audio_history.size()>64:audio_history.pop_front()
	step_history.append({"foot":foot,"surface":ground,"position":[ankle.x,body.position.y,ankle.z],"phase":movement.phase})
	if step_history.size()>24:step_history.pop_front()
	if ground=="Indoor" or (state!="Dash" and state!="Skid" and ground in ["Grass","Path","Sand"]):return
	var colors := {"Path":Color.WHITE,"Grass":Color.WHITE,"Sand":Color("d9c698"),"Water":Color("b9dbea"),"Snow":Color.WHITE,"Leaves":Color("588936")}
	for i in (1 if ground in ["Grass","Path"] else 3):
		var puff := MeshInstance3D.new()
		var dry := ground in ["Grass","Path"]
		var quad := QuadMesh.new();quad.size=Vector2(.75,.75) if dry else {"Water":Vector2(.09,.16),"Leaves":Vector2(.13,.20),"Snow":Vector2(.10,.10),"Sand":Vector2(.065,.065)}[ground]
		puff.mesh=quad
		var mat := material(colors.get(ground,Color.WHITE));mat.albedo_texture=dust_textures[0] if dry else surface_textures[ground]
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;mat.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED;mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		puff.material_override=mat
		add_child(puff)
		var origin := Vector3(ankle.x,body.position.y+.04,ankle.z)
		var backward := -Vector3(sin(movement.heading),0,cos(movement.heading))
		var side := Vector3(backward.z,0,-backward.x)
		var velocity := Vector3.UP+backward*2 if dry else (Vector3.UP*(1.5+i*.2)+backward*.3+side*(i-1)*.7)/60
		dust.append({"node":puff,"age":0.0,"origin":origin,"velocity":velocity,"acceleration":Vector3.DOWN*.05-backward*.075 if dry else Vector3.DOWN*5/3600,"source_unit":movement.travel_gain/30.0 if dry else 1.0,"dry":dry,"lifetime":.3 if dry else .4})
	emitted+=1

func _physics_process(delta: float) -> void:
	if player==null:return
	if Input.is_action_just_pressed("jump"):jump()
	if jump_time>=0:
		jump_time+=delta
		if jump_time>=.1 and not jump_launched:
			body.velocity.y=3.6; jump_launched=true
		if jump_time>=1:jump_time=-1
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
			interaction="Door";interaction_timer=0;door_entering=not indoor;movement.velocity=0;input=Vector2.ZERO
		else:input=Vector2(approach.x,approach.z).normalized()*.45
	if dialogue>0 or interaction=="Door":input=Vector2.ZERO
	var before := body.position
	var commanded: Vector3=movement.step(input,Input.is_action_pressed("sprint"),delta,obstruction)
	body.velocity=Vector3(commanded.x,body.velocity.y-9.8*delta,commanded.z)
	body.move_and_slide()
	if jump_time>=0 and jump_launched and not jump_landed and body.is_on_floor():
		jump_landed=true;landings+=1
		effect_sound("Landing",-1) # Authored hop cue, not an original-game sound ID.
	var actual := Vector2(body.position.x-before.x,body.position.z-before.z).length()/delta
	obstruction=clampf(actual/maxf(commanded.length(),.001),0,1)
	model.rotation.y=movement.shape_heading
	model.rotation.x=movement.lean
	var previous_phase := movement.phase-movement.phase_step*delta*60/16
	var target_state: String=movement.gait
	if commanded.length()>.1 and actual<.02 and not movement.skidding:target_state="Idle"
	if dialogue>0 or interaction=="Door":target_state="Idle"
	var clip: String={"Idle":"idle","Walk":"walk","Run":"run","Dash":"dash","Skid":"skid"}[target_state]
	if jump_time>=0:target_state="Jump";clip="jump"
	var entered_skid := target_state=="Skid" and state!="Skid"
	# Restore the unmodified base before applying another overlay, including omitted tracks.
	for bone in animated_arm_pose:skeleton.set_bone_pose_rotation(bone,animated_arm_pose[bone])
	if target_state!=state:
		state=target_state
		player.play(clip,.167)
		if state not in ["Idle","Jump"]:player.seek(fposmod(previous_phase,1)*player.get_animation(clip).length,true)
	player.speed_scale=1 if state in ["Idle","Jump","Skid"] else player.get_animation(clip).length*movement.phase_step*60/16
	player.advance(delta)
	var overlay := "Net" if interaction=="Receive" else tool
	if overlay!=last_overlay:
		overlay_from=previous_arm_pose.duplicate();overlay_time=0;last_overlay=overlay
	overlay_time=minf(.167,overlay_time+delta)
	for bone in tool_rotations.Axe:
		var animated := skeleton.get_bone_pose_rotation(bone)
		animated_arm_pose[bone]=animated
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
	if entered_skid and actual>.08:
		effect_sound("Skid",0x4129);footstep("Right")
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
		if puff.age>=puff.lifetime:puff.node.queue_free();dust.remove_at(i)
		else:
			var ticks := floorf(puff.age*60+.00001)
			puff.node.position=puff.origin+(puff.velocity*ticks+puff.acceleration*ticks*(ticks+1)/2)*puff.source_unit
			if puff.dry:
				var counter := mini(8,int(ticks)/2)
				puff.node.material_override.albedo_texture=dust_textures[counter]
				puff.node.material_override.albedo_color.a=[255,200,200,200,200,200,200,200,0][counter]/255.0
			else:puff.node.material_override.albedo_color.a=1-puff.age/puff.lifetime
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
	if face_material:face_material.set_shader_parameter("blink",blink_amount())
	if interaction=="Receive":
		interaction_timer-=delta
		if interaction_timer<=0:interaction="Talk"
	elif interaction=="Door":
		var prior := interaction_timer
		interaction_timer+=delta
		var cue_frames := [2,8,33,40] if door_entering else [10,14,35,50]
		var last_frame := 40.0 if door_entering else 50.0
		for i in 4:
			var at: float=cue_frames[i]/last_frame*.7
			if prior<at and interaction_timer>=at:effect_sound(["DoorLatch","DoorCreak","DoorShut","DoorLatch"][i],6+i)
		fade.material.set_shader_parameter("amount",clampf(1-absf(interaction_timer-.35)/.35,0,1))
		if interaction_timer>=.35 and interaction_timer-delta<.35:
			indoor=not indoor;body.position=Vector3(40,0,-2.5) if indoor else Vector3(0,0,-6)
			body.velocity=Vector3.ZERO;movement.reset();door_transitions+=1
		if interaction_timer>=.7:interaction="";fade.material.set_shader_parameter("amount",0)
	var target := Vector3(body.position.x,.85,body.position.z)
	var angle := deg_to_rad(25 if camera_view==2 else 45)
	camera.position=target+Vector3(sin(yaw)*cos(angle),sin(angle),cos(yaw)*cos(angle))*(19 if dialogue>0 else (22 if camera_view==0 else 17))
	camera.look_at(target)
	status.text=state+" · "+("Indoor" if indoor else surface)+" · "+tool+" · speed ×"+str([1,1.5,2.18][calibration])
	bridge_time+=delta
	if OS.has_feature("web") and bridge_time>.1:
		bridge_time=0
		JavaScriptBridge.eval("window.characterPlaytest="+JSON.stringify({"state":state,"y":body.position.y,"jump_time":jump_time,"jumps":jumps,"landings":landings,"x":body.position.x,"z":body.position.z,"yaw":model.rotation.y,"travel_heading":movement.heading,"lean":movement.lean,"phase":movement.phase,"phase_step":movement.phase_step,"effects":emitted,"view":camera_view,"bones":skeleton.get_bone_count(),"physics_time":Time.get_ticks_msec()/1000.0,"speed_mps":actual,"source_velocity":movement.velocity,"animation_rate":player.get_playing_speed(),"tool":tool,"surface":surface,"rain":raining,"indoor":indoor,"dialogue":dialogue,"interaction":interaction,"footsteps":footprint_count,"steps":step_history,"blinks":face_blinks,"blink_index":blink_index,"door_transitions":door_transitions,"floor_error":max_floor_error}))

func jump() -> void:
	if jump_time>=0 or not body.is_on_floor() or dialogue>0 or interaction!="":return
	jump_time=0; jump_launched=false; jump_landed=false; jumps+=1

func make_jump_animation() -> void:
	var animation := Animation.new();animation.length=1.0
	var base := []
	for bone in skeleton.get_bone_count():
		base.append({"position":skeleton.get_bone_pose_position(bone),"rotation":skeleton.get_bone_pose_rotation(bone),"scale":skeleton.get_bone_pose_scale(bone)})
	var path: NodePath=player.get_node(player.root_node).get_path_to(skeleton)
	var tracks := []
	for bone in skeleton.get_bone_count():
		var channels := []
		for type in [Animation.TYPE_POSITION_3D,Animation.TYPE_ROTATION_3D,Animation.TYPE_SCALE_3D]:
			var track := animation.add_track(type)
			animation.track_set_path(track,NodePath(str(path)+":"+skeleton.get_bone_name(bone)))
			channels.append(track)
		tracks.append(channels)
	# time, upper leg pitch, knee flex, upper arm pitch, forearm flex, degrees.
	for pose in [[0,0,0,0,0],[.08,-16,32,12,-10],[.18,8,14,-22,-10],[.45,-24,52,-30,-22],[.72,0,0,-10,0],[.84,-16,32,10,-10],[1.0,0,0,0,0]]:
		for bone in skeleton.get_bone_count():
			skeleton.set_bone_pose_position(bone,base[bone].position)
			skeleton.set_bone_pose_rotation(bone,base[bone].rotation)
			skeleton.set_bone_pose_scale(bone,base[bone].scale)
		skeleton.force_update_all_bone_transforms()
		var globals := []
		for bone in skeleton.get_bone_count():globals.append(skeleton.get_bone_global_pose(bone).basis)
		for side in ["Left","Right"]:
			for part in [["UpLeg",pose[1]],["Leg",pose[1]+pose[2]],["Arm",pose[3]],["ForeArm",pose[3]+pose[4]]]:
				var bone: int=skeleton.find_bone(side+part[0])
				var target: Basis=Basis(Vector3.RIGHT,deg_to_rad(part[1]))*globals[bone]
				var parent: int=skeleton.get_bone_parent(bone)
				var relative: Basis=skeleton.get_bone_global_pose(parent).basis.inverse()*target
				skeleton.set_bone_pose_rotation(bone,relative.orthonormalized().get_rotation_quaternion())
				skeleton.force_update_all_bone_transforms()
		for bone in skeleton.get_bone_count():
			animation.position_track_insert_key(tracks[bone][0],pose[0],skeleton.get_bone_pose_position(bone))
			animation.rotation_track_insert_key(tracks[bone][1],pose[0],skeleton.get_bone_pose_rotation(bone))
			animation.scale_track_insert_key(tracks[bone][2],pose[0],skeleton.get_bone_pose_scale(bone))
	for bone in skeleton.get_bone_count():skeleton.set_bone_pose_rotation(bone,base[bone].rotation)
	player.get_animation_library("").add_animation("jump",animation)
