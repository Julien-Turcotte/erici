extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("scene1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_scene_5_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
