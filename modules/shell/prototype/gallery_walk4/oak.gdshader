// PROTOTYPE #132: keep Muse albedo, quiet fine grain before native baked lighting.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D oak : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 ground_tone : source_color = vec4(0.64, 0.44, 0.25, 1.0);
void fragment() {
	// Wider minification footprint softens grain without moving UVs or adding noise.
	vec3 grain = textureGrad(oak, UV, dFdx(UV) * 2.0, dFdy(UV) * 2.0).rgb;
	ALBEDO = mix(ground_tone.rgb, grain, 0.60) * COLOR.rgb;
	ROUGHNESS = 1.0;
}
