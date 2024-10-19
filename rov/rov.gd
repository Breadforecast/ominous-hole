class_name ROV
extends CharacterBody2D


const SPEED := 100.0
const ROTATIONS_SPEED := 1.25
const BOMB_DISTANCE := 3.0
const EPSILON := 0.5

@export var bomb_scene: PackedScene
@export var commands: Commands
@export var walking_audible_area: Area2D
@export var sound_emit_animation_player: AnimationPlayer

var target_position: Vector2
var target_rotation: float
var pickable_items: Array[ROVPickup]
var shoot_area_targets: Array[Alien]


func _ready() -> void:
	target_position = global_position
	if commands:
		commands.move_drone.connect(move_drone)
		commands.rotate_drone.connect(rotate_drone)
		commands.drone_pickup.connect(pickup_item)
		commands.drone_bomb_drop.connect(create_bomb)
		commands.drone_sound_emit.connect(emit_sound)
		commands.drone_shoot.connect(shoot)


func _physics_process(delta: float) -> void:
	rotation = rotate_toward(rotation, target_rotation, ROTATIONS_SPEED * delta)

	var new_velocity = global_position.direction_to(target_position) * SPEED
	if not _on_target_position():
		velocity = new_velocity
		print("Audible")
	else:
		velocity = Vector2.ZERO
		target_position = global_position
	walking_audible_area.monitorable = velocity.length() > 0.01
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


func create_bomb() -> void:
	var i := bomb_scene.instantiate()
	i.global_position += global_position - Vector2(0.0, BOMB_DISTANCE * 10.0).rotated(rotation)
	i.detonated.connect(
		func():
			%BombShake.play_shake()
	)
	add_sibling(i)


func emit_sound() -> void:
	sound_emit_animation_player.play("sound_emit")


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
	return ((x_1 > x_2 - EPSILON and x_1 < x_2 + EPSILON) and
			(y_1 > y_2 - EPSILON and y_1 < y_2 + EPSILON))


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
