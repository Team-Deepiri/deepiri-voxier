extends ColorRect
## Drives cinematic_post.gdshader from game state / player speed.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(_delta: float) -> void:
	var sm := material as ShaderMaterial
	if sm == null:
		return
	var streak := 0.12
	var persp := 0.38
	var st := GameManager.state
	if st == GameManager.GameState.PLAYING or st == GameManager.GameState.FALLING:
		var sp: float = 0.0
		var pl2 := GameManager.get_player_2d()
		if pl2:
			sp = pl2.velocity.length()
		else:
			var pl3 := GameManager.get_player_3d()
			if pl3:
				sp = pl3.velocity.length()
		streak = clampf(sp / 380.0, 0.0, 1.0) * 0.92
		if st == GameManager.GameState.FALLING:
			streak = maxf(streak, 0.55)
		persp = 0.44 + streak * 0.34
	sm.set_shader_parameter("speed_streak", streak)
	sm.set_shader_parameter("perspective_mix", persp)
