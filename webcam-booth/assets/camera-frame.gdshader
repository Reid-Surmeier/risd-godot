shader_type canvas_item;
void fragment() {
 vec4 pixel = texture(TEXTURE, UV);
 vec2 p = UV * vec2(1024.0, 650.0);
 // Open only the preview aperture; keep the original cream hat and colorful stars.
 if (p.x >= 113.0 && p.x <= 918.0 && p.y >= 65.0 && p.y <= 503.0) {
  // The hat has a white highlight inside its cream face; retain that opaque core.
  if (length((p - vec2(497.0, 163.0)) / vec2(55.0, 48.0)) >= 1.0) {
   pixel.a *= 1.0 - smoothstep(0.97, 0.985, min(pixel.r, min(pixel.g, pixel.b)));
  }
 }
 // The original icon is drawn by the interactive shutter on top of this bar.
 if (p.x >= 491.0 && p.x < 539.0 && p.y >= 536.0 && p.y < 585.0) {
  pixel = texture(TEXTURE, vec2(565.0 / 1024.0, UV.y));
 }
 COLOR = pixel;
}
