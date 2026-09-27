## flowers_page implementation. Reach it through interface.gd only.
extends Control

const Errors := preload("res://modules/flowers_page/errors.gd")
const TITLE := "res://modules/flowers_page/assets/title.png"  # the game's title frame, captured from Ruffle at 2x
const GAME := Vector2(750, 422)  # the <embed> size on ferryhalim.com/orisinal/flowers/
const MARGIN := 48.0  # page px around the window at most
const MAX_FACTOR := 2.0

var key := ""
var ticks := 0
var factor := 1.0
var placed := ""
var window: TextureRect


static func create(deps: Dictionary) -> Dictionary:
	if not ResourceLoader.exists(TITLE):
		return Errors.err(Errors.ASSET_MISSING, TITLE)
	var page: Control = load("res://modules/flowers_page/flowers_page.gd").new()
	page.key = str(deps.get("key", "flowers"))
	return Errors.ok(page)


func _ready() -> void:
	name = "FlowersPage"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ground := ColorRect.new()
	ground.name = "Ground"
	ground.color = Color.WHITE
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ground)
	window = TextureRect.new()
	window.name = "Flowers"
	window.texture = load(TITLE)
	window.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	window.stretch_mode = TextureRect.STRETCH_SCALE
	window.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(window)
	resized.connect(_layout)
	_layout()
	if OS.has_feature("web"):
		JavaScriptBridge.eval(preload("res://modules/flowers_page/flowers_embed.gd").JS)
		visibility_changed.connect(_place)
		tree_exiting.connect(func() -> void: JavaScriptBridge.eval("window.flowersEmbed(null)"))


func _layout() -> void:
	factor = clampf(minf((size.x - 2.0 * MARGIN) / GAME.x, (size.y - 2.0 * MARGIN) / GAME.y), 0.1, MAX_FACTOR)
	window.size = (GAME * factor).round()
	window.position = ((size - window.size) / 2.0).round()


## The Web build lays the Ruffle player over the window; null while the Page is hidden.
func _place() -> void:
	if not OS.has_feature("web"):
		return
	var placement := "null"
	if is_visible_in_tree():
		var r: Rect2 = get_global_transform_with_canvas() * window.get_rect()
		var view := get_viewport_rect().size
		placement = JSON.stringify({"rect": [r.position.x, r.position.y, r.size.x, r.size.y], "view": [view.x, view.y]})
	if placement != placed:
		placed = placement
		JavaScriptBridge.eval("window.flowersEmbed(%s)" % placement)


func _process(_delta: float) -> void:
	ticks += 1
	_place()


func state() -> Dictionary:
	return Errors.ok({"key": key, "ticks": ticks, "window": window.get_rect(), "factor": factor,
			"web": OS.has_feature("web"), "placement": placed if placed != "" else "null"})
