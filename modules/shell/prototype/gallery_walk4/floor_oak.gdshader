// PROTOTYPE #168: source-led oak-board grain over modeled herringbone/lightmap.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D oak : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D parquet_macro : source_color, filter_linear_mipmap, repeat_enable;
// #168: the recorded RISD floor crop is muted tan, not saturated orange.
uniform vec4 ground_tone : source_color = vec4(0.88, 0.80, 0.72, 1.0);
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
	// Eight separately generated faces; crop each tile's dark dividers.
	float face = min(floor(COLOR.a * 8.0), 7.0);
	float row = floor(face * 0.5);
	float column = mod(face, 2.0);
	float row_start = vec4(0.0, 0.276, 0.525, 0.753)[int(row)];
	float row_end = vec4(0.276, 0.525, 0.753, 1.0)[int(row)];
	vec2 grain_uv = vec2((column + 0.04 + UV.x * 0.92) * 0.5,
		mix(row_start, row_end, 0.06 + UV.y * 0.88));
	vec3 grain = textureGrad(oak, grain_uv, dFdx(grain_uv), dFdy(grain_uv)).rgb;
	vec3 grain_origin = textureLod(oak, vec2((column + 0.5) * 0.5, mix(row_start, row_end, 0.5)), 6.0).rgb;
	vec3 grain_detail = clamp((grain - grain_origin) * 1.0, vec3(-0.10), vec3(0.10));
	// The full floor image has a second herringbone; its 4x4 mip only supplies
	// broad photo-guided colour patches, never a visible structural overlay.
	float patch = dot(textureLod(parquet_macro, floor_world_xz / 12.0 + vec2(0.19, 0.13), 8.0).rgb, vec3(0.299, 0.587, 0.114));
	float patch_delta = clamp((patch - 0.69) * 0.60, -0.075, 0.075);
	// A soft antialiased join follows modeled plank edges; no source-wide stripe.
	float end_edge = min(UV.x, 1.0 - UV.x);
	float side_edge = min(UV.y, 1.0 - UV.y);
	float end_join = 1.0 - smoothstep(0.0, max(fwidth(end_edge) * 1.2, 0.018), end_edge);
	float side_join = 1.0 - smoothstep(0.0, max(fwidth(side_edge) * 1.2, 0.007), side_edge);
	float board_tone = mix(0.93, 1.07, fract(COLOR.a * 8.0));
	ALBEDO = clamp(ground_tone.rgb * COLOR.rgb * board_tone + grain_detail + vec3(patch_delta - end_join * 0.055 - side_join * 0.018), vec3(0.0), vec3(1.0));
	ROUGHNESS = 1.0;
}
