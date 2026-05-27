shader_type canvas_item;

uniform float time_scale : hint_range(0.0, 2.0) = 0.15;
uniform vec3 sky_top : source_color = vec3(0.03, 0.02, 0.09);
uniform vec3 sky_bottom : source_color = vec3(0.11, 0.06, 0.24);
uniform vec3 nebula_tint : source_color = vec3(0.15, 0.08, 0.35);
uniform float star_density : hint_range(0.98, 0.9999) = 0.995;

void fragment() {
	float t = TIME * time_scale;
	vec2 uv = UV + vec2(t * 0.02, t * 0.05);
	vec3 grad = mix(sky_bottom, sky_top, UV.y);
	float n = fract(sin(dot(uv * 3.0, vec2(12.9898, 78.233))) * 43758.5453);
	grad += nebula_tint * smoothstep(0.6, 1.0, n) * 0.35;
	float stars = step(star_density, fract(sin(dot(uv * 420.0, vec2(12.9898, 78.233))) * 43758.5453));
	COLOR = vec4(grad + vec3(stars * 1.2), 1.0);
}
