## Retained setup sidebar with live scan selection (#157 owner correction).
extends Control

signal selection_changed(id: String)
signal hover_changed(id: String)

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
# Exact photo-to-record comparisons: research checkpoints ae5e3bbe and 39a10662, issue #169.
# These are museum-record summaries, not assertions about scan licensing or mesh quality.
const RECORDS := {
	"20260811121459": {
		"title": "Love Triumphs over Death (Cupid and Skulls)",
		"accession": "73.148",
		"description": "Terracotta sculpture by Gustave Doré, made around 1876–1880; gift of Uforia, Inc.",
		"url": "https://risdmuseum.org/art-design/collection/love-triumphs-over-death-cupid-and-skulls-73148",
	},
	"20260820133334": {
		"title": "Portrait of Hadrian",
		"accession": "59.050",
		"description": "Roman marble portrait head, made around 130 CE for insertion into a separate bust. Its damaged portions remain unrestored.",
		"url": "https://risdmuseum.org/art-design/collection/portrait-hadrian-59050",
	},
	"panel-cell:11": {
		"title": "Aphrodite",
		"accession": "26.117",
		"description": "Greek bronze figure of Aphrodite, dated 199–100 BCE.",
		"url": "https://risdmuseum.org/sites/default/files/museumplus/312237.pdf#page=37",
	},
	"panel-cell:17": {
		"title": "Aphrodite",
		"accession": "06.331",
		"description": "Terracotta figure of Aphrodite with gilding, dated 300–200 BCE.",
		"url": "https://risdmuseum.org/sites/default/files/museumplus/312237.pdf#page=3",
	},
}

var selected := 0
var hovered := -1
var tick := 0.0
var turn_frames: Dictionary = {}
var detail_labels: Dictionary = {}


func _ready() -> void:
	size = Vector2(1050, 1680)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_exited.connect(func() -> void:
		hovered = -1
		tick = 0.0
		hover_changed.emit("")
		queue_redraw())
	for cell in TURN:
		var path: String = "res://modules/sculpture_viewer/assets/setup/turn/%s.png" % TURN[cell][0]
		turn_frames[cell] = load(path)
	set_process(true)
	_build_details()
	_update_details()
	queue_redraw()


func _process(delta: float) -> void:
	if hovered >= 4 and CELLS[hovered - 4] in turn_frames:
		tick += delta
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var over := _hit(event.position)
		if over != hovered:
			hovered = over
			hover_changed.emit(IDS[over] if over >= 0 and over < 4 else "")
			tick = 0.0
			queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit := _hit(event.position)
		if hit >= 0:
			selected = hit
			selection_changed.emit(IDS[hit] if hit < 4 else "")
			_update_details()
			queue_redraw()
			get_viewport().set_input_as_handled()



func _hit(point: Vector2) -> int:
	for i in range(20):
		if _card_rect(i).has_point(point):
			return i
	return -1


func _card_rect(i: int) -> Rect2:
	return Rect2(40 + (i % 4) * 247, 185 + (i / 4) * 183, 218, 165)


func _draw() -> void:
	# Keep the original RISD header, window ground and chat; replace only objects and form.
	draw_rect(Rect2(20, 180, 1010, 1134), Color.WHITE)
	for i in range(20):
		_draw_card(i)
	_draw_detail()
	if hovered >= 0:
		_draw_hover()


func _draw_card(i: int) -> void:
	var box := _card_rect(i)
	var active := i == selected
	draw_rect(box, Color.WHITE)
	if active:
		draw_rect(box, LINE, false, 1)
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
	var label: String = APPEARANCE[i]
	_text(box.position + Vector2(6, box.size.y - 11), label, 12, PINK if i < 4 else MUTED)


func _draw_detail() -> void:
	draw_line(Vector2(40, 1100), Vector2(1010, 1100), LINE, 1)


func _build_details() -> void:
	_detail_label("Title", 1108, 28, 21, INK)
	_detail_label("Identity", 1138, 22, 15, MUTED)
	_detail_label("Department", 1162, 22, 15, INK)
	_detail_label("LocalSource", 1186, 22, 13, MUTED)
	_detail_label("Status", 1210, 22, 16, PINK)
	_detail_label("Description", 1234, 36, 15, INK)
	_detail_label("Source", 1272, 40, 12, MUTED)


func _detail_label(key: String, y: float, height: float, px: int, color: Color) -> void:
	var label := Label.new()
	label.name = "Detail" + key
	label.position = Vector2(40, y)
	label.size = Vector2(970, height)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", px)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	detail_labels[key] = label


func _update_details() -> void:
	var id: String = IDS[selected] if selected < 4 else "panel-cell:%02d" % CELLS[selected - 4]
	var record: Dictionary = RECORDS.get(id, {})
	detail_labels.Title.text = record.get("title", APPEARANCE[selected])
	detail_labels.Identity.text = "Museum title verified · " + record.accession if not record.is_empty() else "Visual descriptor · museum title unknown"
	detail_labels.Department.text = "Department: unknown"
	detail_labels.LocalSource.text = _name(selected)
	detail_labels.Status.text = "3D scan available" if selected < 4 else "No linked 3D scan · image only"
	detail_labels.Description.text = record.get("description", "Museum description unknown. This %s has not yet been matched to a museum record." % ("scan thumbnail" if selected < 4 else "image-only entry"))
	detail_labels.Source.text = "Source: RISD Museum record (summary)\n" + record.url if not record.is_empty() else "Museum source: unknown\nThe label above describes appearance only."


func _draw_hover() -> void:
	var box := Rect2(-1250, 1190, 600, 470)
	draw_rect(box, Color.WHITE)
	draw_rect(box, PINK, false, 2)
	_text(box.position + Vector2(12, 25), "ENLARGED PREVIEW", 14, PINK)
	_text(box.position + Vector2(12, 47), APPEARANCE[hovered], 13, INK)
	var art := Rect2(box.position + Vector2(12, 56), Vector2(box.size.x - 24, box.size.y - 111))
	var aspect := 1.0 if hovered < 4 else 216.0 / 200.0
	var fitted := Vector2(minf(art.size.x, art.size.y * aspect), art.size.y)
	fitted.y = fitted.x / aspect
	art.position += (art.size - fitted) / 2.0
	art.size = fitted
	if hovered < 4:
		_text(box.end - Vector2(box.size.x - 12, 16), "3D scan · rotating preview", 14, PINK)
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
		"3d_preview_available": selected < 4}
