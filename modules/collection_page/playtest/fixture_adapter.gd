extends Node
## Deterministic playtest adapter. `fail`, `expire` and `slow` exercise the UI's asynchronous
## states; every other query searches the same verified corpus served in production tests.

const CORPUS := "res://docs/evidence/collection-search/corpus.json"
var calls: Array[Dictionary] = []


func dispatch(query: Dictionary, done: Callable) -> Dictionary:
	calls.append(query.duplicate(true))
	var delay := 0.80 if query.q == "slow" else 0.03
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		if query.q == "fail":
			done.call({"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "fixture unavailable"}})
			return
		if query.q == "expire":
			done.call({"ok": false, "value": null, "error": {"code": "collection_data.snapshot_expired", "detail": "fixture snapshot expired"}})
			return
		done.call(_result(query)))
	return {"ok": true, "value": null, "error": null}


func _result(query: Dictionary) -> Dictionary:
	var corpus: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CORPUS))
	var records: Array = corpus.records.duplicate(true)
	var term: String = query.q.to_lower()
	if term == "pages":
		records.clear()
		for index in 25:
			var clone: Dictionary = corpus.records[index % corpus.records.size()].duplicate(true)
			clone.web_id = "%s-%d" % [clone.web_id, index]
			clone.id = "risd:" + clone.web_id
			records.append(clone)
	elif term not in ["", "slow"]:
		records = records.filter(func(record: Dictionary) -> bool: return term in JSON.stringify(record).to_lower())
	if query.category != "All":
		records = records.filter(func(record: Dictionary) -> bool: return record.category == query.category)
	if query.has_image:
		records = records.filter(func(record: Dictionary) -> bool: return record.image != null)
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var key := "title" if query.sort.begins_with("title") else "year_from"
		var av: Variant = a[key] if a[key] != null else 999999
		var bv: Variant = b[key] if b[key] != null else 999999
		return av < bv if query.sort.ends_with("asc") else av > bv)
	var snapshot := FileAccess.get_sha256(CORPUS)
	var total: int = records.size()
	var first: int = (query.page - 1) * 20
	var page_items: Array = records.slice(first, mini(first + 20, total)) if first < total else []
	var value := {"query": query.duplicate(true), "query_id": snapshot, "corpus": {"snapshot": snapshot,
		"count": maxi(corpus.records.size(), total), "coverage": corpus.coverage, "fetched_at": corpus.fetched_at,
		"upstream_status": corpus.upstream_status}, "total": total, "page": query.page,
		"page_size": 20, "categories": ["Painting", "Photographs", "Drawings and Watercolors"], "items": page_items}
	return {"ok": true, "value": value, "error": null}
