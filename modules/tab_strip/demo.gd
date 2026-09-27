## Demo scene: the toolbar at the top, its pages below. Click the blank stub to open a tab.
extends Control

const TabStrip := preload("res://modules/tab_strip/interface.gd")
## The bar is the owner's reference fitted to the window: 4180 source px across the window width,
## which puts the icon cluster at 65 percent of the width, the reference's proportion (a long
## empty stretch that holds six shrunk tabs).
const SOURCE_WIDTH := 4180.0

var strip: Control
var pages: Control


func _ready() -> void:
	var ground := ColorRect.new()  # the page area is white even with no tab open
	ground.name = "Ground"
	ground.color = Color.WHITE
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ground)
	pages = Control.new()
	pages.name = "PageStack"
	var created := TabStrip.create(pages)
	if not created.ok:
		push_error("tab_strip: %s" % created.error.code)
		return
	strip = created.value
	strip.name = "TabStrip"
	add_child(pages)
	add_child(strip)
	_fit()
	get_viewport().size_changed.connect(_fit)


func _fit() -> void:
	var vs := get_viewport_rect().size
	var scale := vs.x / SOURCE_WIDTH
	strip.scale = Vector2(scale, scale)
	TabStrip.set_bar_width(strip, SOURCE_WIDTH)
	pages.position = Vector2(0, 161 * scale)
	pages.size = Vector2(vs.x, vs.y - 161 * scale)
