extends RigidBody2D

const MaxDistance = 800
const MaxSeconds = 1
const ImpulseMag = 550
const Damage = 100

export (float) var tickTime = 0.3

var originalPos = Vector2.ZERO

onready var animPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var damageTickTimer = $DamageTickTimer
onready var hurtBox = $HurtBox

func _ready():
	animPlayer.play("fireLaser")
	animPlayer.play("keepFiringLaser")


func hit_something():
	animPlayer.play("keepFiringLaser")
	disable_collision_temporarily()
	
func disable_collision_temporarily():
	disable_collision()
	damageTickTimer.start(tickTime)
	
func disable_collision():
	hurtBox.set_deferred("monitorable", false)
	
func free_laser_beam():
	queue_free()

# e.g. when temporary laser disabling is over
func _on_DamageTickTimer_timeout():
	hurtBox.monitorable = true
