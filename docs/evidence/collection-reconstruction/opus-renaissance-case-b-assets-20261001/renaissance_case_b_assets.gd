## Five objects from the Renaissance room's east wall case B, IMG_6383 55.6..57.0s, as closed low polygon solids that carry
## the official RISD photographs: Bella Donna Plates 46.391 (API 1494506) and 57.302 (1264011), Death of the Virgin roundel
## 51.105 (1228756), the glass roundel The Virgin as the Woman of the Apocalypse 2017.29 (1442936), and the probable enamel
## plaque Virgin and Child with Clerics and Donors 34.024 (1246991).
## The catalogue fixes each diameter, and the plaque's height and width. Every depth and profile is provisional.
## Painted and worked surfaces are the photographs' own pixels (textures/, sources.json); nothing is repainted or generated.
## Study prototypes only: no mount, no case, no placement. Belongs in modules/shell/prototype/collection_reconstruction/,
## beside seated_woman_asset.gd and medieval_metal_assets.gd; every preload is relative to that folder.
extends RefCounted

const Base := preload("seated_woman_asset.gd")
const Metal := preload("medieval_metal_assets.gd")
const Painting := preload("../gallery_walk4/painting_asset.gd")

const CM := .01
const SIDES := 24
const TEXTURES := "res://assets/renaissance-case-b/"
# Nothing here is accepted. Every built node carries each of these as false.
const FLAGS := ["rear_accepted", "thickness_accepted", "mount_accepted", "placement_accepted", "fine_fidelity_accepted", "whole_room_accepted"]
# A photograph is laid only on faces within 60 degrees of facing it; steeper faces take the plain colour, so no texel is smeared down an edge.
const WEDGE := .5
# Study shade for the plain faces, baked into vertex colour: the room shader is unlit. Not a lighting claim.
const LIGHT := Vector3(-.35, .6, .72)

# `size` is the catalogue's width and height in metres. `depth` is this study's guess. `body` is the median rim pixel of a photograph.
# `front` / `rear` map a photograph onto the solid: the object's outline in texture pixels, as an ellipse or four corners (sources.json).
# An object without `rear` has no photograph of its back: that side is a plain closing surface, not observed form.
const OBJECTS := {
	"plate_46391": {"accession": "46.391", "catalogue_id": "1494506", "identity": "matched", "title": "Bella Donna Plate", "size": Vector2(.225, .225), "depth": .04,
		"source_position": "back panel, upper left", "body": Color("d29734"),
		"front": {"texture": "plate-46391-front.png", "px": Vector2(1052, 1037), "centre": Vector2(525.2, 518.4), "radii": Vector2(518.2, 510.6)}},
	"plate_57302": {"accession": "57.302", "catalogue_id": "1264011", "identity": "matched", "title": "Bella Donna Plate", "size": Vector2(.232, .232), "depth": .034,
		"source_position": "back panel, upper right", "body": Color("b3b1af"),
		"front": {"texture": "plate-57302-front.png", "px": Vector2(977, 984), "centre": Vector2(487.6, 491.5), "radii": Vector2(480.6, 484.5)},
		"rear": {"texture": "plate-57302-rear.png", "px": Vector2(940, 933), "centre": Vector2(469.6, 466.4), "radii": Vector2(461.7, 458.6)}},
	"roundel_51105": {"accession": "51.105", "catalogue_id": "1228756", "identity": "matched", "title": "Death of the Virgin", "size": Vector2(.111, .111), "depth": .008,
		"source_position": "deck, lower left", "body": Color("8a6c4f"),
		"front": {"texture": "roundel-51105-front.png", "px": Vector2(1163, 1171), "centre": Vector2(581.1, 584.8), "radii": Vector2(573.6, 577.3)},
		"rear": {"texture": "roundel-51105-rear.png", "px": Vector2(1161, 1173), "centre": Vector2(579.7, 586.0), "radii": Vector2(572.3, 578.3)}},
	# Real glass: the photographs multiply whatever stands behind the panes. The lead rim and wire loop are opaque.
	"glass_201729": {"accession": "2017.29", "catalogue_id": "1442936", "identity": "matched", "title": "The Virgin as the Woman of the Apocalypse", "size": Vector2(.19, .19), "depth": .007,
		"source_position": "deck, lower centre", "body": Color("3b3636"), "glass": true, "skin_within": .96,
		"front": {"texture": "glass-201729-front.png", "px": Vector2(1070, 1052), "centre": Vector2(534.6, 525.6), "radii": Vector2(527.0, 517.9)},
		"rear": {"texture": "glass-201729-rear.png", "px": Vector2(1069, 1052), "centre": Vector2(534.0, 525.8), "radii": Vector2(526.8, 518.1)}},
	# Probable only: matched on form and colour, its label is not legible in the video.
	"plaque_34024": {"accession": "34.024", "catalogue_id": "1246991", "identity": "probable", "title": "Virgin and Child with Clerics and Donors", "size": Vector2(.107, .129), "depth": .0048,
		"source_position": "deck, lower right", "body": Color("5a5a68"),
		"front": {"texture": "plaque-34024-front.png", "px": Vector2(985, 1171), "corners": [Vector2(8, 13), Vector2(976, 8), Vector2(967, 1162), Vector2(26, 1160)]}},
}

## Object-local metres: origin at the centre of the rearmost plane, +Z the front, +Y the artwork's top.
## Each entry is [name, closed shell]. "main" is the object and carries the photographs; anything else is hardware outside the catalogue size.
static func parts(key: String) -> Array:
	var circle := Metal.ngon(SIDES)
	match key:
		# Shallow footed bowl. Rows are [z cm, radius cm], from the recess inside the foot ring round the outside, over the lip, down to the well.
		"plate_46391":
			return [["main", Metal.plate(circle, Vector2.ZERO, [[.35, 3.9], [0, 4.1], [0, 4.7], [.5, 4.9], [1.6, 8.2], [3, 10.6],
				[3.8, 11.25], [4, 11.05], [3.2, 9.9], [2, 7.6], [1.2, 4.6], [1, 2.5]])]]
		# Broad sloping rim round a small deep well. Foot ring 5.2 cm and its recess 3.7 cm read from the rear photograph.
		"plate_57302":
			return [["main", Metal.plate(circle, Vector2.ZERO, [[.45, 3.6], [0, 3.8], [0, 5.2], [1.5, 5.3], [3, 11.3],
				[3.25, 11.6], [3.4, 11.4], [2.75, 6], [1.5, 4.9], [1.4, 2.5]])]]
		# Flat back, plain edge, scroll border, raised moulding, then the field as one broad low dome for the relief.
		"roundel_51105":
			return [["main", Metal.plate(circle, Vector2.ZERO, [[0, 5.55], [.45, 5.55], [.55, 5.4], [.55, 4.75], [.7, 4.6], [.7, 4.45], [.45, 4.25], [.8, 1.3]])]]
		# 3 mm pane inside a 7 mm lead rim that stands proud on both sides, and the wire loop soldered to the top.
		"glass_201729":
			var out := [["main", Metal.plate(circle, Vector2.ZERO, [[.2, 9.07], [0, 9.07], [0, 9.5], [.7, 9.5], [.7, 9.07], [.5, 9.07]])]]
			var eye := Vector3(0, 10.25, .35)
			out.append(["loop stem", Base.limb([[Vector3(0, 9.4, .35) * CM, .06 * CM, .06 * CM], [Vector3(0, 9.95, .35) * CM, .06 * CM, .06 * CM]], 4)])
			for k in 6:
				var a := eye + Vector3(cos(TAU * k / 6), sin(TAU * k / 6), 0) * .3
				var b := eye + Vector3(cos(TAU * (k + 1) / 6), sin(TAU * (k + 1) / 6), 0) * .3
				out.append(["loop %d" % k, Base.limb([[a * CM, .06 * CM, .06 * CM], [b * CM, .06 * CM, .06 * CM]], 4)])
			return out
		# Copper plaque, corners cut 2 mm, pillowed 2.3 mm toward the centre.
		"plaque_34024":
			var w := 5.35
			var h := 6.45
			var c := .2
			var outline := PackedVector2Array([Vector2(w, -h + c), Vector2(w, h - c), Vector2(w - c, h), Vector2(-w + c, h),
				Vector2(-w, h - c), Vector2(-w, -h + c), Vector2(-w + c, -h), Vector2(w - c, -h)])
			return [["main", Metal.plate(outline, Vector2.ZERO, [[0, 1], [.25, 1], [.4, .9], [.48, .5]])]]
	return []

## Where a photograph's `spec` shows the object-local point `p`. `half` is half the catalogue size; `mirror` for a view from behind.
static func uv(spec: Dictionary, half: Vector2, p: Vector3, mirror := false) -> Vector2:
	var q := Vector2(-p.x if mirror else p.x, -p.y) / half
	if spec.has("corners"):
		var c: Array = spec.corners
		return c[0].lerp(c[1], (q.x + 1) / 2).lerp(c[3].lerp(c[2], (q.x + 1) / 2), (q.y + 1) / 2) / spec.px
	return (spec.centre + q * spec.radii) / spec.px

## Which mesh a triangle belongs to: "front" or "rear" when a photograph covers it squarely, otherwise "body".
static func side(object: Dictionary, part: String, a: Vector3, b: Vector3, c: Vector3) -> String:
	var normal := (c - a).cross(b - a).normalized()
	var mid := (a + b + c) / 3
	if part != "main" or abs(normal.z) <= WEDGE or Vector2(mid.x, mid.y).length() > object.get("skin_within", INF) * object.size.x / 2:
		return "body"
	var face := "front" if normal.z > 0 else "rear"
	return face if object.has(face) else "body"

## An imported texture where the project has one, otherwise the PNG read straight from disk.
static func texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	var image := Image.new()
	image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)

static func material(object: Dictionary, face: String, dir: String) -> Material:
	if face == "body":
		var plain: ShaderMaterial = Painting.mat(null)
		plain.set_shader_parameter("tint", object.body)
		plain.set_shader_parameter("use_vertex_color", true)
		return plain
	var photo := texture(dir + object[face].texture)
	if not object.get("glass", false):
		return Painting.mat(photo)
	# Stained glass filters the light behind it. Alpha transparency keeps it out of the room bake, like the acrylic hoods.
	var pane := StandardMaterial3D.new()
	pane.albedo_texture = photo
	pane.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pane.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pane.blend_mode = BaseMaterial3D.BLEND_MODE_MUL
	return pane

## One artwork as a node: a mesh named "front", "rear" (only where a rear photograph exists) and "body".
## `dir` holds the textures named in OBJECTS. The node has no collision and no mount.
static func build(key: String, dir := TEXTURES) -> Node3D:
	var object: Dictionary = OBJECTS[key]
	var tools := {}
	for part in parts(key):
		var s: PackedVector3Array = part[1]
		for i in range(0, s.size(), 3):
			var face := side(object, part[0], s[i], s[i + 1], s[i + 2])
			if not tools.has(face):
				tools[face] = SurfaceTool.new()
				tools[face].begin(Mesh.PRIMITIVE_TRIANGLES)
			var normal := (s[i + 2] - s[i]).cross(s[i + 1] - s[i]).normalized()
			tools[face].set_normal(normal)
			tools[face].set_color(Color.WHITE * (.78 + .22 * normal.dot(LIGHT.normalized())))
			for j in 3:
				if face != "body":
					tools[face].set_uv(uv(object[face], object.size / 2, s[i + j], face == "rear"))
				tools[face].add_vertex(s[i + j])
	var node := Node3D.new()
	node.name = key.to_pascal_case()
	for face in tools:
		var visual := MeshInstance3D.new()
		visual.name = face
		visual.mesh = tools[face].commit()
		visual.material_override = material(object, face, dir)
		node.add_child(visual)
	for field in ["accession", "catalogue_id", "identity", "title", "size", "source_position"]:
		node.set_meta("catalogue_" + field if field != "source_position" else field, object[field])
	node.set_meta("depth_provisional", object.depth)
	node.set_meta("source_rear_observed", object.has("rear"))
	for flag in FLAGS:
		node.set_meta(flag, false)
	return node
