shader_type canvas_item;

uniform float time_scale : hint_range(0.0, 2.0) = 0.15;
uniform vec3 tint : source_color = vec3(0.15, 0.08, 0.35);

void fragment() {
	float t = TIME * time_scale;
	vec2 uv = UV + vec2(t * 0.02, t * 0.05);
	float n = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
	float stars = smoothstep(0.995, 1.0, n);
	COLOR = vec4(tint * (0.4 + stars * 1.4), 1.0);
}
