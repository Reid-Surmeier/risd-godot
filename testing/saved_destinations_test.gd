extends SceneTree

const Data := preload("res://modules/collection_data/interface.gd")
const Playground := preload("res://modules/playground_page/interface.gd")
const Sketchbook := preload("res://modules/sketchbook/interface.gd")


func _initialize() -> void:
	var storage: Variant = Data.storage_adapter().value
	var data: Variant = Data.create({"search": func(_query: Dictionary, _done: Callable) -> Dictionary:
		return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}},
		"load_saves": storage.load_saves, "save_if_absent": storage.save_if_absent, "now_ms": func() -> int: return 1000}).value
	var corpus: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/evidence/collection-search/corpus.json"))
	var completions: Array = []
	assert(Data.save(data, corpus.records[0], func(result: Dictionary) -> void: completions.append(result)).ok)
	assert(completions[-1].ok)
	var fetch := func(_sha: String, _done: Callable) -> Dictionary:
		return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "offline fixture"}}
	var deps := {"key": "test", "collection_data": data, "image_fetch": fetch}
	var playground: Control = Playground.create(deps).value
	var sketchbook: Control = Sketchbook.create(deps).value
	get_root().add_child(playground)
	get_root().add_child(sketchbook)
	playground.size = Vector2(1440, 820)
	sketchbook.size = Vector2(1440, 820)
	await process_frame
	await process_frame
	assert(playground.state().value.saved_ids == [corpus.records[0].id])
	assert(sketchbook.state().value.saved_ids == [corpus.records[0].id])
	playground.hide()
	sketchbook.hide()
	assert(Data.save(data, corpus.records[1], func(result: Dictionary) -> void: completions.append(result)).ok)
	playground.show()
	sketchbook.show()
	await process_frame
	await process_frame
	assert(playground.state().value.saved_ids.size() == 2)
	assert(sketchbook.state().value.saved_ids.size() == 2)
	assert(sketchbook.state().value.spread == 1 and sketchbook.state().value.strokes == 0)
	print("saved destinations: passed")
	quit()
