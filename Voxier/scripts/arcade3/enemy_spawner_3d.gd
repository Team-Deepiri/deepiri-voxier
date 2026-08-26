extends Node

const MAX_ENEMIES := 28
const SPAWN_INTERVAL := 1.85
const MIN_INTERVAL := 0.42
const SPAWN_RING_OFFSET := 2.2

var spawn_timer := 0.0
var difficulty := 1.0
var active_count := 0
var is_spawning := false


func current_menace() -> float:
	return Outer.sample().menace


func active_limit() -> int:
	return MAX_ENEMIES + int(round((current_menace() - 1.0) * 6.0))


func _ready() -> void:
	add_to_group("enemy_spawner")


func _process(delta: float) -> void:
	if not is_spawning or GameManager.state != GameManager.GameState.PLAYING:
		return
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		var menace := current_menace()
		spawn_timer = max(MIN_INTERVAL, (SPAWN_INTERVAL - difficulty * 0.035) / menace)
		difficulty += 0.04 * delta


func start_spawning() -> void:
	is_spawning = true
	spawn_timer = 0.15
	difficulty = 1.0


func stop_spawning() -> void:
	is_spawning = false


func get_active_enemy_count() -> int:
	return active_count


func spawn_enemy() -> void:
	if active_count >= active_limit():
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var arena := scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return
	var etype := get_weighted_type()
	var enemy: Area3D = load("res://scenes/enemy_3d.tscn").instantiate()
	# Assign the type BEFORE add_child so _ready()/setup_enemy() see it.
	enemy.enemy_type = etype
	arena.add_child(enemy)
	enemy.global_position = _ring_spawn_position()
	
	active_count += 1
	enemy.tree_exiting.connect(_on_enemy_left_tree)


## Horde ring: every spawn is at the player's flanks or ahead — nothing behind.
func _ring_spawn_position() -> Vector3:
	var roll := randf()
	var pz := _player_z()
	var x := 0.0
	var z := 0.0
	if roll < 0.5:
		# Far edge — most common
		x = randf_range(Arena3D.X_MIN + 0.5, Arena3D.X_MAX - 0.5)
		z = randf_range(Arena3D.Z_ENEMY_SPAWN_MIN, Arena3D.Z_ENEMY_SPAWN_MAX)
	elif roll < 0.8:
		# Side flanks — alongside the player, stretching forward
		x = Arena3D.X_MIN - SPAWN_RING_OFFSET if randf() < 0.5 else Arena3D.X_MAX + SPAWN_RING_OFFSET
		z = pz + randf_range(-2.0, 12.0)
	else:
		# Close flanks — right at the player's sides, least common
		x = Arena3D.X_MIN - SPAWN_RING_OFFSET * 0.6 if randf() < 0.5 else Arena3D.X_MAX + SPAWN_RING_OFFSET * 0.6
		z = pz + randf_range(-1.0, 2.0)
	return Vector3(x, 0.5, z)


func _player_z() -> float:
	if GameManager.player:
		return GameManager.player.global_position.z
	return Arena3D.PLAYER_START.z


func _on_enemy_left_tree() -> void:
	active_count = maxi(0, active_count - 1)


func get_weighted_type() -> int:
	var pool := Outer.current_pool()
	if not pool.is_empty():
		var key := ""
		var total := 0.0
		for e in pool:
			total += e.weight
		var r := randf() * total
		var acc := 0.0
		for e in pool:
			acc += e.weight
			if r < acc:
				key = str(e.key)
				break
		var idx := key.trim_prefix("kind_").to_int()
		if idx >= 0 and idx <= 3:
			return idx
	var fallback := randf()
	if difficulty < 3.5:
		if fallback < 0.68:
			return 0
		if fallback < 0.93:
			return 1
		return 2
	elif difficulty < 7.0:
		if fallback < 0.52:
			return 0
		if fallback < 0.82:
			return 1
		return 2
	if fallback < 0.38:
		return 0
	if fallback < 0.72:
		return 1
	return 2
