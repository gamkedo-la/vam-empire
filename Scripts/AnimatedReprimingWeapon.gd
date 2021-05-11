tool
extends Weapon

func _fire_projectile(parent_velocity: Vector2) -> void:
	._fire_projectile(parent_velocity)
	$AnimationPlayer.play("Fire")

func _reprime():
	if !primed:
		$AnimationPlayer.play("Reprime")

func _on_reprime_finished():
	primed = true
