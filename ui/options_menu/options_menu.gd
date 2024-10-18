extends PanelContainer


func _ready() -> void:
	%VolumeSlider.value = Global.user_options.master_volume
	%SensitivitySlider.value = Global.user_options.mouse_sensitivity
	%MaxFPSSlider.value = Global.user_options.max_fps

func apply() -> void:
	Global.user_options.mouse_sensitivity = %SensitivitySlider.value
	Global.user_options.master_volume = %VolumeSlider.value
	Global.user_options.max_fps = %MaxFPSSlider.value
	Global.reset_volume()
	Global.set_fps()
	Global.options_updated.emit()


func _on_apply_button_pressed() -> void:
	apply()


func _on_confirm_button_pressed() -> void:
	apply()
	queue_free()


func _on_max_fps_slider_value_changed(value: float) -> void:
	%MaxFPSValueLabel.text = str(value)
