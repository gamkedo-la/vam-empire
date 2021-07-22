extends Node2D
class_name Ship

enum hpClass {SMALL, MEDIUM, LARGE, XLARGE}
export (String) var ship_name
export (int, 0, 3200) var ACCELERATION = 150
export (int, 0, 10000) var MAX_SPEED = 320
export (int, 0, 200) var FRICTION = 0
export (int, 0, 100000) var MASS = 100
export (float, 0.1, 300) var ROT_SPEED = 0.035
export (float, 0.1, 10) var ROT_ACCEL = 0.05

export (float, 0, 40000) var shieldHealth = 200
export (float, 0, 60000) var hullHealth = 250
export (float, 0, 15000) var energyReserve = 100
export (float, 0, 1500) var energyRecoverPerS = 60
export (float, 0, 5) var energyRecoveryDelayS = 0.5

export (Array, hpClass) var hardpoint_size
export (Array, int) var equipped_weapon_index

onready var ship_sprite = $ShipSprite

onready var hardpoints = $Hardpoints

onready var thrusters = $Thrusters
var rcs_thrusters

var weapons = []
var thrust_length = 0.0

var owner_ref = null
onready var explosion = preload("res://VFX/explosion_unlit.tscn")
onready var expl_sfx = preload("res://Sounds/Explosions/ship_explosion.tscn")
func _ready():
	if hardpoints.get_child_count() > 0:
		for HPoint in hardpoints.get_children():
			var HPidx = HPoint.get_index()
			var weapon = Global.weapon_hangar[hardpoint_size[HPidx]][equipped_weapon_index[HPidx]].duplicate(true)
			#print(weapon[0], HPoint)
		
			equip_weapon(weapon[0].duplicate(), HPoint)
	for T in thrusters.get_children():
		var thrust_exhaust = T.get_node_or_null("ParticleEffect")
		thrust_exhaust.emitting = true
	rcs_thrusters = self.get_node_or_null("RCSThrusters")
	
func set_owner(ref) -> void:
	owner_ref = ref

func equip_weapon(ordnance: Weapon, mount: Position2D):
	#print_debug(ordnance.name)
	#var newWeapon = ordnance.instance()
	#Global.reparent(ordnance, mount)	
	mount.add_child(ordnance)
	#print_debug("Mount children count: ", mount.get_child_count())
	ordnance.global_position = mount.global_position
	weapons.append(ordnance)
	if owner_ref:
		ordnance.set_owner(owner_ref)
	
func fire_weapons(parent_velocity: Vector2):
	var _fired = false
	for weapon in weapons:
		_fired = weapon.fire(parent_velocity)
		# TODO: add conditional checking and remove weapons that don't fire for efficiency

func fire_bomb():
	for weapon in weapons:
		if weapon.weap_type == weapon.WeaponType.BOMB:
			weapon.fire_bomb()
		
func fire_mining_lasers():
	for weapon in weapons:
		if weapon.weap_type == weapon.WeaponType.MINING_LASER:
			weapon.fire_mining_laser()

func release_mining_lasers():
	for weapon in weapons:
		if weapon.weap_type == weapon.WeaponType.MINING_LASER:
			weapon.release_mining_laser()
		
func animate_thrusters(t_vec) -> void:
	for T in thrusters.get_children():
		var thrust_light = T.get_node_or_null("LightEffect")		
		var thrust_exhaust = T.get_node_or_null("ParticleEffect")		
		var thruster_effect = T.get_node_or_null("ThrusterEffect")		
		thrust_light.set_energy(t_vec.length()* 10)
		thrust_exhaust.initial_velocity = t_vec.length()*100
		#print_debug(t_vec.length())
		if t_vec.length() > 0:
			thrust_length += 0.02
			if thrust_length > 1:
				thrust_length = 1
		else:
			thrust_length -= 0.0185
			if thrust_length < 0:
				thrust_length = 0
		if thruster_effect:
			thruster_effect.scale.x = thrust_length
	
	pass

func animate_rcs(thrust: float) -> void:
	if rcs_thrusters:		
		rcs_thrusters.do_break(thrust)

func rotate_rcs(thrust: float):
	if rcs_thrusters:
		if thrust > 0.1:
			rcs_thrusters.bank_right(thrust)
	#		rcs_thrusters.bank_left(0)
		elif thrust < -0.1:
	#		rcs_thrusters.bank_right(0)
			rcs_thrusters.bank_left(-thrust)
		else:
			rcs_thrusters.bank_right(0)
			rcs_thrusters.bank_left(0)

func get_sprite() -> StreamTexture:
	return ship_sprite.texture

func self_destruct() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var x = 25
	while x > 0:
#		print_debug("Looping ", x, " times")
		yield(get_tree().create_timer(0.4), "timeout")
		var exploder = explosion.instance()
		var exp_sfx = expl_sfx.instance()
		add_child(exploder)
		add_child(exp_sfx)

		var rndVec = Vector2(rng.randf_range(-5,5), rng.randf_range(-5,5))
		self.rotation_degrees += rng.randi_range(-5,5)
		self.position += rndVec
		exploder.global_position = global_position + rndVec
#		expl_sfx.play()
		x -= 1
		
		
	self.call_deferred("queue_free")
		
