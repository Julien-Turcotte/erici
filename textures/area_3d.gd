extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("test")
	print(event)
	if event is InputEventMouseButton and event.pressed:
		print("real click")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	pass
