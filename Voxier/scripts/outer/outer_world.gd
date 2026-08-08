extends Node
## Autoload singleton (registered as `Outer`).
## Owns the UniverseDef, advances the simulation distance while playing,
## and hands out the sampled environment + encounter table to the game.

signal district_changed(from: StringName, to: StringName)

const _Def := preload("res://scripts/outer/universe_def.gd")

const BASE_SPEED := 38.0
const _TOTAL := 5400.0

var universe: UniverseDef
var distance := 0.0

var _last := UniverseDef.Sample.new()


func _ready() -> void:
	universe = build_universe()
	distance = 0.0
	_last = universe.sample(distance)


func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	add_speed(delta)


func add_speed(delta: float) -> void:
	distance += delta * BASE_SPEED
	var sample_now := universe.sample(distance)
	if sample_now.district_id != _last.district_id:
		district_changed.emit(_last.district_id, sample_now.district_id)
	_last = sample_now


func refresh() -> void:
	_last = universe.sample(distance)


## Restart travel from the perimeter on a new run.
func reset_run() -> void:
	distance = 0.0
	_last = universe.sample(distance)
	district_changed.emit(_last.district_id, _last.district_id)


func sample() -> UniverseDef.Sample:
	return _last


func rebuild() -> void:
	universe = build_universe()
	_last = universe.sample(distance)
	_last.district_id = universe.resolve(distance).id


func current_district() -> UniverseDef.District:
	return universe.resolve(distance)


## Standard entity table: ordered pools by region key.
func current_pool() -> Array:
	return _last.pool


func build_universe() -> UniverseDef:
	var u := UniverseDef.new()
	u.set_axis_length(_TOTAL)

	# --- Seen Belt (arrival): calm starter, light scavengers. ---
	var starter := UniverseDef.District.new()
	starter.id = &"starter"
	starter.title = "Low Orbit Courier"
	starter.start_pos = 0.0
	starter.end_pos = 900.0
	starter.gravity_mod = 1.0
	starter.thrust_mod = 1.0
	starter.drag_mod = 1.0
	starter.turbulence = 0.0
	starter.speed_mult = 1.0
	starter.flame_color = Color(1.0, 0.62, 0.2)
	starter.particle_color = Color(1.0, 0.62, 0.2)
	starter.ambient = 0.7
	starter.sky_theme = &"courier"
	starter.pool = [
		_e("kind_0", 70),
		_e("kind_1", 18),
	]
	u.add_district(starter)

	# --- Thin Trait Stratus: turbulent, quick enemies. ---
	var stratus := UniverseDef.District.new()
	stratus.id = &"stratus"
	stratus.title = "Stratus Roade"
	stratus.start_pos = 900.0
	stratus.end_pos = 1900.0
	stratus.gravity_mod = 1.12
	stratus.thrust_mod = 1.05
	stratus.drag_mod = 0.92
	stratus.turbulence = 0.30
	stratus.speed_mult = 1.06
	stratus.flame_color = Color(1.0, 0.45, 0.42)
	stratus.particle_color = Color(1.0, 0.45, 0.42)
	stratus.ambient = 1.0
	stratus.sky_theme = &"stratus"
	stratus.pool = [
		_e("kind_0", 34),
		_e("kind_1", 30),
		_e("kind_2", 12),
	]
	u.add_district(stratus)

	# --- Ceramic ground: high density. ---
	var ceramic := UniverseDef.District.new()
	ceramic.id = &"ceramic"
	ceramic.title = "Ceramic Lattice"
	ceramic.start_pos = 1900.0
	ceramic.end_pos = 3000.0
	ceramic.gravity_mod = 1.28
	ceramic.thrust_mod = 0.9
	ceramic.drag_mod = 1.2
	ceramic.turbulence = 0.55
	ceramic.speed_mult = 1.12
	ceramic.flame_color = Color(1.0, 0.9, 0.5)
	ceramic.particle_color = Color(1.0, 0.9, 0.5)
	ceramic.ambient = 1.35
	ceramic.sky_theme = &"ceramic"
	ceramic.pool = [
		_e("kind_1", 30),
		_e("kind_2", 24),
		_e("kind_3", 10),
	]
	u.add_district(ceramic)

	# --- Deep margin: dark, airless, occasional mothers. ---
	var deep := UniverseDef.District.new()
	deep.id = &"deep"
	deep.title = "Deep Margin"
	deep.start_pos = 3000.0
	deep.end_pos = 4200.0
	deep.gravity_mod = 0.68
	deep.thrust_mod = 1.35
	deep.drag_mod = 0.8
	deep.turbulence = 0.9
	deep.speed_mult = 1.3
	deep.flame_color = Color(0.55, 0.42, 1.0)
	deep.particle_color = Color(0.55, 0.42, 1.0)
	deep.ambient = 1.7
	deep.sky_theme = &"deep"
	deep.pool = [
		_e("kind_0", 10),
		_e("kind_2", 28),
		_e("kind_3", 22),
	]
	u.add_district(deep)

	# --- Voracious — final — full menace. ---
	var final_dist := UniverseDef.District.new()
	final_dist.id = &"final"
	final_dist.title = "Voracious Vast"
	final_dist.start_pos = 4200.0
	final_dist.end_pos = 5400.0
	final_dist.gravity_mod = 1.5
	final_dist.thrust_mod = 0.8
	final_dist.drag_mod = 1.4
	final_dist.turbulence = 1.4
	final_dist.speed_mult = 1.45
	final_dist.flame_color = Color(1.0, 0.25, 0.2)
	final_dist.particle_color = Color(1.0, 0.25, 0.2)
	final_dist.ambient = 2.2
	final_dist.sky_theme = &"final"
	final_dist.pool = [
		_e("kind_2", 20),
		_e("kind_3", 34),
	]
	u.add_district(final_dist)

	return u


func _e(key: String, weight: float) -> UniverseDef.Entity:
	var en := UniverseDef.Entity.new()
	en.key = StringName(key)
	en.weight = weight
	return en