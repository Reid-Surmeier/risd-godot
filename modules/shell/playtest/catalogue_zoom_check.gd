## Exercise the same HTTP completion and cancellation used by external Web photographs.
extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _require(value: bool, message: String) -> void:
	if not value:
		failures += 1
		print("FAIL ", message)


func _run() -> void:
	var adapter = load("res://modules/shell/prototype/gallery_walk4/catalogue_zoom.gd").new()
	root.add_child(adapter)
	_require(
		adapter.zoom_path("S1", {"zoom_image": "hall.jpg"}) == "hall.jpg", "Hall path was lost"
	)
	_require(
		adapter.zoom_path("54.186#14", {}).ends_with("54.186.jpg"),
		"object catalogue path was lost when the room normalized its caption"
	)
	_require(adapter.zoom_path("missing#0", {}).is_empty(), "unknown work gained a zoom path")
	var picture := TextureRect.new()
	root.add_child(picture)
	var fallback: Texture2D = load("res://modules/shell/prototype/gallery_walk4/detail/S1.jpg")
	picture.texture = fallback
	adapter._path = "S1.jpg"
	adapter._picture = weakref(picture)
	var url := "http://127.0.0.1:8948/"
	_require(adapter._request.request(url + "S1.jpg") == OK, "request did not start")
	for i in 200:
		if adapter._texture != null:
			break
		await create_timer(0.05).timeout
	_require(picture.texture.get_height() == 4210, "full catalogue image did not replace fallback")
	adapter.clear()
	picture.texture = fallback
	adapter._path = "missing.jpg"
	adapter._picture = weakref(picture)
	_require(adapter._request.request(url + "missing.jpg") == OK, "missing request did not start")
	await create_timer(0.5).timeout
	_require(picture.texture == fallback, "failed download removed the packed photograph")
	adapter._path = "S1.jpg"
	adapter._picture = weakref(picture)
	_require(adapter._request.request(url + "S1.jpg") == OK, "cancelled request did not start")
	adapter.clear()
	await create_timer(0.5).timeout
	_require(
		adapter._texture == null and picture.texture == fallback,
		"cancelled request replaced preview"
	)
	print("CATALOGUE_ZOOM_CHECK failures=", failures)
	quit(1 if failures else 0)
