extends Node3D

@export var target_path: NodePath = NodePath()
@export var follow_height := 5.0
@export var follow_distance := 10.0
@export var follow_smoothing := 6.0
@export_range(-90.0, 90.0, 0.1) var pitch_degrees := -12.0

var _target_pos := Vector3.ZERO


func _ready() -> void:
	var tgt := get_node_or_null(target_path) as Node3D
	if tgt:
		_target_pos = tgt.global_position
		global_position = tgt.global_position + Vector3(0, follow_height, -follow_distance)
	rotation_degrees = Vector3(pitch_degrees, 180, 0)


func _process(delta: float) -> void:
	var tgt := get_node_or_null(target_path) as Node3D
	if not tgt:
		return
	# Keep the camera horizontally level with the player offset and fixed tilt.
	_target_pos = Vector3(tgt.global_position.x, follow_height, tgt.global_position.z - follow_distance)
	global_position = global_position.lerp(_target_pos, 1.0 - exp(-follow_smoothing * delta))
