extends CharacterBody3D

const MOVE_SPEED := 7.5
const FIRE_COOLDOWN := 0.11
const RAPID_FIRE_COOLDOWN := 0.05
const POWERUP_DURATION := 6.0
const BOB_AMP := 0.05
const BOB_FREQ := 13.0
const MAX_TILT := 0.18
const LUNGE_AMP := 0.08
const SQUASH_MAX := 0.07
const ImpactParticles3D := preload("res://scripts/juice/impact_particles_3d.gd")
const PowerupType := preload("res://scripts/game_enums.gd").PowerupType

var move_vel := Vector3.ZERO
var current_rocket: Node3D
var is_alive := true
var falling := false
var _fire_cd := 0.0
var _invuln := 0.0
var _hero: Sprite3D
var _active_powerup := -1
var _powerup_timer := 0.0
var _shield: MeshInstance3D
var _hero_pivot: Node3D
var _walk_phase := 0.0
var _hero_base_y := 0.0
var _flip := 1
@onready var _mesh: MeshInstance3D = $MeshInstance3D
var _mesh_mat: StandardMaterial3D
#mesh mat to add color/flashes without changing texture

@onready var fire_point: Marker3D = $FirePoint


func _ready() -> void:
	add_to_group("player")
	_setup_hero_sprite()
	_setup_shield_visual()
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
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_hero.material_override = sm
	var pivot := Node3D.new()
	pivot.name = "HeroPivot"
	_hero_pivot = pivot
	add_child(pivot)
	pivot.add_child(_hero)
	_hero_base_y = _hero.position.y


func is_invulnerable() -> bool:
	return _invuln > 0.0 or _active_powerup == PowerupType.SHIELD

func apply_powerup(type: int) -> void:
	_active_powerup = type
	_powerup_timer = POWERUP_DURATION
	if _shield:
		_shield.visible = type == PowerupType.SHIELD

func _end_powerup() -> void:
	_active_powerup = -1
	_powerup_timer = 0.0
	if _shield:
		_shield.visible = false

func _setup_shield_visual() -> void:
	_shield = MeshInstance3D.new()
	_shield.name = "Shield"
	var sm := SphereMesh.new()
	sm.radius = 0.72
	sm.height = 1.44
	_shield.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(0.3, 0.9, 1.0, 0.25)
	_shield.material_override = mat
	_shield.position = Vector3(0, 0.72, 0)
	_shield.visible = false
	add_child(_shield)

func apply_hit_stun() -> void:
	_invuln = 2.1
	var tw := create_tween()
	for _i in range(9):
		tw.tween_property(_mesh_mat, "albedo_color:a", 0.28, 0.07)
		tw.tween_property(_mesh_mat, "albedo_color:a", 1.0, 0.07)
	tw.tween_callback(func(): _mesh_mat.albedo_color = Color(1, 1, 1, 1))

func clear_hit_stun() -> void:
	_invuln = 0.0
	_end_powerup()
	if _mesh_mat:
		_mesh_mat.albedo_color = Color(1, 1, 1, 1)


func _physics_process(delta: float) -> void:
	if _invuln > 0.0:
		_invuln = maxf(0.0, _invuln - delta)
	if _fire_cd > 0.0:
		_fire_cd = maxf(0.0, _fire_cd - delta)
	if _active_powerup != -1:
		_powerup_timer -= delta
		if _powerup_timer <= 0.0:
			_end_powerup()
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
		_flip = -1
	elif velocity.x > 0.05:
		_flip = 1
	_update_movement_anim(delta)

	if Input.is_action_pressed("fire") and fire_point and _fire_cd <= 0.0:
		fire()
		_fire_cd = FIRE_COOLDOWN if _active_powerup != PowerupType.RAPID else RAPID_FIRE_COOLDOWN


func fire() -> void:
	GameAudio.play_fire()
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena == null:
		return
	_spawn_bullet(fire_point.global_position, arena)
	if _active_powerup == PowerupType.MULTI:
		_spawn_bullet(fire_point.global_position + Vector3(-0.35, 0, 0.15), arena)
		_spawn_bullet(fire_point.global_position + Vector3(0.35, 0, 0.15), arena)

func _spawn_bullet(pos: Vector3, arena: Node3D) -> void:
	var bullet: Area3D = load("res://scenes/bullet_3d.tscn").instantiate()
	arena.add_child(bullet)
	bullet.global_position = pos
	bullet.is_player_bullet = true


func _update_movement_anim(delta: float) -> void:
	if not _hero:
		return
	var speed_ratio := move_vel.length() / MOVE_SPEED
	var moving := speed_ratio > 0.05
	if moving:
		_walk_phase += delta * BOB_FREQ * (0.55 + 0.45 * speed_ratio)
	else:
		_walk_phase += delta * 2.5
	var bob_amp := BOB_AMP * speed_ratio if moving else 0.02
	_hero.position.y = _hero_base_y + sin(_walk_phase) * bob_amp
	_hero.position.x = LUNGE_AMP * (move_vel.x / MOVE_SPEED) * speed_ratio
	var cam := get_viewport().get_camera_3d()
	if cam and _hero_pivot:
		var lean := (move_vel.x / MOVE_SPEED) * MAX_TILT
		_hero_pivot.basis = Basis(Quaternion(-cam.global_basis.z, lean))
	var sq := SQUASH_MAX * absf(move_vel.x / MOVE_SPEED)
	_hero.scale = Vector3(_flip * (1.0 - sq), 1.0 + sq, 1.0)


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
	_end_powerup()
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena:
		ImpactParticles3D.burst(arena, global_position + Vector3(0, 0.5, 0), Color(0.55, 0.32, 0.78), 40)


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
	_end_powerup()


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

