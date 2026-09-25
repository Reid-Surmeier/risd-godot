## Prototype (owner's reference nohluhn.com/archive, 2026-09-25: every window there carries
## `filter: drop-shadow(0 4px 2px #00000080)`; the owner wants it wider and far more diffuse): a light
## grey drop shadow under every window of every Page, lifting (falling further, wider, softer) while the
## window is dragged. It is the window's visible box blurred exactly on the GPU (window_shadow.gdshader).
## One zero-size node per window, just below it: nothing to click, so no Tenant's window picking
## ever finds it; it follows the window's place, scale, visibility and stacking every frame.
extends Node

const SHADER := preload("res://modules/shell/window_shadow.gdshader")
const DesktopIcons := preload("res://modules/shell/desktop_icons.gd")
# At rest / while dragged (the window lifts: the shadow falls further, wider, softer). Page px.
const AMB_ALPHA := [0.4, 0.34]  # light grey on white paper; the reference's is 0.5 but tight
const AMB_OFFSET := [9.0, 24.0]
const AMB_SIGMA := [18.0, 30.0]  # the gaussian's standard deviation: wide and diffuse
const SPREAD := [2.0, 4.0]
const CONTACT_ALPHA := [0.14, 0.06]  # a faint tight shadow right under the edge keeps the window grounded
const CONTACT_OFFSET := 2.0
const CONTACT_SIGMA := 2.5
const LIFT_SECONDS := 0.16
const MIN_SIZE := Vector2(40, 30)  # smaller children are not windows

var _tenant: Control
var _holder: Control
var _shadows := {}  # window -> {node, last, lift}
static var _white: Texture2D


static func attach(tenant: Control) -> void:
	var s = load("res://modules/shell/window_shadows.gd").new()
	s.name = "WindowShadows"
	s._tenant = tenant
	s._holder = DesktopIcons.window_holder(tenant)
	tenant.add_child(s)


func _process(delta: float) -> void:
	for c in _holder.get_children():
		if c is Control and not _shadows.has(c) and _is_window(c):
			_shadows[c] = {"node": _make(c), "last": c.position, "lift": 0.0, "dragged": false}
	for window in _shadows.keys():
		var e: Dictionary = _shadows[window]
		if not is_instance_valid(window) or window.get_parent() != _holder:
			if is_instance_valid(e.node):
				e.node.queue_free()
			_shadows.erase(window)
			continue
		# lifted from the first move under a held button until the button is let go (a drag, however it pauses)
		var held := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		e.dragged = held and (e.get("dragged", false) or window.position != e.last)
		e.last = window.position
		e.lift = move_toward(e.lift, 1.0 if e.dragged else 0.0, delta / LIFT_SECONDS)
		_sync(window, e)


func _is_window(c: Control) -> bool:
	if c.get_meta("window_shadow", false) or c.name == "DesktopIcons" or DesktopIcons.is_backdrop(c, _tenant):
		return false
	return c.size.x >= MIN_SIZE.x and c.size.y >= MIN_SIZE.y


## The window's visible box in its own px: the opaque part of its picture (the window's own texture,
## or the child texture that covers most of it: its frame), else the window's rectangle.
func _box_of(window: Control) -> Rect2:
	for c in [window] + window.get_children():
		if not (c is TextureRect) or c.texture == null or c.texture is AtlasTexture or c.stretch_mode != TextureRect.STRETCH_SCALE:
			continue
		var r := Rect2(Vector2.ZERO, window.size) if c == window else Rect2(c.position, c.size * c.scale)
		if r.get_area() < 0.85 * window.size.x * window.size.y:
			continue
		var used := _used_uv(c.texture)
		window.set_meta("shadow_radius", _radius_uv(c.texture) * r.size.x)
		return Rect2(r.position + used.position * r.size, used.size * r.size)
	return Rect2(Vector2.ZERO, window.size)


static var _radii := {}  # texture -> its top-left corner's radius, as a fraction of its width


## A rounded corner leaves a clear gap along the diagonal; its radius is ~3.41 times that gap.
static func _radius_uv(tex: Texture2D) -> float:
	if not _radii.has(tex):
		var r := 0.0
		var img := tex.get_image()
		if img != null:
			img = img.duplicate()
			if img.is_compressed():
				img.decompress()
			var used := img.get_used_rect()
			var d := 0
			while d < mini(used.size.x, used.size.y) / 4 and img.get_pixelv(used.position + Vector2i(d, d)).a < 0.5:
				d += 1
			r = d * 3.41 / float(img.get_width())
		_radii[tex] = r
	return _radii[tex]


static var _used := {}  # texture -> its opaque part, in 0..1


static func _used_uv(tex: Texture2D) -> Rect2:
	if not _used.has(tex):
		var img := tex.get_image()
		var used := Rect2(0, 0, 1, 1)
		if img != null:
			img = img.duplicate()
			if img.is_compressed():
				img.decompress()
			var r := img.get_used_rect()
			if r.size.x > 0 and r.size.y > 0:
				used = Rect2(Vector2(r.position) / Vector2(img.get_size()), Vector2(r.size) / Vector2(img.get_size()))
		_used[tex] = used
	return _used[tex]


func _make(window: Control) -> Control:
	var node := Control.new()
	node.name = "Shadow_" + window.name
	node.set_meta("window_shadow", true)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.size = Vector2.ZERO
	var material := ShaderMaterial.new()
	material.shader = SHADER
	node.material = material
	node.draw.connect(_draw_shadow.bind(node, window))
	_holder.add_child(node)
	return node


func _sync(window: Control, e: Dictionary) -> void:
	var node: Control = e.node
	node.visible = window.visible and window.modulate.a > 0.01
	var k := maxf(window.get_global_transform().get_scale().x, 0.001)  # page px -> window px
	var t: float = e.lift
	node.position = window.position
	node.scale = window.scale
	node.modulate.a = window.modulate.a
	var box := _box_of(window)
	var sigma := lerpf(AMB_SIGMA[0], AMB_SIGMA[1], t) / k
	var offset := lerpf(AMB_OFFSET[0], AMB_OFFSET[1], t) / k
	var pad := sigma * 3.0 + offset + lerpf(SPREAD[0], SPREAD[1], t) / k
	var quad := box.grow(pad)
	var m: ShaderMaterial = node.material
	m.set_shader_parameter("quad_pos", quad.position)
	m.set_shader_parameter("quad_size", quad.size)
	m.set_shader_parameter("box", Vector4(box.position.x, box.position.y, box.size.x, box.size.y))
	m.set_shader_parameter("spread", lerpf(SPREAD[0], SPREAD[1], t) / k)
	m.set_shader_parameter("amb_offset", offset)
	m.set_shader_parameter("amb_sigma", sigma)
	m.set_shader_parameter("amb_alpha", lerpf(AMB_ALPHA[0], AMB_ALPHA[1], t))
	m.set_shader_parameter("contact_offset", CONTACT_OFFSET / k)
	m.set_shader_parameter("contact_sigma", CONTACT_SIGMA / k)
	m.set_shader_parameter("contact_alpha", lerpf(CONTACT_ALPHA[0], CONTACT_ALPHA[1], t))
	m.set_shader_parameter("radius", float(window.get_meta("shadow_radius", 0.0)))
	if node.get_meta("quad", Rect2()) != quad:
		node.set_meta("quad", quad)
		node.queue_redraw()
	if node.get_index() != window.get_index() - 1:  # just below its window, wherever it was raised to
		_holder.move_child(node, window.get_index() if node.get_index() > window.get_index() else window.get_index() - 1)


func _draw_shadow(node: Control, _window: Control) -> void:
	node.draw_texture_rect(_white_texture(), node.get_meta("quad", Rect2()), false)


static func _white_texture() -> Texture2D:
	if _white == null:
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_white = ImageTexture.create_from_image(img)
	return _white
