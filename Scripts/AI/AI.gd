extends Node2D
signal state_changed(new_state)

onready var target_detect_area = $TargetDetect

# Actor Variables
var actor: KinematicBody2D = null
var actor_velocity: Vector2 = Vector2.ZERO
var actor_team: String

var target: KinematicBody2D = null
var ship: Ship = null
var origin: Vector2 = global_position

enum State {
	PATROL,
	ENGAGE
}

var current_state: int = State.PATROL setget set_state

# Movement constants
const m_s_up = Vector2.ZERO
const m_s_sos = false
const m_s_maxsli = 4
const m_s_fma = 0.785398

var velocity: Vector2 = Vector2.ZERO


# State Timers
# Time to wait before firing on a newly engaged target, to avoid instant fire
onready var engage_timer = Timer.new()
var engage_speed = 2
# Time to wait to return to patrolling/stop chasing a just lost target
onready var patrol_timer = Timer.new()
var patrol_wait = 3
# Time to wait to return to origin position after chasing a target to a new area
onready var origin_timer = Timer.new()
var origin_wait = 45


func _ready() -> void:
	set_state(State.PATROL)
	

func _physics_process(delta: float) -> void:
	if !actor:
		return
		
	match current_state:
		State.PATROL:
			_patrol()
		State.ENGAGE:
			_engage()
		_:
			printerr("Error: Found a state for enemy that should not exist", self)
	
	move(delta)

func initialize(newActor: KinematicBody2D, newShip: Ship, newTeam: String):
	self.actor = newActor
	self.ship = newShip
	self.actor_team = newTeam
	_install_state_timers()

func set_state(new_state: int) -> void:
	if new_state == current_state:
		return
		
	current_state = new_state
	emit_signal("state_changed", current_state)

func move(delta: float):
	var thrust_vector = Vector2.ZERO
	var strafe_vector = Vector2.ZERO
	if target:
		thrust_vector.x = 1.0
		thrust_vector.x -= clamp(abs(actor.global_position.angle_to(target.global_position)), 0.0, 1.0)
	thrust_vector = thrust_vector.rotated(global_rotation)
	thrust_vector = thrust_vector.normalized()
	
	if thrust_vector != Vector2.ZERO:		
		velocity = velocity.move_toward(thrust_vector * actor.MAX_SPEED, actor.ACCELERATION * delta)
	velocity = actor.move_and_slide(velocity, m_s_up, m_s_sos, m_s_maxsli, m_s_fma, false)
	
#	for index in get_slide_count():
#		var collision = get_slide_collision(index)
#
#		if collision.collider.is_in_group("asteroids"):
#			collision.collider.apply_impulse(velocity, -collision.normal * (velocity * MASS))
#			var damage = velocity.length()/20			
#			take_damage(damage)


func _install_state_timers():
	add_child(engage_timer)
	engage_timer.wait_time = engage_speed
	add_child(patrol_timer)
	patrol_timer.wait_time = patrol_wait
	add_child(origin_timer)
	origin_timer.wait_time = origin_wait

func _patrol():
	pass





func _engage():
	if target != null and ship != null:
		#actor.rotation = actor.global_position.direction_to(target.global_position)
		actor.rotate_toward(target.global_position)
		if abs(actor.global_position.angle_to(target.global_position)) < 0.2:
			ship.fire_weapons(actor_velocity)
	else:
		print("In engage state but no target/ship")

func _on_TargetDetect_body_entered(body: Node) -> void:
	if body.is_in_group(actor_team):
		return
		
	print_debug("Target detected by: ", self, "in group", actor_team, " target: ", body)
	set_state(State.ENGAGE)
	target = body

func _on_TargetLeash_body_exited(body):
	if target && body == target:
		set_state(State.PATROL)
		target = null
