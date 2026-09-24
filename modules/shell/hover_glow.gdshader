// The hover glow (prototype): a soft halo that hugs the hovered control's shape and spills `pad` into
// the scene around it, plus a faint wash over the control itself. Drawn on a quad `pad` larger than the
// control on every side; all lengths are in the control's local units.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D shape : filter_linear, repeat_disable;  // the control's picture, when it has one
uniform bool has_shape = false;
uniform vec2 box = vec2(100.0);  // the control's size
uniform float pad = 18.0;  // how far the glow reaches past the edge
uniform float radius = 4.0;  // corner radius when there is no picture
uniform float strength = 0.0;  // 0..1, tweened on hover
uniform vec4 tint : source_color = vec4(0.36, 0.78, 0.96, 1.0);

float rect_sd(vec2 p) {
	vec2 d = abs(p - box * 0.5) - (box * 0.5 - radius);
	return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

float inside(vec2 p) {
	if (!has_shape) {
		return clamp(0.5 - rect_sd(p), 0.0, 1.0);
	}
	vec2 uv = p / box;
	return (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) ? 0.0 : texture(shape, uv).a;
}

void fragment() {
	vec2 p = UV * (box + 2.0 * pad) - pad;
	float s = inside(p);
	float halo;
	if (has_shape) {  // the picture's alpha, blurred over the reach: the glow follows the silhouette
		float sum = 0.0;
		float w = 0.0;
		// a per-pixel shift of the tap grid turns the grid's stair steps into fine, even grain
		float h = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);
		vec2 jitter = (vec2(h, fract(h * 7.13)) - 0.5) * (pad / 4.0);
		for (int i = -4; i <= 4; i++) {
			for (int j = -4; j <= 4; j++) {
				vec2 o = vec2(float(i), float(j)) * (pad / 4.0) + jitter;
				float k = exp(-dot(o, o) / (pad * pad * 0.35));
				sum += inside(p + o) * k;
				w += k;
			}
		}
		halo = min(sum / w * 2.2, 1.0);
	} else {
		halo = exp(-max(rect_sd(p), 0.0) * 3.0 / pad);
	}
	COLOR = vec4(tint.rgb, tint.a * mix(halo * 0.6, 0.12, s) * strength);
}
