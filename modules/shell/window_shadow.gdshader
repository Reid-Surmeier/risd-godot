// A CSS filter: drop-shadow for one window: the drawn quad grows by `pad` page px on every side, and each
// pixel takes the shadow colour at the window picture's alpha, blurred over `blur` px (a 5x5 gaussian).
shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.22);
uniform float blur = 3.0;      // local px
uniform float pad = 8.0;       // local px the quad grows by
uniform vec2 quad_size = vec2(100.0);  // the picture's drawn size, local px

varying vec2 uv_inner;

void vertex() {
	vec2 dir = UV * 2.0 - 1.0;
	VERTEX += dir * pad;
	uv_inner = UV + dir * pad / quad_size;
}

void fragment() {
	vec2 step_uv = blur / 2.0 / quad_size;
	float w[5] = float[](0.06, 0.24, 0.40, 0.24, 0.06);
	float a = 0.0;
	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 5; j++) {
			vec2 p = uv_inner + vec2(float(i - 2), float(j - 2)) * step_uv;
			float inside = step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
			a += w[i] * w[j] * texture(TEXTURE, clamp(p, 0.0, 1.0)).a * inside;
		}
	}
	COLOR = vec4(shadow_color.rgb, shadow_color.a * a);
}
