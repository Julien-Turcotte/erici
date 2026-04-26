extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.first_play:
		await get_tree().create_timer(10.0).timeout
		visible = false
		Global.first_play = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
