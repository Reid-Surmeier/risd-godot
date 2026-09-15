class_name CollectionDataInterface
extends RefCounted
## Frozen search subset, issue #78. Save operations belong to #80.
## All calls return {ok, value, error:{code,detail}|null}.
## deps.search(query, done) returns dispatch Result and completes done(Result) once.
## search() accepts q/category/sort/has_image/page/optional snapshot; wire schema:
## docs/specs/collection-data-74.md. GET api/collection/search, images by verified SHA.
## A successful dispatch is NOT a successful search. Immediate errors do not call done.
const Implementation = preload("res://modules/collection_data/data.gd")
const HttpAdapter = preload("res://modules/collection_data/http_adapter.gd")

## Construct the existing production search adapter. Web uses the game document's origin and
## native playtests use the adapter's localhost default.
static func http_adapter() -> Dictionary:
	var adapter = HttpAdapter.new()
	if OS.has_feature("web"):
		adapter.base_url = JavaScriptBridge.eval("new URL('./', window.location.href).href")
	return {"ok": true, "value": adapter, "error": null}

static func create(deps: Dictionary) -> Dictionary:
	return Implementation.create(deps)

static func search(handle: Variant, query: Dictionary, done: Callable) -> Dictionary:
	return Implementation.search(handle, query, done)

static func state(handle: Variant) -> Dictionary:
	return Implementation.state(handle)
