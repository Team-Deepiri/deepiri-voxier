extends Area2D

enum EnemyType { DRONE, FIGHTER, MOTHER }

const ImpactParticles := preload("res://scripts/juice/impact_particles.gd")

@export var enemy_type := EnemyType.DRONE

var health := 1
var score_value := 100
var move_speed := 150.0
var fire_rate := 0.5
var zigzag := false

@onready var _poly: Polygon2D = $Polygon2D
var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")
	setup_enemy()
	_apply_visual()

func _apply_visual() -> void:
	match enemy_type:
		EnemyType.DRONE:
			_poly.color = Color(1.0, 0.35, 0.42, 1)
			scale = Vector2(1.0, 1.0)
		EnemyType.FIGHTER:
			_poly.color = Color(0.55, 0.85, 1.0, 1)
			scale = Vector2(1.15, 1.15)
		EnemyType.MOTHER:
			_poly.color = Color(0.82, 0.45, 1.0, 1)
			scale = Vector2(1.55, 1.55)

func setup_enemy() -> void:
	match enemy_type:
		EnemyType.DRONE:
			health = 1
			score_value = 100
			move_speed = 150
			fire_rate = 0.5
			zigzag = true
		EnemyType.FIGHTER:
			health = 2
			score_value = 250
			move_speed = 200
			fire_rate = 0.8
		EnemyType.MOTHER:
			health = 10
			score_value = 1000
			move_speed = 50
			fire_rate = 1.5

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	position.y -= move_speed * delta
	if zigzag:
		position.x += sin(Time.get_ticks_msec() / 1000.0 * 3.1) * 52.0 * delta
	if player and is_instance_valid(player):
		var hx := 0.2
		match enemy_type:
			EnemyType.FIGHTER:
				hx = 0.42
			EnemyType.MOTHER:
				hx = 0.07
			_:
				hx = 0.24
		position.x += (player.global_position.x - global_position.x) * hx * delta
	if position.y < -80:
		queue_free()

func take_damage(dmg: int) -> void:
	health -= dmg
	EventBus.sfx_requested.emit(&"hit")
	_flash_hit()
	if health <= 0:
		die()

func _flash_hit() -> void:
	var tw := create_tween()
	_poly.modulate = Color(3.0, 3.0, 3.0, 1)
	tw.tween_property(_poly, "modulate", Color.WHITE, 0.08)

func die() -> void:
	var scene := get_tree().current_scene
	if scene:
		ImpactParticles.burst(scene, global_position, _poly.color.lightened(0.2), 26)
	EventBus.camera_shake_requested.emit(0.14)
	EventBus.sfx_requested.emit(&"enemy_die")
	GameManager.add_score(score_value)
	if enemy_type == EnemyType.MOTHER and randf() < 0.32:
		spawn_powerup()
	queue_free()

func spawn_powerup() -> void:
	var powerup: Area2D = load("res://scenes/powerup.tscn").instantiate()
	powerup.position = position
	get_tree().current_scene.add_child(powerup)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.damage)
		area.queue_free()

func _on_timer_timeout() -> void:
	queue_free()
