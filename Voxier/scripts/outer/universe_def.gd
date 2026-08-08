class_name UniverseDef
extends RefCounted
## The "outerwork": a 1D axis of the simulated universe (`distance`).
## It is sliced into contiguous Districts. Every District owns:
##   - rocket-affecting properties (gravity/thrust/drag/turbulence/speed)
##   - presentation (flame tint, ambient, sky theme)
##   - its own encounter table (per-area entities)
## `sample()` resolves smooth, blended effects at any point on the axis.


class District:
	var id: StringName
	var title: String
	var start_pos: float = 0.0
	var end_pos: float = 0.0
	var blend := 140.0

	var gravity_mod := 1.0
	var thrust_mod := 1.0
	var drag_mod := 1.0
	var turbulence := 0.0
	var speed_mult := 1.0

	var flame_color := Color(1.0, 0.55, 0.12)
	var ambient := 1.0
	var sky_theme := StringName()
	var particle_color := Color(1.0, 0.55, 0.12)

	var pool: Array = []

	func length() -> float:
		return maxf(0.0, end_pos - start_pos)

	func contains(d: float) -> bool:
		return d >= start_pos and d < end_pos

	## Presence 0..1 including smooth ramps at both borders.
	func presence(d: float) -> float:
		if length() <= 0.0:
			return 0.0
		var left := smoothstep(0.0, blend, d - start_pos)
		var right := smoothstep(0.0, blend, end_pos - d)
		return minf(left, right)

	func pick_entity(r: float) -> StringName:
		var total := 0.0
		for e in pool:
			total += e.weight
		if total <= 0.0:
			return &""
		var acc := 0.0
		for e in pool:
			acc += e.weight
			if r < acc:
				return e.key
		return pool[pool.size() - 1].key


## A weighted encounter option inside a District pool.
class Entity:
	var key: StringName
	var weight := 1.0


## The blended, awaited environment at one point on the axis.
class Sample:
	var district_id: StringName
	var district_title := ""
	var gravity_mod := 1.0
	var thrust_mod := 1.0
	var drag_mod := 1.0
	var turbulence := 0.0
	var speed_mult := 1.0
	var flame_color := Color(1.0, 0.55, 0.12)
	var particle_color := Color(1.0, 0.55, 0.12)
	var ambient := 1.0
	var sky_theme := ""
	var pool: Array = []


var districts: Array = []
var _axis_length := 1.0


func axis_length() -> float:
	return _axis_length


func set_axis_length(v: float) -> void:
	_axis_length = maxf(1.0, v)


func add_district(d: District) -> void:
	districts.append(d)
	rebuild()


func rebuild() -> void:
	_axis_length = 0.0
	for d in districts:
		if d.end_pos > _axis_length:
			_axis_length = d.end_pos


func resolve(d: float) -> District:
	var best: District = null
	var best_p := 0.0
	for district in districts:
		var p: float = float(district.presence(d))
		if p > best_p:
			best_p = p
			best = district
	if best == null and not districts.is_empty():
		best = districts[0]
	return best


func sample(d: float) -> Sample:
	var s := Sample.new()
	var weights := 0.0
	var top: District = null
	var top_p := 0.0
	for district in districts:
		var w: float = float(district.presence(d))
		if w <= 0.0:
			continue
		weights += w
		s.gravity_mod += district.gravity_mod * w
		s.thrust_mod += district.thrust_mod * w
		s.drag_mod += district.drag_mod * w
		s.turbulence += district.turbulence * w
		s.speed_mult += district.speed_mult * w
		s.flame_color += district.flame_color * w
		s.particle_color += district.particle_color * w
		s.ambient += district.ambient * w
		if district.sky_theme != "":
			s.sky_theme = district.sky_theme
		if w > top_p:
			top_p = w
			top = district
	if weights > 0.0:
		s.gravity_mod /= weights
		s.thrust_mod /= weights
		s.drag_mod /= weights
		s.speed_mult /= weights
		s.ambient /= weights
		s.flame_olor /= weights
	if top:
		s.district_id = top.id
		s.district_title = top.title
		s.pool = top.pool
	return s