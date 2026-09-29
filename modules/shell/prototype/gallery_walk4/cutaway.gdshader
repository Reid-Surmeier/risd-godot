// Temporary opaque dissolve: Compatibility does not implement Alpha Hash.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform float cutaway_opacity=1.0;
uniform sampler2D tex: source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool textured=false;
uniform vec4 tint: source_color=vec4(1.0);
uniform vec3 uv_scale=vec3(1.0);
uniform bool vertex_tint=false;
uniform bool unshaded=false;
uniform float scissor=0.0;
void fragment(){
 float threshold=fract(0.754877666*floor(FRAGCOORD.x)+0.569840296*floor(FRAGCOORD.y));
 if(threshold>=cutaway_opacity)discard;
 vec4 color=tint;
 if(textured)color*=texture(tex,UV*uv_scale.xy);
 if(vertex_tint)color*=COLOR;
 if(color.a<scissor)discard;
 ALBEDO=unshaded?vec3(0.0):color.rgb;
 EMISSION=unshaded?color.rgb:vec3(0.0);
 ROUGHNESS=1.0;
}
