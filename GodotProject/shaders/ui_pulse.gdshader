shader_type canvas_item;

uniform float pulse_speed : hint_range(0.5, 8.0) = 2.5;
uniform float amount : hint_range(0.0, 0.3) = 0.06;

void fragment() {
	float p = sin(TIME * pulse_speed) * amount + 1.0;
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.rgb * p, tex.a);
}
