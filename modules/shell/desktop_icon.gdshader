// The desktop icons, quieted (owner, 2026-09-25: lighter grey, a little see-through, only slightly):
// colour pulled toward its grey, then lifted toward white; the black labels become a light grey.
shader_type canvas_item;

uniform float quiet = 1.0;  // 0 = the icon as drawn, 1 = fully quieted
const float DESATURATE = 0.35;
const float LIGHTEN = 0.28;
const float FADE = 0.8;  // opacity when fully quieted

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float grey = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 q = mix(mix(c.rgb, vec3(grey), DESATURATE), vec3(1.0), LIGHTEN);
	COLOR = vec4(mix(c.rgb, q, quiet), c.a * mix(1.0, FADE, quiet)) * COLOR;
}
