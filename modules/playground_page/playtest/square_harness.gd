## Issue #164 acceptance: exercise the square Tenant through its seam and real input.
extends "res://testing/harness_base.gd"

const Page := preload("res://modules/playground_page/interface.gd")
const Data := preload("res://modules/collection_data/interface.gd")


func _press_named(tenant: Control, target: String) -> void:
	var button: Control = tenant.find_child(target, true, false)
	assert(button != null, target)
	await _click(button.get_global_rect().get_center(), target)
	await _frames(3)


func _initialize() -> void:
	get_root().content_scale_size = Vector2i.ZERO
	get_root().mode = Window.MODE_WINDOWED
	var storage: Variant = Data.storage_adapter().value
	var unused := func(_query, _done): return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}}
	var handle: Variant = Data.create({"search": unused, "load_saves": storage.load_saves,
		"save_if_absent": storage.save_if_absent, "now_ms": func(): return 1000}).value
	var made := Page.create({"key": "playground", "collection_data": handle, "image_fetch": unused, "square_pages": true})
	assert(made.ok, str(made.error))
	var tenant: Control = made.value
	var output := await _mount(tenant, Vector2i(1080, 1080), "/tmp/playground-square-164")
	var state: Dictionary = Page.state(tenant).value
	assert(state.page == "explore" and state.results.size() == 12)
	var connections: Array = state.connections.duplicate()
	connections.sort()
	connections.reverse()
	assert(connections == state.connections)
	assert(not Page.show_page(tenant, "missing").ok)
	assert(Page.show_page(tenant, "missing").error.code == "playground_page.page_unknown")
	assert(Page.state(tenant).value.page == "explore")
	await _shot(output, "Explore.png")
	await _press_named(tenant, "Page_all")
	assert(Page.state(tenant).value.page == "all" and Page.state(tenant).value.results.size() == 37)
	await _shot(output, "All-Blocks.png")
	await _press_named(tenant, "Page_channels")
	assert(Page.state(tenant).value.page == "channels")
	await _shot(output, "Channels.png")
	await _press_named(tenant, "Channel_0")
	assert(Page.state(tenant).value.channel == "Public connections" and Page.state(tenant).value.results.size() == 12)
	await _press_named(tenant, "Page_search")
	assert(Page.state(tenant).value.page == "search" and Page.state(tenant).value.results.size() == 25)
	await _shot(output, "Search.png")
	var field: Control = tenant.find_child("SearchQuery", true, false)
	await _click(field.get_global_rect().get_center(), "search field")
	for character in "portrait":
		var event := InputEventKey.new()
		event.unicode = character.unicode_at(0)
		event.pressed = true
		Input.parse_input_event(event)
		await process_frame
	await _key(KEY_ENTER, "submit search")
	await _frames(3)
	state = Page.state(tenant).value
	assert(state.query == "portrait" and state.results.size() > 0 and state.results.size() < 25)
	await _shot(output, "Search-results.png")
	var saved_id: String = state.results[0]
	await _press_named(tenant, "Save_" + saved_id.replace(":", "_"))
	assert(saved_id in Page.state(tenant).value.saved_ids)
	var collection: Array = []
	Data.saved(handle, func(result): collection.append(result))
	assert(collection[0].ok and collection[0].value.items[0].artwork.id == saved_id)
	_log.append({"event": "acceptance", "result": "pass", "pages": 4,
		"checks": ["chronology", "unknown-page", "real navigation", "channels", "real search", "shared save"]})
	print("square Playground acceptance passed")
	_finish(output)
