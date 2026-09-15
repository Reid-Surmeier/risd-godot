extends RefCounted
const CollectionPageAdapter := preload("res://testing/collection_page_adapter.gd")

## Frozen in #78: terminal search responses, including a duplicate callback probe.
static func collection_search(response: Dictionary, twice: bool = false) -> Dictionary:
	return {"ok": true, "error": null, "value": func(_query: Dictionary, done: Callable) -> Dictionary:
		done.call(response.duplicate(true))
		if twice:
			done.call(response.duplicate(true))
		return {"ok": true, "value": null, "error": null}}


## Deterministic asynchronous adapter used by the Collection Page acceptance journey (#88).
static func collection_page_search() -> Dictionary:
	return {"ok": true, "error": null, "value": CollectionPageAdapter.new()}
