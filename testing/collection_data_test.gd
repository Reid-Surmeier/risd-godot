extends SceneTree
const Data = preload("res://modules/collection_data/interface.gd")
const Fixtures = preload("res://testing/interface.gd")
var completions: Array = []


func _initialize() -> void:
	var http := Data.http_adapter()
	assert(http.ok and http.value is Node and http.value.base_url == "http://127.0.0.1:8128/")
	http.value.free()
	assert(not Data.create({}).ok)
	var fixture = Fixtures.collection_search(
		{
			"ok": false,
			"value": null,
			"error": {"code": "collection_data.unavailable", "detail": "Museum unavailable"}
		},
		true
	)
	var storage: Variant = Data.storage_adapter().value
	var handle = (
		Data
		. create(
			{
				"search": fixture.value,
				"load_saves": storage.load_saves,
				"save_if_absent": storage.save_if_absent,
				"now_ms": func() -> int: return 1234
			}
		)
		. value
	)
	assert(not Data.search(handle, {"page": 0}, _done).ok)
	assert(completions.is_empty())
	assert(Data.search(handle, {"q": " Monet  meadow "}, _done).ok)
	assert(completions.size() == 1)
	assert(completions[0].error.code == "collection_data.unavailable")
	assert(Data.state(handle).value.pending == 0)
	var corpus: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://docs/evidence/collection-search/corpus.json")
	)
	assert(Data.save(handle, corpus.records[0], _done).ok)
	assert(
		(
			completions[-1].ok
			and completions[-1].value.inserted
			and completions[-1].value.record.saved_at_ms == 1234
		)
	)
	assert(Data.save(handle, corpus.records[0].duplicate(true), _done).ok)
	assert(
		(
			completions[-1].ok
			and not completions[-1].value.inserted
			and completions[-1].value.record.saved_at_ms == 1234
		)
	)
	assert(Data.saved(handle, _done).ok)
	assert(
		(
			completions[-1].ok
			and completions[-1].value.items.size() == 1
			and completions[-1].value.revision == 1
		)
	)
	print("collection_data seam: passed")
	quit()


func _done(result: Dictionary) -> void:
	completions.append(result)
