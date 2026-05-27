extends Node2D

const _Catalog := preload("res://scripts/rendering/background_catalog.gd")

var current_index := 0
var profile: BackgroundProfile
var target_shift := Vector2.ZERO

@onready var bg_rect: ColorRect = $BackgroundRect
@onready var mid_rect: ColorRect = $MidRect
@onready var fg_rect: ColorRect = $ForegroundRect
@onready var stars_container: Node2D = $StarsContainer
@onready var buildings_container: Node2D = $BuildingsContainer
@onready var trees_container: Node2D = $TreesContainer

var tween: Tween
var star_speeds: Array[float] = []


func _ready():
	add_to_group("background_manager")
	setup_stars()
	build_default_buildings()
	build_default_trees()
	apply_profile(_Catalog.profile_at(0), false)


func setup_stars():
	for i in range(80):
		var star = Polygon2D.new()
		star.polygon = PackedVector2Array([Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)])
		star.color = Color(1, 1, 1, randf_range(0.3, 0.9))
		star.position = Vector2(randf_range(0, 800), randf_range(0, 600))
		star.scale = Vector2(randf_range(0.5, 2), randf_range(0.5, 2)) / 10.0
		stars_container.add_child(star)
		star_speeds.append(randf_range(0.5, 2.5))


func build_default_buildings():
	for i in range(6):
		var building = ColorRect.new()
		building.color = Color(0.04, 0.04, 0.08)
		building.size = Vector2(80, randf_range(80, 180))
		building.position = Vector2(i * 120 + 30, 600 - building.size.y)
		buildings_container.add_child(building)
		for j in range(int(randf_range(3, 6))):
			var window = ColorRect.new()
			window.color = Color(1, 0, 1) if randf() > 0.5 else Color(0, 1, 1)
			window.size = Vector2(8, 8)
			window.position = Vector2(
				building.position.x + randf_range(10, 60),
				building.position.y + randf_range(20, building.size.y - 30)
			)
			buildings_container.add_child(window)


func build_default_trees():
	for i in range(12):
		var tree = Polygon2D.new()
		tree.color = Color(0.05, 0.2, 0.05)
		var h = randf_range(60, 120)
		tree.polygon = PackedVector2Array([Vector2(-20, 0), Vector2(0, -h), Vector2(20, 0)])
		tree.position = Vector2(i * 70 + randf_range(-20, 20), randf_range(450, 550))
		trees_container.add_child(tree)


func _process(delta):
	if GameManager.state != GameManager.GameState.PLAYING and GameManager.state != GameManager.GameState.FALLING:
		return
	update_stars(delta)


func update_stars(delta):
	if profile == null:
		return
	var stress := 1.0
	if GameManager.state == GameManager.GameState.FALLING:
		stress = profile.stress_speed_mul
	for i in range(stars_container.get_child_count()):
		var star = stars_container.get_child(i)
		star.position.y += star_speeds[i] * delta * 60 * stress
		if star.position.y > 620:
			star.position.y = -20
			star.position.x = randf_range(0, 800)
		if profile:
			var sc := profile.star_color
			star.color = Color(sc.r, sc.g, sc.b, star.color.a)


func apply_profile(next: BackgroundProfile, tween_colors: bool = true) -> void:
	if next == null:
		return
	profile = next
	current_index = next.biome_id
	if tween:
		tween.kill()
	if tween_colors:
		tween = create_tween().set_parallel(true)
		tween.tween_property(bg_rect, "color", profile.layer_back, 0.5)
		tween.tween_property(mid_rect, "color", profile.layer_mid, 0.5)
		tween.tween_property(fg_rect, "color", profile.layer_fg, 0.5)
	else:
		bg_rect.color = profile.layer_back
		mid_rect.color = profile.layer_mid
		fg_rect.color = profile.layer_fg
	buildings_container.visible = profile.show_city_silhouette
	trees_container.visible = profile.show_forest_silhouette


func set_background(type: int) -> void:
	apply_profile(_Catalog.profile_for_biome(type), true)


func cycle_background() -> void:
	current_index = (current_index + 1) % _Catalog.profile_count()
	apply_profile(_Catalog.profile_at(current_index), true)


func apply_shift(shift: Vector2) -> void:
	target_shift = shift
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", shift, 0.5)


func get_background_name() -> String:
	if profile:
		return profile.display_name
	return "SPACE"
