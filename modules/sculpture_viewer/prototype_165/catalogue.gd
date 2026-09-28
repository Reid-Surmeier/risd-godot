## THROWAWAY #165: three square catalogue arrangements. F1/F2/F3 switch variants.
## Question: where should a truthful 5x4 inventory, selection detail and hover enlargement live?
extends Control

const PANEL := preload("res://modules/sculpture_viewer/assets/setup/panel-2x.png")
const SCANS := [
	preload("res://modules/sculpture_viewer/prototype_165/scans/20260811121459-front.png"),
	preload("res://modules/sculpture_viewer/prototype_165/scans/20260811122415-front.png"),
	preload("res://modules/sculpture_viewer/prototype_165/scans/20260811123051-front.png"),
	preload("res://modules/sculpture_viewer/prototype_165/scans/20260820133334-front.png"),
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

var variant := 0
var selected := 0
var hovered := -1
var tick := 0.0
var turn_frames: Dictionary = {}


func _ready() -> void:
	size = Vector2(1080, 1080)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for cell in TURN:
		var path: String = "res://modules/sculpture_viewer/assets/setup/turn/%s.png" % TURN[cell][0]
		turn_frames[cell] = load(path)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if hovered >= 4 and CELLS[hovered - 4] in turn_frames:
		tick += delta
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_F1 and event.keycode <= KEY_F3:
			variant = event.keycode - KEY_F1
			hovered = -1
			queue_redraw()
			get_viewport().set_input_as_handled()
	if event is InputEventMouseMotion:
		var over := _hit(event.position)
		if over != hovered:
			hovered = over
			tick = 0.0
			queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit := _hit(event.position)
		if hit >= 0:
			selected = hit
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif event.position.y >= 1023.0:
			variant = mini(2, int(event.position.x / 360.0))
			hovered = -1
			queue_redraw()


func _hit(point: Vector2) -> int:
	for i in range(20):
		if _card_rect(i).has_point(point):
			return i
	return -1


func _card_rect(i: int) -> Rect2:
	var col := i % 4
	var row := i / 4
	match variant:
		0: return Rect2(42 + col * 145, 184 + row * 137, 136, 128)
		1: return Rect2(44 + col * 249, 178 + row * 125, 238, 115)
		_: return Rect2(468 + col * 143, 184 + row * 137, 134, 128)


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
	_draw_variant_bar()


func _draw_card(i: int) -> void:
	var box := _card_rect(i)
	var active := i == selected
	draw_rect(box, Color("#f6f5f7"))
	draw_rect(box, PINK if active else LINE, false, 2 if active else 1)
	var art := Rect2(box.position + Vector2(5, 5), Vector2(box.size.x - 10, box.size.y - 36))
	if variant == 1:
		art.size = Vector2(104, 104)
	elif art.size.x > art.size.y:
		art.position.x += (art.size.x - art.size.y) / 2.0
		art.size.x = art.size.y
	if i < 4:
		draw_texture_rect(SCANS[i], art, false)
	else:
		var cell: int = CELLS[i - 4] - 1
		var source := Rect2(CELL_X[cell % 8], CELL_Y[cell / 8], 216, 200)
		draw_texture_rect_region(PANEL, art, source)
	var label := "SCAN %02d" % (i + 1) if i < 4 else "OBJECT %02d" % (i + 1)
	if variant == 1:
		_text(box.position + Vector2(115, 31), label, 13, PINK if i < 4 else MUTED)
		var caption: String = APPEARANCE[i]
		if i == 6: caption = "Animal vessel"
		if i == 19: caption = "Blue turtle form"
		_text(box.position + Vector2(115, 60), caption, 12, INK)
		_text(box.position + Vector2(115, 89), "SOURCE" if i < 4 else "IMAGE ONLY", 11, MUTED)
	else:
		_text(box.position + Vector2(6, box.size.y - 11), label, 12, PINK if i < 4 else MUTED)


func _draw_detail() -> void:
	var box: Rect2
	match variant:
		0: box = Rect2(647, 184, 390, 685)
		1: box = Rect2(363, 825, 674, 177)
		_: box = Rect2(42, 184, 385, 490)
	draw_rect(box, Color("#faf9fa"))
	draw_rect(box, LINE, false, 1)
	var x := box.position.x + 20
	var y := box.position.y + 30
	_text(Vector2(x, y), "SELECTED OBJECT", 14, PINK)
	_text(Vector2(x, y + 38), APPEARANCE[selected], 21, INK)
	_text(Vector2(x, y + 68), _name(selected) + " · provisional label", 13, MUTED)
	if variant == 1:
		_text(Vector2(x + 335, y + 38), "Department: unverified", 15, INK)
		_text(Vector2(x + 335, y + 72), "3D preview unavailable" if selected < 4 else "No linked 3D scan", 15, PINK)
		_draw_project(Rect2(44, 825, 296, 177))
	else:
		_text(Vector2(x, y + 106), "Department: unverified", 15, INK)
		_text(Vector2(x, y + 137), "Source scan: present" if selected < 4 else "Image-only catalogue entry", 15, INK)
		_text(Vector2(x, y + 164), "3D preview unavailable" if selected < 4 else "No linked 3D scan", 16, PINK)
		if variant == 0:
			_draw_selected_art(Rect2(x, y + 188, box.size.x - 40, 213))
			_draw_project(Rect2(box.position.x + 15, box.end.y - 217, box.size.x - 30, 200))
		else:
			_draw_project(Rect2(box.position.x + 15, box.position.y + 216, box.size.x - 30, 251))


func _draw_selected_art(box: Rect2) -> void:
	draw_rect(box, Color.WHITE)
	draw_rect(box, LINE, false, 1)
	var art := Rect2(box.position + Vector2((box.size.x - 186) / 2.0, 5), Vector2(186, 178))
	if selected < 4:
		draw_texture_rect(SCANS[selected], art, false)
	else:
		var cell: int = CELLS[selected - 4] - 1
		draw_texture_rect_region(PANEL, art, Rect2(CELL_X[cell % 8], CELL_Y[cell / 8], 216, 200))
	_text(box.position + Vector2(10, 201), "2D SOURCE THUMBNAIL · NOT LIVE 3D", 12, MUTED)


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
	var box := Rect2(44, 691 if variant != 1 else 777, 299, 307 if variant != 1 else 225)
	draw_rect(box, Color.WHITE)
	draw_rect(box, PINK, false, 2)
	_text(box.position + Vector2(12, 25), "ENLARGED PREVIEW", 14, PINK)
	var art := Rect2(box.position + Vector2(12, 36), Vector2(box.size.x - 24, box.size.y - 91))
	var aspect := 1.0 if hovered < 4 else 216.0 / 200.0
	var fitted := Vector2(minf(art.size.x, art.size.y * aspect), art.size.y)
	fitted.y = fitted.x / aspect
	art.position += (art.size - fitted) / 2.0
	art.size = fitted
	if hovered < 4:
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


func _draw_variant_bar() -> void:
	draw_rect(Rect2(0, 1022, 1080, 58), Color("#343139"))
	for i in range(3):
		var box := Rect2(i * 360 + 8, 1029, 344, 43)
		draw_rect(box, PINK if i == variant else Color("#5f5863"))
		_text(box.position + Vector2(24, 28), ["F1  A / split catalogue", "F2  B / gallery-first", "F3  C / mirrored split"][i], 15, Color.WHITE)


func _name(i: int) -> String:
	return "Scan %s" % IDS[i] if i < 4 else "Panel cell %02d" % CELLS[i - 4]


func _text(at: Vector2, message: String, px: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, message, HORIZONTAL_ALIGNMENT_LEFT, -1, px, color)


func state() -> Dictionary:
	return {"variant": variant, "selected": selected, "hovered": hovered,
		"selected_id": IDS[selected] if selected < 4 else "panel-cell:%02d" % CELLS[selected - 4],
		"3d_preview_available": false}
