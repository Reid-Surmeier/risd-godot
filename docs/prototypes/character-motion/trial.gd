extends Node
## Scratch-only KayKit motion on untouched ACNH body data. Not Nintendo motion.

const MAP := {
	"Armature_Spine_1": "hips", "Armature_Waist": "hips",
	"Armature_Spine_2": "spine", "Armature_Spine_3": "chest",
	"Armature_Head_2": "head",
	"Armature_Arm_1_L": "upperarm.l", "Armature_Arm_2_L": "lowerarm.l",
	"Armature_Wrist_L": "hand.l", "Armature_Arm_1_R": "upperarm.r",
	"Armature_Arm_2_R": "lowerarm.r", "Armature_Wrist_R": "hand.r",
	"Armature_Leg_1_L_2": "upperleg.l", "Armature_Leg_2_L": "lowerleg.l",
	"Armature_Ankle_L": "foot.l", "Armature_Toe_L": "toes.l",
	"Armature_Leg_1_R_2": "upperleg.r", "Armature_Leg_2_R": "lowerleg.r",
	"Armature_Ankle_R": "foot.r", "Armature_Toe_R": "toes.r",
}
var target: Skeleton3D
var donor: Skeleton3D
var player: AnimationPlayer
var model: Node3D
var label: Label
var camera: Camera3D
var pairs := {}
var metrics := []
var body_scale := 1.75 / 21.87
var hip_ratio := 4.84 / 0.405663
var mapped_before := []
var skin_meshes := []
var sole_indices := []
var floor_offset := 0.0
var hip_adjust := 0.2
var leg_weight := 0.0
var feet := []
@onready var root := get_tree().root

# Adapted from the already accepted KayKit gallery visitor's two-bone solver.
func solve_leg(foot: Dictionary, point: Vector3) -> void:
	var upper := target.get_bone_global_pose(foot.upper)
	var lower := target.get_bone_global_pose(foot.lower)
	var end := target.get_bone_global_pose(foot.ankle)
	var ankle: Vector3 = point - foot.flat * foot.sole
	var a := upper.origin.distance_to(lower.origin)
	var b := lower.origin.distance_to(end.origin)
	var direction := (ankle - upper.origin).normalized()
	var distance := clampf(ankle.distance_to(upper.origin), 0.001, a + b - 0.00001)
	var pole := lower.origin - upper.origin
	pole = (pole - direction * pole.dot(direction)).normalized()
	if pole.length_squared() < 0.1:
		pole = Vector3.FORWARD
	var along := (a * a - b * b + distance * distance) / (2.0 * distance)
	var knee := upper.origin + direction * along + pole * sqrt(maxf(0, a * a - along * along))
	upper.basis = Basis(Quaternion((lower.origin - upper.origin).normalized(), (knee - upper.origin).normalized())) * upper.basis
	target.set_bone_global_pose(foot.upper, upper)
	target.force_update_all_bone_transforms()
	lower = target.get_bone_global_pose(foot.lower)
	end = target.get_bone_global_pose(foot.ankle)
	lower.basis = Basis(Quaternion((end.origin - lower.origin).normalized(), (ankle - lower.origin).normalized())) * lower.basis
	target.set_bone_global_pose(foot.lower, lower)
	target.force_update_all_bone_transforms()
	end = target.get_bone_global_pose(foot.ankle)
	end.basis = foot.flat
	target.set_bone_global_pose(foot.ankle, end)
	target.force_update_all_bone_transforms()

func contacts(phase: float, moving: bool) -> void:
	for i in feet.size():
		var foot: Dictionary = feet[i]
		target.set_bone_pose(foot.toe, target.get_bone_rest(foot.toe))
		target.force_update_all_bone_transforms()
		var planted := (phase >= 0.11 and phase < 0.46) if i == 0 else (phase >= 0.61 and phase < 0.96)
		planted = planted if moving else true
		var point: Vector3 = target.global_transform * (target.get_bone_global_pose(foot.ankle) * foot.sole)
		if moving:
			foot.settling = false
		if not moving:
			var rest_point: Vector3 = target.global_transform * (target.get_bone_global_rest(foot.ankle) * foot.sole)
			rest_point.y = 0
			if not foot.settling and foot.anchor.distance_to(rest_point) > 0.002:
				foot.settling = true
				if not foot.locked:
					foot.anchor = Vector3(point.x, 0, point.z)
			if foot.settling:
				foot.anchor = foot.anchor.lerp(rest_point, 0.2)
				planted = false
				if foot.anchor.distance_to(rest_point) < 0.002:
					foot.anchor = rest_point
					foot.settling = false
					planted = true
		if planted and not foot.locked and moving:
			foot.anchor = Vector3(point.x, 0, point.z)
			foot.anchor_basis = target.global_basis * foot.rest_flat
		foot.locked = planted
		foot.flat = target.global_basis.inverse() * foot.anchor_basis if planted else foot.rest_flat
		var goal: Vector3 = foot.anchor if planted or foot.settling else Vector3(point.x, maxf(point.y, 0.015), point.z)
		solve_leg(foot, target.global_transform.affine_inverse() * goal)

func skin_points(mesh: MeshInstance3D) -> PackedVector3Array:
	var arrays := mesh.mesh.surface_get_arrays(0)
	var transforms := []
	for bind in mesh.skin.get_bind_count():
		var bone := target.find_bone(mesh.skin.get_bind_name(bind))
		assert(bone >= 0)
		transforms.append(target.global_transform * target.get_bone_global_pose(bone) * mesh.skin.get_bind_pose(bind))
	var points := PackedVector3Array()
	for vertex in arrays[Mesh.ARRAY_VERTEX].size():
		var point := Vector3.ZERO
		for k in 4:
			point += (transforms[arrays[Mesh.ARRAY_BONES][vertex * 4 + k]] * arrays[Mesh.ARRAY_VERTEX][vertex]) * arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + k]
		points.append(point)
	return points

func _ready() -> void:
	call_deferred("run")

func sample(clip: String, time: float) -> Array:
	player.play(clip)
	var duration := player.get_animation(clip).length
	player.seek(minf(time, duration - 0.001) if clip == "Interact" else fmod(time, duration), true)
	player.advance(0)
	donor.force_update_all_bone_transforms()
	var globals := []
	for i in donor.get_bone_count():
		globals.append(donor.get_bone_global_pose(i))
	return globals

func transfer(poses: Array, look: float) -> void:
	var current := []
	for i in target.get_bone_count():
		var local := target.get_bone_rest(i)
		var parent := target.get_bone_parent(i)
		var parent_pose: Transform3D = current[parent] if parent >= 0 else Transform3D.IDENTITY
		if pairs.has(i):
			var source: int = pairs[i]
			var delta: Basis = poses[source].basis * donor.get_bone_global_rest(source).basis.inverse()
			if target.get_bone_name(i).contains("Leg_"):
				delta = Basis.IDENTITY.slerp(delta, leg_weight)
			var wanted := delta * target.get_bone_global_rest(i).basis
			if target.get_bone_name(i) == "Armature_Head_2":
				wanted = Basis(Vector3.UP, look) * wanted
			local.basis = parent_pose.basis.inverse() * wanted
		if parent < 0:
			var hips := donor.find_bone("hips")
			local.origin += (poses[hips].origin - donor.get_bone_global_rest(hips).origin) * hip_ratio
			local.origin.y += hip_adjust
		target.set_bone_pose(i, local)
		current.append(parent_pose * local)
	target.force_update_all_bone_transforms()

func setup() -> Node3D:
	var stage := Node3D.new()
	root.add_child(stage)
	model = load("res://character.glb").instantiate()
	stage.add_child(model)
	target = model.find_children("*", "Skeleton3D", true, false)[0]
	var min_y := INF
	var max_y := -INF
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		for point in skin_points(mesh):
			min_y = minf(min_y, point.y)
			max_y = maxf(max_y, point.y)
		if str(mesh.name).contains("Socks"):
			skin_meshes.append(mesh)
	var rest_feet := skin_points(skin_meshes[0])
	for i in rest_feet.size():
		if rest_feet[i].y < min_y + 0.12:
			sole_indices.append(i)
	body_scale = 1.75 / (max_y - min_y)
	floor_offset = -min_y * body_scale
	hip_ratio = (4.84 - min_y) / 0.405663
	model.scale = Vector3.ONE * body_scale
	model.position.y = floor_offset
	for side in ["L", "R"]:
		var ankle := target.find_bone("Armature_Ankle_" + side)
		var ankle_rest := target.get_bone_global_rest(ankle)
		var sole := Vector3.ZERO
		var count := 0
		for i in sole_indices:
			if (rest_feet[i].x > 0) == (side == "L"):
				sole += rest_feet[i]
				count += 1
		sole /= count
		sole.y = min_y
		sole.y -= 4.84
		feet.append({"upper": target.find_bone("Armature_Leg_1_" + side + "_2"),
			"lower": target.find_bone("Armature_Leg_2_" + side), "ankle": ankle,
			"toe": target.find_bone("Armature_Toe_" + side), "flat": ankle_rest.basis, "rest_flat": ankle_rest.basis,
			"anchor_basis": Basis.IDENTITY, "settling": false,
			"sole": ankle_rest.affine_inverse() * sole, "locked": false, "anchor": Vector3.ZERO})
	for foot in feet:
		var rest_point: Vector3 = target.global_transform * (target.get_bone_global_rest(foot.ankle) * foot.sole)
		foot.anchor = Vector3(rest_point.x, 0, rest_point.z)
		foot.anchor_basis = target.global_basis * foot.rest_flat
	print("REST bounds=", min_y, "..", max_y, " soles=", sole_indices.size())
	var source: Node3D = load("res://donor.glb").instantiate()
	stage.add_child(source)
	source.visible = false
	donor = source.find_children("*", "Skeleton3D", true, false)[0]
	player = source.find_children("*", "AnimationPlayer", true, false)[0]
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for name in MAP:
		var a := target.find_bone(name)
		var b := donor.find_bone(MAP[name])
		assert(a >= 0 and b >= 0, "missing mapped bone " + name)
		pairs[a] = b
	for clip in ["Idle", "Walking_A", "Interact"]:
		assert(player.has_animation(clip))
		print("CLIP ", clip, " length=", player.get_animation(clip).length)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("dadbd8")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 1.0
	stage.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -30, 0)
	stage.add_child(light)
	for x in range(-5, 19):
		for z in range(-5, 30):
			var tile := MeshInstance3D.new()
			var mesh := PlaneMesh.new()
			mesh.size = Vector2.ONE * 0.5
			tile.mesh = mesh
			tile.position = Vector3(x * 0.5, 0, z * 0.5)
			var material := StandardMaterial3D.new()
			material.albedo_color = Color("c2c4c2") if (x + z) % 2 == 0 else Color("d4d5d2")
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			tile.material_override = material
			stage.add_child(tile)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.8
	stage.add_child(camera)
	camera.current = true
	label = Label.new()
	label.position = Vector2(12, 12)
	label.add_theme_color_override("font_color", Color.BLACK)
	root.add_child(label)
	return stage

func run() -> void:
	setup()
	var view := OS.get_environment("MOTION_VIEW")
	if OS.has_feature("web"):
		view = str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('view') || 'front'"))
	if view == "":
		view = "front"
	var out := "res://frames-" + view
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	var previous := ""
	var transition := 0.0
	var old_pose: Array = sample("Idle", 0)
	var gait := 0.0
	var yaw := 0.0
	# Warm shaders and skinning before starting the playback clock.
	transfer(old_pose, 0)
	contacts(0, false)
	label.text = "Preparing motion replay..."
	camera.position = Vector3(0, 2.6, 6)
	camera.look_at(Vector3(0, 0.8, 0))
	for warm_frame in (30 if OS.has_feature("web") else 1):
		transfer(old_pose, 0)
		contacts(0, false)
		skin_points(skin_meshes[0])
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var started := Time.get_ticks_usec()
	var previous_time := 0.0
	var frame := 0
	var realtime := OS.has_feature("web") or OS.get_environment("MOTION_REALTIME") == "1"
	while true:
		var wall_time := (Time.get_ticks_usec() - started) / 1000000.0
		var time := wall_time if realtime else frame / 30.0
		if time >= 18.0:
			break
		var delta := time - previous_time if realtime else 1.0 / 30
		previous_time = time
		var clip := "Idle"
		var action := "idle"
		var speed := 0.0
		var desired_yaw := yaw
		if time >= 2 and time < 5:
			clip = "Walking_A"
			action = "straight walk / start"
			speed = 1.2
		elif time >= 6 and time < 8:
			clip = "Walking_A"
			action = "diagonal walk"
			speed = 1.2
			desired_yaw = PI / 4
		elif time >= 8 and time < 10:
			clip = "Walking_A"
			action = "90 / 180 turns"
			desired_yaw = PI / 2 if time < 9 else PI
		elif time >= 10 and time < 11:
			clip = "Walking_A"
			action = "turn to artwork"
			desired_yaw = 0.0
		elif time >= 11 and time < 11.65:
			clip = "Interact"
			action = "interaction / move to cancel"
		elif time >= 11.65 and time < 13:
			clip = "Walking_A"
			action = "interaction canceled by walk"
			speed = 1.2
		elif time >= 16 and time < 17.3:
			clip = "Interact"
			action = "complete interaction"
		elif time >= 14 and time < 16:
			action = "release / look"
		if clip != previous:
			old_pose = mapped_before.duplicate() if not mapped_before.is_empty() else old_pose
			transition = time
			previous = clip
			gait = 0
		# Measured slow-walk trial sped by actual displacement: accelerated walk, not run.
		gait += (speed / 0.4 if speed > 0 else 1.0) * delta
		var pose := sample(clip, gait)
		hip_adjust = move_toward(hip_adjust, -0.30 if clip == "Walking_A" else 0.2, delta * 4.0)
		leg_weight = move_toward(leg_weight, 1.0 if clip == "Walking_A" else 0.0, delta * 4.0)
		var blend := clampf((time - transition) / 0.2, 0, 1)
		for i in pose.size():
			pose[i] = old_pose[i].interpolate_with(pose[i], blend)
		mapped_before = pose
		yaw = lerp_angle(yaw, desired_yaw, 1.0 - pow(0.85, delta * 30.0))
		model.rotation.y = yaw
		model.position += Basis(Vector3.UP, yaw) * Vector3(0, 0, speed * delta)
		transfer(pose, sin(time * 2) * 0.35 if time >= 14 else 0.0)
		contacts(fmod(gait / player.get_animation("Walking_A").length, 1.0), clip == "Walking_A")
		label.text = "NON-AUTHENTIC KAYKIT RETARGET — " + view + "\n" + action + "  %.2fs" % time
		var center := model.position + Vector3.UP * 0.8
		var offset: Vector3 = {"front": Vector3(0, 1.8, 6), "side": Vector3(6, 1.8, 0), "back": Vector3(0, 1.8, -6), "gallery": Vector3(0, 0, 0)}[view]
		if view == "gallery":
			camera.projection = Camera3D.PROJECTION_PERSPECTIVE
			camera.fov = 23.0
			center = model.position + Vector3(0, 1.85, -0.7)
			offset = Vector3(0, sin(deg_to_rad(42.0)), cos(deg_to_rad(42.0))) * 14.2
		camera.position = center + offset
		camera.look_at(center)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.motionProgress = {demo_seconds: %f, frame: %d}" % [time, frame])
		if not OS.has_feature("web"):
			root.get_texture().get_image().save_png(out + "/%04d.png" % frame)
		var feet := []
		for bone in ["Armature_Ankle_L", "Armature_Toe_L", "Armature_Ankle_R", "Armature_Toe_R"]:
			var point := target.global_transform * target.get_bone_global_pose(target.find_bone(bone)).origin
			feet.append([point.x, point.y, point.z])
		var skinned := skin_points(skin_meshes[0])
		var skin_min := INF
		for p in skinned:
			skin_min = minf(skin_min, p.y)
		var sole_points := []
		for i in sole_indices:
			sole_points.append([skinned[i].x, skinned[i].y, skinned[i].z])
		var support := []
		for foot in self.feet:
			var p: Vector3 = target.global_transform * (target.get_bone_global_pose(foot.ankle) * foot.sole)
			support.append({"locked": foot.locked, "error": p.distance_to(foot.anchor) if foot.locked else 0.0})
		metrics.append({"time": time, "wall_time": wall_time, "realtime": realtime, "clip": clip, "action": action, "feet": feet, "sole_vertices": sole_points, "skin_min": skin_min, "support": support,
			"position": [model.position.x, model.position.y, model.position.z], "yaw": yaw})
		frame += 1
	if OS.has_feature("web"):
		# Let the browser observe the final rendered timestamp before audit serialization.
		await get_tree().process_frame
		JavaScriptBridge.eval("window.motionComplete = true")
		await get_tree().create_timer(0.1).timeout
		JavaScriptBridge.eval("window.motionMetrics = " + JSON.stringify(metrics))
	else:
		FileAccess.open("res://metrics-" + view + ".json", FileAccess.WRITE).store_string(JSON.stringify(metrics))
	print("PASS: ", metrics.size(), " complete frames; rig=", target.get_bone_count(), " target_scale=", body_scale, " hip_ratio=", hip_ratio)
	if not OS.has_feature("web"):
		get_tree().quit()
