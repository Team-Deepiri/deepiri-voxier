extends Node2D

const ImpactParticles := preload("res://scripts/juice/impact_particles.gd")
const _APPROACH_SPEED := 560.0

var is_rescue_pickup := false
var current_timer := 25.0
var exploding := false
var start_y := 0.0
var _land_global := Vector2.ZERO
var flame: CPUParticles2D

func _ready() -> void:
	_ensure_rocket_visuals()
	flame = get_node("Flame") as CPUParticles2D
	if not is_rescue_pickup:
		add_to_group("rocket")
	start_y = position.y

func _ensure_rocket_visuals() -> void:
	if get_node_or_null("Flame") != null:
		return
	var body := Polygon2D.new()
	body.name = "Body"
	body.color = Color(0.95, 0.38, 0.16, 1)
	body.polygon = PackedVector2Array([
		Vector2(-16, -28), Vector2(16, -28), Vector2(13, 28), Vector2(-13, 28)
	])
	add_child(body)
	var stripe := Polygon2D.new()
	stripe.name = "Stripe"
	stripe.position = Vector2(0, 4)
	stripe.color = Color(0.2, 0.55, 0.95, 1)
	stripe.polygon = PackedVector2Array([
		Vector2(-10, -4), Vector2(10, -4), Vector2(9, 4), Vector2(-9, 4)
	])
	add_child(stripe)
	var window := Polygon2D.new()
	window.name = "Window"
	window.position = Vector2(0, -12)
	window.color = Color(0.75, 0.88, 1, 1)
	window.polygon = PackedVector2Array([
		Vector2(-6, -6), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)
	])
	add_child(window)
	var fins := Polygon2D.new()
	fins.name = "Fins"
	fins.color = Color(0.72, 0.22, 0.12, 1)
	fins.polygon = PackedVector2Array([
		Vector2(-22, 14), Vector2(-12, 14), Vector2(-12, 24), Vector2(-22, 24)
	])
	add_child(fins)
	var finr := Polygon2D.new()
	finr.name = "FinR"
	finr.scale = Vector2(-1, 1)
	finr.color = fins.color
	finr.polygon = fins.polygon
	add_child(finr)
	var f := CPUParticles2D.new()
	f.name = "Flame"
	f.position = Vector2(0, 30)
	f.emitting = true
	f.amount = 28
	f.lifetime = 0.32
	f.emission_shape = 2
	f.emission_sphere_radius = 6.0
	f.direction = Vector2(0, 1)
	f.spread = 32.0
	f.gravity = Vector2(0, 220)
	f.initial_velocity_min = 55.0
	f.initial_velocity_max = 115.0
	f.scale_amount_min = 2.0
	f.scale_amount_max = 5.5
	f.color = Color(1, 0.55, 0.12, 1)
	add_child(f)

func configure_rescue(start_global: Vector2, land_global: Vector2) -> void:
	is_rescue_pickup = true
	global_position = start_global
	_land_global = land_global
	visible = true
	var to := land_global - start_global
	if to.length() > 4.0:
		rotation = atan2(to.y, to.x) + PI * 0.5
	if flame:
		flame.emitting = true

func _process(delta: float) -> void:
	if exploding:
		current_timer -= delta
		if current_timer < -2:
			rocket_dead()
		return

	if is_rescue_pickup and GameManager.new_rocket == self:
		var to := _land_global - global_position
		if to.length() > 12.0:
			global_position += to.normalized() * _APPROACH_SPEED * delta
			rotation = lerp_angle(rotation, atan2(to.y, to.x) + PI * 0.5, 6.0 * delta)
		else:
			rotation = lerp_angle(rotation, 0.0, 5.0 * delta)
		if flame:
			flame.emitting = true
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
	rotation = lerp_angle(rotation, 0.0, 4.0 * delta)
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
		ImpactParticles.burst(scene, global_position, Color(1.0, 0.55, 0.15), 56)
	EventBus.camera_shake_requested.emit(0.82)
	EventBus.sfx_requested.emit(&"explosion")
	GameManager.on_rocket_exploded()
	spawn_new()

func spawn_new() -> Node2D:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var new_r: Node2D = load("res://scenes/rocket.tscn").instantiate()
	new_r.is_rescue_pickup = true
	scene.add_child(new_r)
	new_r.add_to_group("rocket_pickup")
	new_r.deactivate()
	var pg := scene.get_node_or_null("Player") as Node2D
	var ppos := pg.global_position if pg else Vector2(400, 440)
	var start := ppos + Vector2(820, randf_range(-140, 90))
	var land := ppos + Vector2(randf_range(-160, 160), randf_range(130, 270))
	new_r.configure_rescue(start, land)
	GameManager.new_rocket = new_r
	return new_r

func activate() -> void:
	add_to_group("rocket")
	remove_from_group("rocket_pickup")
	exploding = false
	visible = true
	current_timer = GameManager.rocket_timer
	start_y = position.y
	rotation = 0.0
	if flame:
		flame.emitting = true

func deactivate() -> void:
	if flame:
		flame.emitting = false

func rocket_dead() -> void:
	queue_free()
