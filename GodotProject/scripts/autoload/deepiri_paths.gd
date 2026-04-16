extends Node

func workspace_parent_from_project() -> String:
	return ProjectSettings.globalize_path("res://..")

func project_root_absolute() -> String:
	return ProjectSettings.globalize_path("res://")
