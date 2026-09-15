## Real-input playtest for issue #75's isolated Collection controls prototype.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Prototype := preload("res://prototypes/collection_search_controls/prototype.gd")


func _state(shell: Control, label: String) -> Dictionary:
	var value: Dictionary = Shell.tenant_state(shell, "collection").value
	var entry := {"t_ms": _ms(), "event": "state", "label": label}
	entry.merge(value)
	_log.append(entry)
	return entry


func _control(state: Dictionary, name: String) -> Rect2:
	var r: Array = state.controls[name]
	return Rect2(r[0], r[1], r[2], r[3])


func _popup_item(popup: Dictionary, index: int, count: int) -> Vector2:
	return Vector2(popup.position[0] + popup.size[0] / 2.0, popup.position[1] + popup.size[1] * (index + 0.5) / count)


func _type(text: String) -> void:
	for character in text:
		for pressed in [true, false]:
			var event := InputEventKey.new()
			event.pressed = pressed
			event.unicode = character.unicode_at(0)
			Input.parse_input_event(event)
			await process_frame
	_log.append({"t_ms": _ms(), "event": "type", "text": text})


func _select_all() -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.pressed = pressed
		event.keycode = KEY_A
		event.ctrl_pressed = true
		Input.parse_input_event(event)
		await process_frame
	_log.append({"t_ms": _ms(), "event": "key", "what": "select all", "keycode": "Ctrl+A"})


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"collection": Prototype}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/collection-search-controls")
	await create_timer(1.0).timeout
	var launch := _state(shell, "launch-results")
	await _shot(out_dir, "01-after-1920x1080.png")

	# Real pointer opens the native sort popup; keyboard chooses a different value while it owns focus.
	await _click(_control(launch, "Sort").get_center(), "sort dropdown")
	await _frames(2)
	_state(shell, "sort-popup-open")
	await _shot(out_dir, "02-sort-popup.png")
	await _click(_popup_item(_state(shell, "sort-popup-pointer-target").sort_popup, 1, 3), "Date new-to-old")
	var sorted := _state(shell, "sort-changed")
	await _click(_control(sorted, "Category").get_center(), "category dropdown")
	var category_popup := _state(shell, "category-popup-open")
	await _click(_popup_item(category_popup.category_popup, 1, 3), "Painting category")
	var categorized := _state(shell, "category-changed")
	await _click(_control(categorized, "HasImage").get_center(), "Has Image checkbox")
	var toggled := _state(shell, "checkbox-changed")
	await _click(_control(toggled, "Query").get_center(), "query field")
	await _type("Monet 42")
	_state(shell, "alphabet-numerals-caret")
	await _shot(out_dir, "02b-controls-draft.png")
	await _key(KEY_ESCAPE, "restore all draft controls")
	_state(shell, "all-controls-restored")

	# Real click focuses the LineEdit, real character events type a draft; Escape restores applied state.
	await _click(_control(launch, "Query").get_center(), "query field")
	await _type("none")
	var draft := _state(shell, "draft-none")
	await _key(KEY_ESCAPE, "cancel draft")
	_state(shell, "escape-restored-applied")

	# Apply with Enter. The old result count remains during loading, then the empty state settles.
	await _click(_control(launch, "Query").get_center(), "query field")
	await _type("none")
	await _key(KEY_ENTER, "apply with Enter")
	_state(shell, "loading-keeps-prior-count")
	await _shot(out_dir, "03-loading.png")
	await create_timer(0.45).timeout
	_state(shell, "empty-results")
	await _shot(out_dir, "04-empty.png")

	# Select all text with keyboard, type fail and use the pointer OK button; inspect failure and retry.
	await _click(_control(launch, "Query").get_center(), "query field")
	await _select_all()
	await _type("fail")
	var before_fail := _state(shell, "draft-fail")
	await _click(_control(before_fail, "OK").get_center(), "OK")
	await create_timer(0.45).timeout
	var failed := _state(shell, "failed-search")
	await _shot(out_dir, "05-error-retry.png")
	await _click(_control(failed, "Retry").get_center(), "Retry")
	await create_timer(0.45).timeout
	_state(shell, "retry-failed-fixture")

	# Cancel button restores the applied failure query after typing a different draft.
	await _click(_control(failed, "Query").get_center(), "query field")
	await _select_all()
	await _type("monet")
	var changed := _state(shell, "draft-monet")
	await _click(_control(changed, "Cancel").get_center(), "Cancel")
	_state(shell, "cancel-restored-fail")

	# Resize to the second target and restore the success fixture through real input.
	root.size = Vector2i(1440, 900)
	await _frames(5)
	var small := _state(shell, "resized-1440x900")
	await _click(_control(small, "Query").get_center(), "query field")
	await _select_all()
	await _type("monet")
	await _key(KEY_ENTER, "apply monet")
	await create_timer(0.45).timeout
	var monet := _state(shell, "monet-results-1440x900")
	await _shot(out_dir, "06-after-1440x900.png")

	# Pointer-select the first card, then exercise Save and Save-error presentations.
	var prototype: Control = shell.find_child("CollectionSearchPrototype", true, false)
	var card: Control = prototype.find_child("Card0", true, false)
	await _click(card.get_global_rect().get_center(), "first artwork")
	await _frames(2)
	var selected := _state(shell, "selected-details")
	await _shot(out_dir, "07-selected-details.png")
	var save: Control = prototype.find_child("Save", true, false)
	await _click(save.get_global_rect().get_center(), "Save")
	_state(shell, "saved-presentation")
	var save_error: Control = prototype.find_child("SaveError", true, false)
	await _click(save_error.get_global_rect().get_center(), "Preview save error")
	_state(shell, "save-error-presentation")
	await _shot(out_dir, "08-save-error.png")
	_log.append({"t_ms": _ms(), "event": "assertion_inputs", "draft_none": draft.draft.query,
		"draft_fail": before_fail.draft.query, "draft_monet": changed.draft.query, "small_count": monet.visible_count,
		"layout_reference_sha256": monet.layout_reference_sha256})
	_finish(out_dir)
