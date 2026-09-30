extends SceneTree

const Data := preload("res://modules/collection_data/interface.gd")
const Playground := preload("res://modules/playground_page/interface.gd")
const Sketchbook := preload("res://modules/sketchbook/interface.gd")


func _initialize() -> void:
	var storage: Variant = Data.storage_adapter().value
	var data: Variant = (
		Data
		. create(
			{
				"search":
				func(_query: Dictionary, _done: Callable) -> Dictionary:
					return {
						"ok": false,
						"value": null,
						"error": {"code": "collection_data.unavailable", "detail": "unused"}
					},
				"load_saves": storage.load_saves,
				"save_if_absent": storage.save_if_absent,
				"now_ms": func() -> int: return 1000
			}
		)
		. value
	)
	var corpus: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://docs/evidence/collection-search/corpus.json")
	)
	var completions: Array = []
	assert(
		(
			Data
			. save(
				data,
				corpus.records[0],
				func(result: Dictionary) -> void: completions.append(result)
			)
			. ok
		)
	)
	assert(completions[-1].ok)
	var fetch := func(_sha: String, done: Callable) -> Dictionary:
		done.call(
			{
				"ok": false,
				"value": null,
				"error": {"code": "collection_data.unavailable", "detail": "offline fixture"}
			}
		)
		return {"ok": true, "value": null, "error": null}
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
	assert(playground.state().value.saved_images_unavailable == 1)
	assert(sketchbook.state().value.saved_ids == [corpus.records[0].id])
	assert(sketchbook.state().value.reference_cards[0].image_unavailable)
	playground.hide()
	sketchbook.hide()
	assert(
		(
			Data
			. save(
				data,
				corpus.records[1],
				func(result: Dictionary) -> void: completions.append(result)
			)
			. ok
		)
	)
	playground.show()
	sketchbook.show()
	await process_frame
	await process_frame
	assert(playground.state().value.saved_ids.size() == 2)
	assert(playground.state().value.saved_images_unavailable == 2)
	assert(sketchbook.state().value.saved_ids.size() == 2)
	assert(
		sketchbook.state().value.reference_cards.all(
			func(card: Dictionary) -> bool: return card.image_unavailable
		)
	)
	assert(sketchbook.state().value.spread == 1 and sketchbook.state().value.strokes == 0)
	var stored := {"document": {}}
	assert(Data.saved(data, func(result: Dictionary) -> void: stored.document = result.value).ok)
	var pending_loads: Array = []
	var delayed: Variant = (
		Data
		. create(
			{
				"search":
				func(_query: Dictionary, _done: Callable) -> Dictionary:
					return {
						"ok": false,
						"value": null,
						"error": {"code": "collection_data.unavailable", "detail": "unused"}
					},
				"load_saves":
				func(done: Callable) -> Dictionary:
					pending_loads.append(done)
					return {"ok": true, "value": null, "error": null},
				"save_if_absent": storage.save_if_absent,
				"now_ms": func() -> int: return 1000
			}
		)
		. value
	)
	var delayed_deps := {"key": "delayed", "collection_data": delayed, "image_fetch": fetch}
	var delayed_playground: Control = Playground.create(delayed_deps).value
	var delayed_sketchbook: Control = Sketchbook.create(delayed_deps).value
	get_root().add_child(delayed_playground)
	get_root().add_child(delayed_sketchbook)
	delayed_playground.size = Vector2(1440, 820)
	delayed_sketchbook.size = Vector2(1440, 820)
	await process_frame
	assert(pending_loads.size() == 2)
	delayed_playground.hide()
	delayed_sketchbook.hide()
	for i in 2:
		pending_loads[i].call({"ok": true, "value": stored.document, "error": null})
	await process_frame
	assert(delayed_playground.state().value.saved_ids.is_empty())
	assert(delayed_sketchbook.state().value.saved_ids.is_empty())
	delayed_playground.show()
	delayed_sketchbook.show()
	await process_frame
	assert(pending_loads.size() == 4)
	for i in range(2, 4):
		pending_loads[i].call({"ok": true, "value": stored.document, "error": null})
	await process_frame
	assert(delayed_playground.state().value.saved_ids.size() == 2)
	assert(delayed_sketchbook.state().value.saved_ids.size() == 2)
	print("saved destinations: passed")
	quit()
