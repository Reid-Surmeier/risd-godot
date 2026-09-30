## #167 authored bas-relief study from the official portal photographs.
## Public-domain carved forms are interpreted, not photo brightness used as depth.
extends SceneTree


func _distance_to_line(p: Vector2, a: Vector2, b: Vector2) -> float:
	var t := clampf((p - a).dot(b - a) / maxf((b - a).length_squared(), 0.000001), 0, 1)
	return p.distance_to(a.lerp(b, t))


func _stroke(p: Vector2, points: Array, width: float) -> float:
	var distance := 100.0
	for i in points.size() - 1:
		distance = minf(distance, _distance_to_line(p, points[i], points[i + 1]))
	return exp(-pow(distance / width, 2.0))


func _mass(p: Vector2, points: Array, edge := 0.08) -> float:
	var polygon := PackedVector2Array(points)
	if not Geometry2D.is_point_in_polygon(p, polygon):
		return 0.0
	var distance := 100.0
	for i in points.size():
		distance = minf(distance, _distance_to_line(p, points[i], points[(i + 1) % points.size()]))
	return smoothstep(0.0, edge, distance)


func _ellipse(p: Vector2, center: Vector2, radii: Vector2) -> float:
	return smoothstep(1.0, 0.35, ((p - center) / radii).length())


func _leaf(p: Vector2, variant: int) -> float:
	var lean: float = [-0.10, 0.04, 0.13][variant]
	var q := (p - Vector2(lean * p.y, 0)) * Vector2(0.70, 0.91) + Vector2(0, 0.025)
	var outline := [
		Vector2(-0.04, 0.94),
		Vector2(0.49, 0.68),
		Vector2(0.66, 0.38),
		Vector2(0.51, 0.16),
		Vector2(0.03, 0.07),
		Vector2(-0.51, 0.18),
		Vector2(-0.61, 0.43),
		Vector2(-0.36, 0.77)
	]
	var raised := 0.33 * _mass(q, outline)
	var grooves := (
		0.20 * _stroke(q, [Vector2(0, 0.11), Vector2(0.03, 0.47), Vector2(-0.04, 0.87)], 0.035)
	)
	for row in 6:
		var y := 0.16 + row * 0.105
		grooves += (
			0.15
			* _stroke(
				q,
				[Vector2(0.01, y), Vector2(-0.25, y + 0.11), Vector2(-0.49 + row * 0.05, y + 0.17)],
				0.027
			)
		)
		grooves += (
			0.14
			* _stroke(
				q,
				[
					Vector2(0.02, y + 0.035),
					Vector2(0.27, y + 0.12),
					Vector2(0.52 - row * 0.04, y + 0.18)
				],
				0.030
			)
		)
	return raised - grooves * _mass(q, outline, 0.04)


func _scroll(p: Vector2) -> float:
	var raised := 0.0
	for side in [-1.0, 1.0]:
		var points: Array = []
		var center := Vector2(side * 0.40, 0.64 if side < 0 else 0.58)
		for i in 41:
			var t := i / 40.0
			var radius := lerpf(0.31 if side < 0 else 0.27, 0.025, t)
			var angle: float = side * (t * TAU * 1.18 + PI * 0.63)
			points.append(center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.78))
		raised = maxf(raised, 0.40 * _stroke(p, points, 0.062))
	var tails := [
		Vector2(-0.68, 0.47),
		Vector2(-0.51, 0.28),
		Vector2(-0.13, 0.11),
		Vector2(0.03, 0.19),
		Vector2(0.15, 0.10),
		Vector2(0.53, 0.25),
		Vector2(0.65, 0.42)
	]
	return maxf(raised, 0.33 * _stroke(p, tails, 0.061))


func _animals(p: Vector2, variant: int) -> float:
	# Distinct silhouettes from the paired animal/figural capital faces. Broad
	# bodies, heads and legs are real raised masses; no invented facial texture.
	var raised := 0.0
	if variant == 0:
		raised = maxf(
			raised,
			(
				0.37
				* _mass(
					p,
					[
						Vector2(-0.88, 0.47),
						Vector2(-0.72, 0.72),
						Vector2(-0.48, 0.81),
						Vector2(-0.18, 0.67),
						Vector2(0.05, 0.47),
						Vector2(-0.18, 0.32),
						Vector2(-0.66, 0.38)
					]
				)
			)
		)
		raised = maxf(
			raised,
			(
				0.34
				* _mass(
					p,
					[
						Vector2(0.04, 0.45),
						Vector2(0.25, 0.65),
						Vector2(0.62, 0.75),
						Vector2(0.85, 0.68),
						Vector2(0.77, 0.44),
						Vector2(0.48, 0.34),
						Vector2(0.18, 0.36)
					]
				)
			)
		)
		raised = maxf(raised, 0.47 * _ellipse(p, Vector2(0.07, 0.77), Vector2(0.25, 0.18)))
		for x in [-0.59, -0.30, 0.36, 0.66]:
			raised = maxf(
				raised,
				(
					0.32
					* _stroke(
						p,
						[Vector2(x, 0.44), Vector2(x - 0.04, 0.16), Vector2(x + 0.09, 0.12)],
						0.058
					)
				)
			)
		# Join the head into curved necks and shoulders, as in the detail photo.
		raised = maxf(
			raised,
			(
				0.43
				* _stroke(
					p,
					[
						Vector2(0.07, 0.77),
						Vector2(0.05, 0.61),
						Vector2(-0.18, 0.49),
						Vector2(-0.48, 0.56)
					],
					0.090
				)
			)
		)
		raised = maxf(
			raised,
			(
				0.38
				* _stroke(
					p,
					[
						Vector2(0.08, 0.63),
						Vector2(0.31, 0.51),
						Vector2(0.59, 0.59),
						Vector2(0.80, 0.70)
					],
					0.080
				)
			)
		)
		var feather := 0.0
		for side in [-1.0, 1.0]:
			for row in 4:
				var x := 0.26 + row * 0.12
				feather += _stroke(
					p,
					[
						Vector2(side * x, 0.67),
						Vector2(side * (x - 0.06), 0.55),
						Vector2(side * (x - 0.12), 0.47)
					],
					0.018
				)
		return raised - 0.10 * feather
	# The opposite face has a high central head and two descending forms,
	# unlike the broad horizontal paired bodies on the first animal capital.
	raised = 0.46 * _ellipse(p, Vector2(-0.06, 0.77), Vector2(0.30, 0.19))
	for side in [-1.0, 1.0]:
		var q := Vector2(p.x * side, p.y)
		raised = maxf(
			raised,
			(
				0.35
				* _mass(
					q,
					[
						Vector2(0.05, 0.58),
						Vector2(0.26, 0.73),
						Vector2(0.66, 0.67),
						Vector2(0.76, 0.46),
						Vector2(0.56, 0.29),
						Vector2(0.21, 0.37)
					]
				)
			)
		)
		raised = maxf(
			raised,
			(
				0.34
				* _stroke(q, [Vector2(0.29, 0.41), Vector2(0.23, 0.15), Vector2(0.45, 0.10)], 0.065)
			)
		)
		raised = maxf(
			raised,
			(
				0.28
				* _stroke(q, [Vector2(0.65, 0.46), Vector2(0.70, 0.16), Vector2(0.60, 0.12)], 0.050)
			)
		)
	# The opposite capital has a central rounded head and connected, curled bodies.
	raised = maxf(
		raised,
		0.43 * _stroke(p, [Vector2(-0.06, 0.77), Vector2(-0.03, 0.61), Vector2(0.09, 0.49)], 0.095)
	)
	for side in [-1.0, 1.0]:
		var q := Vector2(p.x * side, p.y)
		raised = maxf(
			raised,
			(
				0.39
				* _stroke(
					q,
					[
						Vector2(0.02, 0.62),
						Vector2(0.23, 0.52),
						Vector2(0.45, 0.58),
						Vector2(0.64, 0.73)
					],
					0.075
				)
			)
		)
		for row in 4:
			var x := 0.25 + row * 0.105
			raised -= (
				0.09
				* _stroke(q, [Vector2(x, 0.62), Vector2(x + 0.07, 0.49), Vector2(x, 0.39)], 0.016)
			)
	return raised


func _band(p: Vector2, side: int) -> float:
	# Two distinct tiers are visible in the closer source: triangular upper
	# notches and deeply cut lower stars, with a scroll above the left animal.
	var centers: Array = (
		[0.045, 0.17, 0.305, 0.445, 0.58, 0.72, 0.86, 0.98]
		if side == 0
		else [0.02, 0.15, 0.295, 0.43, 0.57, 0.705, 0.85, 0.98]
	)
	var height := 0.80
	for i in centers.size():
		var center: float = centers[i]
		var q := Vector2((p.x - center) / (0.067 if i % 3 == 0 else 0.072), (p.y - 0.32) / 0.29)
		if p.y < 0.64:
			var radius := q.length()
			var angle := atan2(q.y, q.x) + 0.06 * sin(i * 2.1 + side)
			var star := (
				pow(absf(sin(angle * 3.0)), 0.65)
				* smoothstep(0.10, 0.42, radius)
				* (1.0 - smoothstep(0.83, 1.02, radius))
			)
			height -= 0.61 * star
		var triangle := [
			Vector2(center - 0.049, 0.69),
			Vector2(center + 0.045, 0.69),
			Vector2(center + 0.009 * sin(i), 0.96)
		]
		height -= 0.56 * _mass(p, triangle, 0.021)
	# Narrow horizontal fillet separates the tiers without a black open gap.
	height -= 0.13 * exp(-pow((p.y - 0.64) / 0.020, 2.0))
	if side == 0 and p.x > 0.67 and p.y < 0.62:
		var q := Vector2((p.x - 0.835) / 0.17, p.y / 0.62)
		height = 0.24 + 1.18 * _scroll(q)
	return clampf(height, 0.05, 0.95)


func _initialize() -> void:
	var fields: Array = []
	for face in 6:
		var data: Array = []
		for y in 96:
			for x in 96:
				var p := Vector2(x / 95.0 * 2.0 - 1.0, 1.0 - y / 95.0)
				var relief := 0.0
				match face:
					0:
						relief = _leaf(p, 0)
					1:
						relief = _leaf(p, 1)
					2:
						relief = _animals(p, 0)
					3:
						relief = _scroll(p)
					4:
						relief = _leaf(p, 2)
					5:
						relief = _animals(p, 1)
				# Keep sub-byte height precision so derivative normals do not
				# turn a smooth carved shoulder into quantization terraces.
				data.append(snappedf(clampf(0.45 + relief, 0, 1) * 255, 0.001))
		fields.append(data)
	var bands: Array = []
	for side in 2:
		var data: Array = []
		for y in 40:
			for x in 128:
				data.append(snappedf(_band(Vector2(x / 127.0, 1.0 - y / 39.0), side) * 255, 0.001))
		bands.append(data)
	var output := FileAccess.open(
		"res://modules/shell/prototype/gallery_walk4/portal-capital-relief.json", FileAccess.WRITE
	)
	output.store_string(
		(
			JSON.stringify(
				{
					"width": 96,
					"height": 96,
					"fields": fields,
					"band_width": 128,
					"band_height": 40,
					"bands": bands
				}
			)
			+ "\n"
		)
	)
	output.close()
	print("PORTAL_SCULPT fields=6 bounded-authored-masses no-photo-depth")
	quit()
