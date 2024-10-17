class_name Alien
extends CharacterBody2D


const SPEED := 75.0

enum States {WANDER, CHASE}

@export var wander_points: Node2D

var rov: ROV
var state := States.WANDER

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var player_ray_cast: RayCast2D = $PlayerRayCast


func _ready() -> void:
	_on_nav_agent_navigation_finished()


func _physics_process(delta: float) -> void:
	var next_path_position := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_path_position)
	var new_velocity = direction * SPEED
	player_ray_cast.target_position = to_local(rov.global_position)
	
	if player_ray_cast.is_colliding():
		state = States.WANDER
	else:
		state = States.CHASE
	
	nav_agent.velocity = new_velocity


func _on_nav_agent_navigation_finished() -> void:
	if state == States.WANDER:
		var points := wander_points.get_children()
		var point: Marker2D = points.pick_random()
		_make_path(point.global_position)
	elif state == States.CHASE:
		_make_path(rov.global_position)


func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	var delta := get_physics_process_delta_time()
	velocity = velocity.move_toward(safe_velocity, 100.0 * delta)
	move_and_slide()


func _make_path(pos: Vector2) -> void:
	nav_agent.target_position = pos
