extends RefCounted

static func burst(parent: Node2D, global_pos: Vector2, color: Color, amount: int = 32) -> void:
	if parent == null:
		return
	var p := CPUParticles2D.new()
	p.z_index = 50
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = amount
	p.lifetime = 0.38
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.initial_velocity_min = 90.0
	p.initial_velocity_max = 260.0
	p.gravity = Vector2(0, 240)
	p.scale_amount_min = 1.2
	p.scale_amount_max = 3.2
	p.color = color
	parent.add_child(p)
	p.global_position = global_pos
	p.emitting = true
	var tw := parent.get_tree().create_timer(p.lifetime + 0.15)
	tw.timeout.connect(func(): p.queue_free())
