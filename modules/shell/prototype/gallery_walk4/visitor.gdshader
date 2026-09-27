// Source pixels stay intact. Key the declared green matte only at display time.
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D sheet : source_color, filter_linear, repeat_disable;

void vertex() {
	// Keep the figure upright at doorways: a fully tilted billboard cuts through
	// the wall above its feet. Compensate projection so the established size holds.
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	vec3 up = vec3(0.0, 1.0, 0.0);
	vec3 toward_camera = normalize(cross(right, up));
	float projected_up = max(length((VIEW_MATRIX * vec4(up, 0.0)).xy), 0.5);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(right, 0.0), vec4(up / projected_up, 0.0), vec4(toward_camera, 0.0), MODEL_MATRIX[3]);
}

void fragment() {
	vec3 color = texture(sheet, UV).rgb;
	if (color.g > 0.25 && color.g > max(color.r, color.b) * 1.35) {
		discard;
	}
	ALBEDO = color;
}
