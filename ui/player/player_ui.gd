extends CanvasLayer


func set_crosshair_visibility(state: bool) -> void:
	%Crosshair.visible = state


func set_input_visibility(state: bool) -> void:
	%InteractCrosshair.visible = state


func _process(delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())
