extends RefCounted

func survey(path: String) -> Dictionary:
	var info := {
		"type": "UNKNOWN",
		"git": false,
		"deps": false,
		"tests": false,
	}
	var dir := DirAccess.open(path)
	if dir == null:
		return info
	if dir.file_exists("package.json"):
		info.type = "NODE"
	elif dir.file_exists("pyproject.toml"):
		info.type = "PYTHON"
	elif dir.file_exists("Cargo.toml"):
		info.type = "RUST"
	elif dir.file_exists("go.mod"):
		info.type = "GO"
	elif dir.file_exists("Gemfile"):
		info.type = "RUBY"
	info.git = dir.dir_exists(".git")
	info.deps = (
		dir.file_exists("package.json")
		or dir.file_exists("pyproject.toml")
		or dir.file_exists("requirements.txt")
		or dir.file_exists("go.mod")
	)
	info.tests = dir.dir_exists("tests") or dir.dir_exists("test") or dir.file_exists("pytest.ini")
	return info
