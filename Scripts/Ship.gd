extends Node2D

enum hpClass {SMALL, MEDIUM, LARGE, XLARGE}
export (String) var ship_name
export (int, 0, 3200) var ACCELERATION = 150
export (int, 0, 10000) var MAX_SPEED = 320
export (int, 0, 200) var FRICTION = 0
export (int, 0, 4000) var MASS = 100
export var ROT_SPEED = deg2rad(2)
export var ROT_ACCEL = deg2rad(0)

export (float, 0, 400) var shieldHealth = 200
export (float, 0, 600) var hullHealth = 250
export (float, 0, 150) var energyReserve = 100

export (Array, hpClass) var hardpoint_size
export (Array, int) var equipped_weapon_index

onready var hardpoints = $Hardpoints

onready var thrusters = $Thrusters

var weapons = []

func _ready():
	for HPoint in hardpoints.get_children():
		var HPidx = HPoint.get_index()
		var weapon = Global.weapon_hangar[hardpoint_size[HPidx]][equipped_weapon_index[HPidx]].duplicate(true)
		#print(weapon[0], HPoint)
		
		equip_weapon(weapon[0].duplicate(), HPoint)
	for T in thrusters.get_children():
		var thrust_exhaust = T.get_node_or_null("ParticleEffect")
		thrust_exhaust.emitting = true
	

func equip_weapon(ordnance, mount):
	print(ordnance.name)
	#var newWeapon = ordnance.instance()
	#Global.reparent(ordnance, mount)	
	mount.add_child(ordnance)
	print("Mount children count: ", mount.get_child_count())
	ordnance.global_position = mount.global_position
	weapons.append(ordnance)
	
func fire_weapons(parent_velocity):
	var fired = false
	for weapon in weapons:
		fired = weapon.fire(parent_velocity)
		# TODO: add conditional checking and remove weapons that don't fire for efficiency
		
func fire_mining_lasers():
	for weapon in weapons:
		if weapon.type == weapon.WeapTypes.MINING_LASER:
			weapon.fire_mining_laser()

func release_mining_lasers():
	for weapon in weapons:
		if weapon.type == weapon.WeapTypes.MINING_LASER:
			weapon.release_mining_laser()
		
func animate_thrusters(t_vec):
	for T in thrusters.get_children():
		var thrust_light = T.get_node_or_null("LightEffect")		
		var thrust_exhaust = T.get_node_or_null("ParticleEffect")		
		thrust_light.set_energy(t_vec.length()* 10)
		thrust_exhaust.initial_velocity = t_vec.length()*100
	
	pass


