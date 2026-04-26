extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Fixed typo and call safely: prefer calling on self if available,
	# otherwise look for a Skeleton3D child node.
	if has_method("physical_bones_start_simulation"):
		physical_bones_start_simulation()
		return
	var sk = get_node_or_null("Skeleton3D")
	if sk == null:
		sk = get_node_or_null("Armature/Skeleton3D")
	if sk and sk.has_method("physical_bones_start_simulation"):
		sk.physical_bones_start_simulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
