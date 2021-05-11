extends KinematicBody2D
class_name Player
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

onready var vector_grid = $PlayerUICanvas/VectorGrid/Grid
onready var vec_indicator = $PlayerUICanvas/VectorGrid/Grid/VecIndicator
onready var velo_indicator = $PlayerUICanvas/VectorGrid/Grid/VeloIndicator
onready var retro_indicator = $PlayerUICanvas/VectorGrid/Grid/RetroIndicator
onready var vel_label = $PlayerUICanvas/VectorGrid/Grid/VelLabel

# End of Original Player.gd variables

# Node to mount an instanced ship scene
onready var ship_node = $PilotedShip
var hardpoints = null
#var thrusters = null
var hull_hitbox = null
var piloted_ship = null

onready var energy_recovery_delay_timer = $EnergyRecoveryDelayTimer
var can_recover_energy = true

func _ready():
	#TODO: pilot_ship_from_pack and change variables in PlayerVars to ShipClass/Index 
	pilot_ship(PlayerVars.player.current_ship)	
	PlayerVars.player_node = self
	PlayerVars.connect("target_change", self, "_target_change")
	PlayerVars.connect("energy_reserve_changed", self, "_on_energy_reserve_changed")

	rng.randomize()

func _process(_delta):
	Global.player_position = position

func _physics_process(delta):
	var targ = PlayerVars.get_target()
	if !player_target:
		targ = get_global_mouse_position()		
	else:
		targ = player_target.global_position
	
	rotate_to_target(targ)

	# I don't love this... But it doesn't feel good to put a process funtion + timer in PlayerVars
	if (can_recover_energy):
		PlayerVars.energy_reserve += PlayerVars.energy_recovery_per_s * delta
	
	match state:
		MOVE:
			move_state(delta)

func move_state(delta):
	var thrust_vector = Vector2.ZERO
	var strafe_vector = Vector2.ZERO
	var retro_vector = Vector2.ZERO
	thrust_vector.x = Input.get_action_strength("ui_up") 
	strafe_vector.x = -Input.get_action_strength("ui_down")
	strafe_vector.y = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")	
	
	vec_indicator.rect_position.x = (strafe_vector.y * 50) + 50
	vec_indicator.rect_position.y = (strafe_vector.x * 50) + 50
	thrust_vector = thrust_vector.rotated(global_rotation)
	thrust_vector = thrust_vector.normalized()
	
	strafe_vector = strafe_vector.rotated(global_rotation)
	strafe_vector = strafe_vector.normalized() * .3
	
	thrust_vector += strafe_vector
#	retro_vector.x = velocity.x/MAX_SPEED
#	retro_vector.y = velocity.y/MAX_SPEED
#	retro_vector = retro_vector.rotated(PI)
	if velocity.length() > 1:
		retro_vector = velocity.rotated(PI)
	var retro_heading = retro_vector.rotated(-global_rotation)
	
	
	retro_vector = retro_vector.normalized()

	var fa_brake = retro_vector
	#experimentation
#	retro_vector = retro_vector.rotated(global_rotation)
#	retro_vector.x = -retro_vector.x
	if thrust_vector != Vector2.ZERO:		
		velocity = velocity.move_toward(thrust_vector * MAX_SPEED, ACCELERATION * delta)
	# Ship is facing with primary thruster 'retro', so we get the full force of braking power
	elif retro_heading.x/MAX_SPEED > 0:
		#velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)			
		fa_brake.y *= .3
		velocity = velocity.move_toward(fa_brake * MAX_SPEED, ACCELERATION * delta)
		#strafe_vector.x = -velocity.normalized().x
	# Use RCS Thrusters to slow down ship
	else:
		fa_brake *= .3
		velocity = velocity.move_toward(fa_brake * MAX_SPEED/3, ACCELERATION/3 * delta)
		
		
#	if strafe_vector == Vector2.ZERO:
#		strafe_vector = -velocity.normalized()
	

#	if strafe_vector != Vector2.ZERO:		
#		strafe_velocity = strafe_velocity.move_toward(strafe_vector * MAX_SPEED/3, ACCELERATION/1.5 * delta)
#	else:
#		strafe_velocity = strafe_velocity.move_toward(Vector2.ZERO, FRICTION * delta)		
#		pass
	#velocity += strafe_velocity
	piloted_ship.animate_thrusters(thrust_vector)
	if retro_heading.x/MAX_SPEED > 0.1:
		#print_debug("retro_heading:", retro_heading)
		piloted_ship.animate_thrusters(retro_heading.normalized())
	
	move()
#	strafe()
	
	var scaled_velo = Vector2.ZERO	
	scaled_velo.x = stepify(velocity.x/MAX_SPEED,0.01)
	scaled_velo.y = stepify(velocity.y/MAX_SPEED,0.01)
#	retro_vector.x = stepify(-velocity.x/MAX_SPEED,0.01)
#	retro_vector.y = stepify(-velocity.y/MAX_SPEED,0.01)
	vel_label.text = str("Vel: (",stepify(velocity.x,0.01),",",stepify(velocity.y,0.01),")"," Scaled: (",scaled_velo.x,",",scaled_velo.y,")")
	scaled_velo = scaled_velo.rotated(-global_rotation)
	retro_vector = retro_vector.rotated(-global_rotation).normalized()
	velo_indicator.rect_position.x = (scaled_velo.y * 50) + 50
	velo_indicator.rect_position.y = (-scaled_velo.x * 50) + 50
	retro_indicator.rect_position.x = (retro_vector.y * 50) + 50
	retro_indicator.rect_position.y = (-retro_vector.x * 50) + 50
	
	
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
			PlayerVars.take_damage(damage)

func strafe():
	strafe_velocity = move_and_slide(strafe_velocity)
	
func roll_animation_finished():
	state = MOVE
	velocity *= .75

func attack_animation_finished():
	state = MOVE

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

func take_damage(amount):
	# Passthrough to PlayerVars, maybe we'll add animation triggers here down the line
	PlayerVars.take_damage(amount)

func heal(amount, energy_cost):
	# Don't let player heal if not enough energy or full on shields
	if (PlayerVars.energy_reserve >= energy_cost && PlayerVars.shield_health < PlayerVars.shield_max_health):
		take_damage(-amount) # Woah man, a heal is just like, negative damage
		PlayerVars.energy_reserve -= energy_cost
	
	print("Heal: ", PlayerVars.hull_health)
	print("Shield: ", PlayerVars.shield_health)

func _on_energy_reserve_changed(_val, change_amount):
	if (change_amount < 0): 
		energy_recovery_delay_timer.start(PlayerVars.energy_recovery_delay_s)
		can_recover_energy = false

func _on_EnergyRecoveryDelayTimer_timeout():
	can_recover_energy = true

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
	
	# TODO: move setting char sheet variables to a PlayerVars.connect() signal hookup
	# order matters! need to set max_* values before regular values. the setters clamp the stat values by the max values
	PlayerVars.shield_max_health = piloted_ship.shieldHealth
	PlayerVars.shield_health = piloted_ship.shieldHealth
	char_sheet.add_sheetStat("Shield Health", piloted_ship.shieldHealth)
	PlayerVars.hull_max_health = piloted_ship.hullHealth
	PlayerVars.hull_health = piloted_ship.hullHealth
	char_sheet.add_sheetStat("Hull Health", piloted_ship.hullHealth)
	PlayerVars.energy_max_reserve = piloted_ship.energyReserve
	PlayerVars.energy_reserve = piloted_ship.energyReserve
	PlayerVars.energy_recovery_per_s = piloted_ship.energyRecoverPerS
	PlayerVars.energy_recovery_delay_s = piloted_ship.energyRecoveryDelayS
	char_sheet.add_sheetStat("Energy Reserve", piloted_ship.energyReserve)

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
