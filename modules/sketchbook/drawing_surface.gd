extends Control

signal strokes_changed
signal pointer_changed
## Native drawing page: tldraw-equivalent ink (Freehand port) in tldraw's size-m draw style,
## one stroke list per spread, the prototype's spine curvature applied to the rendered ink,
## and the pigment-loaded watercolor brush cursor.
## Ported unchanged in behaviour from figma-ui-ux-qwen-pipeline
## prototype/painting-tool-mixbox @ d2faa30
## viewer-godot/scripts/drawing_surface.gd (the global class_name dropped, the pixel paths moved).
## Reach it through interface.gd only.

const Freehand := preload("res://modules/sketchbook/freehand.gd")

const DEFAULT_INK := Color("#4465e9")  # tldraw light theme, blue
const STROKE_WIDTH := 4.5  # tldraw size m: theme stroke 2 * 1.75, plus 1
const CURVE_SCALE := 12.0  # the web filter's feDisplacementMap scale
# The web curve map: (x fraction, green channel / 255).
const CURVE_STOPS := [
	[0.0, 0.502],
	[0.36, 0.502],
	[0.47, 0.839],
	[0.5, 1.0],
	[0.53, 0.839],
	[0.64, 0.502],
	[1.0, 0.502]
]
const PENCIL_HEIGHT := 120.0
const PENCIL_TIP := Vector2(0.02, 0.02)
const BRUSH := preload("res://modules/sketchbook/assets/paintbox/watercolor-brush.png")
const BRUSH_SHADER := preload("res://modules/sketchbook/assets/paintbox/brush-tip.gdshader")
static var _blank_cursor: ImageTexture

var spread := 1
var spreads: Dictionary = {}  # spread -> Array[Dictionary{points, width, polygons}]
var ink_color := DEFAULT_INK
var stroke_width := STROKE_WIDTH
var stroke_opacity := 1.0
var tool := "draw"
var interactive := true
var render_spread := 0  # 0: the open spread; otherwise draw that spread (page-turn sheets)
var freehand := Freehand.new()
var active: Dictionary = {}
var redo_strokes: Dictionary = {}  # spread -> strokes removed by the prototype undo action
var pencil: TextureRect
var pencil_time := 0.0
var pen_down := false
var hovering := false
var perf_rebuild_us := 0  # accumulated since last perf read
var perf_draw_us := 0
var perf_draws := 0
var _last_size := Vector2.ZERO
var _dirty := false
var _static_dirty := true
var _static_viewport: SubViewport
var _static_ink: Control
var _static_view: TextureRect


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP if interactive else MOUSE_FILTER_IGNORE
	if interactive:
		# tldraw receives every pointer event; Godot merges motion into one event per frame by
		# default, which turns a fast sweep into a few straight segments.
		Input.use_accumulated_input = false
		if _blank_cursor == null:
			var blank := Image.create(8, 8, false, Image.FORMAT_RGBA8)
			blank.fill(Color(0, 0, 0, 0))
			_blank_cursor = ImageTexture.create_from_image(blank)
		set_process(false)
		# Finished ink is rasterised once into a texture; per-frame drawing is only the live stroke.
		_static_viewport = SubViewport.new()
		_static_viewport.name = "static-ink"
		_static_viewport.transparent_bg = true
		_static_viewport.disable_3d = true
		_static_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_static_ink = Control.new()
		_static_ink.mouse_filter = MOUSE_FILTER_IGNORE
		_static_ink.draw.connect(_draw_static_ink)
		_static_viewport.add_child(_static_ink)
		add_child(_static_viewport)
		_static_view = TextureRect.new()
		_static_view.name = "static-ink-view"
		_static_view.texture = _static_viewport.get_texture()
		_static_view.mouse_filter = MOUSE_FILTER_IGNORE
		_static_view.stretch_mode = TextureRect.STRETCH_KEEP
		_static_view.show_behind_parent = true
		add_child(_static_view)
		pencil = TextureRect.new()
		pencil.name = "brush-cursor"
		pencil.texture = BRUSH
		pencil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pencil.stretch_mode = TextureRect.STRETCH_SCALE
		pencil.texture_filter = TEXTURE_FILTER_NEAREST
		var texture_size: Vector2 = pencil.texture.get_size()
		pencil.size = Vector2(texture_size.x * PENCIL_HEIGHT / texture_size.y, PENCIL_HEIGHT)
		pencil.pivot_offset = Vector2(pencil.size.x * PENCIL_TIP.x, 0)
		pencil.mouse_filter = MOUSE_FILTER_IGNORE
		var brush_material := ShaderMaterial.new()
		brush_material.shader = BRUSH_SHADER
		brush_material.set_shader_parameter("pigment_color", ink_color)
		pencil.material = brush_material
		pencil.visible = false
		pencil.z_index = 20
		add_child(pencil)
	resized.connect(_on_resized)


## The page changed proportion: existing ink follows it (x and y scale independently).
func _on_resized() -> void:
	if interactive and _last_size.x > 0.0 and _last_size.y > 0.0 and size != _last_size:
		var factor := size / _last_size
		for index in spreads:
			for stroke in spreads[index]:
				var points: Array = stroke.points
				for i in range(points.size()):
					var pt: Vector3 = points[i]
					points[i] = Vector3(pt.x * factor.x, pt.y * factor.y, pt.z)
				_rebuild(stroke, true)
	else:
		for index in spreads:
			for stroke in spreads[index]:
				stroke.erase("render")
	_last_size = size
	_invalidate_static()


func _process(delta: float) -> void:
	if _dirty and not active.is_empty():
		# One rebuild per frame however many motion events arrived.
		var t0 := Time.get_ticks_usec()
		_rebuild(active, false)
		perf_rebuild_us += Time.get_ticks_usec() - t0
		_dirty = false
		queue_redraw()
	if pencil == null or not pencil.visible:
		return
	pencil_time += delta
	# pencil-hover: 2deg..3.5deg wobble over 1.35 s; pencil-press: -1deg at 95%.
	if pen_down:
		pencil.rotation_degrees = lerpf(pencil.rotation_degrees, -1.0, 0.35)
		pencil.scale = pencil.scale.lerp(Vector2(0.95, 0.95), 0.35)
	else:
		pencil.rotation_degrees = 2.75 + 0.75 * sin(pencil_time * TAU / 1.35 - PI / 2.0)
		pencil.scale = pencil.scale.lerp(Vector2.ONE, 0.35)


func _notification(what: int) -> void:
	if not interactive:
		return
	if what == NOTIFICATION_MOUSE_ENTER:
		hovering = true
		_place_pencil(get_local_mouse_position())  # never show it where it last was
		pencil.rotation_degrees = 2.75
		pencil.scale = Vector2.ONE
		pencil.visible = true
		# A transparent cursor image, not MOUSE_MODE_HIDDEN: the web platform re-applies the CSS
		# cursor on every shape change, which made the arrow flicker back over the page.
		Input.set_custom_mouse_cursor(_blank_cursor)
		set_process(true)
		pointer_changed.emit()
	elif what == NOTIFICATION_MOUSE_EXIT:
		hovering = false
		pencil.visible = false
		Input.set_custom_mouse_cursor(null)
		if pen_down:
			_end_stroke()
		pointer_changed.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if tool == "draw":
				_begin_stroke(event.position)
			elif tool == "eraser":
				erase_last_stroke()
		else:
			if tool == "draw":
				_end_stroke()
		accept_event()
	elif event is InputEventMouseMotion:
		_place_pencil(event.position)
		if pen_down:
			_extend_stroke(event.position)
		accept_event()


func _place_pencil(at: Vector2) -> void:
	if pencil != null:
		pencil.position = at - pencil.pivot_offset


func _begin_stroke(at: Vector2) -> void:
	pen_down = true
	pointer_changed.emit()
	var color := ink_color
	color.a *= stroke_opacity
	active = {
		"points": [Vector3(at.x, at.y, 0.5)],
		"width": stroke_width + _jitter() * stroke_width / 6.0,
		"polygons": [],
		"color": color
	}
	_rebuild(active, false)
	queue_redraw()


func _extend_stroke(at: Vector2) -> void:
	active.points.append(Vector3(at.x, at.y, 0.5))
	_dirty = true


func _end_stroke() -> void:
	if not pen_down:
		return
	pen_down = false
	_dirty = false
	_rebuild(active, true)
	_strokes_of(spread).append(active)
	_redo_of(spread).clear()
	active = {}
	if not hovering:
		set_process(false)
	_invalidate_static()
	strokes_changed.emit()


func _jitter() -> float:
	# tldraw adds rng(shape.id) * sw / 6 per shape; seed by stroke count so it is deterministic.
	return fmod(float(stroke_count() * 7919 % 1000) / 1000.0, 1.0)


func _rebuild(stroke: Dictionary, last: bool) -> void:
	stroke.polygons = freehand.ink_polygons(
		stroke.points, Freehand.draw_options(stroke.width, last)
	)
	# The streamlined centreline and radii: the robust fill when an outline self-intersects.
	var centers := PackedVector2Array()
	var radii := PackedFloat32Array()
	for i in range(freehand.point_count):
		centers.append(Vector2(freehand.pt_x[i], freehand.pt_y[i]))
		radii.append(freehand.rads[i])
	stroke.centers = centers
	stroke.radii = radii
	stroke.erase("render")


func _strokes_of(index: int) -> Array:
	if not spreads.has(index):
		spreads[index] = []
	return spreads[index]


func _redo_of(index: int) -> Array:
	if not redo_strokes.has(index):
		redo_strokes[index] = []
	return redo_strokes[index]


func set_tool(next_tool: String) -> void:
	tool = next_tool
	if tool != "draw" and pen_down:
		_end_stroke()
	if pencil != null:
		pencil.visible = hovering and tool == "draw"
	Input.set_custom_mouse_cursor(_blank_cursor if hovering and tool == "draw" else null)
	pointer_changed.emit()


func erase_last_stroke() -> void:
	var strokes := _strokes_of(spread)
	if strokes.is_empty():
		return
	_redo_of(spread).append(strokes.pop_back())
	_invalidate_static()
	strokes_changed.emit()


func undo() -> void:
	erase_last_stroke()


func redo() -> void:
	var undone := _redo_of(spread)
	if undone.is_empty():
		return
	_strokes_of(spread).append(undone.pop_back())
	_invalidate_static()
	strokes_changed.emit()


func can_undo() -> bool:
	return not _strokes_of(spread).is_empty()


func can_redo() -> bool:
	return not _redo_of(spread).is_empty()


func stroke_count(index: int = 0) -> int:
	return _strokes_of(index if index > 0 else spread).size()


func show_spread(index: int) -> void:
	if pen_down:
		_end_stroke()
	spread = maxi(1, index)
	_invalidate_static()


func _invalidate_static() -> void:
	_static_dirty = true
	if _static_viewport != null:
		_static_viewport.size = Vector2i(maxi(1, int(ceil(size.x))), maxi(1, int(ceil(size.y))))
		_static_view.size = size
		_static_ink.size = size
		_static_ink.queue_redraw()
		_static_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	queue_redraw()


## The web filter bows the ink toward the spine: y shifts up by CURVE_SCALE * (green - 0.5).
func _curve(p: Vector2) -> Vector2:
	var u := clampf(p.x / maxf(size.x, 1.0), 0.0, 1.0)
	var g := 0.502
	for i in range(1, CURVE_STOPS.size()):
		if u <= CURVE_STOPS[i][0]:
			var a: Array = CURVE_STOPS[i - 1]
			var b: Array = CURVE_STOPS[i]
			g = lerpf(a[1], b[1], (u - a[0]) / (b[0] - a[0]))
			break
	return Vector2(p.x, p.y - CURVE_SCALE * (g - 0.5))


func _draw() -> void:
	var t0 := Time.get_ticks_usec()
	_draw_ink_layers()
	perf_draw_us += Time.get_ticks_usec() - t0
	perf_draws += 1


func _draw_ink_layers() -> void:
	if not interactive:
		# Page-turn faces: draw the whole spread directly (they render once into their own viewport).
		for stroke in _strokes_of(render_spread if render_spread > 0 else spread):
			_draw_stroke(self, stroke)
		return
	if not active.is_empty():
		_draw_stroke(self, active)


## The finished strokes of the open spread, drawn into the static texture.
func _draw_static_ink() -> void:
	for stroke in _strokes_of(spread):
		_draw_stroke(_static_ink, stroke)


func _draw_stroke(target: CanvasItem, stroke: Dictionary) -> void:
	var color: Color = stroke.get("color", DEFAULT_INK)
	var render: Dictionary = _render_of(stroke)
	for piece in render.fills:
		RenderingServer.canvas_item_add_triangle_array(
			target.get_canvas_item(), piece.indices, piece.points, piece.colors
		)
		target.draw_polyline(piece.rim, color, 1.0, true)
	if render.capsules:
		_draw_capsules(target, stroke)


## Curved outline, triangulation and rim, computed once per stroke revision (finished strokes are
## static; the active stroke changes once per frame).
func _render_of(stroke: Dictionary) -> Dictionary:
	if stroke.has("render"):
		return stroke.render
	var fills: Array = []
	var capsules := false
	for polygon in stroke.polygons:
		if polygon.size() < 3:
			continue
		var curved := PackedVector2Array()
		curved.resize(polygon.size())
		for i in range(polygon.size()):
			curved[i] = _curve(polygon[i])
		var indices := Geometry2D.triangulate_polygon(curved)
		if indices.is_empty():
			capsules = true
			fills.clear()
			break
		var colors := PackedColorArray()
		colors.resize(curved.size())
		colors.fill(stroke.get("color", DEFAULT_INK))
		var rim := curved.duplicate()
		rim.append(curved[0])
		fills.append({"points": curved, "indices": indices, "colors": colors, "rim": rim})
	var render := {"fills": fills, "capsules": capsules}
	stroke.render = render
	return render


## tldraw fills its outline with the nonzero rule, so self-intersections are solid ink. Godot's
## triangulation cannot, so such strokes are drawn as the union of their pressure circles and the
## quads between them, which is the same envelope.
func _draw_capsules(target: CanvasItem, stroke: Dictionary) -> void:
	var centers: PackedVector2Array = stroke.centers
	var radii: PackedFloat32Array = stroke.radii
	var color: Color = stroke.get("color", DEFAULT_INK)
	var live := stroke == active
	for i in range(centers.size()):
		var c := _curve(centers[i])
		# The live stroke skips antialiased circles; it is re-rasterised properly once finished.
		target.draw_circle(c, radii[i], color, true, -1.0, not live)
		if i + 1 < centers.size():
			var n := _curve(centers[i + 1])
			var dir := n - c
			if dir.length() < radii[i] * 0.5:
				continue
			var perp := Vector2(-dir.y, dir.x).normalized()
			target.draw_colored_polygon(
				PackedVector2Array(
					[
						c + perp * radii[i],
						n + perp * radii[i + 1],
						n - perp * radii[i + 1],
						c - perp * radii[i]
					]
				),
				color
			)


func set_ink_color(color: Color) -> void:
	ink_color = color
	if pencil != null:
		(pencil.material as ShaderMaterial).set_shader_parameter("pigment_color", ink_color)


func set_pen_style(width: float, opacity: float) -> void:
	stroke_width = width
	stroke_opacity = opacity


func qa_state() -> Dictionary:
	var strokes := _strokes_of(spread)
	var last_points: int = 0 if strokes.is_empty() else strokes.back().points.size()
	return {
		"spread": spread,
		"strokes": stroke_count(),
		"drawing": pen_down,
		"hovering": hovering,
		"last_stroke_points": last_points,
		"ink_color": ink_color.to_html(false),
		"cursor": "pigment-brush" if tool == "draw" else tool,
		"tool": tool,
		"can_undo": can_undo(),
		"can_redo": can_redo(),
		"last_stroke_color":
		(
			DEFAULT_INK.to_html(false)
			if strokes.is_empty()
			else Color(strokes.back().get("color", DEFAULT_INK)).to_html(false)
		),
		"accumulated_input": Input.use_accumulated_input
	}
