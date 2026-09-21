## Throwaway reconstruction of the supplied PostPet setup composition.
## The reference plate owns the geometry so the prototype stays visually exact.
extends Control

const REFERENCE_SIZE := Vector2(6400, 3632)
const REFERENCE := "res://prototypes/postpet_viewer/assets/reference-layout.png"

var plate: TextureRect
var layout := Control.new()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.name = "reference-layout"
	layout.size = REFERENCE_SIZE
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layout)
	plate = TextureRect.new()
	plate.texture = load(REFERENCE)
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.stretch_mode = TextureRect.STRETCH_SCALE
	plate.size = REFERENCE_SIZE
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(plate)
	resized.connect(_fit)
	_fit()

func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var scale_factor := minf(size.x / REFERENCE_SIZE.x, size.y / REFERENCE_SIZE.y)
	layout.scale = Vector2(scale_factor, scale_factor)
	layout.position = (size - REFERENCE_SIZE * scale_factor) * 0.5
