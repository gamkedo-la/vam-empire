extends KinematicBody2D
signal removed
onready var ai = $AI

# Variables that should come from piloted ship
var rotation_speed = 0.01

export var ship_file = preload("res://Ships/Templates/M_Destroyers/DestroyerTemplate01.tscn")
onready var ship_node = $PilotedShip
onready var minimap_sprite = $Sprite

var piloted_ship = null
# Called when the node enters the scene tree for the first time.
func _ready():

	pilot_ship_from_file(ship_file)
	var ship_sprite = piloted_ship.get_node_or_null("ShipSprite")
	if ship_sprite:
		minimap_sprite.texture = ship_sprite.texture
	ai.initialize(self, piloted_ship)

func _process(_delta):
	pass

func pilot_ship_from_file(ship):
	piloted_ship = ship.instance()
	ship_node.add_child(piloted_ship)	
	var hull = piloted_ship.get_node_or_null("HullCollision")
	Global.reparent(hull, self)

func rotate_toward(location: Vector2):
	rotation = lerp_angle(rotation, global_position.direction_to(location).angle(), rotation_speed)
	
