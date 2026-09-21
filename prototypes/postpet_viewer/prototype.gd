## PostPet setup shell with the sculpture thumbnail row feeding the real viewer module.
extends Control

const CANVAS := Vector2(1782, 1182)
const ROOT := "res://prototypes/postpet_viewer/assets/components/"
const THUMBNAILS := [
	"bust.png", "horse.png", "sphinx.png", "dark-sculpture.png",
	"nude.png", "bust-profile.png", "lion-native-cutout.png",
]

var canvas := Control.new()
var viewer_host: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.size = CANVAS
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	var paper := ColorRect.new()
	paper.size = CANVAS
	paper.color = Color.WHITE
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(paper)
	_build_postpet_panel()
	_build_viewer()
	resized.connect(_fit)
	_fit()

func _build_postpet_panel() -> void:
	var panel := Panel.new()
	panel.name = "postpet-setup"
	panel.position = Vector2(20, 28)
	panel.size = Vector2(690, 930)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(panel)
	var header := TextureRect.new()
	header.texture = load("res://prototypes/postpet_viewer/assets/postpet-header.png")
	header.position = Vector2(20, 18)
	header.size = Vector2(624, 80)
	header.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	header.stretch_mode = TextureRect.STRETCH_SCALE
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(header)
	var rule := HSeparator.new()
	rule.position = Vector2(20, 105)
	rule.size = Vector2(640, 2)
	panel.add_child(rule)
	var row := HBoxContainer.new()
	row.name = "sculpture-pet-row"
	row.position = Vector2(20, 120)
	row.size = Vector2(650, 150)
	row.add_theme_constant_override("separation", 5)
	panel.add_child(row)
	for index in THUMBNAILS.size():
		var button := Button.new()
		button.name = "sculpture-%02d" % index
		button.custom_minimum_size = Vector2(88, 140)
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = "Open sculpture %02d" % (index + 1)
		var thumb := TextureRect.new()
		var path := ROOT + THUMBNAILS[index]
		if index == THUMBNAILS.size() - 1:
			path = "res://prototypes/postpet_viewer/assets/lion-native-cutout.png"
		thumb.texture = load(path)
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		thumb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(thumb)
		button.pressed.connect(func(): _select_sculpture(index))
		row.add_child(button)
	var info := Label.new()
	info.text = "Replace the thumbnails above with additional scan passes.\nClick a sculpture to load it into the viewer."
	info.position = Vector2(28, 300)
	info.add_theme_font_size_override("font_size", 18)
	panel.add_child(info)
	_add_form(panel)

func _add_form(panel: Panel) -> void:
	var form := VBoxContainer.new()
	form.position = Vector2(28, 390)
	form.size = Vector2(620, 360)
	form.add_theme_constant_override("separation", 18)
	panel.add_child(form)
	for label_text in ["ペットのなまえ:   モモ", "飼い主の名前:   ママ", "飼い主の誕生日:   ____ 月  ____ 日"]:
		var label := Label.new()
		label.text = label_text
		label.add_theme_font_size_override("font_size", 22)
		form.add_child(label)
	var note := Label.new()
	note.text = "※ 誕生日は半角数字で入力してください。"
	note.modulate = Color("#ef4b55")
	note.add_theme_font_size_override("font_size", 18)
	form.add_child(note)

func _build_viewer() -> void:
	viewer_host = load("res://modules/sculpture_viewer/viewer.gd").new()
	viewer_host.name = "sculpture-viewer"
	viewer_host.position = Vector2(850, 245)
	viewer_host.size = Vector2(800, 680)
	canvas.add_child(viewer_host)

func _select_sculpture(index: int) -> void:
	# The existing viewer seam owns orbit/navigation; this hook is the replacement point for each scan.
	viewer_host.set_meta("selected_sculpture", index)

func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var scale_factor := minf(size.x / CANVAS.x, size.y / CANVAS.y)
	canvas.scale = Vector2(scale_factor, scale_factor)
	canvas.position = (size - CANVAS * scale_factor) * 0.5
