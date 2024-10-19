extends StaticBody2D


signal detonated

var wipeout_bodies: Array


func _ready() -> void:
	$AnimationPlayer.play("windup")


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body is ROV or body is Alien:
		wipeout_bodies.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	print(body.name)
	if body is ROV or body is Alien:
		wipeout_bodies.erase(body)


func wipeout() -> void:
	detonated.emit()
	for i in wipeout_bodies:
		i.queue_free()
	queue_free()
