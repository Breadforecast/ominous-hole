class_name ROV
extends CharacterBody2D


enum States {IDLE, MOVING, ROTATING}

const MOVE_SPEED := 100.0
const ROTATIONS_SPEED := 1.25
const BOMB_DISTANCE := 3.0
const MOVE_EPSILON := 0.5
const ROT_EPSILON := 0.01

@export var bomb_scene: PackedScene
@export var commands: Commands

var current_state := States.IDLE

var target_position: Vector2
var target_rotation: float
var pickable_items: Array[ROVPickup]
var shoot_area_targets: Array[Alien]


func _ready() -> void:
	target_position = global_position
	target_rotation = global_rotation

	if not is_instance_valid(commands):
		return
	commands.move_drone.connect(move_drone)
	commands.rotate_drone.connect(rotate_drone)
	commands.drone_pickup.connect(pickup_item)
	commands.drone_bomb_drop.connect(create_bomb)
	commands.drone_sound_emit.connect(emit_sound)
	commands.drone_shoot.connect(shoot)
	commands.drone_stop.connect(stop_drone)


func _physics_process(delta: float) -> void:
	%WalkingAudibleArea.monitorable = velocity.length() > 0.01
	match current_state:
		States.IDLE:
			stop_drone()
		States.ROTATING:
			stop_drone()
			rotation = rotate_toward(rotation, target_rotation,
					ROTATIONS_SPEED * delta)
			if _at_target_rotation():
				current_state = States.IDLE
				stop_drone()
		States.MOVING:
			if _on_target_position():
				stop_drone()
				current_state = States.IDLE
				return
			var new_velocity = (global_position.direction_to(target_position) *
					MOVE_SPEED)
			velocity = new_velocity
	move_and_slide()


func move_drone(units: float) -> void:
	target_position = (global_position -
			Vector2(0.0, units * 10.0).rotated(rotation))
	current_state = States.MOVING


func rotate_drone(degrees: float) -> void:
	var new_rotation_radians :=  deg_to_rad(degrees)
	target_rotation = new_rotation_radians
	current_state = States.ROTATING


func stop_drone() -> void:
	velocity = Vector2.ZERO
	target_position = global_position


func pickup_item() -> void:
	if pickable_items.is_empty():
		return
	Global.rov_inventory.append(pickable_items[0].corresponding_3d_object)
	pickable_items[0].queue_free()
	pickable_items.remove_at(0)


func create_bomb() -> void:
	var i := bomb_scene.instantiate()
	i.global_position += (global_position -
			Vector2(0.0, BOMB_DISTANCE * 10.0).rotated(rotation))
	i.detonated.connect(
		func():
			%BombShake.play_shake()
	)
	add_sibling(i)


func emit_sound() -> void:
	%SoundEmitAnimationPlayer.play("sound_emit")


func shoot() -> void:
	%GunShake.play_shake()
	if %GunKillAreaRayCast.is_colliding():
		return
	if shoot_area_targets.is_empty():
		return
	var alien := shoot_area_targets[0]
	shoot_area_targets.remove_at(0)
	alien.queue_free()


func _on_target_position() -> bool:
	var x_1 := global_position.x
	var y_1 := global_position.y
	var x_2 := target_position.x
	var y_2 := target_position.y
	return ((x_1 > x_2 - MOVE_EPSILON and x_1 < x_2 + MOVE_EPSILON) and
			(y_1 > y_2 - MOVE_EPSILON and y_1 < y_2 + MOVE_EPSILON))


func _at_target_rotation() -> bool:
	var x_1 := rotation
	var x_2 := target_rotation
	return x_1 > x_2 - ROT_EPSILON and x_1 < x_2 + ROT_EPSILON


func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area is ROVPickup:
		pickable_items.append(area)


func _on_pickup_area_area_exited(area: Area2D) -> void:
	if area is ROVPickup:
		pickable_items.erase(area)


func _on_gun_kill_area_body_entered(body: Node2D) -> void:
	if body is Alien:
		shoot_area_targets.append(body)


func _on_gun_kill_area_body_exited(body: Node2D) -> void:
	if body is Alien:
		shoot_area_targets.erase(body)


func _on_collision_check_body_shape_entered(body_rid: RID, body: Node2D,
		body_shape_index: int, local_shape_index: int) -> void:
	print(body.name)
	if body is not Alien or ROVPickup:
		stop_drone()
		current_state = States.IDLE
