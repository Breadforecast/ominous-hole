class_name Screen
extends Node3D


@export var viewport: SubViewport
@export var terminal: Control
@export var camera: Camera3D
@export var pickup_scene: PackedScene
@export var pickup_location: Node3D

var interacting: set = set_interacting


func _ready() -> void:
	terminal.commands.spawn_unknown_command.connect(_on_commands_spawn_unknown_command)


func _input(event: InputEvent) -> void:
	if interacting:
		viewport.push_input(event)


func set_interacting(value: bool) -> void:
	interacting = value
	camera.current = value
	terminal.set_input_focus(value)
	viewport.gui_disable_input = not value


func _on_commands_spawn_unknown_command() -> void:
	var s := pickup_scene.instantiate()
	add_sibling(s)
	s.global_position = pickup_location.global_position
