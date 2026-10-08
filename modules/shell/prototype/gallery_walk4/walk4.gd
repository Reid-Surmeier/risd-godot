# #237: preserve the existing private gallery composition as one file.
# gdlint: disable=max-file-lines
## PROTOTYPE 4, throwaway (2026-09-26, map #116): the RISD Grand Gallery with all
## 23 paintings modelled in place.
## Order, canvas sizes and heights: docs/research/grand-gallery-hang.md (branch
## research/grand-gallery-hang).
## Paintings: RISD's own photograph (Wikimedia Commons, CC0) as the canvas
## inside a Muse frame built as a 3D
## nine-slice (painting_asset.gd); the angel is its keyed Muse cut-out.
## Surfaces and the two views through the
## doorways are Muse passes (image-work/grand-gallery-v4). Video pixels are measurement only.
## Keys: Up/W step (hold to walk), Down/S step back, Left/A Right/D turn (hold to
## keep turning). Click the floor
## to walk there, a painting to walk up to it and open it. In the detail view:
## scroll or pinch to zoom, drag to
## pan, double-click to zoom in, Esc or a click outside the painting to close.
extends Control

signal detail_changed(open: bool)

const PaintingAsset := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const DIR := "res://modules/shell/prototype/gallery_walk4/"
const LOW_RES := Vector2i(480, 320)
# room length, arch end (z = 0) to far end (z = -L): paintings + measured gaps (see
# _build_paintings)
const L := 26.3
const W := 10.0  # room width, west wall x = -W/2 (the arch-end wall in the Jan 2026 photo)
const H := 6.0  # wall height to the cornice
const VAULT_RISE := 3.0
const SKY_W := 4.2
const WHITE := Color("#e9e6de")
const CASING := 0.28
const GAP := 0.75  # default gap between frames; measured gaps in gaps.json
const PLANK := Vector2(1.9, 0.36)  # #186 exact owner-selected floor from c614b5ed
# The two doorways differ: the arch door (to the medieval gallery) has a cornice
# head and a shallow reveal onto
# the wide lit room; the far door has a plain casing and a deep vestibule
# with a second door at its end.
const DOORS := {
	"arch":
	{
		"z": 0.0,
		"size": Vector2(1.9, 3.1),
		"reveal": 0.45,
		"card": "door-arch",
		"cornice": true,
		"vestibule": false
	},
	"far":
	{
		"z": -L,
		"size": Vector2(1.9, 2.8),
		"reveal": 2.6,
		"card": "door-far",
		"cornice": false,
		"vestibule": true
	},
}
const BENCHES := [-9.0, -17.0]
# the kid's clearance round a bench (half-size x, z): collision and route planning share it
const BENCH_CLEAR := Vector2(0.78, 1.8)
const WALK_MPS := 1.2
const SPRINT_MPS := 3.0  # Shift held: the accepted character's dash
const STEP_M := 1.0
const TURN_HELD_DPS := 40.0
# A step of the view (Q, E, the buttons, "Other wall") glides for a second, slow-fast-slow, as
# the New Horizons museum's views do. Mouse drags and the wheel still follow the hand.
const VIEW_TURN_S := 1.0
const TURN_TAP_DPS := 75.0
const HOLD_S := 0.25
const KID_H := 1.75
# First 16 held frames: visible alternate contacts at 0 and 8, reviewed in bake/README.
const CONTACT_FRAMES := [0, 8]
const WALK_FRAMES := 16


const LAYER_WEST := 2
const LAYER_EAST := 4
const LAYER_UNLIT := 8


# The arch end, as in the video: one white-cased door in the gallery wall; behind
# its plaster reveal the Romanesque
# stone portal of the medieval gallery is the same opening (its round arch shows
# at the top of the door), a shallow
# stone frontispiece against the wall (IMG_6382, not a tunnel), then the medieval room:
# blue-grey walls, herringbone floor, the crucifix lit warm.
const PORTAL_DEPTH := 0.2
# Where the visitor leaves the stone: the plaster reveal, the masonry, then the jamb columns
# and imposts that stand 0.55 m in front of it.
const PORTAL_MOUTH := DOORS.arch.reveal + PORTAL_DEPTH + 0.55


static var _ps1_shader: Shader
static var _soft_rect: ImageTexture
static var _pool_tex: ImageTexture
# PROTOTYPE #132: fixed dollhouse, lower gallery view, and original camera.
var view_mode := 0
var view_yaw := PI

var _vp: SubViewport
var _view_turn_remaining := 0.0
var _turn_span := 0.0  # what was left to turn when the current eased turn began
var _turn_clock := 1.0  # 0..1 through an eased turn; 1 when none is under way
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
var _portal_floor_material: ShaderMaterial
var _cutaway_materials := {}
var _cutaway_alpha := {8: 1.0}
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
var _catalogue_zoom: Node
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
	# steadies polygon edges at the low resolution; all light is baked, so this is cheap
	_vp.msaa_3d = Viewport.MSAA_2X
	box.add_child(_vp)
	# render at ~LOW_RES wide
	resized.connect(func() -> void: box.stretch_shrink = maxi(1, roundi(size.x / LOW_RES.x)))
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
	resized.connect(_fit_detail)
	resized.connect(_refresh_zoom_image)
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
	if (
		OS.has_feature("web")
		and JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa-perf')")
	):
		add_child(load(DIR + "performance_probe.gd").new())
	if (
		OS.has_feature("web")
		and JavaScriptBridge.eval("new URLSearchParams(location.search).has('render_qa')")
	):
		add_child(load(DIR + "render_diagnostics.gd").new())


# GameCube RGB6 quantization: subtle 2x2 ordering at rendered texels, no time/noise.
# Formula: Dolphin PixelShaderGen, documented in research/animal-crossing-look.
func _post() -> ShaderMaterial:
	var render_mode = (
		JavaScriptBridge.eval("new URLSearchParams(location.search).get('final_render')")
		if OS.has_feature("web")
		else null
	)
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


# A soft dark rectangle (its edges fade over a fifth of each side): the baked
# shadow under frames and benches.
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


# A room material: the PS1 surface shader, lit, optionally textured, with
# baked occlusion in vertex colour.
static func ps(
	tex: Texture2D, tint := Color.WHITE, uv := Vector2.ONE, vcol := false, glow := 0.0, cut := 0.0
) -> ShaderMaterial:
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
		# the skylight's pool: brighter down the middle, falling off toward the
		# walls and the ends, with the soft
		# lighter/darker patches of daylight on satin oak
		var pool := 0.74 + 0.36 * exp(-pow(p.x / 2.7, 2.0))
		pool *= 0.9 + 0.1 * smoothstep(0.0, 3.0, minf(-p.z, p.z + L))
		pool *= 1.0 + 0.06 * sin(p.z * 0.9 + 1.3) * cos(p.x * 1.1)
		ao *= pool
	else:
		ao *= 0.86 + 0.14 * smoothstep(0.0, H, p.y)  # walls: lighter toward the skylight
	return ao


# A subdivided flat panel from corner c along u and v (cells about `cell`
# metres), occlusion in its vertex
# colours, UVs in metres times uv_per_m. layer: which skylight lights it.
func _panel(
	c: Vector3, u: Vector3, v: Vector3, m: Material, cell := 0.5, layer := 1, ao := Callable()
) -> MeshInstance3D:
	var nu := maxi(1, ceili(u.length() / cell))
	var nv := maxi(1, ceili(v.length() / cell))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := u.cross(v).normalized()
	var vertical := absf(n.y) < 0.5
	for j in nv:
		for i in nu:
			var q := [Vector2(i, j), Vector2(i + 1, j), Vector2(i + 1, j + 1), Vector2(i, j + 1)]
			# Godot uses clockwise front faces; agree with the supplied normal.
			for k in [0, 2, 1, 0, 3, 2]:
				var f := Vector2(q[k].x / nu, q[k].y / nv)
				var p := c + u * f.x + v * f.y
				var o: float = ao.call(p) if ao.is_valid() else _ao(p, vertical)
				st.set_color(Color(o, o, o))
				st.set_normal(n)
				st.set_uv(Vector2(f.x * u.length(), (1.0 - f.y) * v.length()))
				st.add_vertex(p)
	var mi := MeshInstance3D.new()
	mi.mesh = load(DIR + "cpu_geometry.gd").commit(st)
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
	# #177: restore the textured wall in the owner-selected screenshot.
	return ps(load(DIR + "textures/wall-muse.webp"), extra, Vector2(0.25, 0.25), true)


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
	var x := W / 2.0
	# (no base plane under the planks: 3 mm below them it z-fought through at a distance)
	_build_floor()
	# Flush panel joints share the wall plane; raised slivers aliased and self-shadowed.
	var divisions := [0.0, 6.99, 7.01, 15.99, 16.01, 23.99, 24.01, L]
	for side in [-1.0, 1.0]:
		for section in divisions.size() - 1:
			var start: float = divisions[section]
			var end: float = divisions[section + 1]
			var tint := Color(0.93, 0.93, 0.93) if section % 2 else Color.WHITE
			var corner := Vector3(side * x, 0, -start if side < 0 else -end)
			_panel(
				corner,
				Vector3(0, 0, (end - start) * side),
				Vector3(0, H, 0),
				_wall_ps(tint),
				0.5,
				LAYER_WEST if side < 0 else LAYER_EAST
			)
	# #176 photo-visible wall panel joins and high ventilation slots.
	for side in [-1.0, 1.0]:
		for z in [-4.0, -13.0, -22.0]:
			_box(Vector3(side * (x - 0.012), 5.10, z), Vector3(0.018, 0.15, 1.14), Color("#647587"))
			var vent := _box(
				Vector3(side * (x - 0.024), 5.10, z), Vector3(0.018, 0.11, 1.08), Color("#25313a")
			)
			vent.set_meta("wall_vent", true)
	_arch_end()
	_far_end()
	# skirting and cornice
	var white := ps(null, WHITE)
	var cornice := ps(
		load(DIR + "textures/cornice-ivory.svg"), Color.WHITE, Vector2(0.7, 0.7), true
	)
	# Reference-led plaster roll/cove, within the existing 0.50 x 0.22 envelope.
	# The crop establishes rounded relief, not measured molding dimensions.
	var cornice_section := [
		Vector2(0, 0),
		Vector2(0, 0.075),
		Vector2(0.025, 0.075),
		Vector2(0.035, 0.092),
		Vector2(0.05, 0.111),
		Vector2(0.07, 0.127),
		Vector2(0.095, 0.139),
		Vector2(0.12, 0.142),
		Vector2(0.145, 0.137),
		Vector2(0.165, 0.125),
		Vector2(0.18, 0.11),
		Vector2(0.20, 0.11),
		Vector2(0.23, 0.114),
		Vector2(0.26, 0.123),
		Vector2(0.29, 0.137),
		Vector2(0.32, 0.155),
		Vector2(0.35, 0.178),
		Vector2(0.38, 0.206),
		Vector2(0.395, 0.22),
		Vector2(0.435, 0.22),
		Vector2(0.46, 0.205),
		Vector2(0.48, 0.16),
		Vector2(0.50, 0),
	]
	for s in [-1.0, 1.0]:
		(
			_box(Vector3(s * (x - 0.04), 0.12, -L / 2), Vector3(0.08, 0.24, L), WHITE, 1, white)
			. set_meta("baseboard", true)
		)
		(
			_box(Vector3(s * (x - 0.06), 0.255, -L / 2), Vector3(0.12, 0.05, L), WHITE, 1, white)
			. set_meta("baseboard", true)
		)
		_trim_profile(
			Vector3(s * x, H - 0.50, 0),
			Vector3.UP,
			Vector3(0, 0, -L),
			cornice_section,
			cornice,
			Vector3(-s, 0, 0)
		)
	for z in [0.0, -L]:
		_trim_profile(
			Vector3(-x, H - 0.50, z),
			Vector3.UP,
			Vector3(W, 0, 0),
			cornice_section,
			cornice,
			Vector3(0, 0, -1 if z == 0.0 else 1)
		)
	# barrel vault from the cornice, end lunettes, and the long skylight curving
	# with it, lamps along its edges
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var gl := SurfaceTool.new()
	gl.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs := 36
	var vault := Color("#e2dccd")
	var arc := 0.0
	var glass_edge := Vector3.ZERO
	var skylight_section := [
		Vector2(0, 0),
		Vector2(0, 0.035),
		Vector2(0.045, 0.035),
		Vector2(0.045, 0.075),
		Vector2(0.12, 0.075),
		Vector2(0.12, 0.045),
		Vector2(0.22, 0.045),
		Vector2(0.22, 0)
	]
	for i in segs:
		var a0 := PI * i / segs
		var a1 := PI * (i + 1) / segs
		var p0 := Vector3(-cos(a0) * x, H + sin(a0) * VAULT_RISE, 0)
		var p1 := Vector3(-cos(a1) * x, H + sin(a1) * VAULT_RISE, 0)
		var seg_len := p0.distance_to(p1)
		var glass := absf((p0.x + p1.x) / 2.0) < SKY_W / 2.0
		var z0 := -0.9 if glass else 0.0
		var z1 := -L + 0.9 if glass else -L
		if glass:  # the glazing: its own strip, its grid following the curve
			var u0 := arc / SKY_W
			var u1 := (arc + seg_len) / SKY_W
			var q := [
				p0 + Vector3(0, 0, z0),
				p1 + Vector3(0, 0, z0),
				p1 + Vector3(0, 0, z1),
				p0 + Vector3(0, 0, z1)
			]
			var qu := [
				Vector2(u0, 0),
				Vector2(u1, 0),
				Vector2(u1, (z0 - z1) / SKY_W),
				Vector2(u0, (z0 - z1) / SKY_W)
			]
			for k in [0, 1, 2, 0, 2, 3]:
				gl.set_uv(qu[k])
				gl.add_vertex(q[k])
			arc += seg_len
			glass_edge = p1
			for end in [z0, z1]:
				_trim_profile(
					p0 + Vector3(0, -0.01, end),
					Vector3(0, 0, 1 if end == z0 else -1),
					p1 - p0,
					skylight_section,
					cornice,
					Vector3.DOWN
				)
			# the frame of the glazing at both ends
			for zz in [0.0, -L]:
				var zi := -0.9 if zz == 0.0 else -L + 0.9
				var cap := [
					p0 + Vector3(0, 0, zz),
					p1 + Vector3(0, 0, zz),
					p1 + Vector3(0, 0, zi),
					p0 + Vector3(0, 0, zz),
					p1 + Vector3(0, 0, zi),
					p0 + Vector3(0, 0, zi)
				]
				if zz < 0:
					cap.reverse()  # both end strips face into the gallery
				for v in cap:
					st.set_color(vault * Color(0.85, 0.85, 0.85))
					st.add_vertex(v)
		else:
			# the cove darkens toward the cornice, brightens toward the light
			var up := 0.5 + 0.5 * sin((a0 + a1) / 2.0)
			var shade := lerpf(0.66, 1.02, up)
			st.set_color(vault * Color(shade, shade, shade))
			for v in [
				p0, p1, p1 + Vector3(0, 0, -L), p0, p1 + Vector3(0, 0, -L), p0 + Vector3(0, 0, -L)
			]:
				st.add_vertex(v)
		st.set_color(vault * Color(0.82, 0.82, 0.8))
		for z in [0.0, -L]:  # the end lunettes
			var lunette := [Vector3(0, H, z), p0 + Vector3(0, 0, z), p1 + Vector3(0, 0, z)]
			if z == 0:
				lunette.reverse()
			for v in lunette:
				st.add_vertex(v)
	for side in [-1.0, 1.0]:
		_trim_profile(
			Vector3(side * glass_edge.x, glass_edge.y - 0.01, -0.9),
			Vector3(side, 0, 0),
			Vector3(0, 0, -L + 1.8),
			skylight_section,
			cornice,
			Vector3.DOWN
		)
	var vmi := MeshInstance3D.new()
	vmi.mesh = load(DIR + "cpu_geometry.gd").commit(st)
	vmi.set_meta("vault", true)
	vmi.material_override = ps(null, Color.WHITE, Vector2.ONE, true)
	_vp.add_child(vmi)
	var gmi := MeshInstance3D.new()
	gmi.mesh = load(DIR + "cpu_geometry.gd").commit(gl)
	gmi.material_override = ps(load(DIR + "textures/skylight-grid-168.svg"), Color.WHITE)
	_vp.add_child(gmi)
	# track lamps along both edges of the glazing, aimed at the walls
	var edge_y := H + VAULT_RISE * sqrt(maxf(0.0, 1.0 - pow(SKY_W / 2.0 / x, 2))) - 0.12
	var lamp := ps(null, Color("#2a2a2a"))
	var z := -1.6
	while z > -L + 1.2:
		for sx in [-1.0, 1.0]:
			var head := _box(
				Vector3(sx * (SKY_W / 2.0 + 0.15), edge_y, z),
				Vector3(0.14, 0.14, 0.2),
				Color.BLACK,
				1,
				lamp
			)
			head.rotation.z = sx * 0.7
			_box(
				Vector3(sx * (SKY_W / 2.0 + 0.2), edge_y - 0.09, z),
				Vector3(0.1, 0.03, 0.1),
				Color.BLACK,
				1,
				ps(null, Color("#ffe9b8"))
			)
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
		for rail_x in [-0.39, 0.39]:
			_box(Vector3(rail_x, 0.265, bz), Vector3(0.035, 0.05, 2.82), Color("#242325"))
		for rail_z in [-1.39, 1.39]:
			_box(Vector3(0, 0.265, bz + rail_z), Vector3(0.81, 0.05, 0.035), Color("#242325"))
		for lx in [-0.38, 0.38]:
			for lz in [-1.38, -0.46, 0.46, 1.38]:
				# Four supports per long side and turned collars are visible in gallery-2456.
				var leg := MeshInstance3D.new()
				var shaft := CylinderMesh.new()
				shaft.top_radius = 0.026
				shaft.bottom_radius = 0.019
				shaft.height = 0.26
				shaft.radial_segments = 12
				leg.mesh = shaft
				leg.position = Vector3(lx, 0.13, bz + lz)
				leg.material_override = ps(null, Color("#242325"))
				leg.set_meta("bench_leg", true)
				_vp.add_child(leg)
				for y in [0.18, 0.22]:
					var collar := MeshInstance3D.new()
					var ring := SphereMesh.new()
					ring.radius = 0.034
					ring.height = 0.025
					ring.radial_segments = 12
					ring.rings = 6
					collar.mesh = ring
					collar.position = Vector3(lx, y, bz + lz)
					collar.material_override = leg.material_override
					_vp.add_child(collar)


# Rounded-rectangle distance keeps the entire cushion rim at one height.
func _bench_crown(x: float, z: float) -> float:
	var q := Vector2(absf(x) - 0.385, absf(z) - 1.41)
	var edge := 0.09 - q.max(Vector2.ZERO).length() - minf(maxf(q.x, q.y), 0.0)
	var t := clampf(edge / 0.13, 0.0, 1.0)
	return 0.355 + 0.065 * sin(t * PI / 2.0)


# Source-led upholstery: rounded edges and paired button depressions, same bounds.
func _bench_surface(x: float, z: float) -> Vector3:
	var corner := Vector2(maxf(absf(x) - 0.385, 0), maxf(absf(z) - 1.41, 0))
	if corner.length() > 0.09:
		corner = corner.normalized() * 0.09
		x = signf(x) * (0.385 + corner.x)
		z = signf(z) * (1.41 + corner.y)
	var height := _bench_crown(x, z)
	for bx in [-0.19, 0.19]:
		for bz in [-1.05, -0.63, -0.21, 0.21, 0.63, 1.05]:
			var distance := Vector2(x - bx, z - bz).length_squared()
			height -= 0.035 * exp(-distance / 0.007)
	return Vector3(x, height, z)


func _bench_cushion(z: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 96:
		for column in 32:
			var quad: Array[Vector3] = []
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				quad.append(
					_bench_surface(
						-0.475 + (column + offset.x) * 0.95 / 32, -1.5 + (row + offset.y) * 3.0 / 96
					)
				)
			for i in [0, 1, 2, 0, 2, 3]:
				var point := quad[i]
				var dx := (
					_bench_surface(point.x + 0.001, point.z)
					- _bench_surface(point.x - 0.001, point.z)
				)
				var dz := (
					_bench_surface(point.x, point.z + 0.001)
					- _bench_surface(point.x, point.z - 0.001)
				)
				st.set_normal(dz.cross(dx).normalized())
				# Authored cavity occlusion follows the modeled tuft depth, not painted buttons.
				var crown := _bench_crown(point.x, point.z)
				st.set_color(
					Color.WHITE * lerpf(1.0, 0.75, clampf((crown - point.y) / 0.035, 0, 1))
				)
				st.set_uv(Vector2(point.x, point.z) * 1.8)
				st.add_vertex(point + Vector3(0, 0, z))
	# Match the sampled top edge with a rounded lower welt, without box corners.
	var perimeter: Array[Vector3] = []
	for edge in 4:
		var count := 32 if edge % 2 == 0 else 96
		for i in count:
			var t := float(i) / count
			var point := (
				Vector2(-0.475 + t * 0.95, -1.5)
				if edge == 0
				else (
					Vector2(0.475, -1.5 + t * 3)
					if edge == 1
					else (
						Vector2(0.475 - t * 0.95, 1.5)
						if edge == 2
						else Vector2(-0.475, 1.5 - t * 3)
					)
				)
			)
			perimeter.append(_bench_surface(point.x, point.y))
	st.set_color(Color.WHITE)
	for i in perimeter.size():
		var a := perimeter[i]
		var b := perimeter[(i + 1) % perimeter.size()]
		for level in 12:
			var quad: Array[Vector3] = []
			for spec in [
				Vector2(0, level), Vector2(1, level), Vector2(1, level + 1), Vector2(0, level + 1)
			]:
				var point := a if spec.x == 0 else b
				var inset := 0.025 * (1 - cos(spec.y / 12 * PI / 2))
				quad.append(
					Vector3(
						point.x - signf(point.x) * inset,
						lerpf(point.y, 0.30, sin(spec.y / 12 * PI / 2)),
						point.z - signf(point.z) * inset
					)
				)
			for index in [0, 2, 1, 0, 3, 2]:
				var point := quad[index]
				var outward := (
					Vector2(
						point.x - clampf(point.x, -0.385, 0.385),
						point.z - clampf(point.z, -1.41, 1.41)
					)
					. normalized()
				)
				var angle := float(level + (1 if index >= 2 else 0)) / 12 * PI / 2
				st.set_normal(Vector3(outward.x * cos(angle), -sin(angle), outward.y * cos(angle)))
				st.set_uv(
					(
						Vector2(
							float(i + (1 if index in [1, 2] else 0)) / perimeter.size() * 7.8,
							point.y
						)
						* 1.8
					)
				)
				st.add_vertex(quad[index] + Vector3(0, 0, z))
	var seat := MeshInstance3D.new()
	seat.mesh = load(DIR + "cpu_geometry.gd").commit(st)
	seat.material_override = ps(
		load(DIR + "textures/bench-cloth-muse.webp"), Color(1.1, 1.1, 1.1), Vector2.ONE, true
	)
	seat.set_meta("bench_cushion", true)
	_vp.add_child(seat)
	# Fabric-covered buttons sit inside the modeled depressions in the source bench.
	for bx in [-0.19, 0.19]:
		for bz in [-1.05, -0.63, -0.21, 0.21, 0.63, 1.05]:
			var button := MeshInstance3D.new()
			var dome := SphereMesh.new()
			dome.radius = 0.007
			dome.height = 0.004
			dome.radial_segments = 12
			dome.rings = 6
			button.mesh = dome
			button.position = _bench_surface(bx, bz) + Vector3(0, 0.003, z)
			button.material_override = ps(
				load(DIR + "textures/bench-cloth-muse.webp"), Color(1.1, 1.1, 1.1)
			)
			_vp.add_child(button)


func _rect_floor() -> void:  # under the planks, never seen: only there so nothing shows through
	var m := ps(null, Color("#6b5234"))
	var f := _panel(
		Vector3(-W / 2, -0.003, 0),
		Vector3(W, 0, 0),
		Vector3(0, 0, -L),
		m,
		8.0,
		1,
		func(_p: Vector3) -> float: return 1.0
	)
	f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


# Herringbone oak as geometry: planks PLANK long and wide, each a random stretch of
# the Muse oak grain with its own
# tone and the room's occlusion, laid on the lattice (b, b), (a, -a) turned 45
# degrees so the zigzag runs down the
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
	var edge_pad := 0.5 * (a + b) / sqrt(2.0) + 0.05
	for j in range(-m, m + 1):
		for k in range(-n, n + 1):
			var o := Vector2(k * b + j * a, k * b - j * a)
			for vert in [false, true]:
				var r := (
					Rect2(o, Vector2(a, b)) if not vert else Rect2(o + Vector2(0, b), Vector2(b, a))
				)
				var c := rot * r.get_center()
				if absf(c.x) > W / 2 + edge_pad or c.y > edge_pad or c.y < -L - edge_pad:
					continue
				var p := [
					r.position,
					Vector2(r.end.x, r.position.y),
					r.end,
					Vector2(r.position.x, r.end.y)
				]
				# Local board UV lets the baked oak shader stay inside one source
				# board; alpha carries a stable random crop for this modeled plank.
				var uv := [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
				var uv2 := [Vector2(0, 0), Vector2(a, 0), Vector2(a, b), Vector2(0, b)]
				if vert:
					uv = [uv[3], uv[0], uv[1], uv[2]]
					uv2 = [Vector2(0, b), Vector2(0, 0), Vector2(a, 0), Vector2(a, b)]
				# The source crop has narrow board-to-board variation; retain the
				# authored lattice, UVs and grain but quiet the orange stripe effect.
				var tone := rng.randf_range(0.97, 1.03)
				var warmth := rng.randf_range(-0.018, 0.018)
				var crop_seed := rng.randf()
				for i in [0, 1, 2, 0, 2, 3]:
					var q: Vector2 = rot * p[i]
					var w := Vector3(q.x, 0, q.y)
					var o2 := _ao(w, false) * tone
					st.set_color(Color(o2 * (1.0 + warmth), o2, o2 * (1.0 - warmth), crop_seed))
					st.set_normal(Vector3.UP)
					st.set_uv(uv[i])
					st.set_uv2(uv2[i])
					st.add_vertex(w)
	# The renovation photographs show straight-laid boards framing both long
	# sides of the herringbone field. This is an isolated geometry trial, not a
	# measured reconstruction; each overlay board still gets a distinct atlas
	# face and authored baked contact.
	for side in [-1, 1]:
		for border_row in range(2):
			var x0 := -W / 2.0 + border_row * b if side < 0 else W / 2.0 - (border_row + 1) * b
			var x1 := x0 + b
			for segment in range(ceili(L / a)):
				var z0 := -L + segment * a
				var z1 := minf(z0 + a, 0.0)
				var board_length := z1 - z0
				var border_tone := rng.randf_range(0.97, 1.03)
				var border_seed := rng.randf()
				var points := [
					Vector3(x0, 0.002, z0),
					Vector3(x0, 0.002, z1),
					Vector3(x1, 0.002, z1),
					Vector3(x1, 0.002, z0)
				]
				var board_uv := [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
				var board_uv2 := [
					Vector2(0, 0), Vector2(board_length, 0), Vector2(board_length, b), Vector2(0, b)
				]
				for i in [0, 1, 2, 0, 2, 3]:
					var shade := _ao(points[i], false) * border_tone
					st.set_color(Color(shade, shade, shade, border_seed))
					st.set_normal(Vector3.UP)
					st.set_uv(board_uv[i])
					st.set_uv2(board_uv2[i])
					st.add_vertex(points[i])
	var mat := ps(
		load(DIR + "textures/oak-board-atlas-168-v3.webp"),
		Color(1.18, 1.16, 1.14),
		Vector2.ONE,
		true
	)
	mat.set_shader_parameter("plank_seams", true)
	mat.set_shader_parameter("oak_atlas", true)
	# herringbone has T-junctions: snapped corners would open cracks
	mat.set_shader_parameter("jitter", 0.0)
	mat.set_shader_parameter("plank", PLANK)
	var mi := MeshInstance3D.new()
	mi.mesh = _conform_floor_edges(st.commit_to_arrays())
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_vp.add_child(mi)


## Split each plank at its neighbors' corners: Web rasterization exposes T-junctions.
## Preserve interpolated texture, color and lighting UVs, including in saved bakes.
static func _conform_floor_edges(arrays: Array) -> ArrayMesh:
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	assert(vertices.size() % 6 == 0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var lattice := Transform2D(PI / 4, Vector2(0, -L / 2))
	var inverse := lattice.affine_inverse()
	for start in range(0, vertices.size(), 6):
		var corners := [start, start + 1, start + 2, start + 5]
		var perimeter: Array[Vector4] = []
		for edge in 4:
			var weights := Vector4.ZERO
			weights[edge] = 1.0
			perimeter.append(weights)
			var next := (edge + 1) % 4
			if vertices[corners[edge]].distance_to(vertices[corners[next]]) > PLANK.y * 1.5:
				var fraction := (
					(PLANK.x - PLANK.y) / PLANK.x if edge % 2 == 0 else PLANK.y / PLANK.x
				)
				weights[edge] = 1.0 - fraction
				weights[next] = fraction
				perimeter.append(weights)
		for edge in perimeter.size():
			for weights in [
				Vector4(0.25, 0.25, 0.25, 0.25),
				perimeter[edge],
				perimeter[(edge + 1) % perimeter.size()]
			]:
				var position := Vector3.ZERO
				var uv := Vector2.ZERO
				var uv2 := Vector2.ZERO
				var color := Color(0, 0, 0, 0)
				for corner in 4:
					var index: int = corners[corner]
					position += vertices[index] * weights[corner]
					uv += arrays[Mesh.ARRAY_TEX_UV][index] * weights[corner]
					uv2 += arrays[Mesh.ARRAY_TEX_UV2][index] * weights[corner]
					color += arrays[Mesh.ARRAY_COLOR][index] * weights[corner]
				st.set_normal(Vector3.UP)
				st.set_uv(uv)
				st.set_uv2(uv2)
				st.set_color(color)
				# Identical lattice points must survive float arithmetic identically.
				var planar := (
					lattice
					* (inverse * Vector2(position.x, position.z)).snapped(Vector2.ONE * 0.0001)
				)
				st.add_vertex(Vector3(planar.x, position.y, planar.y))
	return load(DIR + "cpu_geometry.gd").commit(st)


## #177: clipped passage planks need shared endpoints, including partial triangles.
## Keep UV/color/lightmap interpolation; no material or bake changes.
## ponytail: passage-only quadratic edge scan; spatial buckets if geometry grows.
static func _conform_portal_edges(arrays: Array) -> ArrayMesh:
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var points := {}
	for index in vertices.size():
		var position := vertices[index].snapped(Vector3.ONE * 0.0001)
		for existing: Vector3 in points:
			if position.distance_to(existing) < 0.00015:
				position = existing
				break
		vertices[index] = position
		points[position] = true
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for start in range(0, vertices.size(), 3):
		if (
			(
				(vertices[start + 1] - vertices[start])
				. cross(vertices[start + 2] - vertices[start])
				. length_squared()
			)
			< 0.0000000001
		):
			continue
		var perimeter := []
		for edge in 3:
			var next := (edge + 1) % 3
			var a := vertices[start + edge].snapped(Vector3.ONE * 0.0001)
			var b := vertices[start + next].snapped(Vector3.ONE * 0.0001)
			var direction := b - a
			var cuts := []
			if direction.length_squared() == 0.0:
				continue
			for point: Vector3 in points:
				var fraction := (point - a).dot(direction) / direction.length_squared()
				if (
					fraction >= 0.0
					and fraction < 1.0
					and point.distance_to(a + direction * fraction) < 0.00011
				):
					var weights := Vector3.ZERO
					weights[edge] = 1.0 - fraction
					weights[next] = fraction
					cuts.append([point, weights, fraction])
			cuts.sort_custom(func(a, b): return a[2] < b[2])
			perimeter.append_array(cuts)
		var center := (vertices[start] + vertices[start + 1] + vertices[start + 2]) / 3.0
		for edge in perimeter.size():
			for sample in [
				[center, Vector3.ONE / 3.0],
				perimeter[edge],
				perimeter[(edge + 1) % perimeter.size()]
			]:
				var uv := Vector2.ZERO
				var uv2 := Vector2.ZERO
				var color := Color(0, 0, 0, 0)
				for corner in 3:
					uv += arrays[Mesh.ARRAY_TEX_UV][start + corner] * sample[1][corner]
					color += arrays[Mesh.ARRAY_COLOR][start + corner] * sample[1][corner]
					if arrays[Mesh.ARRAY_TEX_UV2] != null:
						uv2 += arrays[Mesh.ARRAY_TEX_UV2][start + corner] * sample[1][corner]
				st.set_normal(Vector3.UP)
				st.set_uv(uv)
				st.set_uv2(uv2)
				st.set_color(color)
				st.add_vertex(sample[0])
	return load(DIR + "cpu_geometry.gd").commit(st)


func _arch_end() -> void:
	var x := W / 2.0
	var door: Dictionary = DOORS.arch
	var ds: Vector2 = door.size
	var dw := ds.x / 2.0
	var side := x - dw
	var white := ps(load(DIR + "textures/ivory-trim.svg"), Color.WHITE, Vector2(0.7, 0.7), true)
	_panel(Vector3(x, 0, 0), Vector3(-side, 0, 0), Vector3(0, H, 0), _wall_ps(), 0.5, 1)
	_panel(Vector3(-dw, 0, 0), Vector3(-side, 0, 0), Vector3(0, H, 0), _wall_ps(), 0.5, 1)
	_panel(Vector3(dw, ds.y, 0), Vector3(-ds.x, 0, 0), Vector3(0, H - ds.y, 0), _wall_ps(), 0.5, 1)
	# Same source-led plaster moulding construction as the opposite doorway.
	var casing := [
		Vector2(0, 0),
		Vector2(0, 0.10),
		Vector2(0.018, 0.125),
		Vector2(0.042, 0.125),
		Vector2(0.06, 0.105),
		Vector2(0.075, 0.075),
		Vector2(0.27, 0.075),
		Vector2(0.285, 0.09),
		Vector2(0.305, 0.09),
		Vector2(0.32, 0.06),
		Vector2(0.32, 0)
	]
	var skirting := [
		Vector2(0, 0),
		Vector2(0, 0.07),
		Vector2(0.035, 0.07),
		Vector2(0.05, 0.055),
		Vector2(0.18, 0.055),
		Vector2(0.20, 0.067),
		Vector2(0.225, 0.065),
		Vector2(0.24, 0.035),
		Vector2(0.24, 0)
	]
	for s in [-1.0, 1.0]:
		_trim_profile(
			Vector3(s * (dw + 0.36), 0, 0),
			Vector3.UP,
			Vector3(s * (side - 0.36), 0, 0),
			skirting,
			white,
			Vector3.FORWARD
		)
		_trim_profile(
			Vector3(s * dw, 0.26, 0),
			Vector3(s, 0, 0),
			Vector3(0, ds.y - 0.26, 0),
			casing,
			white,
			Vector3.FORWARD
		)
		var plinth := [
			Vector2(0, 0),
			Vector2(0, 0.12),
			Vector2(0.02, 0.14),
			Vector2(0.34, 0.14),
			Vector2(0.36, 0.12),
			Vector2(0.36, 0)
		]
		_trim_profile(
			Vector3(s * dw, 0, 0),
			Vector3(s, 0, 0),
			Vector3(0, 0.26, 0),
			plinth,
			white,
			Vector3.FORWARD
		)
	_trim_profile(
		Vector3(-dw - 0.32, ds.y, 0),
		Vector3.UP,
		Vector3(ds.x + 0.64, 0, 0),
		casing,
		white,
		Vector3.FORWARD
	)
	var crown := [
		Vector2(0, 0),
		Vector2(0, 0.065),
		Vector2(0.025, 0.09),
		Vector2(0.055, 0.14),
		Vector2(0.075, 0.15),
		Vector2(0.10, 0.15),
		Vector2(0.10, 0)
	]
	_trim_profile(
		Vector3(-dw - 0.38, ds.y + 0.32, 0),
		Vector3.UP,
		Vector3(ds.x + 0.76, 0, 0),
		crown,
		white,
		Vector3.FORWARD
	)
	_panel(
		Vector3(0.17, ds.y + 0.55, -0.071),
		Vector3(-0.34, 0, 0),
		Vector3(0, 0.15, 0),
		ps(load(DIR + "textures/exit-sign.svg"), Color.WHITE, Vector2(1.0 / 0.34, 1.0 / 0.15))
	)
	# Reveal normals face into the opening, where the baked light arrives.
	var zr := 0.45
	var rev := ps(null, Color("#dcd5c6"), Vector2.ONE, true)
	var deep := func(p: Vector3) -> float: return lerpf(0.9, 0.62, clampf(p.z / zr, 0.0, 1.0))
	_panel(Vector3(-dw, 0, zr), Vector3(0, 0, -zr), Vector3(0, ds.y, 0), rev, 0.3, 1, deep)
	_panel(Vector3(dw, 0, 0), Vector3(0, 0, zr), Vector3(0, ds.y, 0), rev, 0.3, 1, deep)
	_panel(Vector3(-dw, ds.y, 0), Vector3(ds.x, 0, 0), Vector3(0, 0, zr), rev, 0.3, 1, deep)
	# the stone portal: a shallow round arch, rising just past the door head
	var z0 := zr
	var z1 := zr + PORTAL_DEPTH
	_portal_stone(dw, ds.y, z0, z1)
	# the medieval gallery beyond: lit warm toward the crucifix. Its far wall stays where the
	# deep portal left it (0.45 + 1.2 + 5.0); the room gains the floor the stone gave up.
	var zb := 6.65
	var beyond := zb - z1
	var room := ps(null, Color("#56606b"), Vector2.ONE, true)
	var lit := func(p: Vector3) -> float:
		return lerpf(0.55, 1.05, clampf((p.z - z1) / beyond, 0.0, 1.0))
	_panel(Vector3(-3.0, 0, zb), Vector3(0, 0, -zb), Vector3(0, 5.0, 0), room, 1.0, 1, lit)
	_panel(Vector3(3.0, 0, 0), Vector3(0, 0, zb), Vector3(0, 5.0, 0), room, 1.0, 1, lit)
	# Visible reverse face of the existing wall, with outward-facing normals.
	# Extending the side returns to this plane closes the former floor-edge gaps.
	_panel(Vector3(-3.0, 0, 0.01), Vector3(3.0 - dw, 0, 0), Vector3(0, 5.0, 0), room, 0.5, 1, lit)
	_panel(Vector3(dw, 0, 0.01), Vector3(3.0 - dw, 0, 0), Vector3(0, 5.0, 0), room, 0.5, 1, lit)
	_panel(
		Vector3(-dw, ds.y, 0.01), Vector3(ds.x, 0, 0), Vector3(0, 5.0 - ds.y, 0), room, 0.5, 1, lit
	)
	_panel(Vector3(3.0, 0, zb + 0.01), Vector3(-6.0, 0, 0), Vector3(0, 5.0, 0), room, 1.0, 1, lit)
	_panel(
		Vector3(-3.0, 5.0, z1),
		Vector3(6.0, 0, 0),
		Vector3(0, 0, beyond),
		ps(null, Color("#8c8579"), Vector2.ONE, true),
		1.0,
		1,
		lit
	)
	_portal_floor(zb)
	var card := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(6.0, 5.0)
	card.mesh = qm
	card.material_override = ps(load(DIR + "textures/door-arch.jpg"), Color(1.08, 1.04, 0.98))
	card.position = Vector3(0, 2.5, zb - 0.01)
	card.rotation.y = PI
	_vp.add_child(card)


func _portal_floor(end: float) -> void:
	# Continue the same plank lattice without extending the gallery's clipped mesh.
	# This is the visible walkable passage floor, with no overlay above it.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := 0.84  # Retain passage geometry until its separate transition repair.
	var b := 0.18
	var rot := Transform2D(PI / 4, Vector2(0, -L / 2))
	var clip := PackedVector2Array(
		[Vector2(-3, 0), Vector2(3, 0), Vector2(3, end), Vector2(-3, end)]
	)
	var reach := (L + W) * 0.75
	var n := int(reach / b)
	var m := int(reach / a) + 1
	var rng := RandomNumberGenerator.new()
	rng.seed = 1877
	for j in range(-m, m + 1):
		for k in range(-n, n + 1):
			var o := Vector2(k * b + j * a, k * b - j * a)
			for vertical in [false, true]:
				var r := (
					Rect2(o, Vector2(a, b))
					if not vertical
					else Rect2(o + Vector2(0, b), Vector2(b, a))
				)
				var c := rot * r.get_center()
				# Replay gallery plank selection so a plank crossing z=0 retains
				# the same grain strip and tone on both sides of the clipping plane.
				var v0 := 0.09 * posmod(j * 11 + k * 3, 7)
				var tone := 0.90 + 0.025 * posmod(j * 7 + k * 13, 7)
				if absf(c.x) <= W / 2 + 0.4 and c.y <= 0.4 and c.y >= -L - 0.4:
					v0 = rng.randf_range(0.0, 2.0 / 3.0)
					tone = rng.randf_range(0.9, 1.06)
				if absf(c.x) > 3.5 or c.y < -0.5 or c.y > end + 0.5:
					continue
				var corners := PackedVector2Array(
					[
						rot * r.position,
						rot * Vector2(r.end.x, r.position.y),
						rot * r.end,
						rot * Vector2(r.position.x, r.end.y)
					]
				)
				for polygon in Geometry2D.intersect_polygons(corners, clip):
					var indices := Geometry2D.triangulate_polygon(polygon)
					for index in indices:
						var p: Vector2 = polygon[index]
						var local: Vector2 = (rot.affine_inverse() * p - r.position) / r.size
						var u := local.y if vertical else local.x
						var v := 1.0 - local.x if vertical else local.y
						st.set_normal(Vector3.UP)
						st.set_uv(Vector2(u, v0 + v / 3.0))
						st.set_color(Color(tone, tone * 0.99, tone * 0.97))
						st.add_vertex(Vector3(p.x, -0.002, p.y))
	var mesh := MeshInstance3D.new()
	mesh.mesh = _conform_portal_edges(st.commit_to_arrays())
	mesh.material_override = ps(
		load(DIR + "textures/oak-muse.webp"), Color.WHITE, Vector2.ONE, true
	)
	mesh.set_meta("portal_floor", true)
	mesh.set_meta("portal_floor_end", end)
	_vp.add_child(mesh)


func _portal_relief_sample(data: Array, width: int, height: int, u: float, v: float) -> float:
	var px := clampf(u, 0.0, 1.0) * (width - 1)
	var py := clampf(v, 0.0, 1.0) * (height - 1)
	var ix := mini(int(px), width - 2)
	var iy := mini(int(py), height - 2)
	var a: float = lerpf(data[iy * width + ix], data[iy * width + ix + 1], px - ix)
	var b: float = lerpf(data[(iy + 1) * width + ix], data[(iy + 1) * width + ix + 1], px - ix)
	return lerpf(a, b, py - iy) / 255.0


func _portal_stone(radius: float, height: float, rear: float, front: float) -> void:
	# #167: photo-led orders and supports, not a survey or invented capital carving.
	# Retain the existing opening; all additions remain outside it.
	var spring := height - radius * 0.75
	# The backing runs behind the plaster reveal to the Hall wall (reverse face at z = 0.01):
	# the frontispiece stands against the wall, not in front of a gap.
	var wall := 0.02
	var relief: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(DIR + "portal-capital-relief.json")
	)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var capital_st := SurfaceTool.new()
	capital_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var builder := {"current": st}
	var winding := {"failures": 0}
	var stone_patch := {"index": 0, "tone": 1.0}
	var vary := func(seed_value: int) -> void:
		stone_patch.index = posmod(seed_value, 5)
		stone_patch.tone = 0.94 + 0.025 * posmod(seed_value, 5)
	var patch_origin := func() -> Vector2:
		return [
			Vector2(0.025, 0.025),
			Vector2(0.36, 0.025),
			Vector2(0.69, 0.025),
			Vector2(0.22, 0.36),
			Vector2(0.57, 0.70)
		][stone_patch.index]
	var face := func(
		q: Array, smooth: Array = [], supplied_uv: Array = [], expected_z := 0
	) -> void:
		var normal: Vector3 = (q[2] - q[0]).cross(q[1] - q[0]).normalized()
		# Sample grain inside one existing limestone block, not its rectangular joints.
		var size := Vector2((q[1] - q[0]).length(), (q[3] - q[0]).length())
		size *= 0.22
		if maxf(size.x, size.y) > 0.10:
			size *= 0.10 / maxf(size.x, size.y)
		var origin: Vector2 = patch_origin.call()
		var uv := [origin, origin + Vector2(size.x, 0), origin + size, origin + Vector2(0, size.y)]
		if not supplied_uv.is_empty():
			uv = supplied_uv
		var triangles := [0, 1, 2, 0, 2, 3]
		for offset in triangles.size():
			var i: int = triangles[offset]
			var triangle: int = int(offset / 3) * 3
			var a: Vector3 = q[triangles[triangle]]
			var geometric: Vector3 = (
				(q[triangles[triangle + 2]] - a).cross(q[triangles[triangle + 1]] - a).normalized()
			)
			# Independent topology check for parameterized relief: front and
			# back half-surfaces have known outward Z signs, before shading.
			if offset % 3 == 0 and expected_z != 0 and geometric.z * expected_z < -0.000001:
				winding.failures += 1
			var shading: Vector3 = normal if smooth.is_empty() else smooth[i]
			# A carved crease must use its own triangle plane, not an analytic
			# tangent across the ridge. Preserve smoothing only within 60 degrees.
			if not smooth.is_empty() and shading.dot(geometric) < 0.5:
				shading = geometric
			builder.current.set_normal(shading)
			builder.current.set_color(Color(stone_patch.tone, stone_patch.tone, stone_patch.tone))
			builder.current.set_uv(uv[i])
			builder.current.add_vertex(q[i])
	var block := func(center: Vector3, extent: Vector3) -> void:
		vary.call(roundi(center.x * 37 + center.y * 53 + center.z * 17))
		var p: Array = []
		for z in [-1, 1]:
			for y in [-1, 1]:
				for x in [-1, 1]:
					p.append(center + Vector3(x, y, z) * extent * 0.5)
		for corners in [
			[0, 2, 3, 1], [4, 5, 7, 6], [0, 4, 6, 2], [1, 3, 7, 5], [0, 1, 5, 4], [2, 6, 7, 3]
		]:
			face.call([p[corners[3]], p[corners[2]], p[corners[1]], p[corners[0]]])
	# Smooth tunnel intrados, aligned with the photographed round opening.
	vary.call(0)
	for k in 32:
		var a := PI * k / 32.0
		var b := PI * (k + 1) / 32.0
		var p := Vector3(-radius * cos(a), spring + radius * sin(a), rear)
		var q := Vector3(-radius * cos(b), spring + radius * sin(b), rear)
		for strip in 6:
			var lo := Vector3(0, 0, (front - rear) * strip / 6.0)
			var hi := Vector3(0, 0, (front - rear) * (strip + 1) / 6.0)
			# Close the round-to-rectangular soffit junction at the existing
			# plaster reveal. Only the rear strip tapers to the unchanged head.
			var plo := p + lo
			var qlo := q + lo
			if strip == 0:
				plo.y = minf(plo.y, height)
				qlo.y = minf(qlo.y, height)
			# One continuous grain coordinate across the curved soffit.
			var uv := [
				Vector2(a * radius, hi.z),
				Vector2(b * radius, hi.z),
				Vector2(b * radius, lo.z),
				Vector2(a * radius, lo.z)
			]
			for index in 4:
				uv[index] = Vector2(0.025, 0.025) + uv[index] * 0.02
			face.call([p + hi, q + hi, qlo, plo], [], uv)
	for side in [-1.0, 1.0]:
		# Match the visible backing courses instead of stretching one texture
		# patch over the full-height jamb.
		for course in 6:
			block.call(
				Vector3(side * (radius + 0.15), (course + 0.5) * spring / 6, (rear + front) / 2),
				Vector3(0.3, spring / 6, front - rear)
			)
	# Three stepped concentric orders; the narrow radial joints are real gaps.
	for order in 3:
		var inner := radius + order * 0.27
		var outer := inner + 0.265
		var zf := front + order * 0.13
		# The inner order crosses the plaster reveal's head and stops at its end; the outer
		# two clear it and run back to the wall.
		var zb := maxf(zf - 0.21, rear) if order == 0 else wall
		var blocks: int = [13, 15, 17][order]
		var joint_angle := func(t: float) -> float:
			return PI * t + 0.008 * sin(5.0 * PI * t + order) * sin(PI * t)
		for k in blocks:
			vary.call(k * 7 + order * 13)
			var a: float = joint_angle.call(k / float(blocks))
			var b: float = joint_angle.call((k + 1) / float(blocks))
			var p: Array = []
			for z in [zf, zb]:
				p.append(Vector3(-inner * cos(a), spring + inner * sin(a), z))
				p.append(Vector3(-outer * cos(a), spring + outer * sin(a), z))
				p.append(Vector3(-outer * cos(b), spring + outer * sin(b), z))
				p.append(Vector3(-inner * cos(b), spring + inner * sin(b), z))
			for corners in [
				[0, 1, 2, 3], [7, 6, 5, 4], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]
			]:
				var q := [p[corners[0]], p[corners[1]], p[corners[2]], p[corners[3]]]
				if corners == [0, 1, 2, 3]:
					# Worn arris: a narrow real bevel around the stone's front face.
					var center: Vector3 = (q[0] + q[1] + q[2] + q[3]) * 0.25
					var inset: Array = []
					for point in q:
						inset.append(center + (point - center) * 0.96 + Vector3(0, 0, 0.007))
					face.call(inset)
					for edge in 4:
						var next := (edge + 1) % 4
						face.call([q[edge], q[next], inset[next], inset[edge]])
				else:
					face.call(q)
	# The official full-portal photograph shows a narrow fan-carved outer band.
	# Interpret its radial cuts as bounded geometry, without photo-depth sampling.
	builder.current = capital_st
	vary.call(0)
	var ornament := func(u: float, v: float) -> Vector3:
		var angle := PI * u
		var r := radius + 0.805 + v * 0.075
		var cell := Vector2(fposmod(u * 48.0, 1.0) * 2.0 - 1.0, v * 2.0 - 1.0)
		var cuts := absf(sin(atan2(cell.y, cell.x) * 3.0)) * smoothstep(0.12, 0.55, cell.length())
		var edge := smoothstep(0.0, 0.15, v) * smoothstep(0.0, 0.15, 1.0 - v)
		return Vector3(
			-r * cos(angle), spring + r * sin(angle), front + 0.266 + 0.022 * (1.0 - cuts) * edge
		)
	for segment in 384:
		var a := segment / 384.0
		var b := (segment + 1) / 384.0
		for row in 12:
			var lo := row / 12.0
			var hi := (row + 1) / 12.0
			var q := [
				ornament.call(a, lo),
				ornament.call(a, hi),
				ornament.call(b, hi),
				ornament.call(b, lo)
			]
			var uv: Array = []
			for point in q:
				uv.append(Vector2(0.10, 0.025) + Vector2(point.x, point.y) * 0.015)
			face.call(q, [], uv, 1)
		# Close the thin outer edge into the stone instead of leaving a ribbon.
		var p0: Vector3 = ornament.call(a, 1.0)
		var p1: Vector3 = ornament.call(b, 1.0)
		face.call([p0, p0 - Vector3(0, 0, 0.04), p1 - Vector3(0, 0, 0.04), p1])
	builder.current = st
	for side in [-1.0, 1.0]:
		# Backing courses and stepped impost support the three photographed shafts.
		for row in 6:
			block.call(
				Vector3(
					side * (radius + 0.55), (row + 0.5) * spring / 6, (wall + front + 0.18) / 2
				),
				Vector3(1.08, spring / 6, front + 0.18 - wall)
			)
		block.call(Vector3(side * (radius + 0.55), 0.11, front + 0.16), Vector3(1.14, 0.22, 0.64))
		# Source photos resolve the stepped impost above each shaft. Separate
		# surfaces keep real depth changes from stretching a strip across them.
		for section in 3:
			var section_width: float = [0.38, 0.232, 0.84][section]
			var center_x: float = side * (radius + [0.14, 0.37, 0.72][section])
			var face_z := front + 0.35 + section * 0.11
			var depth := face_z - (front - 0.12)
			block.call(
				Vector3(center_x, spring - 0.075, face_z - depth / 2),
				Vector3(section_width, 0.19, depth)
			)
			builder.current = capital_st
			var frieze := func(u: float, v: float) -> Vector3:
				var x := center_x + (u - 0.5) * section_width
				var photo_u: float = (x - (side * (radius + 0.55) - 0.59)) / 1.18
				var field: Array = relief.bands[0 if side < 0 else 1]
				var sample := _portal_relief_sample(
					field, int(relief.band_width), int(relief.band_height), photo_u, 1.0 - v
				)
				var relief_depth := 0.040 * sample
				relief_depth *= smoothstep(0.0, 0.15, v) * smoothstep(0.0, 0.15, 1.0 - v)
				return Vector3(x, spring - 0.075 + (v - 0.5) * 0.19, face_z + 0.002 + relief_depth)
			# Close the relief skin to its backing at both horizontal edges.
			for v in [0.0, 1.0]:
				var left: Vector3 = frieze.call(0.0, v)
				var right: Vector3 = frieze.call(1.0, v)
				var edge := [
					Vector3(left.x, left.y, face_z), left, right, Vector3(right.x, right.y, face_z)
				]
				if v > 0.0:
					edge.reverse()
				face.call(edge)
			for row in 48:
				for column in 64:
					var u := column / 64.0
					var v := row / 48.0
					var samples := [
						Vector2(u, v),
						Vector2(u, v + 1.0 / 48.0),
						Vector2(u + 1.0 / 64.0, v + 1.0 / 48.0),
						Vector2(u + 1.0 / 64.0, v)
					]
					var q: Array = []
					var smooth: Array = []
					var texture_uv: Array = []
					var origin: Vector2 = patch_origin.call()
					for sample in samples:
						q.append(frieze.call(sample.x, sample.y))
						texture_uv.append(origin + sample * 0.10)
						var along: Vector3 = (
							frieze.call(sample.x + 1.0 / 64.0, sample.y)
							- frieze.call(sample.x - 1.0 / 64.0, sample.y)
						)
						var up: Vector3 = (
							frieze.call(sample.x, sample.y + 1.0 / 48.0)
							- frieze.call(sample.x, sample.y - 1.0 / 48.0)
						)
						smooth.append(along.cross(up).normalized())
					face.call(q, smooth, texture_uv, 1)
			builder.current = st
		for column in 3:
			vary.call(column + int(side) * 11)
			var x: float = side * (radius + [0.14, 0.37, 0.59][column])
			var zc := front + 0.13 + column * 0.11
			var shaft_scale: float = [1.0, 0.61, 0.98][column]
			var profile := [
				Vector2(0.02, 0.20),
				Vector2(0.06, 0.205),
				Vector2(0.16, 0.19),
				Vector2(0.20, 0.16),
				Vector2(0.25, 0.16),
				Vector2(0.29, 0.125)
			]
			# The closer source shows a few long shaft courses, not thirteen
			# short repeated texture bands. Keep the same height/radius envelope.
			for strip in 4:
				var t := strip / 3.0
				var y := lerpf(0.34, spring - 0.57, t)
				var r := 0.132 + 0.004 * sin(t * PI)
				if strip in [1, 2]:
					profile.append_array(
						[Vector2(y - 0.004, r), Vector2(y, r - 0.002), Vector2(y + 0.004, r)]
					)
				else:
					profile.append(Vector2(y, r))
			profile.append_array([Vector2(spring - 0.54, 0.15), Vector2(spring - 0.50, 0.15)])
			for index in profile.size():
				profile[index].y *= shaft_scale
			# Continuous tone and UV height across the entire shaft.
			vary.call(column + int(side) * 11)
			for level in profile.size() - 1:
				for k in 20:
					var a := TAU * k / 20.0
					var b := TAU * (k + 1) / 20.0
					var lo: Vector2 = profile[level]
					var hi: Vector2 = profile[level + 1]
					var smooth: Array = []
					if hi.x - lo.x > 0.00001:
						# The shaft has slight taper/entasis: cylinder-only normals
						# left every tapered segment flat, creating long light bands.
						var slope := (hi.y - lo.y) / (hi.x - lo.x)
						var na := Vector3(cos(a), -slope, sin(a)).normalized()
						var nb := Vector3(cos(b), -slope, sin(b)).normalized()
						smooth = [nb, nb, na, na]
					var origin: Vector2 = patch_origin.call()
					# Circumference and height share the same grain density. Reset
					# within each short shaft course to avoid the texture's mortar.
					var uv := [
						Vector2(b * lo.y, lo.x - profile[0].x),
						Vector2(b * hi.y, hi.x - profile[0].x),
						Vector2(a * hi.y, hi.x - profile[0].x),
						Vector2(a * lo.y, lo.x - profile[0].x)
					]
					for index in 4:
						uv[index] = origin + uv[index] * 0.04
					face.call(
						[
							Vector3(x + lo.y * cos(b), lo.x, zc + lo.y * sin(b)),
							Vector3(x + hi.y * cos(b), hi.x, zc + hi.y * sin(b)),
							Vector3(x + hi.y * cos(a), hi.x, zc + hi.y * sin(a)),
							Vector3(x + lo.y * cos(a), lo.x, zc + lo.y * sin(a))
						],
						smooth,
						uv
					)
			# Broad worn lobes and scroll recesses from the photo, not invented figures.
			builder.current = capital_st
			var field_index: int = 2 - column if side < 0.0 else 3 + column
			var carved := func(angle: float, v: float) -> Vector3:
				# Individually bounded front masses follow the six source faces;
				# these are visual profiles, not surveyed dimensions.
				var shoulders: Array = [0.025, 0.026, 0.049, 0.046, 0.021, 0.031]
				var width: float = (
					(
						lerpf(0.15, 0.145, smoothstep(0.0, 0.2, v))
						+ shoulders[field_index] * sin(clampf(v, 0, 1) * PI * 0.65)
					)
					* shaft_scale
				)
				var ca := cos(angle)
				var sa := sin(angle)
				# Uniform front-face sampling: the previous signed-power x
				# skipped central photo columns and smeared their relief.
				var xx := ca
				var zz := lerpf(
					sa,
					signf(sa) * pow(maxf(0.0, 1.0 - pow(absf(ca), 4.0)), 0.25),
					smoothstep(0.0, 0.2, v)
				)
				var carving := 0.0
				if sa > 0.0:
					# Authored leaf, scroll and figural masses follow the source;
					# photo illumination is deliberately not treated as scan depth.
					var px := clampf((xx + 1.0) * 0.5, 0, 1) * (int(relief.width) - 1)
					var py := (1.0 - clampf(v, 0, 1)) * (int(relief.height) - 1)
					var ix := mini(int(px), int(relief.width) - 2)
					var iy := mini(int(py), int(relief.height) - 2)
					var data: Array = relief.fields[field_index]
					var row0: float = lerpf(
						data[iy * int(relief.width) + ix],
						data[iy * int(relief.width) + ix + 1],
						px - ix
					)
					var row1: float = lerpf(
						data[(iy + 1) * int(relief.width) + ix],
						data[(iy + 1) * int(relief.width) + ix + 1],
						px - ix
					)
					carving += (
						0.12
						* shaft_scale
						* (lerpf(row0, row1, py - iy) / 255.0 - 0.5)
						* sin(PI * clampf(v, 0, 1))
						* pow(sa, 1.5)
					)
				return Vector3(x + xx * width, spring - 0.52 + v * 0.35, zc + zz * width + carving)
			for row in 96:
				for segment in 128:
					var a := TAU * segment / 128.0
					var b := TAU * (segment + 1) / 128.0
					var uv := [
						Vector2(b, row / 96.0),
						Vector2(b, (row + 1) / 96.0),
						Vector2(a, (row + 1) / 96.0),
						Vector2(a, row / 96.0)
					]
					var q: Array = []
					var normals: Array = []
					var texture_uv: Array = []
					for sample in uv:
						texture_uv.append(
							patch_origin.call() + Vector2(sample.x / TAU, sample.y) * 0.10
						)
						q.append(carved.call(sample.x, sample.y))
						var along: Vector3 = (
							carved.call(sample.x + TAU / 128.0, sample.y)
							- carved.call(sample.x - TAU / 128.0, sample.y)
						)
						var up: Vector3 = (
							carved.call(sample.x, sample.y + 1.0 / 96.0)
							- carved.call(sample.x, sample.y - 1.0 / 96.0)
						)
						normals.append(up.cross(along).normalized())
					face.call(q, normals, texture_uv, 1 if (a + b) * 0.5 < PI else -1)
			builder.current = st
			# Capital now meets the aligned impost directly; no extra shelf slab.
	var instance := MeshInstance3D.new()
	instance.mesh = load(DIR + "cpu_geometry.gd").commit(st)
	instance.material_override = ps(
		load(DIR + "textures/stone.png"), Color.WHITE, Vector2.ONE, true
	)
	_vp.add_child(instance)
	var capitals := MeshInstance3D.new()
	# Average actual neighboring relief triangles instead of switching between
	# finite-difference normals and individual faces at steep carved shoulders.
	capital_st.generate_normals()
	capitals.mesh = load(DIR + "cpu_geometry.gd").commit(capital_st)
	capitals.material_override = instance.material_override
	capitals.set_meta("portal_capital", true)
	capitals.set_meta("portal_relief_winding_failures", winding.failures)
	_vp.add_child(capitals)


# The far end: a plain rectangular door with a stepped white casing, a deep cream
# vestibule lit from its far end,
# and the second door and bright room at its back.
func _trim_profile(
	origin: Vector3,
	across: Vector3,
	along: Vector3,
	points: Array,
	material: Material,
	depth_axis := Vector3.BACK
) -> void:
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
		cap.mesh = load(DIR + "cpu_geometry.gd").commit(st)
		cap.material_override = material
		_vp.add_child(cap)


func _door_panel(center: Vector3, material: Material) -> void:
	# One closed face and four bevels replace intersecting thin bead extrusions.
	var outline := [
		Vector2(-0.5, -0.425), Vector2(0.5, -0.425), Vector2(0.5, 0.425), Vector2(-0.5, 0.425)
	]
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
			var normal: Vector3 = (
				(face[triangle[2]] - face[triangle[0]])
				. cross(face[triangle[1]] - face[triangle[0]])
				. normalized()
			)
			assert(normal.z > 0, "Door-panel winding must face into the vestibule")
			for index in triangle:
				st.set_normal(normal)
				st.set_uv(Vector2(face[index].x, face[index].y))
				st.add_vertex(face[index])
	var panel := MeshInstance3D.new()
	panel.mesh = load(DIR + "cpu_geometry.gd").commit(st)
	panel.material_override = material
	_vp.add_child(panel)


func _far_end() -> void:
	var first_surface := _vp.get_child_count()
	var door: Dictionary = DOORS.far
	var z := -L
	var ds: Vector2 = door.size
	var x := W / 2.0
	var dw := ds.x / 2.0
	var side := x - dw
	var reference_blue := _wall_ps(Color(0.76, 0.84, 0.96))
	_panel(Vector3(-x, 0, z), Vector3(side, 0, 0), Vector3(0, H, 0), reference_blue, 0.5, 1)
	_panel(Vector3(dw, 0, z), Vector3(side, 0, 0), Vector3(0, H, 0), reference_blue, 0.5, 1)
	_panel(
		Vector3(-dw, ds.y, z), Vector3(ds.x, 0, 0), Vector3(0, H - ds.y, 0), reference_blue, 0.5, 1
	)
	var white := ps(load(DIR + "textures/ivory-trim.svg"), Color.WHITE, Vector2(0.7, 0.7), true)
	var casing := [
		Vector2(0, 0),
		Vector2(0, 0.10),
		Vector2(0.018, 0.125),
		Vector2(0.042, 0.125),
		Vector2(0.06, 0.105),
		Vector2(0.075, 0.075),
		Vector2(0.27, 0.075),
		Vector2(0.285, 0.09),
		Vector2(0.305, 0.09),
		Vector2(0.32, 0.06),
		Vector2(0.32, 0)
	]
	var skirting := [
		Vector2(0, 0),
		Vector2(0, 0.07),
		Vector2(0.035, 0.07),
		Vector2(0.05, 0.055),
		Vector2(0.18, 0.055),
		Vector2(0.20, 0.067),
		Vector2(0.225, 0.065),
		Vector2(0.24, 0.035),
		Vector2(0.24, 0)
	]
	for s in [-1.0, 1.0]:
		_trim_profile(
			Vector3(s * (dw + 0.36), 0, z),
			Vector3.UP,
			Vector3(s * (side - 0.36), 0, 0),
			skirting,
			white
		)
		_trim_profile(
			Vector3(s * dw, 0.26, z), Vector3(s, 0, 0), Vector3(0, ds.y - 0.26, 0), casing, white
		)
		var plinth := [
			Vector2(0, 0),
			Vector2(0, 0.12),
			Vector2(0.02, 0.14),
			Vector2(0.34, 0.14),
			Vector2(0.36, 0.12),
			Vector2(0.36, 0)
		]
		_trim_profile(Vector3(s * dw, 0, z), Vector3(s, 0, 0), Vector3(0, 0.26, 0), plinth, white)
		_panel(Vector3(s * dw, 0.26, z), Vector3(s * 0.36, 0, 0), Vector3(0, 0, 0.12), white)
	_trim_profile(
		Vector3(-dw - 0.32, ds.y, z), Vector3.UP, Vector3(ds.x + 0.64, 0, 0), casing, white
	)
	var crown := [
		Vector2(0, 0),
		Vector2(0, 0.065),
		Vector2(0.025, 0.09),
		Vector2(0.055, 0.14),
		Vector2(0.075, 0.15),
		Vector2(0.10, 0.15),
		Vector2(0.10, 0)
	]
	_trim_profile(
		Vector3(-dw - 0.38, ds.y + 0.32, z), Vector3.UP, Vector3(ds.x + 0.76, 0, 0), crown, white
	)
	# #160: a fully modeled cream vestibule, no photographic depth card.
	var depth: float = door.reveal
	var cream := ps(
		load(DIR + "textures/ivory-trim.svg"), Color(1.0, 0.98, 0.91), Vector2(0.65, 0.65), true
	)
	var lit := func(p: Vector3) -> float:
		return lerpf(0.55, 1.0, clampf((z - p.z) / depth, 0.0, 1.0))
	# Rear backing sits 5 cm behind the door leaf; extend the shell to meet it.
	var shell_depth := depth + 0.05
	_panel(Vector3(-dw, 0, z), Vector3(0, 0, -shell_depth), Vector3(0, ds.y, 0), cream, 0.5, 1, lit)
	_panel(
		Vector3(dw, 0, z - shell_depth),
		Vector3(0, 0, shell_depth),
		Vector3(0, ds.y, 0),
		cream,
		0.5,
		1,
		lit
	)
	# Inward ceiling and upward floor normals are required for the offline bake.
	_panel(
		Vector3(-dw, ds.y, z - shell_depth),
		Vector3(ds.x, 0, 0),
		Vector3(0, 0, shell_depth),
		cream,
		0.5,
		1,
		lit
	)
	var threshold := ps(
		load(DIR + "textures/oak.png"), Color(0.83, 0.79, 0.71), Vector2(0.52, 1.0), true
	)
	var threshold_section := [
		Vector2(-0.12, 0),
		Vector2(-0.10, 0.012),
		Vector2(0.10, 0.012),
		Vector2(0.12, 0),
		Vector2(0.12, -0.015),
		Vector2(-0.12, -0.015)
	]
	_trim_profile(
		Vector3(-dw, 0, z),
		Vector3.BACK,
		Vector3(ds.x, 0, 0),
		threshold_section,
		threshold,
		Vector3.UP
	)
	for row in 13:
		var timber := ps(
			load(DIR + "textures/oak.png"),
			Color(1.05, 1.03, 0.97) * (0.98 if row % 3 == 0 else 1.0),
			Vector2(0.52, 1.0),
			true
		)
		_panel(
			Vector3(-dw, 0.003, z - 0.12 - row * (shell_depth - 0.12) / 13.0),
			Vector3(ds.x, 0, 0),
			Vector3(0, 0, -(shell_depth - 0.12) / 13.0),
			timber,
			0.4
		)
	for s in [-1.0, 1.0]:
		_trim_profile(
			Vector3(s * dw, 0, z),
			Vector3.UP,
			Vector3(0, 0, -depth),
			skirting,
			white,
			Vector3(-s, 0, 0)
		)
	# The reference's second pale doorway is real relief at the rear, not a picture.
	var rear := z - depth
	_panel(Vector3(-dw, 0, rear - 0.05), Vector3(ds.x, 0, 0), Vector3(0, ds.y, 0), cream)
	for s in [-1.0, 1.0]:
		_trim_profile(
			Vector3(s * 0.62, 0, rear), Vector3(s * 0.55, 0, 0), Vector3(0, 2.35, 0), casing, white
		)
	_trim_profile(
		Vector3(-0.80, 2.35, rear), Vector3(0, 0.55, 0), Vector3(1.6, 0, 0), casing, white
	)
	_panel(Vector3(-0.62, 0, rear - 0.02), Vector3(1.24, 0, 0), Vector3(0, 2.35, 0), white)
	for panel_y in [0.68, 1.68]:
		_door_panel(Vector3(0, panel_y, rear - 0.021), white)
	for sign_z in [z + 0.041, rear + 0.03]:
		var sign_y := ds.y + 0.48 if sign_z > z else 2.65
		_panel(
			Vector3(-0.17, sign_y, sign_z),
			Vector3(0.34, 0, 0),
			Vector3(0, 0.15, 0),
			ps(load(DIR + "textures/exit-sign.svg"), Color.WHITE, Vector2(1.0 / 0.34, 1.0 / 0.15))
		)
	# The inherited panel builder emits reverse winding against its normals.
	# Align this slice's triangle faces before UV2/bake; leave other assets alone.
	for child_index in range(first_surface, _vp.get_child_count()):
		var instance = _vp.get_child(child_index)
		if not instance is MeshInstance3D:
			continue
		var aligned := ArrayMesh.new()
		var sources := []
		for surface in instance.mesh.get_surface_count():
			var arrays: Array = load(DIR + "cpu_geometry.gd").source(instance.mesh, surface).duplicate()
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = (
				arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			)
			if indices.is_empty():
				indices = PackedInt32Array(range(vertices.size()))
			for index in range(0, indices.size(), 3):
				var a := indices[index]
				var geometric := (vertices[indices[index + 2]] - vertices[a]).cross(
					vertices[indices[index + 1]] - vertices[a]
				)
				if geometric.dot(normals[a]) < 0:
					var b := indices[index + 1]
					indices[index + 1] = indices[index + 2]
					indices[index + 2] = b
			arrays[Mesh.ARRAY_INDEX] = indices
			aligned.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			sources.append(arrays)
		aligned.set_meta("cpu_arrays", sources)
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
			node.build_shaped(
				load(DIR + "frames/W6-shaped.png"),
				Vector2(r.canvas_w, r.canvas_h),
				r.outline,
				Color(r.edge_color)
			)
		else:
			node.build_framed(
				load(DIR + "frames/%s.png" % r.tag),
				load(DIR + "canvas/%s.jpg" % r.tag),
				Vector2(r.canvas_w, r.canvas_h),
				r.margins_px
			)
		assets[r.tag] = node
	var x := W / 2.0
	# long walls: even gaps, in the researched order. West runs arch end -> far end;
	# east runs far end -> arch end.
	for wall in [
		{
			"tags": ["W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10"],
			"x": -x,
			"rot": PI / 2,
			"from_far": false
		},
		{
			"tags": ["E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9"],
			"x": x,
			"rot": -PI / 2,
			"from_far": true
		}
	]:
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
	var ma := (DOORS.arch.size.x / 2.0 + CASING + x) / 2.0
	var mf := (DOORS.far.size.x / 2.0 + CASING + x) / 2.0
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
	# A white label card (#238, finish spec step 6): its top edge 5 cm below the frame's lower
	# corner, or beside that corner where the frame hangs too low to leave room above the
	# skirting. Their photographed text is unresolved; do not invent museum wording.
	var caption := MeshInstance3D.new()
	var plate := BoxMesh.new()
	plate.size = Vector3(0.30, 0.17, 0.006)
	caption.mesh = plate
	caption.material_override = ps(null, Color("#e9e4d4"))
	caption.position = (
		Vector3(outer.x / 2.0 - 0.15, -outer.y / 2.0 - 0.135, 0.014)
		if at.y - outer.y / 2.0 >= 0.52
		else Vector3(outer.x / 2.0 + 0.2, -outer.y / 2.0 + 0.085, 0.014)
	)
	caption.set_meta("caption_plate", true)
	node.add_child(caption)
	var layer := (
		LAYER_EAST if at.x > W / 2.0 - 0.1 or (absf(at.z) < 0.1 and at.x > 0) else LAYER_WEST
	)
	for c in node.get_children():
		(c as VisualInstance3D).layers = layer
	var n := basis * Vector3.BACK
	var r := basis * Vector3.RIGHT
	var corners := []
	for c in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		corners.append(at + r * c.x * outer.x / 2.0 + Vector3.UP * c.y * outer.y / 2.0 + n * 0.09)
	_paintings.append(
		{"tag": tag, "rec": rec, "center": at, "normal": n, "corners": corners, "outer": outer}
	)


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
	for n in [
		"step_wood_01",
		"step_wood_02",
		"step_wood_03",
		"step_wood_04",
		"step_wood_05",
		"step_wood_06",
		"pickup",
		"menu_open",
		"menu_close",
		"select",
		"cancel",
		"cursor",
		"item_select"
	]:
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
		if bounds.size.y < 0.05 and absf(center.y) < 0.05:
			mi.layers = 1  # floors remain visible when the near wall is cut away
		elif center.y > H - 0.6 or (bounds.size.y < 0.05 and center.y > 4.0):
			mi.layers = 32
		elif bounds.position.z >= -0.01 and bounds.size.x < 0.1 and center.x < -2.9:
			mi.layers = 2
		elif bounds.position.z >= -0.01 and bounds.size.x < 0.1 and center.x > 2.9:
			mi.layers = 4
		elif bounds.position.z > 6.5:
			mi.layers = 16
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
	_lighting_choice.toggled.connect(
		func(enabled: bool) -> void:
			_play("select")
			_set_lighting(enabled)
	)
	_view_bar.add_child(_lighting_choice)
	_lighting_choice.disabled = not ResourceLoader.exists(DIR + "baked/room.tscn")
	_view_label = Label.new()
	_view_bar.add_child(_view_label)
	if OS.has_feature("web"):
		var variant = JavaScriptBridge.eval("new URLSearchParams(location.search).get('variant')")
		view_mode = {"dollhouse": 0, "gallery": 1, "original": 2}.get(str(variant), 0)
	choice.select(view_mode)
	var use_bake := not _lighting_choice.disabled
	if (
		OS.has_feature("web")
		and JavaScriptBridge.eval(
			"new URLSearchParams(location.search).get('lighting') === 'original'"
		)
	):
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
	# Arch traversal uses the modeled stone passage and its parquet. The far
	# doorway retains #135's isolated navigation room on layers 64–1024.
	_portal_flash = ColorRect.new()
	_portal_flash.color = Color.WHITE
	_portal_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portal_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portal_flash.modulate.a = 0.0
	add_child(_portal_flash)


func _enter_space(next: String) -> void:
	var previous := _space
	# Arch is contiguous world geometry, not the far door's separate QA room.
	if previous == "arch" or next == "arch":
		_space = next
		get_node("OtherWall").visible = next == "gallery"
		_update_camera(1.0)
		print("NAV_SPACE ", previous, " -> ", next)
		return
	_new_action()
	_target = null
	_target_yaw = null
	_velocity = Vector3.ZERO
	_held.clear()
	_space = next
	for node in _vp.get_children():
		if node is WorldEnvironment:
			node.environment.background_color = (
				Color("#20242a") if next == "gallery" else Color("#ece9e2")
			)
			node.environment.ambient_light_energy = (
				0.6 if next == "gallery" and not _baked_lighting else 0.0
			)
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
		_motion_heading = (
			Vector3.FORWARD if next != "gallery" or previous == "arch" else Vector3.BACK
		)
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
	for wall in [0.0, -L] if _space == "gallery" else ([] if _space == "arch" else [0.0]):
		var edge: float = wall - 0.55 if wall == 0.0 else wall + 0.55
		if (_pos.z - edge) * (p.z - edge) < 0.0:
			var at_x := lerpf(_pos.x, p.x, (edge - _pos.z) / (p.z - _pos.z))
			if absf(at_x) > 0.4:
				p.z = edge
	_pos = _clamp(p)


func _orbit(amount: float) -> void:
	if is_zero_approx(amount):
		return
	_new_action()
	_target = null
	_target_yaw = null
	_view_turn_remaining += amount
	if absf(amount) >= 0.5 and not _orbit_dragged:
		_turn_span = _view_turn_remaining
		_turn_clock = 0.0
	else:
		_turn_clock = 1.0  # a drag or the wheel: follow the hand


func _set_lighting(enabled: bool) -> void:
	_baked_lighting = enabled
	# Original room comparison has no capture. Supply neutral ambient only there;
	# baked/probe-disabled tests retain zero ambient and genuine spatial capture.
	for node in _vp.get_children():
		if node is WorldEnvironment:
			node.environment.ambient_light_energy = 0.6 if not enabled and _space != "far" else 0.0
	if enabled and _baked_room == null:
		_baked_room = load(DIR + "baked/room.tscn").instantiate()
		_vp.add_child(_baked_room)
		for mesh in _baked_room.find_children("*", "MeshInstance3D", true, false):
			if mesh.layers in _cutaway_alpha and mesh.material_override is StandardMaterial3D:
				var original: StandardMaterial3D = mesh.material_override
				var material := ShaderMaterial.new()
				material.shader = load(DIR + "cutaway.gdshader")
				material.set_shader_parameter("textured", original.albedo_texture != null)
				material.set_shader_parameter("tex", original.albedo_texture)
				material.set_shader_parameter("tint", original.albedo_color)
				material.set_shader_parameter("uv_scale", original.uv1_scale)
				material.set_shader_parameter("vertex_tint", original.vertex_color_use_as_albedo)
				material.set_shader_parameter(
					"unshaded", original.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED
				)
				material.set_shader_parameter(
					"scissor",
					(
						original.alpha_scissor_threshold
						if original.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
						else 0.0
					)
				)
				if not _cutaway_materials.has(mesh.layers):
					_cutaway_materials[mesh.layers] = []
				_cutaway_materials[mesh.layers].append(
					{"mesh": mesh, "material": material, "original": original}
				)
	if _baked_room:
		_baked_room.visible = enabled
	if _white_capture == null and ResourceLoader.exists(DIR + "baked/white.lmbake"):
		_white_capture = LightmapGI.new()
		var capture: LightmapGIData = ResourceLoader.load(
			DIR + "baked/white.lmbake", "LightmapGIData", ResourceLoader.CACHE_MODE_IGNORE
		)
		capture.clear_users()  # white scene uses existing geometry; keep only its probe field
		_white_capture.light_data = capture
		_vp.add_child(_white_capture)
	if _white_capture:
		_white_capture.visible = _space == "far"
	for mesh in _source_meshes:
		mesh.visible = not enabled
	# The old photographed end cards are scenery, not traversable rooms.
	for mesh in (
		_source_meshes
		+ (_baked_room.find_children("*", "MeshInstance3D", true, false) if _baked_room else [])
	):
		var material = mesh.material_override
		if (
			material is ShaderMaterial
			and material.shader.resource_path.ends_with("/oak.gdshader")
			and material.get_shader_parameter("floor_z_limits").x == 0
		):
			_portal_floor_material = material
		var texture = (
			material.albedo_texture
			if material is StandardMaterial3D
			else (material.get_shader_parameter("albedo") if material is ShaderMaterial else null)
		)
		if (
			texture
			and (
				texture.resource_path.ends_with("door-arch.jpg")
				or texture.resource_path.ends_with("door-far.jpg")
			)
		):
			mesh.hide()
	if OS.has_feature("web"):
		(
			JavaScriptBridge
			. eval(
				(
					(
						"var u=new URL(location.href);u.searchParams.set('lighting','%s');history.repl" +
						"aceState(null,'',u)"
					)
					% ("baked" if enabled else "original")
				)
			)
		)


func _set_view(mode: int) -> void:
	_play("select")
	_new_action()
	_held.clear()
	_velocity = Vector3.ZERO
	_target = null
	_target_yaw = null
	_view_turn_remaining = 0.0
	view_mode = mode
	if mode == 2 and _kid:
		_yaw = wrapf(_kid.rotation.y - PI, -PI, PI)
	(_view_bar.get_child(0) as OptionButton).select(mode)
	_update_camera(1.0)
	if OS.has_feature("web"):
		(
			JavaScriptBridge
			. eval(
				(
					(
						"var u=new URL(location.href);u.searchParams.set('variant','%s');history.repla" +
						"ceState(null,'',u)"
					)
					% ["dollhouse", "gallery", "original"][mode]
				)
			)
		)
	print("VIEW ", ["dollhouse", "gallery", "original"][mode], " yaw ", rad_to_deg(view_yaw))


func _other_wall() -> void:
	if not _open.is_empty() or _space != "gallery":
		return
	# A deliberate gallery shortcut: keep the same bay, cross to the other hang. The visitor
	# walks across and the view glides round with it; nothing jumps.
	var east := sin(view_yaw) > 0.0
	if view_mode != 0:
		_set_view(0)
	_walk_to(Vector3(2.6 if east else -2.6, 0, _pos.z))
	_view_turn_remaining = wrapf((-PI / 2.0 if east else PI / 2.0) - view_yaw, -PI, PI)
	_turn_span = _view_turn_remaining
	_turn_clock = 0.0
	print("OTHER_WALL ", "east" if east else "west")


func _rotate_view(direction: int) -> void:
	_orbit(direction * PI / 2.0)


func _screen_direction() -> Vector3:
	var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
	var right := Vector3(cos(view_yaw), 0, -sin(view_yaw))
	return (
		(
			forward * (int(_held.has("up")) - int(_held.has("down")))
			+ right * (int(_held.has("right")) - int(_held.has("left")))
		)
		. normalized()
	)


func _painting_shown(p: Dictionary) -> bool:
	if _space != "gallery":
		return false
	if view_mode == 2:
		return true
	var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
	return p.normal.dot(forward) < 0.1


# Every static mesh that shares a look (same shader, texture, tint, flags) becomes
# one mesh: a few dozen draw calls
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
		# Offline capital relief owns finer lighting UVs than the arch stone.
		# Keep its authoring metadata intact rather than merging it into the arch.
		if mi.get_meta("portal_capital", false) or mi.get_meta("vault", false):
			continue
		var m := mi.material_override
		var key := ""
		if m is ShaderMaterial:
			var sm := m as ShaderMaterial
			var tex = sm.get_shader_parameter("albedo")
			key = (
				"ps|%s|%s|%s|%s|%s|%s|%s"
				% [
					tex.get_rid().get_id() if tex else 0,
					sm.get_shader_parameter("tint"),
					sm.get_shader_parameter("use_vertex_color"),
					sm.get_shader_parameter("uv_scale"),
					sm.get_shader_parameter("plank_seams"),
					sm.get_shader_parameter("alpha_cut"),
					sm.get_shader_parameter("use_texture")
				]
			)
		elif m is StandardMaterial3D:
			var st3 := m as StandardMaterial3D
			key = (
				"std|%s|%s|%s|%s"
				% [
					st3.albedo_texture.get_rid().get_id() if st3.albedo_texture else 0,
					st3.albedo_color,
					st3.blend_mode,
					st3.transparency
				]
			)
		else:
			continue
		# SurfaceTool cannot mix indexed primitives with unindexed triangle lists:
		# doing so leaves the latter vertices unreferenced (e.g. upholstered seats).
		key += "|baseboard:%s" % mi.get_meta("baseboard", false)
		key += (
			"|layer:%s|indexed:%s"
			% [mi.layers, load(DIR + "cpu_geometry.gd").source(mi.mesh)[Mesh.ARRAY_INDEX] != null]
		)
		if not groups.has(key):
			groups[key] = []
		groups[key].append(mi)
	for key in groups:
		var list: Array = groups[key]
		if list.size() < 2:
			continue
		var cpu: Script = load(DIR + "cpu_geometry.gd")
		var channels := {}
		for mi in list:
			for surf in mi.mesh.get_surface_count():
				var arrays: Array = cpu.source(mi.mesh, surf)
				for channel in [
					Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_COLOR,
					Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2
				]:
					if arrays[channel] != null:
						channels[channel] = true
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var offset := 0
		for mi in list:
			var xf: Transform3D = (mi as MeshInstance3D).global_transform
			for surf in mi.mesh.get_surface_count():
				offset = cpu.append(st, cpu.source(mi.mesh, surf), xf, offset, channels)
		var merged := MeshInstance3D.new()
		merged.mesh = load(DIR + "cpu_geometry.gd").commit(st)
		merged.set_meta("baseboard", list[0].get_meta("baseboard", false))
		merged.layers = list[0].layers
		merged.material_override = list[0].material_override
		merged.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for mi in list:
			mi.get_parent().remove_child(mi)
			mi.queue_free()
		_vp.add_child(merged)


func _build_kid() -> void:
	_generated_visitor = true
	_rigged_visitor = true
	_kid = load("res://modules/shell/character/visitor.gd").new()
	_kid.world_height = KID_H
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
	# One soft round shadow half the visitor's height across, as the New Horizons museum draws
	# it (docs/research/2026-10-01-acnh-museum-polish-spec.md, step 5); the sole patches under
	# it only darken the contact.
	_shadow = _rect(Vector3(0, 0.01, 0), Vector2(0.9, 0.9), Vector3.RIGHT, Vector3.FORWARD, sm)
	if _rigged_visitor:
		sm.albedo_color.a = 0.56
		for index in 2:
			var contact_material: StandardMaterial3D = sm.duplicate()
			_sole_shadows.append(
				_rect(
					Vector3.ZERO,
					Vector2(0.56, 0.72),
					Vector3.RIGHT,
					Vector3.FORWARD,
					contact_material
				)
			)


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
	_catalogue_zoom = load(DIR + "catalogue_zoom.gd").new()
	_detail.add_child(_catalogue_zoom)
	var pic := TextureRect.new()
	pic.name = "Painting"
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom_root.add_child(pic)
	var close := TextureButton.new()  # the game's own tab close icon, drawn at twice its size
	close.name = "Close"
	close.tooltip_text = "Close artwork · Escape"
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
	_open = p
	_view_panel.hide()
	get_node("OtherWall").hide()
	_velocity = Vector3.ZERO
	_held.clear()
	_detail.visible = true
	_detail.modulate.a = 1.0
	detail_changed.emit(true)
	_fit_detail()
	_refresh_zoom_image()
	_detail.get_node("Close").grab_focus()
	_play("menu_open")


func _fit_detail() -> void:
	if _open.is_empty() or _zoom_root == null:
		return
	var p: Dictionary = _open
	var rec: Dictionary = p.rec
	var pic: TextureRect = _zoom_root.get_node("Painting")
	var frame: NinePatchRect = _zoom_root.get_node("Frame")
	# The fitted view is packed; the larger catalogue photograph loads on demand.
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


func _refresh_zoom_image() -> void:
	if not _open.is_empty() and _open.rec.has("zoom_image"):
		_catalogue_zoom.show_image(_open.rec.zoom_image, _zoom_root.get_node("Painting"))


func _close_detail() -> void:
	if _open.is_empty():
		return
	_catalogue_zoom.clear()
	_view_panel.hide()
	_play("menu_close")
	_open = {}
	detail_changed.emit(false)
	_detail.visible = false
	get_node("OtherWall").show()
	grab_focus()


func _zoom_at(point: Vector2, factor: float) -> void:
	var z := clampf(_zoom * factor, 1.0, 6.0)
	var f := z / _zoom
	_zoom_root.position = point + (_zoom_root.position - point) * f
	_zoom = z
	_zoom_root.scale = Vector2(z, z)
	if is_equal_approx(z, 1.0):
		_zoom_root.position = (size - _zoom_root.size) / 2.0


# ---------------------------------------------------------------- walking


func _pace() -> float:
	return SPRINT_MPS if Input.is_key_pressed(KEY_SHIFT) and is_visible_in_tree() else WALK_MPS


func _fwd() -> Vector3:
	return Vector3(-sin(_yaw), 0, -cos(_yaw))


func _process(delta: float) -> void:
	if _entrance_waiting:
		# Boot warms every tab behind its loader. Start only when the viewer is visible.
		if not is_visible_in_tree() or get_tree().root.has_node("BootLoader"):
			return
		if (
			OS.has_feature("web")
			and JavaScriptBridge.eval("document.getElementById('status') !== null")
		):
			return
		_entrance_waiting = false
	if not _open.is_empty():
		return
	var turn := _view_turn_remaining * (1.0 - exp(-delta * 12.0))
	if _turn_clock < 1.0:
		_turn_clock = minf(1.0, _turn_clock + delta / VIEW_TURN_S)
		turn = _view_turn_remaining - _turn_span * (1.0 - smoothstep(0.0, 1.0, _turn_clock))
	var orbit_settled := (
		absf(_view_turn_remaining) >= 0.001 and absf(_view_turn_remaining - turn) < 0.001
	)
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
		_velocity = _velocity.move_toward(
			direction * (_pace() if _rigged_visitor else 2.0),
			(12.0 if direction != Vector3.ZERO else 16.0) * delta
		)
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
			_move_to(_pos + to.normalized() * minf(to.length(), _pace() * delta))
			# stuck against something for half a second: give up on this walk
			_stall_t = (
				_stall_t + delta if _pos.distance_to(_last_pos) < _pace() * delta * 0.2 else 0.0
			)
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
		if (_space == "far" and _pos.z > 0.0) or (_space == "arch" and _pos.z < 0.0):
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
		var facing := _fwd() if view_mode == 2 else _motion_heading
		# Keys thrown against the travel: face where they point at once, so the visitor
		# brakes and turns while it still slides the old way, not after it has set off (#259).
		if view_mode != 2 and _screen_direction().dot(_motion_heading) < 0.0:
			facing = _screen_direction()
		_kid.pose(
			delta,
			distance_moved > 0.0001,
			_kid_t * 10.0 / WALK_FRAMES,
			facing,
			view_yaw if view_mode != 2 else _yaw
		)
	_update_camera(minf(1.0, delta * 5.0))
	_update_hover()
	if orbit_settled:
		print(
			"VIEW_ORBIT ",
			JSON.stringify(
				{
					"yaw": view_yaw if view_mode != 2 else _yaw,
					"position": [_pos.x, _pos.z],
					"space": _space
				}
			)
		)


# Inside the room, clear of the walls and the benches.
func _clamp(p: Vector3) -> Vector3:
	var m := 0.55
	var doorway := absf(p.x) <= 0.4
	if _space == "arch":
		# Keep the visitor inside the narrow reveal until fully past its jambs.
		if (_pos.z - PORTAL_MOUTH) * (p.z - PORTAL_MOUTH) < 0.0 or (
			_pos.z == PORTAL_MOUTH and p.z < PORTAL_MOUTH
		):
			var crossing_x := lerpf(_pos.x, p.x, (PORTAL_MOUTH - _pos.z) / (p.z - _pos.z))
			if absf(crossing_x) > 0.4:
				if _pos.z >= PORTAL_MOUTH:
					p.z = PORTAL_MOUTH
				else:
					p.x = clampf(p.x, -0.4, 0.4)
		var in_passage := p.z < PORTAL_MOUTH
		return Vector3(
			clampf(p.x, -0.4 if in_passage else -2.45, 0.4 if in_passage else 2.45),
			0,
			clampf(p.z, -0.2, 6.1)
		)
	if _space != "gallery":
		return Vector3(
			clampf(p.x, -3.0 + m, 3.0 - m), 0, clampf(p.z, -6.0 + m, 0.2 if doorway else -m)
		)
	p = Vector3(
		clampf(p.x, -W / 2 + m, W / 2 - m),
		0,
		clampf(p.z, -L - 0.2 if doorway else -L + m, 0.2 if doorway else -m)
	)
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


# The camera follows behind the kid but never leaves the room: the line from the
# kid's head to where the camera
# wants to be is cut where it would cross a wall.
func _cutaway_mask(target: int, blend: float) -> int:
	if not _baked_lighting or _space == "far":
		return target
	# Orbit cutaways must not draw translucent walls across the visitor.
	if absf(_view_turn_remaining) > 0.001 or _orbit_dragged:
		blend = 1.0
	var mask := target
	for layer in _cutaway_alpha:
		var alpha := move_toward(
			float(_cutaway_alpha[layer]), 1.0 if target & layer else 0.0, blend
		)
		_cutaway_alpha[layer] = alpha
		for entry in _cutaway_materials.get(layer, []):
			entry.mesh.material_override = entry.material if alpha < 1.0 else entry.original
			entry.material.set_shader_parameter("cutaway_opacity", alpha)
		if alpha > 0.0:
			mask |= layer
	if _portal_floor_material:
		_portal_floor_material.set_shader_parameter("cutaway", 1.0 - float(_cutaway_alpha[8]))
	return mask


func _update_camera(k: float) -> void:
	# Fade visibility changes; the camera's angle, distance and FOV stay fixed.
	var fade := minf(0.2, get_process_delta_time() * 2.5) if is_processing() else 1.0
	if _baked_room:
		_baked_room.get_node("Lightmap").visible = _space != "far"
	if _white_capture:
		_white_capture.visible = _space == "far"
	_kid.layers = 64 if _space == "far" else 1
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
			contact.material_override.albedo_color.a = (
				0.39 if support[index] else 0.22 * clampf(1.0 - height / 0.25, 0.0, 1.0)
			)
		# In a jump the shadow stays on the floor, smaller and fainter the higher the visitor is.
		var lift: float = clampf(minf(soles[0].y, soles[1].y) - _pos.y, 0.0, 1.0)
		_shadow.scale = Vector3.ONE * (1.0 - 0.4 * lift)
		_shadow.material_override.albedo_color.a = 0.56 * (1.0 - 0.6 * lift)
	if not _rigged_visitor:
		_kid.billboard = (
			BaseMaterial3D.BILLBOARD_FIXED_Y if view_mode == 2 else BaseMaterial3D.BILLBOARD_ENABLED
		)
	# Preserve the selected view at the doorway; only the original follow view
	# needs its camera constrained inside the positive-z recess.
	if view_mode == 2 and _space == "arch":
		var heading := _yaw if view_mode == 2 else view_yaw
		var forward := Vector3(-sin(heading), 0, -cos(heading))
		var eye := _pos - forward * 3.1 + Vector3(0, 2.45, 0)
		if eye.z >= PORTAL_MOUTH:
			eye.x = clampf(eye.x, -2.7, 2.7)
		if eye.z > -0.1 and eye.z < PORTAL_MOUTH:
			eye.x = clampf(eye.x, -0.7, 0.7)
		eye.z = minf(eye.z, 6.3)
		_cam.position = eye
		_cam.fov = 58.0
		_cam.cull_mask = _cutaway_mask(31, fade)
		_cam.look_at(_pos + forward * 2.0 + Vector3(0, 1.1, 0))
		return
	if view_mode != 2:
		# The New Horizons museum looks down 29-31 degrees through a 22-24 degree lens
		# (docs/research/2026-10-01-acnh-museum-polish-spec.md). At 30 degrees and 12 m the
		# visitor keeps the size approved in #133 and 3 m of wall shows instead of 2.4 m.
		var pitch := deg_to_rad(30.0 if view_mode == 0 else 35.0)
		var distance := 12.0 if view_mode == 0 else 9.3
		_cam.fov = 23.0 if view_mode == 0 else 30.0
		var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
		var center := _pos + forward * 0.7 + Vector3(0, 1.25 if view_mode == 0 else 1.55, 0)
		# Follow the kid along the gallery; the cutaway lets the eye sit outside it.
		_cam.position = (
			center - forward * distance * cos(pitch) + Vector3.UP * distance * sin(pitch)
		)
		_cam.look_at(center)
		var hidden := (
			(4 if forward.x < -0.2 else (2 if forward.x > 0.2 else 0))
			| (8 if forward.z < -0.2 else (16 if forward.z > 0.2 else 0))
		)
		if _space == "arch":
			hidden = (
				(4 if forward.x < -0.2 else (2 if forward.x > 0.2 else 0))
				| (16 if forward.z < -0.2 else 8)
			)
		_cam.cull_mask = _cutaway_mask(
			(1984 & ~(hidden * 64)) if _space == "far" else (31 & ~hidden), fade
		)
		if _view_label:
			_view_label.text = (
				"WASD · Click art · "
				+ (
					"West wall"
					if forward.x < -0.5
					else (
						"East wall"
						if forward.x > 0.5
						else ("Far wall" if forward.z < -0.5 else "Arch wall")
					)
				)
			)
		return
	_cam.cull_mask = _cutaway_mask(1984 if _space == "far" else 63, fade)
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
	# blocked by a wall: rise over the kid instead
	want = head + d * t + Vector3(0, (1.0 - t) * 0.9, 0)
	_cam.position = _cam.position.lerp(want, k) if k < 1.0 else want
	_cam.look_at(_pos + _fwd() * 4.0 + Vector3(0, 1.1, 0))


func _step(dir: float) -> void:
	_new_action()
	# from where the kid stands: a key replaces any click walk
	_target = _clamp(_pos + _fwd() * STEP_M * dir)


func _new_action() -> void:
	_entrance_waiting = false
	if _entrance_active:
		_entrance_active = false
		_pos.z = minf(_pos.z, -0.05)
	_action += 1
	_path.clear()


# Walk to p. Every leg is checked against each bench's rectangle (grown by
# the kid's clearance); a leg that
# crosses one is replaced by a detour down the side lane nearer the start,
# past both of the bench's ends.
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
		var side := func(v: Vector3, other: Vector3) -> float:
			return (
				signf(v.x)
				if absf(v.x) > 0.05
				else (signf(other.x) if absf(other.x) > 0.05 else 1.0)
			)
		var xa: float = side.call(a, b) * 1.6
		var xb: float = side.call(b, a) * 1.6
		var sa := signf(a.z - bz) if absf(a.z - bz) > 0.01 else 1.0
		var sb := signf(b.z - bz) if absf(b.z - bz) > 0.01 else sa
		var detour: Array = []
		if xa == xb:  # same side of the bench: along the lane from our end to the target's end
			detour = (
				[Vector3(xa, 0, bz + 2.15 * sa)]
				if sa == sb
				else [Vector3(xa, 0, bz + 2.15 * sa), Vector3(xa, 0, bz + 2.15 * sb)]
			)
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
		var corners := [
			r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)
		]
		for k in 4:
			if (
				Geometry2D.segment_intersects_segment(aa, bb, corners[k], corners[(k + 1) % 4])
				!= null
			):
				return bz
	return INF


func _turn(dir: float) -> void:
	_new_action()
	_target = null  # turning by key ends any click walk
	_target_yaw = (_target_yaw if _target_yaw != null else _yaw) + dir * PI / 4


# ---------------------------------------------------------------- picking


func _to_screen(p: Vector3) -> Vector2:
	return _cam.unproject_position(p) / Vector2(_vp.size) * size


# A painting's outline on screen, cut where it passes behind the camera (so
# a painting half out of view is
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
		if _target == null:
			return
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
		_kid.pose(
			get_process_delta_time() if _rigged_visitor else 0.0,
			false,
			0.0,
			_motion_heading,
			view_yaw if view_mode != 2 else _yaw
		)
		while (
			absf(wrapf(_kid.rotation.y - atan2(_motion_heading.x, _motion_heading.z), -PI, PI))
			> 0.015
		):
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
		elif (
			event.pressed
			and event.button_index in [MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT]
		):
			_orbit(
				(
					0.10
					* event.factor
					* (1.0 if event.button_index == MOUSE_BUTTON_WHEEL_LEFT else -1.0)
				)
			)
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
				var inside := Rect2(_zoom_root.position, _zoom_root.size * _zoom).has_point(
					event.position
				)
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


# Esc closes the detail view before anything else can take the key
func _input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_ESCAPE
		and not _open.is_empty()
		and is_visible_in_tree()
	):
		get_viewport().set_input_as_handled()
		_close_detail()


func _notification(what: int) -> void:
	if (
		what == NOTIFICATION_VISIBILITY_CHANGED
		or what == NOTIFICATION_APPLICATION_FOCUS_OUT
		or what == NOTIFICATION_FOCUS_EXIT
	):
		_held.clear()
		_velocity = Vector3.ZERO
		_orbit_from = null
		_orbit_dragged = false


# #237: existing input/asset dispatcher intentionally exits per handled case.
# gdlint: disable=max-returns
func _unhandled_key_input(event: InputEvent) -> void:
	if event.echo:
		return
	if not event.pressed and event is InputEventKey:  # releases always count, even while hidden
		for k in ["up", "down", "left", "right"]:
			if (
				_held.has(k)
				and (
					event.keycode
					in {
						"up": [KEY_UP, KEY_W],
						"down": [KEY_DOWN, KEY_S],
						"left": [KEY_LEFT, KEY_A],
						"right": [KEY_RIGHT, KEY_D]
					}[k]
				)
			):
				_held.erase(k)
	if event.keycode == KEY_SHIFT:
		return
	if not is_visible_in_tree():
		return
	if event.pressed and event.keycode == KEY_SPACE and _open.is_empty():
		_kid.jump()
		get_viewport().set_input_as_handled()
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
		KEY_UP, KEY_W:
			key = "up"
		KEY_DOWN, KEY_S:
			key = "down"
		KEY_LEFT, KEY_A:
			key = "left"
		KEY_RIGHT, KEY_D:
			key = "right"
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
		"up":
			_step(1.0)
		"down":
			_step(-1.0)
		"left":
			_turn(1.0)
		"right":
			_turn(-1.0)

# gdlint: enable=max-returns
