// The web loading screen's dots and bar (web/loading_shell.html), ported to a Godot canvas_item
// shader for generation. progress is completed recorded stages / 4, never elapsed time.
shader_type canvas_item;

uniform float progress = 0.0;

float rand(float x) { return fract(sin(x) * 43758.5453123); }

float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	return mix(rand(i), rand(i + 1.0), smoothstep(0.0, 1.0, f));
}

float sd_pill(vec2 p, vec2 half_size) {
	float r = min(half_size.x, half_size.y);
	vec2 q = abs(p) - half_size + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	float aspect = length(dFdy(UV)) / max(length(dFdx(UV)), 1e-6);
	vec2 st = (UV - 0.5) * vec2(aspect, -1.0);  // centered, y up, 1.0 = rect height

	vec3 col = vec3(0.996);
	vec3 colors[4] = vec3[](vec3(0.98, 0.92, 0.58), vec3(0.99, 0.65, 0.63), vec3(0.67, 0.79, 0.96), vec3(0.83, 0.93, 0.63));
	vec2 center = vec2(0.0, 0.064);
	for (int i = 0; i < 4; i++) {
		float fi = float(i);
		float t = TIME * 0.8 + fi * 10.0;
		float angle = TIME * 1.5 + fi * 1.5708 + (noise(t) - 0.5) * 1.5;
		float radius = 0.066 + (noise(t + 50.0) - 0.5) * 0.04;
		vec2 pos = center + radius * vec2(cos(angle), sin(angle));
		float d = length(st - pos);
		col = mix(col, colors[i], exp(-pow((d - 0.0096) / 0.0112, 2.0)));
	}

	float p = clamp(progress, 0.0, 1.0);
	vec2 bar_half = vec2(0.07, 0.0075);
	vec2 b = st - vec2(-0.010, -0.410);
	float track = sd_pill(b, bar_half);
	float fill_half_w = bar_half.x * p;
	float fill = sd_pill(b - vec2(fill_half_w - bar_half.x, 0.0), vec2(fill_half_w, bar_half.y));
	float glow = 0.0045;
	col = mix(col, vec3(0.975), exp(-pow(max(track, 0.0) / glow, 2.0)));
	col = mix(col, vec3(0.885), exp(-pow(max(fill, 0.0) / glow, 2.0)));
	// Activity moves within the current unfinished stage; completed fill holds until a real event.
	if (p < 1.0) {
		float cursor = p + 0.04 + 0.18 * (sin(TIME * 2.0) * 0.5 + 0.5);
		float activity = sd_pill(b - vec2((2.0 * cursor - 1.0) * bar_half.x, 0.0), vec2(bar_half.x * 0.035, bar_half.y));
		col = mix(col, vec3(0.80), exp(-pow(max(activity, 0.0) / glow, 2.0)));
	}
	col = mix(col, vec3(0.92), exp(-pow(track / (glow * 0.5), 2.0)) * 0.5);

	COLOR = vec4(col, 1.0);
}
