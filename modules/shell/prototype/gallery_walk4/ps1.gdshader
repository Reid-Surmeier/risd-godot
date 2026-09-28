// PROTOTYPE (map #116): the room's surface shader. Unlit: all light is baked into vertex colours (occlusion, the
// skylight's pool on the floor, lamp pools, contact shade), the way DS-era games lit their rooms. The PS1 vertex
// snap and affine warp of the CC0 "PS1 Shader" (godotshaders.com) were tried and removed: at 480 px they made
// the walls and frames ripple while walking. Herringbone seams are drawn here, anti-aliased and faded below a pixel.
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool use_texture = true;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec2 uv_scale = vec2(1.0);
uniform bool use_vertex_color = false;
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.0;
uniform float glow = 0.0;  // kept for callers; unlit surfaces are already their full colour
uniform bool plank_seams = false;  // UV2 carries the position inside a plank, in metres
uniform bool oak_atlas = false;  // #168 trial: one source-guided plank face per atlas row
uniform vec2 plank = vec2(0.66, 0.11);
uniform float jitter = 0.0;  // kept so older callers still set them
uniform bool affine = false;

uniform vec2 floor_z_limits = vec2(-26.3, 0.0);
varying float floor_world_z;
void vertex() { floor_world_z = (MODEL_MATRIX * vec4(VERTEX, 1.0)).z; }

void fragment() {
	if (plank_seams && (floor_world_z < floor_z_limits.x || floor_world_z > floor_z_limits.y)) { discard; }
	vec2 image_uv = UV * uv_scale;
	if (plank_seams && oak_atlas) {
		float row = min(floor(COLOR.a * 4.0), 3.0);
		image_uv = vec2(UV.x * 0.16 + fract(COLOR.a * 17.63) * 0.84,
			(row + 0.5) / 4.0 + (UV.y - 0.5) * 0.13);
	}
	vec4 c = use_texture ? texture(albedo, image_uv) : vec4(1.0);
	c *= tint;
	if (use_vertex_color) {
		c.rgb *= COLOR.rgb;
	}
	if (plank_seams) {
		vec2 p = UV2;
		float d = min(min(p.x, plank.x - p.x), min(p.y, plank.y - p.y));
		float fw = max(fwidth(p.x), fwidth(p.y));
		float seam = 1.0 - smoothstep(0.0, max(fw, 0.004), d);
		float seen = clamp(0.006 / max(fw, 1e-5), 0.0, 1.0);
		c.rgb *= 1.0 - 0.28 * seam * seen;
	}
	ALBEDO = c.rgb;
	if (alpha_cut > 0.0) {
		ALPHA = c.a;
		ALPHA_SCISSOR_THRESHOLD = alpha_cut;
	}
}
