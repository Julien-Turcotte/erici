extends Node3D

@export var speed: float = 2.0
@export var distance: float = 10.0

var direction: float = 1.0
var start_x: float

func _ready():
	start_x = position.x

func _process(delta):
	position.x += speed * direction * delta
	if position.x >= start_x + distance:
		direction = -1.0
	elif position.x <= start_x - distance:
		direction = 1.0
