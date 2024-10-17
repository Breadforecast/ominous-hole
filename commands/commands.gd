class_name Commands
extends Node


signal text_outputted(text: String)
signal move_drone(units: float)
signal rotate_drone(degrees: float)
signal clear_terminal

@export_category("Help Command")
@export var help_acceptable_inputs: Array[String]
@export_multiline var help_text: String
@export_category("Move Drone Command")
@export var move_drone_acceptable_inputs: Array[String]
@export_category("Rotate Drone Command")
@export var rotate_drone_acceptable_inputs: Array[String]
@export_category("Clear Command")
@export var clear_acceptable_inputs: Array[String]


func send_command(command_text: String) -> void:
	command_text = command_text.to_lower()
	var split_command_text := command_text.split(" ", false, 1)
	
	if split_command_text[0] in help_acceptable_inputs:
		text_outputted.emit(help_text)
		return
	if split_command_text[0] in move_drone_acceptable_inputs:
		var units := split_command_text[1].to_int()
		move_drone.emit(units)
		text_outputted.emit("Moved R.O.V. %s units." % units)
		return
	if split_command_text[0] in rotate_drone_acceptable_inputs:
		var degrees := split_command_text[1].to_int()
		degrees = wrapf(degrees, -360.1, 360.1)
		rotate_drone.emit(degrees)
		text_outputted.emit("Rotated R.O.V. %s degrees." % degrees)
		return
	if split_command_text[0] in clear_acceptable_inputs:
		clear_terminal.emit()
		return
	text_outputted.emit("Unknown command.")
