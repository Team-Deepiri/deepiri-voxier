extends Resource
class_name BackgroundProfile

@export var display_name := "Space"
@export var biome_id := 0

@export_group("Sky")
@export var sky_top_color := Color(0.03, 0.02, 0.09, 1.0)
@export var sky_bottom_color := Color(0.11, 0.06, 0.24, 1.0)
@export var nebula_tint := Color(0.15, 0.08, 0.35, 1.0)
@export var nebula_strength := 0.55
@export var star_density := 0.995
@export var star_scroll_speed := 0.15

@export_group("Lighting")
@export var ambient_color := Color(0.35, 0.38, 0.55, 1.0)
@export var ambient_energy := 0.6
@export var fog_enabled := true
@export var fog_color := Color(0.08, 0.06, 0.14, 1.0)
@export var fog_density := 0.018

@export_group("Floor")
@export var floor_color := Color(0.08, 0.06, 0.14, 1.0)
@export var floor_grid_tint := Color(0.25, 0.18, 0.42, 1.0)
@export var floor_scroll_speed := 0.08

@export_group("Stars 3D")
@export var star_count := 120
@export var star_color := Color(1.0, 1.0, 1.0, 1.0)
@export var star_speed_min := 2.0
@export var star_speed_max := 9.0
@export var stress_speed_mul := 2.2

@export_group("2D Layers")
@export var layer_back := Color(0.05, 0.02, 0.12, 1.0)
@export var layer_mid := Color(0.11, 0.06, 0.24, 1.0)
@export var layer_fg := Color(0.0, 0.0, 0.0, 0.3)
@export var show_city_silhouette := false
@export var show_forest_silhouette := false
