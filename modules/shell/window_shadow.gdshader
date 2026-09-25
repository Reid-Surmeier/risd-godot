// A window's drop shadow, drawn over a quad around it: two gaussian-blurred copies of the window's
// visible box (exact, via erf, so any width stays smooth): a wide, diffuse ambient shadow falling
// `amb_offset` below the window, and a faint tight contact shadow just under its edge.
shader_type canvas_item;

uniform vec2 quad_pos;        // the drawn quad, node px
uniform vec2 quad_size = vec2(100.0);
uniform vec4 box;             // the window's visible box: x, y, w, h (node px)
uniform float spread = 0.0;   // the ambient box grows by this on every side
uniform float amb_offset = 8.0;
uniform float amb_sigma = 16.0;
uniform float amb_alpha = 0.38;
uniform float contact_offset = 2.0;
uniform float contact_sigma = 2.5;
uniform float contact_alpha = 0.14;
uniform float radius = 0.0;   // the window's corner radius (node px): the contact shadow rounds with it

float erf_a(float x) {  // Abramowitz-Stegun 7.1.27, |error| < 5e-4
	float s = sign(x);
	float a = abs(x);
	float t = 1.0 + (0.278393 + (0.230389 + (0.000972 + 0.078108 * a) * a) * a) * a;
	t *= t;
	return s - s / (t * t);
}

float blurred_box(vec2 p, vec2 lo, vec2 hi, float sigma) {
	float k = 1.0 / (max(sigma, 0.001) * 1.41421356);
	float x = 0.5 * (erf_a((p.x - lo.x) * k) - erf_a((p.x - hi.x) * k));
	float y = 0.5 * (erf_a((p.y - lo.y) * k) - erf_a((p.y - hi.y) * k));
	return x * y;
}

float blurred_round_box(vec2 p, vec2 lo, vec2 hi, float r, float sigma) {  // via its signed distance
	vec2 c = (lo + hi) * 0.5;
	vec2 q = abs(p - c) - (hi - lo) * 0.5 + r;
	float sd = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
	return 0.5 * (1.0 - erf_a(sd / (max(sigma, 0.001) * 1.41421356)));
}

void fragment() {
	vec2 p = quad_pos + UV * quad_size;
	vec2 lo = box.xy;
	vec2 hi = box.xy + box.zw;
	float amb = blurred_box(p, lo - spread + vec2(0.0, amb_offset), hi + spread + vec2(0.0, amb_offset), amb_sigma);
	float contact = blurred_round_box(p, lo + vec2(0.0, contact_offset), hi + vec2(0.0, contact_offset), radius, contact_sigma);
	COLOR = vec4(0.0, 0.0, 0.0, clamp(amb_alpha * amb + contact_alpha * contact, 0.0, 1.0));
}
