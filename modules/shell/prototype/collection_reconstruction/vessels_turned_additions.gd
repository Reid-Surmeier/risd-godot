## Rockefeller vessels: the existing hollow ring-profile/turned-tureen builder, with
## separate swept handles and spouts. Measured profiles and catalogue metres live
## in assets/additions/vessels-turned/profiles.json; the existing artwork RGB is reused.
## shortcut: front decoration repeats on the rear; replace when a rear photograph is approved.
extends RefCounted

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const PROFILES := "res://assets/additions/vessels-turned/profiles.json"
const SIDES := 32


func build(room) -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PROFILES))
	var changed: Array = []
	for work in data.works:
		var old: Node3D
		for node in room.get_children():
			if node.get_meta("catalogue_asset", "") == work.asset:
				old = node
		assert(old != null, "A turned vessel must replace its own existing blob: " + work.asset)
		var vessel := make(work, load("res://assets/vessels-turned/" + work.asset + ".png"))
		room.add_child(vessel)
		vessel.transform = old.transform
		for key in old.get_meta_list():
			vessel.set_meta(key, old.get_meta(key))
		vessel.set_meta("turned_profile", true)
		vessel.set_meta("turned_catalogue_size_m", work.size_m)
		old.free()
		changed.append(work.asset)
	room.inventory["vessels_turned"] = {"works": changed, "placement_changed": false, "rear_decoration_verified": false}


static func make(work: Dictionary, texture: Texture2D) -> Node3D:
	var node := Node3D.new()
	var size := Vector3(work.size_m[0], work.size_m[1], work.size_m[2])
	var material := Painting.mat(texture, 1.0) # Geometry owns holes; no alpha-cut photograph on a solid.
	for part in work.profiles:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		# Same ring sweep as build_tureen(); a profile may return down its inside,
		# as dish_asset() does, to build a real open cup/bowl or a hollow stand.
		for j in part.rows.size() - 1:
			for i in SIDES:
				var points: Array = []
				var uvs: Array = []
				for pair in [[j, i], [j + 1, i], [j + 1, i + 1], [j, i + 1]]:
					var row: Array = part.rows[pair[0]]
					var angle: float = TAU * pair[1] / SIDES
					var r: float = row[0]
					if part.has("scallops"):
						r *= 1.0 + part.scallops[0] * cos(angle * part.scallops[1]) * row[1]
					var x: float = part.get("centre", 0.0) + cos(angle) * r
					points.append(Vector3(x * size.x, row[1] * size.y, sin(angle) * r * size.z))
					var image_x: float = part.get("centre", 0.0) + cos(angle) * (row[3] if row.size() > 3 else r)
					uvs.append(Vector2(image_x + .5, row[2] if row.size() > 2 else 1.0 - row[1]))
					if part.has("sample_uv"):
						uvs[-1] = Vector2(part.sample_uv[0], part.sample_uv[1])
				if points[0].is_equal_approx(points[3]) or points[1].is_equal_approx(points[2]):
					# A pole is one triangle, not a quad with a degenerate half.
					var ids := [0, 1, 2] if points[0].is_equal_approx(points[3]) else [0, 2, 3]
					st.set_normal((points[ids[1]] - points[ids[0]]).cross(points[ids[2]] - points[ids[0]]).normalized())
					for k in ids:
						st.set_uv(uvs[k])
						st.add_vertex(points[k])
				else:
					Painting.quad(st, points, uvs)
		add_surface(node, st, material, part.name)
	for part in work.get("tubes", []):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var rings: Array = []
		var coords: Array = []
		var loop: bool = part.get("loop", false)
		for j in part.path.size():
			var p: Array = part.path[j]
			var centre := Vector3(p[0] * size.x, p[1] * size.y, p[2] * size.z)
			var previous: Array = part.path[part.path.size() - 2 if loop and j == 0 else max(0, j - 1)]
			var following: Array = part.path[1 if loop and j == part.path.size() - 1 else min(part.path.size() - 1, j + 1)]
			var tangent := Vector3((following[0] - previous[0]) * size.x, (following[1] - previous[1]) * size.y, (following[2] - previous[2]) * size.z).normalized()
			var across := tangent.cross(Vector3.FORWARD).normalized()
			var back := across.cross(tangent).normalized()
			var radius: float = p[3] * size.x
			for i in 8:
				var a := TAU * i / 8.0
				rings.append(centre + radius * (across * cos(a) + back * sin(a)))
				coords.append(Vector2(p[0] + .5, 1.0 - p[1]))
				if part.has("sample_uv"):
					coords[-1] = Vector2(part.sample_uv[0] + .007 * cos(a), part.sample_uv[1] + .007 * sin(a))
		for j in part.path.size() - 1:
			for i in 8:
				var ids := [j * 8 + i, (j + 1) * 8 + i, (j + 1) * 8 + (i + 1) % 8, j * 8 + (i + 1) % 8]
				Painting.quad(st, ids.map(func(k): return rings[k]), ids.map(func(k): return coords[k]))
		# Solid handles close their ends; the spout may instead end at a smaller
		# returning inner ring, leaving its mouth open.
		if not part.get("open", false) and not loop:
			for end in [0, part.path.size() - 1]:
				for i in range(1, 7):
					var ids := [end * 8, end * 8 + i, end * 8 + i + 1]
					if end != 0:
						ids.reverse()
					st.set_normal((rings[ids[1]] - rings[ids[0]]).cross(rings[ids[2]] - rings[ids[0]]).normalized())
					for k in ids:
						st.set_uv(coords[k])
						st.add_vertex(rings[k])
		add_surface(node, st, material, part.name)
	# Measure the complete assembled object, including handles, against the catalogue.
	# This changes geometry dimensions at the original blob origin, never placement.
	var bounds := AABB()
	var first := true
	for mesh in node.get_children():
		bounds = mesh.mesh.get_aabb() if first else bounds.merge(mesh.mesh.get_aabb())
		first = false
	var fit := size / bounds.size
	for mesh in node.get_children():
		mesh.scale = fit
		mesh.position = Vector3(-(bounds.position.x + bounds.size.x / 2) * fit.x, -bounds.position.y * fit.y, -(bounds.position.z + bounds.size.z / 2) * fit.z)
	return node


static func add_surface(node: Node3D, st: SurfaceTool, material: Material, label: String) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = label
	mesh.mesh = st.commit()
	mesh.material_override = material
	node.add_child(mesh)
