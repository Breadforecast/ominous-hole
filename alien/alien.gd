class_name Alien
extends CharacterBody2D


const WANDER_SPEED := 0#30.0
const CHASE_SPEED := 0#60.0

enum States {WANDER, INVESTIGATE, CHASE}

@export var wander_nav_points: Node2D
@export_category("Dependencies")
@export var nav_agent: NavigationAgent2D
@export var player_pos_ray_cast: RayCast2D
@export var main_body_sprite: Sprite2D
@export var radar_previous_sprite: Sprite2D
@export var animation_player: AnimationPlayer

var rov: ROV
var current_state := States.WANDER: set = set_current_state
var speed := WANDER_SPEED
var investigation_point: Vector2
var _last_position: Vector2


func _ready() -> void:
	_last_position = global_position
	radar_previous_sprite.global_position = global_position
	main_body_sprite.global_position = global_position
	animation_player.play("radar_ping")
	_on_nav_agent_navigation_finished()


func _physics_process(delta: float) -> void:
	var next_path_position := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_path_position)
	var new_velocity = direction * WANDER_SPEED
	if is_instance_valid(rov):
		player_pos_ray_cast.target_position = to_local(rov.global_position)

	nav_agent.velocity = new_velocity
	$PlayerDetectionArea.rotation = velocity.angle()


func set_current_state(value: States) -> void:
	current_state = value
	match current_state:
		States.WANDER:
			print("State set: Wandering")
			speed = WANDER_SPEED
		States.INVESTIGATE:
			print("State set: Investigate")
			speed = CHASE_SPEED
		States.CHASE:
			print("State set: Chasing")
			speed = CHASE_SPEED
	if not is_node_ready():
		await ready
	_on_nav_agent_navigation_finished()


func update_main_body_sprite_position() -> void:
	main_body_sprite.global_position = _last_position
	_last_position = global_position


func update_radar_previous_sprite_position() -> void:
	radar_previous_sprite.global_position = global_position


func _on_nav_agent_navigation_finished() -> void:
	match current_state:
		States.WANDER:
			var target_position: Vector2
			if is_instance_valid(wander_nav_points):
				var nav_points := wander_nav_points.get_children()
				target_position = nav_points.pick_random().global_position
			else:
				push_error("Wander Nav Points not found!")
				target_position = Vector2.ZERO
			_make_path(target_position)
		States.INVESTIGATE:
			if not global_position == investigation_point:
				_make_path(investigation_point)
			else:
				current_state = States.WANDER
		States.CHASE:
			_make_path(rov.global_position)


func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	var delta := get_physics_process_delta_time()
	velocity = velocity.move_toward(safe_velocity, 100.0 * delta)
	move_and_slide()


func _make_path(pos: Vector2) -> void:
	nav_agent.target_position = pos


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is ROV and not player_pos_ray_cast.is_colliding():
		current_state = States.CHASE


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is ROV and not player_pos_ray_cast.is_colliding():
		current_state = States.WANDER


func _on_hearing_area_entered(area: Area2D) -> void:
	investigation_point = area.global_position
	current_state = States.INVESTIGATE
