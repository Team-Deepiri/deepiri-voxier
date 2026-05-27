extends RefCounted
class_name UiAudio

const _AudioIds := preload("res://scripts/audio/audio_ids.gd")


static func wire_button(button: BaseButton, hover: bool = true) -> void:
	if button == null:
		return
	button.pressed.connect(func() -> void: EventBus.sfx_requested.emit(_AudioIds.UI_CLICK))
	if hover:
		button.mouse_entered.connect(func() -> void:
			if button.is_hovered():
				EventBus.sfx_requested.emit(_AudioIds.UI_HOVER)
		)


static func wire_buttons_in(node: Node, hover: bool = true) -> void:
	for child in node.get_children():
		if child is BaseButton:
			wire_button(child as BaseButton, hover)
		if child.get_child_count() > 0:
			wire_buttons_in(child, hover)
