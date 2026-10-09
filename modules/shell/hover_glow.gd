## Prototype (owner's references: the kiiikiii.kr hover glow, the nodate.club two-state cursor).
## A hovered button or tab gives off soft white light: the control's
## drawn pixels (every PNG piece it is
## built from, at the size and stretch it is drawn with) are gathered into
## one silhouette, blurred REACH_PX
## screen pixels out into the scene and faded in over FADE_IN, out over
## FADE_OUT. The light is computed on
## first hover and kept until the control resizes. The arrow cursor
## switches to its hover state over it.
## White only (owner's call): on white paper the light has nothing to brighten, by design.
extends RefCounted

const REACH_PX := 90.0  # how far the light spreads past the edge, in screen pixels
# the blur runs on a quarter-size silhouette; the light is scaled back up smoothly
const DOWNSAMPLE := 4
const GAIN := 3.2  # extreme (owner's variation): full white well past the edge before it falls off
const INNER := 0.0  # none on the control itself: only the area around it lights up
const FADE_IN := 0.22
const FADE_OUT := 0.45
const ARROW := "res://assets/cursor/arrow.png"
const ARROW_HOVER := "res://assets/cursor/arrow-hover.png"
const CURSOR_PX := 32


## The owner-supplied cursor pair, when present: each scaled down by a
## whole factor to at most CURSOR_PX
## tall (pixel art stays crisp), its hotspot at the arrow's tip (the
## top-left-most solid pixel). Without
## the files the system arrow stays.
static func use_cursor() -> void:
	for pair in [[ARROW, Input.CURSOR_ARROW], [ARROW_HOVER, Input.CURSOR_POINTING_HAND]]:
		var cursor := arrow_texture(pair[0])
		if cursor != null:
			Input.set_custom_mouse_cursor(cursor, pair[1], cursor.get_meta("tip"))
			if pair[1] == Input.CURSOR_ARROW:
				# ponytail: the Sketchbook hands the arrow back after its brush cursor; it reads it from here,
				# not through an interface. A cursor seam (an Issue) if the prototype stays.
				Engine.set_meta("arrow_cursor", cursor)


static func arrow_texture(path: String = ARROW) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var img: Image = (load(path) as Texture2D).get_image().duplicate()
	img.convert(Image.FORMAT_RGBA8)
	var factor := ceili(float(img.get_height()) / CURSOR_PX)
	if factor > 1:
		img.resize(img.get_width() / factor, img.get_height() / factor, Image.INTERPOLATE_NEAREST)
	var tip := Vector2.ZERO
	var best := 1 << 30
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.8 and x + y < best:
				best = x + y
				tip = Vector2(x, y)
	var tex := ImageTexture.create_from_image(img)
	tex.set_meta("tip", tip)
	return tex


static func attach_all(root: Node) -> void:
	for button in root.find_children("*", "BaseButton", true, false):
		attach(button)


static func attach(target: Control) -> void:
	if target.has_meta("hover_glow"):
		return
	var halo := TextureRect.new()
	halo.name = "HoverGlow"
	halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	halo.stretch_mode = TextureRect.STRETCH_SCALE
	halo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	halo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	halo.z_index = 1  # over the neighbours, so the light falls on the area around the control
	halo.modulate.a = 0.0
	halo.visible = false
	target.add_child(halo)
	target.set_meta("hover_glow", halo)
	for c in [target] + target.find_children("*", "Control", true, false):
		if c != halo:
			c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var fade := func(to: float, seconds: float):
		if halo.has_meta("tween"):
			(halo.get_meta("tween") as Tween).kill()
		halo.visible = true
		var t := halo.create_tween()
		t.tween_property(halo, "modulate:a", to, seconds * absf(to - halo.modulate.a))
		if to == 0.0:
			t.tween_callback(func(): halo.visible = false)
		halo.set_meta("tween", t)
	target.mouse_entered.connect(
		func():
			_light(target, halo)
			fade.call(1.0, FADE_IN)
	)
	target.mouse_exited.connect(func(): fade.call(0.0, FADE_OUT))
	target.hidden.connect(
		func():
			halo.modulate.a = 0.0
			halo.visible = false
	)


## Build (or reuse) the light for the control's current size and scale.
static func _light(target: Control, halo: TextureRect) -> void:
	var s := maxf(target.get_global_transform().get_scale().x, 0.01)  # the tabs sit in a scaled strip
	var key := "%s@%.3f" % [target.size, s]
	if halo.get_meta("key", "") == key:
		return
	halo.set_meta("key", key)
	var mask := _silhouette(target, s)
	halo.texture = ImageTexture.create_from_image(_glow(mask))
	halo.position = -Vector2(REACH_PX, REACH_PX) / s
	halo.size = Vector2(mask.get_size()) / s


## The control's drawn pixels in screen pixels, REACH_PX of empty margin on every side.
static func _silhouette(target: Control, s: float) -> Image:
	var size := Vector2i((target.size * s).ceil()) + Vector2i.ONE * int(REACH_PX) * 2
	var mask := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var origin := target.get_global_rect().position - Vector2(REACH_PX, REACH_PX)
	var drew := false
	for piece in [target] + target.find_children("*", "Control", true, false):
		if piece.name == "HoverGlow" or not piece.is_visible_in_tree():
			continue
		var r: Rect2 = piece.get_global_rect()
		var at := Vector2i((r.position - origin).round())
		var span := Vector2i(r.size.round())
		if span.x < 1 or span.y < 1:
			continue
		var tex: Texture2D = null
		var mode := TextureRect.STRETCH_SCALE
		if piece is TextureRect:
			tex = piece.texture
			mode = piece.stretch_mode
		elif piece is TextureButton:
			tex = piece.texture_normal
		elif piece is Button:
			var box = piece.get_theme_stylebox("normal")
			if box is StyleBoxTexture:
				tex = box.texture
			elif not piece.flat or piece.icon != null:
				mask.fill_rect(Rect2i(at, span), Color.WHITE)
				drew = true
		if tex == null:
			continue
		var img := tex.get_image()
		if img == null:
			continue
		img = img.duplicate()
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		var gs: float = piece.get_global_transform().get_scale().x
		if mode == TextureRect.STRETCH_KEEP or mode == TextureRect.STRETCH_KEEP_CENTERED:
			img.resize(
				maxi(1, roundi(img.get_width() * gs)),
				maxi(1, roundi(img.get_height() * gs)),
				Image.INTERPOLATE_BILINEAR
			)
			if mode == TextureRect.STRETCH_KEEP_CENTERED:
				at += (span - img.get_size()) / 2
			mask.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size().min(span)), at)
		elif mode == TextureRect.STRETCH_TILE:
			img.resize(
				maxi(1, roundi(img.get_width() * gs)),
				maxi(1, roundi(img.get_height() * gs)),
				Image.INTERPOLATE_BILINEAR
			)
			for y in range(0, span.y, img.get_height()):
				for x in range(0, span.x, img.get_width()):
					mask.blend_rect(
						img,
						Rect2i(Vector2i.ZERO, img.get_size().min(span - Vector2i(x, y))),
						at + Vector2i(x, y)
					)
		else:
			img.resize(span.x, span.y, Image.INTERPOLATE_BILINEAR)
			mask.blend_rect(img, Rect2i(Vector2i.ZERO, span), at)
		drew = true
	if not drew:  # nothing drawn (a bare flat button): its rect stands in
		mask.fill_rect(
			Rect2i(Vector2i.ONE * int(REACH_PX), Vector2i((target.size * s).ceil())), Color.WHITE
		)
	return mask


## White light: the silhouette's alpha blurred (three box passes each way,
## near a gaussian) and brightened;
## cut out where the control draws (INNER of it left there), so the control keeps its own look.
static func _glow(mask: Image) -> Image:
	var full := mask.get_size()
	var small := mask.duplicate() as Image
	small.resize(
		maxi(1, full.x / DOWNSAMPLE), maxi(1, full.y / DOWNSAMPLE), Image.INTERPOLATE_BILINEAR
	)
	var w := small.get_width()
	var h := small.get_height()
	var a := PackedFloat32Array()
	a.resize(w * h)
	for y in h:
		for x in w:
			a[y * w + x] = small.get_pixel(x, y).a
	var radius := maxi(1, int(REACH_PX / DOWNSAMPLE / 3.0))
	for _i in 3:
		a = _box(a, w, h, radius, true)
		a = _box(a, w, h, radius, false)
	for y in h:
		for x in w:
			small.set_pixel(x, y, Color(1, 1, 1, minf(a[y * w + x] * GAIN, 1.0)))
	small.resize(full.x, full.y, Image.INTERPOLATE_CUBIC)
	for y in full.y:
		for x in full.x:
			var c := small.get_pixel(x, y)
			c.a *= 1.0 - (1.0 - INNER) * mask.get_pixel(x, y).a
			small.set_pixel(x, y, c)
	return small


## One sliding-window box blur along rows (horizontal) or columns, edges clamped.
static func _box(
	src: PackedFloat32Array, w: int, h: int, r: int, horizontal: bool
) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(w * h)
	var n := w if horizontal else h
	var lines := h if horizontal else w
	var norm := 1.0 / float(2 * r + 1)
	for line in lines:
		var at := func(i: int) -> int:
			i = clampi(i, 0, n - 1)
			return line * w + i if horizontal else i * w + line
		var sum := 0.0
		for i in range(-r, r + 1):
			sum += src[at.call(i)]
		for i in n:
			out[at.call(i)] = sum * norm
			sum += src[at.call(i + r + 1)] - src[at.call(i - r)]
	return out
