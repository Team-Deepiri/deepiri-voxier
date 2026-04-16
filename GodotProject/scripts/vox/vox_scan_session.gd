extends RefCounted
class_name VoxScanSession

var scan_id: int = 0
var started_at_msec: int = 0

func begin() -> void:
	scan_id = randi()
	started_at_msec = Time.get_ticks_msec()

func elapsed_msec() -> int:
	return Time.get_ticks_msec() - started_at_msec
