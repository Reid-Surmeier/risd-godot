extends Node3D
## THROWAWAY #231: walk, turn, sprint and stop with the selected character.
# Owner-requested 3x travel adjustment; these are playtest choices, not recovered game units.
const WALK_SPEED := 3.15
const DASH_SPEED := 5.4
class FootEvents extends Node:
	var emit: Callable
	func footstep(foot: String) -> void:
		emit.call(foot)

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
var transition_time := 0.0
var soles := []

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 1
	return result

func block(position: Vector3, size: Vector3, color: Color, solid := false) -> void:
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

func _ready() -> void:
	var keys: Dictionary = {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"sprint":[KEY_SHIFT]}
	for action in keys:
		InputMap.add_action(action)
		for key in keys[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action,event)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("8fc3b0")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.8
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-20,0)
	sun.shadow_enabled = true
	add_child(sun)
	block(Vector3(0,-0.1,0),Vector3(32,0.2,32),Color("50914a"),true)
	block(Vector3(0,0.002,0),Vector3(5,0.006,32),Color("c8b775"))
	for i in range(-15,16):
		block(Vector3(0,0.008,i),Vector3(5,0.004,0.025),Color("ad9b62"))
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
	var fast: Node3D = load("res://fast.glb").instantiate()
	var fast_player: AnimationPlayer = fast.find_children("*","AnimationPlayer",true,false)[0]
	player.get_animation_library("").add_animation("dash",fast_player.get_animation("walk").duplicate())
	fast.free()
	var relay := FootEvents.new()
	relay.name = "FootEvents"
	relay.emit = footstep
	player.get_node(player.root_node).add_child(relay)
	var animation := player.get_animation("dash")
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track,NodePath("FootEvents"))
	for event in [{"time":0.0,"foot":"Left"},{"time":7.0/30,"foot":"Right"}]:
		animation.track_insert_key(track,event.time,{"method":&"footstep","args":[event.foot]})
	for clip in ["idle","walk","dash"]: player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.callback_mode_method = AnimationMixer.ANIMATION_CALLBACK_MODE_METHOD_IMMEDIATE
	player.play("idle")
	# Cache only rigid Foot vertices using the existing proof's skin calculation.
	for mesh in model.find_children("*","MeshInstance3D",true,false):
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
	hint.text = "WASD / arrows · Shift sprint · R reset\nTouch: hold arrows + Sprint"
	lines.add_child(hint)
	var controls := HBoxContainer.new()
	lines.add_child(controls)
	for title in ["Change view","Reset"]:
		var button := Button.new()
		button.text = title
		button.focus_mode = Control.FOCUS_NONE
		controls.add_child(button)
		if title=="Reset": button.pressed.connect(reset)
		else: button.pressed.connect(func(): camera_view = (camera_view+1)%3)
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
	model.rotation.y = 0
	state = "Idle"
	player.play("idle",0.15)
	transition_time = 0.15
	for puff in dust: puff.node.queue_free()
	dust.clear()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode==KEY_R: reset()

func footstep(foot: String) -> void:
	if state!="Dash": return
	skeleton.force_update_all_bone_transforms()
	var ankle := skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone(foot+"Foot")).origin
	for i in 5:
		var puff := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.06
		sphere.height = 0.12
		puff.mesh = sphere
		puff.material_override = material(Color("f5f7ff"))
		add_child(puff)
		var direction := Vector3(cos(i*2.4),0,sin(i*2.4))
		# Birth position stays in the world when the character turns or stops.
		var anchor := Vector3(ankle.x,0.04,ankle.z)-model.global_basis.z*0.10
		dust.append({"node":puff,"age":0.0,"origin":anchor,"direction":direction})
	emitted += 1

func _physics_process(delta: float) -> void:
	if player==null: return
	var input := Input.get_vector("left","right","up","down")
	var target_state := "Idle" if input.length()<0.1 else ("Dash" if Input.is_action_pressed("sprint") else "Walk")
	var yaw: float = [0.0,PI/2,0.0][camera_view]
	var direction := Vector3(input.x,0,input.y).rotated(Vector3.UP,yaw)
	var speed := 0.0 if target_state=="Idle" else (DASH_SPEED if target_state=="Dash" else WALK_SPEED)
	body.velocity = Vector3(direction.x*speed,body.velocity.y-9.8*delta,direction.z*speed)
	body.move_and_slide()
	if direction.length()>0.1: model.rotation.y = lerp_angle(model.rotation.y,atan2(direction.x,direction.z),minf(1,delta*14))
	if target_state!=state:
		state = target_state
		# Faster WALK cadence alongside travel; stride fit remains a separate research gate.
		player.play({"Idle":"idle","Walk":"walk","Dash":"dash"}[state],0.15,1.25 if state=="Walk" else 1.0)
		transition_time = 0.15
	player.advance(delta)
	skeleton.force_update_all_bone_transforms()
	# ponytail: visual blend-floor lift only; planted turning/terrain needs world-anchor IK.
	model.position.y = 0
	if transition_time>0:
		var low := INF
		for sole in soles: low = minf(low,(skeleton.global_transform*(skeleton.get_bone_global_pose(sole.bone)*sole.point)).y-body.position.y)
		model.position.y = maxf(0,-low)
		transition_time -= delta
	for i in range(dust.size()-1,-1,-1):
		var puff: Dictionary = dust[i]
		puff.age += delta
		if puff.age>=0.24:
			puff.node.queue_free()
			dust.remove_at(i)
		else:
			puff.node.position = puff.origin+puff.direction*puff.age*0.85+Vector3.UP*sin(puff.age/0.24*PI)*0.09
			puff.node.scale = Vector3.ONE*(1-puff.age/0.24)
	var target := body.position+Vector3.UP*0.85
	var angle := deg_to_rad(25 if camera_view==2 else 45)
	camera.position = target+Vector3(sin(yaw)*cos(angle),sin(angle),cos(yaw)*cos(angle))*17
	camera.look_at(target)
	status.text = "Character playtest · "+state
	bridge_time += delta
	if OS.has_feature("web") and bridge_time>0.1:
		bridge_time = 0
		JavaScriptBridge.eval("window.characterPlaytest="+JSON.stringify({"state":state,"x":body.position.x,"z":body.position.z,"yaw":model.rotation.y,"effects":emitted,"view":camera_view,"bones":skeleton.get_bone_count(),"physics_time":Time.get_ticks_msec()/1000.0,"speed_mps":Vector2(body.velocity.x,body.velocity.z).length(),"animation_rate":player.get_playing_speed()}))
