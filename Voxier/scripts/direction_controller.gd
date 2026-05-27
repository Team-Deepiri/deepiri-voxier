extends Node

var current_dir := 0
var target_screen_angle := 0.0
var current_screen_angle := 0.0
var is_rotating := false

const ROTATION_DURATION := 0.8

const DIRECTION_NAMES = ["NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST"]

const SCREEN_ROTATIONS = {
	0: { "angle": 0.0, "cam_offset": Vector2(0, 0), "bg_shift": Vector2(0, 0) },
	1: { "angle": 50.0, "cam_offset": Vector2(25, -8), "bg_shift": Vector2(30, -15) },
	2: { "angle": 90.0, "cam_offset": Vector2(40, 0), "bg_shift": Vector2(50, 0) },
	3: { "angle": 140.0, "cam_offset": Vector2(25, 8), "bg_shift": Vector2(30, 15) },
	4: { "angle": 180.0, "cam_offset": Vector2(0, 12), "bg_shift": Vector2(0, 20) },
	5: { "angle": 230.0, "cam_offset": Vector2(-25, 8), "bg_shift": Vector2(-30, 15) },
	6: { "angle": 270.0, "cam_offset": Vector2(-40, 0), "bg_shift": Vector2(-50, 0) },
	7: { "angle": 310.0, "cam_offset": Vector2(-25, -8), "bg_shift": Vector2(-30, -15) }
}

@onready var camera: Camera2D
@onready var world_container: Node2D
@onready var bg_manager: Node

var rot_tween: Tween

func _ready():
	add_to_group("direction_controller")
	camera = get_viewport().get_camera_2d()
	world_container = get_node_or_null("../../WorldContainer")
	bg_manager = get_tree().get_first_node_in_group("background_manager")

func _process(delta):
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	
	if Input.is_action_just_pressed("turn_left"):
		turn(-1)
	elif Input.is_action_just_pressed("turn_right"):
		turn(1)

func turn(direction: int):
	current_dir = (current_dir + direction + 8) % 8
	target_screen_angle = SCREEN_ROTATIONS[current_dir]["angle"]
	is_rotating = true
	
	if rot_tween:
		rot_tween.kill()
	
	rot_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rot_tween.tween_property(camera, "rotation_degrees", target_screen_angle, ROTATION_DURATION)
	rot_tween.parallel().tween_property(camera, "position", Vector2(400, 300) + SCREEN_ROTATIONS[current_dir]["cam_offset"], ROTATION_DURATION)
	
	if world_container:
		rot_tween.parallel().tween_property(world_container, "rotation_degrees", -target_screen_angle, ROTATION_DURATION)
	
	apply_shift()
	
	rot_tween.finished.connect(finish_rotation)

func apply_shift():
	var shift = SCREEN_ROTATIONS[current_dir]["bg_shift"]
	if bg_manager:
		bg_manager.apply_shift(shift)
		if current_dir % 2 == 0:
			bg_manager.cycle_background()

func finish_rotation() -> void:
	if current_dir % 2 == 0:
		GameManager.add_score(200)
		EventBus.camera_shake_requested.emit(0.18)
		EventBus.sfx_requested.emit(&"rotate")

func get_direction_name() -> String:
	return DIRECTION_NAMES[current_dir]

func reset():
	current_dir = 0
	target_screen_angle = 0.0
	is_rotating = false
	if camera:
		camera.position = Vector2(400, 300)
		camera.rotation_degrees = 0
		camera.skew = 0.0
	if world_container:
		world_container.rotation_degrees = 0