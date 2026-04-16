extends RefCounted

func list_child_directories(root_path: String) -> PackedStringArray:
	var out := PackedStringArray()
	var dir := DirAccess.open(root_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			out.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return out
