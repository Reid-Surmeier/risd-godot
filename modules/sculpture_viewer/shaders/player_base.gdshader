shader_type canvas_item;

void fragment() {
	vec2 pixel = UV * vec2(800.0, 680.0);
	vec4 base = texture(TEXTURE, UV);
	// The reference has opaque arrows baked in. Recover the same vertical
	// frame columns from below them before compositing translucent controls.
	if (pixel.y >= 225.0 && pixel.y < 393.0 && (pixel.x < 122.0 || pixel.x >= 678.0)) {
		base = texture(TEXTURE, vec2(UV.x, 440.5 / 680.0));
	}
	// One empty continuous metal panel. Remove complete old controls, including
	// their bezels and shadows, before adding independently owned silhouettes.
	if (pixel.x >= 35.0 && pixel.x < 765.0 && pixel.y >= 587.0 && pixel.y < 635.0) {
		base = texture(TEXTURE, vec2(460.5 / 800.0, UV.y));
	}
	COLOR = base;
}
