extends RefCounted
## GDScript port of tldraw's freehand ink (tldraw `shapes/shared/freehand`, a fork of
## perfect-freehand): streamlined ingest, simulated-pressure radii, elbow partitioning, left/right
## tracks with rounded corners, round caps and midpoint-quadratic smoothing. Returns filled outline
## polygons in the caller's coordinate space. Ported from tldraw 5.3.2 (node_modules, risd-godot
## kidpix-tldraw prototype); numbers and branches follow the source line by line.
## Ported unchanged in behaviour from figma-ui-ux-qwen-pipeline
## prototype/painting-tool-mixbox @ 7ee5e9c
## viewer-godot/scripts/freehand.gd (the global class_name dropped; the module preloads it). Reach
## it through interface.gd only.

const MIN_PRESSURE := 0.025
const RATE_OF_PRESSURE_CHANGE := 0.275
const FIXED_PI := PI + 1e-4
const TRACK_TOLERANCE_RATIO := 0.05
const SIMPLIFY_WINDOW := 8
const MAX_ROUNDED_CORNER_STEPS := 13
const HARD_CORNER_DPR := -0.62
const CURVE_STEPS := 3

# Pipeline (ingest/compute_radii): streamlined points, raw inputs, pressure, distances, radii.
var pt_x: PackedFloat64Array
var pt_y: PackedFloat64Array
var in_x: PackedFloat64Array
var in_y: PackedFloat64Array
var in_z: PackedFloat64Array
var press: PackedFloat64Array
var dists: PackedFloat64Array
var runs: PackedFloat64Array
var rads: PackedFloat64Array
var point_count := 0
# Source partition fed to the track builder.
var sx: PackedFloat64Array
var sy: PackedFloat64Array
var six: PackedFloat64Array
var siy: PackedFloat64Array
var sr: PackedFloat64Array
var srl: PackedFloat64Array
var scap: PackedByteArray
var src_count := 0
# Tracks.
var left: PackedVector2Array
var right: PackedVector2Array


## tldraw `simulatePressureSettings`: a mouse "draw" stroke.
static func draw_options(stroke_width: float, last: bool) -> Dictionary:
	return {
		"size": stroke_width,
		"thinning": 0.5,
		"streamline": _modulate(stroke_width, 9.0, 16.0, 0.64, 0.74),
		"smoothing": 0.62,
		"simulate_pressure": true,
		"last": last,
	}


static func _modulate(value: float, a0: float, a1: float, b0: float, b1: float) -> float:
	return b0 + (b1 - b0) * clampf((value - a0) / (a1 - a0), 0.0, 1.0)


static func _ease_out_sine(t: float) -> float:
	return sin(t * PI / 2.0)


## The filled ink polygons for raw input points (x, y, pressure).
func ink_polygons(raw: Array, options: Dictionary) -> Array[PackedVector2Array]:
	ingest(raw, options)
	var polygons: Array[PackedVector2Array] = []
	if point_count == 0:
		return polygons
	compute_radii(options)
	_partition_at_elbows(options, polygons)
	return polygons


func _resize_pipeline(n: int) -> void:
	pt_x.resize(n)
	pt_y.resize(n)
	in_x.resize(n)
	in_y.resize(n)
	in_z.resize(n)
	press.resize(n)
	dists.resize(n)
	runs.resize(n)
	rads.resize(n)


func ingest(raw: Array, options: Dictionary) -> void:
	var streamline: float = options.get("streamline", 0.5)
	var size: float = options.get("size", 16.0)
	var simulate_pressure: bool = options.get("simulate_pressure", false)
	var is_last: bool = options.get("last", false)
	point_count = 0
	var raw_len := raw.size()
	if raw_len == 0:
		return
	var t := 0.15 + (1.0 - streamline) * 0.85
	var st_x := PackedFloat64Array()
	var st_y := PackedFloat64Array()
	var st_z := PackedFloat64Array()
	st_x.resize(raw_len + 8)
	st_y.resize(raw_len + 8)
	st_z.resize(raw_len + 8)
	_resize_pipeline(raw_len + 8)
	var min_dist2 := pow(size / 3.0, 2)
	var clamp_z := not simulate_pressure
	var first: Vector3 = raw[0]
	var first_z := _z_of(first, clamp_z)
	var start_idx := 1
	while start_idx < raw_len:
		var pt: Vector3 = raw[start_idx]
		var dx := pt.x - first.x
		var dy := pt.y - first.y
		if dx * dx + dy * dy > min_dist2:
			break
		first_z = maxf(first_z, _z_of(pt, clamp_z))
		start_idx += 1
	st_x[0] = first.x
	st_y[0] = first.y
	st_z[0] = first_z
	var m := 1
	for i in range(start_idx, raw_len):
		var pt: Vector3 = raw[i]
		st_x[m] = pt.x
		st_y[m] = pt.y
		st_z[m] = _z_of(pt, clamp_z)
		m += 1
	var removed_near_end := 0
	if m > 1:
		var last_x := st_x[m - 1]
		var last_y := st_y[m - 1]
		var j := m - 2
		while j >= 0:
			var dx := st_x[j] - last_x
			var dy := st_y[j] - last_y
			if dx * dx + dy * dy > min_dist2:
				break
			j -= 1
			removed_near_end += 1
		if j < m - 2:
			st_x[j + 1] = last_x
			st_y[j + 1] = last_y
			st_z[j + 1] = st_z[m - 1]
			m = j + 2
	var is_complete := (
		is_last
		or not simulate_pressure
		or (
			m > 1
			and pow(st_x[m - 1] - st_x[m - 2], 2) + pow(st_y[m - 1] - st_y[m - 2], 2) < size * size
		)
		or removed_near_end > 0
	)
	if m == 2 and simulate_pressure:
		var x0 := st_x[0]
		var y0 := st_y[0]
		var z0 := st_z[0]
		var x1 := st_x[1]
		var y1 := st_y[1]
		var z1 := st_z[1]
		for i in range(1, 5):
			var u2 := i / 4.0
			st_x[i] = x0 + (x1 - x0) * u2
			st_y[i] = y0 + (y1 - y0) * u2
			st_z[i] = (z0 + (z1 - z0)) * i / 4.0
		m = 5
	pt_x[0] = st_x[0]
	pt_y[0] = st_y[0]
	in_x[0] = st_x[0]
	in_y[0] = st_y[0]
	in_z[0] = st_z[0]
	press[0] = 0.5 if simulate_pressure else st_z[0]
	dists[0] = 0.0
	runs[0] = 0.0
	rads[0] = 1.0
	var count := 1
	if is_complete and streamline > 0.0:
		st_x[m] = st_x[m - 1]
		st_y[m] = st_y[m - 1]
		st_z[m] = st_z[m - 1]
		m += 1
	var total_length := 0.0
	var prev_x := st_x[0]
	var prev_y := st_y[0]
	var u := 1.0 - t
	for i in range(1, m):
		var x: float
		var y: float
		if t == 0.0 or (is_last and i == m - 1):
			x = st_x[i]
			y = st_y[i]
		else:
			x = st_x[i] + (prev_x - st_x[i]) * u
			y = st_y[i] + (prev_y - st_y[i]) * u
		if absf(prev_x - x) < 1e-4 and absf(prev_y - y) < 1e-4:
			continue
		var distance := sqrt(pow(y - prev_y, 2) + pow(x - prev_x, 2))
		total_length += distance
		if i < 4 and total_length < size:
			continue
		pt_x[count] = x
		pt_y[count] = y
		in_x[count] = st_x[i]
		in_y[count] = st_y[i]
		in_z[count] = st_z[i]
		press[count] = 0.5 if simulate_pressure else st_z[i]
		dists[count] = distance
		runs[count] = total_length
		rads[count] = 1.0
		count += 1
		prev_x = x
		prev_y = y
	if total_length < 1.0:
		var max_p := 0.5
		for i in range(count):
			max_p = maxf(max_p, press[i])
		for i in range(count):
			press[i] = max_p
	point_count = count


func _z_of(p: Vector3, clamp_z: bool) -> float:
	var z := p.z
	return MIN_PRESSURE if clamp_z and z < MIN_PRESSURE else z


func compute_radii(options: Dictionary) -> void:
	var size: float = options.get("size", 16.0)
	var thinning: float = options.get("thinning", 0.5)
	var simulate_pressure: bool = options.get("simulate_pressure", true)
	var n := point_count
	var total_length := runs[n - 1]
	if not simulate_pressure and total_length < size:
		var max_p := 0.5
		for i in range(n):
			max_p = maxf(max_p, press[i])
		for i in range(n):
			press[i] = max_p
			rads[i] = size * _ease_out_sine(0.5 - thinning * (0.5 - max_p))
		return
	var prev_pressure := press[0]
	for i in range(n):
		if runs[i] > size * 5.0:
			break
		var sp := minf(1.0, dists[i] / size)
		var p: float
		if simulate_pressure:
			var rp := minf(1.0, 1.0 - sp)
			p = minf(1.0, prev_pressure + (rp - prev_pressure) * (sp * RATE_OF_PRESSURE_CHANGE))
		else:
			p = minf(1.0, prev_pressure + (press[i] - prev_pressure) * 0.5)
		prev_pressure = prev_pressure + (p - prev_pressure) * 0.5
	for i in range(n):
		var radius: float
		if thinning != 0.0:
			var pressure := press[i]
			var sp := minf(1.0, dists[i] / size)
			if simulate_pressure:
				var rp := minf(1.0, 1.0 - sp)
				pressure = minf(
					1.0, prev_pressure + (rp - prev_pressure) * (sp * RATE_OF_PRESSURE_CHANGE)
				)
			else:
				pressure = minf(
					1.0, prev_pressure + (pressure - prev_pressure) * (sp * RATE_OF_PRESSURE_CHANGE)
				)
			radius = size * _ease_out_sine(0.5 - thinning * (0.5 - pressure))
			prev_pressure = pressure
		else:
			radius = size / 2.0
		rads[i] = radius


func _partition_at_elbows(options: Dictionary, out: Array[PackedVector2Array]) -> void:
	var n := point_count
	if n == 0:
		return
	if n <= 2:
		_load_src_from_pipeline()
		_render_partition(options, false, 0.0, 0.0, out)
		return
	var a := 0
	var a_elbow := false
	var has_anchor := false
	var anchor_x := 0.0
	var anchor_y := 0.0
	var dx := pt_x[1] - pt_x[0]
	var dy := pt_y[1] - pt_y[0]
	var length := sqrt(dx * dx + dy * dy)
	var prev_vx := dx / length
	var prev_vy := dy / length
	for i in range(1, n - 1):
		dx = pt_x[i + 1] - pt_x[i]
		dy = pt_y[i + 1] - pt_y[i]
		length = sqrt(dx * dx + dy * dy)
		var next_vx := dx / length
		var next_vy := dy / length
		var dpr := prev_vx * next_vx + prev_vy * next_vy
		prev_vx = next_vx
		prev_vy = next_vy
		if dpr < -0.8:
			_finish_partition(
				a, a_elbow, i, true, false, has_anchor, anchor_x, anchor_y, options, out
			)
			a = i
			a_elbow = true
			has_anchor = true
			anchor_x = pt_x[i]
			anchor_y = pt_y[i]
			continue
		if dpr > 0.7:
			continue
		var pdx := pt_x[i] - pt_x[i - 1]
		var pdy := pt_y[i] - pt_y[i - 1]
		var ndx := pt_x[i + 1] - pt_x[i]
		var ndy := pt_y[i + 1] - pt_y[i]
		var mean_radius := (rads[i - 1] + rads[i] + rads[i + 1]) / 3.0
		if (pdx * pdx + pdy * pdy + ndx * ndx + ndy * ndy) / (mean_radius * mean_radius) < 1.5:
			_finish_partition(
				a, a_elbow, i, false, true, has_anchor, anchor_x, anchor_y, options, out
			)
			a = i
			a_elbow = false
			has_anchor = false
			continue
	_finish_partition(a, a_elbow, n - 1, false, false, has_anchor, anchor_x, anchor_y, options, out)


func _finish_partition(
	a: int,
	a_elbow: bool,
	b: int,
	b_elbow: bool,
	b_dup: bool,
	has_anchor: bool,
	anchor_x: float,
	anchor_y: float,
	options: Dictionary,
	out: Array[PackedVector2Array]
) -> void:
	var length := b - a + 1 + (1 if b_dup else 0)
	var s := 0
	var e := 0
	var start_x := in_x[a] if a_elbow else pt_x[a]
	var start_y := in_y[a] if a_elbow else pt_y[a]
	var start_radius := rads[a]
	while length - s > 2:
		var i := a + 1 + s
		var dx := start_x - pt_x[i]
		var dy := start_y - pt_y[i]
		if dx * dx + dy * dy < pow((start_radius + rads[i]) / 2.0 * 0.5, 2):
			has_anchor = true
			anchor_x = pt_x[i]
			anchor_y = pt_y[i]
			s += 1
		else:
			break
	var end_x := in_x[b] if b_elbow else pt_x[b]
	var end_y := in_y[b] if b_elbow else pt_y[b]
	var end_radius := rads[b]
	while length - s - e > 2:
		var i := (b - e) if b_dup else (b - 1 - e)
		var dx := end_x - pt_x[i]
		var dy := end_y - pt_y[i]
		if dx * dx + dy * dy < pow((end_radius + rads[i]) / 2.0 * 0.5, 2):
			e += 1
		else:
			break
	var inner_start := a + 1 + s
	var inner_end := (b - e) if b_dup else (b - 1 - e)
	_load_src_partition(a, a_elbow, inner_start, inner_end, b, b_elbow, b_dup and e == 0)
	_render_partition(options, has_anchor, anchor_x, anchor_y, out)


func _resize_src(n: int) -> void:
	sx.resize(n)
	sy.resize(n)
	six.resize(n)
	siy.resize(n)
	sr.resize(n)
	srl.resize(n)
	scap.resize(n)


func _load_src_from_pipeline() -> void:
	var n := point_count
	_resize_src(n)
	for i in range(n):
		sx[i] = pt_x[i]
		sy[i] = pt_y[i]
		six[i] = in_x[i]
		siy[i] = in_y[i]
		sr[i] = rads[i]
		srl[i] = runs[i]
		scap[i] = 1 if (i == 0 or i == n - 1) else 0
	src_count = n


func _load_src_partition(
	a: int, a_elbow: bool, inner_start: int, inner_end: int, b: int, b_elbow: bool, dup_quirk: bool
) -> void:
	_resize_src(maxi(inner_end - inner_start, 0) + 3)
	sx[0] = in_x[a] if a_elbow else pt_x[a]
	sy[0] = in_y[a] if a_elbow else pt_y[a]
	six[0] = in_x[a]
	siy[0] = in_y[a]
	sr[0] = rads[a]
	srl[0] = runs[a]
	scap[0] = 1
	var w := 1
	for i in range(inner_start, inner_end + 1):
		sx[w] = pt_x[i]
		sy[w] = pt_y[i]
		six[w] = in_x[i]
		siy[w] = in_y[i]
		sr[w] = rads[i]
		srl[w] = runs[i]
		scap[w] = 0
		w += 1
	if dup_quirk:
		scap[w - 1] = 1
	sx[w] = in_x[b] if b_elbow else pt_x[b]
	sy[w] = in_y[b] if b_elbow else pt_y[b]
	six[w] = in_x[b]
	siy[w] = in_y[b]
	sr[w] = rads[b]
	srl[w] = runs[b]
	scap[w] = 1
	src_count = w + 1


func _simplify_track(track: PackedVector2Array, tol: float) -> PackedVector2Array:
	var length := track.size()
	if length <= 2 or tol <= 0.0:
		return track
	var tol2 := tol * tol
	var out := PackedVector2Array([track[0]])
	var anchor := 0
	var last_idx := length - 1
	while anchor < last_idx:
		var best := anchor + 1
		var max_j := mini(anchor + SIMPLIFY_WINDOW, last_idx)
		var a := track[anchor]
		for j in range(anchor + 2, max_j + 1):
			var ac := track[j] - a
			var l2 := ac.length_squared()
			var fits := true
			for k in range(anchor + 1, j):
				var t := 0.0 if l2 == 0.0 else clampf((track[k] - a).dot(ac) / l2, 0.0, 1.0)
				if (track[k] - (a + ac * t)).length_squared() > tol2:
					fits = false
					break
			if not fits:
				break
			best = j
		out.append(track[best])
		anchor = best
	return out


func _build_tracks(options: Dictionary, has_anchor: bool, anchor_x: float, anchor_y: float) -> void:
	var size: float = options.get("size", 16.0)
	var smoothing: float = options.get("smoothing", 0.5)
	left = PackedVector2Array()
	right = PackedVector2Array()
	var n := src_count
	if n == 0 or size <= 0.0:
		return
	var total_length := srl[n - 1]
	var min_distance := pow(size * smoothing, 2)
	var cur := Vector2(1, 1)
	if n > 1:
		var d := Vector2(sx[0] - sx[1], sy[0] - sy[1])
		cur = d if d.length() == 0.0 else d / d.length()
	var prev_vec := cur
	var pl := Vector2(sx[0], sy[0])
	var pr := pl
	var tl := pl
	var tr := pr
	var prev_sharp := false
	for i in range(n):
		var point := Vector2(sx[i], sy[i])
		var radius := sr[i]
		var vec := cur
		var next_vec := vec
		if i < n - 1:
			var from := Vector2(anchor_x, anchor_y) if (i == 0 and n > 2 and has_anchor) else point
			var d := from - Vector2(sx[i + 1], sy[i + 1])
			next_vec = d if d.length() == 0.0 else d / d.length()
		cur = next_vec
		var prev_dpr := vec.dot(prev_vec)
		var next_dpr := next_vec.dot(vec) if i < n - 1 else 1.0
		var sharp := prev_dpr < 0.0 and not prev_sharp
		var next_sharp := next_dpr < 0.2
		if sharp or next_sharp:
			if next_dpr > HARD_CORNER_DPR and total_length - srl[i] > radius:
				var offset := prev_vec * radius
				var cpr := prev_vec.x * next_vec.y - prev_vec.y * next_vec.x
				if cpr < 0.0:
					tl = point + offset
					tr = point - offset
				else:
					tl = point - offset
					tr = point + offset
				left.append(tl)
				right.append(tr)
			else:
				var input := Vector2(six[i], siy[i])
				var d := Vector2(-prev_vec.y * radius, prev_vec.x * radius)
				var step := 1.0 / MAX_ROUNDED_CORNER_STEPS
				var t := 0.0
				while t < 1.0:
					var angle := FIXED_PI * t
					tl = (
						input
						+ Vector2(
							d.x * cos(angle) - d.y * sin(angle), d.x * sin(angle) + d.y * cos(angle)
						)
					)
					left.append(tl)
					angle = FIXED_PI + FIXED_PI * -t
					tr = (
						input
						+ Vector2(
							d.x * cos(angle) - d.y * sin(angle), d.x * sin(angle) + d.y * cos(angle)
						)
					)
					right.append(tr)
					t += step
			pl = tl
			pr = tr
			if next_sharp:
				prev_sharp = true
			continue
		prev_sharp = false
		if scap[i] == 1:
			var offset := Vector2(vec.y * radius, -vec.x * radius)
			left.append(point - offset)
			right.append(point + offset)
			continue
		var lerped := next_vec + (vec - next_vec) * next_dpr
		var offset := Vector2(lerped.y * radius, -lerped.x * radius)
		tl = point - offset
		if i <= 1 or (pl - tl).length_squared() > min_distance:
			left.append(tl)
			pl = tl
		tr = point + offset
		if i <= 1 or (pr - tr).length_squared() > min_distance:
			right.append(tr)
			pr = tr
		prev_vec = vec
	var tolerance := size * TRACK_TOLERANCE_RATIO
	left = _simplify_track(left, tolerance)
	right = _simplify_track(right, tolerance)


## Appends the polygon for the current source partition, mirroring tldraw's svgInk path:
## M left[0], smooth quadratics through left midpoints, a round end cap, back along the right
## track, and a round start cap.
func _render_partition(
	options: Dictionary,
	has_anchor: bool,
	anchor_x: float,
	anchor_y: float,
	out: Array[PackedVector2Array]
) -> void:
	var n := src_count
	if n == 0:
		return
	if n == 1:
		out.append(_circle(Vector2(sx[0], sy[0]), sr[0]))
		return
	_build_tracks(options, has_anchor, anchor_x, anchor_y)
	if left.size() == 0 or right.size() == 0:
		return
	var poly := PackedVector2Array()
	var pen := _SmoothPen.new(poly)
	pen.move_to(left[0])
	for i in range(1, left.size()):
		pen.smooth_to((left[i - 1] + left[i]) / 2.0)
	# End cap: semicircle around the last source point from +perp to -perp (SVG sweep 1).
	var last := Vector2(sx[n - 1], sy[n - 1])
	var v := Vector2(sx[n - 2], sy[n - 2]) - last
	var perp := Vector2(-v.y, v.x).normalized() * sr[n - 1]
	pen.line_to(last + perp)
	_arc(poly, last, last + perp, PI)
	pen.reset_control()
	var prev := right[right.size() - 1]
	for i in range(right.size() - 2, -1, -1):
		pen.smooth_to((prev + right[i]) / 2.0)
		prev = right[i]
	var first := Vector2(sx[0], sy[0])
	var v0 := first - Vector2(sx[1], sy[1])
	var perp0 := Vector2(v0.y, -v0.x).normalized() * sr[0]
	pen.line_to(first + perp0)
	_arc(poly, first, first + perp0, PI)
	out.append(poly)


func _circle(center: Vector2, radius: float) -> PackedVector2Array:
	var poly := PackedVector2Array()
	for i in range(16):
		var angle := TAU * i / 16.0
		poly.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return poly


func _arc(poly: PackedVector2Array, center: Vector2, from: Vector2, sweep: float) -> void:
	var start := (from - center).angle()
	var radius := (from - center).length()
	var steps := 8
	for i in range(1, steps + 1):
		var angle := start + sweep * i / steps
		poly.append(center + Vector2(cos(angle), sin(angle)) * radius)


## SVG "t" semantics: each smooth quadratic reflects the previous control point.
class _SmoothPen:
	var poly: PackedVector2Array
	var current := Vector2.ZERO
	var control := Vector2.ZERO
	var has_control := false

	func _init(target: PackedVector2Array) -> void:
		poly = target

	func move_to(p: Vector2) -> void:
		poly.append(p)
		current = p
		has_control = false

	func line_to(p: Vector2) -> void:
		poly.append(p)
		current = p
		has_control = false

	func reset_control() -> void:
		current = poly[poly.size() - 1]
		has_control = false

	func smooth_to(p: Vector2) -> void:
		var c := (current * 2.0 - control) if has_control else current
		for i in range(1, CURVE_STEPS + 1):
			var t := float(i) / CURVE_STEPS
			var q := current.lerp(c, t).lerp(c.lerp(p, t), t)
			poly.append(q)
		control = c
		current = p
		has_control = true
