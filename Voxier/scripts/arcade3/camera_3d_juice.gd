extends Camera3D
var _trauma := 0.0
const TRAUMA_DECAY := 1.85
const SHAKE_MULT := 0.45
const _BASE_FOV := 62.0
func _ready() -> void:
	EventBus.camera_shake_requested.connect(_on_shake_requested)
func _exit_tree() -> void:
	if EventBus.camera_shake_requested.is_connected(_on_shake_requested):
		EventBus.camera_shake_requested.disconnect(_on_shake_requested)
func _on_shake_requested(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)
func _process(delta: float) -> void:
	var target_fov := _BASE_FOV
	var pl := GameManager.get_player_3d()
	var st := GameManager.state
	if pl and (st == GameManager.GameState.PLAYING or st == GameManager.GameState.FALLING):
		var sp: float = pl.velocity.length()
		target_fov = _BASE_FOV + clampf(sp / 12.0, 0.0, 1.0) * 6.0
		if st == GameManager.GameState.FALLING:
			target_fov += 4.0
	elif st == GameManager.GameState.MENU:
		target_fov = _BASE_FOV
	set_fov(lerpf(get_fov(), target_fov, 1.0 - exp(-5.0 * delta)))
	if _trauma <= 0.0:
		h_offset = 0.0
		v_offset = 0.0
		return
	_trauma = maxf(0.0, _trauma - TRAUMA_DECAY * delta)
	var shake := _trauma * _trauma * SHAKE_MULT
	h_offset = randf_range(-1.0, 1.0) * shake
	v_offset = randf_range(-1.0, 1.0) * shake
