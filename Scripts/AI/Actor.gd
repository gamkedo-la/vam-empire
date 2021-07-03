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
export (String) var mission_string = ""
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
export var active_targetind = preload("res://AI/Scenes/ActiveTargetIndicator.tscn")

var indicator_active: bool = false

var explosion = preload("res://VFX/explosion_unlit.tscn")
onready var ship_node = $PilotedShip
onready var minimap_sprite = $Sprite
onready var death_timer = Timer.new()

# Movement constants
const m_s_up = Vector2.ZERO
const m_s_sos = false
const m_s_maxsli = 4
const m_s_fma = 0.785398

var velocity: Vector2 = Vector2.ZERO

var piloted_ship = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_timer.wait_time = 1
	death_timer.connect("timeout", self, "_remove_self")
	add_child(death_timer)
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
	if not PlayerVars.is_connected("target_active", self, "_check_if_active_target"):
		assert(PlayerVars.connect("target_active", self, "_check_if_active_target") == OK)
	PlayerVars.emit_signal("check_target", actor_team, mission_string, self)

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
		Effects.show_player_shield_dmg_text(global_position, amount)
		if shieldHealth > pre_shield:
			Effects.emit_signal("ChargeShield", true)
	else:
		self.hullHealth -= amount
		Effects.show_player_hp_dmg_text(global_position, amount)
	
	# TODO: Play animations/explosions, random loot drop chances, pay-out bounties to player if a Pirate/Vampire
	if hullHealth <= 0:
		_death()

func _death() -> void:
		var exploder = explosion.instance()
		get_tree().get_root().add_child(exploder)
		exploder.global_position = global_position
		_disable()
		death_timer.start()
		PlayerVars.emit_signal("actor_killed", actor_team, mission_string)

func _disable() -> void:
#	print_debug("Enemy ", self, " is disabled now.")
	hit_box.disconnect("area_entered", self, "_on_HitBox_area_entered")
	emit_signal("removed", self)
	ai.set_state(2)
	self.visible = false

func _remove_self() -> void:	
#	print_debug("Enemy ", self, " being destroyed now.")
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
			hitParent.hit_something()
	pass

func _check_if_active_target(_actor:Actor) -> void:
	if _actor == self && !indicator_active:
		
		var newIndicator = active_targetind.instance()
		call_deferred("add_child", newIndicator)
		indicator_active = true
		
