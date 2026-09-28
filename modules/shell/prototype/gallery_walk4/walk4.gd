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
const L := 26.3  # room length, arch end (z = 0) to far end (z = -L): paintings + measured gaps (see _build_paintings)
const W := 10.0  # room width, west wall x = -W/2 (the arch-end wall in the Jan 2026 photo)
const H := 6.0  # wall height to the cornice
const VAULT_RISE := 3.0
const SKY_W := 4.2
const WHITE := Color("#e9e6de")
const CASING := 0.28
const GAP := 0.75  # default gap between frames; measured gaps in gaps.json
const PLANK := Vector2(0.84, 0.18)
# The two doorways differ: the arch door (to the medieval gallery) has a cornice head and a shallow reveal onto
# the wide lit room; the far door has a plain casing and a deep vestibule with a second door at its end.
const DOORS := {
	"arch": {"z": 0.0, "size": Vector2(1.9, 3.1), "reveal": 0.45, "card": "door-arch", "cornice": true, "vestibule": false},
	"far": {"z": -L, "size": Vector2(1.9, 2.8), "reveal": 2.6, "card": "door-far", "cornice": false, "vestibule": true},
}
const BENCHES := [-9.0, -17.0]
const BENCH_CLEAR := Vector2(0.78, 1.8)  # the kid's clearance round a bench (half-size x, z): collision and route planning share it
const WALK_MPS := 1.2
const STEP_M := 1.0
const TURN_HELD_DPS := 40.0
const TURN_TAP_DPS := 75.0
const HOLD_S := 0.25
const KID_H := 1.75

var _vp: SubViewport
# PROTOTYPE #132: fixed dollhouse, lower gallery view, and original camera.
var view_mode := 0
var view_yaw := PI
var _view_turn_remaining := 0.0
var _orbit_from = null
var _orbit_dragged := false
var _space := "gallery"  # arch/far identify which gallery doorway the white test room returns to
var _entrance_active := false
var _entrance_waiting := false
var _motion_heading := Vector3.FORWARD
var _portal_flash: ColorRect
var _view_panel: PanelContainer
var _view_bar: HBoxContainer
var _view_label: Label
var _velocity := Vector3.ZERO
var _source_meshes: Array[Node] = []
var _baked_room: Node3D
var _white_capture: LightmapGI
var _baked_lighting := true
var _lighting_choice: CheckButton
var _cam: Camera3D
var _kid: Node3D
var _rigged_visitor := true
var _generated_visitor := true
var _shadow: MeshInstance3D
var _sole_shadows: Array[MeshInstance3D] = []
var _kid_frames: Array[Texture2D] = []
var _kid_t := 0.0
var _pos := Vector3(-2.6, 0, -8.0)
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
var _path: Array = []  # waypoints still to walk before _target
var _action := 0  # bumped by every new action; a pending approach whose number is stale gives up
var _stall_t := 0.0
var _last_pos := Vector3.ZERO
# Sounds: Animal Crossing: Wild World's own (sounds/SOURCES.md)
var _sfx := {}
var _step_i := 0
var _hover_tag := ""
# First 16 held frames: visible alternate contacts at 0 and 8, reviewed in bake/README.
const CONTACT_FRAMES := [0, 8]
const WALK_FRAMES := 16


func _ready() -> void:
	add_to_group("soft_render_view")
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := SubViewportContainer.new()
	box.stretch = true
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	box.material = _post()
	add_child(box)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.msaa_3d = Viewport.MSAA_2X  # steadies polygon edges at the low resolution; all light is baked, so this is cheap
	box.add_child(_vp)
	resized.connect(func() -> void: box.stretch_shrink = maxi(1, roundi(size.x / LOW_RES.x)))  # render at ~LOW_RES wide
	_build_room()
	_build_paintings()
	_partition_surfaces()
	_merge_static()
	_source_meshes = _vp.find_children("*", "MeshInstance3D", true, false)
	_build_test_room()
	_build_kid()
	_cam = Camera3D.new()
	_cam.fov = 58.0
	_cam.near = 0.05
	_vp.add_child(_cam)
	_build_detail()
	_build_sounds()
	_build_view_controls()
	_pos = Vector3(0, 0, -0.35)
	_walk_to(Vector3(0, 0, -2.6))
	_entrance_active = true
	_entrance_waiting = true
	_motion_heading = (_target - _pos).normalized()
	_kid.position = _pos
	if _generated_visitor:
		_kid.pose(0.0, false, 0.0, _motion_heading, view_yaw if view_mode != 2 else _yaw)
	_update_camera(1.0)
	if OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa-perf')"):
		add_child(load(DIR + "performance_probe.gd").new())
	if OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).has('render_qa')"):
		add_child(load(DIR + "render_diagnostics.gd").new())


# GameCube RGB6 quantization: subtle 2x2 ordering at rendered texels, no time/noise.
# Formula: Dolphin PixelShaderGen, documented in research/animal-crossing-look.
func _post() -> ShaderMaterial:
	var render_mode = JavaScriptBridge.eval("new URLSearchParams(location.search).get('final_render')") if OS.has_feature("web") else null
	if render_mode != "original":
		var finish := ShaderMaterial.new()
		finish.shader = load(DIR + "gamecube.gdshader")
		# Opt-in diagnostic modes keep viewport/camera/shell geometry identical.
		if render_mode == "copy-none":
			finish.set_shader_parameter("copy_filter", 0.0)
		elif render_mode == "copy-full":
			finish.set_shader_parameter("copy_filter", 1.0)
		elif render_mode == "rgb6-plain":
			finish.set_shader_parameter("quantization_mode", 1)
		elif render_mode == "bypass":
			finish.set_shader_parameter("quantization_mode", 0)
			finish.set_shader_parameter("copy_filter", 0.0)
		return finish
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	ivec2 px = ivec2(floor(UV / TEXTURE_PIXEL_SIZE));
	float d = float(((px.x ^ px.y) & 1) * 2 + (px.y & 1));
	vec3 v = floor(c.rgb * 255.0 + 0.5);
	v = v - floor(v / 64.0) + d;
	COLOR = vec4(clamp(floor(v / 4.0) / 63.0, 0.0, 1.0), c.a);
}
"""
	var m := ShaderMaterial.new()
	m.shader = sh
	return m


static var _ps1_shader: Shader
static var _soft_rect: ImageTexture
static var _pool_tex: ImageTexture


func _pool_mat() -> StandardMaterial3D:
	if _pool_tex == null:
		var n := 64
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				# a soft cone from the lamp above: brightest just above the picture's centre, every edge of the
				# quad already at zero so no line shows where it ends
				var u := (x + 0.5) / n * 2.0 - 1.0
				var v := (y + 0.5) / n * 2.0 - 1.0
				var d := Vector2(u, (v + 0.15) / 1.15).length()
				var a := pow(clampf(1.0 - d, 0.0, 1.0), 2.2)
				a *= smoothstep(1.0, 0.7, absf(u)) * smoothstep(1.0, 0.7, absf(v))
				img.set_pixel(x, y, Color(1, 1, 1, a))
		_pool_tex = ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = _pool_tex
	m.albedo_color = Color(0.32, 0.24, 0.12)
	m.render_priority = -1
	return m


# A soft dark rectangle (its edges fade over a fifth of each side): the baked shadow under frames and benches.
func _shadow_mat(strength: float) -> StandardMaterial3D:
	if _soft_rect == null:
		var n := 64
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d := minf(minf(x, n - 1 - x), minf(y, n - 1 - y)) / (n * 0.2)
				var a := smoothstep(0.0, 1.0, clampf(d, 0.0, 1.0))
				img.set_pixel(x, y, Color(0, 0, 0, a))
		_soft_rect = ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = _soft_rect
	m.albedo_color = Color(0.05, 0.06, 0.09, strength)
	m.render_priority = -1
	return m


# A room material: the PS1 surface shader, lit, optionally textured, with baked occlusion in vertex colour.
static func ps(tex: Texture2D, tint := Color.WHITE, uv := Vector2.ONE, vcol := false, glow := 0.0, cut := 0.0) -> ShaderMaterial:
	if _ps1_shader == null:
		_ps1_shader = load("res://modules/shell/prototype/gallery_walk4/ps1.gdshader")
	var m := ShaderMaterial.new()
	m.shader = _ps1_shader
	m.set_shader_parameter("use_texture", tex != null)
	if tex:
		m.set_shader_parameter("albedo", tex)
	m.set_shader_parameter("tint", tint)
	m.set_shader_parameter("uv_scale", uv)
	m.set_shader_parameter("use_vertex_color", vcol)
	m.set_shader_parameter("glow", glow)
	m.set_shader_parameter("alpha_cut", cut)
	return m


# Baked occlusion: darker where a surface meets the floor, the cornice, another wall or a bench.
func _ao(p: Vector3, vertical: bool) -> float:
	var t := func(d: float, s: float, k: float) -> float: return 1.0 - k * exp(-maxf(d, 0.0) / s)
	var ao := 1.0
	for d in [p.x + W / 2.0, W / 2.0 - p.x, -p.z, p.z + L]:
		if d > 0.03:
			ao *= t.call(d, 0.55, 0.3)
	if vertical and p.y > 0.02:
		ao *= t.call(p.y, 0.45, 0.32)
	if vertical and p.y < H - 0.02:
		ao *= t.call(H - p.y, 0.6, 0.18)
	if not vertical:
		for bz in BENCHES:
			var dx := maxf(absf(p.x) - 0.48, 0.0)
			var dz := maxf(absf(p.z - bz) - 1.5, 0.0)
			ao *= t.call(Vector2(dx, dz).length(), 0.35, 0.45)
		# the skylight's pool: brighter down the middle, falling off toward the walls and the ends, with the soft
		# lighter/darker patches of daylight on satin oak
		var pool := 0.74 + 0.36 * exp(-pow(p.x / 2.7, 2.0))
		pool *= 0.9 + 0.1 * smoothstep(0.0, 3.0, minf(-p.z, p.z + L))
		pool *= 1.0 + 0.06 * sin(p.z * 0.9 + 1.3) * cos(p.x * 1.1)
		ao *= pool
	else:
		ao *= 0.86 + 0.14 * smoothstep(0.0, H, p.y)  # walls: lighter toward the skylight
	return ao


# A subdivided flat panel from corner c along u and v (cells about `cell` metres), occlusion in its vertex
# colours, UVs in metres times uv_per_m. layer: which skylight lights it.
func _panel(c: Vector3, u: Vector3, v: Vector3, m: Material, cell := 0.5, layer := 1, ao := Callable()) -> MeshInstance3D:
	var nu := maxi(1, ceili(u.length() / cell))
	var nv := maxi(1, ceili(v.length() / cell))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := u.cross(v).normalized()
	var vertical := absf(n.y) < 0.5
	for j in nv:
		for i in nu:
			var q := [Vector2(i, j), Vector2(i + 1, j), Vector2(i + 1, j + 1), Vector2(i, j + 1)]
			for k in [0, 1, 2, 0, 2, 3]:
				var f := Vector2(q[k].x / nu, q[k].y / nv)
				var p := c + u * f.x + v * f.y
				var o: float = ao.call(p) if ao.is_valid() else _ao(p, vertical)
				st.set_color(Color(o, o, o))
				st.set_normal(n)
				st.set_uv(Vector2(f.x * u.length(), (1.0 - f.y) * v.length()))
				st.add_vertex(p)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = m
	mi.layers = layer
	_vp.add_child(mi)
	return mi


func _box(c: Vector3, size: Vector3, col: Color, layer := 1, m: Material = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = c
	mi.material_override = m if m else ps(null, col)
	mi.layers = layer
	_vp.add_child(mi)
	return mi


func _wall_ps(extra := Color.WHITE) -> ShaderMaterial:
	# Broad pigment patches, one repeat per four metres; no fine grain to crawl.
	return ps(load(DIR + "textures/wall-muse.webp"), extra, Vector2(0.25, 0.25), true)


const LAYER_WEST := 2
const LAYER_EAST := 4
const LAYER_UNLIT := 8


func _build_room() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#20242a")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#dde1e7")
	env.ambient_light_energy = 0.0  # LightmapGI supplies the baked illumination
	var we := WorldEnvironment.new()
	we.environment = env
	_vp.add_child(we)
	var X := W / 2.0
	# (no base plane under the planks: 3 mm below them it z-fought through at a distance)
	_build_floor()
	# long walls, subdivided so the occlusion and the affine texturing hold
	_panel(Vector3(-X, 0, 0), Vector3(0, 0, -L), Vector3(0, H, 0), _wall_ps(), 0.5, LAYER_WEST)
	_panel(Vector3(X, 0, -L), Vector3(0, 0, L), Vector3(0, H, 0), _wall_ps(), 0.5, LAYER_EAST)
	_arch_end()
	_far_end()
	# skirting and cornice
	var white := ps(null, WHITE)
	for s in [-1.0, 1.0]:
		_box(Vector3(s * (X - 0.04), 0.12, -L / 2), Vector3(0.08, 0.24, L), WHITE, 1, white)
		_box(Vector3(s * (X - 0.06), 0.255, -L / 2), Vector3(0.12, 0.05, L), WHITE, 1, white)
		_box(Vector3(s * (X - 0.12), H - 0.17, -L / 2), Vector3(0.24, 0.34, L), WHITE, 1, white)
		_box(Vector3(s * (X - 0.05), H - 0.42, -L / 2), Vector3(0.1, 0.16, L), WHITE, 1, white)
		# Sloped plaster fascia joins the two cornice steps; its underside bakes separately.
		_panel(Vector3(s * (X - 0.1), H - 0.50, -L if s > 0 else 0.0), Vector3(0, 0, L * s), Vector3(-s * 0.14, 0.18, 0), white)
	for z in [-0.12, -L + 0.12]:
		_box(Vector3(0, H - 0.17, z), Vector3(W, 0.34, 0.24), WHITE, 1, white)
	# barrel vault from the cornice, end lunettes, and the long skylight curving with it, lamps along its edges
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var gl := SurfaceTool.new()
	gl.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs := 36
	var vault := Color("#e2dccd")
	var arc := 0.0
	for i in segs:
		var a0 := PI * i / segs
		var a1 := PI * (i + 1) / segs
		var p0 := Vector3(-cos(a0) * X, H + sin(a0) * VAULT_RISE, 0)
		var p1 := Vector3(-cos(a1) * X, H + sin(a1) * VAULT_RISE, 0)
		var seg_len := p0.distance_to(p1)
		var glass := absf((p0.x + p1.x) / 2.0) < SKY_W / 2.0
		var z0 := -0.9 if glass else 0.0
		var z1 := -L + 0.9 if glass else -L
		if glass:  # the glazing: its own strip, its grid following the curve
			var u0 := arc / 0.7
			var u1 := (arc + seg_len) / 0.7
			var q := [p0 + Vector3(0, 0, z0), p1 + Vector3(0, 0, z0), p1 + Vector3(0, 0, z1), p0 + Vector3(0, 0, z1)]
			var qu := [Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, (z0 - z1) / 0.7), Vector2(u0, (z0 - z1) / 0.7)]
			for k in [0, 1, 2, 0, 2, 3]:
				gl.set_uv(qu[k])
				gl.add_vertex(q[k])
			arc += seg_len
			# the frame of the glazing at both ends
			for zz in [0.0, -L]:
				var zi := -0.9 if zz == 0.0 else -L + 0.9
				for v in [p0 + Vector3(0, 0, zz), p1 + Vector3(0, 0, zz), p1 + Vector3(0, 0, zi), p0 + Vector3(0, 0, zz), p1 + Vector3(0, 0, zi), p0 + Vector3(0, 0, zi)]:
					st.set_color(vault * Color(0.85, 0.85, 0.85))
					st.add_vertex(v)
		else:
			var up := 0.5 + 0.5 * sin((a0 + a1) / 2.0)  # the cove darkens toward the cornice, brightens toward the light
			var shade := lerpf(0.66, 1.02, up)
			st.set_color(vault * Color(shade, shade, shade))
			for v in [p0, p1, p1 + Vector3(0, 0, -L), p0, p1 + Vector3(0, 0, -L), p0 + Vector3(0, 0, -L)]:
				st.add_vertex(v)
		st.set_color(vault * Color(0.82, 0.82, 0.8))
		for z in [0.0, -L]:  # the end lunettes
			for v in [Vector3(0, H, z), p0 + Vector3(0, 0, z), p1 + Vector3(0, 0, z)]:
				st.add_vertex(v)
	var vmi := MeshInstance3D.new()
	vmi.mesh = st.commit()
	vmi.material_override = ps(null, Color.WHITE, Vector2.ONE, true)
	_vp.add_child(vmi)
	var gmi := MeshInstance3D.new()
	gmi.mesh = gl.commit()
	gmi.material_override = ps(load(DIR + "textures/skylight.png"), Color(1.08, 1.1, 1.14))
	_vp.add_child(gmi)
	# track lamps along both edges of the glazing, aimed at the walls
	var edge_y := H + VAULT_RISE * sqrt(maxf(0.0, 1.0 - pow(SKY_W / 2.0 / X, 2))) - 0.12
	var lamp := ps(null, Color("#2a2a2a"))
	var z := -1.6
	while z > -L + 1.2:
		for sx in [-1.0, 1.0]:
			var head := _box(Vector3(sx * (SKY_W / 2.0 + 0.15), edge_y, z), Vector3(0.14, 0.14, 0.2), Color.BLACK, 1, lamp)
			head.rotation.z = sx * 0.7
			_box(Vector3(sx * (SKY_W / 2.0 + 0.2), edge_y - 0.09, z), Vector3(0.1, 0.03, 0.1), Color.BLACK, 1, ps(null, Color("#ffe9b8")))
		z -= 2.2
	# benches down the centre: a tufted seat on a dark frame
	for bz in BENCHES:
		var bs := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(1.5, 3.6)
		bs.mesh = pm
		bs.material_override = _shadow_mat(0.55)
		bs.position = Vector3(0.08, 0.004, bz + 0.05)
		bs.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_vp.add_child(bs)
		_bench_cushion(bz)
		_box(Vector3(0, 0.26, bz), Vector3(0.85, 0.08, 2.9), Color("#1d2433"))
		for lx in [-0.38, 0.38]:
			for lz in [-1.38, 1.38]:
				_box(Vector3(lx, 0.11, bz + lz), Vector3(0.06, 0.22, 0.06), Color("#141414"))


# Same bench bounds, with bevelled upholstery edges that the lightmap can describe.
func _bench_cushion(z: float) -> void:
	var outline := [Vector2(-0.40, -1.5), Vector2(0.40, -1.5), Vector2(0.475, -1.425), Vector2(0.475, 1.425), Vector2(0.40, 1.5), Vector2(-0.40, 1.5), Vector2(-0.475, 1.425), Vector2(-0.475, -1.425)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []
	for height in [0.30, 0.38, 0.42]:
		var ring: Array = []
		for point in outline:
			var inset := Vector2(signf(point.x), signf(point.y)) * (0.035 if height == 0.42 else 0.0)
			ring.append(Vector3(point.x - inset.x, height, point.y - inset.y + z))
		rings.append(ring)
	for level in 2:
		for i in 8:
			var next := (i + 1) % 8
			var q := [rings[level][i], rings[level][next], rings[level + 1][next], rings[level + 1][i]]
			var normal: Vector3 = (q[3] - q[0]).cross(q[1] - q[0]).normalized()
			for corner in [0, 1, 2, 0, 2, 3]:
				st.set_normal(normal)
				st.add_vertex(q[corner])
	for level in [0, 2]:
		for i in 8:
			st.set_normal(Vector3.UP if level == 2 else Vector3.DOWN)
			var first := i if level == 2 else (i + 1) % 8
			var second := (i + 1) % 8 if level == 2 else i
			for point in [Vector3(0, 0.42 if level == 2 else 0.30, z), rings[level][first], rings[level][second]]:
				st.add_vertex(point)
	var seat := MeshInstance3D.new()
	seat.mesh = st.commit()
	seat.material_override = ps(null, Color("#2f3a52"))
	_vp.add_child(seat)


func _rect_floor() -> void:  # under the planks, never seen: only there so nothing shows through
	var m := ps(null, Color("#6b5234"))
	var f := _panel(Vector3(-W / 2, -0.003, 0), Vector3(W, 0, 0), Vector3(0, 0, -L), m, 8.0, 1, func(_p: Vector3) -> float: return 1.0)
	f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


# Herringbone oak as geometry: planks PLANK long and wide, each a random stretch of the Muse oak grain with its own
# tone and the room's occlusion, laid on the lattice (b, b), (a, -a) turned 45 degrees so the zigzag runs down the
# room. The seams are drawn by the shader from UV2 (position inside the plank), anti-aliased.
func _build_floor() -> void:
	var a := PLANK.x
	var b := PLANK.y
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1877
	var rot := Transform2D(PI / 4, Vector2(0, -L / 2))
	var reach := (L + W) * 0.75
	var n := int(reach / b)
	var m := int(reach / a) + 1
	for j in range(-m, m + 1):
		for k in range(-n, n + 1):
			var o := Vector2(k * b + j * a, k * b - j * a)
			for vert in [false, true]:
				var r := Rect2(o, Vector2(a, b)) if not vert else Rect2(o + Vector2(0, b), Vector2(b, a))
				var c := rot * r.get_center()
				if absf(c.x) > W / 2 + 0.4 or c.y > 0.4 or c.y < -L - 0.4:
					continue
				var p := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
				# One grain length per plank; vary its vertical strip without wrapping.
				var v0 := rng.randf_range(0.0, 2.0 / 3.0)
				var uv := [Vector2(0, v0), Vector2(1, v0), Vector2(1, v0 + 1.0 / 3.0), Vector2(0, v0 + 1.0 / 3.0)]
				var uv2 := [Vector2(0, 0), Vector2(a, 0), Vector2(a, b), Vector2(0, b)]
				if vert:
					uv = [uv[3], uv[0], uv[1], uv[2]]
					uv2 = [Vector2(0, b), Vector2(0, 0), Vector2(a, 0), Vector2(a, b)]
				# The source crop has narrow board-to-board variation; retain the
				# authored lattice, UVs and grain but quiet the orange stripe effect.
				var tone := rng.randf_range(0.91, 1.07)
				for i in [0, 1, 2, 0, 2, 3]:
					var q: Vector2 = rot * p[i]
					var w := Vector3(q.x, 0, q.y)
					var o2 := _ao(w, false) * tone
					st.set_color(Color(o2, o2, o2))
					st.set_normal(Vector3.UP)
					st.set_uv(uv[i])
					st.set_uv2(uv2[i])
					st.add_vertex(w)
	var mat := ps(load(DIR + "textures/oak.png"), Color.WHITE, Vector2.ONE, true)
	mat.set_shader_parameter("plank_seams", true)
	mat.set_shader_parameter("jitter", 0.0)  # herringbone has T-junctions: snapped corners would open cracks
	mat.set_shader_parameter("plank", PLANK)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_vp.add_child(mi)


# The arch end, as in the video: one white-cased door in the gallery wall; behind its plaster reveal the Romanesque
# stone portal of the medieval gallery is the same opening (its round arch shows at the top of the door), a deep
# stone tunnel, then the medieval room: blue-grey walls, herringbone floor, the crucifix lit warm.
const PORTAL_DEPTH := 1.2


func _arch_end() -> void:
	var X := W / 2.0
	var door: Dictionary = DOORS.arch
	var ds: Vector2 = door.size
	var dw := ds.x / 2.0
	var side := X - dw
	var white := ps(null, WHITE)
	_panel(Vector3(X, 0, 0), Vector3(-side, 0, 0), Vector3(0, H, 0), _wall_ps(), 0.5, 1)
	_panel(Vector3(-dw, 0, 0), Vector3(-side, 0, 0), Vector3(0, H, 0), _wall_ps(), 0.5, 1)
	_panel(Vector3(dw, ds.y, 0), Vector3(-ds.x, 0, 0), Vector3(0, H - ds.y, 0), _wall_ps(), 0.5, 1)
	for s in [-1.0, 1.0]:
		_box(Vector3(s * (dw + side / 2), 0.09, -0.015), Vector3(side, 0.18, 0.03), WHITE, 1, white)
		_box(Vector3(s * (dw + 0.17), ds.y / 2 + 0.1, -0.04), Vector3(0.3, ds.y + 0.2, 0.08), WHITE, 1, white)
		_box(Vector3(s * (dw + 0.04), ds.y / 2, -0.07), Vector3(0.08, ds.y, 0.14), WHITE, 1, white)
	_box(Vector3(0, ds.y + 0.19, -0.04), Vector3(ds.x + 0.64, 0.3, 0.08), WHITE, 1, white)
	_box(Vector3(0, ds.y + 0.36, -0.08), Vector3(ds.x + 0.8, 0.07, 0.16), WHITE, 1, white)
	_box(Vector3(0, ds.y + 0.62, -0.04), Vector3(0.34, 0.14, 0.05), Color.WHITE, 1, ps(null, Color(0.3, 1.0, 0.5)))
	# the wall's plaster reveal
	var zr := 0.45
	var rev := ps(null, Color("#dcd5c6"), Vector2.ONE, true)
	var deep := func(p: Vector3) -> float: return lerpf(0.9, 0.62, clampf(p.z / zr, 0.0, 1.0))
	_panel(Vector3(-dw, 0, 0), Vector3(0, 0, zr), Vector3(0, ds.y, 0), rev, 0.3, 1, deep)
	_panel(Vector3(dw, 0, zr), Vector3(0, 0, -zr), Vector3(0, ds.y, 0), rev, 0.3, 1, deep)
	_panel(Vector3(-dw, ds.y, zr), Vector3(ds.x, 0, 0), Vector3(0, 0, -zr), rev, 0.3, 1, deep)
	# the stone portal: a round-arched tunnel, its arch rising just past the door head
	var stone := ps(load(DIR + "textures/stone.png"), Color(1.0, 0.97, 0.92), Vector2(0.8, 0.8), true)
	var a := dw
	var spring := ds.y - a * 0.75
	var z0 := zr
	var z1 := zr + PORTAL_DEPTH
	var N := 16
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var put := func(p: Vector3, o: float) -> void:
		st.set_color(Color(o, o, o))
		st.set_uv(Vector2(p.x + p.z, p.y))
		st.add_vertex(p)
	var quad := func(q: Array, o: Array) -> void:
		for i in [0, 1, 2, 0, 2, 3]:
			put.call(q[i], o[i])
	for k in N:  # the barrel of the arch
		var t0 := PI * k / N
		var t1 := PI * (k + 1) / N
		var q0 := Vector2(-a * cos(t0), spring + a * sin(t0))
		var q1 := Vector2(-a * cos(t1), spring + a * sin(t1))
		quad.call([Vector3(q0.x, q0.y, z0), Vector3(q1.x, q1.y, z0), Vector3(q1.x, q1.y, z1), Vector3(q0.x, q0.y, z1)], [0.62, 0.62, 0.8, 0.8])
	for sx in [-1.0, 1.0]:  # the jambs
		quad.call([Vector3(sx * a, 0, z0), Vector3(sx * a, spring, z0), Vector3(sx * a, spring, z1), Vector3(sx * a, 0, z1)], [0.5, 0.66, 0.84, 0.7])
	# the stone face round the arch, seen through the door above its head
	for k in N:
		var t0 := PI * k / N
		var t1 := PI * (k + 1) / N
		var q0 := Vector2(-a * cos(t0), spring + a * sin(t0))
		var q1 := Vector2(-a * cos(t1), spring + a * sin(t1))
		quad.call([Vector3(q0.x, q0.y, z0), Vector3(q0.x, ds.y + 0.4, z0), Vector3(q1.x, ds.y + 0.4, z0), Vector3(q1.x, q1.y, z0)], [0.55, 0.5, 0.5, 0.55])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = stone
	_vp.add_child(mi)
	# the medieval gallery beyond: lit warm toward the crucifix
	var beyond := 5.0
	var zb := z1 + beyond
	var room := ps(null, Color("#56606b"), Vector2.ONE, true)
	var lit := func(p: Vector3) -> float: return lerpf(0.55, 1.05, clampf((p.z - z1) / beyond, 0.0, 1.0))
	_panel(Vector3(-3.0, 0, z1), Vector3(0, 0, beyond), Vector3(0, 5.0, 0), room, 1.0, 1, lit)
	_panel(Vector3(3.0, 0, zb), Vector3(0, 0, -beyond), Vector3(0, 5.0, 0), room, 1.0, 1, lit)
	_panel(Vector3(-3.0, 5.0, zb), Vector3(6.0, 0, 0), Vector3(0, 0, -beyond), ps(null, Color("#8c8579"), Vector2.ONE, true), 1.0, 1, lit)
	_panel(Vector3(-3.0, 0.002, z0), Vector3(6.0, 0, 0), Vector3(0, 0, beyond + PORTAL_DEPTH), ps(load(DIR + "textures/oak-muse.webp"), Color.WHITE, Vector2(1, 3), true), 1.0, 1, lit)
	var card := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(6.0, 5.0)
	card.mesh = qm
	card.material_override = ps(load(DIR + "textures/door-arch.jpg"), Color(1.08, 1.04, 0.98))
	card.position = Vector3(0, 2.5, zb - 0.01)
	card.rotation.y = PI
	_vp.add_child(card)


# The far end: a plain rectangular door with a stepped white casing, a deep cream vestibule lit from its far end,
# and the second door and bright room at its back.
func _trim_profile(origin: Vector3, across: Vector3, along: Vector3, points: Array, material: Material, depth_axis := Vector3.BACK) -> void:
	# #160 prototype: extruded section, UV1 in metres; offline bake unwraps UV2.
	for index in points.size():
		var a: Vector2 = points[index]
		var b: Vector2 = points[(index + 1) % points.size()]
		var corner := origin + across * a.x + depth_axis * a.y
		var edge := across * (b.x - a.x) + depth_axis * (b.y - a.y)
		if across.cross(along).dot(depth_axis) > 0:
			_panel(corner, edge, along, material, 0.3)
		else:
			_panel(corner, along, edge, material, 0.3)
	var triangles := Geometry2D.triangulate_polygon(PackedVector2Array(points))
	for end in [0, 1]:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for index in triangles:
			var p: Vector2 = points[index]
			st.set_normal(along.normalized() * (1 if end else -1))
			st.set_uv(p)
			st.add_vertex(origin + along * end + across * p.x + depth_axis * p.y)
		var cap := MeshInstance3D.new()
		cap.mesh = st.commit()
		cap.material_override = material
		_vp.add_child(cap)

func _door_panel(center: Vector3, material: Material) -> void:
	# One closed face and four bevels replace intersecting thin bead extrusions.
	var outline := [Vector2(-0.5, -0.425), Vector2(0.5, -0.425), Vector2(0.5, 0.425), Vector2(-0.5, 0.425)]
	var outer: Array[Vector3] = []
	var inner: Array[Vector3] = []
	for p in outline:
		outer.append(center + Vector3(p.x, p.y, 0))
		inner.append(center + Vector3(p.x - signf(p.x) * 0.055, p.y - signf(p.y) * 0.055, 0.035))
	var faces: Array = [inner]
	for i in 4:
		var next := (i + 1) % 4
		faces.append([outer[i], outer[next], inner[next], inner[i]])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in faces:
		for triangle in [[0, 2, 1], [0, 3, 2]]:
			var normal: Vector3 = (face[triangle[2]] - face[triangle[0]]).cross(face[triangle[1]] - face[triangle[0]]).normalized()
			assert(normal.z > 0, "Door-panel winding must face into the vestibule")
			for index in triangle:
				st.set_normal(normal)
				st.set_uv(Vector2(face[index].x, face[index].y))
				st.add_vertex(face[index])
	var panel := MeshInstance3D.new()
	panel.mesh = st.commit()
	panel.material_override = material
	_vp.add_child(panel)

func _far_end() -> void:
	var first_surface := _vp.get_child_count()
	var door: Dictionary = DOORS.far
	var z := -L
	var ds: Vector2 = door.size
	var X := W / 2.0
	var dw := ds.x / 2.0
	var side := X - dw
	var reference_blue := _wall_ps(Color(0.76, 0.84, 0.96))
	_panel(Vector3(-X, 0, z), Vector3(side, 0, 0), Vector3(0, H, 0), reference_blue, 0.5, 1)
	_panel(Vector3(dw, 0, z), Vector3(side, 0, 0), Vector3(0, H, 0), reference_blue, 0.5, 1)
	_panel(Vector3(-dw, ds.y, z), Vector3(ds.x, 0, 0), Vector3(0, H - ds.y, 0), reference_blue, 0.5, 1)
	var white := ps(load(DIR + "textures/ivory-trim.svg"), Color.WHITE, Vector2(0.7, 0.7), true)
	var casing := [Vector2(0, 0), Vector2(0, 0.10), Vector2(0.018, 0.125), Vector2(0.042, 0.125), Vector2(0.06, 0.105), Vector2(0.075, 0.075), Vector2(0.27, 0.075), Vector2(0.285, 0.09), Vector2(0.305, 0.09), Vector2(0.32, 0.06), Vector2(0.32, 0)]
	var skirting := [Vector2(0, 0), Vector2(0, 0.07), Vector2(0.035, 0.07), Vector2(0.05, 0.055), Vector2(0.18, 0.055), Vector2(0.20, 0.067), Vector2(0.225, 0.065), Vector2(0.24, 0.035), Vector2(0.24, 0)]
	for s in [-1.0, 1.0]:
		_trim_profile(Vector3(s * (dw + 0.36), 0, z), Vector3.UP, Vector3(s * (side - 0.36), 0, 0), skirting, white)
		_trim_profile(Vector3(s * dw, 0.26, z), Vector3(s, 0, 0), Vector3(0, ds.y - 0.26, 0), casing, white)
		var plinth := [Vector2(0, 0), Vector2(0, 0.12), Vector2(0.02, 0.14), Vector2(0.34, 0.14), Vector2(0.36, 0.12), Vector2(0.36, 0)]
		_trim_profile(Vector3(s * dw, 0, z), Vector3(s, 0, 0), Vector3(0, 0.26, 0), plinth, white)
		_panel(Vector3(s * dw, 0.26, z), Vector3(s * 0.36, 0, 0), Vector3(0, 0, 0.12), white)
	_trim_profile(Vector3(-dw - 0.32, ds.y, z), Vector3.UP, Vector3(ds.x + 0.64, 0, 0), casing, white)
	var crown := [Vector2(0, 0), Vector2(0, 0.065), Vector2(0.025, 0.09), Vector2(0.055, 0.14), Vector2(0.075, 0.15), Vector2(0.10, 0.15), Vector2(0.10, 0)]
	_trim_profile(Vector3(-dw - 0.38, ds.y + 0.32, z), Vector3.UP, Vector3(ds.x + 0.76, 0, 0), crown, white)
	# #160: a fully modeled cream vestibule, no photographic depth card.
	var depth: float = door.reveal
	var cream := ps(load(DIR + "textures/ivory-trim.svg"), Color(1.0, 0.98, 0.91), Vector2(0.65, 0.65), true)
	var lit := func(p: Vector3) -> float: return lerpf(0.55, 1.0, clampf((z - p.z) / depth, 0.0, 1.0))
	# Rear backing sits 5 cm behind the door leaf; extend the shell to meet it.
	var shell_depth := depth + 0.05
	_panel(Vector3(-dw, 0, z), Vector3(0, 0, -shell_depth), Vector3(0, ds.y, 0), cream, 0.5, 1, lit)
	_panel(Vector3(dw, 0, z - shell_depth), Vector3(0, 0, shell_depth), Vector3(0, ds.y, 0), cream, 0.5, 1, lit)
	# Inward ceiling and upward floor normals are required for the offline bake.
	_panel(Vector3(-dw, ds.y, z - shell_depth), Vector3(ds.x, 0, 0), Vector3(0, 0, shell_depth), cream, 0.5, 1, lit)
	var threshold := ps(load(DIR + "textures/oak.png"), Color(0.83, 0.79, 0.71), Vector2(0.52, 1.0), true)
	var threshold_section := [Vector2(-0.12, 0), Vector2(-0.10, 0.012), Vector2(0.10, 0.012), Vector2(0.12, 0), Vector2(0.12, -0.015), Vector2(-0.12, -0.015)]
	_trim_profile(Vector3(-dw, 0, z), Vector3.BACK, Vector3(ds.x, 0, 0), threshold_section, threshold, Vector3.UP)
	for row in 13:
		var timber := ps(load(DIR + "textures/oak.png"), Color(1.05, 1.03, 0.97) * (0.98 if row % 3 == 0 else 1.0), Vector2(0.52, 1.0), true)
		_panel(Vector3(-dw, 0.003, z - 0.12 - row * (shell_depth - 0.12) / 13.0), Vector3(ds.x, 0, 0), Vector3(0, 0, -(shell_depth - 0.12) / 13.0), timber, 0.4)
	for s in [-1.0, 1.0]:
		_trim_profile(Vector3(s * dw, 0, z), Vector3.UP, Vector3(0, 0, -depth), skirting, white, Vector3(-s, 0, 0))
	# The reference's second pale doorway is real relief at the rear, not a picture.
	var rear := z - depth
	_panel(Vector3(-dw, 0, rear - 0.05), Vector3(ds.x, 0, 0), Vector3(0, ds.y, 0), cream)
	for s in [-1.0, 1.0]:
		_trim_profile(Vector3(s * 0.62, 0, rear), Vector3(s * 0.55, 0, 0), Vector3(0, 2.35, 0), casing, white)
	_trim_profile(Vector3(-0.80, 2.35, rear), Vector3(0, 0.55, 0), Vector3(1.6, 0, 0), casing, white)
	_panel(Vector3(-0.62, 0, rear - 0.02), Vector3(1.24, 0, 0), Vector3(0, 2.35, 0), white)
	for panel_y in [0.68, 1.68]:
		_door_panel(Vector3(0, panel_y, rear - 0.021), white)
	for sign_z in [z + 0.041, rear + 0.03]:
		var sign_y := ds.y + 0.48 if sign_z > z else 2.65
		_panel(Vector3(-0.17, sign_y, sign_z), Vector3(0.34, 0, 0), Vector3(0, 0.15, 0), ps(load(DIR + "textures/exit-sign.svg"), Color.WHITE, Vector2(1.0 / 0.34, 1.0 / 0.15)))
	# The inherited panel builder emits reverse winding against its normals.
	# Align this slice's triangle faces before UV2/bake; leave other assets alone.
	for child_index in range(first_surface, _vp.get_child_count()):
		var instance = _vp.get_child(child_index)
		if not instance is MeshInstance3D:
			continue
		var aligned := ArrayMesh.new()
		for surface in instance.mesh.get_surface_count():
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			if indices.is_empty():
				indices = PackedInt32Array(range(vertices.size()))
			for index in range(0, indices.size(), 3):
				var a := indices[index]
				var geometric := (vertices[indices[index + 2]] - vertices[a]).cross(vertices[indices[index + 1]] - vertices[a])
				if geometric.dot(normals[a]) < 0:
					var b := indices[index + 1]
					indices[index + 1] = indices[index + 2]
					indices[index + 2] = b
			arrays[Mesh.ARRAY_INDEX] = indices
			aligned.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		instance.mesh = aligned


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
			node.build_shaped(load(DIR + "frames/W6-shaped.png"), Vector2(r.canvas_w, r.canvas_h), r.outline, Color(r.edge_color))
		else:
			node.build_framed(load(DIR + "frames/%s.png" % r.tag), load(DIR + "canvas/%s.jpg" % r.tag), Vector2(r.canvas_w, r.canvas_h), r.margins_px)
		assets[r.tag] = node
	var X := W / 2.0
	# long walls: even gaps, in the researched order. West runs arch end -> far end; east runs far end -> arch end.
	for wall in [{"tags": ["W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10"], "x": -X, "rot": PI / 2, "from_far": false},
			{"tags": ["E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9"], "x": X, "rot": -PI / 2, "from_far": true}]:
		var gaps: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "gaps.json"))
		var total := 0.0
		for i in wall.tags.size():
			total += assets[wall.tags[i]].outer.x
			if i > 0:
				total += gaps.get("%s-%s" % [wall.tags[i - 1], wall.tags[i]], GAP)
		var d: float = (L - total) / 2.0  # the rest splits evenly between the two corners
		for i in wall.tags.size():
			var t: String = wall.tags[i]
			if i > 0:
				d += gaps.get("%s-%s" % [wall.tags[i - 1], t], GAP)
			var w: float = assets[t].outer.x
			var along := d + w / 2.0
			var z := -(L - along) if wall.from_far else -along
			_place(t, by[t], assets[t], Vector3(wall.x, 0, z), wall.rot)
			d += w
	# end walls: one painting centred on each side of the door
	var ma := (DOORS.arch.size.x / 2.0 + CASING + X) / 2.0
	var mf := (DOORS.far.size.x / 2.0 + CASING + X) / 2.0
	_place("S1", by.S1, assets.S1, Vector3(ma, 0, 0), PI)  # arch end, east of the door
	_place("S2", by.S2, assets.S2, Vector3(-ma, 0, 0), PI)
	_place("N1", by.N1, assets.N1, Vector3(-mf, 0, -L), 0.0)  # far end, west of the door
	_place("N2", by.N2, assets.N2, Vector3(mf, 0, -L), 0.0)


func _place(tag: String, rec: Dictionary, node: Node3D, at: Vector3, rot: float) -> void:
	var outer: Vector2 = node.outer
	at.y = _hang_center(rec, outer.y)
	var basis := Basis(Vector3.UP, rot)
	node.transform = Transform3D(basis, at)
	_vp.add_child(node)
	# the skylight's cast shadow: soft, straight down the wall below the frame, a little wider than it
	var sh := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = node.outer + Vector2(0.22, 0.3)
	sh.mesh = q
	sh.material_override = _shadow_mat(0.5)
	sh.position = Vector3(0, -0.2, 0.006)
	sh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.add_child(sh)
	node.move_child(sh, 0)
	# the track lamp's warm pool, brightest just above the picture and spilling onto the wall around it
	var pool := MeshInstance3D.new()
	var pq := QuadMesh.new()
	pq.size = Vector2(node.outer.x * 1.7 + 0.6, node.outer.y * 1.6 + 0.6)
	pool.mesh = pq
	pool.material_override = _pool_mat()
	pool.position = Vector3(0, 0.25, 0.004)
	node.add_child(pool)
	node.move_child(pool, 0)
	var layer := LAYER_EAST if at.x > W / 2.0 - 0.1 or (absf(at.z) < 0.1 and at.x > 0) else LAYER_WEST
	for c in node.get_children():
		(c as VisualInstance3D).layers = layer
	var n := basis * Vector3.BACK
	var r := basis * Vector3.RIGHT
	var corners := []
	for c in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		corners.append(at + r * c.x * outer.x / 2.0 + Vector3.UP * c.y * outer.y / 2.0 + n * 0.09)
	_paintings.append({"tag": tag, "rec": rec, "center": at, "normal": n, "corners": corners, "outer": outer})


func _mat(tex: Texture2D) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_texture = tex
	return m


func _rect(c: Vector3, size: Vector2, right: Vector3, up: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	mi.material_override = m
	mi.transform = Transform3D(Basis(right, up, right.cross(up)), c)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_vp.add_child(mi)
	return mi


func _build_sounds() -> void:
	for n in ["step_wood_01", "step_wood_02", "step_wood_03", "step_wood_04", "step_wood_05", "step_wood_06",
			"pickup", "menu_open", "menu_close", "select", "cancel", "cursor", "item_select"]:
		if ResourceLoader.exists(DIR + "sounds/%s.ogg" % n):
			var pl := AudioStreamPlayer.new()
			pl.stream = load(DIR + "sounds/%s.ogg" % n)
			pl.volume_db = -8.0 if n.begins_with("step") else -4.0
			add_child(pl)
			_sfx[n] = pl


func _play(n: String, pitch := 1.0) -> void:
	if _sfx.has(n) and is_visible_in_tree():
		var pl: AudioStreamPlayer = _sfx[n]
		pl.pitch_scale = pitch
		pl.play()


# Keep cutaway groups intact through batching. The bake sees the complete room.
func _partition_surfaces() -> void:
	for mi in _vp.find_children("*", "MeshInstance3D", true, false):
		var bounds: AABB = mi.global_transform * mi.mesh.get_aabb()
		var center := bounds.get_center()
		if center.y > H - 0.6:
			mi.layers = 32
		elif bounds.end.x < -W / 2.0 + 0.5:
			mi.layers = 2
		elif bounds.position.x > W / 2.0 - 0.5:
			mi.layers = 4
		elif bounds.position.z > -0.65:
			mi.layers = 8
		elif bounds.end.z < -L + 0.65:
			mi.layers = 16
		else:
			mi.layers = 1


func _build_view_controls() -> void:
	_view_panel = PanelContainer.new()
	_view_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_view_panel.offset_top = -40
	_view_panel.offset_bottom = -4
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.06, 0.07, 0.09, 0.88)
	background.content_margin_top = 4
	background.content_margin_bottom = 4
	_view_panel.add_theme_stylebox_override("panel", background)
	add_child(_view_panel)
	_view_panel.hide()  # F6 exposes authoring comparisons; the museum has no debug strip.
	var other_wall := Button.new()
	other_wall.name = "OtherWall"
	other_wall.text = "Other wall"
	other_wall.tooltip_text = "Cross the gallery to view the opposite paintings"
	other_wall.focus_mode = Control.FOCUS_NONE
	other_wall.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	other_wall.position = Vector2(-126, -44)
	other_wall.size = Vector2(114, 32)
	other_wall.pressed.connect(_other_wall)
	add_child(other_wall)
	_view_bar = HBoxContainer.new()
	_view_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_view_bar.add_theme_constant_override("separation", 8)
	_view_panel.add_child(_view_bar)
	var choice := OptionButton.new()
	for title in ["Dollhouse", "Gallery", "Original"]:
		choice.add_item(title)
	choice.focus_mode = Control.FOCUS_NONE
	choice.item_selected.connect(_set_view)
	_view_bar.add_child(choice)
	for direction in [1, -1]:
		var button := Button.new()
		button.text = "Q <" if direction == 1 else "> E"
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _rotate_view(direction))
		_view_bar.add_child(button)
	_lighting_choice = CheckButton.new()
	_lighting_choice.text = "Baked light"
	_lighting_choice.focus_mode = Control.FOCUS_NONE
	_lighting_choice.toggled.connect(func(enabled: bool) -> void:
		_play("select")
		_set_lighting(enabled))
	_view_bar.add_child(_lighting_choice)
	_lighting_choice.disabled = not ResourceLoader.exists(DIR + "baked/room.tscn")
	_view_label = Label.new()
	_view_bar.add_child(_view_label)
	if OS.has_feature("web"):
		var variant = JavaScriptBridge.eval("new URLSearchParams(location.search).get('variant')")
		view_mode = {"dollhouse": 0, "gallery": 1, "original": 2}.get(str(variant), 0)
	choice.select(view_mode)
	var use_bake := not _lighting_choice.disabled
	if OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).get('lighting') === 'original'"):
		use_bake = false
	_lighting_choice.set_pressed_no_signal(use_bake)
	_set_lighting(use_bake)


# #135: deliberately plain navigation room, reused with a remembered return doorway.
# Native unshaded face tones require no new runtime light or gallery rebake.
func _build_test_room() -> void:
	var face := func(c: Vector3, size3: Vector3, color: Color, layer: int) -> void:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
		_box(c, size3, color, layer, material)
	face.call(Vector3(0, -0.06, -3), Vector3(6, 0.12, 6.4), Color("#ece9e2"), 64)
	face.call(Vector3(-3, 1.8, -3), Vector3(0.12, 3.6, 6), Color("#dddcd7"), 128)
	face.call(Vector3(3, 1.8, -3), Vector3(0.12, 3.6, 6), Color("#f5f4ed"), 256)
	face.call(Vector3(0, 1.8, -6), Vector3(6, 3.6, 0.12), Color("#e7e6df"), 1024)
	for sign_x in [-1.0, 1.0]:
		face.call(Vector3(sign_x * 1.975, 1.8, 0), Vector3(2.05, 3.6, 0.12), Color("#f1f0ea"), 512)
		face.call(Vector3(sign_x * 1.01, 1.5, -0.08), Vector3(0.14, 3.0, 0.16), Color.WHITE, 512)
	face.call(Vector3(0, 3.3, 0), Vector3(1.9, 0.6, 0.12), Color("#f1f0ea"), 512)
	face.call(Vector3(0, 3.02, -0.08), Vector3(2.16, 0.14, 0.16), Color.WHITE, 512)
	# A shallow white recess shows depth through the existing casing. The actual
	# portal crosses at the mouth, before its rear wall; no new gallery bake.
	for door in [DOORS.arch]:  # far passage now belongs to its baked architectural slice
		var outward := 1.0 if door.z == 0.0 else -1.0
		var layer := 8 if door.z == 0.0 else 16
		var depth := 1.1
		var width: float = door.size.x - 0.08
		var height: float = door.size.y - 0.04
		var middle: float = door.z + outward * depth / 2.0
		face.call(Vector3(0, height / 2.0, door.z + outward * depth), Vector3(width, height, 0.025), Color("#eeede7"), layer)
		face.call(Vector3(-width / 2.0, height / 2.0, middle), Vector3(0.035, height, depth), Color("#d7d6ce"), layer)
		face.call(Vector3(width / 2.0, height / 2.0, middle), Vector3(0.035, height, depth), Color("#f8f7f0"), layer)
		face.call(Vector3(0, height, middle), Vector3(width, 0.035, depth), Color("#fdfcf6"), layer)
		face.call(Vector3(0, -0.0125, middle), Vector3(width, 0.025, depth), Color("#e3e0d6"), layer)
		# Flush threshold: the walkable floor stays at y=0, including the entrance.
		face.call(Vector3(0, -0.014, door.z), Vector3(width, 0.03, 0.24), Color("#cbc7bc"), layer)
	_portal_flash = ColorRect.new()
	_portal_flash.color = Color.WHITE
	_portal_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portal_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portal_flash.modulate.a = 0.0
	add_child(_portal_flash)


func _enter_space(next: String) -> void:
	var previous := _space
	_new_action()
	_target = null
	_target_yaw = null
	_velocity = Vector3.ZERO
	_held.clear()
	_space = next
	for node in _vp.get_children():
		if node is WorldEnvironment:
			node.environment.background_color = Color("#20242a") if next == "gallery" else Color("#ece9e2")
			node.environment.ambient_light_energy = 0.6 if next == "gallery" and not _baked_lighting else 0.0
	if next == "gallery":
		_pos = Vector3(0, 0, -0.7 if previous == "arch" else -L + 0.7)
		view_yaw = 0.0 if previous == "arch" else PI
	else:
		_pos = Vector3(0, 0, -0.7)
		view_yaw = 0.0
	_yaw = view_yaw
	if _rigged_visitor:
		_kid.position = _pos
		_kid.reset_contacts()
		_motion_heading = Vector3.FORWARD if next != "gallery" or previous == "arch" else Vector3.BACK
		_kid.pose(0.0, false, 0.0, _motion_heading, view_yaw)
	_view_turn_remaining = 0.0
	get_node("OtherWall").visible = next == "gallery"
	_portal_flash.modulate.a = 1.0
	create_tween().tween_property(_portal_flash, "modulate:a", 0.0, 0.22)
	_update_camera(1.0)
	print("NAV_SPACE ", previous, " -> ", next)


func _move_to(p: Vector3) -> void:
	# Sweep the doorway's wall plane as well as clamping the endpoint: diagonal
	# movement must not cut a corner through a solid part of the end wall.
	for wall in [0.0, -L] if _space == "gallery" else [0.0]:
		var edge: float = wall - 0.55 if wall == 0.0 else wall + 0.55
		if (_pos.z - edge) * (p.z - edge) < 0.0:
			var at_x := lerpf(_pos.x, p.x, (edge - _pos.z) / (p.z - _pos.z))
			if absf(at_x) > 0.4:
				p.z = edge
	_pos = _clamp(p)


func _orbit(amount: float) -> void:
	if is_zero_approx(amount):
		return
	if _generated_visitor:
		if _rigged_visitor:
			_kid.look_direction = signf(amount)
		_kid.play_gesture("look")
	_new_action()
	_target = null
	_target_yaw = null
	_view_turn_remaining += amount


func _set_lighting(enabled: bool) -> void:
	_baked_lighting = enabled
	# Original room comparison has no capture. Supply neutral ambient only there;
	# baked/probe-disabled tests retain zero ambient and genuine spatial capture.
	for node in _vp.get_children():
		if node is WorldEnvironment:
			node.environment.ambient_light_energy = 0.6 if not enabled and _space == "gallery" else 0.0
	if enabled and _baked_room == null:
		_baked_room = load(DIR + "baked/room.tscn").instantiate()
		_vp.add_child(_baked_room)
	if _baked_room:
		_baked_room.visible = enabled
	if _white_capture == null and ResourceLoader.exists(DIR + "baked/white.lmbake"):
		_white_capture = LightmapGI.new()
		var capture: LightmapGIData = ResourceLoader.load(DIR + "baked/white.lmbake", "LightmapGIData", ResourceLoader.CACHE_MODE_IGNORE)
		capture.clear_users()  # white scene uses existing geometry; keep only its probe field
		_white_capture.light_data = capture
		_vp.add_child(_white_capture)
	if _white_capture:
		_white_capture.visible = _space != "gallery"
	for mesh in _source_meshes:
		mesh.visible = not enabled
	# The old photographed end cards are scenery, not traversable rooms.
	for mesh in _source_meshes + (_baked_room.find_children("*", "MeshInstance3D", true, false) if _baked_room else []):
		var material = mesh.material_override
		var texture = material.albedo_texture if material is StandardMaterial3D else (material.get_shader_parameter("albedo") if material is ShaderMaterial else null)
		if texture and (texture.resource_path.ends_with("door-arch.jpg") or texture.resource_path.ends_with("door-far.jpg")):
			mesh.hide()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("var u=new URL(location.href);u.searchParams.set('lighting','%s');history.replaceState(null,'',u)" % ("baked" if enabled else "original"))


func _set_view(mode: int) -> void:
	_play("select")
	_new_action()
	_held.clear()
	_velocity = Vector3.ZERO
	_target = null
	_target_yaw = null
	_view_turn_remaining = 0.0
	view_mode = mode
	(_view_bar.get_child(0) as OptionButton).select(mode)
	_update_camera(1.0)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("var u=new URL(location.href);u.searchParams.set('variant','%s');history.replaceState(null,'',u)" % ["dollhouse", "gallery", "original"][mode])
	print("VIEW ", ["dollhouse", "gallery", "original"][mode], " yaw ", rad_to_deg(view_yaw))


func _other_wall() -> void:
	if not _open.is_empty() or _space != "gallery":
		return
	# A deliberate gallery shortcut: keep the same bay, cross to the other hang.
	var east := sin(view_yaw) > 0.0
	_pos = _clamp(Vector3(2.6 if east else -2.6, 0, _pos.z))
	view_yaw = -PI / 2.0 if east else PI / 2.0
	_set_view(0)
	print("OTHER_WALL ", "east" if east else "west")


func _rotate_view(direction: int) -> void:
	_orbit(direction * PI / 2.0)


func _screen_direction() -> Vector3:
	var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
	var right := Vector3(cos(view_yaw), 0, -sin(view_yaw))
	return (forward * (int(_held.has("up")) - int(_held.has("down"))) + right * (int(_held.has("right")) - int(_held.has("left")))).normalized()


func _painting_shown(p: Dictionary) -> bool:
	if _space != "gallery":
		return false
	if view_mode == 2:
		return true
	var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
	return p.normal.dot(forward) < 0.1


# Every static mesh that shares a look (same shader, texture, tint, flags) becomes one mesh: a few dozen draw calls
# instead of ~350, which is what held the frame rate down in the browser.
func _merge_static() -> void:
	var groups := {}
	var stack: Array = [_vp]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			stack.append(c)
		if not (n is MeshInstance3D) or n.mesh == null:
			continue
		var mi := n as MeshInstance3D
		var m := mi.material_override
		var key := ""
		if m is ShaderMaterial:
			var sm := m as ShaderMaterial
			var tex = sm.get_shader_parameter("albedo")
			key = "ps|%s|%s|%s|%s|%s|%s|%s" % [tex.get_rid().get_id() if tex else 0, sm.get_shader_parameter("tint"),
				sm.get_shader_parameter("use_vertex_color"), sm.get_shader_parameter("uv_scale"), sm.get_shader_parameter("plank_seams"),
				sm.get_shader_parameter("alpha_cut"), sm.get_shader_parameter("use_texture")]
		elif m is StandardMaterial3D:
			var st3 := m as StandardMaterial3D
			key = "std|%s|%s|%s|%s" % [st3.albedo_texture.get_rid().get_id() if st3.albedo_texture else 0, st3.albedo_color, st3.blend_mode, st3.transparency]
		else:
			continue
		key += "|layer:%s" % mi.layers
		if not groups.has(key):
			groups[key] = []
		groups[key].append(mi)
	for key in groups:
		var list: Array = groups[key]
		if list.size() < 2:
			continue
		var st := SurfaceTool.new()
		for mi in list:
			var xf: Transform3D = (mi as MeshInstance3D).global_transform
			for surf in mi.mesh.get_surface_count():
				st.append_from(mi.mesh, surf, xf)
		var merged := MeshInstance3D.new()
		merged.mesh = st.commit()
		merged.layers = list[0].layers
		merged.material_override = list[0].material_override
		merged.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for mi in list:
			mi.get_parent().remove_child(mi)
			mi.queue_free()
		_vp.add_child(merged)


func _build_kid() -> void:
	_generated_visitor = not (OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).get('character') === 'original'"))
	_rigged_visitor = not (OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).get('character') === 'sprite'")) and _generated_visitor
	if _generated_visitor:
		_kid = load(DIR + ("rig/visitor.gd" if _rigged_visitor else "visitor.gd")).new()
		if _rigged_visitor:
			_kid.identity = OS.get_environment("GALLERY_CHARACTER") != "rogue" and not (OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).get('character') === 'rogue'"))
		_kid.world_height = KID_H * (1.17 if _rigged_visitor else 1.0)
	else:
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
	g.set_color(0, Color(0, 0, 0, 0.9 if _rigged_visitor else 0.55))
	g.set_color(1, Color(0, 0, 0, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.0)
	var sm := _mat(gt)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_shadow = _rect(Vector3(0, 0.01, 0), Vector2(0.75, 0.42), Vector3.RIGHT, Vector3.FORWARD, sm)
	if _rigged_visitor:
		sm.albedo_color.a = 0.25
		for index in 2:
			var contact_material: StandardMaterial3D = sm.duplicate()
			_sole_shadows.append(_rect(Vector3.ZERO, Vector2(0.56, 0.72), Vector3.RIGHT, Vector3.FORWARD, contact_material))


# ---------------------------------------------------------------- the detail view

func _build_detail() -> void:
	_detail = Control.new()
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_PASS
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
	var close := TextureButton.new()  # the game's own tab close icon, drawn at twice its size
	close.name = "Close"
	close.texture_normal = load("res://modules/tab_strip/assets/icon_close.png")
	close.texture_pressed = load("res://modules/tab_strip/assets/icon_close_pressed.png")
	close.ignore_texture_size = true
	close.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	close.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	close.size = Vector2(44, 44)
	close.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close.position = Vector2(-58, 14)
	close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close.pressed.connect(func() -> void: _close_detail())
	_detail.add_child(close)
	var frame := NinePatchRect.new()
	frame.name = "Frame"
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom_root.add_child(frame)


func _open_detail(p: Dictionary) -> void:
	_view_panel.hide()
	get_node("OtherWall").hide()
	_velocity = Vector3.ZERO
	var rec: Dictionary = p.rec
	var pic: TextureRect = _zoom_root.get_node("Painting")
	var frame: NinePatchRect = _zoom_root.get_node("Frame")
	# one master: the shaped work shows its own keyed cut-out, as in the room, on white
	var tex: Texture2D = load(DIR + ("frames/W6-shaped.png" if p.tag == "W6" else "detail/%s.jpg" % p.tag))
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
	_held.clear()
	_play("menu_open")
	get_tree().create_timer(0.18).timeout.connect(func() -> void: _play("pickup"))
	_detail.visible = true
	var t := create_tween()
	t.tween_property(_detail, "modulate:a", 1.0, 0.4)


func _close_detail() -> void:
	_view_panel.hide()
	_play("menu_close")
	var t := create_tween()
	t.tween_property(_detail, "modulate:a", 0.0, 0.3)
	await t.finished
	_detail.visible = false
	_open = {}
	get_node("OtherWall").show()


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
	if _entrance_waiting:
		# Boot warms every tab behind its loader. Start only when the viewer is visible.
		if not is_visible_in_tree() or get_tree().root.has_node("BootLoader"):
			return
		if OS.has_feature("web") and JavaScriptBridge.eval("document.getElementById('status') !== null"):
			return
		_entrance_waiting = false
	if not _open.is_empty():
		return
	var turn := _view_turn_remaining * (1.0 - exp(-delta * 12.0))
	var orbit_settled := absf(_view_turn_remaining) >= 0.001 and absf(_view_turn_remaining - turn) < 0.001
	_view_turn_remaining -= turn
	if view_mode == 2:
		_yaw = wrapf(_yaw + turn, -PI, PI)
	else:
		view_yaw = wrapf(view_yaw + turn, -PI, PI)
	for k in _held.keys():
		_held[k] += delta
	if view_mode == 2 and _held.get("left", 0.0) > HOLD_S:
		_yaw += deg_to_rad(TURN_HELD_DPS) * delta
		_target_yaw = null
	if view_mode == 2 and _held.get("right", 0.0) > HOLD_S:
		_yaw -= deg_to_rad(TURN_HELD_DPS) * delta
		_target_yaw = null
	if view_mode == 2 and _held.get("up", 0.0) > HOLD_S:
		_target = _clamp(_pos + _fwd() * 0.4)
	if view_mode == 2 and _held.get("down", 0.0) > HOLD_S:
		_target = _clamp(_pos - _fwd() * 0.4)
	if _target_yaw != null:
		var d := wrapf(_target_yaw - _yaw, -PI, PI)
		var a := deg_to_rad(TURN_TAP_DPS) * delta
		if absf(d) <= a:
			_yaw = _target_yaw
			_target_yaw = null
		else:
			_yaw += signf(d) * a
	var position_before := _pos
	if view_mode != 2:
		var direction := _screen_direction()
		_velocity = _velocity.move_toward(direction * (WALK_MPS if _rigged_visitor else 2.0), (12.0 if direction != Vector3.ZERO else 16.0) * delta)
		if _velocity.length() > 0.01:
			_move_to(_pos + _velocity * delta)
	var goal = _path[0] if not _path.is_empty() else _target
	if goal != null:
		var to: Vector3 = goal - _pos
		to.y = 0
		if to.length() < 0.05:
			if not _path.is_empty():
				_path.pop_front()
			else:
				_target = null
		else:
			_move_to(_pos + to.normalized() * minf(to.length(), WALK_MPS * delta))
			# stuck against something for half a second: give up on this walk
			_stall_t = _stall_t + delta if _pos.distance_to(_last_pos) < WALK_MPS * delta * 0.2 else 0.0
			if _stall_t > 0.5:
				_path.clear()
				_target = null
				_stall_t = 0.0
	_last_pos = _pos
	var distance_moved := _pos.distance_to(position_before)
	if distance_moved > 0.0001:
		_motion_heading = (_pos - position_before).normalized()
	if _entrance_active and _target == null:
		_entrance_active = false
		print("ENTRY_COMPLETE ", _pos)
	if not _entrance_active:
		if _space != "gallery" and _pos.z > 0.0:
			_enter_space("gallery")
		elif _space == "gallery" and (_pos.z > 0.0 or _pos.z < -L):
			_enter_space("arch" if _pos.z > 0.0 else "far")
	if distance_moved > 0.0001:
		var previous := int(_kid_t * 10.0) if _kid_t > 0.0 else -1
		var speed := distance_moved / maxf(delta, 0.0001)
		# GC contacts are eight keyframes apart; full-stick cadence is ~3.6 steps/s.
		var steps_per_second := 3.6 * sqrt(minf(speed / 2.0, 1.0))
		_kid_t += delta * steps_per_second * 8.0 / 10.0
		var current := int(_kid_t * 10.0)
		for frame in range(previous + 1, current + 1):
			if not _rigged_visitor and frame % WALK_FRAMES in CONTACT_FRAMES:
				_step_i = (_step_i + 1) % 6
				_play("step_wood_%02d" % (_step_i + 1))
		if not _generated_visitor:
			_kid.texture = _kid_frames[current % WALK_FRAMES]
	else:
		_kid_t = 0.0
		if not _generated_visitor:
			_kid.texture = _kid_frames[0]
	_kid.position = _pos
	if _generated_visitor:
		_kid.pose(delta, distance_moved > 0.0001, _kid_t * 10.0 / WALK_FRAMES, _motion_heading, view_yaw if view_mode != 2 else _yaw)
	if _rigged_visitor:
		for contact in _kid.contacts:
			_step_i = (_step_i + 1) % 6
			_play("step_wood_%02d" % (_step_i + 1))
	_update_camera(minf(1.0, delta * 5.0))
	_update_hover()
	if orbit_settled:
		print("VIEW_ORBIT ", JSON.stringify({"yaw": view_yaw if view_mode != 2 else _yaw, "position": [_pos.x, _pos.z], "space": _space}))


# Inside the room, clear of the walls and the benches.
func _clamp(p: Vector3) -> Vector3:
	var m := 0.55
	var doorway := absf(p.x) <= 0.4
	if _space != "gallery":
		return Vector3(clampf(p.x, -3.0 + m, 3.0 - m), 0, clampf(p.z, -6.0 + m, 0.2 if doorway else -m))
	p = Vector3(clampf(p.x, -W / 2 + m, W / 2 - m), 0, clampf(p.z, -L - 0.2 if doorway else -L + m, 0.2 if doorway else -m))
	for bz in BENCHES:
		var hx := BENCH_CLEAR.x
		var hz := BENCH_CLEAR.y
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
	if _baked_room:
		_baked_room.get_node("Lightmap").visible = _space == "gallery"
	if _white_capture:
		_white_capture.visible = _space != "gallery"
	_kid.layers = 1 if _space == "gallery" else 64
	_shadow.layers = _kid.layers
	_kid.position = _pos
	_shadow.position = _pos + Vector3(0, 0.01, 0)
	if _rigged_visitor:
		var soles: Array = _kid.sole_positions()
		var support: Array = _kid.sole_support()
		_shadow.position = (soles[0] + soles[1]) * 0.5
		_shadow.position.y = _pos.y + 0.006
		for index in 2:
			var contact := _sole_shadows[index]
			contact.layers = _kid.layers
			contact.position = Vector3(soles[index].x, _pos.y + 0.008, soles[index].z)
			contact.rotation.y = _kid.rotation.y
			var height: float = maxf(0.0, soles[index].y - _pos.y)
			contact.material_override.albedo_color.a = 0.85 if support[index] else 0.22 * clampf(1.0 - height / 0.25, 0.0, 1.0)
	if not _rigged_visitor:
		_kid.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y if view_mode == 2 else BaseMaterial3D.BILLBOARD_ENABLED
	if view_mode != 2:
		var pitch := deg_to_rad(42.0 if view_mode == 0 else 35.0)
		var distance := 14.2 if view_mode == 0 else 9.3
		_cam.fov = 23.0 if view_mode == 0 else 30.0
		var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
		var center := _pos + forward * 0.7 + Vector3(0, 1.85 if view_mode == 0 else 1.55, 0)
		# Follow the kid along the gallery; the cutaway lets the eye sit outside it.
		_cam.position = center - forward * distance * cos(pitch) + Vector3.UP * distance * sin(pitch)
		_cam.look_at(center)
		var hidden := (4 if forward.x < -0.2 else (2 if forward.x > 0.2 else 0)) | (8 if forward.z < -0.2 else (16 if forward.z > 0.2 else 0))
		_cam.cull_mask = (1984 & ~(hidden * 64)) if _space != "gallery" else (31 & ~hidden)
		if _view_label:
			_view_label.text = "WASD · Click art · " + ("West wall" if forward.x < -0.5 else ("East wall" if forward.x > 0.5 else ("Far wall" if forward.z < -0.5 else "Arch wall")))
		return
	_cam.cull_mask = 1984 if _space != "gallery" else 63
	_cam.fov = 58.0
	if _view_label:
		_view_label.text = "WASD · Click art"
	var head := _pos + Vector3(0, 1.3, 0)
	var want := _pos - _fwd() * 3.1 + Vector3(0, 1.95, 0)
	var d := want - head
	var t := 1.0
	var m := 0.25
	var room_w := W if _space == "gallery" else 6.0
	var room_l := L if _space == "gallery" else 6.0
	for axis in [0, 2]:
		var lo: float = -room_w / 2 + m if axis == 0 else -room_l + m
		var hi: float = room_w / 2 - m if axis == 0 else -m
		if d[axis] > 0.0001:
			t = minf(t, (hi - head[axis]) / d[axis])
		elif d[axis] < -0.0001:
			t = minf(t, (lo - head[axis]) / d[axis])
	t = clampf(t, 0.0, 1.0)
	want = head + d * t + Vector3(0, (1.0 - t) * 0.9, 0)  # blocked by a wall: rise over the kid instead
	_cam.position = _cam.position.lerp(want, k) if k < 1.0 else want
	_cam.look_at(_pos + _fwd() * 4.0 + Vector3(0, 1.1, 0))


func _step(dir: float) -> void:
	_new_action()
	_target = _clamp(_pos + _fwd() * STEP_M * dir)  # from where the kid stands: a key replaces any click walk


func _new_action() -> void:
	_entrance_waiting = false
	if _entrance_active:
		_entrance_active = false
		_pos.z = minf(_pos.z, -0.05)
	_action += 1
	_path.clear()


# Walk to p. Every leg is checked against each bench's rectangle (grown by the kid's clearance); a leg that
# crosses one is replaced by a detour down the side lane nearer the start, past both of the bench's ends.
func _walk_to(p: Vector3) -> void:
	_velocity = Vector3.ZERO
	_new_action()
	_target = _clamp(p)
	if _space != "gallery":
		return
	var pts: Array = [_pos, _target]
	var i := 0
	while i < pts.size() - 1 and pts.size() < 16:
		var hit := _bench_hit(pts[i], pts[i + 1])
		if hit == INF:
			i += 1
			continue
		var bz: float = hit
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[i + 1]
		var side := func(v: Vector3, other: Vector3) -> float: return signf(v.x) if absf(v.x) > 0.05 else (signf(other.x) if absf(other.x) > 0.05 else 1.0)
		var xa: float = side.call(a, b) * 1.6
		var xb: float = side.call(b, a) * 1.6
		var sa := signf(a.z - bz) if absf(a.z - bz) > 0.01 else 1.0
		var sb := signf(b.z - bz) if absf(b.z - bz) > 0.01 else sa
		var detour: Array = []
		if xa == xb:  # same side of the bench: along the lane from our end to the target's end
			detour = [Vector3(xa, 0, bz + 2.15 * sa)] if sa == sb else [Vector3(xa, 0, bz + 2.15 * sa), Vector3(xa, 0, bz + 2.15 * sb)]
		else:  # opposite sides: round the bench's end on our side
			detour = [Vector3(xa, 0, bz + 2.15 * sa), Vector3(xb, 0, bz + 2.15 * sa)]
		var added := 0
		for k in detour.size():
			var q: Vector3 = _clamp(detour[k])
			if q.distance_to(pts[i + added]) > 0.05:  # never the point we stand on
				pts.insert(i + 1 + added, q)
				added += 1
		if added == 0:
			i += 1
		# no advance: the new legs are checked again against every bench
	_path = pts.slice(1, pts.size() - 1)


# The z of the nearest bench (from a) that the straight leg a->b crosses, or INF.
func _bench_hit(a: Vector3, b: Vector3) -> float:
	var order := BENCHES.duplicate()
	order.sort_custom(func(p: float, q: float) -> bool: return absf(p - a.z) < absf(q - a.z))
	for bz in order:
		# the collision rectangle, a hair smaller so a kid standing on its edge is outside it
		var r := Rect2(Vector2(-BENCH_CLEAR.x, bz - BENCH_CLEAR.y), BENCH_CLEAR * 2.0).grow(-0.02)
		var aa := Vector2(a.x, a.z)
		var bb := Vector2(b.x, b.z)
		if r.has_point(bb):
			return bz
		var corners := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
		for k in 4:
			if Geometry2D.segment_intersects_segment(aa, bb, corners[k], corners[(k + 1) % 4]) != null:
				return bz
	return INF


func _turn(dir: float) -> void:
	_new_action()
	_target = null  # turning by key ends any click walk
	_target_yaw = (_target_yaw if _target_yaw != null else _yaw) + dir * PI / 4


# ---------------------------------------------------------------- picking

func _to_screen(p: Vector3) -> Vector2:
	return _cam.unproject_position(p) / Vector2(_vp.size) * size


# A painting's outline on screen, cut where it passes behind the camera (so a painting half out of view is
# still clickable by what shows, and a corner behind the camera never flips across the screen).
func _visible_outline(corners: Array) -> PackedVector2Array:
	var fwd := -_cam.global_transform.basis.z
	var o := _cam.global_position + fwd * (_cam.near * 2.0)
	var kept: Array = []
	for i in corners.size():
		var a: Vector3 = corners[i]
		var b: Vector3 = corners[(i + 1) % corners.size()]
		var da := (a - o).dot(fwd)
		var db := (b - o).dot(fwd)
		if da >= 0.0:
			kept.append(a)
		if (da >= 0.0) != (db >= 0.0):
			kept.append(a + (b - a) * (da / (da - db)))
	var out := PackedVector2Array()
	for q in kept:
		out.append(_to_screen(q))
	return out


# The painting under the pointer: its on-screen outline grown by a margin; the nearest wins.
func _painting_at(pt: Vector2) -> Dictionary:
	var best := {}
	var best_d := INF
	for p in _paintings:
		if not _painting_shown(p):
			continue
		var poly := _visible_outline(p.corners)
		if poly.size() < 3:
			continue
		var cen := Vector2.ZERO
		for q in poly:
			cen += q / poly.size()
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
	var hp := _painting_at(get_local_mouse_position())
	var tag: String = hp.get("tag", "")
	if tag != "" and tag != _hover_tag:
		_play("cursor", 1.1)
	_hover_tag = tag
	var over := not hp.is_empty()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if over else Control.CURSOR_ARROW


func _click(pt: Vector2) -> void:
	var p := _painting_at(pt)
	print("NAV_PICK ", p.get("tag", "floor"))
	if not p.is_empty():
		_play("select")
		_approach(p)
		return
	var vp_pt := pt / size * Vector2(_vp.size)
	var o := _cam.project_ray_origin(vp_pt)
	var d := _cam.project_ray_normal(vp_pt)
	if d.y < -0.01:
		_walk_to(o + d * (-o.y / d.y))
		var to: Vector3 = _target - _pos
		if to.length() > 0.2:
			_target_yaw = atan2(-to.x, -to.z)


func _approach(p: Dictionary) -> void:
	var stand: Vector3 = p.center + p.normal * clampf(p.outer.y * 1.1, 2.0, 3.5)
	stand.y = 0
	_walk_to(stand)
	var mine := _action
	var face := atan2(p.normal.x, p.normal.z)
	while _target != null or not _path.is_empty():
		await get_tree().process_frame
		if _action != mine or not _open.is_empty():
			return  # a newer click or key took over
	if _pos.distance_to(_clamp(stand)) > 0.6:
		return  # could not get there
	_target_yaw = face
	while _target_yaw != null:
		await get_tree().process_frame
		if _action != mine:
			return
	if _generated_visitor:
		_motion_heading = -p.normal
		_kid.pose(get_process_delta_time() if _rigged_visitor else 0.0, false, 0.0, _motion_heading, view_yaw if view_mode != 2 else _yaw)
		if _rigged_visitor:
			while absf(wrapf(_kid.rotation.y - atan2(_motion_heading.x, _motion_heading.z), -PI, PI)) > 0.015:
				await get_tree().process_frame
				if _action != mine or not _open.is_empty():
					return
		_kid.play_gesture("wave")
		while _kid.gesture != "":
			await get_tree().process_frame
			if _action != mine or not _open.is_empty():
				return
	_open_detail(p)


# ---------------------------------------------------------------- input

func _gui_input(event: InputEvent) -> void:
	if not _open.is_empty():
		var close: Control = _detail.get_node("Close")
		if event is InputEventMouse and close.get_global_rect().has_point(event.global_position):
			return  # the X button takes it
		_detail_input(event)
		accept_event()
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			grab_focus()
			if event.pressed:
				_new_action()
				_target = null
				_orbit_from = event.position
				_orbit_dragged = false
			else:
				if _orbit_from != null and not _orbit_dragged:
					_click(event.position)
				_orbit_from = null
			accept_event()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT]:
			_orbit(0.10 * event.factor * (1.0 if event.button_index == MOUSE_BUTTON_WHEEL_LEFT else -1.0))
			accept_event()
	elif event is InputEventMouseMotion and _orbit_from != null:
		if not _orbit_dragged and event.position.distance_to(_orbit_from) > 6.0:
			_orbit_dragged = true
			_orbit((event.position.x - _orbit_from.x) * 0.006)
		elif _orbit_dragged:
			_orbit(event.relative.x * 0.006)
		accept_event()
	elif event is InputEventPanGesture:
		_orbit(-event.delta.x * 0.05)
		accept_event()


func _detail_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_EQUAL, KEY_PLUS, KEY_KP_ADD]:
			_zoom_at(size / 2.0, 1.25)
		elif event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]:
			_zoom_at(size / 2.0, 0.8)
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_FOCUS_EXIT:
		_held.clear()
		_velocity = Vector3.ZERO
		_orbit_from = null
		_orbit_dragged = false


func _unhandled_key_input(event: InputEvent) -> void:
	if event.echo:
		return
	if not event.pressed and event is InputEventKey:  # releases always count, even while hidden
		for k in ["up", "down", "left", "right"]:
			if _held.has(k) and event.keycode in {"up": [KEY_UP, KEY_W], "down": [KEY_DOWN, KEY_S], "left": [KEY_LEFT, KEY_A], "right": [KEY_RIGHT, KEY_D]}[k]:
				_held.erase(k)
	if not is_visible_in_tree():
		return
	if event.pressed and event.keycode == KEY_F6:
		_view_panel.visible = not _view_panel.visible
		get_viewport().set_input_as_handled()
		return
	if event.pressed and _open.is_empty() and event.keycode in [KEY_Q, KEY_E]:
		_rotate_view(1 if event.keycode == KEY_Q else -1)
		get_viewport().set_input_as_handled()
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
	_new_action()
	if view_mode != 2:
		_target = null
		_target_yaw = null
		return
	match key:
		"up": _step(1.0)
		"down": _step(-1.0)
		"left": _turn(1.0)
		"right": _turn(-1.0)
