extends KinematicBody2D


export (int, 0, 3200) var ACCELERATION = 150
export (int, 0, 1000) var MAX_SPEED = 320
export (int, 0, 200) var FRICTION = 0
export (int, 0, 200) var MASS = 100
export var ROT_SPEED = deg2rad(2)
var ROT_ACCEL = deg2rad(0)

export (float, 0, 400) var shieldHealth = 200
export (float, 0, 600) var hullHealth = 250
export (float, 0, 150) var energyReserve = 100
export (float, 0, 600) var healingEnergy = 250
export (float, 0, 10)  var healingEnergyRecoveryPerTimeUnit = 5

var shieldMaxHealth = null
var hullMaxHealth = null
var energyMax = null
var healingMaxEnergy = null

var healingBot = null
# Default variables for move_and_slide
const m_s_up = Vector2.ZERO
const m_s_sos = false
const m_s_maxsli = 4
const m_s_fma = 0.785398


enum {
	MOVE,
	ROLL,
	ATTACK, 
	HEAL
}

var state = MOVE
var velocity = Vector2.ZERO
var strafe_velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
var rng = RandomNumberGenerator.new()

var player_target = null

onready var base_bullet = preload("res://Bullets/Scenes/BasicBullet.tscn")
onready var left_gun = $LeftGunPos
onready var right_gun = $RightGunPos
onready var thrust_light = $Sprite/RearLightAmber
onready var thrust_exhaust = $Sprite/RearLightAmber/Particles2D

onready var debug_select = $DebugDraw


func _ready():
	rng.randomize()
	shieldMaxHealth = shieldHealth
	hullMaxHealth = hullHealth
	energyMax = energyReserve
	healingMaxEnergy = healingEnergy
	healingBot = get_node("HealingBot")
	healingBot.visible = false

func _process(delta):
	#print(shieldMaxHealth)
	if(Input.is_key_pressed(KEY_H)):
		state = HEAL
		heal_ship()
	else:
		state = MOVE
		healingBot.visible = false
		
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)	
	
func _physics_process(delta):
	var targ = player_target
	if !player_target:
		targ = get_global_mouse_position()
		debug_select.visible = false
	else:
		targ = player_target.global_position
		
		debug_select.global_transform = player_target.global_transform
		debug_select.visible = true

	rotate_to_target(targ)

func move_state(delta):
	var thrust_vector = Vector2.ZERO
	var strafe_vector = Vector2.ZERO
	
	var look_vec = get_global_mouse_position() - global_position	
	
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
		
	thrust_light.set_energy(thrust_vector.length()* 10)	
	#thrust_exhaust.set_amout(thrust_vector.length() + 100)
	thrust_exhaust.initial_velocity = thrust_vector.length()*100
	
	move()
	strafe()
	
	if Input.is_action_pressed("attack"):
		#state = ATTACK
		#This code should be modularized and passed off to various 'weapons' that may be installed on the ship
		var bullet_l = base_bullet.instance()
		var bullet_r = base_bullet.instance()
		
		get_node("/root/World").add_child(bullet_l)
		get_node("/root/World").add_child(bullet_r)
		
		bullet_l.global_position = left_gun.global_position
		bullet_l.global_rotation = global_rotation
		bullet_r.global_position = right_gun.global_position
		bullet_r.global_rotation = global_rotation
		var dir = Vector2(1, 0).rotated(self.global_rotation)
		var rnd_impulse = rng.randf_range(0.8, 2.0)
		bullet_l.launchBullet(rnd_impulse, dir)
		rnd_impulse = rng.randf_range(0.8, 2.0)
		bullet_r.launchBullet(rnd_impulse, dir)

	elif Input.is_action_just_pressed("ui_esc"):
		# If no target, bring up main menu, otherwise get rid of target first
		if !player_target:
			Global._display_menu()			
		else:
			player_target = null
	
	
func attack_state(_delta):
	velocity = Vector2.ZERO
	
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
		print("You're Dead")
		

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
	
func heal_ship():
	if(healingEnergy > 0):
		healingBot.visible = true
		if(hullHealth < hullMaxHealth):
			hullHealth = min(hullHealth + 1, hullMaxHealth)
			healingEnergy-=1
		elif (shieldHealth < shieldMaxHealth):
			shieldHealth = min(shieldHealth + 1, shieldMaxHealth)
			healingEnergy-=1
	print("Heal: ", hullHealth)
	print("Shield: ", shieldHealth)

func _on_HealingTimer_timeout():
	if (state != HEAL && healingEnergy < healingMaxEnergy):
		healingEnergy+=healingEnergyRecoveryPerTimeUnit
		print("Heal Energy Recovery :", healingEnergy)
