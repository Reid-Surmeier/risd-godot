shader_type canvas_item;

uniform vec2 frame_origin = vec2(0.0);
uniform vec2 frame_size = vec2(1.0);
uniform vec2 display_size = vec2(1.0);
uniform vec4 inset = vec4(0.0);
uniform int face_kind = 0; // button, translucent navigation, progress rail
uniform float circle_center_x = 34.0;
uniform sampler2D fill_texture : source_color, filter_linear;
uniform float fill_width = 0.0;
uniform float corner_radius = 5.0;

void fragment() {
	vec2 local = (UV / TEXTURE_PIXEL_SIZE - frame_origin) / frame_size;
	vec2 pixel = local * display_size;
	vec2 source_pixel = frame_origin + inset.xy + local * (frame_size - inset.xy - inset.zw);
	vec4 face = texture(TEXTURE, source_pixel * TEXTURE_PIXEL_SIZE);
	float radius = face_kind == 2 ? 10.0 : corner_radius;
	vec2 q = abs(pixel - display_size * 0.5) - (display_size * 0.5 - vec2(radius));
	float distance_to_edge = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
	float mask = 1.0 - smoothstep(-1.5, 0.0, distance_to_edge);
	if (face_kind == 1) {
		distance_to_edge = length(pixel - vec2(circle_center_x, 84.0)) - 83.0;
		mask = 1.0 - smoothstep(-1.0, 0.5, distance_to_edge);
		float luminance = dot(face.rgb, vec3(0.299, 0.587, 0.114));
		float glyph = (1.0 - smoothstep(0.45, 0.66, luminance))
			* step(28.0, pixel.x) * step(pixel.x, 98.0)
			* step(55.0, pixel.y) * step(pixel.y, 116.0);
		face.rgb = mix(mix(face.rgb, vec3(0.97, 0.985, 1.0), 0.82), face.rgb, glyph);
		face.a *= mix(0.55, 0.88, glyph);
	} else if (face_kind == 2) {
		// Use only the uniform material sample: the donor's baked end cap must
		// not appear inside the single silhouette owned by this rail.
		face = texture(TEXTURE, vec2(0.5, source_pixel.y * TEXTURE_PIXEL_SIZE.y));
		if (pixel.x < fill_width) {
			face = texture(fill_texture, vec2(0.5, local.y));
		}
	}
	COLOR = vec4(face.rgb, face.a * mask);
}
