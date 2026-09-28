// PROTOTYPE #168: source-led herringbone albedo over modeled planks/lightmap.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D parquet : source_color, filter_linear_mipmap, repeat_enable;
// #168: the recorded RISD floor crop is muted tan, not saturated orange.
uniform vec4 ground_tone : source_color = vec4(0.69, 0.58, 0.47, 1.0);
// Whole authored planks extend past the end walls; the white doorway recess
// shares the floor plane. Keep parquet fragments inside the room to avoid Z fighting.
uniform vec2 floor_z_limits = vec2(-26.3, 0.0);
varying float floor_world_z;
varying vec2 floor_world_xz;
void vertex() {
	vec3 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	floor_world_z = p.z;
	floor_world_xz = p.xz;
}
void fragment() {
	if (floor_world_z < floor_z_limits.x || floor_world_z > floor_z_limits.y) { discard; }
	// The earlier narrow strip and 3x contrast exposed oak.png's comb-like
	// streaks. The source-guided floor pass carries broader wood structure;
	// sample it in world space so adjacent modeled planks do not reset grain.
	vec3 broad = texture(parquet, floor_world_xz / 5.0).rgb;
	ALBEDO = mix(ground_tone.rgb, broad, 0.78) * COLOR.rgb;
	ROUGHNESS = 1.0;
}
