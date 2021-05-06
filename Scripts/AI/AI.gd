extends Node2D
signal state_changed(new_state)

onready var target_detect_area = $TargetDetect

# Actor Variables
var actor: Actor = null
var actor_velocity: Vector2 = Vector2.ZERO
var actor_team: String

var target: KinematicBody2D = null
var ship: Ship = null
var origin: Vector2 = Vector2.ZERO
var journey_distance: float = 0.0
var journey_percent: float = 0.0

enum State {
	PATROL,
	ENGAGE
}

var current_state: int = State.PATROL setget set_state

# State Timers
# Time to wait before firing on a newly engaged target, to avoid instant fire
onready var engage_timer = Timer.new()
var engage_speed = 2
# Time to wait to return to patrolling/stop chasing a just lost target
onready var patrol_timer = Timer.new()
var patrol_wait = 3
var patrol_target: Vector2 = Vector2.ZERO
export (float, 1.0, 9000.0) var patrol_range = 2000
var patrol_reached: bool = true
# Time to wait to return to origin position after chasing a target to a new area
onready var origin_timer = Timer.new()
var origin_wait = 45

onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
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
	
func initialize(newActor: Actor, newShip: Ship, newTeam: String):
	self.actor = newActor
	self.ship = newShip
	self.actor_team = newTeam
	origin = actor.position
	_install_state_timers()

func set_state(new_state: int) -> void:
	if new_state == current_state:
		return		
	current_state = new_state
	emit_signal("state_changed", current_state)


func _install_state_timers():
	add_child(engage_timer)
	engage_timer.wait_time = engage_speed
	add_child(patrol_timer)
	patrol_timer.wait_time = patrol_wait
	add_child(origin_timer)
	origin_timer.wait_time = origin_wait

func _patrol():
	if patrol_target.distance_to(actor.global_position) < 50:
		patrol_reached = true
	if !patrol_reached:
		#actor.rotate_toward(patrol_target)
		journey_percent = clamp(actor.global_position.distance_to(patrol_target) / journey_distance, 0.2, 1.0)
	else:
		var random_x = rng.randf_range(-patrol_range, patrol_range)
		var random_y = rng.randf_range(-patrol_range, patrol_range)
		patrol_target = Vector2(random_x, random_y) + origin
		journey_distance = actor.global_position.distance_to(patrol_target)
		patrol_reached = false
		

func _engage():
	if target != null and ship != null:
		#actor.rotation = actor.global_position.direction_to(target.global_position)
		journey_percent = clamp(actor.global_position.distance_to(target.global_position) / journey_distance, 0, 1.0)
		#actor.rotate_toward(target.global_position)
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
	journey_distance = actor.global_position.distance_to(target.global_position)
	

func _on_TargetLeash_body_exited(body):
	if target && body == target:
		set_state(State.PATROL)
		target = null
