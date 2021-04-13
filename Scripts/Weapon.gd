extends Node2D

export(String) var weap_name

enum hpClass {SMALL, MEDIUM, LARGE, XLARGE}
export (hpClass) var size

enum WeapTypes {
	PHYS_PROJECTILE,
	ENERGY_PROJECTILE,
	LASER,
	MINING_LASER,
	MINING_DRILL,
	DRONE_BAY,
	 }
export (WeapTypes) var type
enum MountTypes {
	FIXED,
	GIMBALED
}
export (MountTypes) var mount

export(PackedScene) var projectile
export(PackedScene) var beam

export (NodePath) var anchor_path
export (NodePath) var barrel_tip_path

onready var root_node = get_tree().get_root()

var anchor
var barrel_tip

var rng = RandomNumberGenerator.new()

func _ready():
	# Import the anchor and barrel tip Position2D objects actual "nodes" from the NodePath added in the editor so they can be used
	print_debug("Getting here")
	anchor = get_node(anchor_path)
	barrel_tip = get_node(barrel_tip_path)
	
	
func fire(parent_velocity):
	# TODO: Add more variety here that will come from the weapon characteristics that can be set in editor
	# TODO: Improve the entire process of 'firing' projectiles to feel better and look better in game
	match type:
		WeapTypes.PHYS_PROJECTILE:
			_fire_projectile(parent_velocity)
			return true
		WeapTypes.ENERGY_PROJECTILE:
			_fire_projectile(parent_velocity)
			return true
		WeapTypes.LASER:
			_fire_laser(parent_velocity)
			return true
		_:
			# Tell the ship to stop trying to fire this weapon
			return false 
		

func _fire_projectile(parent_velocity):
	var rnd_impulse = rng.randf_range(0.8, 2.0)
	var proj = projectile.instance()
	root_node.add_child(proj)
	proj.global_position = barrel_tip.global_position
	proj.global_rotation = barrel_tip.global_rotation	
	var dir = Vector2(1, 0).rotated(barrel_tip.global_rotation)
	rnd_impulse = rng.randf_range(0.8, 2.0) * clamp(parent_velocity.length()/100, 1, 5)
	proj.linear_velocity = parent_velocity
	proj.launchBullet(rnd_impulse, dir)

func _fire_laser(parent_velocity):
	pass
