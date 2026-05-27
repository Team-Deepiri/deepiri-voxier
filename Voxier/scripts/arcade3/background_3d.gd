extends Node3D

const _Catalog := preload("res://scripts/rendering/background_catalog.gd")
const _SkyShader := preload("res://shaders/wildspace_sky.gdshader")
const _FloorShader := preload("res://shaders/wildspace_floor.gdshader")

var current_index := 0
var profile: BackgroundProfile
var _shift_offset := Vector3.ZERO
var _rotation_kick := 0.0
var _stars: Node3D
var _sky_mat: ShaderMaterial
var _floor_mat: ShaderMaterial
var _parallax_far: MeshInstance3D
var _tween: Tween
var _world_env: WorldEnvironment
var _floor_mesh: MeshInstance3D


func _ready() -> void:
	add_to_group("background_manager")
	_world_env = get_tree().current_scene.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_floor_mesh = _find_floor_mesh()
	_build_sky_dome()
	_build_parallax_band()
	_build_stars()
	apply_profile(_Catalog.profile_at(0), false)


func _find_floor_mesh() -> MeshInstance3D:
	var arena := get_parent()
	if arena == null:
		return null
	return arena.get_node_or_null("Floor/MeshInstance3D") as MeshInstance3D


func _build_sky_dome() -> void:
	var quad := MeshInstance3D.new()
	quad.name = "SkyBackdrop"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(90.0, 42.0)
	quad.mesh = mesh
	_sky_mat = ShaderMaterial.new()
	_sky_mat.shader = _SkyShader
	quad.material_override = _sky_mat
	quad.position = Vector3(0.0, 8.0, 38.0)
	quad.rotation_degrees.y = 180.0
	add_child(quad)


func _build_parallax_band() -> void:
	_parallax_far = MeshInstance3D.new()
	_parallax_far.name = "ParallaxBand"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(70.0, 10.0)
	_parallax_far.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1, 1, 1, 0.22)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_parallax_far.material_override = mat
	_parallax_far.position = Vector3(0.0, 4.5, 32.0)
	_parallax_far.rotation_degrees.y = 180.0
	add_child(_parallax_far)


func _build_stars() -> void:
	_stars = Node3D.new()
	_stars.name = "Stars"
	add_child(_stars)


func _rebuild_star_field() -> void:
	if profile == null:
		return
	for c in _stars.get_children():
		c.queue_free()
	for i in profile.star_count:
		var m := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = randf_range(0.02, 0.07)
		s.height = s.radius * 2.0
		m.mesh = s
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var ccol := profile.star_color
		mat.albedo_color = Color(ccol.r, ccol.g, ccol.b, randf_range(0.35, 0.95))
		m.material_override = mat
		m.position = Vector3(randf_range(-18.0, 18.0), randf_range(2.0, 14.0), randf_range(-6.0, 42.0))
		m.set_meta("speed", randf_range(profile.star_speed_min, profile.star_speed_max))
		_stars.add_child(m)


func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING and GameManager.state != GameManager.GameState.FALLING:
		return
	if profile == null:
		return
	var mul := 1.0
	if GameManager.state == GameManager.GameState.FALLING:
		mul = profile.stress_speed_mul
	var scroll := profile.star_scroll_speed * 60.0 * delta * mul
	if _sky_mat:
		_sky_mat.set_shader_parameter("scroll_speed", profile.star_scroll_speed * mul)
		_rotation_kick = move_toward(_rotation_kick, 0.0, delta * 2.5)
		_sky_mat.set_shader_parameter("rotation_kick", _rotation_kick)
	if _floor_mat:
		_floor_mat.set_shader_parameter("scroll_speed", profile.floor_scroll_speed * mul)
		_floor_mat.set_shader_parameter("rotation_kick", _rotation_kick)
	if _parallax_far:
		_parallax_far.position.z += scroll * 0.15
		if _parallax_far.position.z > 46.0:
			_parallax_far.position.z = 28.0
	for c in _stars.get_children():
		if c is Node3D:
			var spd := float(c.get_meta("speed", 5.0))
			c.position.z += delta * spd * mul * 0.35
			if c.position.z > 48.0:
				c.position.z = -8.0
				c.position.x = randf_range(-18.0, 18.0)


func apply_profile(next: BackgroundProfile, tween_colors: bool = true) -> void:
	if next == null:
		return
	profile = next
	_rebuild_star_field()
	_apply_environment(tween_colors)
	_apply_shaders(tween_colors)
	_apply_parallax_color(tween_colors)


func _apply_environment(tween_colors: bool) -> void:
	if _world_env == null or _world_env.environment == null:
		return
	var e := _world_env.environment
	var target_bg := profile.sky_top_color
	if tween_colors and _tween:
		_tween.kill()
	if tween_colors:
		_tween = create_tween().set_parallel(true)
		_tween.tween_method(_set_env_bg_color, e.background_color, target_bg, 0.65)
		_tween.tween_method(_set_env_ambient, e.ambient_light_color, profile.ambient_color, 0.65)
		_tween.tween_method(_set_env_fog, e.fog_light_color, profile.fog_color, 0.65)
	else:
		e.background_mode = Environment.BG_COLOR
		e.background_color = target_bg
		e.ambient_light_color = profile.ambient_color
		e.ambient_light_energy = profile.ambient_energy
		e.fog_enabled = profile.fog_enabled
		e.fog_light_color = profile.fog_color
		e.fog_density = profile.fog_density


func _set_env_bg_color(c: Color) -> void:
	if _world_env and _world_env.environment:
		_world_env.environment.background_color = c


func _set_env_ambient(c: Color) -> void:
	if _world_env and _world_env.environment:
		_world_env.environment.ambient_light_color = c


func _set_env_fog(c: Color) -> void:
	if _world_env and _world_env.environment:
		_world_env.environment.fog_light_color = c


func _apply_shaders(tween_colors: bool) -> void:
	if _sky_mat:
		_sky_mat.set_shader_parameter("sky_top", Vector3(profile.sky_top_color.r, profile.sky_top_color.g, profile.sky_top_color.b))
		_sky_mat.set_shader_parameter("sky_bottom", Vector3(profile.sky_bottom_color.r, profile.sky_bottom_color.g, profile.sky_bottom_color.b))
		_sky_mat.set_shader_parameter("nebula_tint", Vector3(profile.nebula_tint.r, profile.nebula_tint.g, profile.nebula_tint.b))
		_sky_mat.set_shader_parameter("nebula_strength", profile.nebula_strength)
		_sky_mat.set_shader_parameter("star_density", profile.star_density)
		_sky_mat.set_shader_parameter("scroll_speed", profile.star_scroll_speed)
	if _floor_mesh and _floor_mesh.mesh:
		if _floor_mat == null:
			_floor_mat = ShaderMaterial.new()
			_floor_mat.shader = _FloorShader
			_floor_mesh.material_override = _floor_mat
		_floor_mat.set_shader_parameter("floor_color", Vector3(profile.floor_color.r, profile.floor_color.g, profile.floor_color.b))
		_floor_mat.set_shader_parameter("grid_tint", Vector3(profile.floor_grid_tint.r, profile.floor_grid_tint.g, profile.floor_grid_tint.b))
		_floor_mat.set_shader_parameter("scroll_speed", profile.floor_scroll_speed)


func _apply_parallax_color(tween_colors: bool) -> void:
	if _parallax_far == null or _parallax_far.material_override == null:
		return
	var mat := _parallax_far.material_override as StandardMaterial3D
	var target := Color(profile.nebula_tint.r, profile.nebula_tint.g, profile.nebula_tint.b, 0.2)
	if tween_colors:
		var tw := create_tween()
		tw.tween_property(mat, "albedo_color", target, 0.55)
	else:
		mat.albedo_color = target


func set_background(type: int) -> void:
	current_index = type
	apply_profile(_Catalog.profile_for_biome(type), true)


func cycle_background() -> void:
	current_index = (current_index + 1) % _Catalog.profile_count()
	apply_profile(_Catalog.profile_at(current_index), true)
	_rotation_kick = 0.35


func apply_shift(shift: Vector2) -> void:
	_shift_offset = Vector3(shift.x * 0.025, 0.0, shift.y * 0.01)
	position = _shift_offset


func get_background_name() -> String:
	if profile:
		return profile.display_name
	return "SPACE"
