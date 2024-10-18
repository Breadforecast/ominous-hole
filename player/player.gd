class_name Player
extends CharacterBody3D


const SPEED := 5.0
const ACCELERATION := 50.0
const CAMERA_CLAMP := deg_to_rad(85.0)

@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var raycast: RayCast3D
@export var hold_point: Node3D
@export var drop_point: Node3D
@export var drop_preview: MeshInstance3D

var _input_dir: Vector2
var _camera_input_direction := Vector2.ZERO
var mouse_sensitivity: float
var viewport_selected: SubViewport
var holding: Pickup


func _ready() -> void:
	Global.options_updated.connect(_on_options_updated)
	mouse_sensitivity = Global.user_options.mouse_sensitivity


func _input(event: InputEvent) -> void:
	var captured := (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED or
			not viewport_selected)

	if Input.is_action_just_pressed("left_click") and captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("ui_cancel"):
		if viewport_selected:
			viewport_selected.owner.interacting = false
			viewport_selected = null
			%PlayerUI.set_crosshair_visibility(true)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("drop") and holding:
		hold_point.remove_child(holding)
		get_parent().add_child(holding)
		holding.global_position = drop_point.global_position
		holding.rotation.y = camera_pivot.rotation.y
		holding = null

	if captured:
		_input_dir = Input.get_vector("strafe_left", "strafe_right",
				"forward", "backward")
	else:
		_input_dir = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := ( event is InputEventMouseMotion and
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity


func _process(delta: float) -> void:
	drop_preview.visible = is_instance_valid(holding)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := (camera_pivot.transform.basis * Vector3(_input_dir.x,
			0, _input_dir.y)).normalized()

	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta)

	_camera_movement(delta)

	move_and_slide()


func _camera_movement(delta: float) -> void:
	camera_pivot.rotation.x -= _camera_input_direction.y * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x,
			-CAMERA_CLAMP, CAMERA_CLAMP)
	camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO


func _on_options_updated() -> void:
	mouse_sensitivity = Global.user_data.mouse_sensitivity
