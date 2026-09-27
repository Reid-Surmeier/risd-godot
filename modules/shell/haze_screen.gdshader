// Haze: the whole screen blended with a soft copy of itself, the same diffusion as the loading
// dots but much lighter, so edges and text lose their digital hardness without going blurry.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen : hint_screen_texture, filter_linear, repeat_disable;
uniform float radius_pixels = 1.6; // how far the diffusion spreads
uniform float amount = 0.45;       // 0 = sharp, 1 = only the soft copy

// Rectangle is in the desktop's coordinates; map through the same shell warp.
uniform vec4 quiet_rect = vec4(0.0);
uniform float desktop_aspect = 1.0;
uniform float desktop_curve = 0.0;
uniform float desktop_scale = 1.0;

void fragment() {
	vec4 sharp = texture(screen, SCREEN_UV);
	vec2 source_uv = (SCREEN_UV - vec2(0.5)) / desktop_scale;
	source_uv.x /= desktop_aspect;
	source_uv /= 1.0 - (dot(source_uv, source_uv) - 0.25) * desktop_curve;
	source_uv.x *= desktop_aspect;
	source_uv += vec2(0.5);
	bool quiet = quiet_rect.z > quiet_rect.x && quiet_rect.w > quiet_rect.y
		&& all(greaterThanEqual(source_uv, quiet_rect.xy))
		&& all(lessThanEqual(source_uv, quiet_rect.zw));
	if (quiet) {
		COLOR = sharp;
	} else {
		// 12 taps on two rings, turned by the golden angle: a cheap, round blur
		vec4 soft = vec4(0.0);
		for (int i = 0; i < 12; i++) {
			float a = float(i) * 2.39996;
			float r = (i % 2 == 0 ? 0.5 : 1.0) * radius_pixels;
			soft += texture(screen, SCREEN_UV + vec2(cos(a), sin(a)) * r * SCREEN_PIXEL_SIZE);
		}
		COLOR = mix(sharp, soft / 12.0, amount);
	}
}
