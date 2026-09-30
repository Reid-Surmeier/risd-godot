extends Control
const Data = preload("res://modules/collection_data/interface.gd")
const HttpAdapter = preload("res://modules/collection_data/http_adapter.gd")
var output: VBoxContainer
var report := {"search": {}, "rendered_hashes": []}
var image_base_url := "http://127.0.0.1:8128/"
var pending_images := 0
var finished := false


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
	_label("Verified RISD painting images through the same-origin Collection route.", 22)
	var adapter := HttpAdapter.new()
	if OS.has_feature("web"):
		adapter.base_url = JavaScriptBridge.eval("new URL('./', window.location.href).href")
	image_base_url = adapter.base_url
	add_child(adapter)
	var storage: Variant = Data.storage_adapter().value
	var handle: Variant = (
		Data
		. create(
			{
				"search": adapter.dispatch,
				"load_saves": storage.load_saves,
				"save_if_absent": storage.save_if_absent,
				"now_ms": func() -> int: return 0
			}
		)
		. value
	)
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
		_label(
			(
				"Upstream: "
				+ result.value.corpus.upstream_status
				+ " • "
				+ result.value.corpus.fetched_at
			),
			18
		)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)
		output.add_child(row)
		var compact := get_viewport_rect().size.x < 900
		for artwork in result.value.items:
			var card := VBoxContainer.new()
			card.custom_minimum_size.x = 300 if compact else 620
			row.add_child(card)
			var texture := TextureRect.new()
			texture.custom_minimum_size = Vector2(300, 250) if compact else Vector2(620, 500)
			texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			card.add_child(texture)
			var title := Label.new()
			title.text = artwork.title + "\n" + ", ".join(artwork.makers) + " • " + artwork.dating
			title.add_theme_font_size_override("font_size", 14 if compact else 20)
			title.add_theme_color_override("font_color", Color("17253b"))
			card.add_child(title)
			if artwork.image != null:
				pending_images += 1
				_load_image(artwork.image, texture)
	_maybe_finish()


func _load_image(manifest: Dictionary, target: TextureRect) -> void:
	var request := HTTPRequest.new()
	request.timeout = 15.0
	request.body_size_limit = 20 * 1024 * 1024
	add_child(request)
	request.request_completed.connect(
		func(status: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			request.queue_free()
			if status == HTTPRequest.RESULT_SUCCESS and code == 200:
				var context := HashingContext.new()
				context.start(HashingContext.HASH_SHA256)
				context.update(body)
				var hash := context.finish().hex_encode()
				var decoded := Image.new()
				if hash == manifest.sha256 and decoded.load_jpg_from_buffer(body) == OK:
					target.texture = ImageTexture.create_from_image(decoded)
					report.rendered_hashes.append(hash)
			pending_images -= 1
			_maybe_finish()
	)
	if request.request(image_base_url + "api/collection/image/" + manifest.sha256) != OK:
		request.queue_free()
		pending_images -= 1
		_maybe_finish()


func _maybe_finish() -> void:
	if finished or pending_images > 0 or report.search.is_empty():
		return
	finished = true
	report.rendered_hashes.sort()
	await get_tree().process_frame
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.risdSearchProbe = " + JSON.stringify(report))
	else:
		DirAccess.make_dir_recursive_absolute("/tmp/risd-search78")
		var file := FileAccess.open("/tmp/risd-search78/native-report.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(report, "\t"))
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png("/tmp/risd-search78/native.png")
		get_tree().quit()
