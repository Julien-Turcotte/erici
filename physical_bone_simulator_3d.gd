extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node = get_parent()
	while node != null:
		if node is Skeleton3D:
			if node.has_method("physical_bones_start_simulation"):
				node.physical_bones_start_simulation()
			return
		node = node.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
