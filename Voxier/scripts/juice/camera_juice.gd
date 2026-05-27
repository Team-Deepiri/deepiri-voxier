extends Camera2D

var _trauma := 0.0
const TRAUMA_DECAY := 1.85
const SHAKE_MULT := 22.0
const MENU_CENTER := Vector2(400, 300)
const FOLLOW_OFFSET := Vector2(0, -78.0)
const _BASE_ZOOM := 1.02
const _ZOOM_SPEED_MAX := 0.09
const _SKEW_MAX := 0.045

func _ready() -> void:
	EventBus.camera_shake_requested.connect(_on_shake_requested)

func _exit_tree() -> void:
	if EventBus.camera_shake_requested.is_connected(_on_shake_requested):
		EventBus.camera_shake_requested.disconnect(_on_shake_requested)

func _on_shake_requested(amount: float) -> void:
	add_trauma(amount)

func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	var st := GameManager.state
	var follow := MENU_CENTER
	var pl := GameManager.player
	if st == GameManager.GameState.PLAYING or st == GameManager.GameState.FALLING:
		if pl and is_instance_valid(pl):
			var gp := pl.global_position
			follow = Vector2(gp.x, gp.y) + FOLLOW_OFFSET
	position = position.lerp(follow, 1.0 - exp(-4.25 * delta))

	var target_zoom := _BASE_ZOOM
	var target_skew := 0.0
	if pl and is_instance_valid(pl) and (
		st == GameManager.GameState.PLAYING or st == GameManager.GameState.FALLING
	):
		var sp := pl.velocity.length()
		target_zoom = _BASE_ZOOM + clampf(sp / 520.0, 0.0, 1.0) * _ZOOM_SPEED_MAX
		if st == GameManager.GameState.FALLING:
			target_zoom += 0.04
		target_skew = clampf(pl.velocity.x / 720.0, -1.0, 1.0) * _SKEW_MAX
	elif st == GameManager.GameState.MENU:
		target_zoom = 1.0
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 1.0 - exp(-5.0 * delta))
	skew = lerpf(skew, target_skew, 1.0 - exp(-4.5 * delta))

	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return
	_trauma = maxf(0.0, _trauma - TRAUMA_DECAY * delta)
	var shake := _trauma * _trauma * SHAKE_MULT
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake
