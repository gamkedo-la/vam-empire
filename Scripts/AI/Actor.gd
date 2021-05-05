extends KinematicBody2D
class_name Actor
signal removed
onready var ai = $AI

# Team Variables
enum Team {
	FRIENDLY,
	PIRATE,
	VAMPIRE
}

export (Team) var actor_team
var team_group = null
# Loaded from Ship
var ACCELERATION: int = 0
var MAX_SPEED: int = 0
var FRICTION: int = 0
var MASS: int = 0
var ROT_SPEED: float = 0
var ROT_ACCEL: float = 0
var shieldHealth: int = 0
var hullHealth: int = 0
var energyReserve: int = 0
var shieldMaxHealth: int = 0
var hullMaxHealth: int = 0
var energyMax: int = 0
var healingMaxEnergy: int = 0



export var ship_file = preload("res://Ships/Templates/M_Destroyers/DestroyerTemplate01.tscn")
onready var ship_node = $PilotedShip
onready var minimap_sprite = $Sprite


# Movement constants
const m_s_up = Vector2.ZERO
const m_s_sos = false
const m_s_maxsli = 4
const m_s_fma = 0.785398

var velocity: Vector2 = Vector2.ZERO


# Context-Base Steering Variables borrowing and adapting from concepts found @
# https://kidscancode.org/godot_recipes/ai/context_map/
export var steer_force = 0.1
export var look_ahead = 300
export var num_rays = 64

# context arrays
var ray_directions = []
var interest = []
var danger = []
var danger_pos = []

var chosen_dir: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO



var piloted_ship = null
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pilot_ship_from_file(ship_file)
	instantiate_ship_variables()
	var ship_sprite = piloted_ship.get_node_or_null("ShipSprite")
	if ship_sprite:
		minimap_sprite.texture = ship_sprite.texture
	_set_team()
	if team_group:
		self.add_to_group(team_group)
	ai.initialize(self, piloted_ship, team_group)
	
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
	set_danger()
	choose_direction()
	
	var arrive_pct = clamp(ai.journey_percent, 0.05, .8)	
	var desired_velocity = chosen_dir.rotated(rotation) * (MAX_SPEED * arrive_pct)
	velocity = velocity.linear_interpolate(desired_velocity, steer_force)
	#rotation = lerp_angle(rotation, velocity.angle(), ROT_SPEED)
	rotation = velocity.angle()
	move_and_collide(velocity * delta)
	update()


func pilot_ship_from_file(ship):
	piloted_ship = ship.instance()
	ship_node.add_child(piloted_ship)	
	var hull = piloted_ship.get_node_or_null("HullCollision")
	Global.reparent(hull, self)

func instantiate_ship_variables():
	ACCELERATION = piloted_ship.ACCELERATION	
	MAX_SPEED = piloted_ship.MAX_SPEED	
	FRICTION = piloted_ship.FRICTION	
	MASS = piloted_ship.MASS	
	ROT_SPEED = piloted_ship.ROT_SPEED	
	ROT_ACCEL = piloted_ship.ROT_ACCEL	
	shieldHealth = piloted_ship.shieldHealth	
	hullHealth = piloted_ship.hullHealth	
	energyReserve = piloted_ship.energyReserve	

func rotate_toward(location: Vector2):
	global_rotation = lerp_angle(global_rotation, global_position.direction_to(location).angle(), ROT_SPEED)

func set_interest() -> void:
	# Set interest in each slot based on world direction	
	var path_direction = get_path_direction()
	for i in num_rays:
		var d = ray_directions[i].dot(path_direction)
		interest[i] = max(1, d)

func set_danger() -> void:
	# Cast rays to find danger directions
	danger_pos = []
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(global_position,
				ray_directions[i].rotated(-global_rotation) * look_ahead,
				[self])
		if result:
			danger[i] = 1.0
			danger_pos.append(result.position)
		else:
			danger[i] = 0.0
		

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

func get_path_direction():
	if ai.target:
		return to_local(ai.target.global_position)
	elif ai.patrol_target:
		return to_local(ai.patrol_target)
	else:
		return Vector2.ZERO
		

func _draw():
	if UserSettings.current.system.show_context_steering:
		for i in num_rays:
			draw_line(transform.x, ray_directions[i] * look_ahead, Color.purple)
			if interest[i]:
				draw_line(transform.x, ray_directions[i] * interest[i], Color.green)
			if danger[i]:
				draw_line(transform.x, ray_directions[i] * look_ahead, Color.red)
		for hit in danger_pos:
			draw_circle((hit - global_position).rotated(-global_rotation), 5, Color.aqua)
		if ai.target != null:
			draw_line(transform.x, to_local(ai.target.global_position), Color.red)
#	draw_line(actor.position, patrol_target, Color.yellow)



func _set_team():
	match actor_team:
		Team.FRIENDLY:
			team_group = "friendly"
		Team.PIRATE:
			team_group = "pirate"
		Team.VAMPIRE:
			team_group = "vampire"
		_:
			printerr("Unknown Team for Actor ", self)
