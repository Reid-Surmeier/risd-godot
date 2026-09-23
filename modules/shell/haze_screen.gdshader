// Haze: the whole screen blended with a soft copy of itself, the same diffusion as the loading
// dots but much lighter, so edges and text lose their digital hardness without going blurry.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen : hint_screen_texture, filter_linear, repeat_disable;
uniform float radius_pixels = 1.6; // how far the diffusion spreads
uniform float amount = 0.45;       // 0 = sharp, 1 = only the soft copy

void fragment() {
	vec4 sharp = texture(screen, SCREEN_UV);
	// 12 taps on two rings, turned by the golden angle: a cheap, round blur
	vec4 soft = vec4(0.0);
	for (int i = 0; i < 12; i++) {
		float a = float(i) * 2.39996;
		float r = (i % 2 == 0 ? 0.5 : 1.0) * radius_pixels;
		soft += texture(screen, SCREEN_UV + vec2(cos(a), sin(a)) * r * SCREEN_PIXEL_SIZE);
	}
	COLOR = mix(sharp, soft / 12.0, amount);
}
