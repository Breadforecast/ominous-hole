extends Node2D


@export var aliens_node: Node2D
@export var rov: ROV


func _ready() -> void:
	for i in aliens_node.get_children():
		if i is Alien:
			i.rov = rov
