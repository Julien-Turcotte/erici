extends Node3D

func _ready() -> void:
	print("alien_freakstersfix: ready")
	var sk = get_node_or_null("Armature/Skeleton3D")
	if sk == null:
		sk = get_node_or_null("Armature/Skeleton")
	if sk == null:
		sk = get_node_or_null("Skeleton3D")
	if sk == null:
		print("alien_freakstersfix: Skeleton node not found; physical bones not started")
		return
	if sk.has_method("physical_bones_start_simulation"):
		sk.physical_bones_start_simulation()
	else:
		print("alien_freakstersfix: method physical_bones_start_simulation not available on Skeleton")
