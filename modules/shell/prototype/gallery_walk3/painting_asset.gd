## PROTOTYPE (map #116, "the Painting Asset recipe on three paintings"): one real painting built as geometry.
## Local space: x right, y up, z out of the wall; the wall is z = 0 and the asset is centred on the origin.
## Framed: the Muse empty-frame texture (opening keyed transparent) on the front at z = DEPTH, outer and inner
## side faces taking the frame's own edge colours (shaded), and the Muse canvas inset INSET behind the face.
## Shaped: one keyed cut-out (the canvas with its gilt edge) standing EDGE off the wall with a darker back copy.
extends Node3D

const DEPTH := 0.09
const INSET := 0.03
const EDGE := 0.04
const WALL_PATCH := Color("#535b63")


static func _mat(tex: Texture2D, shade := 1.0, scissor := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.albedo_texture = tex
	m.albedo_color = Color(shade, shade, shade)
	if scissor:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		m.alpha_scissor_threshold = 0.5
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


# A quad from four corners (counter-clockwise from bottom-left) with matching UVs.
static func _quad(st: SurfaceTool, p: Array, uv: Array) -> void:
	for i in [0, 1, 2, 0, 2, 3]:
		st.set_uv(uv[i])
		st.add_vertex(p[i])


func _mesh(build: Callable, mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	build.call(st)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	add_child(mi)


## size: the framed painting's outer size in metres. opening: the frame texture's opening as fractions (x0, y0, x1, y1, image y down).
func build_framed(frame_tex: Texture2D, canvas_tex: Texture2D, size: Vector2, opening: Array) -> void:
	var w := size.x / 2.0
	var h := size.y / 2.0
	var ox0: float = -w + opening[0] * size.x
	var ox1: float = -w + opening[2] * size.x
	var oy1: float = h - opening[1] * size.y  # top of the opening
	var oy0: float = h - opening[3] * size.y  # bottom
	_wall_patch(size)
	# the front face: the whole frame texture, its opening cut away
	_mesh(func(st: SurfaceTool) -> void:
		_quad(st, [Vector3(-w, -h, DEPTH), Vector3(w, -h, DEPTH), Vector3(w, h, DEPTH), Vector3(-w, h, DEPTH)],
			[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]), _mat(frame_tex, 1.0, true))
	# outer sides: a thin strip of the frame's outer edge, stretched back to the wall
	var e := 0.035  # sample the side colour from inside the outer band, clear of any keyed fringe
	_mesh(func(st: SurfaceTool) -> void:
		_quad(st, [Vector3(-w, h, 0), Vector3(w, h, 0), Vector3(w, h, DEPTH), Vector3(-w, h, DEPTH)],
			[Vector2(0, 0), Vector2(1, 0), Vector2(1, e), Vector2(0, e)])  # top
		_quad(st, [Vector3(-w, -h, DEPTH), Vector3(w, -h, DEPTH), Vector3(w, -h, 0), Vector3(-w, -h, 0)],
			[Vector2(0, 1 - e), Vector2(1, 1 - e), Vector2(1, 1), Vector2(0, 1)])  # bottom
		_quad(st, [Vector3(-w, -h, 0), Vector3(-w, -h, DEPTH), Vector3(-w, h, DEPTH), Vector3(-w, h, 0)],
			[Vector2(0, 1), Vector2(e, 1), Vector2(e, 0), Vector2(0, 0)])  # left
		_quad(st, [Vector3(w, -h, DEPTH), Vector3(w, -h, 0), Vector3(w, h, 0), Vector3(w, h, DEPTH)],
			[Vector2(1 - e, 1), Vector2(1, 1), Vector2(1, 0), Vector2(1 - e, 0)]), _mat(frame_tex, 0.62))  # right
	# inner sides: from the opening's lip down to the canvas
	var zc := DEPTH - INSET
	var u0: float = opening[0]
	var u1: float = opening[2]
	var v0: float = opening[1]
	var v1: float = opening[3]
	_mesh(func(st: SurfaceTool) -> void:
		_quad(st, [Vector3(ox0, oy1, zc), Vector3(ox1, oy1, zc), Vector3(ox1, oy1, DEPTH), Vector3(ox0, oy1, DEPTH)],
			[Vector2(u0, v0 - e), Vector2(u1, v0 - e), Vector2(u1, v0 - e * 2), Vector2(u0, v0 - e * 2)])
		_quad(st, [Vector3(ox0, oy0, DEPTH), Vector3(ox1, oy0, DEPTH), Vector3(ox1, oy0, zc), Vector3(ox0, oy0, zc)],
			[Vector2(u0, v1 + e * 2), Vector2(u1, v1 + e * 2), Vector2(u1, v1 + e), Vector2(u0, v1 + e)])
		_quad(st, [Vector3(ox0, oy0, zc), Vector3(ox0, oy0, DEPTH), Vector3(ox0, oy1, DEPTH), Vector3(ox0, oy1, zc)],
			[Vector2(u0 - e, v1), Vector2(u0 - e * 2, v1), Vector2(u0 - e * 2, v0), Vector2(u0 - e, v0)])
		_quad(st, [Vector3(ox1, oy0, DEPTH), Vector3(ox1, oy0, zc), Vector3(ox1, oy1, zc), Vector3(ox1, oy1, DEPTH)],
			[Vector2(u1 + e * 2, v1), Vector2(u1 + e, v1), Vector2(u1 + e, v0), Vector2(u1 + e * 2, v0)]), _mat(frame_tex, 0.48))
	# the canvas, inset
	_mesh(func(st: SurfaceTool) -> void:
		_quad(st, [Vector3(ox0, oy0, zc), Vector3(ox1, oy0, zc), Vector3(ox1, oy1, zc), Vector3(ox0, oy1, zc)],
			[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]), _mat(canvas_tex))


## A shaped work: one keyed texture (transparent outside the outline) standing EDGE off the wall.
func build_shaped(tex: Texture2D, size: Vector2) -> void:
	var w := size.x / 2.0
	var h := size.y / 2.0
	_wall_patch(size)
	for z in [EDGE, EDGE * 0.35, 0.004]:  # front, a darker body behind it, and a dark back: reads as a slab
		var shade := 1.0 if z == EDGE else 0.4
		_mesh(func(st: SurfaceTool) -> void:
			_quad(st, [Vector3(-w, -h, z), Vector3(w, -h, z), Vector3(w, h, z), Vector3(-w, h, z)],
				[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]), _mat(tex, shade, true))


# Plain wall over the flat photo of this painting in the wall strip, so it is not seen twice.
func _wall_patch(size: Vector2) -> void:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = WALL_PATCH
	var pad := Vector2(0.18, 0.18)
	_mesh(func(st: SurfaceTool) -> void:
		var w := size.x / 2.0 + pad.x
		var h := size.y / 2.0 + pad.y
		_quad(st, [Vector3(-w, -h, 0.003), Vector3(w, -h, 0.003), Vector3(w, h, 0.003), Vector3(-w, h, 0.003)],
			[Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]), m)
