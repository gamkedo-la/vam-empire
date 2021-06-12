tool
extends Node2D
class_name Weapon

export(String) var weap_name

#export (AudioStreamRandomPitch) var sfxFire

enum hpClass {SMALL, MEDIUM, LARGE, XLARGE}
export (hpClass) var size

enum WeaponType {
	PHYS_PROJECTILE,
	ENERGY_PROJECTILE,
	LASER,
	MINING_LASER,
	MINING_DRILL,
	DRONE_BAY,
	 }
enum ProjectileSounds {
	PROJECTILE_01,
	PROJECTILE_02,
	PROJECTILE_03,
	PROJECTILE_04,
	PROJECTILE_05,
	RANDOM
}
var ProjSoundFiles = [
	"res://Sounds/Weapon/Projectile_Firing_SFX_01.wav",
	"res://Sounds/Weapon/Projectile_Firing_SFX_02.wav",
	"res://Sounds/Weapon/Projectile_Firing_SFX_03.wav",
	"res://Sounds/Weapon/Projectile_Firing_SFX_04.wav",
	"res://Sounds/Weapon/Projectile_Firing_SFX_05.wav"
]

enum BeamSounds {
	BEAM_01,
	BEAM_02,
	BEAM_03,
	BEAM_04,
	RANDOM
}

var weap_type: int
enum MountTypes {
	FIXED,
	GIMBALED
}
export (MountTypes) var mount

var projectile: PackedScene
var projectile_sound: int
var use_constant_projectile_speed: bool
var constant_projectile_speed: float

var beam: PackedScene
var beam_sound: int

var fire_rate = 50 setget set_fire_rate, get_fire_rate
onready var root_node = get_tree().get_root()

var sfxFire: AudioStreamRandomPitch = null

onready var weapon_sprite = $WeaponAnchor/WeaponSprite
var muzzle_flash = null
onready var anchor = $WeaponAnchor
var barrel_tip = null
var mining_beam

var rng = RandomNumberGenerator.new()
var fire_timer
var primed = true
var weap_sound = null

var owner_ref = null

func _init():	
	property_list_changed_notify()


func _ready():
	
	# Don't run this code /in editor/, since we're using Tool Mode for our Weapon Class to make setting these up easier
	# Other scenes are 'safe' because they are called in game from Ship.gd
	if not Engine.editor_hint:
	# Import the anchor and barrel tip Position2D objects actual "nodes" from the NodePath added in the editor so they can be used	
		muzzle_flash = get_node_or_null("WeaponAnchor/WeaponSprite/BarrelTip/MuzzleFlash")
		barrel_tip = get_node_or_null("WeaponAnchor/WeaponSprite/BarrelTip")
		weap_sound = get_node_or_null("WeaponSound")
		fire_timer = Timer.new()
		add_child(fire_timer)
		fire_timer.autostart = true
		fire_timer.wait_time = 100/fire_rate
		fire_timer.connect("timeout", self, "_reprime")	
		sfxFire = AudioStreamRandomPitch.new()
		sfxFire.audio_stream = load(ProjSoundFiles[projectile_sound])
		sfxFire.random_pitch = 1.1
		if weap_sound:		
			weap_sound.stream = sfxFire
	
func set_owner(ref) -> void:
	owner_ref = ref
	
func fire(parent_velocity: Vector2):
	if primed:
		# TODO: Add more variety here that will come from the weapon characteristics that can be set in editor
		# TODO: Improve the entire process of 'firing' projectiles to feel better and look better in game
		match weap_type:
			WeaponType.PHYS_PROJECTILE:
				_fire_projectile(parent_velocity)
				if muzzle_flash:
					muzzle_flash.on()
				return true
			WeaponType.ENERGY_PROJECTILE:
				_fire_projectile(parent_velocity)
				if muzzle_flash:
					muzzle_flash.on()
				return true
			WeaponType.LASER:
				_fire_laser(parent_velocity)
				if muzzle_flash:
					muzzle_flash.on()
				return true
			_:
				# Tell the ship to stop trying to fire this weapon
				return false 

func fire_mining_laser():
	if !Global.hold_fire:
		mining_beam = beam.instance()
		root_node.add_child(mining_beam)
	
	if mining_beam:
		mining_beam.global_position = barrel_tip.global_position
		mining_beam.global_rotation = barrel_tip.global_rotation + PI/2	
	
func release_mining_laser():
	#print("Releasing mining laser")
	if mining_beam:
		mining_beam.free_laser_beam()
	
func set_fire_rate(val):
	fire_rate = val
	if fire_timer:
		fire_timer.wait_time = 100/fire_rate

func get_fire_rate():
	return fire_rate

func _fire_projectile(parent_velocity: Vector2) -> void:	
	var proj = projectile.instance()
	root_node.add_child(proj)
	proj.global_position = barrel_tip.global_position
	proj.global_rotation = barrel_tip.global_rotation	
	var dir = Vector2(1, 0).rotated(barrel_tip.global_rotation)
	var impulse = rng.randf_range(0.8, 2.0) * clamp(parent_velocity.length()/100, 1, 5)
	if (use_constant_projectile_speed):
		impulse = constant_projectile_speed

	proj.linear_velocity = parent_velocity
	proj.launchBullet(impulse, dir, owner_ref)
	primed = false	
	if weap_sound:		
		weap_sound.play(0.1)
	fire_timer.start()
	

func _fire_laser(parent_velocity):
	pass

func _reprime():	
	primed = true





# Custom Editor Behavior:
# To make setup of a new weapon easier on designers!

func _get(property): # overridden
	if property == "weapon/weap_type":
		return weap_type
	if property == "weapon/projectile":
		return projectile
	if property == "weapon/projectile_sound":
		return projectile_sound
	if property == "weapon/use_constant_projectile_speed":
		return use_constant_projectile_speed
	if property == "weapon/constant_projectile_speed":
		return constant_projectile_speed
	if property == "weapon/beam":
		return beam
	if property == "weapon/beam_sound":
		return beam_sound
	if property == "weapon/fire_rate":
		return fire_rate

func _set(property, value): # overridden
	if property == "weapon/weap_type":
		weap_type = value
		property_list_changed_notify()
	if property == "weapon/projectile":
		projectile = value
	if property == "weapon/projectile_sound":
		projectile_sound = value
	if property == "weapon/use_constant_projectile_speed":
		use_constant_projectile_speed = value
		property_list_changed_notify()
	if property == "weapon/constant_projectile_speed":
		constant_projectile_speed = value
	if property == "weapon/beam":
		beam = value
	if property == "weapon/beam_sound":
		beam_sound = value
	if property == "weapon/fire_rate":
		fire_rate = value
	return true


#
#	PHYS_PROJECTILE,
#	ENERGY_PROJECTILE,
#	LASER,
#	MINING_LASER,
#	MINING_DRILL,
#	DRONE_BAY
# call once when node selected. Added to ordinary export
func _get_property_list():	# overridden function
	var property_list = []
	# List the weapon type choice no matter what. This is the 'primary driver and must be listed this way.
	# As an "export", weap_type can't trigger the property_list_change_notify(), that I have found yet! It would be nice if it *could*.
	property_list.append({"name": "weapon/weap_type","type": 2,"hint": 3,
	"hint_string": "Phys_Projectile:0,Energy_Projectile:1,Laser:2,Mining_Laser:3,Mining_Drill:4,Drone_Bay:5","usage": 8199,})
	
	# Projectile only features
	if weap_type == WeaponType.PHYS_PROJECTILE || weap_type == WeaponType.ENERGY_PROJECTILE:
		property_list.append({"name": "weapon/projectile","type": 17,"usage": 8199,"hint": 17,"hint_string": "PackedScene",})
		property_list.append({"name":"weapon/projectile_sound","hint":3,
		"hint_string":"Projectile 01:0,Projectile 02:1,Projectile 03:2,Projectile 04:3,Projectile 05:4,Random:5","type":2,"usage":8199,})
		property_list.append({"name": "weapon/use_constant_projectile_speed", "type": 1, "usage": 8199, "hint": 0})
		if use_constant_projectile_speed:
			property_list.append({"name": "weapon/constant_projectile_speed", "type": 3, "usage": 8199})

	# Laser only features
	if weap_type == WeaponType.LASER || weap_type == WeaponType.MINING_LASER:
		property_list.append({"name": "weapon/beam","type": 17,"usage": 8199,"hint": 17,"hint_string": "PackedScene",})
		
	# Features common to Phys/Eneryg Proj and Lasers
	if weap_type == WeaponType.PHYS_PROJECTILE || weap_type == WeaponType.ENERGY_PROJECTILE || weap_type == WeaponType.LASER || weap_type == WeaponType.MINING_LASER:
		property_list.append({"name":"weapon/fire_rate","hint":1,"hint_string":"50,10000", "type":3, "usage":8199,})
		property_list.append({"name":"weapon/beam_sound","hint":3,
		"hint_string":"Beam 01:0,Beam 02:1,Beam 03:2,Beam 04:3,Beam 05:4,Random:5","type":2,"usage":8199,})
	return property_list
