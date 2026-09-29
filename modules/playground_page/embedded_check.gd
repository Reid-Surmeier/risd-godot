## #175 private regression: reuse frozen real-input acceptance at the retained client size.
extends "res://modules/playground_page/playtest/square_harness.gd"

func _mount(node: Node, _size: Vector2i, _default_out_dir: String) -> String:
	get_root().min_size = Vector2i.ZERO
	var output := await super._mount(node, Vector2i(590, 790), "/tmp/playground-embedded-175")
	node.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	node.size = Vector2(590, 790)
	await _frames(3)
	assert(node.compact and node.content_width == 468, str(node.size, node.compact, node.content_width))
	assert(node.canvas.scale.x * 12 >= 12, "embedded text shrank below its designed size")
	for character in "너는 여전히 너야":
		assert(node.theme.default_font.has_char(character.unicode_at(0)), "missing Korean glyph")
	node._detail(node.arena[0])
	await _frames(2)
	var panel: Control = node.detail.get_child(0)
	assert(Rect2(Vector2.ZERO, node.canvas.size).encloses(panel.get_rect()), "detail escaped client")
	node.detail.free()
	return output

func _press_named(tenant: Control, target: String) -> void:
	var button: Control = tenant.find_child(target, true, false)
	assert(button != null, target)
	if tenant.scroll.is_ancestor_of(button):
		tenant.scroll.ensure_control_visible(button)
		await _frames(2)
	await super._press_named(tenant, target)
