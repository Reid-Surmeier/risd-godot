extends Node
## Constructed by composition, then injected into CollectionDataInterface.create.
var base_url := "http://127.0.0.1:8128/"


func dispatch(query: Dictionary, done: Callable) -> Dictionary:
	var request := HTTPRequest.new()
	request.timeout = 15.0
	request.body_size_limit = 2 * 1024 * 1024
	request.max_redirects = 0
	add_child(request)
	var params: PackedStringArray = []
	for key in query:
		params.append(
			(
				str(key).uri_encode() + "=" + str(query[key]).to_lower().uri_encode()
				if query[key] is bool
				else str(key).uri_encode() + "=" + str(query[key]).uri_encode()
			)
		)
	request.request_completed.connect(
		func(status: int, _code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			request.queue_free()
			if status != HTTPRequest.RESULT_SUCCESS:
				done.call(
					{
						"ok": false,
						"value": null,
						"error":
						{
							"code": "collection_data.unavailable",
							"detail": "Search request failed or timed out"
						}
					}
				)
				return
			var decoded: Variant = JSON.parse_string(body.get_string_from_utf8())
			done.call(
				(
					decoded
					if decoded is Dictionary
					else {
						"ok": false,
						"value": null,
						"error":
						{
							"code": "collection_data.invalid_response",
							"detail": "Search returned invalid JSON"
						}
					}
				)
			)
	)
	var started := request.request(base_url + "api/collection/search?" + "&".join(params))
	if started != OK:
		request.queue_free()
		return {
			"ok": false,
			"value": null,
			"error": {"code": "collection_data.unavailable", "detail": "Search could not start"}
		}
	return {"ok": true, "value": null, "error": null}


func fetch_image(sha256: String, done: Callable) -> Dictionary:
	var request := HTTPRequest.new()
	request.timeout = 15.0
	request.body_size_limit = 20 * 1024 * 1024
	add_child(request)
	request.request_completed.connect(
		func(status: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			request.queue_free()
			if status == HTTPRequest.RESULT_SUCCESS and code == 200:
				done.call({"ok": true, "value": body, "error": null})
			else:
				done.call(
					{
						"ok": false,
						"value": null,
						"error":
						{"code": "collection_data.unavailable", "detail": "Image request failed"}
					}
				)
	)
	var started := request.request(base_url + "api/collection/image/" + sha256)
	if started != OK:
		request.queue_free()
		return {
			"ok": false,
			"value": null,
			"error":
			{"code": "collection_data.unavailable", "detail": "Image request could not start"}
		}
	return {"ok": true, "value": null, "error": null}
