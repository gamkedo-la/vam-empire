extends RigidBody2D

export var health = 200

func _ready():
	add_to_group("asteroids")

func _process(_delta):
	if health < 0:
		queue_free()


func _on_HurtBox_area_entered(area):
	var hitParent = area.get_parent()
	health -= hitParent.Damage
	hitParent.hit_something()

