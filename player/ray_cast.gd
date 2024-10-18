extends RayCast3D


@export var player: Player

var prev_hover
var pressed := false


func _input(event: InputEvent) -> void:
	var can_interact := is_colliding() and not player.holding
	%PlayerUI.set_input_visibility(can_interact)
	if can_interact:
		var collider := get_collider()
		var collider_owner = collider.owner
		var can_pickup_item := collider is Pickup and player.holding == null
		if Input.is_action_just_pressed("interact"):
			if collider_owner is Screen:
				collider_owner.interacting = true
				player.viewport_selected = collider_owner.viewport
				%PlayerUI.set_crosshair_visibility(false)
				return
			if can_pickup_item:
				player.holding = collider
				player.holding.get_parent().remove_child(player.holding)
				player.hold_point.add_child(player.holding)
				player.holding.position = Vector3.ZERO
				player.holding.rotation = Vector3.ZERO
				return
			click()
	if Input.is_action_just_released("interact"):
		release()


func click():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				'action': 'click'
				})
			pressed = true
		prev_hover = tmpcol


func release():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				'action': 'click'
				})
			pressed = false
	elif prev_hover:
		if prev_hover.has_method("laser_input"):
			prev_hover.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				'action': 'click'
				})
