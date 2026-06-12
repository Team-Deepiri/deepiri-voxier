extends Node3D

const _Scenes := preload("res://scripts/ui/scene_registry.gd")
const _UiAudio := preload("res://scripts/audio/ui_audio.gd")

@onready var settings_btn: Button = $UI/Control/StartPanel/VBox/SettingsBtn
@onready var cat_btn: Button = $UI/Control/StartPanel/VBox/CatBtn
@onready var _ui_root: CanvasLayer = $UI


func _ready() -> void:
	_UiAudio.wire_buttons_in(_ui_root)
	settings_btn.pressed.connect(_on_settings_pressed)
	cat_btn.pressed.connect(_on_cat_pressed)


func _on_settings_pressed():
	get_tree().change_scene_to_file(_Scenes.SETTINGS)


func _on_cat_pressed():
	get_tree().change_scene_to_file(_Scenes.CAT_PILOT)


func _on_start_pressed():
	GameManager.start_game()


func _on_retry_pressed():
	GameManager.restart()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hop") or event.is_action_pressed("ui_accept"):
		if GameManager.has_new_rocket and GameManager.new_rocket:
			if (
				GameManager.state == GameManager.GameState.FALLING
				or GameManager.state == GameManager.GameState.PLAYING
			):
				GameManager.hop_to_rocket()
