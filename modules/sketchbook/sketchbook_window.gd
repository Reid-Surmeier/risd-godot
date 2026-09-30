extends Control
## Original open-book texture and its baked edge shadow, with drawing and page turns.
## The transparent top paper margin is the drag handle; there is no surrounding frame.

const SketchbookDrawingSurface := preload("res://modules/sketchbook/drawing_surface.gd")
const PaperTurn := preload("res://modules/sketchbook/paper_turn.gd")

signal layout_changed

const FOOTER := 44
const BUTTON_SIZE := Vector2(61, 32)  # the 84x44 reference button, reduced
const MIN_SIZE := Vector2(420, 380)
# The drawable page interior inside the book image (fractions, from the web prototype).
const HITBOX_INSET := Rect2(0.03, 0.043, 0.94, 0.911)
const TURN_SECONDS := 0.52
var turn_seconds := TURN_SECONDS  # QA can slow it (?turn-seconds=) to photograph frames

var spread := 1
var title_bar: Control
var resize_handle: Control
var book: TextureRect
var previous_button: TextureButton
var next_button: TextureButton
var surface: SketchbookDrawingSurface
var gutter: TextureRect
var turn: PaperTurn
var face_viewport: SubViewport
var face_paper: TextureRect
var face_ink: SketchbookDrawingSurface
var stationary: Control
var stationary_ink: SketchbookDrawingSurface
var turning := ""
var turn_started_ms := 0
var last_turn_ms := 0
var _resizing := false
var _resize_anchor := Vector2.ZERO
var _resize_origin := Vector2.ZERO


func _ready() -> void:
	custom_minimum_size = MIN_SIZE
	# This original texture carries its own edge shadow, so skip the Shell’s additional mask.
	set_meta("window_shadow", true)
	book = TextureRect.new()
	book.name = "book"
	book.texture = load("res://modules/sketchbook/assets/sketchbook-page-v005-soft-384.png")
	book.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	book.stretch_mode = TextureRect.STRETCH_SCALE
	book.texture_filter = TEXTURE_FILTER_LINEAR
	book.mouse_filter = MOUSE_FILTER_IGNORE
	# Unmatte only the neutral white surround/shadow at draw time. The original cream
	# paper stays opaque; its existing shadow blends over windows underneath, not a white box.
	var matte := Shader.new()
	matte.code = """shader_type canvas_item;
void fragment() {
    float lo = min(COLOR.r, min(COLOR.g, COLOR.b));
    float hi = max(COLOR.r, max(COLOR.g, COLOR.b));
    if (hi - lo < 0.035 && lo > 0.6) {
        float alpha = 1.0 - lo;
        COLOR = vec4((COLOR.rgb - vec3(lo)) / max(alpha, 0.001), alpha * COLOR.a);
    }
}"""
	var paper_material := ShaderMaterial.new()
	paper_material.shader = matte
	book.material = paper_material
	add_child(book)
	surface = SketchbookDrawingSurface.new()
	surface.name = "drawing-surface"
	surface.strokes_changed.connect(layout_changed.emit)
	surface.pointer_changed.connect(layout_changed.emit)
	add_child(surface)
	gutter = TextureRect.new()
	gutter.name = "center-gutter"
	gutter.texture = _gutter_texture()
	gutter.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gutter.stretch_mode = TextureRect.STRETCH_SCALE
	gutter.mouse_filter = MOUSE_FILTER_IGNORE
	var multiply := CanvasItemMaterial.new()
	multiply.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	gutter.material = multiply
	add_child(gutter)
	_build_turn()
	title_bar = Control.new()
	title_bar.name = "title-bar"
	title_bar.mouse_default_cursor_shape = CURSOR_DRAG
	title_bar.tooltip_text = "Sketchbook"
	add_child(title_bar)
	previous_button = _arrow("previous-page", "prev")
	next_button = _arrow("next-page", "next")
	previous_button.pressed.connect(func(): turn_page("backward"))
	next_button.pressed.connect(func(): turn_page("forward"))
	resize_handle = Control.new()
	resize_handle.name = "resize-handle"
	resize_handle.size = Vector2(12, 12)
	resize_handle.mouse_default_cursor_shape = CURSOR_FDIAGSIZE
	resize_handle.gui_input.connect(_on_resize_input)
	add_child(resize_handle)
	resized.connect(_layout)
	show_spread(1)
	_layout()


func _arrow(node_name: String, kind: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load("res://modules/sketchbook/assets/ro-btn-%s.png" % kind)
	if kind == "prev":
		button.texture_disabled = load("res://modules/sketchbook/assets/ro-btn-prev-disabled.png")
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = TEXTURE_FILTER_LINEAR
	button.size = BUTTON_SIZE
	add_child(button)
	return button


func show_spread(next_spread: int) -> void:
	spread = maxi(1, next_spread)
	surface.show_spread(spread)
	previous_button.disabled = spread == 1 or turning != ""
	next_button.disabled = turning != ""
	layout_changed.emit()


## The web prototype's paper turn: the outgoing half of the page lifts about the spine as a cream
## card carrying its ink, rotates through the viewer with perspective, and lands on the other side;
## the half that does not move keeps the outgoing ink until the card lands.
func turn_page(direction: String) -> void:
	if turning != "" or (direction == "backward" and spread == 1):
		return
	var outgoing := spread
	turning = direction
	turn_started_ms = Time.get_ticks_msec()
	var forward := direction == "forward"
	var page := page_rect()
	var half := Vector2(page.size.x / 2.0, page.size.y)
	# Face texture: the outgoing half of the page itself (the book image's half) with its ink.
	face_viewport.size = Vector2i(int(ceil(half.x)), int(ceil(half.y)))
	face_paper.size = book.size
	face_paper.position = book.position - page.position - Vector2(half.x if forward else 0.0, 0.0)
	face_ink.position = Vector2(-half.x if forward else 0.0, 0.0)
	face_ink.size = page.size
	face_ink.render_spread = outgoing
	face_ink.spreads = surface.spreads
	face_ink.queue_redraw()
	face_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# The half that does not move keeps showing the outgoing spread's ink until the sheet lands.
	stationary.position = page.position + Vector2(0.0 if forward else half.x, 0.0)
	stationary.size = half
	stationary_ink.position = Vector2(0.0 if forward else -half.x, 0.0)
	stationary_ink.size = page.size
	stationary_ink.render_spread = outgoing
	stationary_ink.spreads = surface.spreads
	stationary_ink.queue_redraw()
	stationary.visible = true
	turn.direction = direction
	turn.progress = 0.0
	turn.hinge = page.position + Vector2(half.x, half.y / 2.0)
	turn.sheet_size = half
	turn.face = face_viewport.get_texture()
	turn.visible = true
	turn.queue_redraw()
	show_spread(spread + (1 if forward else -1))
	set_process(true)


func _process(delta: float) -> void:
	if turning == "":
		set_process(false)
		return
	turn.progress += delta / turn_seconds
	turn.queue_redraw()
	if turn.progress >= 1.0:
		_finish_turn()


func _finish_turn() -> void:
	turn.visible = false
	stationary.visible = false
	face_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	last_turn_ms = Time.get_ticks_msec() - turn_started_ms
	turning = ""
	previous_button.disabled = spread == 1
	next_button.disabled = false
	set_process(false)
	layout_changed.emit()


func _build_turn() -> void:
	face_viewport = SubViewport.new()
	face_viewport.name = "paper-turn-face"
	face_viewport.transparent_bg = false
	face_viewport.disable_3d = true
	face_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	face_viewport.msaa_2d = Viewport.MSAA_4X
	var cream := ColorRect.new()
	cream.color = PaperTurn.CREAM
	cream.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	face_viewport.add_child(cream)
	face_paper = TextureRect.new()
	face_paper.texture = book.texture
	face_paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face_paper.stretch_mode = TextureRect.STRETCH_SCALE
	face_paper.texture_filter = TEXTURE_FILTER_LINEAR
	face_viewport.add_child(face_paper)
	face_ink = SketchbookDrawingSurface.new()
	face_ink.name = "paper-turn-face-ink"
	face_ink.interactive = false
	face_ink.render_spread = 1
	face_viewport.add_child(face_ink)
	add_child(face_viewport)
	stationary = Control.new()
	stationary.name = "paper-turn-stationary"
	stationary.clip_contents = true
	stationary.mouse_filter = MOUSE_FILTER_IGNORE
	stationary.visible = false
	stationary_ink = SketchbookDrawingSurface.new()
	stationary_ink.name = "paper-turn-stationary-ink"
	stationary_ink.interactive = false
	stationary_ink.render_spread = 1
	stationary.add_child(stationary_ink)
	add_child(stationary)
	turn = PaperTurn.new()
	turn.name = "paper-turn"
	turn.mouse_filter = MOUSE_FILTER_IGNORE
	turn.visible = false
	add_child(turn)


## The web gutter: multiply gradient, transparent -> (112,84,53) 18% -> (76,55,34) 26% -> transparent.
func _gutter_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.42, 0.5, 0.58, 1.0])
	gradient.colors = PackedColorArray(
		[
			Color.WHITE,
			Color.WHITE.lerp(Color(112 / 255.0, 84 / 255.0, 53 / 255.0), 0.18),
			Color.WHITE.lerp(Color(76 / 255.0, 55 / 255.0, 34 / 255.0), 0.26),
			Color.WHITE,
			Color.WHITE,
		]
	)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 4
	return texture


func _layout() -> void:
	var w := size.x
	var h := size.y
	title_bar.position = Vector2.ZERO
	title_bar.size = Vector2(w, (h - FOOTER) * HITBOX_INSET.position.y)
	var content := Rect2(0, 0, w, h - FOOTER)
	var stage := content.size
	book.size = stage
	book.position = content.position
	var page := page_rect()
	surface.position = page.position
	surface.size = page.size
	gutter.position = Vector2(
		book.position.x + stage.x / 2.0 - 7.0, book.position.y + stage.y * 0.037
	)
	gutter.size = Vector2(14.0, stage.y * (1.0 - 0.037 - 0.039))
	turn.position = Vector2.ZERO
	turn.size = size
	var footer_y := h - FOOTER
	previous_button.position = Vector2(12, footer_y)
	next_button.position = Vector2(w - 12 - BUTTON_SIZE.x, footer_y)
	resize_handle.position = Vector2(w - 12, h - 12)
	layout_changed.emit()


## The drawable page interior in this window's local coordinates.
func page_rect() -> Rect2:
	return Rect2(book.position + book.size * HITBOX_INSET.position, book.size * HITBOX_INSET.size)


func _on_resize_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_resizing = event.pressed
		_resize_anchor = get_parent().get_local_mouse_position()
		_resize_origin = size
		accept_event()
	elif event is InputEventMouseMotion and _resizing:
		var desired: Vector2 = (
			_resize_origin + get_parent().get_local_mouse_position() - _resize_anchor
		)
		var minimum_scale := maxf(MIN_SIZE.x / _resize_origin.x, MIN_SIZE.y / _resize_origin.y)
		var scale := maxf(
			maxf(desired.x / _resize_origin.x, desired.y / _resize_origin.y), minimum_scale
		)
		size = _resize_origin * scale
		accept_event()


func qa_state() -> Dictionary:
	var page := page_rect()
	return {
		"spread": spread,
		"strokes": surface.stroke_count(),
		"turning": turning,
		"turn_progress": turn.progress if turning != "" else 1.0,
		"last_turn_ms": last_turn_ms,
		"page_rect": [page.position.x, page.position.y, page.size.x, page.size.y],
		"chrome_pieces": 0,
		"previous_disabled": previous_button.disabled,
		"visible": visible,
		"pointer": surface.qa_state(),
	}
