extends SceneTree
const Data = preload("res://modules/collection_data/interface.gd")
const Fixtures = preload("res://testing/interface.gd")
var completions: Array = []

func _initialize() -> void:
	var http := Data.http_adapter()
	assert(http.ok and http.value is Node and http.value.base_url == "http://127.0.0.1:8128/")
	http.value.free()
	assert(not Data.create({}).ok)
	var fixture = Fixtures.collection_search({"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "Museum unavailable"}}, true)
	var handle = Data.create({"search": fixture.value}).value
	assert(not Data.search(handle, {"page": 0}, _done).ok)
	assert(completions.is_empty())
	assert(Data.search(handle, {"q": " Monet  meadow "}, _done).ok)
	assert(completions.size() == 1)
	assert(completions[0].error.code == "collection_data.unavailable")
	assert(Data.state(handle).value.pending == 0)
	print("collection_data seam: passed")
	quit()

func _done(result: Dictionary) -> void:
	completions.append(result)
