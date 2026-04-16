extends Node

signal score_changed(new_total: int)
signal game_state_changed(new_state: int)
signal vox_scan_started(root_path: String)
signal vox_scan_finished(repo_count: int)
signal camera_shake_requested(trauma: float)
signal sfx_requested(id: StringName)
