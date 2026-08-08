extends CPUParticles3D
## Forward speed streaks that amplify with travel velocity and adopt the
## current district's particle color.

var _player: Node3D


func _ready() -> void:
	_player = GameManager.get_player_3d()


func _process(delta: float) -> void:
	var st := GameManager.state
	var on := st == GameManager.GameState.PLAYING or st == GameManager.GameState.FALLING
	var speed_ratio := 0.0
	if on and _player:
		speed_ratio = clampf(_player.velocity.length() / 12.5, 0.0, 1.0)
	var running := on and speed_ratio > 0.02
	emitting = running
	if not running:
		return
	amount = int(round(speed_ratio * 90.0))
	var env := Outer.sample()
	color = env.particle_color.lerp(Color(0.7, 0.85, 1.0, 1.0), 0.3)
	color.a = 0.18 + 0.5 * speed_ratio