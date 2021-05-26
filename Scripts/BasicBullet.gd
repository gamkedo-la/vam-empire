extends RigidBody2D

const MaxDistance = 800
const MaxSeconds = 1
const ImpulseMag = 550
const Damage = 100

var originalPos = Vector2.ZERO

onready var animPlayer = $AnimationPlayer
onready var sprite = $Sprite
var lifetime = 0

func launchBullet(rnd_impulse, direction):
	originalPos = self.position	
	
	apply_central_impulse(direction * (ImpulseMag * rnd_impulse))
	

func _physics_process(delta):
	lifetime += delta
	var distanceTravelled = self.position.distance_to(originalPos)
	if distanceTravelled > 0:
		sprite.visible = true;
	if distanceTravelled > MaxDistance || lifetime > 5:
		queue_free()
		
func hit_something():
	apply_central_impulse((Vector2.ZERO + self.linear_velocity*.25) * -1)
	animPlayer.play("HitTarget")
	
func free_bullet():
	queue_free()
