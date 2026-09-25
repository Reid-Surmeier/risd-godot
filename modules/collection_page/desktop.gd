## The eight RO HUD windows of the Image Viewer desktop: each the owner's own screenshot, placed at
## the layout reference's 1944x1280 review coordinates scaled to the Page and anchored to its
## nearest edges (#63), its magenta border
## keyed out by remove-pink.gdshader. Reach it through interface.gd only.
##
## Ported from qwen-image-pipeline prototype/81-image-viewer @ 5d55209 desktop.gd. Changed: paths
## moved under res://modules/collection_page/, snapshot() carries drag_height for the probe.
extends Control

const ROOT := "res://modules/collection_page/"
const MUSE_FILTER_FRAME := ROOT + "assets/muse-filter-frame.webp"
const DESKTOP := Vector2(1944, 1280)
# Screenshot placements in the layout reference's 1944 x 1280 review coordinates.
const PANELS := [
	["equipment", Rect2(12, 20, 482, 254), 30],
	["options", Rect2(12, 291, 493, 213), 30],
	["filters", Rect2(12, 522, 508, 231), 44],
	["status", Rect2(0, 762, 499, 63), 31],
	["trade", Rect2(12, 828, 492, 213), 31],
	["chat", Rect2(6, 1050, 505, 230), 29],
	["party", Rect2(530, 709, 319, 312), 38],
	["bottom", Rect2(519, 1221, 1403, 54), 54],
]
var panels: Array[TextureRect] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for entry in PANELS:
		var panel := TextureRect.new()
		panel.name = entry[0]
		var texture: Texture2D
		if entry[0] == "filters":
			var frame := AtlasTexture.new()
			var muse_image := Image.new()
			if muse_image.load_webp_from_buffer(FileAccess.get_file_as_bytes(MUSE_FILTER_FRAME)) != OK:
				push_error("Muse filter frame could not be decoded")
				return
			frame.atlas = ImageTexture.create_from_image(muse_image)
			frame.region = Rect2(12, 526, 520, 220)
			texture = frame
		else:
			texture = load(ROOT + "assets/" + entry[0] + ".png")
		panel.texture = texture
		panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var material := ShaderMaterial.new()
		material.shader = preload("res://modules/collection_page/remove-pink.gdshader")
		if entry[0] == "filters":
			material.set_shader_parameter("border_width", 3.0)
		panel.material = material
		add_child(panel)
		panels.append(panel)


## The windows at one uniform scale of the reference (#63), each kept at its native distance, times
## the scale, from the page edges nearest its centre.
func arrange(available: Vector2) -> void:
	var factor := minf(available.x / DESKTOP.x, available.y / DESKTOP.y)
	for index in panels.size():
		var rect: Rect2 = PANELS[index][1]
		var at := rect.position * factor
		var far := available - (DESKTOP - rect.position) * factor
		if rect.get_center().x > DESKTOP.x / 2:
			at.x = far.x
		if rect.get_center().y > DESKTOP.y / 2:
			at.y = far.y
		panels[index].position = at
		panels[index].size = rect.size * factor
		panels[index].set_meta("drag_height", PANELS[index][2] * factor)


func snapshot() -> Array:
	var result := []
	for panel in panels:
		result.append({"name": panel.name, "rect": panel.get_rect(), "drag_height": panel.get_meta("drag_height"),
				"order": panel.get_index()})
	return result
