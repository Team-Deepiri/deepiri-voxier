extends Area3D

enum EnemyType { DRONE, FIGHTER, MOTHER }

const ImpactParticles3D := preload("res://scripts/juice/impact_particles_3d.gd")
const Bullet3DScene := preload("res://scenes/bullet_3d.tscn")

const SEP_RADIUS := 1.45
const COHESION_RADIUS := 4.0
const BOUNDARY_MARGIN := 0.8
const FIGHTER_ORBIT_RADIUS := 5.0
const FIGHTER_BULLET_SPEED := 13.0
const STRAFE_FLIP_MIN := 1.6
const STRAFE_FLIP_MAX := 3.4

@export var enemy_type := EnemyType.DRONE

var health := 1
var score_value := 100
var move_speed := 5.2
var fire_rate := 0.8
var accel := 20.0
var sep_weight := 1.6

var _vel := Vector3.ZERO
var _fire_cd := 0.0
var _strafe_dir := 1
var _strafe_flip_timer := 2.0
var _menace_scale := 1.0
var _neighbors: Array = []

@onready var _mesh: MeshInstance3D = $MeshInstance3D
var _mesh_mat: StandardMaterial3D
var player: Node3D
var _tint := Color.WHITE


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")
	setup_enemy()
	_apply_visual()
	_strafe_dir = 1 if randf() < 0.5 else -1
	_strafe_flip_timer = randf_range(STRAFE_FLIP_MIN, STRAFE_FLIP_MAX)
	var menace := Outer.sample().menace
	_menace_scale = 0.92 + 0.12 * menace
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
	var district_tint := Color.WHITE
	var env := Outer.sample()
	if env.district_id != "":
		district_tint = env.flame_color
	mat.albedo_color = district_tint
	match enemy_type:
		EnemyType.DRONE:
			mat.albedo_color = Color(1.0, 0.35, 0.42).lerp(district_tint, 0.45)
		EnemyType.FIGHTER:
			mat.albedo_color = Color(0.55, 0.85, 1.0).lerp(district_tint, 0.45)
		EnemyType.MOTHER:
			mat.albedo_color = Color(0.82, 0.45, 1.0).lerp(district_tint, 0.45)
	_tint = mat.albedo_color
	_scale_visual()


func _scale_visual() -> void:
	match enemy_type:
		EnemyType.DRONE:
			scale = Vector3.ONE
		EnemyType.FIGHTER:
			scale = Vector3(1.15, 1.15, 1.15)
		EnemyType.MOTHER:
			scale = Vector3(1.55, 1.55, 1.55)


func setup_enemy() -> void:
	match enemy_type:
		EnemyType.DRONE:
			health = 1
			score_value = 100
			move_speed = 4.6
			fire_rate = 0.0
			accel = 20.0
			sep_weight = 1.6
		EnemyType.FIGHTER:
			health = 2
			score_value = 250
			move_speed = 5.4
			fire_rate = 0.35
			accel = 24.0
			sep_weight = 0.9
		EnemyType.MOTHER:
			health = 10
			score_value = 1000
			move_speed = 2.2
			fire_rate = 0.0
			accel = 7.0
			sep_weight = 0.25


func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	if player and not is_instance_valid(player):
		player = null

	_neighbors = get_tree().get_nodes_in_group("enemy")
	var desired := _desired_velocity(delta)
	_vel = _vel.move_toward(desired, accel * delta)
	global_position += _vel * delta
	global_position.y = 0.5
	_update_bank(delta)

	if fire_rate > 0.0 and player:
		_fire_cd -= delta
		if _fire_cd <= 0.0 and _player_distance() < FIGHTER_ORBIT_RADIUS * 1.6:
			_fire_at_player()
			_fire_cd = 1.0 / fire_rate


## Horde brains: per-type steering recipe blended into one desired velocity.
func _desired_velocity(delta: float) -> Vector3:
	var speed := move_speed * _menace_scale
	var target_pos := player.global_position if player else global_position + Vector3(0, 0, -4.0)
	var desired := Vector3.ZERO
	match enemy_type:
		EnemyType.DRONE:
			desired += Steering3D.seek(global_position, target_pos, speed)
			desired += Steering3D.separation(global_position, _neighbors, SEP_RADIUS * SEP_RADIUS, speed, self) * sep_weight
			var center := Steering3D.cohesion_point(global_position, _neighbors, COHESION_RADIUS * COHESION_RADIUS, self)
			if center != Vector3.ZERO:
				desired += Steering3D.seek(global_position, center, speed) * 0.25
		EnemyType.FIGHTER:
			_strafe_flip_timer -= delta
			if _strafe_flip_timer <= 0.0:
				_strafe_dir = -_strafe_dir
				_strafe_flip_timer = randf_range(STRAFE_FLIP_MIN, STRAFE_FLIP_MAX)
			# Fly straight onto the engagement ring and hold it — no dive-in.
			desired += Steering3D.orbit(global_position, target_pos, FIGHTER_ORBIT_RADIUS, _strafe_dir, speed)
			desired += Steering3D.separation(global_position, _neighbors, SEP_RADIUS * SEP_RADIUS, speed, self) * sep_weight
		EnemyType.MOTHER:
			desired += Steering3D.seek(global_position, target_pos, speed)
			desired += Steering3D.separation(global_position, _neighbors, SEP_RADIUS * SEP_RADIUS, speed, self) * sep_weight
	desired += Steering3D.boundary_force(
		global_position,
		Arena3D.X_MIN, Arena3D.X_MAX, Arena3D.Z_MIN, Arena3D.Z_MAX,
		BOUNDARY_MARGIN, speed * 2.0
	)
	return desired.limit_length(speed * 1.6)


func _player_distance() -> float:
	if player == null:
		return INF
	var d := global_position - player.global_position
	d.y = 0.0
	return d.length()


## Bank the mesh into lateral movement so the horde reads as alive.
func _update_bank(_delta: float) -> void:
	var bank := clampf(-_vel.x * 0.07, -0.45, 0.45)
	_mesh.rotation.z = lerpf(_mesh.rotation.z, bank, 0.18)


func _fire_at_player() -> void:
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return
	var aim := (player.global_position + Vector3(0, 0.55, 0)) - global_position
	aim.y = absf(aim.y) * 0.5 + 0.12
	var dir := aim.normalized()
	var bullet: Area3D = Bullet3DScene.instantiate()
	bullet.is_player_bullet = false
	bullet.custom_direction = dir
	bullet.speed = FIGHTER_BULLET_SPEED
	arena.add_child(bullet)
	bullet.global_position = global_position + dir * 0.75


func take_damage(dmg: int) -> void:
	health -= dmg
	EventBus.sfx_requested.emit(&"hit")
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
	if randf() < 0.25:
		spawn_powerup()
	queue_free()


func spawn_powerup() -> void:
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return
	_add_powerup.call_deferred(arena, global_position)

func _add_powerup(arena: Node3D, drop_position: Vector3) -> void:
	var powerup: Area3D = load("res://scenes/powerup_3d.tscn").instantiate()
	powerup.powerup_type = randi() % 3
	arena.add_child(powerup)
	powerup.global_position = drop_position



func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.damage)
		area.queue_free()
		return
	var par := area.get_parent()
	if par and par.is_in_group("player"):
		GameManager.on_player_hit()
