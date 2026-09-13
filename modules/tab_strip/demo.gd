## Demo scene: the toolbar at the top, its pages below. Click the blank stub to open a tab.
extends Control

const TabStrip := preload("res://modules/tab_strip/interface.gd")
## Tabs are drawn at this fraction of their source size (the bar is 161 source px tall).
const SCALE := 0.55

var strip: Control
var pages: Control


func _ready() -> void:
	pages = Control.new()
	pages.name = "PageStack"
	var created := TabStrip.create(pages)
	if not created.ok:
		push_error("tab_strip: %s" % created.error.code)
		return
	strip = created.value
	strip.name = "TabStrip"
	strip.scale = Vector2(SCALE, SCALE)
	add_child(pages)
	add_child(strip)
	_fit()
	get_viewport().size_changed.connect(_fit)


func _fit() -> void:
	var vs := get_viewport_rect().size
	TabStrip.set_bar_width(strip, vs.x / SCALE)
	pages.position = Vector2(0, 161 * SCALE)
	pages.size = Vector2(vs.x, vs.y - 161 * SCALE)
