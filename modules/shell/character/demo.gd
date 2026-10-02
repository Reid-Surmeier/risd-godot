# gdlint: disable=max-public-methods,max-file-lines
# Keep the accepted private playtest intact; it is not the Shell public interface.
extends Node3D
## THROWAWAY #231: source-informed movement and interaction review.
# Travel gain remains a playtest calibration, not recovered game meters.
const Locomotion = preload("res://modules/shell/character/locomotion.gd")
const Sounds = preload("res://modules/shell/character/sound.gd")
var movement := Locomotion.new()
var sounds := Sounds.new()
var audio_history := []
var audio_playback: AudioStreamPlaybackPolyphonic
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
var npc_point := Vector3(-2, 0, -3)
var door_point := Vector3(0, 0, -8)
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
var jump_landing_time := -1.0
var jump_pose_time := 0.0
var jump_stage := "Ground"
var jump_heading := 0.0
var jump_moving := false
var release_palm := Vector3.ZERO
var release_last := Vector3.ZERO
var release_active := false
var jump_impact := 0.0
var jump_ground_offset := 0.0
var landing_carried_drop := 0.0
var landing_carried_age := 0.0
var last_landing_drop := 0.0
var jump_buffer := 0.0
var grip_last := Vector3.ZERO
var grip_time := 0.0
var planted_feet := {}
var procedural_base := []
var actor_shadow: MeshInstance3D
var shadow_scale := 1.0
var jumps := 0
var landings := 0
var step_history := []
var foot_planted := {"Left": true, "Right": true}
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
	var keys: Dictionary = {
		"left": [KEY_A, KEY_LEFT],
		"right": [KEY_D, KEY_RIGHT],
		"up": [KEY_W, KEY_UP],
		"down": [KEY_S, KEY_DOWN],
		"sprint": [KEY_SHIFT],
		"slow": [KEY_CTRL],
		"interact": [KEY_E],
		"jump": [KEY_SPACE]
	}
	for action in keys:
		InputMap.add_action(action)
		for key in keys[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for item in [
		["left", JOY_AXIS_LEFT_X, -1],
		["right", JOY_AXIS_LEFT_X, 1],
		["up", JOY_AXIS_LEFT_Y, -1],
		["down", JOY_AXIS_LEFT_Y, 1]
	]:
		var event := InputEventJoypadMotion.new()
		event.axis = item[1]
		event.axis_value = item[2]
		InputMap.action_add_event(item[0], event)
	for key in [JOY_BUTTON_B, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER]:
		var event := InputEventJoypadButton.new()
		event.button_index = key
		InputMap.action_add_event("sprint", event)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("8fc3b0")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.45
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -20, 0)
	sun.shadow_enabled = true
	sun.light_energy = 0.65
	add_child(sun)
	var ground := block(Vector3(0, -0.1, 0), Vector3(32, 0.2, 32), Color("50914a"), true)
	ground_material = ground.get_child(0).material_override
	path_nodes.append(block(Vector3(0, 0.002, 0), Vector3(5, 0.006, 32), Color("c8b775")))
	for i in range(-15, 16):
		path_nodes.append(block(Vector3(0, 0.008, i), Vector3(5, 0.004, 0.025), Color("ad9b62")))
	for x in [-16, 16]:
		block(Vector3(x, 0.5, 0), Vector3(0.4, 1, 32), Color("577541"), true)
	for z in [-16, 16]:
		block(Vector3(0, 0.5, z), Vector3(32, 1, 0.4), Color("577541"), true)
	for point in [Vector3(-4, 0, -4), Vector3(4, 0, 3), Vector3(-6, 0, 5), Vector3(6, 0, -6)]:
		block(point + Vector3.UP * 0.5, Vector3(0.5, 1, 0.5), Color("976647"), true)
		var tree := MeshInstance3D.new()
		var crown := SphereMesh.new()
		crown.radius = 1.0
		crown.height = 2.4
		tree.mesh = crown
		tree.position = point + Vector3.UP * 2
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
	model = load("res://modules/shell/character/walk.glb").instantiate()
	body.add_child(model)
	player = model.find_children("*", "AnimationPlayer", true, false)[0]
	skeleton = model.find_children("*", "Skeleton3D", true, false)[0]
	var own_library: AnimationLibrary = player.get_animation_library("").duplicate(true)
	player.remove_animation_library("")
	player.add_animation_library("", own_library)
	assert(skeleton.get_bone_count() == 24)
	for name in ["run", "dash", "skid", "axe", "net"]:
		var source: Node3D = load("res://modules/shell/character/" + name + ".glb").instantiate()
		var source_player: AnimationPlayer = (
			source.find_children("*", "AnimationPlayer", true, false)[0]
		)
		var animation: Animation = source_player.get_animation("walk").duplicate()
		if name in ["axe", "net"]:
			tool_rotations[name.capitalize()] = {}
			# Constant rest channels can be omitted on import; retain the actual bone rest pose.
			for side in ["Right"] if name == "net" else ["Left", "Right"]:
				for part in ["Shoulder", "Arm", "ForeArm", "Hand"]:
					var bone: int = skeleton.find_bone(side + part)
					tool_rotations[name.capitalize()][bone] = (
						skeleton
						. get_bone_rest(bone)
						. basis
						. orthonormalized()
						. get_rotation_quaternion()
					)
			for track in animation.get_track_count():
				if animation.track_get_type(track) != Animation.TYPE_ROTATION_3D:
					continue
				var bone_name := str(animation.track_get_path(track)).split(":")[-1]
				if (
					bone_name
					in (
						["RightShoulder", "RightArm", "RightForeArm", "RightHand"]
						if name == "net"
						else [
							"LeftShoulder",
							"LeftArm",
							"LeftForeArm",
							"LeftHand",
							"RightShoulder",
							"RightArm",
							"RightForeArm",
							"RightHand"
						]
					)
				):
					tool_rotations[name.capitalize()][skeleton.find_bone(bone_name)] = (
						animation.rotation_track_interpolate(track, 0)
					)
		else:
			player.get_animation_library("").add_animation(name, animation)
		source.free()
	for clip in ["idle", "walk", "run", "dash", "skid"]:
		player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	# Owner prefers a quieter idle; retain the source loop and its starting pose.
	var quieter_idle: Animation = player.get_animation("idle").duplicate()
	for track in quieter_idle.get_track_count():
		var kind: int = quieter_idle.track_get_type(track)
		if kind not in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D]:
			continue
		var reference: Variant = quieter_idle.track_get_key_value(track, 0)
		for key in quieter_idle.track_get_key_count(track):
			var value: Variant = quieter_idle.track_get_key_value(track, key)
			quieter_idle.track_set_key_value(
				track,
				key,
				(
					reference.slerp(value, .5)
					if kind == Animation.TYPE_ROTATION_3D
					else reference.lerp(value, .5)
				)
			)
	player.get_animation_library("").add_animation("idle", quieter_idle)
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play("idle")
	player.advance(0)
	make_jump_animation()
	make_tools()
	make_face()
	make_interactions()
	make_effects()
	make_actor_shadow()
	# Cache only rigid Foot vertices using the existing proof's skin calculation.
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		if mesh.skin == null:
			continue
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				for influence in 4:
					if arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + influence] < 0.9999:
						continue
					var bind: int = arrays[Mesh.ARRAY_BONES][vertex * 4 + influence]
					var bone: int = mesh.skin.get_bind_bone(bind)
					if bone < 0:
						bone = skeleton.find_bone(mesh.skin.get_bind_name(bind))
					if skeleton.get_bone_name(bone) in ["LeftFoot", "RightFoot"]:
						soles.append(
							{
								"bone": bone,
								"point":
								mesh.skin.get_bind_pose(bind) * arrays[Mesh.ARRAY_VERTEX][vertex]
							}
						)
	assert(soles.size() > 500)
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
	panel.position = Vector2(14, 14)
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
	for title in ["View", "Reset", "Interact", "Jump"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		controls.add_child(button)
		if title == "Reset":
			button.pressed.connect(reset)
		elif title == "Interact":
			button.pressed.connect(interact)
		elif title == "Jump":
			button.pressed.connect(jump)
		else:
			button.pressed.connect(func(): camera_view = (camera_view + 1) % 3)
	var options := HBoxContainer.new()
	lines.add_child(options)
	for title in ["Tool", "Surface", "Rain"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		options.add_child(button)
		if title == "Tool":
			button.pressed.connect(cycle_tool)
		elif title == "Surface":
			button.pressed.connect(cycle_surface)
		else:
			button.pressed.connect(func(): raining = not raining)
	var sound_button := Button.new()
	sound_button.text = "Sound: original house"
	sound_button.focus_mode = Control.FOCUS_NONE
	lines.add_child(sound_button)
	sound_button.pressed.connect(
		func():
			var profiles := ["House", "Stone", "Adapted"]
			sounds.captured_profile = profiles[
				(profiles.find(sounds.captured_profile) + 1) % profiles.size()
			]
			sound_button.text = ({
				"House": "Sound: original house",
				"Stone": "Sound: original stone",
				"Adapted": "Sound: adapted surfaces"
			}[sounds.captured_profile])
	)
	var tuning := HBoxContainer.new()
	lines.add_child(tuning)
	for title in ["Walk / Run", "Speed"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		tuning.add_child(button)
		if title == "Walk / Run":
			button.pressed.connect(func(): slow = not slow)
		else:
			button.pressed.connect(
				func():
					calibration = (calibration + 1) % 3
					movement.travel_gain = [3.15, 4.725, 6.867][calibration] / 4.875
			)
	message = Label.new()
	message.text = "E near the neighbour or house door"
	message.add_theme_font_size_override("font_size", 13)
	lines.add_child(message)
	fade = ColorRect.new()
	var iris := Shader.new()
	iris.code = """shader_type canvas_item;
uniform float amount=0.0;
void fragment(){
 vec2 size=1.0/SCREEN_PIXEL_SIZE;
 vec2 p=(UV-vec2(.5))*vec2(size.x/size.y,1.0);
 float radius=(1.0-amount)*length(vec2(size.x/size.y,1.0))*.51;
 COLOR=vec4(0.0,0.0,0.0,smoothstep(radius-.006,radius,length(p)));
}"""
	var iris_material := ShaderMaterial.new()
	iris_material.shader = iris
	fade.material = iris_material
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(fade)
	var touch := Node2D.new()
	layer.add_child(touch)
	var texture := Image.create(62, 62, false, Image.FORMAT_RGBA8)
	texture.fill(Color(0.12, 0.25, 0.19, 0.85))
	for item in [
		["left", "<", Vector2(0, 64)],
		["up", "^", Vector2(64, 0)],
		["down", "v", Vector2(64, 128)],
		["right", ">", Vector2(128, 64)],
		["sprint", "Sprint", Vector2(218, 128)],
		["jump", "Jump", Vector2(218, 64)]
	]:
		var button := TouchScreenButton.new()
		button.action = item[0]
		button.texture_normal = ImageTexture.create_from_image(texture)
		button.position = item[2]
		touch.add_child(button)
		var label := Label.new()
		label.text = item[1]
		label.position = Vector2(3, 15)
		label.size = Vector2(56, 32)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if item[0] not in ["sprint", "jump"]:
			label.add_theme_font_size_override("font_size", 26)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)
	get_viewport().size_changed.connect(
		func(): touch.position = Vector2(14, get_viewport().get_visible_rect().size.y - 212)
	)
	touch.position = Vector2(14, get_viewport().get_visible_rect().size.y - 212)


func reset() -> void:
	jump_buffer = 0
	landing_carried_drop = 0
	landing_carried_age = 0
	last_landing_drop = 0
	jump_time = -1
	jump_launched = false
	jump_landed = false
	jump_landing_time = -1
	jump_stage = "Ground"
	planted_feet.clear()
	foot_planted = {"Left": true, "Right": true}
	body.position = Vector3.ZERO
	body.velocity = Vector3.ZERO
	movement.reset()
	model.rotation = Vector3.ZERO
	state = "Idle"
	player.play("idle", 0.15)
	dialogue = 0
	interaction = ""
	indoor = false
	obstruction = 1
	if fade:
		fade.material.set_shader_parameter("amount", 0)
	if message:
		message.text = "E near the neighbour or house door"
	for puff in dust:
		puff.node.queue_free()
	dust.clear()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			reset()
		elif event.physical_keycode == KEY_E:
			interact()


func cycle_tool() -> void:
	tool = ["None", "Axe", "Net"][(["None", "Axe", "Net"].find(tool) + 1) % 3]


func cycle_surface() -> void:
	var choices := ["Path", "Grass", "Sand", "Water", "Snow", "Leaves", "Indoor"]
	surface = choices[(choices.find(surface) + 1) % choices.size()]


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
	for name in ["Axe", "Net"]:
		var prop := Node3D.new()
		tool_attachment.add_child(prop)
		prop.scale = Vector3.ONE * 100  # BoneAttachment resets its transform; compensate on the prop.
		tool_meshes[name] = prop
		prop.visible = false
		var shaft := CylinderMesh.new()
		shaft.top_radius = .022
		shaft.bottom_radius = .022
		shaft.height = .65
		primitive(prop, shaft, Vector3(0, .25, 0), Color("94613b"))
		if name == "Axe":
			var blade := BoxMesh.new()
			blade.size = Vector3(.28, .19, .04)
			primitive(prop, blade, Vector3(.09, .56, 0), Color("434b5b"))
		else:
			var rim := TorusMesh.new()
			rim.inner_radius = .16
			rim.outer_radius = .18
			var node := primitive(prop, rim, Vector3(0, .68, 0), Color("a9947f"))
			node.rotation_degrees.x = 90
			for offset in [-.1, 0, .1]:
				var strand := BoxMesh.new()
				strand.size = Vector3(.29, .006, .006)
				primitive(prop, strand, Vector3(0, .68 + offset, 0), Color("e4d5c0"))
		# Preserve the source tool socket on the prop, without rotating the palm.
		# Offsets: original fitted tool Hand channel relative to the shared rest Hand.
		var socket: Quaternion = {
			"Axe": Quaternion(-.248413606, .694114696, .202865733, .644469521),
			"Net": Quaternion(-.080665449, .360625453, -.301986787, .878775482)
		}[name]
		prop.quaternion = socket * Quaternion.from_euler(Vector3(0, 0, -PI / 2))
		if name == "Net":
			var bases := []
			for bone in skeleton.get_bone_count():
				var local: Basis = skeleton.get_bone_rest(bone).basis
				if tool_rotations.Net.has(bone):
					local = Basis(tool_rotations.Net[bone])
				var parent: int = skeleton.get_bone_parent(bone)
				bases.append(local if parent < 0 else bases[parent] * local)
			var hand_basis: Basis = bases[skeleton.find_bone("RightHand")]
			var axis: Vector3 = (hand_basis * prop.basis).y.normalized()
			var outward := (axis + Vector3(-.9, 0, 0)).normalized()
			prop.basis = (
				hand_basis.inverse() * Basis(Quaternion(axis, outward)) * hand_basis * prop.basis
			)


func make_face() -> void:
	random.seed = 231
	var shader := Shader.new()
	shader.code = """shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform sampler2D atlas : source_color, filter_linear_mipmap;
uniform sampler2D hand_atlas : source_color, filter_linear;
uniform float blink=0.0;
void fragment(){
 ALBEDO=COLOR.r>.5 ? texture(hand_atlas,UV).rgb : texture(atlas,UV).rgb;
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
   vec3 lid=mix(textureLod(atlas,skin_top[i],0.0).rgb,
    textureLod(atlas,skin_bottom[i],0.0).rgb,clamp((d.y+1.0)*.5,0.0,1.0));
   vec2 iris_uv=centers[i]+vec2(d.x,clamp(d.y/opening,-1.0,1.0))*radius;
   float exposed=1.0-smoothstep(opening-.045,opening+.045,abs(d.y));
   vec3 closing=mix(lid,textureLod(atlas,iris_uv,0.0).rgb,exposed);
   float line=(1.0-smoothstep(.025,.075,abs(d.y-.08*d.x*d.x)))*
    (1.0-smoothstep(.65,.85,abs(d.x)))*smoothstep(.8,1.0,blink);
   closing=mix(closing,vec3(.15,.09,.07),line);
   ALBEDO=mix(ALBEDO,closing,(1.0-smoothstep(.97,1.0,length(d)))*smoothstep(0.0,.125,blink));
  }
 }
}"""
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		# Immutable skin assignment gates the face effect; UV islands alone overlap clothes.
		if mesh.skin == null:
			continue
		var face_mesh := ArrayMesh.new()
		for index in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(index)
			var colors := PackedColorArray()
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				var head_weight := 0.0
				var hand_weight := 0.0
				for influence in 4:
					var bind: int = arrays[Mesh.ARRAY_BONES][vertex * 4 + influence]
					var bone: int = mesh.skin.get_bind_bone(bind)
					if bone < 0:
						bone = skeleton.find_bone(mesh.skin.get_bind_name(bind))
					if skeleton.get_bone_name(bone) == "Head":
						head_weight += arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + influence]
					if skeleton.get_bone_name(bone).ends_with("Hand"):
						hand_weight += arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + influence]
				colors.append(
					Color(1 if hand_weight > .5 else 0, 0, 0, 1 if head_weight > .9 else 0)
				)
			arrays[Mesh.ARRAY_COLOR] = colors
			face_mesh.add_surface_from_arrays(mesh.mesh.surface_get_primitive_type(index), arrays)
			face_mesh.surface_set_material(index, mesh.get_active_material(index))
		mesh.mesh = face_mesh
		for index in mesh.mesh.get_surface_count():
			var source: Material = mesh.get_active_material(index)
			if source is StandardMaterial3D and source.albedo_texture:
				face_material = ShaderMaterial.new()
				face_material.shader = shader
				face_material.set_shader_parameter("atlas", source.albedo_texture)
				face_material.set_shader_parameter(
					"hand_atlas", load("res://modules/shell/character/hand-atlas.png")
				)
				mesh.set_surface_override_material(index, face_material)


func blink_amount() -> float:
	if blink_index < 0:
		return 0.0
	var age := 15.0 - blink_index + blink_updates
	return smoothstep(0.0, 1.0, clampf(minf((age - 1) / 5.0, (15 - age) / 5.0), 0, 1))


func make_interactions() -> void:
	block(door_point + Vector3(0, 1.7, -.5), Vector3(4, 3.4, 1), Color("bd9565"), true)
	block(door_point + Vector3(0, .85, .05), Vector3(1.25, 1.7, .04), Color("665642"))
	block(Vector3(40, -.1, 0), Vector3(10, .2, 10), Color("a48665"), true)
	for x in [35, 45]:
		block(Vector3(x, 1.5, 0), Vector3(.2, 3, 10), Color("e3cda8"), true)
	for z in [-5, 5]:
		block(Vector3(40, 1.5, z), Vector3(10, 3, .2), Color("e3cda8"), true)
	block(Vector3(40, .7, -4.9), Vector3(1.3, 1.4, .03), Color("665642"))
	var npc := Node3D.new()
	npc.position = npc_point
	add_child(npc)
	var sphere := SphereMesh.new()
	sphere.radius = .3
	sphere.height = .6
	primitive(npc, sphere, Vector3.UP * 1.25, Color("d7ae72"))
	var torso := CapsuleMesh.new()
	torso.radius = .25
	torso.height = .8
	primitive(npc, torso, Vector3.UP * .6, Color("657ab4"))


func interact() -> void:
	if interaction in ["Door", "DoorApproach"]:
		return
	if dialogue > 0:
		dialogue += 1
		if dialogue == 2:
			message.text = "A gift for you! · E to continue"
			interaction = "Receive"
			interaction_timer = .7
		elif dialogue >= 3:
			dialogue = 0
			interaction = ""
			message.text = "See you around!"
		return
	if (
		indoor and body.position.distance_to(Vector3(40, 0, -4)) < 2.5
		or not indoor and body.position.distance_to(door_point) < 2.5
	):
		interaction = "DoorApproach"
		interaction_timer = 0
		movement.velocity = 0
	elif not indoor and body.position.distance_to(npc_point) < 2.5:
		dialogue = 1
		interaction = "Talk"
		movement.velocity = 0
		movement.heading = atan2(npc_point.x - body.position.x, npc_point.z - body.position.z)
		movement.shape_heading = movement.heading
		message.text = "Hello, neighbour! · E to continue"
	else:
		message.text = "Move closer to the neighbour or door"


func make_effects() -> void:
	foot_audio = AudioStreamPlayer.new()
	add_child(foot_audio)
	var polyphonic := AudioStreamPolyphonic.new()
	polyphonic.polyphony = 16
	foot_audio.stream = polyphonic
	foot_audio.play()
	audio_playback = foot_audio.get_stream_playback()
	foot_audio.tree_entered.connect(_resume_audio)
	# Original masks are unavailable: four authored I4 cloud silhouettes, source timing.
	var masks := []
	for frame in 4:
		var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		for y in 16:
			for x in 16:
				var point := Vector2(x - 7.5, y - 8.5)
				var distance := INF
				for lobe in [
					[Vector2(-3, -1), 3.1],
					[Vector2(0, -3), 3.7],
					[Vector2(3, -1), 3.0],
					[Vector2(0, 1.7), 3.6]
				]:
					var expansion: float = 1 + frame * .10
					distance = minf(
						distance,
						point.distance_to(lobe[0] * expansion) - lobe[1] * (1 - frame * .07)
					)
				var alpha := clampf(.75 - distance, 0, 1)
				if frame >= 2:
					alpha *= smoothstep(1.0, 3.5, point.length())
				image.set_pixel(x, y, Color(1, 1, 1, roundf(alpha * 15) / 15))
		masks.append(image)
	for counter in 9:
		var pairs := [[0, 0], [0, 1], [1, 1], [1, 2], [2, 2], [2, 3], [3, 3], [3, 3], [3, 3]]
		var pair: Array = pairs[counter]
		var fraction: float = [0, 128, 255, 128, 0, 128, 255, 128, 0][counter] / 255.0
		var image: Image = masks[pair[0]].duplicate()
		for y in 16:
			for x in 16:
				image.set_pixel(
					x,
					y,
					masks[pair[0]].get_pixel(x, y).lerp(masks[pair[1]].get_pixel(x, y), fraction)
				)
		dust_textures.append(ImageTexture.create_from_image(image))
	# Separate authored payloads for splash droplets, leaf chips, snow and sand grains.
	for ground in ["Water", "Leaves", "Snow", "Sand"]:
		var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		for y in 16:
			for x in 16:
				var point := Vector2(x - 7.5, y - 7.5) / 7.5
				var radius := (
					Vector2(point.x * 1.8, point.y).length()
					if ground in ["Water", "Leaves"]
					else point.length()
				)
				var alpha := 1 - smoothstep(.65, .95, radius)
				if ground == "Leaves":
					alpha *= 1 - smoothstep(.08, .22, absf(point.x + point.y * .35)) * .35
				if ground == "Snow":
					alpha *= 1 - smoothstep(.25, .4, minf(absf(point.x), absf(point.y)))
				if ground == "Sand":
					alpha = 1.0 if absf(point.x) < .45 and absf(point.y) < .45 else 0.0
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
		surface_textures[ground] = ImageTexture.create_from_image(image)


func effect_sound(bank: String, source_id: int, gain := 1.0) -> void:
	var variant := jumps % 4 if bank in ["Jump", "Landing"] else 0
	var captured: bool = bank == "DoorShut" and sounds.captured_profile != "Adapted"
	var stream: AudioStream = (
		sounds.recorded_close if captured else sounds.streams[sounds.key(bank, false, variant)]
	)
	var playback_id := audio_playback.play_stream(
		stream,
		.024 if captured else 0,
		-14 + linear_to_db(maxf(.01, gain)) + (14 + sounds.CAPTURED_MIX_DB if captured else 0),
		1.0
	)
	audio_history.append(
		{
			"bank": bank,
			"id": -1 if captured else source_id,
			"requested_id": source_id,
			"source": "house_door_close.wav" if captured else "authored",
			"start_offset": .024 if captured else 0,
			"browser_time":
			JavaScriptBridge.eval("performance.now() / 1000") if OS.has_feature("web") else null,
			"pitch": 1.0,
			"gain": gain,
			"variant": variant,
			"jump_time": jump_time,
			"stage": jump_stage,
			"surface": surface,
			"time": Time.get_ticks_usec() / 1000000.0,
			"playback_id": playback_id
		}
	)
	if audio_history.size() > 64:
		audio_history.pop_front()


func footstep(foot: String) -> void:
	if (
		(jump_time >= 0 and (not jump_landed or jump_landing_time < 4.0 / 60))
		or not body.is_on_floor()
		or state == "Idle"
		or dialogue > 0
		or interaction == "Door"
		or Vector2(body.velocity.x, body.velocity.z).length() < .08
	):
		return
	skeleton.force_update_all_bone_transforms()
	var ankle := (
		skeleton.global_transform
		* skeleton.get_bone_global_pose(skeleton.find_bone(foot + "Foot")).origin
	)
	footprint_count += 1
	var ground := "Indoor" if indoor else ("Water" if raining and surface != "Indoor" else surface)
	if state != "Skid":
		var cue := sounds.step(ground, state, foot, indoor or ground == "Indoor")
		cue.playback_id = audio_playback.play_stream(
			cue.stream,
			cue.get("start_offset", 0),
			-14 + linear_to_db(cue.gain) + cue.get("gain_offset_db", 0),
			cue.pitch
		)
		cue.time = Time.get_ticks_usec() / 1000000.0
		if OS.has_feature("web"):
			# Stamp dispatch directly on the browser clock; a later bridge snapshot is not this call.
			cue.browser_time = JavaScriptBridge.eval("performance.now() / 1000")
		cue.foot = foot
		cue.phase = movement.phase
		cue.stage = jump_stage
		cue.on_floor = body.is_on_floor()
		cue.erase("stream")
		audio_history.append(cue)
		if audio_history.size() > 64:
			audio_history.pop_front()
	step_history.append(
		{
			"foot": foot,
			"surface": ground,
			"position": [ankle.x, body.position.y, ankle.z],
			"phase": movement.phase
		}
	)
	if step_history.size() > 24:
		step_history.pop_front()
	if (
		ground == "Indoor"
		or (state != "Dash" and state != "Skid" and ground in ["Grass", "Path", "Sand"])
	):
		return
	var colors := {
		"Path": Color.WHITE,
		"Grass": Color.WHITE,
		"Sand": Color("d9c698"),
		"Water": Color("b9dbea"),
		"Snow": Color.WHITE,
		"Leaves": Color("588936")
	}
	for i in 1 if ground in ["Grass", "Path"] else 3:
		var puff := MeshInstance3D.new()
		var dry := ground in ["Grass", "Path"]
		var quad := QuadMesh.new()
		quad.size = (
			Vector2(.75, .75)
			if dry
			else {
				"Water": Vector2(.09, .16),
				"Leaves": Vector2(.13, .20),
				"Snow": Vector2(.10, .10),
				"Sand": Vector2(.065, .065)
			}[ground]
		)
		puff.mesh = quad
		var mat := material(colors.get(ground, Color.WHITE))
		mat.albedo_texture = dust_textures[0] if dry else surface_textures[ground]
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		puff.material_override = mat
		add_child(puff)
		var origin := Vector3(ankle.x, body.position.y + .04, ankle.z)
		var backward := -Vector3(sin(movement.heading), 0, cos(movement.heading))
		var side := Vector3(backward.z, 0, -backward.x)
		var velocity := (
			Vector3.UP + backward * 2
			if dry
			else (Vector3.UP * (1.5 + i * .2) + backward * .3 + side * (i - 1) * .7) / 60
		)
		dust.append(
			{
				"node": puff,
				"age": 0.0,
				"origin": origin,
				"velocity": velocity,
				"acceleration":
				Vector3.DOWN * .05 - backward * .075 if dry else Vector3.DOWN * 5 / 3600,
				"source_unit": movement.travel_gain / 30.0 if dry else 1.0,
				"dry": dry,
				"lifetime": .3 if dry else .4
			}
		)
	emitted += 1


func _physics_process(delta: float) -> void:
	if player == null:
		return
	var displayed := []
	for bone in skeleton.get_bone_count():
		displayed.append(
			[
				skeleton.get_bone_pose_position(bone),
				skeleton.get_bone_pose_rotation(bone),
				skeleton.get_bone_pose_scale(bone)
			]
		)
	jump_buffer = maxf(0, jump_buffer - delta)
	if (
		jump_buffer > 0
		and jump_landed
		and jump_landing_time >= .10 - .000001
		and body.is_on_floor()
	):
		jump_time = -1
		jump_buffer = 0
		jump()
	if Input.is_action_just_pressed("jump"):
		jump()
	if jump_time >= 0:
		jump_time += delta
		if (jump_moving or jump_time >= .05 - .000001) and not jump_launched:
			body.velocity.y = 3.6
			jump_launched = true
			jump_stage = "Ascend"
			effect_sound("Jump", -1, .7)
		if jump_landed:
			jump_landing_time += delta
			if jump_landing_time >= .23:
				jump_time = -1
				jump_stage = "Ground"
				planted_feet.clear()
	ground_material.albedo_color = {
		"Path": Color("50914a"),
		"Grass": Color("50914a"),
		"Sand": Color("bdae82"),
		"Water": Color("397d99"),
		"Snow": Color("dedfdf"),
		"Leaves": Color("796936"),
		"Indoor": Color("a48665")
	}[surface]
	for node in path_nodes:
		node.visible = surface == "Path"
	var input := Input.get_vector("left", "right", "up", "down", 0)
	if input.length() <= 9.899495 / 61:
		input = Vector2.ZERO
	if slow or Input.is_action_pressed("slow"):
		input *= .45
	var yaw: float = [0.0, PI / 2, 0.0][camera_view]
	input = input.rotated(-yaw)
	if interaction == "DoorApproach":
		var approach := (Vector3(40, 0, -4.2) if indoor else Vector3(0, 0, -7.2)) - body.position
		if Vector2(approach.x, approach.z).length() < .08:
			interaction = "Door"
			interaction_timer = 0
			door_entering = not indoor
			movement.velocity = 0
			input = Vector2.ZERO
		else:
			input = Vector2(approach.x, approach.z).normalized() * .45
	if dialogue > 0 or interaction == "Door":
		input = Vector2.ZERO
	var before := body.position
	var commanded: Vector3 = movement.step(
		input, Input.is_action_pressed("sprint"), delta, obstruction
	)
	if jump_time >= 0 and commanded.length() > .2:
		jump_moving = true
	body.velocity = Vector3(commanded.x, body.velocity.y - 9.8 * delta, commanded.z)
	var impact_velocity := absf(body.velocity.y)
	var swept_contact := false
	var swept_floor := -INF
	if jump_time >= 0 and jump_launched and not jump_landed and body.velocity.y < 0:
		var next_root: Vector3 = body.global_position + body.velocity * delta
		var sweep := PhysicsRayQueryParameters3D.create(
			Vector3(next_root.x, body.global_position.y + .25, next_root.z),
			next_root - Vector3.UP * .01
		)
		sweep.exclude = [body.get_rid()]
		var hit := get_world_3d().direct_space_state.intersect_ray(sweep)
		if (
			not hit.is_empty()
			and hit.normal.dot(Vector3.UP) >= cos(body.floor_max_angle)
			and next_root.y < hit.position.y
		):
			swept_contact = true
			swept_floor = hit.position.y
			body.velocity.y = maxf(
				body.velocity.y, (hit.position.y - body.global_position.y) / delta
			)
	body.move_and_slide()
	if swept_contact and not body.is_on_floor():
		body.apply_floor_snap()
		if body.is_on_floor():
			body.velocity.y = 0
			body.global_position.y = maxf(body.global_position.y, swept_floor)
	if jump_time >= 0 and jump_launched and not jump_landed and body.is_on_floor():
		jump_landed = true
		jump_landing_time = 0
		landings += 1
		jump_stage = "Land"
		jump_heading = movement.shape_heading
		jump_moving = Vector2(body.velocity.x, body.velocity.z).length() > .2 or input.length() > .1
		jump_impact = clampf(impact_velocity / 3.6, .25, 1.0)
		capture_planted_feet()
		# Authored hop cue; the original-game sound ID is unknown.
		effect_sound("Landing", -1, clampf(jump_impact, .35, 1.0))
	if jump_time >= 0:
		jump_stage = (
			"Land"
			if jump_landed
			else (
				"Anticipate"
				if not jump_launched
				else ("Ascend" if body.velocity.y > 0 else "Descend")
			)
		)
		jump_pose_time = (
			jump_landing_time
			if jump_landed
			else (
				minf(jump_time / .05 * .11, .11)
				if not jump_launched
				else .60 * clampf(1 - body.velocity.y / 3.6, 0, 2) / 2
			)
		)
	var actual := Vector2(body.position.x - before.x, body.position.z - before.z).length() / delta
	obstruction = clampf(actual / maxf(commanded.length(), .001), 0, 1)
	model.rotation.y = movement.shape_heading
	model.rotation.x = move_toward(
		model.rotation.x, 0 if jump_time >= 0 else movement.lean, deg_to_rad(120) * delta
	)
	var previous_phase := movement.phase - movement.phase_step * delta * 60 / 16
	var target_state: String = movement.gait
	if commanded.length() > .1 and actual < .02 and not movement.skidding:
		target_state = "Idle"
	if dialogue > 0 or interaction == "Door":
		target_state = "Idle"
	var clip: String = {
		"Idle": "idle", "Walk": "walk", "Run": "run", "Dash": "dash", "Skid": "skid"
	}[target_state]
	if jump_time >= 0 and not (jump_landed and jump_moving):
		target_state = "Jump"
		clip = "landing" if jump_landed else ("flight" if jump_launched else "jump")
	var entered_skid := target_state == "Skid" and state != "Skid"
	# Procedural contact IK never becomes the next animation's input.
	for bone in procedural_base.size():
		skeleton.set_bone_pose_position(bone, procedural_base[bone][0])
		skeleton.set_bone_pose_rotation(bone, procedural_base[bone][1])
	# Restore the unmodified base before applying another overlay, including omitted tracks.
	for bone in animated_arm_pose:
		skeleton.set_bone_pose_rotation(bone, animated_arm_pose[bone])
	if target_state != state or player.current_animation != clip:
		if state == "Jump" and target_state != "Jump" and tool == "Axe":
			last_overlay = "None"
		if jump_landed and jump_moving:
			landing_carried_drop = last_landing_drop
			landing_carried_age = 0
		state = target_state
		play_from_displayed(clip, .18 if state == "Jump" else .167, displayed)
		if state not in ["Idle", "Jump"]:
			player.seek(fposmod(previous_phase, 1) * player.get_animation(clip).length, true)
	player.speed_scale = (
		1
		if state in ["Idle", "Jump", "Skid"]
		else player.get_animation(clip).length * movement.phase_step * 60 / 16
	)
	if state == "Jump" and not jump_landed:
		player.seek(maxf(0, jump_pose_time - delta), false)
		player.advance(delta)
	else:
		player.advance(delta)
	# Jump owns its arm drive; the prop stays attached and the holding pose returns on recovery.
	var overlay := tool if state == "Jump" else ("Net" if interaction == "Receive" else tool)
	if overlay != last_overlay:
		overlay_from = previous_arm_pose.duplicate()
		overlay_time = 0
		last_overlay = overlay
		grip_time = 0
		grip_last = skeleton.get_bone_global_pose(skeleton.find_bone("LeftHand")) * Vector3(0, 7, 0)
	overlay_time = minf(.30, overlay_time + delta)
	for bone in tool_rotations.Axe:
		var animated := skeleton.get_bone_pose_rotation(bone)
		animated_arm_pose[bone] = animated
		var desired: Quaternion = (
			tool_rotations[overlay].get(bone, animated) if overlay != "None" else animated
		)
		if (
			(overlay == "Axe" or state == "Jump")
			and skeleton.get_bone_name(bone).begins_with("Left")
		):
			desired = animated
		var start: Quaternion = overlay_from.get(bone, animated)
		skeleton.set_bone_pose_rotation(bone, start.slerp(desired, overlay_time / .30))
		previous_arm_pose[bone] = skeleton.get_bone_pose_rotation(bone)
	for name in tool_meshes:
		tool_meshes[name].visible = name == tool
	skeleton.force_update_all_bone_transforms()
	if tool == "Axe" and jump_time >= 0 and not jump_landed and release_active:
		var left: int = skeleton.find_bone("LeftHand")
		var alpha := smoothstep(0.0, .30, jump_time)
		var destination: Vector3 = skeleton.get_bone_global_pose(left) * Vector3(0, 7, 0)
		var goal := release_palm.lerp(destination, alpha)
		goal.z += 22 * sin(PI * alpha)
		goal = release_last.move_toward(goal, 3)
		release_last = goal
		if alpha >= 1 and goal.distance_to(destination) < .5:
			release_active = false
		for iteration in 4:
			var current: Transform3D = skeleton.get_bone_global_pose(left)
			var target := current
			target.origin = goal - current.basis * Vector3(0, 7, 0)
			var elbow: Vector3 = (
				skeleton.get_bone_global_pose(skeleton.find_bone("LeftForeArm")).origin
			)
			var shoulder: Vector3 = (
				skeleton.get_bone_global_pose(skeleton.find_bone("LeftArm")).origin
			)
			var pole := (elbow - shoulder).normalized().lerp(Vector3(.8, .2, 1).normalized(), alpha)
			solve_chain("LeftArm", "LeftForeArm", "LeftHand", target, pole, true)
		for part in ["Arm", "ForeArm", "Hand"]:
			var bone: int = skeleton.find_bone("Left" + part)
			previous_arm_pose[bone] = skeleton.get_bone_pose_rotation(bone)
	if overlay == "Axe" and state != "Jump":
		var left: int = skeleton.find_bone("LeftHand")
		var current: Transform3D = skeleton.get_bone_global_pose(left)
		var grip: Vector3 = (
			(
				skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))
				* tool_meshes.Axe.transform
			)
			* Vector3(0, -.02, 0)
		)
		grip_time = minf(.50, grip_time + delta)
		var alpha := grip_time / .50
		var palm: Vector3 = current * Vector3(0, 7, 0)
		var safe := palm.lerp(grip, .5)
		safe.z = maxf(safe.z, 60)
		safe.x = maxf(safe.x, 42)
		var goal := (
			palm * (1 - alpha) * (1 - alpha) + safe * 2 * alpha * (1 - alpha) + grip * alpha * alpha
		)
		goal = grip_last.move_toward(goal, 3)
		grip_last = goal
		# Solve the actual palm socket, preserving the anatomical wrist after each solve.
		for iteration in 4:
			current = skeleton.get_bone_global_pose(left)
			var target: Transform3D = current
			target.origin = goal - current.basis * Vector3(0, 7, 0)
			var elbow: Vector3 = (
				skeleton.get_bone_global_pose(skeleton.find_bone("LeftForeArm")).origin
			)
			var shoulder: Vector3 = (
				skeleton.get_bone_global_pose(skeleton.find_bone("LeftArm")).origin
			)
			var pole := (elbow - shoulder).normalized().lerp(Vector3(.8, .2, 2).normalized(), alpha)
			solve_chain("LeftArm", "LeftForeArm", "LeftHand", target, pole, true)
		previous_arm_pose[left] = skeleton.get_bone_pose_rotation(left)
		previous_arm_pose[skeleton.find_bone("LeftForeArm")] = skeleton.get_bone_pose_rotation(
			skeleton.find_bone("LeftForeArm")
		)
		previous_arm_pose[skeleton.find_bone("LeftArm")] = skeleton.get_bone_pose_rotation(
			skeleton.find_bone("LeftArm")
		)
	procedural_base.clear()
	for bone in skeleton.get_bone_count():
		procedural_base.append(
			[skeleton.get_bone_pose_position(bone), skeleton.get_bone_pose_rotation(bone)]
		)
	model.position.y = (
		jump_ground_offset * (1 - smoothstep(.05, .17, jump_time))
		if jump_time >= 0 and jump_launched and not jump_landed
		else 0.0
	)
	landing_carried_age += delta
	last_landing_drop = 0
	if jump_time >= 0 and (not jump_launched or jump_landed):
		var drop: float = (
			.032 * sin(PI * clampf(jump_time / .05, 0, 1))
			if not jump_launched
			else (.065 if jump_moving else .085) * jump_impact * landing_envelope(jump_landing_time)
		)
		if jump_landed and jump_moving:
			drop -= landing_carried_drop * (1 - clampf(landing_carried_age / .167, 0, 1))
		# The native blend already carries compression; cancel that share and remember the total.
		last_landing_drop = (
			drop
			+ (
				landing_carried_drop * (1 - clampf(landing_carried_age / .167, 0, 1))
				if jump_landed and jump_moving
				else 0.0
			)
		)
		var hip: int = skeleton.find_bone("Hips")
		var pelvis: Transform3D = skeleton.get_bone_global_pose(hip)
		pelvis.origin.y -= drop / skeleton.global_basis.get_scale().y
		set_jump_global(hip, pelvis)
		if not jump_moving:
			var reach_lowering := 0.0
			for side in ["Left", "Right"]:
				var u: Vector3 = (
					skeleton.get_bone_global_pose(skeleton.find_bone(side + "UpLeg")).origin
				)
				var k: Vector3 = (
					skeleton.get_bone_global_pose(skeleton.find_bone(side + "Leg")).origin
				)
				var a: Vector3 = (
					skeleton.get_bone_global_pose(skeleton.find_bone(side + "Foot")).origin
				)
				var target: Vector3 = (
					(skeleton.global_transform.affine_inverse() * planted_feet[side]).origin
				)
				var distance := (u.distance_to(k) + k.distance_to(a)) * .97
				var horizontal := Vector2(u.x - target.x, u.z - target.z).length()
				reach_lowering = maxf(
					reach_lowering,
					u.y - target.y - sqrt(maxf(0, distance * distance - horizontal * horizontal))
				)
			reach_lowering = minf(
				reach_lowering, maxf(0, .10 - drop) / skeleton.global_basis.get_scale().y
			)
			last_landing_drop += reach_lowering * skeleton.global_basis.get_scale().y
			pelvis = skeleton.get_bone_global_pose(hip)
			pelvis.origin.y -= reach_lowering
			set_jump_global(hip, pelvis)
		for side in ["Left", "Right"]:
			var foot: int = skeleton.find_bone(side + "Foot")
			var target: Transform3D = (
				skeleton.global_transform * skeleton.get_bone_global_pose(foot)
			)
			if not jump_moving:
				target = planted_feet[side]
			else:
				# Moving landings retain the gait's foot paths instead of locking both feet behind the body.
				var low_sole := INF
				for sole in soles:
					if sole.bone == foot:
						low_sole = minf(low_sole, (target * sole.point).y)
				target.origin.y += maxf(0, body.position.y - low_sole)
			solve_chain(
				side + "UpLeg",
				side + "Leg",
				side + "Foot",
				skeleton.global_transform.affine_inverse() * target,
				Vector3.BACK
			)
	update_actor_shadow()
	# Correct the complete visual root after lean/blends; this is floor clearance, not stance IK.
	var low := INF
	var foot_heights := {"Left": INF, "Right": INF}
	var root_height := model.position.y
	for sole in soles:
		var height: float = (
			(skeleton.global_transform * (skeleton.get_bone_global_pose(sole.bone) * sole.point)).y
			- body.position.y
		)
		low = minf(low, height)
		var side := "Left" if skeleton.get_bone_name(sole.bone) == "LeftFoot" else "Right"
		foot_heights[side] = minf(foot_heights[side], height)
	# Sole normalization is only a grounded contact correction; never cancel an airborne tuck.
	if state != "Jump" or not jump_launched or jump_landed:
		model.position.y = -low
	elif body.velocity.y < 0:
		# Only prevent soles crossing the actual floor; retain the authored airborne pose.
		var floor_ray := PhysicsRayQueryParameters3D.create(
			body.global_position + Vector3.UP * .25, body.global_position - Vector3.UP
		)
		floor_ray.exclude = [body.get_rid()]
		var floor_hit := get_world_3d().direct_space_state.intersect_ray(floor_ray)
		if not floor_hit.is_empty():
			model.position.y += maxf(0, floor_hit.position.y - body.position.y - low)
	if body.is_on_floor():
		max_floor_error = maxf(max_floor_error, absf(low + model.position.y))
	tool_attachment.on_skeleton_update()
	if entered_skid and actual > .08:
		effect_sound("Skid", 0x4129)
		footstep("Right")
	if state in ["Walk", "Run", "Dash"] and actual > .08 and body.is_on_floor():
		# Hysteresis ignores toe rocking; cue only after this sole lifts and returns to the floor.
		for side in ["Left", "Right"]:
			var height: float = foot_heights[side] + model.position.y - root_height
			# The outgoing pose persists through gait blends; ignore its toe roll in every gait.
			if height > .05 * model.scale.y:
				foot_planted[side] = false
			elif not foot_planted[side] and height <= .01 * model.scale.y:
				foot_planted[side] = true
				footstep(side)
	else:
		foot_planted = {"Left": true, "Right": true}
	for i in range(dust.size() - 1, -1, -1):
		var puff: Dictionary = dust[i]
		puff.age += delta
		if puff.age >= puff.lifetime:
			puff.node.queue_free()
			dust.remove_at(i)
		else:
			var ticks := floorf(puff.age * 60 + .00001)
			puff.node.position = (
				puff.origin
				+ (
					(puff.velocity * ticks + puff.acceleration * ticks * (ticks + 1) / 2)
					* puff.source_unit
				)
			)
			if puff.dry:
				var counter := mini(8, int(ticks) / 2)
				puff.node.material_override.albedo_texture = dust_textures[counter]
				puff.node.material_override.albedo_color.a = (
					[255, 200, 200, 200, 200, 200, 200, 200, 0][counter] / 255.0
				)
			else:
				puff.node.material_override.albedo_color.a = 1 - puff.age / puff.lifetime
	blink_clock -= delta
	if blink_index < 0 and blink_clock <= 0:
		blink_index = 15
		blink_updates = 0
		blink_repeat = random.randi_range(0, 3)
		face_blinks += 1
	if blink_index >= 0:
		blink_updates += delta * 60
		while blink_updates >= 1 and blink_index >= 0:
			blink_updates -= 1
			blink_index -= 1
		if blink_index < 0:
			if blink_repeat > 0:
				blink_repeat -= 1
				blink_index = 15
			else:
				blink_clock = random.randf_range(1, 2)
	if face_material:
		face_material.set_shader_parameter("blink", blink_amount())
	if interaction == "Receive":
		interaction_timer -= delta
		if interaction_timer <= 0:
			interaction = "Talk"
	elif interaction == "Door":
		var prior := interaction_timer
		interaction_timer += delta
		var cue_frames := [2, 8, 33, 40] if door_entering else [10, 14, 35, 50]
		var last_frame := 40.0 if door_entering else 50.0
		for i in 4:
			var at: float = cue_frames[i] / last_frame * .7
			if prior < at and interaction_timer >= at:
				effect_sound(["DoorLatch", "DoorCreak", "DoorShut", "DoorLatch"][i], 6 + i)
		fade.material.set_shader_parameter(
			"amount", clampf(1 - absf(interaction_timer - .35) / .35, 0, 1)
		)
		if interaction_timer >= .35 and interaction_timer - delta < .35:
			indoor = not indoor
			body.position = Vector3(40, 0, -2.5) if indoor else Vector3(0, 0, -6)
			body.velocity = Vector3.ZERO
			movement.reset()
			door_transitions += 1
		if interaction_timer >= .7:
			interaction = ""
			fade.material.set_shader_parameter("amount", 0)
	var target := Vector3(body.position.x, .85, body.position.z)
	var angle := deg_to_rad(25 if camera_view == 2 else 45)
	camera.position = (
		target
		+ (
			Vector3(sin(yaw) * cos(angle), sin(angle), cos(yaw) * cos(angle))
			* (19 if dialogue > 0 else (22 if camera_view == 0 else 17))
		)
	)
	camera.look_at(target)
	status.text = (
		state
		+ " · "
		+ ("Indoor" if indoor else surface)
		+ " · "
		+ tool
		+ " · speed ×"
		+ str([1, 1.5, 2.18][calibration])
	)
	bridge_time += delta
	if OS.has_feature("web") and bridge_time > .1:
		bridge_time = 0
		JavaScriptBridge.eval(
			(
				"window.characterPlaytest="
				+ JSON.stringify(
					{
						"state": state,
						"y": body.position.y,
						"jump_time": jump_time,
						"jump_stage": jump_stage,
						"jumps": jumps,
						"landings": landings,
						"x": body.position.x,
						"z": body.position.z,
						"yaw": model.rotation.y,
						"travel_heading": movement.heading,
						"lean": movement.lean,
						"phase": movement.phase,
						"phase_step": movement.phase_step,
						"effects": emitted,
						"view": camera_view,
						"bones": skeleton.get_bone_count(),
						"physics_time": Time.get_ticks_msec() / 1000.0,
						"speed_mps": actual,
						"source_velocity": movement.velocity,
						"animation_rate": player.get_playing_speed(),
						"tool": tool,
						"surface": surface,
						"rain": raining,
						"indoor": indoor,
						"dialogue": dialogue,
						"interaction": interaction,
						"footsteps": footprint_count,
						"steps": step_history,
						"blinks": face_blinks,
						"blink_index": blink_index,
						"door_transitions": door_transitions,
						"floor_error": max_floor_error,
						"audio_profile":
						(
							"original-" + sounds.captured_profile.to_lower() + "-capture"
							if sounds.captured_profile != "Adapted"
							else "authored-surface-adaptation"
						),
						"audio_events": audio_history.slice(-8)
					}
				)
			)
		)


func jump() -> void:
	if jump_time >= 0:
		if jump_landed:
			jump_buffer = .12
		return
	if not body.is_on_floor() or dialogue > 0 or interaction != "":
		return
	landing_carried_drop = 0
	landing_carried_age = 0
	last_landing_drop = 0
	jump_time = 0
	jump_launched = false
	jump_landed = false
	jump_landing_time = -1
	jumps += 1
	jump_heading = movement.shape_heading
	jump_ground_offset = model.position.y
	release_palm = skeleton.get_bone_global_pose(skeleton.find_bone("LeftHand")) * Vector3(0, 7, 0)
	release_last = release_palm
	release_active = tool == "Axe"
	jump_moving = Vector2(body.velocity.x, body.velocity.z).length() > .2
	capture_planted_feet()


func play_from_displayed(clip: String, duration: float, poses: Array) -> void:
	# A constant native clip captures the visible blend, including interrupted transitions.
	# AnimationPlayer otherwise blends from the former clip, losing a partly blended pose.
	var snapshot: Animation = player.get_animation("jump").duplicate()
	snapshot.length = duration + .1
	for track in snapshot.get_track_count():
		while snapshot.track_get_key_count(track) > 0:
			snapshot.track_remove_key(track, 0)
		var bone: int = skeleton.find_bone(str(snapshot.track_get_path(track)).split(":")[-1])
		snapshot.track_insert_key(track, 0, poses[bone][track % 3])
	player.stop(true)
	var library := player.get_animation_library("")
	if library.has_animation("__pose"):
		library.remove_animation("__pose")
	library.add_animation("__pose", snapshot)
	player.play("__pose")
	player.advance(0)
	player.play(clip, duration)


func landing_envelope(time: float) -> float:
	return smoothstep(0.0, .067, time) * (1 - smoothstep(.067, .23, time))


func capture_planted_feet() -> void:
	planted_feet.clear()
	for side in ["Left", "Right"]:
		var foot: int = skeleton.find_bone(side + "Foot")
		var target: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(foot)
		# Use the rest shoe orientation on the ground, not an airborne toe angle.
		target.basis = (skeleton.global_transform * skeleton.get_bone_global_rest(foot)).basis
		var lowest := INF
		for sole in soles:
			if sole.bone == foot:
				lowest = minf(lowest, (target * sole.point).y)
		target.origin.y += body.position.y - lowest
		planted_feet[side] = target


func solve_chain(
	upper_name: String,
	lower_name: String,
	end_name: String,
	target: Transform3D,
	pole_hint: Vector3,
	preserve_wrist := false
) -> void:
	var upper: int = skeleton.find_bone(upper_name)
	var lower: int = skeleton.find_bone(lower_name)
	var end: int = skeleton.find_bone(end_name)
	var u: Transform3D = skeleton.get_bone_global_pose(upper)
	var l: Transform3D = skeleton.get_bone_global_pose(lower)
	var e: Transform3D = skeleton.get_bone_global_pose(end)
	var l1 := u.origin.distance_to(l.origin)
	var l2 := l.origin.distance_to(e.origin)
	var direction := (target.origin - u.origin).normalized()
	var distance := clampf(
		target.origin.distance_to(u.origin),
		absf(l1 - l2) + .001,
		(l1 + l2) * .99 if preserve_wrist else l1 + l2 - .001
	)
	var along := (l1 * l1 - l2 * l2 + distance * distance) / (2 * distance)
	var pole := (pole_hint - direction * pole_hint.dot(direction)).normalized()
	var knee := u.origin + direction * along + pole * sqrt(maxf(0, l1 * l1 - along * along))
	var clamped := u.origin + direction * distance
	var solved_u := Transform3D(
		(
			Basis(Quaternion((l.origin - u.origin).normalized(), (knee - u.origin).normalized()))
			* u.basis
		),
		u.origin
	)
	var solved_l := Transform3D(
		(
			Basis(Quaternion((e.origin - l.origin).normalized(), (clamped - knee).normalized()))
			* l.basis
		),
		knee
	)
	set_jump_global(upper, solved_u)
	set_jump_global(lower, solved_l)
	target.origin = clamped
	if preserve_wrist:
		target.basis = solved_l.basis * skeleton.get_bone_rest(end).basis
	set_jump_global(end, target)


func make_actor_shadow() -> void:
	actor_shadow = MeshInstance3D.new()
	add_child(actor_shadow)
	var quad := QuadMesh.new()
	quad.size = Vector2(.65, .65)
	actor_shadow.mesh = quad
	actor_shadow.rotation.x = -PI / 2
	actor_shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader := Shader.new()
	shader.code = """shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float opacity=.3;
void fragment(){
 float circle=1.0-smoothstep(.40,.50,length(UV-vec2(.5)));
 ALBEDO=vec3(0.0);ALPHA=circle*opacity;
}"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	actor_shadow.material_override = mat
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func update_actor_shadow() -> void:
	var query := PhysicsRayQueryParameters3D.create(
		body.position + Vector3.UP * .02, body.position + Vector3.DOWN * 3
	)
	query.exclude = [body.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	actor_shadow.visible = not hit.is_empty()
	if hit.is_empty():
		return
	var altitude: float = maxf(0, body.position.y - hit.position.y)
	# Original scale/alpha curve; 1m fade range is a target-world calibration.
	var strength := clampf(1 - altitude, 0, 1)
	shadow_scale = .6 + .4 * strength
	actor_shadow.scale = Vector3.ONE * shadow_scale
	actor_shadow.position = hit.position + Vector3.UP * .012
	actor_shadow.material_override.set_shader_parameter("opacity", strength * .30)


func make_jump_animation() -> void:
	var animation := Animation.new()
	animation.length = 1.20
	var base := []
	var globals := []
	for bone in skeleton.get_bone_count():
		base.append(
			{
				"position": skeleton.get_bone_pose_position(bone),
				"rotation": skeleton.get_bone_pose_rotation(bone),
				"scale": skeleton.get_bone_pose_scale(bone)
			}
		)
		globals.append(skeleton.get_bone_global_pose(bone))
	var path: NodePath = player.get_node(player.root_node).get_path_to(skeleton)
	var tracks := []
	for bone in skeleton.get_bone_count():
		var channels := []
		for type in [
			Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D
		]:
			var track := animation.add_track(type)
			animation.track_set_path(
				track, NodePath(str(path) + ":" + skeleton.get_bone_name(bone))
			)
			channels.append(track)
		tracks.append(channels)
	# time, planted pelvis drop, thigh pitch, knee flex, arm pitch, elbow flex, arm spread.
	# Key poses are authored here; physics selects ascent/descent/contact, not a fixed flight clock.
	for pose in [
		[0, 0, 0, 0, 0, 0, 0, 0, 0],
		[.11, 0, 0, 0, 30, 0, 8, 10, 5],
		[.16, 0, 0, 0, -20, 0, 16, 12, -3],
		[.20, -.055, -3, 5, -35, 0, 20, 14, -5],
		[.50, -.055, -3, 5, -55, 0, 28, -10, 15],
		[.80, -.04, -3, 5, -18, 0, 15, 3, 8],
		[.84, 0, 0, 0, -12, 0, 8, 3, 8],
		[.90, 0, 0, 0, 18, 0, 12, 10, 10],
		[1.00, 0, 0, 0, 5, 0, 4, 3, 3],
		[1.07, 0, 0, 0, 0, 0, 0, 0, 0],
		[1.20, 0, 0, 0, 0, 0, 0, 0, 0]
	]:
		for bone in skeleton.get_bone_count():
			skeleton.set_bone_pose_position(bone, base[bone].position)
			skeleton.set_bone_pose_rotation(bone, base[bone].rotation)
			skeleton.set_bone_pose_scale(bone, base[bone].scale)
		skeleton.force_update_all_bone_transforms()
		var hip: int = skeleton.find_bone("Hips")
		var pelvis: Transform3D = globals[hip]
		pelvis.origin.y -= pose[1] / skeleton.global_basis.get_scale().y
		set_jump_global(hip, pelvis)
		for part in [
			["Spine", pose[7] / 3.0],
			["Spine01", pose[7] / 3.0],
			["Spine02", pose[7] / 3.0],
			["Head", pose[8]]
		]:
			var bone: int = skeleton.find_bone(part[0])
			skeleton.set_bone_pose_rotation(
				bone, base[bone].rotation * Quaternion(Vector3.RIGHT, deg_to_rad(part[1]))
			)
			skeleton.force_update_all_bone_transforms()
		for side in ["Left", "Right"]:
			if pose[0] <= .16 or pose[0] >= .84:
				# Feet stay planted as pelvis drops: solve the actual two-joint chain.
				var upper: int = skeleton.find_bone(side + "UpLeg")
				var lower: int = skeleton.find_bone(side + "Leg")
				var foot: int = skeleton.find_bone(side + "Foot")
				var h: Vector3 = skeleton.get_bone_global_pose(upper).origin
				var target: Vector3 = globals[foot].origin
				var l1: float = globals[upper].origin.distance_to(globals[lower].origin)
				var l2: float = globals[lower].origin.distance_to(target)
				var direction: Vector3 = (target - h).normalized()
				var d: float = target.distance_to(h)
				var along: float = (l1 * l1 - l2 * l2 + d * d) / (2 * d)
				# This imported character faces +Z (Godot BACK); knees flex toward the toes.
				var pole: Vector3 = (
					(Vector3.BACK - direction * Vector3.BACK.dot(direction)).normalized()
				)
				var knee: Vector3 = (
					h + direction * along + pole * sqrt(maxf(0, l1 * l1 - along * along))
				)
				for chain in [
					[upper, h, knee, globals[upper].origin, globals[lower].origin],
					[lower, knee, target, globals[lower].origin, target]
				]:
					var transform: Transform3D = globals[chain[0]]
					transform.basis = (
						Basis(
							Quaternion(
								(chain[4] - chain[3]).normalized(),
								(chain[2] - chain[1]).normalized()
							)
						)
						* transform.basis
					)
					transform.origin = chain[1]
					set_jump_global(chain[0], transform)
				set_jump_global(foot, globals[foot])
			else:
				var upper: int = skeleton.find_bone(side + "UpLeg")
				var lower: int = skeleton.find_bone(side + "Leg")
				var foot: int = skeleton.find_bone(side + "Foot")
				var h: Vector3 = skeleton.get_bone_global_pose(upper).origin
				var length: float = (
					globals[upper].origin.distance_to(globals[lower].origin)
					+ globals[lower].origin.distance_to(globals[foot].origin)
				)
				var target: Transform3D = skeleton.get_bone_global_pose(foot)
				target.origin = (
					h
					+ (
						(Vector3.DOWN + Vector3(.08 if side == "Left" else -.08, 0, 0)).normalized()
						* length
						* (.97 if pose[0] >= .80 else .999)
					)
				)
				target.basis = skeleton.get_bone_global_rest(foot).basis
				solve_chain(side + "UpLeg", side + "Leg", side + "Foot", target, Vector3.BACK)
			for part in [["Arm", pose[4]], ["ForeArm", pose[4] + pose[5]]]:
				var bone: int = skeleton.find_bone(side + part[0])
				var transform: Transform3D = skeleton.get_bone_global_pose(bone)
				transform.basis = (
					Basis(Vector3.BACK, deg_to_rad(pose[6] * (1 if side == "Left" else -1)))
					* Basis(Vector3.RIGHT, deg_to_rad(part[1]))
					* globals[bone].basis
				)
				set_jump_global(bone, transform)
		for bone in skeleton.get_bone_count():
			animation.position_track_insert_key(
				tracks[bone][0], pose[0], skeleton.get_bone_pose_position(bone)
			)
			animation.rotation_track_insert_key(
				tracks[bone][1], pose[0], skeleton.get_bone_pose_rotation(bone)
			)
			animation.scale_track_insert_key(
				tracks[bone][2], pose[0], skeleton.get_bone_pose_scale(bone)
			)
	for bone in skeleton.get_bone_count():
		skeleton.set_bone_pose_position(bone, base[bone].position)
		skeleton.set_bone_pose_rotation(bone, base[bone].rotation)
	player.get_animation_library("").add_animation("jump", animation)
	var landing := Animation.new()
	landing.length = .23
	for track in animation.get_track_count():
		var new_track := landing.add_track(animation.track_get_type(track))
		landing.track_set_path(new_track, animation.track_get_path(track))
		for key in animation.track_get_key_count(track):
			var time := animation.track_get_key_time(track, key)
			if time >= .84 and time <= 1.07:
				landing.track_insert_key(
					new_track, time - .84, animation.track_get_key_value(track, key)
				)
	player.get_animation_library("").add_animation("landing", landing)
	var flight := Animation.new()
	flight.length = .64
	for track in animation.get_track_count():
		var new_track := flight.add_track(animation.track_get_type(track))
		flight.track_set_path(new_track, animation.track_get_path(track))
		for key in animation.track_get_key_count(track):
			var time := animation.track_get_key_time(track, key)
			if time >= .20 and time <= .84:
				flight.track_insert_key(
					new_track, time - .20, animation.track_get_key_value(track, key)
				)
	player.get_animation_library("").add_animation("flight", flight)


func set_jump_global(bone: int, transform: Transform3D) -> void:
	var parent: int = skeleton.get_bone_parent(bone)
	var relative: Transform3D = (
		transform
		if parent < 0
		else skeleton.get_bone_global_pose(parent).affine_inverse() * transform
	)
	skeleton.set_bone_pose_position(bone, relative.origin)
	skeleton.set_bone_pose_rotation(
		bone, relative.basis.orthonormalized().get_rotation_quaternion()
	)
	skeleton.force_update_all_bone_transforms()


func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		if is_instance_valid(foot_audio):
			foot_audio.stop()
	elif what == NOTIFICATION_PREDELETE:
		audio_playback = null
		sounds.recorded_steps.clear()
		sounds.recorded_stone.clear()
		sounds.recorded_close = null
		sounds.streams.clear()


func _resume_audio() -> void:
	foot_audio.play()
	audio_playback = foot_audio.get_stream_playback()
