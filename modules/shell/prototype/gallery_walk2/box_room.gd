## PROTOTYPE, throwaway: "Tour Into the Picture" for one still. The still is projected from its own camera
## onto a box (floor, ceiling, two walls, far wall) fitted to the far wall's rectangle in the still, and a
## second camera walks into that box. Near the start the view is exactly the still; walking forward, the
## walls stream past with real perspective. Anything standing in the room (a bench) smears onto the floor.
extends SubViewportContainer

const EYE := 1.0  # camera height; the box's scale is relative to it

var cam: Camera3D
var _mat: ShaderMaterial
var _depth := 1.0
var _l := -1.0
var _r := 1.0
var _top := 2.0

const SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D still : source_color, filter_linear;
uniform float tan_half;
uniform float aspect;
varying vec3 wpos;
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float d = max(-wpos.z, 0.02);
	vec2 uv = vec2(0.5 + wpos.x / (d * 2.0 * tan_half * aspect), 0.5 - (wpos.y - 1.0) / (d * 2.0 * tan_half));
	ALBEDO = texture(still, clamp(uv, vec2(0.001), vec2(0.999))).rgb;
}
"""


func _init() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_DISABLED
	add_child(vp)
	cam = Camera3D.new()
	cam.position = Vector3(0, EYE, 0)
	vp.add_child(cam)
	var sh := Shader.new()
	sh.code = SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	var mi := MeshInstance3D.new()
	mi.name = "Box"
	vp.add_child(mi)


## far: the far wall's rectangle in the still, in 0..1 (x0, y0, x1, y1). fov_deg: the still's vertical field of view.
func set_still(tex: Texture2D, far: Rect2, fov_deg: float) -> void:
	var aspect := tex.get_size().x / tex.get_size().y
	var t := tan(deg_to_rad(fov_deg) / 2.0)
	cam.fov = fov_deg
	cam.position = Vector3(0, EYE, 0)
	_mat.set_shader_parameter("still", tex)
	_mat.set_shader_parameter("tan_half", t)
	_mat.set_shader_parameter("aspect", aspect)
	# the far wall's bottom edge sits on the floor (y = 0), EYE below the camera
	var v_bottom := far.end.y
	_depth = EYE / ((v_bottom - 0.5) * 2.0 * t)
	var l := (far.position.x - 0.5) * 2.0 * t * aspect * _depth
	var r := (far.end.x - 0.5) * 2.0 * t * aspect * _depth
	var top := EYE + (0.5 - far.position.y) * 2.0 * t * _depth
	_l = l
	_r = r
	_top = top
	var z0 := 0.6  # the box starts a little behind the camera
	var z1 := -_depth
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var quad := func(a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
		for v in [a, b, c, a, c, d]:
			st.add_vertex(v)
	quad.call(Vector3(l, 0, z0), Vector3(r, 0, z0), Vector3(r, 0, z1), Vector3(l, 0, z1))  # floor
	quad.call(Vector3(l, top, z0), Vector3(l, top, z1), Vector3(r, top, z1), Vector3(r, top, z0))  # ceiling
	quad.call(Vector3(l, 0, z0), Vector3(l, 0, z1), Vector3(l, top, z1), Vector3(l, top, z0))  # left wall
	quad.call(Vector3(r, 0, z0), Vector3(r, top, z0), Vector3(r, top, z1), Vector3(r, 0, z1))  # right wall
	quad.call(Vector3(l, 0, z1), Vector3(r, 0, z1), Vector3(r, top, z1), Vector3(l, top, z1))  # far wall
	var mi: MeshInstance3D = get_child(0).get_node("Box")
	mi.mesh = st.commit()
	mi.material_override = _mat


## Walk the camera `fraction` of the room's depth forward, with a small step bob.
func walk_to(fraction: float, secs: float) -> Tween:
	var t := create_tween().set_parallel()
	t.tween_property(cam, "position:z", -fraction * _depth, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var bob := create_tween().set_loops(int(secs / 0.5))
	bob.tween_property(cam, "position:y", EYE + 0.015, 0.25).set_trans(Tween.TRANS_SINE)
	bob.tween_property(cam, "position:y", EYE, 0.25).set_trans(Tween.TRANS_SINE)
	return t


## Where a ray from the walking camera meets a side wall (between floor and cornice), or Vector3.INF.
func hit_wall(from: Vector3, dir: Vector3) -> Vector3:
	for x in [_l, _r]:
		if absf(dir.x) < 1e-5:
			continue
		var t: float = (x - from.x) / dir.x
		if t <= 0.0:
			continue
		var p := from + dir * t
		if p.y > 0.05 and p.y < _top and p.z < 0.0 and p.z > -_depth:
			return p
	return Vector3.INF
