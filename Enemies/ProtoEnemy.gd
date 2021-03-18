extends KinematicBody2D

var target = null
var chase_speed = 50
var velocity = Vector2.ZERO


func _physics_process(delta):
	velocity = Vector2.ZERO
	if target:
		look_at(target.position)
		velocity = position.direction_to(target.position) * chase_speed
	velocity = move_and_slide(velocity)

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("player"):
		target = body

func _on_PlayerLeash_body_exited(body):
	if body.is_in_group("player"):
		target = null
