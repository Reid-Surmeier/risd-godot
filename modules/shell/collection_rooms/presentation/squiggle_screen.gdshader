// Squigglevision by tentabrobpy (CC0).
// https://godotshaders.com/shader/squigglevision/
// Adapted from per-object UVs to the final screen pass after the CRT output.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen : hint_screen_texture, filter_linear, repeat_disable;
uniform sampler2D noise : filter_linear, repeat_enable;
uniform float strength_pixels = 0.45;
uniform float fps = 3.0;

void fragment() {
	vec2 noise_uv = SCREEN_UV / SCREEN_PIXEL_SIZE / vec2(textureSize(noise, 0));
	vec2 noise_offset = vec2(floor(TIME * fps)) * vec2(PI, E);
	float noise_sample = texture(noise, noise_uv + noise_offset).r * 4.0 * PI;
	vec2 direction = vec2(cos(noise_sample), sin(noise_sample));
	vec2 uv = SCREEN_UV + direction * strength_pixels * SCREEN_PIXEL_SIZE;
	COLOR = texture(screen, clamp(uv, SCREEN_PIXEL_SIZE * 0.5, vec2(1.0) - SCREEN_PIXEL_SIZE * 0.5));
}
