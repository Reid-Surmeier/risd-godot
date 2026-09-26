## PROTOTYPE 3, throwaway (2026-09-26): the RISD Grand Gallery as a real-time low-poly 3D room, walked in third
## person inside the Collection frame. Walls are textured with orthographic elevations rebuilt from the owner's
## video (structure-from-motion, image-work/grand-gallery-v3), so every painting hangs where it really hangs.
## Keys: Up/W step forward (hold to keep walking), Down/S step back, Left/A Right/D turn (hold to keep turning),
## Esc closes a painting. Click the floor to walk there; click a painting to walk up to it and open it.
extends Control

const DIR := "res://modules/shell/prototype/gallery_walk3/"
const LOW_RES := Vector2i(480, 320)  # the render resolution; upscaled with hard pixels
const STEP_M := 1.5
const WALK_MPS := 1.6
const TURN_DPS := 90.0
const KID_H := 1.05
const FRAME_MARGINS := [177, 168, 173, 181]  # the detail frame's border, in its pixels

var layout: Dictionary
var _vp: SubViewport
var _cam: Camera3D
var _kid: Sprite3D
var _kid_frames: Array[Texture2D] = []
var _kid_t := 0.0
var _pos := Vector3.ZERO  # the kid's feet
var _yaw := 0.0  # radians, 0 = facing north (-Z)
var _target = null  # Vector3 the kid is walking to, or null
var _target_yaw = null
var _moving := false
var _paintings: Array = []  # {id, wall, center(Vector3), normal(Vector3), size(Vector2), detail}
var _detail: Control
var _open := ""
var _held := {}


func _ready() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	layout = JSON.parse_string(FileAccess.get_file_as_string(DIR + "layout.json"))
	var box := SubViewportContainer.new()
	box.stretch = true
	box.stretch_shrink = 1
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	box.material = _crt_material()
	add_child(box)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.size = LOW_RES
	_vp.msaa_3d = Viewport.MSAA_DISABLED
	box.add_child(_vp)
	resized.connect(func() -> void: _vp.size = LOW_RES)
	_build_room()
	_build_kid()
	_cam = Camera3D.new()
	_cam.fov = 58.0
	_vp.add_child(_cam)
	var start: Array = layout.start
	_pos = Vector3(start[0], 0, start[1])
	_yaw = deg_to_rad(start[2])
	_build_detail()
	_update_camera(1.0)


func _crt_material() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform float scan = 0.93;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float row = floor(UV.y / TEXTURE_PIXEL_SIZE.y);
	c.rgb *= mix(1.0, scan, mod(row, 2.0));
	COLOR = c;
}
"""
	var m := ShaderMaterial.new()
	m.shader = sh
	return m


func _mat(tex: Texture2D, color := Color.WHITE) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	m.albedo_color = color
	if tex:
		m.albedo_texture = tex
	return m


func _quad(size: Vector2, mat: Material, xf: Transform3D, uv_scale := Vector2.ONE) -> MeshInstance3D:
	var q := QuadMesh.new()
	q.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = q
	mi.transform = xf
	if uv_scale != Vector2.ONE and mat is StandardMaterial3D:
		mat.uv1_scale = Vector3(uv_scale.x, uv_scale.y, 1)
	mi.material_override = mat
	_vp.add_child(mi)
	return mi


func _build_room() -> void:
	var room: Dictionary = layout.room
	var L: float = room.length
	var W: float = room.width
	var H: float = room.wall_height
	var wall_col := Color(room.wall_color)
	# floor (tiled herringbone) and walls (plain wall colour behind the elevation strips)
	var floor_mat := _mat(load(DIR + "textures/floor.png"))
	floor_mat.uv1_scale = Vector3(W / 1.6, L / 0.8, 1)
	_quad(Vector2(W, L), floor_mat, Transform3D(Basis(Vector3.RIGHT, -PI / 2), Vector3(0, 0, -L / 2)))
	var plain := _mat(null, wall_col)
	_quad(Vector2(L, H), plain, Transform3D(Basis(Vector3.UP, PI / 2), Vector3(-W / 2, H / 2, -L / 2)))  # west
	_quad(Vector2(L, H), plain, Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(W / 2, H / 2, -L / 2)))  # east
	# the two ends: the north doorway wall and the south arch wall, each one texture
	for end in ["north", "south"]:
		var e: Dictionary = room[end]
		var tex: Texture2D = load(DIR + "textures/%s.png" % end)
		var z := -L if end == "north" else 0.0
		var rot := 0.0 if end == "north" else PI
		_quad(Vector2(W, H), _mat(tex), Transform3D(Basis(Vector3.UP, rot), Vector3(0, H / 2, z)))
	# elevation strips on the long walls, placed in metres
	for s in layout.strips:
		var tex: Texture2D = load(DIR + "textures/%s.png" % s.id)
		var west: bool = s.wall == "west"
		var len_m: float = s.length
		var h_m: float = s.height
		var z_mid: float = -(s.from_south + len_m / 2.0)
		var x := -W / 2 + 0.01 if west else W / 2 - 0.01
		var basis := Basis(Vector3.UP, PI / 2 if west else -PI / 2)
		var sm := _mat(tex)
		sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA  # feathered edges melt into the plain wall
		_quad(Vector2(len_m, h_m), sm, Transform3D(basis, Vector3(x, s.bottom + h_m / 2, z_mid)))
	# cornice and a low-poly barrel vault with the skylight down its middle
	var vault_col := Color(room.vault_color)
	var R := W / 2.0
	var segs := 8
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in segs:
		var a0 := PI * i / segs
		var a1 := PI * (i + 1) / segs
		var p0 := Vector3(-cos(a0) * R, H + sin(a0) * R * room.vault_rise, 0)
		var p1 := Vector3(-cos(a1) * R, H + sin(a1) * R * room.vault_rise, 0)
		var shade := 0.82 + 0.18 * sin((a0 + a1) / 2.0)
		st.set_color(vault_col * Color(shade, shade, shade))
		for v in [p0, p1, p1 + Vector3(0, 0, -L), p0, p1 + Vector3(0, 0, -L), p0 + Vector3(0, 0, -L)]:
			st.add_vertex(v)
		st.set_color(vault_col * Color(0.9, 0.9, 0.9))  # the two end caps of the vault
		for z in [0.0, -L]:
			for v in [Vector3(0, H, z), p0 + Vector3(0, 0, z), p1 + Vector3(0, 0, z)]:
				st.add_vertex(v)
	var vm := StandardMaterial3D.new()
	vm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	vm.vertex_color_use_as_albedo = true
	vm.cull_mode = BaseMaterial3D.CULL_DISABLED
	var vault := MeshInstance3D.new()
	vault.mesh = st.commit()
	vault.material_override = vm
	_vp.add_child(vault)
	var sky := _mat(load(DIR + "textures/skylight.png"))
	sky.uv1_scale = Vector3(1, L / 3.0, 1)
	_quad(Vector2(room.skylight_width, L), sky, Transform3D(Basis(Vector3.RIGHT, PI / 2), Vector3(0, H + R * room.vault_rise - 0.02, -L / 2)))
	# paintings: clickable spots on the walls
	for p in layout.paintings:
		var west: bool = p.wall == "west"
		var n := Vector3.RIGHT if west else Vector3.LEFT
		var c := Vector3(-W / 2 if west else W / 2, p.center_y, -p.along_from_south)
		_paintings.append({"id": p.id, "center": c, "normal": n, "size": Vector2(p.width, p.height), "detail": p.detail})


func _build_kid() -> void:
	var i := 0
	while ResourceLoader.exists(DIR + "kid/%02d.png" % i):
		_kid_frames.append(load(DIR + "kid/%02d.png" % i))
		i += 1
	_kid = Sprite3D.new()
	_kid.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	_kid.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_kid.shaded = false
	_kid.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_kid.texture = _kid_frames[0]
	_kid.pixel_size = KID_H / _kid_frames[0].get_height()
	_kid.offset = Vector2(0, _kid_frames[0].get_height() / 2.0)
	_vp.add_child(_kid)
	# a soft drop shadow under the kid
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.55))
	g.set_color(1, Color(0, 0, 0, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.0)
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.albedo_texture = gt
	var shadow := _quad(Vector2(0.75, 0.42), sm, Transform3D(Basis(Vector3.RIGHT, -PI / 2), Vector3(0, 0.01, 0)))
	shadow.name = "Shadow"
	_kid.set_meta("shadow", shadow)


func _build_detail() -> void:
	_detail = Control.new()
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.modulate.a = 0.0
	add_child(_detail)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.04, 0.05, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(dim)
	var pic := TextureRect.new()
	pic.name = "Painting"
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(pic)
	var frame := NinePatchRect.new()  # the owner's Muse low-poly gilt frame (renaissance-frame-lowpoly-thin-v3)
	frame.name = "Frame"
	frame.texture = load(DIR + "textures/detail-frame.png")
	frame.patch_margin_left = FRAME_MARGINS[0]
	frame.patch_margin_top = FRAME_MARGINS[1]
	frame.patch_margin_right = FRAME_MARGINS[2]
	frame.patch_margin_bottom = FRAME_MARGINS[3]
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(frame)


# The painting fills most of the view; the gilt border is drawn at ~9% of its height around it.
func _layout_detail(aspect: float) -> void:
	var pic: TextureRect = _detail.get_node("Painting")
	var frame: NinePatchRect = _detail.get_node("Frame")
	var ph := minf(size.y * 0.7, size.x * 0.62 / aspect)
	var pw := ph * aspect
	pic.size = Vector2(pw, ph)
	pic.position = (size - pic.size) / 2
	var k := ph * 0.09 / FRAME_MARGINS[1]
	frame.scale = Vector2(k, k)
	frame.size = Vector2(pw / k + FRAME_MARGINS[0] + FRAME_MARGINS[2], ph / k + FRAME_MARGINS[1] + FRAME_MARGINS[3])
	frame.position = pic.position - Vector2(FRAME_MARGINS[0], FRAME_MARGINS[1]) * k


func _process(delta: float) -> void:
	if _open != "":
		return
	var fwd := Vector3(sin(_yaw) * -1.0, 0, -cos(_yaw))
	# held keys: continuous walking and turning
	if _held.get("left", 0.0) > 0.25:
		_yaw += deg_to_rad(TURN_DPS) * delta
		_target_yaw = null
	if _held.get("right", 0.0) > 0.25:
		_yaw -= deg_to_rad(TURN_DPS) * delta
		_target_yaw = null
	for k in _held.keys():
		_held[k] += delta
	var moving := false
	if _held.get("up", 0.0) > 0.25:
		_target = _pos + fwd * WALK_MPS * 0.3
	if _held.get("down", 0.0) > 0.25:
		_target = _pos - fwd * WALK_MPS * 0.3
	if _target_yaw != null:
		var d := wrapf(_target_yaw - _yaw, -PI, PI)
		var stepa := deg_to_rad(TURN_DPS * 2.0) * delta
		if absf(d) <= stepa:
			_yaw = _target_yaw
			_target_yaw = null
		else:
			_yaw += signf(d) * stepa
	if _target != null:
		var to: Vector3 = _target - _pos
		to.y = 0
		var dist := to.length()
		if dist < 0.03:
			_target = null
		else:
			_pos += to.normalized() * minf(dist, WALK_MPS * delta)
			moving = true
	_pos = _clamp_to_room(_pos)
	_moving = moving
	if moving and _kid_frames.size() > 1:
		_kid_t += delta
		_kid.texture = _kid_frames[int(_kid_t * 12.0) % _kid_frames.size()]
	elif not _kid_frames.is_empty():
		_kid.texture = _kid_frames[0]
	_update_camera(minf(1.0, delta * 6.0))


func _clamp_to_room(p: Vector3) -> Vector3:
	var room: Dictionary = layout.room
	var m := 0.6
	return Vector3(clampf(p.x, -room.width / 2 + m, room.width / 2 - m), 0, clampf(p.z, -room.length + m, -m))


func _update_camera(k: float) -> void:
	var fwd := Vector3(-sin(_yaw), 0, -cos(_yaw))
	_kid.position = _pos
	(_kid.get_meta("shadow") as Node3D).position = _pos + Vector3(0, 0.01, 0)
	var want := _pos - fwd * 3.1 + Vector3(0, 1.95, 0)
	_cam.position = _cam.position.lerp(want, k) if k < 1.0 else want
	_cam.look_at(_pos + fwd * 4.0 + Vector3(0, 1.05, 0))


func _step(dir: float) -> void:
	var fwd := Vector3(-sin(_yaw), 0, -cos(_yaw))
	_target = _clamp_to_room((_target if _target != null else _pos) + fwd * STEP_M * dir)


func _turn(dir: float) -> void:
	var base: float = _target_yaw if _target_yaw != null else _yaw
	_target_yaw = base + dir * PI / 4


func _screen_to_ray(p: Vector2) -> Array:
	var vp_p := p / size * Vector2(LOW_RES)
	return [_cam.project_ray_origin(vp_p), _cam.project_ray_normal(vp_p)]


func _click(p: Vector2) -> void:
	var ray := _screen_to_ray(p)
	var o: Vector3 = ray[0]
	var d: Vector3 = ray[1]
	# a painting first
	var best := {}
	var best_t := INF
	for pt in _paintings:
		var n: Vector3 = pt.normal
		var denom := d.dot(n)
		if absf(denom) < 1e-4:
			continue
		var t: float = (pt.center - o).dot(n) / denom
		if t <= 0 or t >= best_t:
			continue
		var hit := o + d * t
		var local: Vector3 = hit - pt.center
		if absf(local.y) < pt.size.y / 2 + 0.1 and absf(local.z) < pt.size.x / 2 + 0.1:
			best = pt
			best_t = t
	if not best.is_empty():
		_approach(best)
		return
	# otherwise the floor
	if d.y < -0.01:
		var t := -o.y / d.y
		_target = _clamp_to_room(o + d * t)
		var to: Vector3 = _target - _pos
		if to.length() > 0.2:
			_target_yaw = atan2(-to.x, -to.z)


func _approach(pt: Dictionary) -> void:
	var stand: Vector3 = pt.center + pt.normal * 2.2
	stand.y = 0
	_target = _clamp_to_room(stand)
	_target_yaw = atan2(pt.normal.x, pt.normal.z)  # face the wall
	while _target != null or _target_yaw != null:
		await get_tree().process_frame
	_open_detail(pt)


func _open_detail(pt: Dictionary) -> void:
	var tex: Texture2D = load(DIR + "paintings/%s.jpg" % pt.detail)
	var pic: TextureRect = _detail.get_node("Painting")
	pic.texture = tex
	_layout_detail(float(tex.get_width()) / tex.get_height())
	_open = pt.id
	var t := create_tween()
	t.tween_property(_detail, "modulate:a", 1.0, 0.5)


func _close_detail() -> void:
	var t := create_tween()
	t.tween_property(_detail, "modulate:a", 0.0, 0.35)
	await t.finished
	_open = ""


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		accept_event()
		if _open != "":
			_close_detail()
		else:
			_click(event.position)


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or event.echo:
		return
	var name := ""
	match event.keycode:
		KEY_UP, KEY_W: name = "up"
		KEY_DOWN, KEY_S: name = "down"
		KEY_LEFT, KEY_A: name = "left"
		KEY_RIGHT, KEY_D: name = "right"
		KEY_ESCAPE:
			if event.pressed and _open != "":
				_close_detail()
			get_viewport().set_input_as_handled()
			return
	if name == "":
		return
	get_viewport().set_input_as_handled()
	if event.pressed:
		if _open != "":
			return
		_held[name] = 0.0
		match name:
			"up": _step(1.0)
			"down": _step(-1.0)
			"left": _turn(1.0)
			"right": _turn(-1.0)
	else:
		_held.erase(name)
