extends Node


signal options_updated


var user_options := {
	"mouse_sensitivity": 0.5, # Range of 0-1, steps of 0.01
	"master_volume": 0.5, # Linear volume, range of 0-1, steps of 0.01
	"max_fps": 1000, # Range of 1-360, steps of 1
}


func _ready() -> void:
	reset_volume()
	set_fps()


func reset_volume() -> void:
	var m_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(m_index, 
			linear_to_db(user_options.master_volume))


func set_fps() -> void:
	Engine.max_fps = user_options.max_fps
