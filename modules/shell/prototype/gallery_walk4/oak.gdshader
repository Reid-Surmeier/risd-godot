// PROTOTYPE #132: keep Muse albedo, quiet fine grain before native baked lighting.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D oak : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 ground_tone : source_color = vec4(0.64, 0.44, 0.25, 1.0);
// Each modeled plank previously compressed several painted board bands. Sample
// one quarter of that vertical span; keep the source pixels and lighting UVs.
uniform float grain_width : hint_range(0.25, 1.0) = 0.25;
// Whole authored planks extend past the end walls; the white doorway recess
// shares the floor plane. Keep parquet fragments inside the room to avoid Z fighting.
uniform vec2 floor_z_limits = vec2(-26.3, 0.0);
varying float floor_world_z;
void vertex() { floor_world_z = (MODEL_MATRIX * vec4(VERTEX, 1.0)).z; }
void fragment() {
	if (floor_world_z < floor_z_limits.x || floor_world_z > floor_z_limits.y) { discard; }
	// Wider minification footprint softens grain without moving UVs or adding noise.
	vec2 grain_uv = vec2(UV.x, 0.5 + (UV.y - 0.5) * grain_width);
	vec3 grain = textureGrad(oak, grain_uv, dFdx(grain_uv) * 2.0, dFdy(grain_uv) * 2.0).rgb;
	ALBEDO = mix(ground_tone.rgb, grain, 0.60) * COLOR.rgb;
	ROUGHNESS = 1.0;
}
