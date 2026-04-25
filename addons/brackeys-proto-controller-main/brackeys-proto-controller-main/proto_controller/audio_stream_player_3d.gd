extends AudioStreamPlayer3D

@export var interval: float = 0.5
var timer: float = 0.0

func _ready() -> void:
	timer = interval
	if stream:
		play()

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		timer += interval
		if stream:
			play()
