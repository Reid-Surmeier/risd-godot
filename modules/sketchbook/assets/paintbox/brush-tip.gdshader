shader_type canvas_item;

uniform vec4 pigment_color : source_color = vec4(0.0, 0.27, 0.56, 1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float along_brush = (UV.x + UV.y) * 0.5;
	float bristles = 1.0 - smoothstep(0.31, 0.40, along_brush);
	float value = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 loaded = pigment_color.rgb * (0.52 + value * 0.8);
	COLOR = vec4(mix(source.rgb, loaded, bristles), source.a);
}
