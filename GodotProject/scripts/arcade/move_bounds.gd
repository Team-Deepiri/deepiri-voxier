extends RefCounted

var min_x := 40.0
var max_x := 760.0
var min_y := 200.0
var max_y := 560.0

func clamp_position(p: Vector2) -> Vector2:
	return Vector2(clampf(p.x, min_x, max_x), clampf(p.y, min_y, max_y))
