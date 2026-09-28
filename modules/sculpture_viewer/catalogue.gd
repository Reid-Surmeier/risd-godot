## Square catalogue selected in #165, integrated by #170.
extends Control

const PANEL := preload("res://modules/sculpture_viewer/assets/setup/panel-2x.png")
const SCANS := [
	preload("res://modules/sculpture_viewer/assets/scans/20260811121459-front.png"),
	preload("res://modules/sculpture_viewer/assets/scans/20260811122415-front.png"),
	preload("res://modules/sculpture_viewer/assets/scans/20260811123051-front.png"),
	preload("res://modules/sculpture_viewer/assets/scans/20260820133334-front.png"),
]
const IDS := ["20260811121459", "20260811122415", "20260811123051", "20260820133334"]
const CELLS := [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20, 21, 22]
const APPEARANCE := [
	"Group with skulls", "Sculptural relief", "Bearded bust", "Pale bust",
	"Decorated bowl", "Bull", "Animal-shaped vessel", "Curved object",
	"Colored bust", "Standing figure", "Guardian lion", "Small figure",
	"Rider", "Dancing figure", "Standing figure", "Terracotta figure",
	"Gold mask", "Blue carved form", "Bird", "Blue turtle-like form",
]
const CELL_X := [80, 330, 582, 836, 1062, 1300, 1522, 1776]
const CELL_Y := [410, 770, 1150]
const TURN := {
	6: ["06-bowl", 50], 7: ["07-bull", 24], 8: ["08-dog", 24],
	10: ["1557236", 73], 12: ["1552311", 73], 13: ["1532371", 73],
	14: ["1487831", 73], 15: ["1581601", 25], 16: ["1573591", 73],
	18: ["1554066", 73], 19: ["1548171", 73], 20: ["1264886", 25],
	21: ["1344456", 25],
}
const INK := Color("#36333c")
const MUTED := Color("#77727e")
const PINK := Color("#dc526b")
const LINE := Color("#c7c3cc")

var selected := 0
var hovered := -1
var tick := 0.0
var turn_frames: Dictionary = {}
var scan_viewport: SubViewport
var scan_camera: Camera3D
var scan_yaw := 180.0


func _ready() -> void:
	size = Vector2(1080, 1080)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for cell in TURN:
		var path: String = "res://modules/sculpture_viewer/assets/setup/turn/%s.png" % TURN[cell][0]
		turn_frames[cell] = load(path)
	_build_scan_preview()
	visibility_changed.connect(_scan_render_mode)
	_scan_render_mode()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if hovered >= 4 and CELLS[hovered - 4] in turn_frames:
		tick += delta
		queue_redraw()
	if hovered == 2 and scan_camera:
		scan_yaw = wrapf(scan_yaw + delta * 12.0, 0.0, 360.0)
		_update_scan_camera()
		queue_redraw()


func _build_scan_preview() -> void:
	# PROTOTYPE #157: only the independently preview-passing bearded scan is loaded.
	scan_viewport = SubViewport.new()
	scan_viewport.size = Vector2i(550, 392)
	scan_viewport.own_world_3d = true
	scan_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(scan_viewport)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#f8f8fa")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9e1e7")
	environment.ambient_light_energy = 0.82
	var world := WorldEnvironment.new()
	world.environment = environment
	scan_viewport.add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-42, -28, 0)
	key.light_energy = 1.15
	scan_viewport.add_child(key)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-3.5, 2.5, 4)
	fill.light_color = Color("#dcebf4")
	fill.light_energy = 0.52
	fill.omni_range = 10.0
	scan_viewport.add_child(fill)
	var packed := load("res://modules/sculpture_viewer/prototype_157/bearded-candidate.glb") as PackedScene
	if packed == null:
		push_error("Prototype bearded GLB could not be loaded")
		return
	var model := packed.instantiate()
	scan_viewport.add_child(model)
	_make_opaque(model)
	scan_camera = Camera3D.new()
	scan_camera.fov = 36.0
	scan_viewport.add_child(scan_camera)
	scan_camera.current = true
	_update_scan_camera()


func _make_opaque(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh := node as MeshInstance3D
		var original := mesh.get_active_material(0) as StandardMaterial3D
		if original and original.albedo_texture:
			var material := StandardMaterial3D.new()
			material.albedo_texture = original.albedo_texture
			material.roughness = 1.0
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
			mesh.material_override = material
	for child in node.get_children():
		_make_opaque(child)


func _update_scan_camera() -> void:
	var yaw := deg_to_rad(scan_yaw)
	var pitch := deg_to_rad(-8.0)
	var target := Vector3(0, 2.173, 0)
	scan_camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * 7.2
	scan_camera.look_at(target)


func _scan_render_mode() -> void:
	if scan_viewport:
		scan_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if hovered == 2 and is_visible_in_tree() else SubViewport.UPDATE_DISABLED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var over := _hit(make_canvas_position_local(event.position))
		if over != hovered:
			hovered = over
			tick = 0.0
			_scan_render_mode()
			queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit := _hit(make_canvas_position_local(event.position))
		if hit >= 0:
			selected = hit
			queue_redraw()
			get_viewport().set_input_as_handled()



func _hit(point: Vector2) -> int:
	for i in range(20):
		if _card_rect(i).has_point(point):
			return i
	return -1


func _card_rect(i: int) -> Rect2:
	return Rect2(468 + (i % 4) * 143, 184 + (i / 4) * 137, 134, 128)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)
	# Existing approved RISD setup lettering; no newly generated logo.
	draw_texture_rect_region(PANEL, Rect2(37, 22, 305, 88), Rect2(40, 35, 610, 175))
	_text(Vector2(675, 52), "3D VIEWER", 22, PINK)
	_text(Vector2(675, 79), "SCAN CATALOGUE  /  20 OBJECTS", 14, MUTED)
	draw_line(Vector2(42, 129), Vector2(1038, 129), LINE, 1)
	_text(Vector2(44, 159), "FOUR SCAN SOURCES · SIXTEEN IMAGE-ONLY ENTRIES", 14, INK)
	for i in range(20):
		_draw_card(i)
	_draw_detail()
	if hovered >= 0:
		_draw_hover()


func _draw_card(i: int) -> void:
	var box := _card_rect(i)
	var active := i == selected
	draw_rect(box, Color("#f6f5f7"))
	draw_rect(box, PINK if active else LINE, false, 2 if active else 1)
	var art := Rect2(box.position + Vector2(5, 5), Vector2(box.size.x - 10, box.size.y - 36))
	if art.size.x > art.size.y:
		art.position.x += (art.size.x - art.size.y) / 2.0
		art.size.x = art.size.y
	if i < 4:
		draw_texture_rect(SCANS[i], art, false)
	else:
		var cell: int = CELLS[i - 4] - 1
		var source := Rect2(CELL_X[cell % 8], CELL_Y[cell / 8], 216, 200)
		draw_texture_rect_region(PANEL, art, source)
	var label := "SCAN %02d" % (i + 1) if i < 4 else "OBJECT %02d" % (i + 1)
	_text(box.position + Vector2(6, box.size.y - 11), label, 12, PINK if i < 4 else MUTED)


func _draw_detail() -> void:
	# A hovered preview is the object currently being viewed; clicks retain selection after leave.
	var detail := hovered if hovered >= 0 else selected
	var box := Rect2(42, 184, 385, 490)
	draw_rect(box, Color("#faf9fa"))
	draw_rect(box, LINE, false, 1)
	var x := box.position.x + 20
	var y := box.position.y + 30
	_text(Vector2(x, y), "VIEWING OBJECT" if hovered >= 0 else "SELECTED OBJECT", 14, PINK)
	_text(Vector2(x, y + 38), APPEARANCE[detail], 21, INK)
	_text(Vector2(x, y + 68), _name(detail) + " · provisional label", 13, MUTED)
	_text(Vector2(x, y + 106), "Department: unverified", 15, INK)
	_text(Vector2(x, y + 137), "Source scan: present" if detail < 4 else "Image-only catalogue entry", 15, INK)
	var preview_status := "Live 3D hover trial · not accepted" if detail == 2 else "3D preview unavailable" if detail < 4 else "No linked 3D scan"
	_text(Vector2(x, y + 164), preview_status, 16, PINK)
	_draw_project(Rect2(box.position.x + 15, box.position.y + 216, box.size.x - 30, 251))


func _draw_project(box: Rect2) -> void:
	draw_rect(box, Color.WHITE)
	draw_rect(box, LINE, false, 1)
	_text(box.position + Vector2(12, 25), "ABOUT THE SCANNING PROJECT", 14, PINK)
	var lines := [
		"Lorem ipsum dolor sit amet, consectetur",
		"adipiscing elit. Integer nec odio.",
		"Praesent libero, sed cursus ante",
		"dapibus diam. Sed nisi. Nulla quis sem."
	]
	for n in range(lines.size()):
		_text(box.position + Vector2(12, 55 + n * 25), lines[n], 13, INK)


func _draw_hover() -> void:
	var box := Rect2(44, 691, 299, 307)
	draw_rect(box, Color.WHITE)
	draw_rect(box, PINK, false, 2)
	_text(box.position + Vector2(12, 25), "ENLARGED PREVIEW", 14, PINK)
	_text(box.position + Vector2(12, 47), APPEARANCE[hovered], 13, INK)
	var art := Rect2(box.position + Vector2(12, 56), Vector2(box.size.x - 24, box.size.y - 87))
	var aspect := 1.0 if hovered < 4 else 216.0 / 200.0
	var fitted := Vector2(minf(art.size.x, art.size.y * aspect), art.size.y)
	fitted.y = fitted.x / aspect
	art.position += (art.size - fitted) / 2.0
	art.size = fitted
	if hovered < 4:
		if hovered == 2 and scan_camera:
			draw_texture_rect(scan_viewport.get_texture(), art, false)
			_text(box.end - Vector2(box.size.x - 12, 16), "LIVE 3D · source scan trial", 13, PINK)
		else:
			draw_texture_rect(SCANS[hovered], art, false)
			_text(box.end - Vector2(box.size.x - 12, 16), "3D preview unavailable", 14, PINK)
	else:
		var cell: int = CELLS[hovered - 4]
		if cell in turn_frames:
			var frame: int = int(tick * 12.0) % TURN[cell][1]
			var source := Rect2((frame % 8) * 216, (frame / 8) * 200, 216, 200)
			draw_texture_rect_region(turn_frames[cell], art, source)
			_text(box.end - Vector2(box.size.x - 12, 16), "Animated thumbnail · no linked scan", 12, MUTED)
		else:
			var index := cell - 1
			draw_texture_rect_region(PANEL, art, Rect2(CELL_X[index % 8], CELL_Y[index / 8], 216, 200))
			_text(box.end - Vector2(box.size.x - 12, 16), "Image-only preview", 13, MUTED)


func _name(i: int) -> String:
	return "Scan %s" % IDS[i] if i < 4 else "Panel cell %02d" % CELLS[i - 4]


func _text(at: Vector2, message: String, px: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, message, HORIZONTAL_ALIGNMENT_LEFT, -1, px, color)


func catalogue_state() -> Dictionary:
	return {"selected": selected, "hovered": hovered,
		"selected_id": IDS[selected] if selected < 4 else "panel-cell:%02d" % CELLS[selected - 4],
		"3d_preview_available": false}
