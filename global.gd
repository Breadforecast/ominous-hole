extends Node


signal options_updated


var user_options := {
	"mouse_sensitivity": 0.5, # Range of 0-1
	"master_volume": 0.5, # Linear volume, range of 0-1
}


func _ready() -> void:
	reset_volume()


func reset_volume() -> void:
	var m_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(m_index, 
			linear_to_db(user_options.master_volume))
