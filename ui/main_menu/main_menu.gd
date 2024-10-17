extends MarginContainer


@export var options_menu_scene: PackedScene
@export var ship_scene: PackedScene


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(ship_scene)


func _on_options_button_pressed() -> void:
	var om := options_menu_scene.instantiate()
	add_sibling(om)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
