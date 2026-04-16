extends RefCounted

func directory_size_kb(path: String, profile: VoxScanProfile) -> float:
	return float(get_dir_size(path, profile, 0, 12)) / 1024.0

func get_dir_size(path: String, profile: VoxScanProfile, depth: int, max_depth: int) -> int:
	if depth > max_depth:
		return 0
	var total := 0
	var dir := DirAccess.open(path)
	if dir == null:
		return 0
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		if profile.skip_directory_names.has(file_name) and dir.current_is_dir():
			file_name = dir.get_next()
			continue
		var sub := path.path_join(file_name)
		if dir.current_is_dir():
			total += get_dir_size(sub, profile, depth + 1, max_depth)
		else:
			var f := FileAccess.open(sub, FileAccess.READ)
			if f:
				total += f.get_length()
		file_name = dir.get_next()
	dir.list_dir_end()
	return total
