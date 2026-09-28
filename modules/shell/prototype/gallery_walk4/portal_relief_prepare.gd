## Offline #167: bounded low relief sampled from the owner's photo, not a scan.
extends SceneTree

func _initialize() -> void:
	var source := Image.load_from_file("res://image-work/grand-gallery-v2/source/arch-outside.png")
	assert(source != null)
	var fields: Array = []
	var width := 64
	var height := 56
	# Four individually visible faces, excluding the impost above each capital.
	# Order is left outer, left inner, right inner, right outer. Source unchanged.
	for crop in [Rect2i(119, 679, 116, 100), Rect2i(236, 681, 115, 99), Rect2i(705, 673, 122, 105), Rect2i(828, 673, 119, 106)]:
		var field: Array = []
		for y in height:
			for x in width:
				var pixel: Vector2i = crop.position + Vector2i(Vector2(x / float(width - 1), y / float(height - 1)) * Vector2(crop.size - Vector2i.ONE))
				var luminance := 0.0
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						luminance += source.get_pixel(pixel.x + dx, pixel.y + dy).get_luminance() / 9.0
				field.append(roundi(clampf((luminance - 0.12) / 0.48, 0, 1) * 255))
		fields.append(field)
	var output := FileAccess.open("res://modules/shell/prototype/gallery_walk4/portal-capital-relief.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"width": width, "height": height, "fields": fields}) + "\n")
	output.close()
	print("PORTAL_RELIEF fields=4 grid=64x56 source-photo-only")
	quit()
