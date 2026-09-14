## The Playground mockup Tenant: built by interface.gd's create; everything in here is free to change.
## A white surface with the owner's reference picture (assets/reference.png, PROVENANCE.md) drawn
## at native size, re-centred whenever the Page resizes. Not a hand-drawn pixel anywhere.
extends ColorRect

const Errors := preload("res://modules/playground_page/errors.gd")
const IMAGE := "res://modules/playground_page/assets/reference.png"

var key := ""
var ticks := 0
var inputs := 0
var _image: TextureRect


static func create(deps: Dictionary) -> Dictionary:
	if not ResourceLoader.exists(IMAGE):
		return Errors.err(Errors.ASSET_MISSING, IMAGE)
	var tex = load(IMAGE)
	if tex == null:
		return Errors.err(Errors.ASSET_MISSING, IMAGE)
	var page = load("res://modules/playground_page/playground_page.gd").new()
	page.key = deps.get("key", "")
	page.name = "PlaygroundPage"
	page.color = Color.WHITE
	page._image = TextureRect.new()
	page._image.name = "Reference"
	page._image.texture = tex
	page._image.stretch_mode = TextureRect.STRETCH_KEEP
	page._image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page._image.size = tex.get_size()
	page.add_child(page._image)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.resized.connect(page._centre)
	return Errors.ok(page)


func _ready() -> void:
	_centre()


func _centre() -> void:
	_image.position = ((size - _image.size) / 2.0).floor()


func _process(_delta: float) -> void:
	ticks += 1


func _unhandled_input(_event: InputEvent) -> void:
	inputs += 1


func state() -> Dictionary:
	return Errors.ok({"key": key, "ticks": ticks, "inputs": inputs, "size": size,
			"image_size": _image.size, "image_rect": Rect2(_image.position, _image.size)})
