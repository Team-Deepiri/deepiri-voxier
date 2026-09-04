extends Node3D

@export var target_path: NodePath = NodePath()
@export var follow_height := 7.0
@export var follow_distance := 11.0
@export var follow_smoothing := 6.0
@export_range(-90.0, 90.0, 0.1) var pitch_degrees := -12.0

var _arena: Node3D


func _ready() -> void:
	_arena = get_node_or_null("%Arena") as Node3D
	var tgt := get_node_or_null(target_path) as Node3D
	if tgt:
		global_position = _desired_pos(tgt.global_position)
	rotation_degrees = Vector3(pitch_degrees, 180.0, 0)


func _process(delta: float) -> void:
	var tgt := get_node_or_null(target_path) as Node3D
	if not tgt:
		return
	# World-space follow — the arena rotates beneath the camera,
	# giving visible feedback on direction changes.
	var desired := tgt.global_position + Vector3(0, follow_height, -follow_distance)
	global_position = global_position.lerp(desired, 1.0 - exp(-follow_smoothing * delta))


func _desired_pos(player_global: Vector3) -> Vector3:
	return player_global + Vector3(0, follow_height, -follow_distance)
