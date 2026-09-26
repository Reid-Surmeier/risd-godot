## PROTOTYPE 4, throwaway (2026-09-26, map #116): the RISD Grand Gallery with all 23 paintings modelled in place.
## Order, canvas sizes and heights: docs/research/grand-gallery-hang.md (branch research/grand-gallery-hang).
## Paintings: RISD's own photograph (Wikimedia Commons, CC0) as the canvas inside a Muse frame built as a 3D
## nine-slice (painting_asset.gd); the angel is its keyed Muse cut-out. Surfaces and the two views through the
## doorways are Muse passes (image-work/grand-gallery-v4). Video pixels are measurement only.
## Keys: Up/W step (hold to walk), Down/S step back, Left/A Right/D turn (hold to keep turning). Click the floor
## to walk there, a painting to walk up to it and open it. In the detail view: scroll or pinch to zoom, drag to
## pan, double-click to zoom in, Esc or a click outside the painting to close.
extends Control

const PaintingAsset := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const DIR := "res://modules/shell/prototype/gallery_walk4/"
const LOW_RES := Vector2i(480, 320)
const L := 26.0  # room length, arch end (z = 0) to far end (z = -L)
const W := 11.5  # room width, west wall x = -W/2
const H := 6.0  # wall height to the cornice
const VAULT_RISE := 3.0
const SKY_W := 4.2
const WALL_COL := Color("#535b63")
const WHITE := Color("#e9e6de")
const DOOR := Vector2(1.7, 3.0)
const CASING := 0.28
const REVEAL := 0.6
const BENCHES := [-9.0, -17.0]
const WALK_MPS := 1.2
const STEP_M := 1.0
const TURN_HELD_DPS := 40.0
const TURN_TAP_DPS := 75.0
const HOLD_S := 0.25
const KID_H := 1.05

var _vp: SubViewport
var _cam: Camera3D
var _kid: Sprite3D
var _shadow: MeshInstance3D
var _kid_frames: Array[Texture2D] = []
var _kid_t := 0.0
var _pos := Vector3(0, 0, -4.2)
var _yaw := 0.0
var _target = null
var _target_yaw = null
var _paintings: Array = []  # {tag, rec, node, center, normal, corners(world)}
var _held := {}
var _open := {}
var _detail: Control
var _zoom_root: Control
var _zoom := 1.0
var _drag_from = null
var _dragged := false


func _ready() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := SubViewportContainer.new()
	box.stretch = true
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	box.material = _crt()
	add_child(box)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.msaa_3d = Viewport.MSAA_DISABLED
	box.add_child(_vp)
	resized.connect(func() -> void: box.stretch_shrink = maxi(1, roundi(size.x / LOW_RES.x)))  # render at ~480 px wide
	_build_room()
	_build_paintings()
	_build_kid()
	_cam = Camera3D.new()
	_cam.fov = 58.0
	_cam.near = 0.05
	_vp.add_child(_cam)
	_build_detail()
	_update_camera(1.0)


func _crt() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec4 c = texture(TEXTURE, UV);\n\tc.rgb *= mix(1.0, 0.93, mod(floor(UV.y / TEXTURE_PIXEL_SIZE.y), 2.0));\n\tCOLOR = c;\n}\n"
	var m := ShaderMaterial.new()
	m.shader = sh
	return m


func _mat(tex: Texture2D, col := Color.WHITE, uv := Vector2.ONE) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.albedo_color = col
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if tex:
		m.albedo_texture = tex
		m.uv1_scale = Vector3(uv.x, uv.y, 1)
	return m


# A flat rectangle: centre, width along `right`, height along `up`, facing `normal`.
func _rect(c: Vector3, size: Vector2, right: Vector3, up: Vector3, m: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := right * size.x / 2.0
	var u := up * size.y / 2.0
	var p := [c - r - u, c + r - u, c + r + u, c - r + u]
	var uv := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
	for i in [0, 1, 2, 0, 2, 3]:
		st.set_uv(uv[i])
		st.add_vertex(p[i])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = m
	_vp.add_child(mi)
	return mi


func _box(c: Vector3, size: Vector3, col: Color) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = c
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 1.0
	mi.material_override = m
	_vp.add_child(mi)


func _wall_mat(w: float, h: float) -> StandardMaterial3D:
	return _mat(load(DIR + "textures/wall.png"), Color.WHITE, Vector2(w / 1.5, h / 1.5))


func _build_room() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#20242a")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.85, 0.88)
	env.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = env
	_vp.add_child(we)
	var sun := DirectionalLight3D.new()  # the skylight, for the benches' and trims' shading
	sun.rotation = Vector3(deg_to_rad(-70), deg_to_rad(20), 0)
	sun.light_energy = 0.5
	_vp.add_child(sun)
	var X := W / 2.0
	# floor
	_rect(Vector3(0, 0, -L / 2), Vector2(W, L), Vector3.RIGHT, Vector3.FORWARD, _mat(load(DIR + "textures/floor.png"), Color.WHITE, Vector2(W / 1.3, L / 1.3)))
	# long walls
	_rect(Vector3(-X, H / 2, -L / 2), Vector2(L, H), Vector3.FORWARD, Vector3.UP, _wall_mat(L, H))
	_rect(Vector3(X, H / 2, -L / 2), Vector2(L, H), Vector3.BACK, Vector3.UP, _wall_mat(L, H))
	# end walls, each around its doorway
	for end in [{"z": 0.0, "right": Vector3.LEFT, "card": "door-arch"}, {"z": -L, "right": Vector3.RIGHT, "card": "door-far"}]:
		_end_wall(end.z, end.right, end.card)
	# skirting and cornice along the long walls
	for s in [-1.0, 1.0]:
		_box(Vector3(s * (X - 0.015), 0.09, -L / 2), Vector3(0.03, 0.18, L), WHITE)
		_box(Vector3(s * (X - 0.12), H - 0.17, -L / 2), Vector3(0.24, 0.34, L), WHITE)
	for z in [-0.12, -L + 0.12]:
		_box(Vector3(0, H - 0.17, z), Vector3(W, 0.34, 0.24), WHITE)
	# barrel vault (low-poly), end lunettes, skylight
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs := 10
	var vault := Color("#dcd5c4")
	for i in segs:
		var a0 := PI * i / segs
		var a1 := PI * (i + 1) / segs
		var p0 := Vector3(-cos(a0) * X, H + sin(a0) * VAULT_RISE, 0)
		var p1 := Vector3(-cos(a1) * X, H + sin(a1) * VAULT_RISE, 0)
		var shade := 0.8 + 0.2 * sin((a0 + a1) / 2.0)
		st.set_color(vault * Color(shade, shade, shade))
		for v in [p0, p1, p1 + Vector3(0, 0, -L), p0, p1 + Vector3(0, 0, -L), p0 + Vector3(0, 0, -L)]:
			st.add_vertex(v)
		st.set_color(vault * Color(0.88, 0.88, 0.88))
		for z in [0.0, -L]:
			for v in [Vector3(0, H, z), p0 + Vector3(0, 0, z), p1 + Vector3(0, 0, z)]:
				st.add_vertex(v)
	var vm := StandardMaterial3D.new()
	vm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	vm.vertex_color_use_as_albedo = true
	vm.cull_mode = BaseMaterial3D.CULL_DISABLED
	var vmi := MeshInstance3D.new()
	vmi.mesh = st.commit()
	vmi.material_override = vm
	_vp.add_child(vmi)
	var sky_y := H + VAULT_RISE * sqrt(maxf(0.0, 1.0 - pow(SKY_W / 2.0 / X, 2))) - 0.02
	_rect(Vector3(0, sky_y, -L / 2), Vector2(SKY_W, L - 1.0), Vector3.RIGHT, Vector3.BACK, _mat(load(DIR + "textures/skylight.png"), Color(1.1, 1.1, 1.1), Vector2(1, (L - 1.0) / SKY_W)))
	# benches down the centre
	for bz in BENCHES:
		_box(Vector3(0, 0.3, bz), Vector3(0.95, 0.18, 3.0), Color("#2b3346"))
		for lx in [-0.4, 0.4]:
			for lz in [-1.4, 1.4]:
				_box(Vector3(lx, 0.1, bz + lz), Vector3(0.05, 0.2, 0.05), Color("#1a1a1a"))


# An end wall at z with a doorway in the middle: three wall pieces, a white casing with depth, a reveal and the
# Muse view of the room beyond, glowing, with a green EXIT sign.
func _end_wall(z: float, right: Vector3, card: String) -> void:
	var X := W / 2.0
	var n := Vector3(0, 0, -1) if z == 0.0 else Vector3(0, 0, 1)  # into the room
	var dw := DOOR.x / 2.0
	var side := X - dw
	_rect(Vector3(-(dw + side / 2) * right.x, H / 2, z), Vector2(side, H), right, Vector3.UP, _wall_mat(side, H))
	_rect(Vector3((dw + side / 2) * right.x, H / 2, z), Vector2(side, H), right, Vector3.UP, _wall_mat(side, H))
	_rect(Vector3(0, (H + DOOR.y) / 2, z), Vector2(DOOR.x, H - DOOR.y), right, Vector3.UP, _wall_mat(DOOR.x, H - DOOR.y))
	for s in [-1.0, 1.0]:
		_box(Vector3(s * (dw + side / 2), 0.09, z + n.z * 0.015), Vector3(side, 0.18, 0.03), WHITE)
	# casing: two jambs and a head, standing 0.1 m proud
	_box(Vector3(-(dw + CASING / 2), DOOR.y / 2 + CASING / 4, z + n.z * 0.05), Vector3(CASING, DOOR.y + CASING / 2, 0.1), WHITE)
	_box(Vector3(dw + CASING / 2, DOOR.y / 2 + CASING / 4, z + n.z * 0.05), Vector3(CASING, DOOR.y + CASING / 2, 0.1), WHITE)
	_box(Vector3(0, DOOR.y + CASING / 2, z + n.z * 0.05), Vector3(DOOR.x + CASING * 2 + 0.08, CASING, 0.12), WHITE)
	# the reveal and the view beyond
	var back := z - n.z * REVEAL
	var rev := _mat(null, Color("#cfc8b8"))
	_rect(Vector3(-dw, DOOR.y / 2, (z + back) / 2), Vector2(REVEAL, DOOR.y), Vector3(0, 0, -n.z), Vector3.UP, rev)
	_rect(Vector3(dw, DOOR.y / 2, (z + back) / 2), Vector2(REVEAL, DOOR.y), Vector3(0, 0, n.z), Vector3.UP, rev)
	_rect(Vector3(0, DOOR.y, (z + back) / 2), Vector2(DOOR.x, REVEAL), Vector3.RIGHT, Vector3(0, 0, n.z), rev)
	_rect(Vector3(0, 0.005, (z + back) / 2), Vector2(DOOR.x, REVEAL), Vector3.RIGHT, Vector3(0, 0, -n.z), _mat(load(DIR + "textures/floor.png")))
	_rect(Vector3(0, DOOR.y / 2, back), DOOR, right, Vector3.UP, _mat(load(DIR + "textures/%s.jpg" % card), Color(1.25, 1.22, 1.15)))
	var glow := _mat(null, Color(1.0, 0.97, 0.9, 0.22))
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_rect(Vector3(0, DOOR.y / 2, z + n.z * 0.02), DOOR + Vector2(0.3, 0.3), right, Vector3.UP, glow)
	_box(Vector3(0, DOOR.y + CASING + 0.14, z + n.z * 0.04), Vector3(0.34, 0.14, 0.05), Color(0.2, 1.0, 0.45))


func _hang_center(rec: Dictionary, outer_h: float) -> float:
	var s: String = rec.hang
	var nums := []
	var rx := RegEx.new()
	rx.compile("[0-9]+\\.[0-9]+")
	for m in rx.search_all(s):
		nums.append(float(m.get_string()))
	var v: float = nums[0] if nums.size() > 0 else 1.55
	if nums.size() > 1 and s.find("–") >= 0:
		v = (nums[0] + nums[1]) / 2.0
	if s.begins_with("centre"):
		return v
	return v + outer_h / 2.0  # "frame bottom" / "bottom"


func _build_paintings() -> void:
	var works: Array = JSON.parse_string(FileAccess.get_file_as_string(DIR + "works.json"))
	var by := {}
	for r in works:
		by[r.tag] = r
	var assets := {}
	for r in works:
		var node: Node3D = PaintingAsset.new()
		if r.tag == "W6":
			node.build_shaped(load(DIR + "frames/W6-shaped.png"), Vector2(r.canvas_w, r.canvas_h))
		else:
			node.build_framed(load(DIR + "frames/%s.png" % r.tag), load(DIR + "canvas/%s.jpg" % r.tag), Vector2(r.canvas_w, r.canvas_h), r.margins_px)
		assets[r.tag] = node
	var X := W / 2.0
	# long walls: even gaps, in the researched order. West runs arch end -> far end; east runs far end -> arch end.
	for wall in [{"tags": ["W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10"], "x": -X, "rot": PI / 2, "from_far": false},
			{"tags": ["E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9"], "x": X, "rot": -PI / 2, "from_far": true}]:
		var total := 0.0
		for t in wall.tags:
			total += assets[t].outer.x
		var gap: float = (L - total) / (wall.tags.size() + 1)
		var d := gap
		for t in wall.tags:
			var w: float = assets[t].outer.x
			var along := d + w / 2.0
			var z := -(L - along) if wall.from_far else -along
			_place(t, by[t], assets[t], Vector3(wall.x, 0, z), wall.rot)
			d += w + gap
	# end walls: one painting centred on each side of the door
	var mid := (DOOR.x / 2.0 + CASING + X) / 2.0
	_place("S1", by.S1, assets.S1, Vector3(mid, 0, 0), PI)  # arch end, east of the door
	_place("S2", by.S2, assets.S2, Vector3(-mid, 0, 0), PI)
	_place("N1", by.N1, assets.N1, Vector3(-mid, 0, -L), 0.0)  # far end, west of the door
	_place("N2", by.N2, assets.N2, Vector3(mid, 0, -L), 0.0)


func _place(tag: String, rec: Dictionary, node: Node3D, at: Vector3, rot: float) -> void:
	var outer: Vector2 = node.outer
	at.y = _hang_center(rec, outer.y)
	var basis := Basis(Vector3.UP, rot)
	node.transform = Transform3D(basis, at)
	_vp.add_child(node)
	var n := basis * Vector3.BACK
	var r := basis * Vector3.RIGHT
	var corners := []
	for c in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		corners.append(at + r * c.x * outer.x / 2.0 + Vector3.UP * c.y * outer.y / 2.0 + n * 0.09)
	_paintings.append({"tag": tag, "rec": rec, "center": at, "normal": n, "corners": corners, "outer": outer})


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
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.55))
	g.set_color(1, Color(0, 0, 0, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.0)
	var sm := _mat(gt)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_shadow = _rect(Vector3(0, 0.01, 0), Vector2(0.75, 0.42), Vector3.RIGHT, Vector3.FORWARD, sm)


# ---------------------------------------------------------------- the detail view

func _build_detail() -> void:
	_detail = Control.new()
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.modulate.a = 0.0
	_detail.visible = false
	_detail.clip_contents = true
	add_child(_detail)
	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(bg)
	_zoom_root = Control.new()
	_zoom_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(_zoom_root)
	var pic := TextureRect.new()
	pic.name = "Painting"
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom_root.add_child(pic)
	var frame := NinePatchRect.new()
	frame.name = "Frame"
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom_root.add_child(frame)


func _open_detail(p: Dictionary) -> void:
	var rec: Dictionary = p.rec
	var pic: TextureRect = _zoom_root.get_node("Painting")
	var frame: NinePatchRect = _zoom_root.get_node("Frame")
	var tex: Texture2D = load(DIR + "detail/%s.jpg" % p.tag)
	pic.texture = tex
	var aspect := float(tex.get_width()) / tex.get_height()
	var ph := minf(size.y * 0.74, size.x * 0.66 / aspect)
	var pw := ph * aspect
	pic.size = Vector2(pw, ph)
	pic.position = Vector2.ZERO
	frame.visible = rec.has("margins_px")
	if frame.visible:
		var m: Array = rec.margins_px
		var ft: Texture2D = load(DIR + "frames/%s.png" % p.tag)
		frame.texture = ft
		frame.patch_margin_left = m[0]
		frame.patch_margin_top = m[1]
		frame.patch_margin_right = m[2]
		frame.patch_margin_bottom = m[3]
		var k: float = ph / (ft.get_height() - m[1] - m[3])  # the frame's own band proportion
		frame.scale = Vector2(k, k)
		frame.size = Vector2(pw / k + m[0] + m[2], ph / k + m[1] + m[3])
		frame.position = -Vector2(m[0], m[1]) * k
	_zoom_root.size = Vector2(pw, ph)
	_zoom = 1.0
	_zoom_root.scale = Vector2.ONE
	_zoom_root.position = (size - Vector2(pw, ph)) / 2.0
	_open = p
	_detail.visible = true
	var t := create_tween()
	t.tween_property(_detail, "modulate:a", 1.0, 0.4)


func _close_detail() -> void:
	var t := create_tween()
	t.tween_property(_detail, "modulate:a", 0.0, 0.3)
	await t.finished
	_detail.visible = false
	_open = {}


func _zoom_at(point: Vector2, factor: float) -> void:
	var z := clampf(_zoom * factor, 1.0, 6.0)
	var f := z / _zoom
	_zoom_root.position = point + (_zoom_root.position - point) * f
	_zoom = z
	_zoom_root.scale = Vector2(z, z)
	if is_equal_approx(z, 1.0):
		_zoom_root.position = (size - _zoom_root.size) / 2.0


# ---------------------------------------------------------------- walking

func _fwd() -> Vector3:
	return Vector3(-sin(_yaw), 0, -cos(_yaw))


func _process(delta: float) -> void:
	if not _open.is_empty():
		return
	for k in _held.keys():
		_held[k] += delta
	if _held.get("left", 0.0) > HOLD_S:
		_yaw += deg_to_rad(TURN_HELD_DPS) * delta
		_target_yaw = null
	if _held.get("right", 0.0) > HOLD_S:
		_yaw -= deg_to_rad(TURN_HELD_DPS) * delta
		_target_yaw = null
	if _held.get("up", 0.0) > HOLD_S:
		_target = _clamp(_pos + _fwd() * 0.4)
	if _held.get("down", 0.0) > HOLD_S:
		_target = _clamp(_pos - _fwd() * 0.4)
	if _target_yaw != null:
		var d := wrapf(_target_yaw - _yaw, -PI, PI)
		var a := deg_to_rad(TURN_TAP_DPS) * delta
		if absf(d) <= a:
			_yaw = _target_yaw
			_target_yaw = null
		else:
			_yaw += signf(d) * a
	var moving := false
	if _target != null:
		var to: Vector3 = _target - _pos
		to.y = 0
		if to.length() < 0.03:
			_target = null
		else:
			_pos = _clamp(_pos + to.normalized() * minf(to.length(), WALK_MPS * delta))
			moving = true
	if moving and _kid_frames.size() > 1:
		_kid_t += delta
		_kid.texture = _kid_frames[int(_kid_t * 10.0) % _kid_frames.size()]
	elif not _kid_frames.is_empty():
		_kid.texture = _kid_frames[0]
	_update_camera(minf(1.0, delta * 5.0))
	_update_hover()


# Inside the room, clear of the walls and the benches.
func _clamp(p: Vector3) -> Vector3:
	var m := 0.55
	p = Vector3(clampf(p.x, -W / 2 + m, W / 2 - m), 0, clampf(p.z, -L + m, -m))
	for bz in BENCHES:
		var hx := 0.48 + 0.3
		var hz := 1.5 + 0.3
		var dx := p.x
		var dz: float = p.z - bz
		if absf(dx) < hx and absf(dz) < hz:
			if hx - absf(dx) < hz - absf(dz):
				p.x = signf(dx if dx != 0.0 else 1.0) * hx
			else:
				p.z = bz + signf(dz if dz != 0.0 else 1.0) * hz
	return p


# The camera follows behind the kid but never leaves the room: the line from the kid's head to where the camera
# wants to be is cut where it would cross a wall.
func _update_camera(k: float) -> void:
	_kid.position = _pos
	_shadow.position = _pos + Vector3(0, 0.01, 0)
	var head := _pos + Vector3(0, 1.3, 0)
	var want := _pos - _fwd() * 3.1 + Vector3(0, 1.95, 0)
	var d := want - head
	var t := 1.0
	var m := 0.25
	for axis in [0, 2]:
		var lo: float = -W / 2 + m if axis == 0 else -L + m
		var hi: float = W / 2 - m if axis == 0 else -m
		if d[axis] > 0.0001:
			t = minf(t, (hi - head[axis]) / d[axis])
		elif d[axis] < -0.0001:
			t = minf(t, (lo - head[axis]) / d[axis])
	t = clampf(t, 0.0, 1.0)
	want = head + d * t + Vector3(0, (1.0 - t) * 0.9, 0)  # blocked by a wall: rise over the kid instead
	_cam.position = _cam.position.lerp(want, k) if k < 1.0 else want
	_cam.look_at(_pos + _fwd() * 4.0 + Vector3(0, 1.1, 0))


func _step(dir: float) -> void:
	_target = _clamp((_target if _target != null else _pos) + _fwd() * STEP_M * dir)


func _turn(dir: float) -> void:
	_target_yaw = (_target_yaw if _target_yaw != null else _yaw) + dir * PI / 4


# ---------------------------------------------------------------- picking

func _to_screen(p: Vector3) -> Vector2:
	return _cam.unproject_position(p) / Vector2(_vp.size) * size


# The painting under the pointer: its on-screen outline grown by a margin; the nearest wins.
func _painting_at(pt: Vector2) -> Dictionary:
	var best := {}
	var best_d := INF
	for p in _paintings:
		if _cam.is_position_behind(p.center):
			continue
		var poly := PackedVector2Array()
		for c in p.corners:
			poly.append(_to_screen(c))
		var cen := (poly[0] + poly[2]) / 2.0
		var grown := PackedVector2Array()
		for q in poly:
			grown.append(q + (q - cen).normalized() * 14.0)
		if not Geometry2D.is_point_in_polygon(pt, grown):
			continue
		var dist: float = _cam.global_position.distance_to(p.center)
		if dist < best_d:
			best_d = dist
			best = p
	return best


func _update_hover() -> void:
	var over := not _painting_at(get_local_mouse_position()).is_empty()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if over else Control.CURSOR_ARROW


func _click(pt: Vector2) -> void:
	var p := _painting_at(pt)
	if not p.is_empty():
		_approach(p)
		return
	var vp_pt := pt / size * Vector2(_vp.size)
	var o := _cam.project_ray_origin(vp_pt)
	var d := _cam.project_ray_normal(vp_pt)
	if d.y < -0.01:
		_target = _clamp(o + d * (-o.y / d.y))
		var to: Vector3 = _target - _pos
		if to.length() > 0.2:
			_target_yaw = atan2(-to.x, -to.z)


func _approach(p: Dictionary) -> void:
	var stand: Vector3 = p.center + p.normal * clampf(p.outer.y * 1.1, 2.0, 3.5)
	stand.y = 0
	_target = _clamp(stand)
	_target_yaw = atan2(p.normal.x, p.normal.z)
	while _target != null or _target_yaw != null:
		await get_tree().process_frame
		if not _open.is_empty():
			return
	_open_detail(p)


# ---------------------------------------------------------------- input

func _gui_input(event: InputEvent) -> void:
	if not _open.is_empty():
		_detail_input(event)
		accept_event()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		accept_event()
		_click(event.position)


func _detail_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.15)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				_zoom_at(event.position, 3.0 if _zoom < 2.0 else 1.0 / _zoom)
				_drag_from = null
			elif event.pressed:
				_drag_from = event.position
				_dragged = false
			else:
				var inside := Rect2(_zoom_root.position, _zoom_root.size * _zoom).has_point(event.position)
				if not _dragged and not inside:
					_close_detail()
				_drag_from = null
	elif event is InputEventMouseMotion and _drag_from != null and _zoom > 1.0:
		_zoom_root.position += event.relative
		_dragged = _dragged or event.relative.length() > 1.0
	elif event is InputEventMagnifyGesture:
		_zoom_at(event.position, event.factor)
	elif event is InputEventPanGesture:
		_zoom_root.position -= event.delta * 8.0


func _input(event: InputEvent) -> void:  # Esc closes the detail view before anything else can take the key
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and not _open.is_empty() and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		_close_detail()


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or event.echo:
		return
	var key := ""
	match event.keycode:
		KEY_UP, KEY_W: key = "up"
		KEY_DOWN, KEY_S: key = "down"
		KEY_LEFT, KEY_A: key = "left"
		KEY_RIGHT, KEY_D: key = "right"
		KEY_ESCAPE:
			if event.pressed and not _open.is_empty():
				_close_detail()
			get_viewport().set_input_as_handled()
			return
		KEY_EQUAL, KEY_PLUS, KEY_KP_ADD:
			if event.pressed and not _open.is_empty():
				_zoom_at(size / 2.0, 1.25)
			return
		KEY_MINUS, KEY_KP_SUBTRACT:
			if event.pressed and not _open.is_empty():
				_zoom_at(size / 2.0, 0.8)
			return
	if key == "":
		return
	get_viewport().set_input_as_handled()
	if not event.pressed:
		_held.erase(key)
		return
	if not _open.is_empty():
		return
	_held[key] = 0.0
	match key:
		"up": _step(1.0)
		"down": _step(-1.0)
		"left": _turn(1.0)
		"right": _turn(-1.0)
