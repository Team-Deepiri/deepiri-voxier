extends Node

var current_dir := 0
var target_screen_angle := 0.0
var is_rotating := false

const ROTATION_DURATION := 0.8

const DIRECTION_NAMES = ["NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST"]

const SCREEN_ROTATIONS = {
	0: { "angle": 0.0, "bg_shift": Vector2(0, 0) },
	1: { "angle": 50.0, "bg_shift": Vector2(30, -15) },
	2: { "angle": 90.0, "bg_shift": Vector2(50, 0) },
	3: { "angle": 140.0, "bg_shift": Vector2(30, 15) },
	4: { "angle": 180.0, "bg_shift": Vector2(0, 20) },
	5: { "angle": 230.0, "bg_shift": Vector2(-30, 15) },
	6: { "angle": 270.0, "bg_shift": Vector2(-50, 0) },
	7: { "angle": 310.0, "bg_shift": Vector2(-30, -15) }
}

var rot_tween: Tween
var _arena: Node3D
var bg_manager: Node


func _ready() -> void:
	add_to_group("direction_controller")
	_arena = get_parent().get_node_or_null("%Arena") as Node3D
	bg_manager = get_tree().get_first_node_in_group("background_manager")


func _process(_delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	if Input.is_action_just_pressed("turn_left"):
		turn(-1)
	elif Input.is_action_just_pressed("turn_right"):
		turn(1)


func turn(direction: int) -> void:
	current_dir = (current_dir + direction + 8) % 8
	target_screen_angle = SCREEN_ROTATIONS[current_dir]["angle"]
	is_rotating = true
	if rot_tween:
		rot_tween.kill()
	rot_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if _arena:
		rot_tween.tween_property(_arena, "rotation_degrees:y", target_screen_angle, ROTATION_DURATION)
	apply_shift()
	rot_tween.finished.connect(finish_rotation, CONNECT_ONE_SHOT)


func apply_shift() -> void:
	var shift: Vector2 = SCREEN_ROTATIONS[current_dir]["bg_shift"]
	if bg_manager and bg_manager.has_method("apply_shift"):
		bg_manager.apply_shift(shift)
		if current_dir % 2 == 0 and bg_manager.has_method("cycle_background"):
			bg_manager.cycle_background()


func finish_rotation() -> void:
	is_rotating = false
	if current_dir % 2 == 0:
		GameManager.add_score(200)
		EventBus.camera_shake_requested.emit(0.18)
		EventBus.sfx_requested.emit(&"rotate")


func get_direction_name() -> String:
	return DIRECTION_NAMES[current_dir]


func reset() -> void:
	current_dir = 0
	target_screen_angle = 0.0
	is_rotating = false
	if _arena:
		_arena.rotation_degrees = Vector3(0, 0, 0)
