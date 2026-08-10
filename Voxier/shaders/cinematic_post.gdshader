shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
/// How much barrel / "looking up the shaft" perspective vs flat (0 = flat).
uniform float perspective_mix : hint_range(0.0, 1.0) = 0.5;
/// Horizontal wobble from forward speed.
uniform float speed_streak : hint_range(0.0, 1.0) = 0.0;
uniform float chroma_strength : hint_range(0.0, 0.02) = 0.0045;
/// Retro-block size in screen pixels (0 = no pixelation).
uniform float pixel : hint_range(0.0, 14.0) = 3.0;

vec2 warp_perspective(vec2 uv) {
	vec2 focus = vec2(0.5, 1.12);
	vec2 d = uv - focus;
	float widen = mix(0.58, 1.0, pow(clamp(uv.y, 0.0, 1.0), 0.82));
	d.x /= widen;
	return focus + d;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 warped = mix(uv, warp_perspective(uv), perspective_mix);
	warped.x += sin(warped.y * 32.0 + TIME * 22.0) * 0.0014 * speed_streak;
	warped = clamp(warped, vec2(0.001), vec2(0.999));

	if (pixel > 0.001) {
		vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
		vec2 blocks = res / pixel;
		warped = (floor(warped * blocks) + 0.5) / blocks;
	}

	vec3 col = texture(screen_texture, warped).rgb;
	float ax = chroma_strength * (0.35 + speed_streak);
	col.r = texture(screen_texture, warped + vec2(ax, 0.0)).r;
	col.b = texture(screen_texture, warped - vec2(ax, 0.0)).b;

	float lift = smoothstep(0.95, 0.35, length(uv - vec2(0.5, 0.38)));
	col *= mix(0.9, 1.08, lift);
	COLOR = vec4(col, 1.0);
}
