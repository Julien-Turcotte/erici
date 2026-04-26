extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_scene_5_animation_finished(anim_name: StringName) -> void:
	play("colorreact")


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		play("colorreact")


func _on_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://control.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	play("colorreact")
