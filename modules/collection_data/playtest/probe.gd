extends Control
const Data = preload("res://modules/collection_data/interface.gd")
const HttpAdapter = preload("res://modules/collection_data/http_adapter.gd")
var output: VBoxContainer
var report := {"search": {}, "rendered_hashes": []}

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("e7e9ee")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	output = VBoxContainer.new()
	output.position = Vector2(32, 24)
	output.size = Vector2(1300, 840)
	output.add_theme_color_override("font_color", Color("17253b"))
	add_child(output)
	_label("RISD search connection — engineering probe", 30)
	_label("Collection controls and verified painting images are still in progress.", 22)
	var adapter := HttpAdapter.new()
	if OS.has_feature("web"):
		adapter.base_url = JavaScriptBridge.eval("new URL('./', window.location.href).href")
	add_child(adapter)
	var handle: Variant = Data.create({"search": adapter.dispatch}).value
	Data.search(handle, {"q": "Monet", "category": "Painting"}, _received)

func _label(value: String, font_size: int = 20) -> void:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("17253b"))
	output.add_child(label)

func _received(result: Dictionary) -> void:
	report.search = result
	if not result.ok:
		_label(result.error.detail)
	else:
		_label(result.value.corpus.coverage, 18)
		_label("Upstream: " + result.value.corpus.upstream_status + " • " + result.value.corpus.fetched_at, 18)
		for artwork in result.value.items:
			_label("\n" + artwork.title, 24)
			_label(", ".join(artwork.makers) + " • " + str(artwork.year_from) + " • " + artwork.accession)
			_label(artwork.materials + " • " + artwork.category)
			_label(artwork.credit, 16)
			if artwork.image == null:
				_label("Image not yet verified — no substitute image shown", 16)
	await get_tree().process_frame
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.risdSearchProbe = " + JSON.stringify(report))
	else:
		var file := FileAccess.open("/tmp/risd-search78/native-report.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(report, "\t"))
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png("/tmp/risd-search78/native.png")
		get_tree().quit()
