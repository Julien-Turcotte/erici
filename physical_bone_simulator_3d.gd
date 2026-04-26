extends PhysicalBoneSimulator3D

func _ready() -> void:
	influence = 1.0
	call_deferred("_initialize_ragdoll")


func _initialize_ragdoll() -> void:
	var skeleton := _find_parent_skeleton()
	if skeleton == null:
		return
	await get_tree().physics_frame
	_disable_animation_nodes(_get_scene_root())
	_start_ragdoll(skeleton)


func _get_scene_root() -> Node:
	var node: Node = self
	while node.get_parent() != null:
		node = node.get_parent()
	return node


func _disable_animation_nodes(node: Node) -> void:
	if node is AnimationPlayer:
		(node as AnimationPlayer).stop()
		if _has_property(node, "playback_active"):
			node.set("playback_active", false)
	if node is AnimationTree:
		if _has_property(node, "active"):
			node.set("active", false)
	if node.get_class() == "AnimationMixer":
		if _has_property(node, "active"):
			node.set("active", false)
	for child in node.get_children():
		_disable_animation_nodes(child)


func _has_property(node: Object, property_name: String) -> bool:
	for p in node.get_property_list():
		if p.has("name") and p["name"] == property_name:
			return true
	return false


func _find_parent_skeleton() -> Skeleton3D:
	var node := get_parent()
	while node != null:
		if node is Skeleton3D:
			return node
		node = node.get_parent()
	return null
func _start_ragdoll(skeleton: Skeleton3D) -> void:
	if not skeleton.has_method("physical_bones_start_simulation"):
		return
	for child in get_children():
		if child is PhysicalBone3D:
			_set_default_joint_limits(child)
			child.can_sleep = false
			_nudge_bone(child)
	skeleton.physical_bones_start_simulation()


func _nudge_bone(physical_bone: PhysicalBone3D) -> void:
	if physical_bone.has_method("set_sleep_state"):
		physical_bone.set_sleep_state(false)
	if physical_bone.has_method("apply_central_impulse"):
		physical_bone.apply_central_impulse(Vector3(0.0, -0.03, 0.01))
func _set_default_joint_limits(physical_bone: PhysicalBone3D) -> void:
	for axis in ["x", "y", "z"]:
		physical_bone.set("joint_constraints/%s/angular_limit_enabled" % axis, true)
		physical_bone.set("joint_constraints/%s/angular_limit_upper" % axis, 35.0)
		physical_bone.set("joint_constraints/%s/angular_limit_lower" % axis, -35.0)
func _process(_delta: float) -> void:
	pass
