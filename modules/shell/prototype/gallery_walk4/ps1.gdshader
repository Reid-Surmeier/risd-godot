// PROTOTYPE (map #116): the room's surface shader. A Godot 4 port of Mighty Duke's "PS1 Shader" (CC0,
// https://godotshaders.com/shader/ps1-shader/): vertex snapping to a coarse screen grid and affine
// (non-perspective) texture mapping, kept subtle. Changed from the original: per-pixel lambert-wrap light so
// the room receives cast shadows (vertex lighting drops them), NORMAL transformed as the page's comments
// suggest, vertex colour as baked occlusion, and anti-aliased plank seams for the herringbone floor.
shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap, specular_disabled, cull_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool use_texture = true;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec2 uv_scale = vec2(1.0);
uniform bool use_vertex_color = false;
uniform float jitter : hint_range(0.0, 1.0) = 0.35;
uniform bool affine = true;
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.0;
uniform float glow = 0.0;  // self-lit share: the lit views beyond the doors
uniform bool plank_seams = false;  // UV2 carries the position inside a plank, in metres
uniform vec2 plank = vec2(0.66, 0.11);

varying vec3 aff_uv;  // (uv * w, w): divided per pixel, this interpolates uv linearly in screen space

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	if (jitter > 0.0) {
		float res = (1.0 - jitter) * min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 2.0;
		float w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
		VERTEX.xy = round(VERTEX.xy / w * res) / res * w;
	}
	float wz = affine ? -VERTEX.z : 1.0;
	aff_uv = vec3(UV * uv_scale * wz, wz);
}

void fragment() {
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;  // two-sided surfaces keep their authored normal whichever way they were wound
	}
	vec2 uv = aff_uv.xy / aff_uv.z;
	vec4 c = use_texture ? texture(albedo, uv) : vec4(1.0);
	c *= tint;
	if (use_vertex_color) {
		c.rgb *= COLOR.rgb;
	}
	if (plank_seams) {
		vec2 p = UV2;
		float d = min(min(p.x, plank.x - p.x), min(p.y, plank.y - p.y));
		float fw = fwidth(d);
		c.rgb *= mix(0.62, 1.0, smoothstep(0.0, max(fw * 1.5, 0.004), d));
	}
	ALBEDO = c.rgb * (1.0 - glow);
	EMISSION = c.rgb * glow;
	if (alpha_cut > 0.0) {
		ALPHA = c.a;
		ALPHA_SCISSOR_THRESHOLD = alpha_cut;
	}
}
