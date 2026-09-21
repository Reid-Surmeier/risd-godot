## Additional prototype checks; the existing frozen acceptance tests remain untouched.
extends "res://testing/harness_base.gd"
const Demo = preload("res://modules/playground_page/prototype/demo.gd")
var checks: Array = []

func check(name: String, passed: bool) -> void:
	checks.append({"name": name, "passed": passed})

func _initialize() -> void:
	var page: Control = Demo.create_page()
	var out := await _mount(page, Vector2i(1920, 1080), "/tmp/playground-proof")
	await _frames(10)
	await _shot(out, "01-desktop.png")
	var first: Control = page.saved_list.get_child(0)
	await _click(first.get_global_rect().get_center(), "select saved artwork")
	await _frames(3)
	var detail := page.find_child("ArtworkDetail", true, false) as Label
	check("click_saved_artwork_opens_correct_details", detail != null and "Prototype Vase 00" in detail.text)
	var query := page.find_child("SavedQuery", true, false) as LineEdit
	check("filter_is_editable_control", query != null)
	if query != null:
		await _click(query.get_global_rect().get_center(), "focus saved filter")
		for character in "Drawing":
			var ev := InputEventKey.new()
			ev.pressed = true
			ev.unicode = character.unicode_at(0)
			Input.parse_input_event(ev)
			await process_frame
		await _frames(3)
		var visible := 0
		for row in page.saved_list.get_children():
			if row.visible:
				visible += 1
		check("typing_filters_twelve_records_to_six", visible == 6)
		var clear: Control = page.find_child("ClearFilter", true, false)
		await _click(clear.get_global_rect().get_center(), "clear filter")
		await _frames(3)
		check("clear_restores_all_records", query.text == "" and page.saved_list.get_children().all(func(row): return row.visible))
	var scroll := page.find_child("SavedScroll", true, false) as ScrollContainer
	check("overflow_has_scroll_control", scroll != null)
	if scroll != null:
		for i in 12:
			await _button(scroll.get_global_rect().get_center(), MOUSE_BUTTON_WHEEL_DOWN, true)
			await _button(scroll.get_global_rect().get_center(), MOUSE_BUTTON_WHEEL_DOWN, false)
		check("wheel_reaches_overflow", scroll.scroll_vertical > 0)
	await _shot(out, "02-after-interactions.png")
	page.hide()
	page.show()
	await _frames(3)
	var counter := page.find_child("SavedQuery", true, false)
	if counter != null:
		check("refresh_does_not_double_count_old_rows", page.filter_count.text == "12 / 12 saved works")
	_log.append({"event": "checks", "checks": checks})
	print(JSON.stringify(checks))
	_finish(out)
	if checks.any(func(result): return not result.passed):
		quit(1)
