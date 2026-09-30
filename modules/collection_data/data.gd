extends RefCounted
const Errors = preload("res://modules/collection_data/errors.gd")
const SORTS := ["date_asc", "date_desc", "title_asc", "title_desc"]


static func _ok(value: Variant) -> Dictionary:
	return {"ok": true, "value": value, "error": null}


static func _error(code: String, detail: String) -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func create(deps: Dictionary) -> Dictionary:
	if not deps.get("search") is Callable or not deps.search.is_valid():
		return _error(Errors.INVALID_DEPENDENCY, "A search adapter is required")
	for name in ["load_saves", "save_if_absent", "now_ms"]:
		if not deps.get(name) is Callable or not deps[name].is_valid():
			return _error(Errors.INVALID_DEPENDENCY, "A %s adapter is required" % name)
	return _ok(
		{
			"adapter": deps.search,
			"load_saves": deps.load_saves,
			"save_if_absent": deps.save_if_absent,
			"now_ms": deps.now_ms,
			"pending": 0,
			"saved_revision": 0,
			"storage_status": "unknown",
			"last_error": null
		}
	)


static func _handle(value: Variant) -> bool:
	return (
		value is Dictionary
		and value.get("adapter") is Callable
		and value.get("load_saves") is Callable
		and value.has("pending")
	)


static func state(handle: Variant) -> Dictionary:
	if not _handle(handle):
		return _error(Errors.INVALID_DEPENDENCY, "Invalid data handle")
	return _ok(
		{
			"pending": handle.pending,
			"saved_revision": handle.saved_revision,
			"storage_status": handle.storage_status,
			"last_error": handle.last_error
		}
	)


static func saved(handle: Variant, done: Callable) -> Dictionary:
	if not _handle(handle) or not done.is_valid():
		return _error(Errors.INVALID_DEPENDENCY, "Invalid saved-artwork dependency")
	return _storage_call(handle, handle.load_saves, [], done, false)


static func save(handle: Variant, artwork: Dictionary, done: Callable) -> Dictionary:
	if not _handle(handle) or not done.is_valid():
		return _error(Errors.INVALID_DEPENDENCY, "Invalid save dependency")
	if not _record(artwork):
		return _error(Errors.INVALID_RECORD, "Invalid artwork")
	var saved_at: Variant = handle.now_ms.call()
	if not _integer(saved_at) or saved_at < 0 or saved_at > 9007199254740991:
		return _error(Errors.INVALID_DEPENDENCY, "Invalid clock")
	return _storage_call(
		handle, handle.save_if_absent, [artwork.duplicate(true), int(saved_at)], done, true
	)


static func _storage_call(
	handle: Dictionary, operation: Callable, args: Array, done: Callable, saving: bool
) -> Dictionary:
	var completion := {
		"finished": false, "dispatching": true, "buffered": null, "has_buffered": false
	}
	handle.pending += 1
	var finish := func(response: Variant) -> void:
		if completion.finished:
			return
		if completion.dispatching:
			completion.buffered = response
			completion.has_buffered = true
			return
		completion.finished = true
		handle.pending -= 1
		var result := _save_result(response) if saving else _saved_result(response)
		handle.last_error = result.error
		handle.storage_status = "available" if result.ok else "error"
		if result.ok:
			handle.saved_revision = result.value.revision
		done.call(result)
	var call_args := args.duplicate()
	call_args.append(finish)
	var dispatched: Variant = operation.callv(call_args)
	completion.dispatching = false
	if not dispatched is Dictionary or dispatched.get("ok") != true:
		completion.finished = true
		handle.pending -= 1
		return _error(Errors.STORAGE_UNAVAILABLE, "Storage operation could not start")
	if completion.has_buffered:
		finish.call(completion.buffered)
	return _ok(null)


static func _saved_result(response: Variant) -> Dictionary:
	if not _result_envelope(response):
		return _error(Errors.STORAGE_CORRUPT, "Storage returned invalid data")
	if not response.ok:
		return _storage_error(response)
	return (
		_ok(response.value.duplicate(true))
		if _saved_collection(response.value)
		else _error(Errors.STORAGE_CORRUPT, "Saved data is corrupt")
	)


static func _save_result(response: Variant) -> Dictionary:
	if not _result_envelope(response):
		return _error(Errors.STORAGE_CORRUPT, "Storage returned invalid data")
	if not response.ok:
		return _storage_error(response)
	var value: Variant = response.value
	if (
		not value is Dictionary
		or not value.get("record") is Dictionary
		or not value.get("inserted") is bool
		or not _integer(value.get("revision"))
	):
		return _error(Errors.STORAGE_CORRUPT, "Storage returned invalid save result")
	if not _saved_item(value.record) or value.revision < 0:
		return _error(Errors.STORAGE_CORRUPT, "Storage returned invalid save result")
	return _ok(value.duplicate(true))


static func _result_envelope(value: Variant) -> bool:
	return (
		value is Dictionary
		and value.get("ok") is bool
		and value.has("value")
		and value.has("error")
	)


static func _storage_error(response: Dictionary) -> Dictionary:
	var error: Variant = response.error
	var allowed := [
		Errors.STORAGE_UNAVAILABLE,
		Errors.STORAGE_CORRUPT,
		Errors.STORAGE_VERSION,
		Errors.STORAGE_WRITE_FAILED
	]
	return (
		response.duplicate(true)
		if error is Dictionary and error.get("code") in allowed and _text(error.get("detail"))
		else _error(Errors.STORAGE_CORRUPT, "Storage returned an invalid error")
	)


static func _saved_item(item: Variant) -> bool:
	return (
		item is Dictionary
		and _record(item.get("artwork"))
		and _integer(item.get("saved_at_ms"))
		and item.saved_at_ms >= 0
		and item.saved_at_ms <= 9007199254740991
	)


static func _saved_collection(value: Variant) -> bool:
	if (
		not value is Dictionary
		or value.get("schema_version") != 1
		or not _integer(value.get("revision"))
		or value.revision < 0
		or not value.get("items") is Array
		or value.items.size() > 1000
	):
		return false
	var ids := {}
	for item in value.items:
		if not _saved_item(item) or ids.has(item.artwork.id):
			return false
		ids[item.artwork.id] = true
	return JSON.stringify(value).to_utf8_buffer().size() <= 4 * 1024 * 1024


static func search(handle: Variant, query: Dictionary, done: Callable) -> Dictionary:
	if not _handle(handle) or not done.is_valid():
		return _error(Errors.INVALID_DEPENDENCY, "Invalid search dependency")
	var normalized := _query(query)
	if not normalized.ok:
		return normalized
	var completion := {
		"finished": false, "dispatching": true, "has_buffered": false, "buffered": null
	}
	handle.pending += 1
	var finish := func(response: Variant) -> void:
		if completion.finished:
			return
		if completion.dispatching:
			if not completion.has_buffered:
				completion.has_buffered = true
				completion.buffered = response
			return
		completion.finished = true
		handle.pending -= 1
		var result := _response(response, normalized.value)
		handle.last_error = result.error
		done.call(result)
	var dispatched: Variant = handle.adapter.call(normalized.value.duplicate(true), finish)
	completion.dispatching = false
	if not dispatched is Dictionary or dispatched.get("ok") != true:
		completion.finished = true
		handle.pending -= 1
		return _error(Errors.UNAVAILABLE, "Search could not be started")
	if completion.has_buffered:
		finish.call(completion.buffered)
	return _ok(null)


static func _query(input: Dictionary) -> Dictionary:
	for key in input:
		if key not in ["q", "category", "sort", "has_image", "page", "snapshot"]:
			return _error(Errors.INVALID_QUERY, "Unknown query field")
	var query := {"q": "", "category": "All", "sort": "title_asc", "has_image": false, "page": 1}
	query.merge(input, true)
	if (
		not query.q is String
		or not query.category is String
		or not query.sort is String
		or not query.has_image is bool
		or not _integer(query.page)
	):
		return _error(Errors.INVALID_QUERY, "Invalid query types")
	var whitespace := RegEx.create_from_string("\\s+")
	query.q = whitespace.sub(query.q.strip_edges(), " ", true)
	if (
		query.q.length() > 256
		or query.category.is_empty()
		or query.category.to_utf8_buffer().size() > 128
		or query.sort not in SORTS
		or query.page < 1
		or query.page > 50000
		or (query.has("snapshot") and not _hash(query.snapshot))
	):
		return _error(Errors.INVALID_QUERY, "Invalid query value")
	query.page = int(query.page)
	return _ok(query)


static func _integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(value) and value == floor(value)


static func _hash(value: Variant) -> bool:
	return value is String and RegEx.create_from_string("^[a-f0-9]{64}$").search(value) != null


static func _text(value: Variant, limit: int = 4096) -> bool:
	return (
		value is String
		and value.to_utf8_buffer().size() <= limit
		and (
			RegEx.create_from_string("[\\x00-\\x08\\x0b\\x0c\\x0e-\\x1f\\x7f]").search(value)
			== null
		)
	)


static func _url(value: Variant, media: bool = false) -> bool:
	if not _text(value, 2048):
		return false
	var pattern := "^https://risdmuseum\\.org/art-design/collection/[a-zA-Z0-9_-]+$"
	if media:
		pattern = "^https://risdmuseum\\.cdn\\.picturepark\\.com/v/[a-zA-Z0-9_-]+/$"
	return RegEx.create_from_string(pattern).search(value) != null


static func _time(value: Variant) -> bool:
	return (
		value is String
		and (
			(
				RegEx
				. create_from_string(
					"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]{3})?Z$"
				)
				. search(value)
			)
			!= null
		)
	)


static func _rights(value: Variant) -> bool:
	return (
		value is Dictionary
		and value.get("status") in ["public_domain", "licensed", "unknown"]
		and value.has("evidence_url")
		and value.has("observed_at")
		and (value.evidence_url == null or _url(value.evidence_url))
		and (value.observed_at == null or _time(value.observed_at))
		and (
			value.status == "unknown" or (value.evidence_url != null and value.observed_at != null)
		)
	)


static func _record(a: Variant) -> bool:
	if (
		not a is Dictionary
		or not _text(a.get("web_id"), 128)
		or a.web_id.is_empty()
		or a.get("id") != "risd:" + a.web_id
	):
		return false
	if RegEx.create_from_string("[\\s/\\\\?#]").search(a.web_id) != null:
		return false
	for key in ["title", "dating", "accession", "category", "materials", "credit"]:
		if not _text(a.get(key)):
			return false
	if (
		not a.get("makers") is Array
		or a.makers.size() > 32
		or not a.has("year_from")
		or (a.year_from != null and not _integer(a.year_from))
	):
		return false
	for maker in a.makers:
		if not _text(maker):
			return false
	if (
		not _url(a.get("source_url"))
		or not _rights(a.get("rights"))
		or not _time(a.get("upstream_checked_at"))
		or a.get("availability") not in ["available", "unavailable", "unknown"]
		or not a.has("image")
	):
		return false
	if a.image != null:
		var i: Variant = a.image
		if (
			not i is Dictionary
			or not _text(i.get("id"))
			or i.id.is_empty()
			or not _url(i.get("source_url"), true)
			or i.get("evidence_url") != a.source_url
			or not _hash(i.get("sha256"))
			or i.get("mime") not in ["image/jpeg", "image/png", "image/webp"]
		):
			return false
		if (
			not _integer(i.get("width"))
			or not _integer(i.get("height"))
			or i.width <= 0
			or i.height <= 0
			or not _time(i.get("verified_at"))
			or not _rights(i.get("rights"))
			or i.rights.status == "unknown"
		):
			return false
	return JSON.stringify(a).to_utf8_buffer().size() <= 65536


static func _response(response: Variant, query: Dictionary) -> Dictionary:
	var invalid := _error(Errors.INVALID_RESPONSE, "Invalid search response")
	if (
		not response is Dictionary
		or not response.get("ok") is bool
		or not response.has("value")
		or not response.has("error")
	):
		return invalid
	if not response.ok:
		var error: Variant = response.error
		if (
			not error is Dictionary
			or (
				error.get("code")
				not in [
					Errors.INVALID_QUERY,
					Errors.UNAVAILABLE,
					Errors.INVALID_RESPONSE,
					Errors.SNAPSHOT_EXPIRED
				]
			)
			or not _text(error.get("detail"))
		):
			return invalid
		return response.duplicate(true)
	var page: Variant = response.value
	if (
		not page is Dictionary
		or not page.get("query") is Dictionary
		or not _hash(page.get("query_id"))
		or not page.get("corpus") is Dictionary
		or not page.get("items") is Array
		or not page.get("categories") is Array
	):
		return invalid
	var echoed := _query(page.query)
	if not echoed.ok or echoed.value != query:
		return invalid
	var corpus: Dictionary = page.corpus
	if (
		not _hash(corpus.get("snapshot"))
		or (query.has("snapshot") and corpus.snapshot != query.snapshot)
		or not _integer(corpus.get("count"))
		or corpus.count < 0
		or not _text(corpus.get("coverage"))
		or not _time(corpus.get("fetched_at"))
		or corpus.get("upstream_status") not in ["fresh", "cached", "unavailable"]
	):
		return invalid
	if (
		not _integer(page.get("total"))
		or page.total < 0
		or page.total > corpus.count
		or page.get("page") != query.page
		or page.get("page_size") != 20
		or page.items.size() != mini(20, maxi(0, int(page.total) - (int(query.page) - 1) * 20))
	):
		return invalid
	var ids: Array = []
	for item in page.items:
		if not _record(item) or item.id in ids:
			return invalid
		ids.append(item.id)
	for category in page.categories:
		if not _text(category, 128):
			return invalid
	return response.duplicate(true)
