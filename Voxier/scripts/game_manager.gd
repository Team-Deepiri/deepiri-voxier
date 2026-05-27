extends Node

const _TUNE := preload("res://resources/game_tune_default.tres")
const _ImpactParticles3D := preload("res://scripts/juice/impact_particles_3d.gd")

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, FALLING, ROCKET_CHANGE }

var state := GameState.MENU
var score := 0
var lives := 3
var tune = _TUNE
var current_rocket: Node3D
var new_rocket: Node3D
var has_new_rocket := false
var rocket_timer := 25.0
var rocket_interval := 25.0
var fall_height := 0.0
var max_fall_height := 200.0
var pickup_ttl := 0.0

var ui_score: Label
var ui_lives: Label
var ui_timer: Label
var ui_direction: Label
var ui_rocket_warning: Control
var ui_start: Control
var ui_gameover: Control
var ui_finalscore: Label

var player: CharacterBody3D
var direction_controller: Node
var background_manager: Node
var enemy_spawner: Node


func _ready():
	call_deferred("_bind_scene_nodes")


func _bind_scene_nodes() -> void:
	var scene := get_tree().current_scene
	if scene:
		ui_score = scene.get_node_or_null("%ScoreLabel") as Label
		ui_lives = scene.get_node_or_null("%LivesLabel") as Label
		ui_timer = scene.get_node_or_null("%TimerLabel") as Label
		ui_direction = scene.get_node_or_null("%DirectionLabel") as Label
		ui_rocket_warning = scene.get_node_or_null("%RocketWarning") as Control
		ui_start = scene.get_node_or_null("%StartPanel") as Control
		ui_gameover = scene.get_node_or_null("%GameOverPanel") as Control
		ui_finalscore = scene.get_node_or_null("%FinalScoreLabel") as Label
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	direction_controller = get_tree().get_first_node_in_group("direction_controller")
	background_manager = get_tree().get_first_node_in_group("background_manager")
	enemy_spawner = get_tree().get_first_node_in_group("enemy_spawner")


func _process(delta: float) -> void:
	if state != GameState.PLAYING and state != GameState.FALLING:
		return
	update_ui()
	if state == GameState.FALLING:
		handle_falling(delta)


func start_game(reset_progress: bool = true) -> void:
	#Rebind the nodes after restart, only catches after scene changes
	if ui_score == null:
		_bind_scene_nodes()
	
	state = GameState.PLAYING
	if reset_progress:
		score = tune.starting_score
		lives = tune.starting_lives
	has_new_rocket = false
	rocket_interval = tune.initial_rocket_interval
	rocket_timer = 0.0
	fall_height = 0.0

	ui_start.visible = false
	ui_gameover.visible = false

	if player:
		player.revive()
		player.visible = true
		player.falling = false
		player.clear_hit_stun()

	current_rocket = get_tree().get_first_node_in_group("rocket") as Node3D
	if current_rocket and player:
		current_rocket.global_position = player.global_position + Arena3D.ROCKET_MOUNT_OFFSET
		current_rocket.activate()
		player.mount_rocket(current_rocket)

	if enemy_spawner:
		enemy_spawner.start_spawning()

	if direction_controller:
		direction_controller.reset()

	if background_manager and background_manager.has_method("set_background"):
		background_manager.set_background(0)


func game_over():
	state = GameState.GAME_OVER
	ui_finalscore.text = "SCORE: " + str(score)
	ui_gameover.visible = true

	if enemy_spawner:
		enemy_spawner.stop_spawning()


func on_rocket_exploded():
	has_new_rocket = true
	pickup_ttl = 4.8
	ui_rocket_warning.visible = true

	if player:
		player.dismount_rocket()
		player.falling = true
		state = GameState.FALLING
		fall_height = 0.0


func handle_falling(delta: float) -> void:
	fall_height += 80 * delta
	if player:
		player.global_position.z -= 2.8 * delta
	if has_new_rocket and new_rocket:
		pickup_ttl -= delta
		if pickup_ttl <= 0.0:
			missed_rocket()
			return
		var p2 := Vector2(player.global_position.x, player.global_position.z)
		var r2 := Vector2(new_rocket.global_position.x, new_rocket.global_position.z)
		if p2.distance_to(r2) < Arena3D.RESCUE_LAND_RADIUS:
			catch_rocket()
			return
	if fall_height > max_fall_height:
		lose_life()


func catch_rocket():
	var damage := int(fall_height / 30.0)
	lives = maxi(0, lives - damage)
	pickup_ttl = 0.0
	EventBus.sfx_requested.emit(&"pickup")
	current_rocket = new_rocket
	current_rocket.global_position = player.global_position + Arena3D.ROCKET_MOUNT_OFFSET
	current_rocket.activate()

	player.mount_rocket(current_rocket)
	player.falling = false
	has_new_rocket = false
	new_rocket = null

	rocket_interval = max(tune.min_rocket_interval, rocket_interval - tune.rocket_interval_shrink_on_catch)
	rocket_timer = rocket_interval

	ui_rocket_warning.visible = false

	state = GameState.PLAYING

	if lives <= 0:
		game_over()


func lose_life():
	lives -= 1

	if has_new_rocket and new_rocket:
		new_rocket.queue_free()
	new_rocket = null

	has_new_rocket = false
	ui_rocket_warning.visible = false

	if lives <= 0:
		state = GameState.GAME_OVER
		ui_finalscore.text = "SCORE: " + str(score)
		ui_gameover.visible = true
	else:
		start_game(false)


func on_player_hit() -> void:
	if state != GameState.PLAYING:
		return
	if player and player.is_invulnerable():
		return
	lives -= 1
	EventBus.camera_shake_requested.emit(0.52)
	EventBus.sfx_requested.emit(&"hurt")
	var arena := get_tree().current_scene.get_node_or_null("%Arena") as Node3D
	if arena and player:
		_ImpactParticles3D.burst(arena, player.global_position + Vector3(0, 0.4, 0), Color(1, 0.45, 0.55), 22)
	if player:
		player.apply_hit_stun()
	if lives <= 0:
		player_die_game_over()
	else:
		update_ui()


func player_die_game_over() -> void:
	if player:
		player.die_visual_only()
	game_over()


func hop_to_rocket():
	if not has_new_rocket or not new_rocket:
		return
	EventBus.camera_shake_requested.emit(0.38)
	EventBus.sfx_requested.emit(&"hop")
	if current_rocket:
		current_rocket.deactivate()
		current_rocket.queue_free()

	current_rocket = new_rocket
	current_rocket.global_position = player.global_position + Arena3D.ROCKET_MOUNT_OFFSET
	current_rocket.activate()

	player.mount_rocket(current_rocket)
	has_new_rocket = false
	new_rocket = null
	rocket_timer = 0.0

	rocket_interval = max(tune.min_rocket_interval, rocket_interval - tune.rocket_interval_shrink_on_hop)
	rocket_timer = rocket_interval

	ui_rocket_warning.visible = false

	state = GameState.PLAYING

	if player:
		player._mesh
		player.set_tint(Color(1.15, 1.12, 1.05, 1))
		var tw := player.create_tween()
		tw.tween_property(player._mesh_mat, "albedo_color", Color.WHITE, 0.22)
	if background_manager and background_manager.has_method("cycle_background"):
		background_manager.cycle_background()


func missed_rocket():
	if new_rocket:
		new_rocket.queue_free()
	lose_life()


func add_score(points: int):
	score += points
	EventBus.score_changed.emit(score)


func update_ui():
	if ui_score:
		ui_score.text = str(score)
	if ui_lives:
		ui_lives.text = "LIVES: " + str(lives)
	if state == GameState.PLAYING and ui_timer:
		ui_timer.text = str(ceil(rocket_timer))
	if direction_controller and ui_direction:
		ui_direction.text = direction_controller.get_direction_name()


func restart():
	get_tree().reload_current_scene()
	
