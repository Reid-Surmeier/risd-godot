// The loading screen's tape look (boot_loader.gd), measured from the owner's VHS-style reference:
// the tape frame is already reduced in pixels and JPEG-compressed; this adds what the signal does
// on top. Brightness is soft sideways, colour trails to the right of its shape at lower resolution,
// and dark edges get a light halo. White stays white.
shader_type canvas_item;

vec3 to_yiq(vec3 c) { return mat3(vec3(0.299, 0.596, 0.211), vec3(0.587, -0.274, -0.523), vec3(0.114, -0.322, 0.312)) * c; }
vec3 from_yiq(vec3 c) { return mat3(vec3(1.0, 1.0, 1.0), vec3(0.956, -0.272, -1.106), vec3(0.621, -0.647, 1.703)) * c; }

void fragment() {
	vec2 px = vec2(TEXTURE_PIXEL_SIZE.x, 0.0);   // one tape pixel sideways
	vec4 here = texture(TEXTURE, UV);
	vec4 luma = (texture(TEXTURE, UV - px) + 2.0 * here + texture(TEXTURE, UV + px)) * 0.25;
	vec4 chroma = vec4(0.0);
	for (int k = 0; k < 5; k++) {
		chroma += texture(TEXTURE, UV - px * float(k) * 0.75);
	}
	chroma /= 5.0;
	vec4 wide = (texture(TEXTURE, UV - 2.0 * px) + texture(TEXTURE, UV + 2.0 * px)
			+ texture(TEXTURE, UV - vec2(0.0, 2.0 * TEXTURE_PIXEL_SIZE.y)) + texture(TEXTURE, UV + vec2(0.0, 2.0 * TEXTURE_PIXEL_SIZE.y))) * 0.25;

	float a = max(luma.a, 1e-4);
	float y = to_yiq(luma.rgb / a).x;
	y += 0.4 * (y - to_yiq(wide.rgb / max(wide.a, 1e-4)).x);   // edge halo
	vec3 rgb = from_yiq(vec3(y, to_yiq(chroma.rgb / max(chroma.a, 1e-4)).yz));
	COLOR = vec4(clamp(rgb, 0.0, 1.0), luma.a);
}
