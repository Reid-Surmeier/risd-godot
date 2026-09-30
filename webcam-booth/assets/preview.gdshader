shader_type canvas_item;
void fragment() {
 vec2 cell = floor(UV * vec2(160.0, 120.0));
 vec3 rgb = texture(TEXTURE, (cell + 0.5) / vec2(160.0, 120.0)).rgb;
 rgb = floor(rgb * 31.0 + 0.5) / 31.0;
 rgb *= 1.0 - 0.08 * mod(cell.y, 2.0);
 COLOR = vec4(rgb, 1.0);
}
