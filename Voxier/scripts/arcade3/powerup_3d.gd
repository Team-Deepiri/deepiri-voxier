extends Area3D

const PowerupType := preload("res://scripts/game_enums.gd").PowerupType

@export var powerup_type := PowerupType.RAPID

var fall_speed := 5.5


func _ready() -> void:
	add_to_group("powerup")
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh and mesh.material_override is StandardMaterial3D:
		var mat := (mesh.material_override as StandardMaterial3D).duplicate()
		mesh.material_override = mat
		match powerup_type:
			PowerupType.RAPID:
				mat.albedo_color = Color.RED
			PowerupType.SHIELD:
				mat.albedo_color = Color.CYAN
			PowerupType.MULTI:
				mat.albedo_color = Color.YELLOW


func _process(delta: float) -> void:
	position.z -= fall_speed * delta
	if position.z > 44.0:
		queue_free()


func collect() -> void:
	EventBus.sfx_requested.emit(&"pickup")
	GameManager.add_score(50)
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("apply_powerup"):
		p.apply_powerup(powerup_type)
	queue_free()


func _on_area_entered(area: Area3D) -> void:
	var par := area.get_parent()
	if par and par.is_in_group("player"):
		collect()
