extends Control


@export var radar_viewport: SubViewport
@export var command_output: VBoxContainer
@export var command_input: LineEdit
@export var commands: Commands


func clear_command_output() -> void:
	for label in command_output.get_children():
		label.queue_free()


func output_command_text(text: String, show_arrow := true) -> void:
	var label := RichTextLabel.new()
	label.text = ">%s" % text if show_arrow else text
	label.scroll_active = false
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	command_output.add_child(label)
	command_input.clear()


func set_input_focus(value: bool) -> void:
	if value:
		command_input.grab_focus()
	else:
		command_input.release_focus()


func _on_input_field_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		return
	output_command_text(new_text)
	commands.send_command(new_text)


func _on_commands_text_outputted(text: String) -> void:
	output_command_text(text, false)


func _on_commands_clear_terminal() -> void:
	clear_command_output()
