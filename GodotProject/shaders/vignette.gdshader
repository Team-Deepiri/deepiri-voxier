shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float d = length(uv);
	float v = smoothstep(0.42, 1.35, d);
	COLOR = vec4(0.0, 0.0, 0.0, v * strength);
}
