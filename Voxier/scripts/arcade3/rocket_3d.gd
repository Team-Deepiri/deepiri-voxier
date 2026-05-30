extends Node3D

const ImpactParticles3D := preload("res://scripts/juice/impact_particles_3d.gd")
const _APPROACH := 12.0

var is_rescue_pickup := false
var current_timer := 25.0
var exploding := false
var start_z := 0.0
var _land_global := Vector3.ZERO
var flame: CPUParticles3D


func _ready() -> void:
	_ensure_visuals()
	flame = get_node("Flame") as CPUParticles3D
	if not is_rescue_pickup:
		add_to_group("rocket")
	start_z = position.z


func _ensure_visuals() -> void:
	if get_node_or_null("Flame") != null:
		return
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.35
	cyl.bottom_radius = 0.28
	cyl.height = 1.4
	body.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.92, 0.38, 0.14)
	mat.metallic = 0.35
	mat.roughness = 0.42
	body.material_override = mat
	body.rotation_degrees = Vector3(90, 0, 0)
	body.position.y = 0.35
	add_child(body)
	var nose := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.12
	cone.bottom_radius = 0.32
	cone.height = 0.45
	nose.mesh = cone
	var nm := StandardMaterial3D.new()
	nm.albedo_color = Color(0.75, 0.88, 1.0)
	nm.metallic = 0.6
	nm.roughness = 0.25
	nose.material_override = nm
	nose.rotation_degrees = Vector3(-90, 0, 0)
	nose.position = Vector3(0, 0.95, 0.15)
	add_child(nose)
	var f := CPUParticles3D.new()
	f.name = "Flame"
	f.position = Vector3(0, 0.05, -0.75)
	f.emitting = true
	f.amount = 36
	f.lifetime = 0.32
	f.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	f.emission_sphere_radius = 0.12
	f.direction = Vector3(0, 0, -1)
	f.spread = 28.0
	f.gravity = Vector3(0, -1.5, 0)
	f.initial_velocity_min = 1.2
	f.initial_velocity_max = 3.2
	f.scale_amount_min = 0.06
	f.scale_amount_max = 0.18
	f.color = Color(1, 0.55, 0.12, 1)
	add_child(f)


func configure_rescue(start_g: Vector3, land_g: Vector3) -> void:
	is_rescue_pickup = true
	global_position = start_g
	_land_global = land_g
	visible = true
	var to := land_g - start_g
	to.y = 0.0
	if to.length() > 0.2:
		rotation.y = atan2(to.x, to.z)
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
		to.y = 0.0
		if to.length() > 0.35:
			global_position += to.normalized() * _APPROACH * delta
			rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), 6.0 * delta)
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
	position.z = start_z + sin(Time.get_ticks_msec() / 1000.0 * 3.2) * 0.12
	rotation.y = lerp_angle(rotation.y, 0.0, 4.0 * delta)
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
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena:
		ImpactParticles3D.burst(arena, global_position, Color(1.0, 0.55, 0.15), 56)
	EventBus.camera_shake_requested.emit(0.82)
	EventBus.sfx_requested.emit(&"explosion")
	GameManager.on_rocket_exploded()
	spawn_new()


func spawn_new() -> Node3D:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var arena := scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return null
	var new_r: Node3D = load("res://scenes/rocket_3d.tscn").instantiate()
	new_r.is_rescue_pickup = true
	arena.add_child(new_r)
	new_r.add_to_group("rocket_pickup")
	new_r.deactivate()
	var pg := scene.get_node_or_null("%Player") as Node3D
	var ppos := pg.global_position if pg else Arena3D.PLAYER_START
	var start := ppos + Vector3(10.0 + Arena3D.RESCUE_APPROACH, 0.4, randf_range(-2.0, 3.0))
	var land := ppos + Vector3(randf_range(-3.5, 3.5), 0.4, randf_range(0.5, 3.5))
	new_r.configure_rescue(start, land)
	GameManager.new_rocket = new_r
	EventBus.sfx_requested.emit(&"rocket_spawn")
	return new_r


func activate() -> void:
	add_to_group("rocket")
	remove_from_group("rocket_pickup")
	exploding = false
	visible = true
	current_timer = GameManager.rocket_timer
	start_z = position.z
	rotation = Vector3.ZERO
	if flame:
		flame.emitting = true


func deactivate() -> void:
	if flame:
		flame.emitting = false


func rocket_dead() -> void:
	queue_free()
