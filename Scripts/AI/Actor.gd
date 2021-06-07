extends KinematicBody2D
class_name Actor
signal removed
onready var ai = $AI

onready var hit_box = $HitBox

# Team Variables
enum Team {
	FRIENDLY,
	PIRATE,
	VAMPIRE
}

enum Squadron {
	SOLO,
	LEADER,
	MEMBER	
}

export (Team) var actor_team
export (Squadron) var squadron_status

var team_group = null

export (Array, NodePath) var squadron_members  ## Pick members if this Actor is a Squad Leader

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

var piloted_ship = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pilot_ship_from_file(ship_file)
	instantiate_ship_variables()
	var ship_sprite = piloted_ship.get_node_or_null("ShipSprite")
	if ship_sprite:
		minimap_sprite.texture = ship_sprite.texture
	_set_team()
	if team_group:
		self.add_to_group(team_group)
	ai.initialize(self, piloted_ship, team_group)
	_init_collision()

func pilot_ship_from_file(ship) -> void:
	piloted_ship = ship.instance()
	piloted_ship.set_owner(self)
	ship_node.add_child(piloted_ship)	
	var hull = piloted_ship.get_node_or_null("HullCollision")
	Global.reparent(hull, self)

func instantiate_ship_variables() -> void:
	ACCELERATION = piloted_ship.ACCELERATION	
	MAX_SPEED = piloted_ship.MAX_SPEED	
	FRICTION = piloted_ship.FRICTION	
	MASS = piloted_ship.MASS	
	ROT_SPEED = piloted_ship.ROT_SPEED	
	ROT_ACCEL = piloted_ship.ROT_ACCEL	
	shieldHealth = piloted_ship.shieldHealth	
	hullHealth = piloted_ship.hullHealth	
	energyReserve = piloted_ship.energyReserve	

func rotate_toward(location: Vector2) -> void:
	global_rotation = lerp_angle(global_rotation, global_position.direction_to(location).angle(), ROT_SPEED)

func take_damage(amount):
	if amount == 0:
		return

	# We should update shield health when shields are up and we're taking damage, or hull is full and we're healing
	var update_shield = false
	if (amount > 0 && shieldHealth > 0) || (amount < 0 && hullHealth == hullMaxHealth):
		update_shield = true

	if update_shield:
		var pre_shield = self.shieldHealth
		self.shieldHealth -= amount
		if shieldHealth > pre_shield:
			Effects.emit_signal("ChargeShield", true)
	else:
		self.hullHealth -= amount
	
	# TODO: Play animations/explosions, random loot drop chances, pay-out bounties to player if a Pirate/Vampire
	if hullHealth <= 0:
		emit_signal("removed", self)
		call_deferred("queue_free")

func _set_team() -> void:
	match actor_team:
		Team.FRIENDLY:
			team_group = "friendly"
		Team.PIRATE:
			team_group = "pirate"
		Team.VAMPIRE:
			team_group = "vampire"
		_:
			printerr("Unknown Team for Actor ", self)

func _init_collision() -> void:
	if actor_team == Team.PIRATE || Team.VAMPIRE:
		hit_box.set_collision_layer_bit(2, true)
		
func _on_HitBox_area_entered(area):
	var hitParent = area.get_parent()	
	if hitParent.is_in_group("projectile"):
		if !hitParent.owner_ref.team_group == team_group:
			take_damage(hitParent.Damage)
			Effects.show_dmg_text(hitParent.global_position, hitParent.Damage)
			hitParent.hit_something()
	pass
