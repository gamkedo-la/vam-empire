extends RigidBody2D

const MaxDistance = 800
const MaxSeconds = 1
const ImpulseMag = 550
const Damage = 100

var originalPos = Vector2.ZERO

onready var animPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var smoketrail = $Smoketrail

var lifetime = 0
var owner_ref = null

func launchBullet(rnd_impulse, direction, parentRef):
	self.add_to_group("projectile")
	originalPos = self.position	
	owner_ref = parentRef
	apply_central_impulse(direction * (ImpulseMag * rnd_impulse))
	

func _process(_delta):
	smoketrail.add_point(global_position)

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
