extends Control


const _Scenes := preload("res://scripts/ui/scene_registry.gd")
#const _Keys := preload("res://scripts/save/settings_keys.gd")
#const _Local := preload("res://scripts/save/local_settings.gd")
#const _UiAudio := preload("res://scripts/audio/ui_audio.gd")
#2 const for settings, one for audio not used yet as need to do more searching

@onready var return_btn: Button = $CanvasLayer/SettingsPanel/VBox/ReturnBtn
#@onready var _ui_root: CanvasLayer = $CanvasLayer


func _ready() -> void:
	return_btn.pressed.connect(_on_return_pressed)

func _on_return_pressed():
	get_tree().change_scene_to_file(_Scenes.MAIN)

