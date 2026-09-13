## Demo scene: the toolbar at the top, its pages below. Click the blank stub to open a tab.
extends Control

const TabStrip := preload("res://modules/tab_strip/interface.gd")

var strip: Control


func _ready() -> void:
	var pages := Control.new()
	pages.name = "PageStack"
	var created := TabStrip.create(pages)
	if not created.ok:
		push_error("tab_strip: %s" % created.error.code)
		return
	strip = created.value
	strip.name = "TabStrip"
	# source bar is 3135 px wide; show it at the width of the window
	var scale := get_viewport_rect().size.x / 3135.0
	strip.scale = Vector2(scale, scale)
	pages.position = Vector2(0, 161 * scale)
	pages.size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y - 161 * scale)
	add_child(pages)
	add_child(strip)
