extends Camera2D

var _trauma := 0.0
const TRAUMA_DECAY := 1.85
const SHAKE_MULT := 22.0

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
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return
	_trauma = maxf(0.0, _trauma - TRAUMA_DECAY * delta)
	var shake := _trauma * _trauma * SHAKE_MULT
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake
