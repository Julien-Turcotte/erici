extends Node
# FootstepsEnv.gd — distance/velocity-driven footsteps adapted to your ProtoController setup

@export var player_path: NodePath = NodePath("")                     # optional, leave empty if script is child of ProtoController
@export var foot_ray_path: NodePath = NodePath("Collider/FootRay")   # default matches your scene
@export var audio_player_path: NodePath = NodePath("FootAudio")      # default matches your scene

@export var max_speed: float = 5.0
@export var min_step_distance: float = 0.6
@export var max_step_distance: float = 1.2

@export var metal_sounds: Array[AudioStream] = []
@export var concrete_sounds: Array[AudioStream] = []
@export var default_sounds: Array[AudioStream] = []

@export var volume_db: float = -3.0
@export var pitch_randomness: float = 0.06
@export var debug_print_collider: bool = false

var _player: Node = null
var _foot_ray: RayCast3D = null
var _audio: AudioStreamPlayer3D = null
var _distance_accum: float = 0.0
var _prev_pos: Vector3 = Vector3.ZERO
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

	# find player (explicit or parent)
	if player_path != NodePath(""):
		_player = get_node_or_null(player_path)
	if not _player:
		_player = get_parent()

	# find FootRay (try this node first, then player)
	_foot_ray = get_node_or_null(foot_ray_path)
	if not _foot_ray and _player:
		_foot_ray = _player.get_node_or_null(foot_ray_path)
	if _foot_ray and not _foot_ray.is_enabled():
		_foot_ray.set_enabled(true)

	# find or create audio player (attach to player if present)
	_audio = get_node_or_null(audio_player_path)
	if not _audio and _player:
		_audio = _player.get_node_or_null(audio_player_path)
	if not _audio:
		_audio = AudioStreamPlayer3D.new()
		_audio.name = "FootAudio"
		if _player and _player is Node:
			_player.add_child(_audio)
		else:
			add_child(_audio)

	# try to auto-tune max_speed from player (common exported names)
	if _player:
		var candidate := _player.get("base_speed") if _player.has_method("get") else null
		if candidate == null:
			candidate = _player.get("MOVE_SPEED") if _player.has_method("get") else null
		if candidate != null and float(candidate) > 0.0:
			max_speed = float(candidate)

	# prev pos for non-CharacterBody speed estimation
	if _player and _player is Node:
		_prev_pos = _player.global_transform.origin

func _physics_process(delta: float) -> void:
	if delta <= 0 or not _player:
		return

	# grounded check
	var grounded: bool = false
	if _player is CharacterBody3D:
		grounded = (_player as CharacterBody3D).is_on_floor()
	else:
		grounded = _foot_ray != null and _foot_ray.is_colliding()

	# compute horizontal moved distance and horizontal speed
	var moved: float = 0.0
	var h_speed: float = 0.0
	if _player is CharacterBody3D:
		var vel = (_player as CharacterBody3D).velocity
		h_speed = Vector2(vel.x, vel.z).length()
		moved = h_speed * delta
	else:
		var pos: Vector3 = _player.global_transform.origin
		var d: float = Vector2(pos.x - _prev_pos.x, pos.z - _prev_pos.z).length()
		moved = d
		h_speed = d / max(delta, 1e-6)
		_prev_pos = pos

	# accumulate distance and trigger footstep
	if grounded and moved > 0.001:
		var t := clamp(h_speed / max_speed, 0.0, 1.0)
		var step_distance := lerp(max_step_distance, min_step_distance, t)
		_distance_accum += moved
		if _distance_accum >= step_distance:
			_distance_accum -= step_distance
