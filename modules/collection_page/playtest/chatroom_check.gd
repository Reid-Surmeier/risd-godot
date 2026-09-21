extends SceneTree

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, label: String) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1


func _run() -> void:
	var result: Dictionary = load("res://modules/collection_page/interface.gd").global_chatroom()
	_check(result.ok, "chatroom_constructs")
	var chat: Control = result.value
	root.add_child(chat)
	chat.size = Vector2(320, 150)
	await process_frame
	_check(chat.input.get_theme_stylebox("normal") is StyleBoxEmpty, "original_input_pixels_remain_visible")
	_check(chat.attach.text.is_empty() and chat.send.text.is_empty(), "original_chat_icons_remain_visible")
	_check(chat.body.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_NEVER, "original_blue_scrollbar_remains_visible")
	var first_message := chat.messages.get_child(0) as Label
	_check(first_message.get_theme_font_size("font_size") == 12, "original_message_size_is_preserved")
	_check(first_message.get_theme_color("font_color").is_equal_approx(Color("009740")), "original_speaker_color_is_preserved")
	chat.input.text = "hello RISD"
	chat.input.text_submitted.emit(chat.input.text)
	_check(chat.qa_state().text_posts == 1, "enter_posts_text")
	chat.input.text = "send button"
	chat.send.pressed.emit()
	_check(chat.qa_state().text_posts == 2, "button_posts_text")
	chat.input.text = "   "
	chat.send.pressed.emit()
	_check(chat.qa_state().text_posts == 2, "empty_text_is_rejected")
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color("4b78d1"))
	chat._post_image_bytes(image.save_png_to_buffer(), "image/png")
	_check(chat.qa_state().image_posts == 1, "png_posts_thumbnail")
	chat._post_image_bytes(PackedByteArray([1, 2, 3]), "image/gif")
	_check(chat.qa_state().image_posts == 1, "unsupported_image_is_rejected")
	var oversized := PackedByteArray()
	oversized.resize(chat.MAX_IMAGE_BYTES + 1)
	chat._post_image_bytes(oversized, "image/png")
	_check(chat.qa_state().image_posts == 1, "oversized_image_is_rejected")
	chat.queue_free()
	print("global chatroom: " + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
