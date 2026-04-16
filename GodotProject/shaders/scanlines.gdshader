shader_type canvas_item;

uniform float line_density : hint_range(20.0, 800.0) = 240.0;
uniform float opacity : hint_range(0.0, 0.5) = 0.08;

void fragment() {
	float y = UV.y * line_density;
	float scan = step(0.5, fract(y));
	COLOR = vec4(0.0, 0.0, 0.0, (1.0 - scan) * opacity);
}
