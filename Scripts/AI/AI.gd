extends Node2D
signal state_changed(new_state)

onready var target_detect_area = $TargetDetect

# Actor Variables
var actor: Actor = null
var actor_velocity: Vector2 = Vector2.ZERO
var actor_team: String

var target: KinematicBody2D = null
var ship: Ship = null
var origin: Vector2 = global_position
var journey_distance: float = 0.0
var journey_percent: float = 0.0

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

# Context-Base Steering Variables borrowing and adapting from concepts found @
# https://kidscancode.org/godot_recipes/ai/context_map/
export var steer_force = 0.1
export var look_ahead = 100
export var num_rays = 8

# context arrays
var ray_directions = []
var interest = []
var danger = []

var chosen_dir: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO



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
	
	# context steering prep
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
	

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

func initialize(newActor: Actor, newShip: Ship, newTeam: String):
	self.actor = newActor
	self.ship = newShip
	self.actor_team = newTeam
	_install_state_timers()

func set_state(new_state: int) -> void:
	if new_state == current_state:
		return		
	current_state = new_state
	emit_signal("state_changed", current_state)

func move(delta: float) -> void:
	set_interest()
	set_danger()
	choose_direction()
	if journey_percent <= 0.0:
		journey_percent = 0.01
	var desired_velocity = chosen_dir.rotated(actor.rotation) * (actor.MAX_SPEED * journey_percent)
	velocity = velocity.linear_interpolate(desired_velocity, steer_force)
	rotation = velocity.angle()
	actor.move_and_collide(velocity * delta)


func set_interest() -> void:
	# Set interest in each slot based on world direction

	if owner and owner.has_method("get_path_direction"):
		var path_direction = owner.get_path_direction(global_position)
		for i in num_rays:
			var d = ray_directions[i].rotated(global_rotation).dot(path_direction)
			interest[i] = max(0, d)
	# If no world path, use default interest
	
	else:
		set_default_interest()

func set_default_interest():
	# Default to moving forward

	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)

func set_danger() -> void:
	# Cast rays to find danger directions

	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(position,
				position + ray_directions[i].rotated(rotation) * look_ahead,
				[self])
		danger[i] = 1.0 if result else 0.0

func choose_direction() -> void:
	# Eliminate interest in slots with danger

	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest

	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()

func get_path_direction(pos) -> Vector2:
	if target:
		return target.global_position
	elif patrol_target:
		return patrol_target
	else:
		return Vector2.ZERO
		

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
		actor.rotate_toward(patrol_target)
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
		journey_percent = clamp(actor.global_position.distance_to(target.global_position) / journey_distance, 0.2, 1.0)
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
	journey_distance = actor.global_position.distance_to(target.global_position)
	

func _on_TargetLeash_body_exited(body):
	if target && body == target:
		set_state(State.PATROL)
		target = null
