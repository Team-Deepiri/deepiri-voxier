extends Area3D

enum EnemyType { DRONE, FIGHTER, MOTHER }

const ImpactParticles3D := preload("res://scripts/juice/impact_particles_3d.gd")

@export var enemy_type := EnemyType.DRONE

var health := 1
var score_value := 100
var move_speed := 5.2
var fire_rate := 0.5
var zigzag := false

@onready var _mesh: MeshInstance3D = $MeshInstance3D
var _mesh_mat: StandardMaterial3D
var player: Node3D
var _tint := Color.WHITE


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")
	setup_enemy()
	_apply_visual()
	call_deferred("_setup_material")

#Set up a standardMaterial3D to get the flash on hit
func _setup_material() -> void:
	var mat := StandardMaterial3D.new()
	mat.flags_transparent = true
	mat.albedo_color = Color.WHITE
	for i in _mesh.get_surface_override_material_count():
		_mesh.set_surface_override_material(i, mat)
	_mesh_mat = mat


func _apply_visual() -> void:
	var mat := _mesh.get_active_material(0) as StandardMaterial3D
	if mat == null:
		return
	match enemy_type:
		EnemyType.DRONE:
			mat.albedo_color = Color(1.0, 0.35, 0.42)
			_tint = mat.albedo_color
			scale = Vector3.ONE
		EnemyType.FIGHTER:
			mat.albedo_color = Color(0.55, 0.85, 1.0)
			_tint = mat.albedo_color
			scale = Vector3(1.15, 1.15, 1.15)
		EnemyType.MOTHER:
			mat.albedo_color = Color(0.82, 0.45, 1.0)
			_tint = mat.albedo_color
			scale = Vector3(1.55, 1.55, 1.55)


func setup_enemy() -> void:
	match enemy_type:
		EnemyType.DRONE:
			health = 1
			score_value = 100
			move_speed = 5.2
			fire_rate = 0.5
			zigzag = true
		EnemyType.FIGHTER:
			health = 2
			score_value = 250
			move_speed = 6.8
			fire_rate = 0.8
			zigzag = true
		EnemyType.MOTHER:
			health = 10
			score_value = 1000
			move_speed = 2.4
			fire_rate = 1.5
			zigzag = false


func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	position.z -= move_speed * delta
	if zigzag:
		position.x += sin(Time.get_ticks_msec() / 1000.0 * 3.1) * 1.8 * delta
	if player and is_instance_valid(player):
		var hx := 0.22
		match enemy_type:
			EnemyType.FIGHTER:
				hx = 0.42
			EnemyType.MOTHER:
				hx = 0.06
			_:
				hx = 0.24
		position.x += (player.global_position.x - global_position.x) * hx * delta
	if position.z < Arena3D.Z_MIN - 4.0:
		queue_free()


func take_damage(dmg: int) -> void:
	health -= dmg
	_flash_hit()
	if health <= 0:
		die()


func _flash_hit() -> void:
	var tw := create_tween()
	_mesh_mat.albedo_color = Color(2.5, 2.5, 2.5, 1.0)
	tw.tween_property(_mesh_mat, "albedo_color", Color.WHITE, 0.08)


func die() -> void:
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena:
		ImpactParticles3D.burst(arena, global_position, _tint.lightened(0.2), 28)
	EventBus.camera_shake_requested.emit(0.14)
	EventBus.sfx_requested.emit(&"enemy_die")
	GameManager.add_score(score_value)
	if enemy_type == EnemyType.MOTHER and randf() < 0.32:
		spawn_powerup()
	queue_free()


func spawn_powerup() -> void:
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return
	var powerup: Area3D = load("res://scenes/powerup_3d.tscn").instantiate()
	arena.add_child(powerup)
	powerup.global_position = global_position



func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.damage)
		area.queue_free()
		return
	var par := area.get_parent()
	if par and par.is_in_group("player"):
		GameManager.on_player_hit()
