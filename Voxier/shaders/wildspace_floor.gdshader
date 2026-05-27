shader_type spatial;

uniform vec3 floor_color : source_color = vec3(0.08, 0.06, 0.14);
uniform vec3 grid_tint : source_color = vec3(0.25, 0.18, 0.42);
uniform float scroll_speed : hint_range(0.0, 0.5) = 0.08;
uniform float rotation_kick : hint_range(-1.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV * 24.0;
	uv.y += TIME * scroll_speed + rotation_kick * 0.5;
	vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
	float line = 1.0 - min(min(grid.x, grid.y), 1.0);
	line = smoothstep(0.0, 1.0, line);
	vec3 col = mix(floor_color, grid_tint, line * 0.35);
	ALBEDO = col;
	ROUGHNESS = 0.92;
	METALLIC = 0.04;
}
