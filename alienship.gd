extends Node3D

@onready var particles = $UniParticles3D
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_scene_3_animation_finished(anim_name: StringName) -> void:
	particles.play()
