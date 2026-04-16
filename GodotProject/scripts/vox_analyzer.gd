extends Node
class_name VoxAnalyzer

const _DirectoryWalker := preload("res://scripts/vox/directory_walker.gd")
const _RepoNaming := preload("res://scripts/vox/repo_naming.gd")
const _RepoClassifier := preload("res://scripts/vox/repo_classifier.gd")
const _MetricsCollector := preload("res://scripts/vox/metrics_collector.gd")

var profile: VoxScanProfile

func _init() -> void:
	profile = load("res://resources/vox_scan_profile_default.tres") as VoxScanProfile

func scan_repos(root_path: String) -> Array:
	var repos: Array = []
	var naming := _RepoNaming.new()
	var walker := _DirectoryWalker.new()
	for dir_name in walker.list_child_directories(root_path):
		if naming.matches_workspace_repo(dir_name, profile):
			var path := root_path.path_join(dir_name)
			repos.append(analyze_repo(path, dir_name))
	repos.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.name < b.name)
	return repos

func analyze_repo(path: String, name: String) -> Dictionary:
	var classifier := _RepoClassifier.new()
	var flags := classifier.survey(path)
	var metrics := _MetricsCollector.new()
	flags["name"] = name
	flags["size"] = metrics.directory_size_kb(path, profile)
	return flags

func get_dir_size(path: String) -> int:
	var metrics := _MetricsCollector.new()
	return int(metrics.directory_size_kb(path, profile) * 1024.0)
