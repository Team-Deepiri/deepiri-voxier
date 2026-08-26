extends Area3D

@export var speed := 26.0
@export var damage := 1
@export var is_player_bullet := true

## Optional flight direction (normalized in _ready). Player bullets ignore it
## and always fly +Z; enemy bullets fall back to straight -Z when unset.
var custom_direction := Vector3.ZERO

var velocity := Vector3.ZERO

func _ready() -> void:
	if is_player_bullet:
		add_to_group("player_bullet")
		velocity = Vector3(0, 0, speed)
	else:
		add_to_group("enemy_bullet")
		if custom_direction != Vector3.ZERO:
			velocity = custom_direction.normalized() * speed
		else:
			velocity = Vector3(0, 0, -speed)
	var lt := get_node_or_null("Lifetime") as Timer
	if lt:
		lt.start()


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	var p := global_position
	if p.x < -20.0 or p.x > 20.0 or p.z < -4.0 or p.z > 44.0 or absf(p.y) > 20.0:
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	if is_player_bullet and area.is_in_group("enemy"):
		area.take_damage(damage)
		queue_free()
	elif not is_player_bullet:
		var par := area.get_parent()
		if par and par.is_in_group("player"):
			queue_free()


func _on_timer_timeout() -> void:
	queue_free()
