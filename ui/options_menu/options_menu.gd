extends PanelContainer


func _ready() -> void:
	%VolumeSlider.value = Global.user_options.master_volume
	%SensitivitySlider.value = Global.user_options.mouse_sensitivity


func apply() -> void:
	Global.user_options.mouse_sensitivity = %SensitivitySlider.value
	Global.user_options.master_volume = %VolumeSlider.value
	Global.reset_volume()
	Global.options_updated.emit()


func _on_apply_button_pressed() -> void:
	apply()


func _on_confirm_button_pressed() -> void:
	apply()
	queue_free()
