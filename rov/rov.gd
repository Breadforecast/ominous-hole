class_name ROV
extends CharacterBody2D


const SPEED := 150.0
const ROTATIONS_SPEED := 0.05
const EPSILON := 0.5

@export var commands: Commands

var target_position: Vector2
var target_rotation: float
var pickable_items: Array[ROVPickup]


func _ready() -> void:
	target_position = global_position
	if commands:
		commands.move_drone.connect(move_drone)
		commands.rotate_drone.connect(rotate_drone)
		commands.drone_pickup.connect(pickup_item)


func _physics_process(delta: float) -> void:
	rotation = rotate_toward(rotation, target_rotation, ROTATIONS_SPEED)

	var new_velocity = global_position.direction_to(target_position) * SPEED
	if not _on_target_position():
		velocity = new_velocity
	else:
		velocity = Vector2.ZERO
		target_position = global_position
	move_and_slide()


func move_drone(units: float) -> void:
	target_position = global_position - Vector2(0.0, units * 10.0).rotated(rotation)


func rotate_drone(degrees: float) -> void:
	var new_rotation_radians := rotation + deg_to_rad(degrees)
	target_rotation = new_rotation_radians


func pickup_item() -> void:
	if pickable_items.is_empty():
		return
	Global.rov_inventory.append(pickable_items[0].corresponding_3d_object)
	pickable_items[0].queue_free()
	pickable_items.remove_at(0)


func _on_target_position() -> bool:
	var x_1 := global_position.x
	var y_1 := global_position.y
	var x_2 := target_position.x
	var y_2 := target_position.y
	return ((x_1 > x_2 - EPSILON and x_1 < x_2 + EPSILON) and
			(y_1 > y_2 - EPSILON and y_1 < y_2 + EPSILON))


func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area is ROVPickup:
		pickable_items.append(area)


func _on_pickup_area_area_exited(area: Area2D) -> void:
	if area is ROVPickup:
		pickable_items.erase(area)
