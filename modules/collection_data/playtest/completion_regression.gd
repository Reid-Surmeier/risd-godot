extends SceneTree
const Data = preload("res://modules/collection_data/interface.gd")
var responses: Array = []
func _initialize() -> void:
	var handle = Data.create({"search": func(_query: Dictionary, done: Callable) -> Dictionary:
		done.call(null)
		return {"ok": true, "value": null, "error": null}}).value
	assert(Data.search(handle, {}, func(value: Dictionary) -> void: responses.append(value)).ok)
	assert(responses.size() == 1)
	assert(responses[0].error.code == "collection_data.invalid_response")
	assert(Data.state(handle).value.pending == 0)
	print("malformed synchronous completion: passed")
	quit()
