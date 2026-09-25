// A window's drop shadow from its silhouette (a quarter-resolution alpha mask of the pieces the window
// draws, padded on every side): the mask blurred (7x7 gaussian taps over bilinear texels), moved down by
// `offset`, in black at `strength`.
shader_type canvas_item;

uniform float sigma = 2.5;       // mask texels
uniform vec2 offset = vec2(0.0); // mask uv, down is positive y
uniform float strength = 0.16;

void fragment() {
	vec2 texel = TEXTURE_PIXEL_SIZE;
	vec2 uv = UV - offset;
	float step_px = max(sigma, 0.001) / 1.6;
	float total = 0.0;
	float a = 0.0;
	for (int i = -3; i <= 3; i++) {
		for (int j = -3; j <= 3; j++) {
			vec2 d = vec2(float(i), float(j)) * step_px;
			float w = exp(-dot(d, d) / (2.0 * sigma * sigma));
			a += w * texture(TEXTURE, uv + d * texel).a;
			total += w;
		}
	}
	COLOR = vec4(0.0, 0.0, 0.0, strength * a / total);
}
