extends RigidBody2D

const MaxDistance = 800
const MaxSeconds = 1
const ImpulseMag = 550
const Damage = 100

var originalPos = Vector2.ZERO

onready var animPlayer = $AnimationPlayer
onready var sprite = $Sprite

func _ready():
	animPlayer.play("fireLaser")
	animPlayer.play("keepFiringLaser")


func hit_something():
	animPlayer.play("keepFiringLaser")
	
func free_laser_beam():
	queue_free()
