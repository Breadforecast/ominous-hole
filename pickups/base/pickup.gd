class_name Pickup
extends RigidBody3D


@export var fancy_name: String
@export var mesh: MeshInstance3D
@export var collision_shape: CollisionShape3D


func _enter_tree() -> void:
	var being_held := get_parent().name == "HoldPoint"
	freeze = being_held
	mesh.set_layer_mask_value(1, not being_held)
	mesh.set_layer_mask_value(2, being_held)
	collision_shape.disabled = being_held
