extends ColorRect

@export var alpha : float = 0.0
@export var innercirl : float = 0.0
@export var outercirl : float = 0.0

func _ready() -> void:
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("inner_radius", innercirl)
	material.set_shader_parameter("outer_radius", outercirl)

func _process(delta: float) -> void:
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("inner_radius", innercirl)
	material.set_shader_parameter("outer_radius", outercirl)
