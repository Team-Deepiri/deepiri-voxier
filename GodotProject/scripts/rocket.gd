extends Node2D

const ImpactParticles := preload("res://scripts/juice/impact_particles.gd")

var current_timer := 25.0
var exploding := false
var start_y := 0.0

@onready var body: Polygon2D = $Body
@onready var flame: CPUParticles2D = $Flame

func _ready() -> void:
	add_to_group("rocket")
	start_y = position.y

func _process(delta: float) -> void:
	if exploding:
		current_timer -= delta
		if current_timer < -2:
			rocket_dead()
		return
	if GameManager.current_rocket != self:
		if flame:
			flame.emitting = false
		return
	if GameManager.state != GameManager.GameState.PLAYING:
		if flame:
			flame.emitting = false
		return
	GameManager.rocket_timer -= delta
	current_timer = GameManager.rocket_timer
	position.y = start_y + sin(Time.get_ticks_msec() / 1000.0 * 3.2) * 4.0
	if flame:
		flame.emitting = true
	if current_timer <= 0:
		explode()

func explode() -> void:
	if exploding:
		return
	exploding = true
	remove_from_group("rocket")
	visible = false
	if flame:
		flame.emitting = false
	current_timer = 2.0
	var scene := get_tree().current_scene
	if scene:
		ImpactParticles.burst(scene, global_position, Color(1.0, 0.55, 0.15), 48)
	EventBus.camera_shake_requested.emit(0.72)
	EventBus.sfx_requested.emit(&"explosion")
	GameManager.on_rocket_exploded()
	spawn_new()

func spawn_new() -> Node2D:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var new_r: Node2D = load("res://scenes/rocket.tscn").instantiate()
	new_r.position = Vector2(randf_range(120, 680), randf_range(90, 260))
	new_r.start_y = new_r.position.y
	scene.add_child(new_r)
	new_r.remove_from_group("rocket")
	new_r.add_to_group("rocket_pickup")
	new_r.deactivate()
	GameManager.new_rocket = new_r
	return new_r

func activate() -> void:
	add_to_group("rocket")
	remove_from_group("rocket_pickup")
	exploding = false
	visible = true
	current_timer = GameManager.rocket_timer
	start_y = position.y
	if flame:
		flame.emitting = true

func deactivate() -> void:
	if flame:
		flame.emitting = false

func rocket_dead() -> void:
	queue_free()
