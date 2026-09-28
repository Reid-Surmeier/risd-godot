// PROTOTYPE #168: source-led oak-board grain over modeled herringbone/lightmap.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D oak : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D parquet_macro : source_color, filter_linear_mipmap, repeat_enable;
// #168: the recorded RISD floor crop is muted tan, not saturated orange.
uniform vec4 ground_tone : source_color = vec4(0.70, 0.61, 0.52, 1.0);
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
	// The Muse oak pass has broad board grain but also painted board divisions.
	// Sample only within one source board, at a varied horizontal crop; the
	// modeled geometry is the only source of herringbone structure.
	float grain_scale = mix(0.48, 0.72, COLOR.a);
	float crop = fract(COLOR.a * 17.63) * (1.0 - grain_scale);
	// A clean source-board interior with varied lengthwise crop.
	float source_row = 0.29 + COLOR.a * 0.025;
	vec2 grain_uv = vec2(UV.x * grain_scale + crop, source_row + UV.y * 0.13);
	vec3 grain = textureGrad(oak, grain_uv, dFdx(grain_uv), dFdy(grain_uv)).rgb;
	vec3 grain_low = textureLod(oak, grain_uv, 5.0).rgb;
	vec3 grain_detail = clamp((grain - grain_low) * 0.5, vec3(-0.05), vec3(0.05));
	// The full floor image has a second herringbone; its 4x4 mip only supplies
	// broad photo-guided colour patches, never a visible structural overlay.
	float patch = dot(textureLod(parquet_macro, floor_world_xz / 12.0 + vec2(0.19, 0.13), 8.0).rgb, vec3(0.299, 0.587, 0.114));
	float patch_delta = clamp((patch - 0.69) * 0.35, -0.045, 0.045);
	// A soft antialiased join follows modeled plank edges; no source-wide stripe.
	float edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float join = 1.0 - smoothstep(0.0, max(fwidth(edge) * 1.2, 0.012), edge);
	ALBEDO = clamp(ground_tone.rgb * COLOR.rgb + grain_detail + vec3(patch_delta - join * 0.020), vec3(0.0), vec3(1.0));
	ROUGHNESS = 1.0;
}
