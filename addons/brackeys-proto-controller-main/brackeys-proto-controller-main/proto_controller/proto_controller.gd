# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false
@export var energy : int = 100

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.003
## Normal speed.
@export var base_speed : float = 0.7
## Speed of jump.
@export var jump_velocity : float = 5.5
## How fast do we run?
@export var sprint_speed : float = 1
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "a"
## Name of Input Action to move Right.
@export var input_right : String = "d"
## Name of Input Action to move Forward.
@export var input_forward : String = "w"
## Name of Input Action to move Backward.
@export var input_back : String = "s"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "shift"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"



var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

var is_in_sun : bool = false
var current_sun : DirectionalLight3D = null
var damage_cooldown : float = 0.1
var damage_timer : float = 0.0
var alive : bool = true

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

func _ready() -> void:
	var ititial_position = self.global_position
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	get_sun()

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	if alive:
		check_sun() # en premier ofc
		damage_timer -= delta
		if damage_timer <= 0.0:
			take_dammage()
			damage_timer = damage_cooldown

		
		# If freeflying, handle freefly and nothing else
		if can_freefly and freeflying:
			var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
			var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			motion *= freefly_speed * delta
			move_and_collide(motion)
			return
		
		# Apply gravity to velocity
		if has_gravity:
			if not is_on_floor():
				velocity += get_gravity() * delta

		# Apply jumping
		if can_jump:
			if Input.is_action_just_pressed(input_jump) and is_on_floor():
				velocity.y = jump_velocity

		# Modify speed based on sprinting
		if can_sprint and Input.is_action_pressed(input_sprint):
				move_speed = sprint_speed
		else:
			move_speed = base_speed

		# Apply desired movement to velocity
		if can_move:
			var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
			var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if move_dir:
				velocity.x = move_dir.x * move_speed
				velocity.z = move_dir.z * move_speed
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
		else:
			velocity.x = 0
			velocity.y = 0
		
		# Use velocity to actually move
		move_and_slide()
	else:
		get_tree().paused = true
		$dead.visible = true


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	# Set rotation directly so existing node scale is preserved.
	rotation = Vector3(0.0, look_rotation.y, 0.0)
	head.rotation = Vector3(look_rotation.x, 0.0, 0.0)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

func take_dammage():
	if is_in_sun:
		if energy > 0:
			energy -= 1
		else:
			alive = false
	$CanvasLayer/red.alpha = 0.6 * (1.0 - energy / 100.0)
		
	
func check_sun() -> void :
	if current_sun == null:
		is_in_sun = false
		return


	var sun_direction: Vector3 = -current_sun.global_transform.basis.z  # light travel direction
	var to_sun: Vector3 = -sun_direction  # direction from player toward the sun source

	var space_state = get_world_3d().direct_space_state
	var ray_origin = global_position + Vector3.UP * 0.5  # offset up slightly to avoid self-hit
	var ray_end = ray_origin + to_sun * 1000.0

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self]  # don't hit ourselves

	var result = space_state.intersect_ray(query)
	is_in_sun = result.is_empty()  
	
	
func get_sun():
	var nodes = get_parent().get_children()
	for node in nodes:
		if node is DirectionalLight3D:
			current_sun = node
			return
	current_sun = null
	


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://control.tscn")
