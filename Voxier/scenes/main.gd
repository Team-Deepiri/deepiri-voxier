extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var rocket: Node2D = $Rocket
@onready var bg_manager: Node2D = $BackgroundManager
@onready var dir_controller: Node = $DirectionController
@onready var spawner: Node = $EnemySpawner
@onready var camera: Camera2D = $Camera2D

func _ready():
	player.add_to_group("player")
	rocket.add_to_group("rocket")
	bg_manager.add_to_group("background_manager")
	dir_controller.add_to_group("direction_controller")
	spawner.add_to_group("enemy_spawner")

func _input(event):
	if event.is_action_pressed("fire") and GameManager.state == GameManager.GameState.PLAYING:
		pass
	
	if event.is_action_pressed("hop"):
		if GameManager.has_new_rocket:
			GameManager.hop_to_rocket()
	
	if event.is_action_pressed("ui_accept"):
		match GameManager.state:
			GameManager.GameState.MENU:
				GameManager.start_game()
			GameManager.GameState.GAME_OVER:
				GameManager.restart()
