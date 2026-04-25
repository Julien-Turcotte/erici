extends Camera3D

const BASE_FOV = 68.0
const BOB_FREQUENCY = 1.0
const BOB_AMPLITUDE = 0.012
const TILT_AMOUNT = 1.5
const TILT_SPEED = 8.0
const BREATHE_SPEED = 0.4
const BREATHE_AMOUNT = 1.2

var bob_time: float = 0.0
var breathe_time: float = 0.0
var current_tilt: float = 0.0

@onready var body = $"../.." as CharacterBody3D

func _ready():
	fov = BASE_FOV

func _process(delta):
	_handle_breathing(delta)
	_handle_headbob(delta)
	_handle_tilt(delta)

func _handle_breathing(delta):
	breathe_time += delta * BREATHE_SPEED
	fov = BASE_FOV + sin(breathe_time * TAU) * BREATHE_AMOUNT

func _handle_headbob(delta):
	if body == null:
		return
	var is_moving = Vector2(body.velocity.x, body.velocity.z).length() > 0.1
	if is_moving and body.is_on_floor():
		bob_time += delta * BOB_FREQUENCY * TAU
	else:
		bob_time = lerp(bob_time, 0.0, delta * 5.0)

	position.y = sin(bob_time) * BOB_AMPLITUDE
	position.x = sin(bob_time * 0.5) * BOB_AMPLITUDE * 0.5

func _handle_tilt(delta):
	var strafe = Input.get_axis("a", "d")
	var target_tilt = -strafe * TILT_AMOUNT
	current_tilt = lerp(current_tilt, target_tilt, delta * TILT_SPEED)
	# Apply only to camera Z, never touch Head
	rotation_degrees.z = current_tilt
