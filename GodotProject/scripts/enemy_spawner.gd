extends Node

const MAX_ENEMIES := 18
const SPAWN_INTERVAL := 1.85
const MIN_INTERVAL := 0.42

var spawn_timer := 0.0
var difficulty := 1.0
var active_count := 0
var is_spawning := false

func _ready() -> void:
	add_to_group("enemy_spawner")

func _process(delta: float) -> void:
	if not is_spawning or GameManager.state != GameManager.GameState.PLAYING:
		return
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = max(MIN_INTERVAL, SPAWN_INTERVAL - difficulty * 0.035)
		difficulty += 0.04 * delta

func start_spawning() -> void:
	is_spawning = true
	spawn_timer = 0.15
	difficulty = 1.0

func stop_spawning() -> void:
	is_spawning = false

func spawn_enemy() -> void:
	if active_count >= MAX_ENEMIES:
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var etype := get_weighted_type()
	var enemy: Area2D = preload("res://scenes/enemy.tscn").instantiate()
	enemy.position = Vector2(randf_range(50, 750), -40)
	enemy.enemy_type = etype
	scene.add_child(enemy)
	active_count += 1
	enemy.tree_exiting.connect(_on_enemy_left_tree)

func _on_enemy_left_tree() -> void:
	active_count = maxi(0, active_count - 1)

func get_weighted_type() -> int:
	var r := randf()
	if difficulty < 3.5:
		if r < 0.68:
			return 0
		if r < 0.93:
			return 1
		return 2
	elif difficulty < 7.0:
		if r < 0.52:
			return 0
		if r < 0.82:
			return 1
		return 2
	if r < 0.38:
		return 0
	if r < 0.72:
		return 1
	return 2
