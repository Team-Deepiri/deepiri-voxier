extends CharacterBody2D

const MOVE_SPEED := 300.0
const FIRE_COOLDOWN := 0.11
const ImpactParticles := preload("res://scripts/juice/impact_particles.gd")

var move_vel := Vector2.ZERO
var current_rocket: Node2D
var is_alive := true
var falling := false
var _fire_cd := 0.0
var _invuln := 0.0

@onready var body: Polygon2D = $Body
@onready var head: Polygon2D = $Head
@onready var fire_point: Marker2D = $FirePoint

func _ready() -> void:
	add_to_group("player")

func is_invulnerable() -> bool:
	return _invuln > 0.0

func apply_hit_stun() -> void:
	_invuln = 2.1
	var tw := create_tween()
	for _i in range(9):
		tw.tween_property(self, "modulate:a", 0.28, 0.07)
		tw.tween_property(self, "modulate:a", 1.0, 0.07)
	tw.tween_callback(func(): modulate = Color(1, 1, 1, 1))

func clear_hit_stun() -> void:
	_invuln = 0.0
	modulate = Color(1, 1, 1, 1)

func _physics_process(delta: float) -> void:
	if _invuln > 0.0:
		_invuln = maxf(0.0, _invuln - delta)
	if _fire_cd > 0.0:
		_fire_cd = maxf(0.0, _fire_cd - delta)
	if not is_alive:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if GameManager.state == GameManager.GameState.FALLING and falling:
		velocity = Vector2(0, 60)
		move_and_slide()
		return
	if GameManager.state != GameManager.GameState.PLAYING:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		input.x = -1
	elif Input.is_action_pressed("move_right"):
		input.x = 1
	if Input.is_action_pressed("move_up"):
		input.y = 1
	elif Input.is_action_pressed("move_down"):
		input.y = -1
	move_vel = input.normalized() * MOVE_SPEED
	velocity = move_vel
	move_and_slide()
	position.x = clampf(position.x, 40, 760)
	position.y = clampf(position.y, 200, 560)
	if velocity.x < 0:
		scale.x = -1
	elif velocity.x > 0:
		scale.x = 1
	if Input.is_action_pressed("fire") and fire_point and _fire_cd <= 0.0:
		fire()
		_fire_cd = FIRE_COOLDOWN

func fire() -> void:
	EventBus.sfx_requested.emit(&"fire")
	var bullet: Area2D = load("res://scenes/bullet.tscn").instantiate()
	bullet.position = fire_point.global_position
	bullet.is_player_bullet = true
	get_tree().current_scene.add_child(bullet)

func mount_rocket(rocket_node: Node2D) -> void:
	current_rocket = rocket_node
	falling = false
	if current_rocket:
		current_rocket.position = position + Vector2(0, -70)

func dismount_rocket() -> void:
	current_rocket = null
	falling = true

func die_visual_only() -> void:
	is_alive = false
	visible = false
	var scene := get_tree().current_scene
	if scene:
		ImpactParticles.burst(scene, global_position, Color(1, 0.35, 0.2), 40)

func revive() -> void:
	is_alive = true
	visible = true
	falling = false
	position = Vector2(400, 480)
	modulate = Color.WHITE
	_invuln = 0.0

func _on_area_entered(area: Area2D) -> void:
	if not is_alive or GameManager.state != GameManager.GameState.PLAYING:
		return
	if is_invulnerable():
		return
	if area.is_in_group("enemy") or area.is_in_group("enemy_bullet"):
		GameManager.on_player_hit()
