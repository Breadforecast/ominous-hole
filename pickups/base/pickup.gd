class_name Pickup
extends RigidBody3D


@export var fancy_name: String
@export var id: int
@export var mesh: Node3D
@export var collision_shape: CollisionShape3D


func _enter_tree() -> void:
	var being_held := get_parent().name == "HoldPoint"
	freeze = being_held
	collision_shape.disabled = being_held
