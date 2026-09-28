## Offline #167: bounded low relief sampled from the owner's photo, not a scan.
extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 2, "Supply official full-portal and capital-detail inspection paths; see PORTAL-CLOSER-SOURCES.md")
	var source := Image.load_from_file(args[0])
	var detail := Image.load_from_file(args[1])
	assert(source != null and detail != null)
	var fields: Array = []
	var width := 96
	var height := 96
	# Six visible capital faces, not two mirrored pairs. The first three use
	# the museum's detailed left-support photo; the others use its full portal.
	# Order: left outer/middle/inner, then right inner/middle/outer.
	var crops := [
		[Vector2(525, 950), Vector2(1000, 965), Vector2(1015, 1770), Vector2(545, 1760)],
		[Vector2(1090, 955), Vector2(1580, 950), Vector2(1590, 1770), Vector2(1100, 1770)],
		[Vector2(1620, 970), Vector2(2640, 970), Vector2(2440, 1770), Vector2(1650, 1760)],
		[Vector2(1675, 1370), Vector2(1870, 1370), Vector2(1890, 1550), Vector2(1680, 1550)],
		[Vector2(1890, 1370), Vector2(1995, 1380), Vector2(1990, 1555), Vector2(1890, 1550)],
		[Vector2(2010, 1335), Vector2(2230, 1350), Vector2(2210, 1555), Vector2(2010, 1550)],
	]
	for index in crops.size():
		var corners: Array = crops[index]
		var photo: Image = detail if index < 3 else source
		var radius := 4 if index < 3 else 1
		var count := float((2 * radius + 1) * (2 * radius + 1))
		var field: Array = []
		for y in height:
			for x in width:
				var top: Vector2 = corners[0].lerp(corners[1], x / float(width - 1))
				var bottom: Vector2 = corners[3].lerp(corners[2], x / float(width - 1))
				var pixel := Vector2i(top.lerp(bottom, y / float(height - 1)))
				var luminance := 0.0
				for dy in range(-radius, radius + 1):
					for dx in range(-radius, radius + 1):
						luminance += photo.get_pixel(pixel.x + dx, pixel.y + dy).get_luminance() / count
				field.append(roundi(clampf((luminance - 0.10) / 0.65, 0, 1) * 255))
		fields.append(field)
	# Independent photographed impost strips; perspective follows each visible
	# band instead of imposing a repeated analytic diamond pattern.
	var bands: Array = []
	for corners in [[Vector2(70, 1185), Vector2(1060, 1260), Vector2(1040, 1330), Vector2(70, 1300)], [Vector2(1660, 1260), Vector2(2560, 1270), Vector2(2545, 1350), Vector2(1670, 1340)]]:
		var band: Array = []
		for y in 40:
			for x in 128:
				var top: Vector2 = corners[0].lerp(corners[1], x / 127.0)
				var bottom: Vector2 = corners[3].lerp(corners[2], x / 127.0)
				var pixel := Vector2i(top.lerp(bottom, y / 39.0))
				var lum := 0.0
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						lum += source.get_pixel(pixel.x + dx, pixel.y + dy).get_luminance() / 9.0
				band.append(roundi(clampf((lum - 0.10) / 0.65, 0, 1) * 255))
		bands.append(band)
	var output := FileAccess.open("res://modules/shell/prototype/gallery_walk4/portal-capital-relief.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"width": width, "height": height, "fields": fields, "band_width": 128, "band_height": 40, "bands": bands}) + "\n")
	output.close()
	print("PORTAL_RELIEF fields=6 grid=96x96 official-source-photos-only")
	quit()
