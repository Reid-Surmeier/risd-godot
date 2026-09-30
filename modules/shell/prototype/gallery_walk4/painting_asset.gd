## PROTOTYPE (map #116): one real painting as geometry. Local space: x right, y up, z out of the wall (wall at z = 0),
## centred on the canvas. The frame is a 3D nine-slice of its Muse texture: every band keeps its real width
## (band pixels scaled by the canvas's metres per opening pixel), a front face DEPTH off the wall, outer sides back to
## the wall, inner reveals down to the canvas, which sits INSET behind the frame's face.
extends Node3D

const DEPTH := 0.09
const INSET := 0.035

var outer := Vector2.ZERO  # the framed size in metres, for picking

static var _shader: Shader


# The room's PS1 surface shader, lit (paintings cast and receive the skylight's shadows); no affine warp on a canvas.
static func mat(tex: Texture2D, shade := 1.0, cut := false) -> ShaderMaterial:
	if _shader == null:
		_shader = load("res://modules/shell/prototype/gallery_walk4/ps1.gdshader")
	var m := ShaderMaterial.new()
	m.shader = _shader
	m.set_shader_parameter("use_texture", tex != null)
	if tex:
		m.set_shader_parameter("albedo", tex)
	m.set_shader_parameter("tint", Color(shade, shade, shade))
	m.set_shader_parameter("affine", false)
	m.set_shader_parameter("alpha_cut", 0.5 if cut else 0.0)
	return m


static func quad(st: SurfaceTool, p: Array, uv: Array) -> void:
	var n: Vector3 = (p[1] - p[0]).cross(p[3] - p[0]).normalized()
	st.set_normal(n)
	for i in [0, 1, 2, 0, 2, 3]:
		st.set_uv(uv[i])
		st.add_vertex(p[i])


func _mesh(build: Callable, m: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	build.call(st)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = m
	add_child(mi)


## canvas: canvas size in metres. margins: the frame texture's band widths in pixels (left, top, right, bottom).
func build_framed(
	frame_tex: Texture2D, canvas_tex: Texture2D, canvas: Vector2, margins: Array
) -> void:
	var ts := frame_tex.get_size()
	var open_px := Vector2(ts.x - margins[0] - margins[2], ts.y - margins[1] - margins[3])
	var mpp := canvas.y / open_px.y  # metres per texture pixel, from the canvas height
	var l: float = margins[0] * mpp
	var t: float = margins[1] * mpp
	var r: float = margins[2] * mpp
	var b: float = margins[3] * mpp
	var cx := canvas.x / 2.0
	var cy := canvas.y / 2.0
	outer = Vector2(canvas.x + l + r, canvas.y + t + b)
	# x and y cut lines (metres) and matching u, v (0..1, v down)
	var xs := [-cx - l, -cx, cx, cx + r]
	var ys := [cy + t, cy, -cy, -cy - b]
	var us := [0.0, margins[0] / ts.x, 1.0 - margins[2] / ts.x, 1.0]
	var vs := [0.0, margins[1] / ts.y, 1.0 - margins[3] / ts.y, 1.0]
	var z := DEPTH
	_mesh(
		func(st: SurfaceTool) -> void:
			for j in 3:
				for i in 3:
					if i == 1 and j == 1:
						continue
					quad(
						st,
						[
							Vector3(xs[i], ys[j + 1], z),
							Vector3(xs[i + 1], ys[j + 1], z),
							Vector3(xs[i + 1], ys[j], z),
							Vector3(xs[i], ys[j], z)
						],
						[
							Vector2(us[i], vs[j + 1]),
							Vector2(us[i + 1], vs[j + 1]),
							Vector2(us[i + 1], vs[j]),
							Vector2(us[i], vs[j])
						]
					),
		mat(frame_tex, 1.0, true)
	)
	# outer sides: a strip from just inside each outer edge, run back to the wall
	var eu := 12.0 / ts.x
	var ev := 12.0 / ts.y
	var X0: float = xs[0]
	var X1: float = xs[3]
	var Y0: float = ys[3]
	var Y1: float = ys[0]
	_mesh(
		func(st: SurfaceTool) -> void:
			quad(
				st,
				[Vector3(X0, Y1, 0), Vector3(X1, Y1, 0), Vector3(X1, Y1, z), Vector3(X0, Y1, z)],
				[Vector2(0.1, ev), Vector2(0.9, ev), Vector2(0.9, ev * 2), Vector2(0.1, ev * 2)]
			)
			quad(
				st,
				[Vector3(X0, Y0, z), Vector3(X1, Y0, z), Vector3(X1, Y0, 0), Vector3(X0, Y0, 0)],
				[
					Vector2(0.1, 1 - ev * 2),
					Vector2(0.9, 1 - ev * 2),
					Vector2(0.9, 1 - ev),
					Vector2(0.1, 1 - ev)
				]
			)
			quad(
				st,
				[Vector3(X0, Y0, 0), Vector3(X0, Y0, z), Vector3(X0, Y1, z), Vector3(X0, Y1, 0)],
				[Vector2(eu, 0.9), Vector2(eu * 2, 0.9), Vector2(eu * 2, 0.1), Vector2(eu, 0.1)]
			)
			quad(
				st,
				[Vector3(X1, Y0, z), Vector3(X1, Y0, 0), Vector3(X1, Y1, 0), Vector3(X1, Y1, z)],
				[
					Vector2(1 - eu * 2, 0.9),
					Vector2(1 - eu, 0.9),
					Vector2(1 - eu, 0.1),
					Vector2(1 - eu * 2, 0.1)
				]
			),
		mat(frame_tex, 0.6, true)
	)  # cut to the frame: a crest or shaped corner leaves no floating edge
	# inner reveals, from the frame's inner lip down to the canvas
	var zc := DEPTH - INSET
	var u1: float = us[1]
	var u2: float = us[2]
	var v1: float = vs[1]
	var v2: float = vs[2]
	_mesh(
		func(st: SurfaceTool) -> void:
			quad(
				st,
				[
					Vector3(-cx, cy, zc),
					Vector3(cx, cy, zc),
					Vector3(cx, cy, z),
					Vector3(-cx, cy, z)
				],
				[
					Vector2(u1, v1 - ev),
					Vector2(u2, v1 - ev),
					Vector2(u2, v1 - ev * 2),
					Vector2(u1, v1 - ev * 2)
				]
			)
			quad(
				st,
				[
					Vector3(-cx, -cy, z),
					Vector3(cx, -cy, z),
					Vector3(cx, -cy, zc),
					Vector3(-cx, -cy, zc)
				],
				[
					Vector2(u1, v2 + ev * 2),
					Vector2(u2, v2 + ev * 2),
					Vector2(u2, v2 + ev),
					Vector2(u1, v2 + ev)
				]
			)
			quad(
				st,
				[
					Vector3(-cx, -cy, zc),
					Vector3(-cx, -cy, z),
					Vector3(-cx, cy, z),
					Vector3(-cx, cy, zc)
				],
				[
					Vector2(u1 - eu, v2),
					Vector2(u1 - eu * 2, v2),
					Vector2(u1 - eu * 2, v1),
					Vector2(u1 - eu, v1)
				]
			)
			quad(
				st,
				[
					Vector3(cx, -cy, z),
					Vector3(cx, -cy, zc),
					Vector3(cx, cy, zc),
					Vector3(cx, cy, z)
				],
				[
					Vector2(u2 + eu * 2, v2),
					Vector2(u2 + eu, v2),
					Vector2(u2 + eu, v1),
					Vector2(u2 + eu * 2, v1)
				]
			),
		mat(frame_tex, 0.45)
	)
	_mesh(
		func(st: SurfaceTool) -> void:
			quad(
				st,
				[
					Vector3(-cx, -cy, zc),
					Vector3(cx, -cy, zc),
					Vector3(cx, cy, zc),
					Vector3(-cx, cy, zc)
				],
				[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
			),
		mat(canvas_tex)
	)


## A shaped work: a closed slab following its real outline (points in 0..1 of the texture, y down): a triangulated
## front face textured with its keyed Muse cut-out, and continuous side faces back to the wall.
func build_shaped(tex: Texture2D, size: Vector2, outline: Array, edge_color: Color) -> void:
	outer = size
	var d := 0.05
	var pts := PackedVector2Array()
	var uvs: Array = []
	for q in outline:
		pts.append(Vector2((q[0] - 0.5) * size.x, (0.5 - q[1]) * size.y))
		uvs.append(Vector2(q[0], q[1]))
	var tris := Geometry2D.triangulate_polygon(pts)
	_mesh(
		func(st: SurfaceTool) -> void:
			st.set_normal(Vector3.BACK)
			for i in tris:
				st.set_uv(uvs[i])
				st.add_vertex(Vector3(pts[i].x, pts[i].y, d)),
		mat(tex)
	)
	var edge := mat(null)  # the gilt edge's own colour: the texture's outline pixels would sample the keyed matte
	edge.set_shader_parameter("tint", edge_color * Color(0.7, 0.7, 0.7))
	_mesh(
		func(st: SurfaceTool) -> void:
			for i in pts.size():
				var j := (i + 1) % pts.size()
				var a := pts[i]
				var b := pts[j]
				quad(
					st,
					[
						Vector3(a.x, a.y, 0),
						Vector3(b.x, b.y, 0),
						Vector3(b.x, b.y, d),
						Vector3(a.x, a.y, d)
					],
					[uvs[i], uvs[j], uvs[j], uvs[i]]
				),
		edge
	)
