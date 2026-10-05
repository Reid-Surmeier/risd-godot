shader_type canvas_item;
void fragment() {
 vec4 pixel = texture(TEXTURE, UV);
 float green = pixel.g - max(pixel.r, pixel.b);
 float alpha = 1.0 - smoothstep(0.08, 0.25, green);
 if (alpha < 0.95) pixel.g = min(pixel.g, max(pixel.r, pixel.b));
 COLOR = vec4(pixel.rgb, pixel.a * alpha);
}
