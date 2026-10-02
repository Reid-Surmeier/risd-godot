// Native RGB6 texels -> GameCube-style display-copy filter -> bilinear enlargement.
// Source arithmetic and copy-filter weights: docs/research/gallery-final-render-overlay.md.
shader_type canvas_item;
render_mode unshaded;

// 1 = the interlaced mode's 1/4, 1/2, 1/4 rows; 0 = no vertical softening.
// Half strength suits the prototype's lower-than-480-line viewport.
uniform float copy_filter : hint_range(0.0, 1.0) = 0.5;
// Diagnostic controls (#140). Default 2 retains the shipped finish.
// 0 preserves input color; 1 is plain six-bit truncation; 2 is GX raster dither.
uniform int quantization_mode : hint_range(0, 2) = 2;

vec4 rgb6(vec4 c, ivec2 pixel) {
	if (quantization_mode == 0) {
		return c;
	}
	float d = float(((pixel.x ^ pixel.y) & 1) * 2 + (pixel.y & 1));
	vec3 v = floor(c.rgb * 255.0 + 0.5);
	if (quantization_mode == 2) {
		v = v - floor(v / 64.0) + d;
	}
	return vec4(clamp(floor(v / 4.0) / 63.0, 0.0, 1.0), c.a);
}

void fragment() {
	vec2 position = UV / TEXTURE_PIXEL_SIZE - vec2(0.5);
	ivec2 base = ivec2(floor(position));
	vec2 blend = fract(position);
	// Two columns, four rows: adjacent reconstructed pixels share filter taps.
	ivec2 limit = textureSize(TEXTURE, 0) - ivec2(1);
	ivec2 p0 = clamp(base + ivec2(0, -1), ivec2(0), limit);
	ivec2 p1 = clamp(base + ivec2(1, -1), ivec2(0), limit);
	ivec2 p2 = clamp(base, ivec2(0), limit);
	ivec2 p3 = clamp(base + ivec2(1, 0), ivec2(0), limit);
	ivec2 p4 = clamp(base + ivec2(0, 1), ivec2(0), limit);
	ivec2 p5 = clamp(base + ivec2(1, 1), ivec2(0), limit);
	ivec2 p6 = clamp(base + ivec2(0, 2), ivec2(0), limit);
	ivec2 p7 = clamp(base + ivec2(1, 2), ivec2(0), limit);
	vec4 a = mix(rgb6(texelFetch(TEXTURE, p0, 0), p0), rgb6(texelFetch(TEXTURE, p1, 0), p1), blend.x);
	vec4 b = mix(rgb6(texelFetch(TEXTURE, p2, 0), p2), rgb6(texelFetch(TEXTURE, p3, 0), p3), blend.x);
	vec4 c = mix(rgb6(texelFetch(TEXTURE, p4, 0), p4), rgb6(texelFetch(TEXTURE, p5, 0), p5), blend.x);
	vec4 d = mix(rgb6(texelFetch(TEXTURE, p6, 0), p6), rgb6(texelFetch(TEXTURE, p7, 0), p7), blend.x);
	float side = copy_filter * 0.25;
	vec3 top = a.rgb * side + b.rgb * (1.0 - 2.0 * side) + c.rgb * side;
	vec3 bottom = b.rgb * side + c.rgb * (1.0 - 2.0 * side) + d.rgb * side;
	COLOR = vec4(mix(top, bottom, blend.y), mix(b.a, c.a, blend.y));
}
