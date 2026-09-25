## Prototype (owner's reference nohluhn.com/archive, 2026-09-25: every window there carries
## `filter: drop-shadow(0 4px 2px #00000080)`): a light grey drop shadow under every window of every
## Page, lifting (falling further, softer) while the window is dragged. The shadow is the shape of the window's picture
## (the window's own texture, or the child texture that is its frame), blurred on the GPU
## (window_shadow.gdshader); a window drawn some other way gets a soft rectangle.
## One zero-size node per window, just below it: nothing to click, so no Tenant's window picking
## ever finds it; it follows the window's place, scale, visibility and stacking every frame.
extends Node

const SHADER := preload("res://modules/shell/window_shadow.gdshader")
const DesktopIcons := preload("res://modules/shell/desktop_icons.gd")
const COLOR := Color(0.0, 0.0, 0.0, 0.3)  # light grey on white paper; the reference's is 0.5
const OFFSET := 5.0  # page px down (the reference: 4 css px on a 1060 px page)
const BLUR := 4.0  # page px
const LIFT_OFFSET := 12.0  # while dragged: the window lifts, the shadow falls further and softer
const LIFT_BLUR := 10.0
const LIFT_SECONDS := 0.12
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


## The picture whose alpha is the window's shape: the window itself, or the child texture that
## covers most of it (its frame); null means the window's rectangle.
func _shape_of(window: Control) -> Array:  # [texture, rect in window px]
	var candidates: Array = [window] + window.get_children()
	for c in candidates:
		if not (c is TextureRect) or c.texture == null or c.texture is AtlasTexture or c.stretch_mode == TextureRect.STRETCH_TILE:
			continue
		var r := Rect2(Vector2.ZERO, window.size) if c == window else Rect2(c.position, c.size * c.scale)
		if r.get_area() >= 0.85 * window.size.x * window.size.y:
			return [c.texture, r]
	return [null, Rect2(Vector2.ZERO, window.size)]


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
	var off := lerpf(OFFSET, LIFT_OFFSET, e.lift) / k
	node.position = window.position + Vector2(0, off) * window.scale.y
	node.scale = window.scale
	node.modulate.a = window.modulate.a
	var shape := _shape_of(window)
	var blur := lerpf(BLUR, LIFT_BLUR, e.lift) / k
	var key := "%s|%s|%s|%.2f" % [shape[0], shape[1], window.size, blur]
	if node.get_meta("key", "") != key:
		node.set_meta("key", key)
		node.set_meta("shape", shape)
		var m: ShaderMaterial = node.material
		m.set_shader_parameter("shadow_color", COLOR)
		m.set_shader_parameter("blur", blur)
		m.set_shader_parameter("pad", blur * 2.0 + 2.0)
		m.set_shader_parameter("quad_size", (shape[1] as Rect2).size)
		node.queue_redraw()
	if node.get_index() != window.get_index() - 1:  # just below its window, wherever it was raised to
		_holder.move_child(node, window.get_index() if node.get_index() > window.get_index() else window.get_index() - 1)


func _draw_shadow(node: Control, window: Control) -> void:
	var shape: Array = node.get_meta("shape", [])
	if shape.is_empty():
		return
	var tex: Texture2D = shape[0] if shape[0] != null else _white_texture()
	node.draw_texture_rect(tex, shape[1], false)


static func _white_texture() -> Texture2D:
	if _white == null:
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_white = ImageTexture.create_from_image(img)
	return _white
