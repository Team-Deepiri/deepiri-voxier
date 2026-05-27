shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec3 sky_top : source_color = vec3(0.03, 0.02, 0.09);
uniform vec3 sky_bottom : source_color = vec3(0.11, 0.06, 0.24);
uniform vec3 nebula_tint : source_color = vec3(0.15, 0.08, 0.35);
uniform float nebula_strength : hint_range(0.0, 1.0) = 0.55;
uniform float star_density : hint_range(0.98, 0.9999) = 0.995;
uniform float scroll_speed : hint_range(0.0, 1.0) = 0.15;
uniform float rotation_kick : hint_range(-1.0, 1.0) = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * scroll_speed;
	uv += vec2(t * 0.03 + rotation_kick * 0.08, t * 0.06);

	vec3 grad = mix(sky_bottom, sky_top, clamp(UV.y, 0.0, 1.0));
	float n = noise(uv * 3.5);
	float n2 = noise(uv * 7.0 + vec2(t * 0.2, 0.0));
	float nebula = smoothstep(0.35, 0.95, n * 0.55 + n2 * 0.45);
	grad += nebula_tint * nebula * nebula_strength;

	float stars = step(star_density, hash21(uv * 420.0 + vec2(t * 2.0, 0.0)));
	stars += step(star_density + 0.0015, hash21(uv * 180.0 - vec2(0.0, t))) * 0.6;
	grad += vec3(stars);

	ALBEDO = grad;
}
