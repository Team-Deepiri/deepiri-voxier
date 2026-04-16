extends RefCounted

var _path: String

func _init(user_file: String = "user://deepiri_voxier_settings.cfg") -> void:
	_path = user_file

func read_int(key: String, fallback: int) -> int:
	var c := ConfigFile.new()
	if c.load(_path) != OK:
		return fallback
	return int(c.get_value("app", key, fallback))

func write_int(key: String, value: int) -> void:
	var c := ConfigFile.new()
	c.load(_path)
	c.set_value("app", key, value)
	c.save(_path)
