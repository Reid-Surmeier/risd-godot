## #135: experimentally reviewed Muse/Seedance cuts, not a certified skeletal rig.
extends Sprite3D

const HOME := "res://modules/shell/prototype/gallery_walk4/visitor/"
var clips := {}
var gesture := ""
var gesture_time := 0.0
var facing := 1
var world_height := 1.75
var _idle: Texture2D
var _material: ShaderMaterial
var _manifest: Dictionary

func _ready() -> void:
	_manifest = JSON.parse_string(FileAccess.get_file_as_string(HOME + "motion.json"))
	_idle = load(HOME + _manifest.idle)
	for clip in ["walk", "look", "wave"]:
		clips[clip] = []
		for file in _manifest[clip]:
			clips[clip].append(load(HOME + file))
	_material = ShaderMaterial.new()
	_material.shader = load("res://modules/shell/prototype/gallery_walk4/visitor.gdshader")
	material_override = _material
	_show(_idle, "idle")

func _show(image: Texture2D, clip: String) -> void:
	var single := clip == "look" or clip == "wave"
	hframes = 1 if single else 2
	vframes = hframes
	texture = image
	var cell := image.get_height() / float(vframes)
	var registration: Dictionary = _manifest.registration[clip]
	var pivot: Array = registration.pivots[0 if single else facing]
	pixel_size = world_height / float(registration.visible_height)
	# One fixed pivot per clip/view preserves the generated gait bob and foot lift.
	offset = Vector2(cell * 0.5 - float(pivot[0]), float(pivot[1]) - cell * 0.5)
	_material.set_shader_parameter("sheet", image)
	frame = 0 if single else facing

func play_gesture(name: String) -> bool:
	if name not in ["look", "wave"] or clips.get(name, []).is_empty():
		return false
	if facing != int(_manifest.gesture_facing[name]) or gesture == name:
		return false
	gesture = name
	gesture_time = 0.0
	return true

func pose(delta: float, moving: bool, phase: float, heading: Vector3, camera_yaw: float) -> void:
	var forward := Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var right := Vector3(cos(camera_yaw), 0, -sin(camera_yaw))
	var depth := heading.dot(forward)
	var across := heading.dot(right)
	var previous_facing := facing
	facing = (1 if depth >= 0.0 else 0) if absf(depth) >= absf(across) else (3 if across >= 0.0 else 2)
	if moving or facing != previous_facing:
		gesture = ""
	var image := _idle
	var selected := "idle"
	if moving and not clips.walk.is_empty():
		selected = "walk"
		image = clips.walk[int(fposmod(phase, 1.0) * clips.walk.size()) % clips.walk.size()]
	elif gesture != "":
		gesture_time += delta
		var index := int(gesture_time * float(_manifest.gesture_fps))
		if index < clips[gesture].size():
			selected = gesture
			image = clips[gesture][index]
		else:
			gesture = ""
	_show(image, selected)
