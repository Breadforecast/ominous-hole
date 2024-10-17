class_name Screen
extends MeshInstance3D


@export var viewport: SubViewport
@export var terminal: Control
@export var camera: Camera3D

var interacting: set = set_interacting

func set_interacting(value: bool) -> void:
	interacting = value
	camera.current = value
	terminal.set_input_focus(value)
	viewport.gui_disable_input = not value
	Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if value else 
			Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if interacting:
		viewport.push_input(event)
