extends KinematicBody2D

# The player and the ship will be 2 separte scenes combined modularly

# Original Player.gd variables, some of which may break off into PlayerVars.gd (for easier global access) and some may
# break off to become part of the instanced Ships which will be 'equipped' or piloted by the Player.

# Loaded from Ship
var ACCELERATION = 0
var MAX_SPEED = 0
var FRICTION = 0
var MASS = 0
var ROT_SPEED = 0
var ROT_ACCEL = 0
var shieldHealth = 0
var hullHealth = 0
var energyReserve = 0
var shieldMaxHealth = null
var hullMaxHealth = null
var energyMax = null
var healingMaxEnergy = null

# HealBot Vars
var healingEnergy = 250
var healingEnergyRecoveryPerTimeUnit = 5



# Default variables for move_and_slide
const m_s_up = Vector2.ZERO
const m_s_sos = false
const m_s_maxsli = 4
const m_s_fma = 0.785398


enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var strafe_velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
var rng = RandomNumberGenerator.new()

var player_target = null

# Bullet will be modularized as part of the Hardpoint mounted weapons, for now we're just going to fire it off the hardpoints
onready var base_bullet = preload("res://Bullets/Scenes/BasicBullet.tscn")
#provisional
onready var mining_beam = preload("res://Bullets/Scenes/MiningLaserBeam.tscn")

onready var char_sheet = $PlayerUICanvas/CharacterSheet

onready var inventory = $PlayerUICanvas/Inventory

# End of Original Player.gd variables



# Node to mount an instanced ship scene
onready var ship_node = $PilotedShip
var hardpoints = null
#var thrusters = null
var hull_hitbox = null
var piloted_ship = null


func _ready():
	#TODO: pilot_ship_from_pack and change variables in PlayerVars to ShipClass/Index 
	pilot_ship(PlayerVars.player.current_ship)	
	PlayerVars.player_node = self
	PlayerVars.connect("target_change", self, "_target_change")
	rng.randomize()
	shieldMaxHealth = shieldHealth
	hullMaxHealth = hullHealth
	energyMax = energyReserve
	
	healingMaxEnergy = healingEnergy

	
func _physics_process(delta):
	var targ = PlayerVars.get_target()
	if !player_target:
		targ = get_global_mouse_position()		
	else:
		targ = player_target.global_position


	rotate_to_target(targ)
	
	match state:
		MOVE:
			move_state(delta)


func move_state(delta):
	var thrust_vector = Vector2.ZERO
	var strafe_vector = Vector2.ZERO
	
	thrust_vector.x = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	strafe_vector.y = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	thrust_vector = thrust_vector.rotated(global_rotation)
	thrust_vector = thrust_vector.normalized()
	strafe_vector = strafe_vector.rotated(global_rotation)
	strafe_vector = strafe_vector.normalized()

	
	if thrust_vector != Vector2.ZERO:		
		velocity = velocity.move_toward(thrust_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		#velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)	
		pass
		
	if strafe_vector != Vector2.ZERO:		
		strafe_velocity = strafe_velocity.move_toward(strafe_vector * MAX_SPEED/3, ACCELERATION/3 * delta)
	else:
		#strafe_velocity = strafe_velocity.move_toward(Vector2.ZERO, FRICTION * delta)	
		pass

	piloted_ship.animate_thrusters(thrust_vector)
	move()
	strafe()
	
	if Input.is_action_pressed("attack"):
		if !Global.hold_fire:
			fire_attached_weapons()
	
	if Input.is_action_pressed("mining"):
		fire_mining_lasers()
		Global.hold_fire = true
	elif Input.is_action_just_released("mining"):
		Global.hold_fire = false
		release_mining_lasers()
			
func move():
	velocity = move_and_slide(velocity, m_s_up, m_s_sos, m_s_maxsli, m_s_fma, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		#if collision.collider.get_parent().is_in_group("asteroids"):
		if collision.collider.is_in_group("asteroids"):
			collision.collider.apply_impulse(velocity, -collision.normal * (velocity * MASS))
			var damage = velocity.length()/20			
			take_damage(damage)

func strafe():
	strafe_velocity = move_and_slide(strafe_velocity)
	
func roll_animation_finished():
	state = MOVE
	velocity *= .75

func attack_animation_finished():
	state = MOVE

func take_damage(damage):
	if shieldHealth > 0:
		shieldHealth -= damage
	elif hullHealth > 0:
		hullHealth -= damage
	else:
		print_debug("You're Dead")
		

func rotate_to_target(target):

	if self.get_angle_to(target) > ROT_SPEED:
		self.rotation += ROT_SPEED + ROT_ACCEL
	else:
		self.rotation -= ROT_SPEED + ROT_ACCEL
		
	if abs(self.get_angle_to(target)) < ROT_SPEED * 1.1:
		self.look_at(target)
		ROT_ACCEL = deg2rad(0)
	else:
		ROT_ACCEL += deg2rad(.05)
	
func load_hardpoints():
	# Simplified until we have actual weapons to mount.  We'll just 'fire' from the hardpoint for now
	hardpoints = piloted_ship.get_node_or_null("Hardpoints")


func instantiate_ship_variables():
	ACCELERATION = piloted_ship.ACCELERATION
	char_sheet.add_sheetStat("Acceleration", ACCELERATION)
	MAX_SPEED = piloted_ship.MAX_SPEED
	char_sheet.add_sheetStat("Max Speed", MAX_SPEED)
	FRICTION = piloted_ship.FRICTION
	char_sheet.add_sheetStat("Friction", FRICTION)
	MASS = piloted_ship.MASS
	char_sheet.add_sheetStat("Mass", MASS) 
	ROT_SPEED = piloted_ship.ROT_SPEED
	char_sheet.add_sheetStat("Rotation Speed", ROT_SPEED)
	ROT_ACCEL = piloted_ship.ROT_ACCEL
	char_sheet.add_sheetStat("Rotation Acceleration", ROT_ACCEL)
	shieldHealth = piloted_ship.shieldHealth
	char_sheet.add_sheetStat("Shield Health", shieldHealth)
	hullHealth = piloted_ship.hullHealth
	char_sheet.add_sheetStat("Hull Health", hullHealth)
	energyReserve = piloted_ship.energyReserve
	char_sheet.add_sheetStat("Energy Reserve", energyReserve)
	
func pilot_ship_from_pack(ship):
	var hull_colliders =  self.get_tree().get_nodes_in_group("HullCollider")
	if piloted_ship:
		piloted_ship.queue_free()
	if hull_colliders:
		for Collider in hull_colliders:
			Collider.queue_free()	
	piloted_ship = ship
	ship_node.add_child(piloted_ship)	
	# TODO: Retool this to load multiple Hull Colliders from Ship	
	var hull = piloted_ship.get_node_or_null("HullCollision").duplicate()
	add_child(hull)
	#Global.reparent(piloted_ship.get_node_or_null("HullCollision"), self)	
	
	instantiate_ship_variables()



func pilot_ship(ship):		
	var ship_load = load(ship)
	piloted_ship = ship_load.instance()
	ship_node.add_child(piloted_ship)
	var test = piloted_ship.get_node_or_null("HullCollision")
	print_debug("TEST: ", test)
	Global.reparent(piloted_ship.get_node_or_null("HullCollision"), self)
	instantiate_ship_variables()
		

func fire_attached_weapons():
	piloted_ship.fire_weapons(velocity)
		
func fire_mining_lasers():
	piloted_ship.fire_mining_lasers()

func release_mining_lasers():
	piloted_ship.release_mining_lasers()
	
func _target_change(val):
	print("_target_change: ", val)
	if val:
		player_target = val
	else:
		player_target = null

func get_ship_inventory():
	return inventory
