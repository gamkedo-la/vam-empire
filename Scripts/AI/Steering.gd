extends Node2D
class_name ActorSteering

# Dependencies/Actor Variables
var actor: Actor = null
var ai: AIController = null
var actor_velocity: Vector2 = Vector2.ZERO
var actor_team: String
var ship: Ship = null
var origin: Vector2 = Vector2.ZERO

# Movement constants
const m_s_up = Vector2.ZERO
const m_s_sos = false
const m_s_maxsli = 4
const m_s_fma = 0.785398

var velocity: Vector2 = Vector2.ZERO

# Context-Base Steering Variables borrowing and adapting from concepts found @
# https://kidscancode.org/godot_recipes/ai/context_map/
export var steer_force = 0.1
export var look_ahead = 250
export var num_rays = 16

# context arrays
var ray_directions = []
var interest = []
var danger = []
var danger_pos = []

var chosen_dir: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var steer_time: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# context steering prep
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
	


func _physics_process(delta: float):
	move(delta)

func move(delta: float):	
	set_interest()
	if steer_time > 0.1:
		set_danger()	
	choose_direction()
	
	
	var arrive_pct = clamp(ai.journey_percent, 0.01, 0.8)	
	var desired_velocity = chosen_dir.rotated(actor.rotation) * (actor.MAX_SPEED * arrive_pct)
	velocity = velocity.linear_interpolate(desired_velocity, steer_force)
	#rotation = lerp_angle(rotation, velocity.angle(), ROT_SPEED)
	actor.rotation = velocity.angle()
#	actor.move_and_collide(velocity * delta)
	velocity = actor.move_and_slide(velocity, m_s_up, m_s_sos, m_s_maxsli, m_s_fma, false)
	update()

func initialize(newActor: Actor, newShip: Ship, newTeam: String, newAI: AIController):
	self.actor = newActor
	self.ship = newShip
	self.actor_team = newTeam
	self.ai = newAI
	origin = actor.position	

func set_interest() -> void:
	# Set interest in each slot based on world direction	
	var path_direction: Vector2 = ai.get_current_target()
	for i in num_rays:
		var d = ray_directions[i].dot(path_direction)
		interest[i] = max(1, d)

func set_danger() -> void:
	# Cast rays to find danger directions
	danger_pos = []
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(actor.global_position,
				actor.global_position + ray_directions[i].rotated(actor.global_rotation) * look_ahead,
				[self,actor])
		if result:
			danger[i] = actor.global_position.distance_to(result.position) / look_ahead
			danger_pos.append(result.position)
		else:
			danger[i] = 0.0

func choose_direction() -> void:
	# Eliminate interest in slots with danger

	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] *= clamp(danger[i], 0.0, 1.0)
	# Choose direction based on remaining interest

	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()

func _draw():
	if UserSettings.current.system.show_context_steering:
		for i in num_rays:
			draw_line(transform.x, ray_directions[i] * look_ahead, Color.purple)
			if interest[i]:
				draw_line(transform.x, ray_directions[i] * interest[i], Color.green)
			if danger[i]:
				draw_line(ray_directions[i] * interest[i], ray_directions[i] * (danger[i] * look_ahead), Color.red)
		for hit in danger_pos:
			draw_circle((hit - global_position).rotated(-global_rotation), 5, Color.aqua)
		if ai.target != null:
			draw_line(transform.x, to_local(ai.target.global_position), Color.red)
#	draw_line(actor.position, patrol_target, Color.yellow)


