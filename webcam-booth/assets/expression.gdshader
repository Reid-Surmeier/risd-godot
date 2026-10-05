shader_type canvas_item;
uniform vec2 eye_left = vec2(0.43, 0.41);
uniform vec2 eye_right = vec2(0.57, 0.41);
uniform vec2 mouth = vec2(0.5, 0.55);
uniform float mouth_width = 0.12;
uniform vec4 expression = vec4(0.0);
uniform vec3 pose = vec3(0.0);
void fragment() {
 vec2 uv = UV;
 vec2 center = (eye_left + eye_right + mouth) / 3.0;
 float face_weight = exp(-dot((uv-center)/vec2(0.23,0.3),(uv-center)/vec2(0.23,0.3))*2.0);
 vec2 relative = uv-center;
 float angle = -pose.z * face_weight;
 uv = center + mat2(vec2(cos(angle),sin(angle)),vec2(-sin(angle),cos(angle))) * relative;
 uv -= pose.xy * face_weight;
 vec2 dl = (uv-eye_left)/vec2(0.045,0.035);
 vec2 dr = (uv-eye_right)/vec2(0.045,0.035);
 uv.y += (uv.y-eye_left.y)*expression.x*1.6*exp(-dot(dl,dl));
 uv.y += (uv.y-eye_right.y)*expression.y*1.6*exp(-dot(dr,dr));
 vec2 dm = (uv-mouth)/vec2(max(mouth_width*0.65,0.03),0.065);
 float smile_weight = exp(-dot(dm,dm));
 uv.x -= sign(uv.x-mouth.x)*expression.z*0.018*smile_weight;
 uv.y += expression.z*0.018*smile_weight*clamp(abs(dm.x),0.0,1.0);
 float jaw_weight = exp(-pow((uv.x-mouth.x)/0.12,2.0))*smoothstep(mouth.y-0.02,mouth.y+0.08,uv.y);
 uv.y -= expression.w*0.035*jaw_weight;
 COLOR = texture(TEXTURE,clamp(uv,vec2(0.0),vec2(1.0)));
}
