extends RefCounted

static func movement_actions() -> PackedStringArray:
	return PackedStringArray(["move_left", "move_right", "move_up", "move_down"])

static func combat_actions() -> PackedStringArray:
	return PackedStringArray(["fire", "hop"])
