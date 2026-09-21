## Throwaway reconstruction of the supplied PostPet setup/login composition.
## The reference plate owns the geometry; only the viewer image is interactive.
extends Control

const REFERENCE_SIZE := Vector2(1782, 1182)
const VIEWPORT_RECT := Rect2(917, 117, 635, 583)
const REFERENCE := "res://prototypes/postpet_viewer/assets/reference-layout.png"
const LION := "res://prototypes/postpet_viewer/assets/lion-native-cutout.png"
const LION_ABOVE := "res://prototypes/postpet_viewer/assets/lion-pass1-from-above.png"

var plate: TextureRect
var viewer_surface: ColorRect
var lion: TextureRect
var layout := Control.new()
var view_index := 0

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
	viewer_surface = ColorRect.new()
	viewer_surface.name = "viewer-surface"
	viewer_surface.position = VIEWPORT_RECT.position
	viewer_surface.size = VIEWPORT_RECT.size
	viewer_surface.color = Color("#ffffff")
	viewer_surface.mouse_filter = Control.MOUSE_FILTER_STOP
	layout.add_child(viewer_surface)
	lion = TextureRect.new()
	lion.name = "muse-lion-pass"
	lion.texture = load(LION)
	lion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lion.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lion.position = Vector2(1014, 205)
	lion.size = Vector2(440, 400)
	lion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(lion)
	var interaction := Control.new()
	interaction.name = "viewer-interaction"
	interaction.position = VIEWPORT_RECT.position
	interaction.size = VIEWPORT_RECT.size
	interaction.mouse_default_cursor_shape = Control.CURSOR_DRAG
	interaction.gui_input.connect(_viewer_input)
	layout.add_child(interaction)
	resized.connect(_fit)
	_fit()

func _viewer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			view_index = 1 - view_index
			lion.texture = load(LION_ABOVE if view_index == 1 else LION)

func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var scale_factor := minf(size.x / REFERENCE_SIZE.x, size.y / REFERENCE_SIZE.y)
	layout.scale = Vector2(scale_factor, scale_factor)
	layout.position = (size - REFERENCE_SIZE * scale_factor) * 0.5
