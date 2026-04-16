extends RefCounted

func points_for_enemy(kind: String) -> int:
	match kind:
		"fast":
			return 25
		"tank":
			return 15
		_:
			return 10
