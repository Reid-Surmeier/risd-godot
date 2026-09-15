extends RefCounted
## Frozen in #78: terminal search responses, including a duplicate callback probe.
static func collection_search(response: Dictionary, twice: bool = false) -> Dictionary:
	return {"ok": true, "error": null, "value": func(_query: Dictionary, done: Callable) -> Dictionary:
		done.call(response.duplicate(true))
		if twice:
			done.call(response.duplicate(true))
		return {"ok": true, "value": null, "error": null}}
