extends CharacterBody3D

const MOVE_SPEED := 7.5
const FIRE_COOLDOWN := 0.11
const ImpactParticles3D := preload("res://scripts/juice/impact_particles_3d.gd")

var move_vel := Vector3.ZERO
var current_rocket: Node3D
var is_alive := true
var falling := false
var _fire_cd := 0.0
var _invuln := 0.0
var _hero: Sprite3D
@onready var _mesh: MeshInstance3D = $MeshInstance3D
var _mesh_mat: StandardMaterial3D
#mesh mat to add color/flashes without changing texture

@onready var fire_point: Marker3D = $FirePoint


func _ready() -> void:
	add_to_group("player")
	_setup_hero_sprite()
	call_deferred("_setup_material")

#set up the mesh_mat for the damage indicator
func _setup_material() -> void:
	var mat := StandardMaterial3D.new()
	mat.flags_transparent = true
	mat.albedo_color = Color.WHITE
	
	for i in _mesh.get_surface_override_material_count():
		_mesh.set_surface_override_material(i, mat)
	_mesh_mat = mat

func _setup_hero_sprite() -> void:
	_hero = Sprite3D.new()
	_hero.name = "HeroSprite3D"
	_hero.texture = FoxTextureBuilder.create_texture()
	_hero.pixel_size = 0.012
	_hero.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_hero.position = Vector3(0, 0.85, 0)
	_hero.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.albedo_texture = _hero.texture
	_hero.material_override = sm
	add_child(_hero)


func is_invulnerable() -> bool:
	return _invuln > 0.0


func apply_hit_stun() -> void:
	_invuln = 2.1
	var tw := create_tween()
	for _i in range(9):
		tw.tween_property(_mesh_mat, "albedo_color:a", 0.28, 0.07)
		tw.tween_property(_mesh_mat, "albedo_color:a", 1.0, 0.07)
	tw.tween_callback(func(): _mesh_mat.albedo_color = Color(1, 1, 1, 1))

func clear_hit_stun() -> void:
	_invuln = 0.0
	if _mesh_mat:
		_mesh_mat.albedo_color = Color(1, 1, 1, 1)


func _physics_process(delta: float) -> void:
	if _invuln > 0.0:
		_invuln = maxf(0.0, _invuln - delta)
	if _fire_cd > 0.0:
		_fire_cd = maxf(0.0, _fire_cd - delta)
	if not is_alive:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	if GameManager.state == GameManager.GameState.FALLING and falling:
		velocity = Vector3(0, 0, -3.2)
		move_and_slide()
		return
	if GameManager.state != GameManager.GameState.PLAYING:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	var input := Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		input.x = -1
	elif Input.is_action_pressed("move_right"):
		input.x = 1
	if Input.is_action_pressed("move_up"):
		input.z = 1
	elif Input.is_action_pressed("move_down"):
		input.z = -1
	move_vel = input.normalized() * MOVE_SPEED
	velocity = move_vel
	move_and_slide()
	global_position.x = clampf(global_position.x, Arena3D.X_MIN, Arena3D.X_MAX)
	global_position.z = clampf(global_position.z, Arena3D.Z_MIN, Arena3D.Z_MAX)
	if velocity.x < -0.05:
		_hero.rotation.y = PI
	elif velocity.x > 0.05:
		_hero.rotation.y = 0.0
	if Input.is_action_pressed("fire") and fire_point and _fire_cd <= 0.0:
		fire()
		_fire_cd = FIRE_COOLDOWN


func fire() -> void:
	EventBus.sfx_requested.emit(&"fire")
	var bullet: Area3D = load("res://scenes/bullet_3d.tscn").instantiate()
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return
	arena.add_child(bullet)
	bullet.global_position = fire_point.global_position
	bullet.is_player_bullet = true


func mount_rocket(rocket_node: Node3D) -> void:
	current_rocket = rocket_node
	falling = false
	if current_rocket:
		current_rocket.global_position = global_position + Arena3D.ROCKET_MOUNT_OFFSET


func dismount_rocket() -> void:
	current_rocket = null
	falling = true


func die_visual_only() -> void:
	is_alive = false
	visible = false
	if _hero:
		_hero.visible = false
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena:
		ImpactParticles3D.burst(arena, global_position + Vector3(0, 0.5, 0), Color(1, 0.35, 0.2), 40)


func revive() -> void:
	is_alive = true
	visible = true
	if _hero:
		_hero.visible = true
	falling = false
	global_position = Arena3D.PLAYER_START
	if _mesh_mat:
		_mesh_mat.albedo_color = Color.WHITE
	_invuln = 0.0


func _on_hurt_area_entered(area: Area3D) -> void:
	if not is_alive or GameManager.state != GameManager.GameState.PLAYING:
		return
	if is_invulnerable():
		return
	if area.is_in_group("enemy") or area.is_in_group("enemy_bullet"):
		GameManager.on_player_hit()


#Allows the color to be changed externally, such as in the GameManager
func set_tint(color: Color) -> void:
	if _mesh_mat:
		_mesh_mat.albedo_color = color
