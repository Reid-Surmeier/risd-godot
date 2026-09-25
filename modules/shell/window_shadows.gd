## Prototype (owner's reference nohluhn.com/archive, 2026-09-25, whose windows each carry
## `filter: drop-shadow(0 4px 2px #00000080)`; tuned with the owner: soft, light, minimal): a drop
## shadow under every window of every Page, in the shape the window actually draws (its pictures,
## buttons, panels and viewports; never its bare bounding box), lifting while the window is dragged.
## The silhouette is built on the CPU at a quarter of page resolution when the window's size or pieces
## change; the blur and the lift are GPU work every frame (window_shadow.gdshader).
## One zero-size node per window, just below it: nothing to click, so no Tenant's window picking
## ever finds it; it follows the window's place, visibility and stacking every frame.
extends Node

const SHADER := preload("res://modules/shell/window_shadow.gdshader")
const DesktopIcons := preload("res://modules/shell/desktop_icons.gd")
# At rest / while dragged. Page px.
const STRENGTH := [0.16, 0.2]
const OFFSET := [5.0, 14.0]
const SIGMA := [10.0, 18.0]
const LIFT_SECONDS := 0.16
const DS := 4.0  # page px per silhouette texel
const PAD := 64.0  # page px of room around the silhouette for the blur and the fall
const MIN_SIZE := Vector2(40, 30)  # smaller children are not windows
const SKIP := ["HoverGlow", "DesktopIcons"]

var _tenant: Control
var _holder: Control
var _shadows := {}  # window -> {node, last, lift, dragged, key, rect (page px, relative to the window's origin)}
static var _alpha_cache := {}  # texture -> its alpha, at most 256 px on the long side


static func attach(tenant: Control) -> void:
	var s = load("res://modules/shell/window_shadows.gd").new()
	s.name = "WindowShadows"
	s._tenant = tenant
	s._holder = DesktopIcons.window_holder(tenant)
	tenant.add_child(s)


func _process(delta: float) -> void:
	for c in _holder.get_children():
		if c is Control and not _shadows.has(c) and _is_window(c):
			_shadows[c] = {"node": _make(c), "last": c.position, "lift": 0.0, "dragged": false, "key": ""}
	for window in _shadows.keys():
		var e: Dictionary = _shadows[window]
		if not is_instance_valid(window) or window.get_parent() != _holder:
			if is_instance_valid(e.node):
				e.node.queue_free()
			_shadows.erase(window)
			continue
		# lifted from the first move under a held button until the button is let go (a drag, however it pauses)
		var held := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		e.dragged = held and (e.dragged or window.position != e.last)
		e.last = window.position
		e.lift = move_toward(e.lift, 1.0 if e.dragged else 0.0, delta / LIFT_SECONDS)
		_sync(window, e)


func _is_window(c: Control) -> bool:
	if c.get_meta("window_shadow", false) or c.name in SKIP or DesktopIcons.is_backdrop(c, _tenant):
		return false
	return c.size.x >= MIN_SIZE.x and c.size.y >= MIN_SIZE.y


func _make(window: Control) -> Control:
	var node := Control.new()
	node.name = "Shadow_" + window.name
	node.set_meta("window_shadow", true)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.size = Vector2.ZERO
	var material := ShaderMaterial.new()
	material.shader = SHADER
	node.material = material
	node.draw.connect(func():
		if node.has_meta("mask"):
			node.draw_texture_rect(node.get_meta("mask"), node.get_meta("draw_rect", Rect2()), false))
	_holder.add_child(node)
	return node


func _sync(window: Control, e: Dictionary) -> void:
	var node: Control = e.node
	node.visible = window.is_visible_in_tree() and window.modulate.a > 0.01
	if not node.visible:
		return
	var key := "%s|%s|%d" % [window.size, window.get_global_transform().get_scale(), window.get_child_count()]
	if e.key != key:
		e.key = key
		_build(window, _pieces(window), e)
	var t: float = e.lift
	var origin := window.get_global_transform().origin
	var g: Rect2 = e.rect
	g.position += origin
	var inv := _holder.get_global_transform().affine_inverse()
	var hs := _holder.get_global_transform().get_scale()
	var local := Rect2(inv * g.position, g.size / hs)
	if node.get_meta("draw_rect", Rect2()) != local:
		node.set_meta("draw_rect", local)
		node.queue_redraw()
	var m: ShaderMaterial = node.material
	m.set_shader_parameter("sigma", lerpf(SIGMA[0], SIGMA[1], t) / DS)
	m.set_shader_parameter("offset", Vector2(0, lerpf(OFFSET[0], OFFSET[1], t) / g.size.y))
	m.set_shader_parameter("strength", lerpf(STRENGTH[0], STRENGTH[1], t))
	node.modulate.a = window.modulate.a
	if node.get_index() != window.get_index() - 1:  # just below its window, wherever it was raised to
		_holder.move_child(node, window.get_index() if node.get_index() > window.get_index() else window.get_index() - 1)


## Every piece the window draws, as [kind, control]: pictures by their alpha, flat pieces as rectangles.
func _pieces(window: Control) -> Array:
	var out := []
	var stack: Array = [window]
	while not stack.is_empty():
		var c = stack.pop_back()
		if not (c is Control) or not c.visible or c.name in SKIP or c.get_meta("window_shadow", false):
			continue
		if c is TextureRect and c.texture != null:
			out.append(["tex", c])
		elif c is TextureButton and c.texture_normal != null:
			out.append(["tex", c])
		elif (c is ColorRect and c.color.a > 0.05) or c is SubViewportContainer or c is NinePatchRect:
			out.append(["rect", c])
		elif c is Panel or c is PanelContainer:
			var box = c.get_theme_stylebox("panel")
			if box is StyleBoxFlat and box.bg_color.a > 0.05 or box is StyleBoxTexture:
				out.append(["rect", c])
		stack.append_array(c.get_children())
	return out


## The silhouette mask, in page px around the window's origin, padded by PAD.
func _build(window: Control, pieces: Array, e: Dictionary) -> void:
	var origin := window.get_global_transform().origin
	var bounds := Rect2()
	var rects := []
	for p in pieces:
		var c: Control = p[1]
		var r := c.get_global_rect()
		r.position -= origin
		rects.append(r)
		bounds = r if bounds.size == Vector2.ZERO else bounds.merge(r)
	if bounds.size == Vector2.ZERO:
		bounds = Rect2(Vector2.ZERO, window.size * window.get_global_transform().get_scale())
	bounds = bounds.grow(PAD)
	var size := Vector2i((bounds.size / DS).ceil())
	var mask := Image.create(maxi(size.x, 1), maxi(size.y, 1), false, Image.FORMAT_RGBA8)
	for i in pieces.size():
		var c: Control = pieces[i][1]
		var r: Rect2 = rects[i]
		var at := Vector2i(((r.position - bounds.position) / DS).round())
		var span := Vector2i((r.size / DS).round())
		if span.x < 1 or span.y < 1:
			continue
		if pieces[i][0] == "rect":
			mask.fill_rect(Rect2i(at, span), Color.WHITE)
			continue
		var tex: Texture2D = c.texture if c is TextureRect else c.texture_normal
		var alpha := _alpha_of(tex)
		if alpha == null:
			mask.fill_rect(Rect2i(at, span), Color.WHITE)
			continue
		var img := alpha.duplicate()
		var mode: int = c.stretch_mode if c is TextureRect else TextureRect.STRETCH_SCALE
		if mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED or mode == TextureRect.STRETCH_KEEP_ASPECT:
			var k := minf(float(span.x) / tex.get_width(), float(span.y) / tex.get_height())
			var fit := Vector2i(maxi(1, roundi(tex.get_width() * k)), maxi(1, roundi(tex.get_height() * k)))
			if mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
				at += (span - fit) / 2
			span = fit
		elif mode == TextureRect.STRETCH_TILE:
			mask.fill_rect(Rect2i(at, span), Color.WHITE)
			continue
		img.resize(span.x, span.y, Image.INTERPOLATE_BILINEAR)
		mask.blend_rect(img, Rect2i(Vector2i.ZERO, span), at)
	e.rect = bounds
	var old: Texture2D = e.node.get_meta("mask") if e.node.has_meta("mask") else null
	if old is ImageTexture and old.get_size() == Vector2(mask.get_size()):
		old.update(mask)
	else:
		e.node.set_meta("mask", ImageTexture.create_from_image(mask))
	e.node.queue_redraw()


## A picture (a region of an atlas included) at most 256 px on its long side; only its alpha is used.
static var _atlas_cache := {}  # source texture -> its full image, decompressed


static func _alpha_of(tex: Texture2D) -> Image:
	if _alpha_cache.has(tex):
		return _alpha_cache[tex]
	var src := tex
	var region := Rect2i()
	if tex is AtlasTexture and tex.atlas != null:
		src = tex.atlas
		region = Rect2i(tex.region)
	if not _atlas_cache.has(src):
		var full := src.get_image() if src != null else null
		if full != null:
			full = full.duplicate()
			if full.is_compressed():
				full.decompress()
			full.convert(Image.FORMAT_RGBA8)
		_atlas_cache[src] = full
	var img: Image = _atlas_cache[src]
	if img != null:
		img = img.get_region(region) if region.size.x > 0 else img.duplicate()
		var k := minf(1.0, 256.0 / maxf(img.get_width(), img.get_height()))
		img.resize(maxi(1, roundi(img.get_width() * k)), maxi(1, roundi(img.get_height() * k)), Image.INTERPOLATE_BILINEAR)
	_alpha_cache[tex] = img
	return img
