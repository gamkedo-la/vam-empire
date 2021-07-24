extends RigidBody2D

signal disengage

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
	visible = false
	emit_signal("disengage", self)
	damageTickTimer.wait_time = 1.0
	if not damageTickTimer.is_connected("timeout", self, "_free_beam"):
		assert(damageTickTimer.connect("timeout", self, "_free_beam") == OK)
	damageTickTimer.start()
	
	
func _free_beam() -> void:
	call_deferred("queue_free")

# e.g. when temporary laser disabling is over
func _on_DamageTickTimer_timeout():
	hurtBox.monitorable = true
