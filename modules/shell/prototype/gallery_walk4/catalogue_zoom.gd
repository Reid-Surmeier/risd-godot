## Catalogue photographs beside the Web pack: fetch one when its zoom page opens.
## The packed detail remains visible while the photograph loads.
extends Node

var _request: HTTPRequest
var _path := ""
var _texture: Texture2D
var _picture: WeakRef
var _objects: Variant


func _ready() -> void:
	_request = HTTPRequest.new()
	_request.timeout = 30.0
	add_child(_request)
	_request.request_completed.connect(_completed)


func zoom_path(tag: String, record: Dictionary) -> String:
	if record.has("zoom_image"):
		return str(record.zoom_image)
	if _objects == null:
		_objects = JSON.parse_string(
			FileAccess.get_file_as_string("res://modules/shell/collection_rooms/objects.json")
		)
	if _objects is Dictionary:
		return str(_objects.get(tag.get_slice("#", 0), {}).get("zoom_image", ""))
	return ""


func show_image(path: String, picture: TextureRect) -> void:
	_picture = weakref(picture)
	if path == _path:
		if _texture != null:
			picture.texture = _texture
		return
	_request.cancel_request()
	_path = path
	_texture = null
	if OS.has_feature("web"):
		var relative := "museum-images/" + path.get_file()
		var url: String = JavaScriptBridge.eval(
			"new URL(" + JSON.stringify(relative) + ", location.href).href"
		)
		if _request.request(url) != OK:
			push_warning("Catalogue zoom request could not start: " + path.get_file())
	else:
		var photograph := Image.new()
		if photograph.load(path) == OK:
			_present(photograph)
		else:
			push_warning("Catalogue zoom photograph could not load: " + path.get_file())


func _completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if _path.is_empty():
		return
	var photograph := Image.new()
	if (
		result == HTTPRequest.RESULT_SUCCESS
		and code == 200
		and photograph.load_jpg_from_buffer(body) == OK
	):
		_present(photograph)
	else:
		push_warning("Catalogue zoom photograph did not download: " + _path.get_file())


func _present(photograph: Image) -> void:
	_texture = ImageTexture.create_from_image(photograph)
	var picture = _picture.get_ref()
	if is_instance_valid(picture):
		picture.texture = _texture


func clear() -> void:
	_request.cancel_request()
	_path = ""
	_texture = null
	_picture = null
