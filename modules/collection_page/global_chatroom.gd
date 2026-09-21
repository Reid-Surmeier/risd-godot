extends TextureRect

const CHAT_ASSET := "res://modules/collection_page/assets/chat.png"
const FONT := preload("res://modules/collection_page/assets/PixelMplus12-Regular.ttf")
const MAX_IMAGE_BYTES := 8 * 1024 * 1024

var body := ScrollContainer.new()
var messages := VBoxContainer.new()
var input := LineEdit.new()
var attach := Button.new()
var send := Button.new()
var text_posts := 0
var image_posts := 0
var picker_requests := 0
var _web_callback: JavaScriptObject
var _web_callback_name := ""
var _web_picker_id := ""


func _ready() -> void:
	texture = load(CHAT_ASSET)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	body.name = "Messages"
	body.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	body.add_theme_stylebox_override("panel", _flat(Color.WHITE))
	add_child(body)
	messages.add_theme_constant_override("separation", 2)
	body.add_child(messages)
	for line in ["Sebas*: A Dürer print!", "SakumaRiri: The Large Horse?", "ANRI: At RISD? Nice!", "Show_A: Love the detail!"]:
		_add_text(line, false)
	input.name = "MessageInput"
	input.placeholder_text = "Message"
	input.add_theme_font_override("font", FONT)
	input.text_submitted.connect(func(_value): _post_text())
	add_child(input)
	attach.name = "AttachImage"
	attach.text = "+"
	attach.tooltip_text = "Post an image"
	attach.pressed.connect(_pick_image)
	add_child(attach)
	send.name = "SendMessage"
	send.text = "↑"
	send.tooltip_text = "Send message"
	send.pressed.connect(_post_text)
	add_child(send)
	if OS.has_feature("web"):
		_web_callback_name = "risdChatImage%d" % get_instance_id()
		_web_picker_id = "risd-chat-picker-%d" % get_instance_id()
		_web_callback = JavaScriptBridge.create_callback(_on_web_image)
		JavaScriptBridge.get_interface("window")[_web_callback_name] = _web_callback
		_setup_web_picker()
	visibility_changed.connect(_sync_web_picker)
	set_notify_transform(true)
	resized.connect(_layout)
	_layout()


func _exit_tree() -> void:
	if OS.has_feature("web") and not _web_callback_name.is_empty():
		JavaScriptBridge.eval("document.getElementById(%s)?.remove()" % JSON.stringify(_web_picker_id))
		JavaScriptBridge.get_interface("window")[_web_callback_name] = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		call_deferred("_sync_web_picker")


func _layout() -> void:
	body.position = Vector2(size.x * 0.018, size.y * 0.125)
	body.size = Vector2(size.x * 0.925, size.y * 0.68)
	messages.custom_minimum_size.x = maxf(0.0, body.size.x - 10.0)
	input.position = Vector2(size.x * 0.025, size.y * 0.845)
	input.size = Vector2(size.x * 0.785, size.y * 0.115)
	attach.position = Vector2(size.x * 0.815, size.y * 0.845)
	attach.size = Vector2(size.x * 0.07, size.y * 0.115)
	send.position = Vector2(size.x * 0.89, size.y * 0.845)
	send.size = Vector2(size.x * 0.075, size.y * 0.115)
	var font_size := maxi(8, roundi(size.x / 32.0))
	input.add_theme_font_size_override("font_size", font_size)
	for button in [attach, send]:
		button.add_theme_font_override("font", FONT)
		button.add_theme_font_size_override("font_size", font_size)
	call_deferred("_sync_web_picker")


func _post_text() -> void:
	var value := input.text.strip_edges()
	if value.is_empty():
		input.placeholder_text = "Type a message"
		return
	_add_text("You: " + value)
	text_posts += 1
	input.clear()
	input.placeholder_text = "Message"


func _add_text(value: String, scroll_to_end := true) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("17264f"))
	messages.add_child(label)
	if scroll_to_end:
		call_deferred("_scroll_bottom")


func _pick_image() -> void:
	picker_requests += 1
	if OS.has_feature("web"):
		JavaScriptBridge.eval("document.getElementById(%s)?.click()" % JSON.stringify(_web_picker_id))
		return
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp;Images;image/png,image/jpeg,image/webp"])
	dialog.file_selected.connect(_on_native_image)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.7)


func _setup_web_picker() -> void:
	var picker := JSON.stringify(_web_picker_id)
	var callback := JSON.stringify(_web_callback_name)
	JavaScriptBridge.eval("""(() => {
		const old = document.getElementById(%s);
		if (old) old.remove();
		const input = document.createElement('input');
		input.id = %s;
		input.type = 'file';
		input.accept = 'image/png,image/jpeg,image/webp';
		input.setAttribute('aria-label', 'Post an image');
		Object.assign(input.style, { position: 'fixed', opacity: '0', zIndex: '2147483647', cursor: 'pointer' });
		input.onchange = () => {
			const file = input.files && input.files[0];
			if (!file) return;
			if (file.size > %d) { window[%s]('', 'Image is over 8 MiB'); input.value = ''; return; }
			const reader = new FileReader();
			reader.onload = () => { window[%s](String(reader.result), ''); input.value = ''; };
			reader.onerror = () => { window[%s]('', 'Could not read image'); input.value = ''; };
			reader.readAsDataURL(file);
		};
		document.body.appendChild(input);
	})()""" % [picker, picker, MAX_IMAGE_BYTES, callback, callback, callback])
	call_deferred("_sync_web_picker")


func _sync_web_picker() -> void:
	if not OS.has_feature("web") or _web_picker_id.is_empty() or not is_inside_tree():
		return
	var rect: Rect2 = attach.get_global_transform() * Rect2(Vector2.ZERO, attach.size)
	var viewport_size := get_viewport_rect().size
	JavaScriptBridge.eval("""(() => {
		const input = document.getElementById(%s);
		const canvas = document.querySelector('canvas');
		if (!input || !canvas) return;
		const box = canvas.getBoundingClientRect();
		input.style.display = %s ? 'block' : 'none';
		input.style.left = `${box.left + %f / %f * box.width}px`;
		input.style.top = `${box.top + %f / %f * box.height}px`;
		input.style.width = `${%f / %f * box.width}px`;
		input.style.height = `${%f / %f * box.height}px`;
	})()""" % [JSON.stringify(_web_picker_id), "true" if is_visible_in_tree() else "false",
			rect.position.x, viewport_size.x, rect.position.y, viewport_size.y,
			rect.size.x, viewport_size.x, rect.size.y, viewport_size.y])


func _on_web_image(args: Array) -> void:
	var error := str(args[1]) if args.size() > 1 else ""
	if not error.is_empty():
		_reject(error)
		return
	var data_url := str(args[0]) if not args.is_empty() else ""
	var comma := data_url.find(",")
	var semicolon := data_url.find(";")
	if not data_url.begins_with("data:image/") or semicolon < 5 or comma <= semicolon:
		_reject("Unsupported image")
		return
	_post_image_bytes(Marshalls.base64_to_raw(data_url.substr(comma + 1)), data_url.substr(5, semicolon - 5))


func _on_native_image(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_IMAGE_BYTES:
		_reject("Image is over 8 MiB" if file != null else "Could not read image")
		return
	var mime: String = {"png": "image/png", "jpg": "image/jpeg", "jpeg": "image/jpeg", "webp": "image/webp"}.get(path.get_extension().to_lower(), "")
	_post_image_bytes(file.get_buffer(file.get_length()), mime)
	file.close()


func _post_image_bytes(bytes: PackedByteArray, mime: String) -> void:
	if bytes.is_empty() or bytes.size() > MAX_IMAGE_BYTES or mime not in ["image/png", "image/jpeg", "image/webp"]:
		_reject("Unsupported image")
		return
	var decoded := Image.new()
	var status := decoded.load_png_from_buffer(bytes) if mime == "image/png" else (decoded.load_jpg_from_buffer(bytes) if mime == "image/jpeg" else decoded.load_webp_from_buffer(bytes))
	if status != OK:
		_reject("Unsupported image")
		return
	var card := VBoxContainer.new()
	var label := Label.new()
	label.text = "You posted an image"
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("17264f"))
	card.add_child(label)
	var preview := TextureRect.new()
	preview.texture = ImageTexture.create_from_image(decoded)
	preview.custom_minimum_size = Vector2(96, 64)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(preview)
	messages.add_child(card)
	image_posts += 1
	input.placeholder_text = "Message"
	call_deferred("_scroll_bottom")


func _reject(reason: String) -> void:
	input.placeholder_text = reason


func _scroll_bottom() -> void:
	body.scroll_vertical = roundi(body.get_v_scroll_bar().max_value)


func qa_state() -> Dictionary:
	return {"text_posts": text_posts, "image_posts": image_posts, "message_count": messages.get_child_count(),
			"picker_requests": picker_requests,
			"input_rect": input.get_global_transform() * Rect2(Vector2.ZERO, input.size),
			"attach_rect": attach.get_global_transform() * Rect2(Vector2.ZERO, attach.size),
			"send_rect": send.get_global_transform() * Rect2(Vector2.ZERO, send.size)}


static func _flat(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	return style
