## Three works from the Renaissance room's south and west walls, IMG_6383 6.1 / 11.5 / 15.1 s, as closed solids that carry the
## official RISD photographs: Velvet Cover 23.307X (API 1202276) on its white mount board, The Woodcutters 29.280 (1201986), and
## Madonna and Child with Saint Barbara and Saint Catherine 58.196 (1591076) in its dark moulded frame.
## The catalogue fixes the velvet's length, and the height and width of the other two. Every depth is provisional.
## Painted and woven surfaces are the photographs' own pixels (textures/, sources.json); nothing is repainted or generated.
## The velvet's back is the museum's own photograph of it. The other two backs were never photographed: each is one plain colour.
## The frame's faces are strips of the video itself.
## Study prototypes only: no acrylic hood, no label, no placement. Belongs in modules/shell/prototype/collection_reconstruction/,
## beside seated_woman_asset.gd; every preload is relative to that folder.
extends RefCounted

const Base := preload("seated_woman_asset.gd")
const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")

const TEXTURES := "res://modules/shell/collection_rooms/assets/renaissance-wall/"
# Nothing here is accepted. Every built node carries each of these as false.
const FLAGS := ["rear_accepted", "thickness_accepted", "mount_accepted", "frame_accepted", "placement_accepted", "fine_fidelity_accepted", "metric_accepted",
	"dimension_conflict_resolved", "whole_room_accepted"]
# A photograph is laid only on faces within 60 degrees of facing it.
const WEDGE := .5
# Study shade for the plain faces, baked into vertex colour: the room shader is unlit. Not a lighting claim.
const LIGHT := Vector3(-.35, .6, .72)
const NEUTRAL := Color("8c8780") # every surface no source shows

# `size` is the catalogue's width and height in metres; the velvet's width is not catalogued and comes from geometry.json.
# `depth` is this study's guess. Outlines, scales and colours read from the sources are in textures/geometry.json (prep.py).
# `conflicts` are the places where catalogue, photograph and video disagree or fall silent; each node carries them, unresolved.
const OBJECTS := {
	"velvet_23307x": {"accession": "23.307X", "catalogue_id": "1202276", "title": "Velvet Cover", "catalogue_dimensions": "127 cm (50 inches) (length)",
		"size": Vector2(0, 1.27), "depth": .003, "source_position": "south wall, east half, on a white board under an acrylic hood",
		"conflicts": ["width is not catalogued: 0.500 m is the photograph's proportion; two weak video fits against the tapestry gave 0.48 and 0.53 m",
			"the catalogue length is read as including both fringes: the same fits gave 1.27 and 1.34 m overall, against 1.46 m if it meant the velvet alone"]},
	"woodcutters_29280": {"accession": "29.280", "catalogue_id": "1201986", "title": "The Woodcutters", "catalogue_dimensions": "152.4 x 94 cm (60 x 37 inches)",
		"size": Vector2(.94, 1.524), "depth": .005, "source_position": "south wall, west half, hung bare on the wall",
		"conflicts": ["the photograph is 0.6207 wide for its height, the catalogue 0.6168: it is stretched 0.6 percent taller to the catalogue size"]},
	"madonna_58196": {"accession": "58.196", "catalogue_id": "1591076", "title": "Madonna and Child with Saint Barbara and Saint Catherine",
		"catalogue_dimensions": "91.4 x 87 cm (36 x 34 1/4 inches)", "size": Vector2(.87, .914), "depth": .010, "source_position": "west wall, south end, framed",
		"conflicts": ["the studio photograph is 0.9403 wide for its height, the catalogue 0.9519: it keeps its proportion at the catalogue height and leaves 5 mm of panel bare each side, behind the frame",
			"the video shows the photograph covering about 97.7 percent of the frame's opening each way, so the painted image here may be about 2 percent large",
			"frame size is not catalogued: the 7.7 cm band is the mean of four video readings from 7.3 to 8.2 cm"]},
}
const MOUNT_DEPTH := .02 # the velvet's board; its thickness is not visible in the video
# The frame's section, read by eye from the video's shading: [metres in from the outer edge, front height above the wall].
# Raised outer moulding, flat frieze, a small bead, then a slope down to the sight edge. Widths are measured (geometry.json); heights are guesses.
const FRAME_SECTION := [[0, .040], [.010, .055], [.030, .042], [.059, .042], [.065, .047], [.077, .030]]
const FRAME_LAP := .004 # how far the sight edge covers the photograph on every side
const PANEL_FROM_WALL := .012 # the panel's back stands this far off the wall, inside the frame
const FRAME_SIDES := ["bottom", "right", "top", "left"]

static func geometry(dir := TEXTURES) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(dir + "geometry.json"))

## A flat closed slab with the given outline (metres), from z0 at the back to z1 at the front.
static func prism(outline: PackedVector2Array, z0: float, z1: float) -> PackedVector3Array:
	var ring := outline.duplicate()
	if Geometry2D.is_polygon_clockwise(ring):
		ring.reverse()
	var out := PackedVector3Array()
	var caps := Geometry2D.triangulate_polygon(ring)
	for i in range(0, caps.size(), 3):
		var a := ring[caps[i]]
		var b := ring[caps[i + 1]]
		var c := ring[caps[i + 2]]
		if (b - a).cross(c - a) < 0:
			var swap := b
			b = c
			c = swap
		out.append_array([Vector3(a.x, a.y, z1), Vector3(c.x, c.y, z1), Vector3(b.x, b.y, z1), Vector3(a.x, a.y, z0), Vector3(b.x, b.y, z0), Vector3(c.x, c.y, z0)])
	for i in ring.size():
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		out.append_array([Vector3(a.x, a.y, z0), Vector3(b.x, b.y, z1), Vector3(b.x, b.y, z0), Vector3(a.x, a.y, z0), Vector3(a.x, a.y, z1), Vector3(b.x, b.y, z1)])
	return out

## Base.shell with its faces turned outward whichever way the rings were listed.
static func solid(rings: Array) -> PackedVector3Array:
	var s := Base.shell(rings)
	var volume := 0.0
	for i in range(0, s.size(), 3):
		volume += s[i].dot(s[i + 2].cross(s[i + 1]))
	if volume > 0:
		return s
	for ring in rings:
		ring.reverse()
	return Base.shell(rings)

## Half the frame's sight opening and half its outer size, metres.
static func frame_extent(g: Dictionary) -> Array:
	var sight := Vector2(g.photo_m[0], g.photo_m[1]) / 2 - Vector2(FRAME_LAP, FRAME_LAP)
	var band: float = FRAME_SECTION[-1][0]
	return [sight, sight + Vector2(band, band)]

## One frame member's start corner, the direction it runs and the direction into the picture. Members run anticlockwise seen from the front.
static func frame_member(g: Dictionary, k: int) -> Array:
	var outer: Vector2 = frame_extent(g)[1]
	var corners := [Vector2(-outer.x, -outer.y), Vector2(outer.x, -outer.y), Vector2(outer.x, outer.y), Vector2(-outer.x, outer.y)]
	var along: Vector2 = (corners[(k + 1) % 4] - corners[k]).normalized()
	return [corners[k], corners[(k + 1) % 4], along, Vector2(-along.y, along.x)]

## Object-local metres: origin at the centre of the artwork's back, +Z the front, +Y the artwork's top.
## Each entry is [name, closed shell]. Names beginning "main" are the artwork at its catalogue size; the rest is hardware around it.
static func parts(key: String, g: Dictionary) -> Array:
	var depth: float = OBJECTS[key].depth
	if g.has("outline_px"):
		var outline := PackedVector2Array()
		for p in g.outline_px:
			outline.append(Vector2((p[0] - g.origin_px[0]) * g.m_per_px[0], (g.origin_px[1] - p[1]) * g.m_per_px[1]))
		var out := [["main", prism(outline, 0, depth)]]
		if g.has("mount"):
			var c := Vector2(g.mount.centre_m[0], g.mount.centre_m[1])
			var half := Vector2(g.mount.size_m[0], g.mount.size_m[1]) / 2
			out.append(["mount", Base.box(Vector3(c.x - half.x, c.y - half.y, -MOUNT_DEPTH), Vector3(c.x + half.x, c.y + half.y, 0))])
		return out
	# The panel: the photographed width, and a strip either side that the studio photograph does not reach.
	var size: Vector2 = OBJECTS[key].size / 2
	var seen: float = g.photo_m[0] / 2
	var out := [["main", Base.box(Vector3(-seen, -size.y, 0), Vector3(seen, size.y, depth))],
		["main left margin", Base.box(Vector3(-size.x, -size.y, 0), Vector3(-seen, size.y, depth))],
		["main right margin", Base.box(Vector3(seen, -size.y, 0), Vector3(size.x, size.y, depth))]]
	# Four mitred members, each a run of four-sided solids along the section. The panel's edges sit inside them; no rebate is cut.
	for k in 4:
		var m := frame_member(g, k)
		for j in FRAME_SECTION.size() - 1:
			var rings := []
			for end in [[m[0], m[2]], [m[1], -m[2]]]:
				var ring := PackedVector3Array()
				for q in [[FRAME_SECTION[j][0], 0.0], [FRAME_SECTION[j + 1][0], 0.0], [FRAME_SECTION[j + 1][0], FRAME_SECTION[j + 1][1]], [FRAME_SECTION[j][0], FRAME_SECTION[j][1]]]:
					var p: Vector2 = end[0] + (end[1] + m[3]) * q[0]
					ring.append(Vector3(p.x, p.y, q[1] - PANEL_FROM_WALL))
				rings.append(ring)
			out.append(["frame " + FRAME_SIDES[k], solid(rings)])
	return out

## Where the photograph shows the object-local point `p`. A photograph of the back is seen from behind, so it runs the other way across.
static func uv(g: Dictionary, p: Vector3, behind := false) -> Vector2:
	return (Vector2(g.origin_px[0], g.origin_px[1]) + Vector2((-p.x if behind else p.x) / g.m_per_px[0], -p.y / g.m_per_px[1])) / Vector2(g.px[0], g.px[1])

## Where frame member `k`'s video strip shows `p`: x along the member, y from the sight edge (0) out to the outer edge (1).
static func frame_uv(g: Dictionary, k: int, p: Vector3) -> Vector2:
	var m := frame_member(g, k)
	var q: Vector2 = Vector2(p.x, p.y) - m[0]
	return Vector2(q.dot(m[2]) / m[0].distance_to(m[1]), 1 - q.dot(m[3]) / FRAME_SECTION[-1][0])

## Which mesh a triangle belongs to. "front" carries the photograph, "frame <side>" a video strip; everything else is plain.
static func side(g: Dictionary, part: String, a: Vector3, b: Vector3, c: Vector3) -> String:
	var normal := (c - a).cross(b - a).normalized()
	if not part.begins_with("main"):
		if normal.z < -WEDGE:
			return "hardware rear"
		if part.begins_with("frame"):
			return part if normal.z > WEDGE else "frame edge"
		return part
	if normal.z < -WEDGE:
		return "rear"
	return "front" if part == "main" and normal.z > WEDGE else "edge"

## An imported texture where the project has one, otherwise the PNG read straight from disk.
static func texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	var image := Image.new()
	image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)

static func plain(colour: Color) -> ShaderMaterial:
	var m: ShaderMaterial = Painting.mat(null)
	m.set_shader_parameter("tint", colour)
	m.set_shader_parameter("use_vertex_color", true)
	return m

static func material(g: Dictionary, face: String, dir: String) -> Material:
	match face:
		"front":
			return Painting.mat(texture(dir + g.texture), 1.0, g.has("outline_px"))
		"rear":
			if g.has("rear"):
				return Painting.mat(texture(dir + g.rear.texture), 1.0, true)
			if not g.has("outline_texture"):
				return plain(NEUTRAL)
			# The textile's own outline, cut from a white mask and tinted: the shape is the source's, the surface is not observed.
			var back: ShaderMaterial = Painting.mat(texture(dir + g.outline_texture), 1.0, true)
			back.set_shader_parameter("tint", NEUTRAL)
			return back
		"hardware rear":
			return plain(NEUTRAL)
		"edge":
			return plain(Color(g.edge_colour) if g.has("edge_colour") else NEUTRAL)
		"mount":
			return plain(Color(g.mount.colour))
		"frame edge":
			return plain(Color(g.frame.side_colour.left)) # the member least washed out by the track lights
	return Painting.mat(texture(dir + "frame-58196-%s.png" % face.trim_prefix("frame ")))

## One artwork as a node: meshes "front", "rear" and "edge", then "mount" for the velvet or "frame <side>" and "frame edge" for the painting,
## and "hardware rear" for the back of either.
## `dir` holds the textures and geometry.json. The node has no collision; free a hardware mesh to place the artwork without it.
static func build(key: String, dir := TEXTURES) -> Node3D:
	var object: Dictionary = OBJECTS[key]
	var g: Dictionary = geometry(dir)[key]
	var tools := {}
	for part in parts(key, g):
		var s: PackedVector3Array = part[1]
		for i in range(0, s.size(), 3):
			var face := side(g, part[0], s[i], s[i + 1], s[i + 2])
			if not tools.has(face):
				tools[face] = SurfaceTool.new()
				tools[face].begin(Mesh.PRIMITIVE_TRIANGLES)
			var normal := (s[i + 2] - s[i]).cross(s[i + 1] - s[i]).normalized()
			tools[face].set_normal(normal)
			tools[face].set_color(Color.WHITE * (.78 + .22 * normal.dot(LIGHT.normalized())))
			for j in 3:
				if face == "rear" and g.has("rear"):
					tools[face].set_uv(uv(g.rear, s[i + j], true))
				elif face in ["front", "rear"]:
					tools[face].set_uv(uv(g, s[i + j]))
				elif face.begins_with("frame ") and face != "frame edge":
					tools[face].set_uv(frame_uv(g, FRAME_SIDES.find(face.trim_prefix("frame ")), s[i + j]))
				tools[face].add_vertex(s[i + j])
	var node := Node3D.new()
	node.name = key.to_pascal_case()
	for face in tools:
		var visual := MeshInstance3D.new()
		visual.name = face
		visual.mesh = tools[face].commit()
		visual.material_override = material(g, face, dir)
		node.add_child(visual)
	for field in ["accession", "catalogue_id", "title", "catalogue_dimensions"]:
		node.set_meta(field if field.begins_with("catalogue") else "catalogue_" + field, object[field])
	node.set_meta("size", Vector2(g.size_m[0], g.size_m[1]))
	node.set_meta("width_from_catalogue", object.size.x > 0)
	node.set_meta("depth_provisional", object.depth)
	node.set_meta("source_position", object.source_position)
	node.set_meta("source_rear_observed", g.has("rear"))
	node.set_meta("dimension_conflicts", object.conflicts)
	# How far behind the origin the wall is: the board's or the frame's back.
	node.set_meta("wall_behind_origin", MOUNT_DEPTH if g.has("mount") else PANEL_FROM_WALL if g.has("frame") else 0.0)
	for flag in FLAGS:
		node.set_meta(flag, false)
	return node
