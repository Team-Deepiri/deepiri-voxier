extends Control


const _Scenes := preload("res://scripts/ui/scene_registry.gd")
const _Keys := preload("res://scripts/save/settings_keys.gd")


@onready var return_btn: Button = $CanvasLayer/SettingsPanel/VBox/ReturnBtn
@onready var audio_btn: CheckButton = $CanvasLayer/SettingsPanel/VBox/CheckBtn
@onready var master_slider: HSlider = $CanvasLayer/SettingsPanel/VBox/MasterSlider
@onready var music_slider: HSlider = $CanvasLayer/SettingsPanel/VBox/MusicSlider
@onready var sfx_slider: HSlider = $CanvasLayer/SettingsPanel/VBox/SFXSlider



func _ready() -> void:
	return_btn.pressed.connect(_on_return_pressed)
	audio_btn.toggled.connect(_on_audio_toggled)
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	#get save data and set audio values from save
	audio_btn.button_pressed = GameAudio.audio_enabled
	master_slider.value = GameAudio.master_volume_linear
	music_slider.value = GameAudio.music_volume_linear
	sfx_slider.value = GameAudio.sfx_volume_linear
	

func _on_return_pressed():
	get_tree().change_scene_to_file(_Scenes.MAIN)


func _on_audio_toggled(enabled: bool) -> void:
	GameAudio.set_audio_enabled(enabled)

func _on_music_changed(value: float) -> void:
	GameAudio.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	GameAudio.set_sfx_volume(value)

func _on_master_changed(value: float) -> void:
	GameAudio.set_master_volume(value)
