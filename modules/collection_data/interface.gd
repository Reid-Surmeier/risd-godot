class_name CollectionDataInterface
extends RefCounted
## Frozen search and browser-local save seam, issues #78 and #80.
## All calls return {ok, value, error:{code,detail}|null}.
## deps.search(query, done) returns dispatch Result and completes done(Result) once.
## search() accepts q/category/sort/has_image/page/optional snapshot; wire schema:
## docs/specs/collection-data-74.md. GET api/collection/search, images by verified SHA.
## A successful dispatch is NOT a successful search. Immediate errors do not call done.
const Implementation = preload("res://modules/collection_data/data.gd")
const HttpAdapter = preload("res://modules/collection_data/http_adapter.gd")
const StorageAdapter = preload("res://modules/collection_data/storage_adapter.gd")

## Construct the production HTTP adapter. Composition injects its `dispatch` search Callable and
## `fetch_image` Callable; Web uses the game document's origin and native uses localhost.
static func http_adapter() -> Dictionary:
	var adapter = HttpAdapter.new()
	if OS.has_feature("web"):
		adapter.base_url = JavaScriptBridge.eval("new URL('./', window.location.href).href")
	return {"ok": true, "value": adapter, "error": null}

## Construct the fixed-name IndexedDB adapter on Web and a volatile native adapter for playtests.
static func storage_adapter() -> Dictionary:
	return StorageAdapter.new().initialize()

static func create(deps: Dictionary) -> Dictionary:
	return Implementation.create(deps)

static func search(handle: Variant, query: Dictionary, done: Callable) -> Dictionary:
	return Implementation.search(handle, query, done)

static func saved(handle: Variant, done: Callable) -> Dictionary:
	return Implementation.saved(handle, done)

static func save(handle: Variant, artwork: Dictionary, done: Callable) -> Dictionary:
	return Implementation.save(handle, artwork, done)

static func state(handle: Variant) -> Dictionary:
	return Implementation.state(handle)
