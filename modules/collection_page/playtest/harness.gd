## Production Collection search playtest. It reaches the page through the Shell, uses real input
## events, deterministic asynchronous replies, and the same verified image route as Web.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Page := preload("res://modules/collection_page/interface.gd")
const Data := preload("res://modules/collection_data/interface.gd")
const Testing := preload("res://testing/interface.gd")

var server_pid := -1


func _search(shell: Control, label: String) -> Dictionary:
	var tenant: Dictionary = Shell.tenant_state(shell, "collection").value
	var s: Dictionary = tenant.search
	var controls := {}
	for key in s.controls:
		controls[key] = _rect(s.controls[key])
	var items := []
	for item in s.items:
		items.append({"id": item.id, "rect": _rect(item.rect), "has_texture": item.has_texture,
			"image_unavailable": item.image_unavailable})
	var response := {}
	if not s.response.is_empty():
		response = {"total": s.response.total, "page": s.response.page, "page_size": s.response.page_size,
			"query": s.response.query, "snapshot": s.response.corpus.snapshot, "coverage": s.response.corpus.coverage,
			"upstream_status": s.response.corpus.upstream_status}
	var windows := []
	for window in tenant.windows:
		windows.append({"name": window.name, "rect": _rect(window.rect), "order": window.order, "drag_height": window.drag_height})
	var entry := {"t_ms": _ms(), "event": "search", "label": label, "phase": s.phase, "draft": s.draft,
		"applied": s.applied, "last_successful": s.last_successful, "requests": s.requests,
		"completions": s.completions, "ignored_completions": s.ignored_completions, "response": response,
		"items": items, "selected": s.selected, "images_loaded": s.images_loaded, "image_failures": s.image_failures,
		"controls": controls, "sort_popup_visible": s.sort_popup.visible, "category_popup_visible": s.category_popup.visible,
		"focus_owner": s.focus_owner, "sort_items": s.sort_items, "category_items": s.category_items,
		"ticks": tenant.ticks, "inputs": tenant.inputs, "size": [tenant.size.x, tenant.size.y], "windows": windows}
	_log.append(entry)
	return entry


func _wait_phase(shell: Control, wanted: String, label: String, timeout_frames := 240) -> Dictionary:
	for i in timeout_frames:
		await process_frame
		var s: Dictionary = Shell.tenant_state(shell, "collection").value.search
		if s.phase == wanted:
			return _search(shell, label)
	_log.append({"t_ms": _ms(), "event": "timeout", "label": label, "wanted": wanted})
	return _search(shell, label)


func _type_text(control: LineEdit, value: String, what: String) -> void:
	await _click(control.get_global_rect().get_center(), "focus " + what)
	control.select_all()
	for character in value:
		for pressed in [true, false]:
			var event := InputEventKey.new()
			event.unicode = character.unicode_at(0)
			event.pressed = pressed
			Input.parse_input_event(event)
			await process_frame
	_log.append({"t_ms": _ms(), "event": "text", "what": what, "value": value})


func _drag(from: Vector2, by: Vector2, what: String) -> void:
	await _button(from, MOUSE_BUTTON_LEFT, true)
	var event := InputEventMouseMotion.new()
	event.position = from + by
	event.global_position = event.position
	event.relative = by
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(event)
	await process_frame
	await _button(from + by, MOUSE_BUTTON_LEFT, false)
	_log.append({"t_ms": _ms(), "event": "drag", "what": what, "by": [by.x, by.y]})


func _initialize() -> void:
	server_pid = OS.create_process("/usr/bin/env", ["RISD_SEARCH_PORT=8141", "node", "--experimental-strip-types",
		"modules/collection_data/server/server.ts"], false)
	await create_timer(0.5).timeout
	var adapter: Node = Testing.collection_page_search().value
	get_root().add_child(adapter)
	var image_adapter: Node = Data.http_adapter().value
	image_adapter.base_url = "http://127.0.0.1:8141/"
	get_root().add_child(image_adapter)
	var data: Variant = Data.create({"search": adapter.dispatch}).value
	var factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = image_adapter.fetch_image
		return Page.create(page_deps)
	var shell: Control = Shell.create({"collection": factory}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/collection-page-search")
	await create_timer(0.8).timeout
	await _wait_phase(shell, "results", "default-results")
	await create_timer(0.5).timeout
	var launch := _search(shell, "default-images")
	await _shot(out_dir, "01-default-results.png")

	var query: LineEdit = shell.find_child("Query", true, false)
	await _type_text(query, "雪", "IME Unicode commit")
	var typed := _search(shell, "unicode-draft-no-request")
	await _key(KEY_ESCAPE, "cancel Unicode draft")
	var canceled := _search(shell, "unicode-canceled")

	# Keyboard-only traversal and apply: Query → Sort → Category → Has Image → OK.
	await _type_text(query, "Monet", "A query")
	_search(shell, "A-typed")
	await _key(KEY_TAB, "focus Sort")
	_search(shell, "focus-sort")
	await _key(KEY_SPACE, "open Sort for Escape")
	_search(shell, "sort-popup-open")
	await _key(KEY_ESCAPE, "dismiss Sort popup")
	_search(shell, "sort-popup-dismissed")
	await _key(KEY_SPACE, "open Sort")
	await _key(KEY_DOWN, "choose second sort")
	await _key(KEY_ENTER, "close Sort")
	await _key(KEY_TAB, "focus Category")
	_search(shell, "focus-category")
	await _key(KEY_SPACE, "open Category")
	await _key(KEY_DOWN, "choose Painting")
	await _key(KEY_ENTER, "close Category")
	await _key(KEY_TAB, "focus Has Image")
	_search(shell, "focus-checkbox")
	await _key(KEY_SPACE, "toggle Has Image off")
	_search(shell, "checkbox-off")
	await _key(KEY_SPACE, "toggle Has Image on")
	await _key(KEY_TAB, "focus OK")
	_search(shell, "focus-ok")
	await _key(KEY_ENTER, "apply A")
	await _wait_phase(shell, "results", "A-success")
	await create_timer(0.4).timeout
	var a := _search(shell, "A-images")
	await _shot(out_dir, "02-filtered-paintings.png")

	# Failed B keeps A visible; Escape restores A's controls without another request.
	await _type_text(query, "fail", "B query")
	await _key(KEY_ENTER, "apply B")
	var failed := await _wait_phase(shell, "error", "B-failed")
	await _shot(out_dir, "03-unavailable-keeps-A.png")
	await _key(KEY_ESCAPE, "cancel B")
	await _frames(2)
	var restored := _search(shell, "B-canceled-restores-A")

	# A slow older request may finish after a newer request, but cannot replace it.
	await _type_text(query, "slow", "slow request")
	await _key(KEY_ENTER, "apply slow")
	await _type_text(query, "Monet", "newer request")
	await _key(KEY_ENTER, "apply newer")
	await _wait_phase(shell, "results", "newer-wins-first")
	await create_timer(1.0).timeout
	var stale := _search(shell, "older-reply-ignored")

	# Pagination consumes the applied query plus snapshot while an unsent draft remains in the field.
	query = shell.find_child("Query", true, false)
	var category: OptionButton = shell.find_child("Category", true, false)
	var has_image: CheckBox = shell.find_child("HasImage", true, false)
	category.select(0)
	has_image.button_pressed = false
	await _type_text(query, "pages", "paginated query")
	await _key(KEY_ENTER, "apply paginated query")
	await _wait_phase(shell, "results", "page-one")
	await _type_text(query, "unsent", "draft retained across pagination")
	var before_page := _search(shell, "page-one-with-draft")
	var next: Button = shell.find_child("Next", true, false)
	await _click(next.get_global_rect().get_center(), "next page")
	var page_two := await _wait_phase(shell, "results", "page-two")

	category.select(0)
	has_image.button_pressed = false
	await _type_text(query, "no-such-work", "empty query")
	await _key(KEY_ENTER, "apply empty query")
	var empty := await _wait_phase(shell, "results", "empty-results")
	await _shot(out_dir, "04-empty.png")

	await _type_text(query, "House", "missing image query")
	await _key(KEY_ENTER, "apply missing image query")
	var missing := await _wait_phase(shell, "results", "missing-image")
	await _shot(out_dir, "05-missing-image.png")

	await _type_text(query, "broken", "broken image query")
	await _key(KEY_ENTER, "apply broken image query")
	await _wait_phase(shell, "results", "broken-image-response")
	await create_timer(0.2).timeout
	var broken := _search(shell, "broken-image")
	await _shot(out_dir, "06-broken-image.png")

	await _type_text(query, "expire", "expired snapshot query")
	await _key(KEY_ENTER, "apply expired snapshot query")
	var expired := await _wait_phase(shell, "snapshot_expired", "snapshot-expired")
	await _shot(out_dir, "07-snapshot-expired.png")
	var retry: Button = shell.find_child("Retry", true, false)
	await _click(retry.get_global_rect().get_center(), "retry expired snapshot")
	var retried := await _wait_phase(shell, "results", "snapshot-retry")

	# Selection only changes presentation; it dispatches no request.
	category.select(0)
	has_image.button_pressed = false
	await _type_text(query, "Monet", "selection query")
	await _key(KEY_ENTER, "apply selection query")
	var selectable := await _wait_phase(shell, "results", "before-selection")
	var first_card: PanelContainer = shell.find_child("Card_" + selectable.items[0].id.trim_prefix("risd:"), true, false)
	first_card.grab_focus()
	_search(shell, "result-focused")
	await _key(KEY_ENTER, "keyboard-select first result")
	var selected := _search(shell, "selected")
	await _shot(out_dir, "08-selected.png")

	# One retained window drag and viewer resize protect the existing chrome behavior.
	var page: Control = shell.find_child("CollectionPage", true, false)
	var filters: Dictionary = selectable.windows.filter(func(w: Dictionary) -> bool: return w.name == "filters")[0]
	var from := page.get_global_transform() * Vector2(filters.rect.x + 60, filters.rect.y + minf(12, filters.drag_height / 2))
	await _drag(from, Vector2(24, 12), "move filters")
	var moved := _search(shell, "filters-moved")
	var viewer: Dictionary = moved.windows.filter(func(w: Dictionary) -> bool: return w.name == "viewer")[0]
	var corner := page.get_global_transform() * Vector2(viewer.rect.x + viewer.rect.w - 8, viewer.rect.y + viewer.rect.h - 8)
	await _drag(corner, Vector2(-80, -50), "resize viewer")
	var resized := _search(shell, "viewer-resized")

	# A reply that arrives while hidden is held until Collection is visible again.
	await _type_text(query, "slow", "hidden slow query")
	await _key(KEY_ENTER, "apply hidden slow query")
	var shell_state: Dictionary = Shell.state(shell).value
	await _click(_center(shell, shell_state.tabs[0].rect), "Map tab")
	await create_timer(0.45).timeout
	var hidden_before := _search(shell, "hidden-before-reply")
	await create_timer(0.75).timeout
	var hidden := _search(shell, "hidden-after-reply")
	await _click(_center(shell, shell_state.tabs[4].rect), "Collection tab")
	await create_timer(0.5).timeout
	var resumed := _search(shell, "resumed-applies-reply")

	get_root().size = Vector2i(720, 486)
	await _frames(8)
	var compact := _search(shell, "compact-720x486")
	await _shot(out_dir, "09-compact-720x486.png")

	_log.append({"t_ms": _ms(), "event": "fixture", "calls": adapter.calls, "server_pid": server_pid,
		"checkpoints": [launch.requests, typed.requests, canceled.requests, a.requests, failed.requests, restored.requests,
			stale.requests, before_page.requests, page_two.requests, empty.requests, missing.requests, broken.requests,
			expired.requests, retried.requests, selected.requests, moved.requests, resized.requests, hidden_before.requests,
			hidden.requests, resumed.requests, compact.requests]})
	if server_pid > 0:
		OS.kill(server_pid)
	_finish(out_dir)
