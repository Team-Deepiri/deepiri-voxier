extends Node3D

const _Catalog := preload("res://scripts/rendering/background_catalog.gd")

@onready var _bg: Node = $Arena/Background3D


func _ready() -> void:
	if _bg and _bg.has_method("apply_profile"):
		_bg.apply_profile(_Catalog.profile_at(0), false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		if _bg and _bg.has_method("cycle_background"):
			_bg.cycle_background()
	elif event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var idx: int = int(event.keycode) - KEY_1
			if _bg and _bg.has_method("set_background"):
				_bg.set_background(idx)
