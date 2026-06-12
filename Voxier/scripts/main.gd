extends Node2D

const _Scenes := preload("res://scripts/ui/scene_registry.gd")

@onready var player: CharacterBody2D = $Player
@onready var rocket: Node2D = $Rocket
@onready var bg_manager: Node2D = $BackgroundManager
@onready var dir_controller: Node = $DirectionController
@onready var spawner: Node = $EnemySpawner
@onready var camera: Camera2D = $Camera2D

@onready var settings_btn: Button = $UI/StartPanel/VBox/SettingsBtn
@onready var cat_btn: Button = $UI/StartPanel/VBox/CatBtn
@onready var _speed_lines: CPUParticles2D = $SpeedFX/SpeedLines

func _ready():
	settings_btn.pressed.connect(_on_settings_pressed)
	cat_btn.pressed.connect(_on_cat_pressed)


func _process(_delta: float) -> void:
	if _speed_lines == null:
		return
	var st := GameManager.state
	var on := st == GameManager.GameState.PLAYING or st == GameManager.GameState.FALLING
	_speed_lines.emitting = on
	if on and player:
		var sp := player.velocity.length()
		_speed_lines.amount = mini(120, 55 + int(sp * 0.12))

func _on_settings_pressed():
	get_tree().change_scene_to_file(_Scenes.SETTINGS)

func _on_cat_pressed():
	get_tree().change_scene_to_file(_Scenes.CAT_PILOT)

func _on_start_pressed():
	GameManager.start_game()

func _on_retry_pressed():
	GameManager.restart()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire") and GameManager.state == GameManager.GameState.PLAYING:
		pass
	if event.is_action_pressed("hop") or event.is_action_pressed("ui_accept"):
		if GameManager.has_new_rocket and GameManager.new_rocket:
			if (
				GameManager.state == GameManager.GameState.FALLING
				or GameManager.state == GameManager.GameState.PLAYING
			):
				GameManager.hop_to_rocket()
