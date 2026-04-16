extends RefCounted

func matches_workspace_repo(dir_name: String, profile: VoxScanProfile) -> bool:
	for p in profile.name_prefixes:
		if dir_name.begins_with(p):
			return true
	return false
