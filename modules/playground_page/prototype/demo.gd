## Throwaway #106: actual Playground with explicitly synthetic, memory-only saves.
extends Control
const Page = preload("res://modules/playground_page/interface.gd")
const Data = preload("res://modules/collection_data/interface.gd")

static func create_page() -> Control:
	var items: Array = []
	for i in 12:
		var id := "prototype-%02d" % i
		items.append({"saved_at_ms": i, "artwork": {
			"id": "risd:" + id, "web_id": id, "title": "Prototype %s %02d" % ["Vase" if i % 2 == 0 else "Drawing", i],
			"makers": ["Synthetic test record"], "dating": "", "accession": "", "category": "Test",
			"materials": "", "credit": "Prototype fixture — not a museum record", "year_from": null,
			"source_url": "https://risdmuseum.org/art-design/collection/" + id,
			"rights": {"status": "unknown", "evidence_url": null, "observed_at": null},
			"upstream_checked_at": "2026-09-20T00:00:00Z", "availability": "unknown", "image": null}})
	var unavailable := func(_a: Variant, _b: Variant) -> Dictionary:
		return {"ok": false, "value": null, "error": {"code": "prototype.unavailable", "detail": "Offline prototype"}}
	var data: Variant = Data.create({"search": unavailable,
		"load_saves": func(done: Callable) -> Dictionary:
			done.call({"ok": true, "value": {"schema_version": 1, "revision": 0, "items": items}, "error": null})
			return {"ok": true, "value": null, "error": null},
		"save_if_absent": unavailable, "now_ms": func() -> int: return 0}).value
	return Page.create({"key": "playground", "collection_data": data, "image_fetch": unavailable}).value

func _ready() -> void:
	add_child(create_page())

func _process(_delta: float) -> void:
	# Read-only browser probe, confined to this throwaway scene; no action shortcuts.
	if not OS.has_feature("web") or not JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa')"):
		return
	var page: Control = get_child(0)
	var controls := {}
	for control_name in ["SavedQuery", "ClearFilter", "SavedScroll"]:
		var control: Control = page.find_child(control_name, true, false)
		if control != null:
			var r := control.get_global_rect()
			controls[control_name] = [r.position.x, r.position.y, r.size.x, r.size.y]
	var first: Control = page.saved_list.get_child(0)
	var r := first.get_global_rect()
	controls.first = [r.position.x, r.position.y, r.size.x, r.size.y]
	JavaScriptBridge.eval("window.playgroundProof=" + JSON.stringify({"controls": controls,
		"detail": page.artwork_detail.text, "query": page.saved_query.text,
		"count": page.filter_count.text, "scroll": page.saved_scroll.scroll_vertical}))
