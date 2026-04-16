extends ColorRect

@export var scanline_density := 240.0
@export var vignette_strength := 0.25

func _ready() -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter("line_density", scanline_density)
		material.set_shader_parameter("opacity", 0.08)
