shader_type canvas_item;
render_mode blend_mix;

uniform float rim : hint_range(0.0, 1.0) = 0.35;
uniform vec3 light_dir = vec3(0.55, -0.35, 0.75);

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	if (t.a < 0.05) {
		COLOR = t;
	} else {
		vec2 ts = max(vec2(1.0), vec2(textureSize(TEXTURE, 0)));
		vec2 e = vec2(1.0) / ts;
		float a_up = texture(TEXTURE, UV + vec2(0.0, -e.y)).a;
		float a_dn = texture(TEXTURE, UV + vec2(0.0, e.y)).a;
		float a_lf = texture(TEXTURE, UV + vec2(-e.x, 0.0)).a;
		float a_rt = texture(TEXTURE, UV + vec2(e.x, 0.0)).a;
		float edge = clamp((a_up + a_dn + a_lf + a_rt) * 0.25 - t.a + 0.35, 0.0, 1.0);
		vec3 rim_col = vec3(1.0, 0.82, 0.55) * edge * rim;
		float shade = 0.82 + 0.22 * clamp(dot(normalize(vec3(UV - 0.5, 0.35)), normalize(light_dir)), 0.0, 1.0);
		COLOR = vec4(t.rgb * shade + rim_col, t.a);
	}
}
