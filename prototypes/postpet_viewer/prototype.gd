## Throwaway PostPet composition built from separate UI components.
## The screenshot is a placement reference; it is not rendered as the page.
extends Control

const CANVAS := Vector2(6400, 3632)
const ASSET_ROOT := "res://prototypes/postpet_viewer/assets/components/"
const LION := "res://prototypes/postpet_viewer/assets/lion-native-cutout.png"

var desktop := Control.new()
var viewer: Panel

const OBJECTS := [
	{"id": "sphinx", "asset": "sphinx.png", "position": Vector2(5650, 930), "size": Vector2(520, 900)},
	{"id": "bust", "asset": "bust.png", "position": Vector2(4470, 1200), "size": Vector2(700, 500)},
	{"id": "horse", "asset": "horse.png", "position": Vector2(5050, 1200), "size": Vector2(820, 500)},
	{"id": "nude", "asset": "nude.png", "position": Vector2(5600, 1940), "size": Vector2(600, 850)},
	{"id": "dark-sculpture", "asset": "dark-sculpture.png", "position": Vector2(4450, 1910), "size": Vector2(650, 800)},
	{"id": "bust-profile", "asset": "bust-profile.png", "position": Vector2(5080, 2410), "size": Vector2(700, 850)},
]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desktop.size = CANVAS
	desktop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desktop)
	var paper := ColorRect.new()
	paper.color = Color.WHITE
	paper.size = CANVAS
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(paper)
	_add_component("setup-window.png", Vector2(1830, 790), Vector2(2700, 1900))
	for object in OBJECTS:
		_add_object(object)
	resized.connect(_fit)
	_fit()

func _add_component(asset: String, position: Vector2, dimensions: Vector2) -> TextureRect:
	var image := TextureRect.new()
	image.texture = load(ASSET_ROOT + asset)
	image.position = position
	image.size = dimensions
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(image)
	return image

func _add_object(object: Dictionary) -> void:
	_add_component(object.asset, object.position, object.size)
	var hit := Button.new()
	hit.name = "select-%s" % object.id
	hit.position = object.position
	hit.size = object.size
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.tooltip_text = "Open %s in the 3D viewer" % object.id.replace("-", " ")
	hit.pressed.connect(func(): _open_viewer(object.id))
	desktop.add_child(hit)

func _open_viewer(object_id: String) -> void:
	if viewer != null:
		viewer.queue_free()
	viewer = Panel.new()
	viewer.name = "viewer-%s" % object_id
	viewer.position = Vector2(1670, 400)
	viewer.size = Vector2(3060, 2780)
	viewer.mouse_filter = Control.MOUSE_FILTER_STOP
	desktop.add_child(viewer)
	var title := Label.new()
	title.text = "RISD Museum  /  %s  /  3D viewer" % object_id.replace("-", " ").capitalize()
	title.position = Vector2(90, 60)
	title.add_theme_font_size_override("font_size", 76)
	viewer.add_child(title)
	var surface := ColorRect.new()
	surface.position = Vector2(90, 190)
	surface.size = Vector2(2880, 2050)
	surface.color = Color("#f4f5f6")
	viewer.add_child(surface)
	var sculpture := TextureRect.new()
	sculpture.texture = load(LION)
	sculpture.position = Vector2(830, 420)
	sculpture.size = Vector2(1250, 1250)
	sculpture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sculpture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sculpture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	viewer.add_child(sculpture)
	var close := Button.new()
	close.text = "Close"
	close.position = Vector2(2520, 2320)
	close.size = Vector2(360, 180)
	close.add_theme_font_size_override("font_size", 54)
	close.pressed.connect(func(): viewer.queue_free(); viewer = null)
	viewer.add_child(close)

func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var scale_factor := minf(size.x / CANVAS.x, size.y / CANVAS.y)
	desktop.scale = Vector2(scale_factor, scale_factor)
	desktop.position = (size - CANVAS * scale_factor) * 0.5
