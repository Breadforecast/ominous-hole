class_name ROV
extends CharacterBody2D


const SPEED := 150.0
const ROTATIONS_SPEED := 0.05
const EPSILON := 0.5

@export var commands: Commands

var target_position: Vector2 
var target_rotation: float


func _ready() -> void:
	target_position = global_position
	if commands:
		commands.move_drone.connect(move_drone)
		commands.rotate_drone.connect(rotate_drone)


func move_drone(units: float) -> void:
	target_position = global_position - Vector2(0.0, units).rotated(rotation)
	print("Drone moved!")


func rotate_drone(degrees: float) -> void:
	var new_rotation_radians := rotation + deg_to_rad(degrees)
	target_rotation = new_rotation_radians
	print("Drone rotated!")


func _on_target_position() -> bool:
	var x_1 := global_position.x
	var y_1 := global_position.y
	var x_2 := target_position.x
	var y_2 := target_position.y
	return ((x_1 > x_2 - EPSILON and x_1 < x_2 + EPSILON) and 
			(y_1 > y_2 - EPSILON and y_1 < y_2 + EPSILON))


func _physics_process(delta: float) -> void:
	rotation = rotate_toward(rotation, target_rotation, ROTATIONS_SPEED)
	
	var new_velocity = global_position.direction_to(target_position) * SPEED
	if not _on_target_position():
		velocity = new_velocity
	else:
		velocity = Vector2.ZERO
		target_position = global_position
	move_and_slide()
