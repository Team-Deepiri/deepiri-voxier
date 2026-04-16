extends Area2D

enum PowerupType { RAPID, SHIELD, MULTI }

@export var powerup_type := PowerupType.RAPID

var fall_speed := 80.0

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	add_to_group("powerup")
	match powerup_type:
		PowerupType.RAPID:
			$ColorRect.color = Color.RED
		PowerupType.SHIELD:
			$ColorRect.color = Color.CYAN
		PowerupType.MULTI:
			$ColorRect.color = Color.YELLOW

func _process(delta):
	position.y += fall_speed * delta
	if position.y > 620:
		queue_free()

func collect() -> void:
	EventBus.sfx_requested.emit(&"pickup")
	GameManager.add_score(50)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	var p := area.get_parent()
	if p and p.is_in_group("player"):
		collect()