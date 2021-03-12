extends RigidBody2D

const MaxDistance = 800
const MaxSeconds = 1
const ImpulseMag = 550
const Damage = 10

var originalPos = Vector2.ZERO

onready var animPlayer = $AnimationPlayer


func launchBullet(rnd_impulse):
	originalPos = self.position	
	
	apply_central_impulse(Vector2.UP * (ImpulseMag * rnd_impulse))

func _physics_process(delta):
	var distanceTravelled = self.position.distance_to(originalPos)
	if distanceTravelled > MaxDistance:
		queue_free()
		
func hit_something():
	apply_central_impulse((Vector2.ZERO + self.linear_velocity*.25) * -1)
	animPlayer.play("HitTarget")
	
func free_bullet():
	queue_free()
