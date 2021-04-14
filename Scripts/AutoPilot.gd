extends KinematicBody2D
signal removed
# The start of a very basic ship AI with a base goal to create friendly ships just 'moving around' to add some life to things


onready var ship_node = $PilotedShip
onready var minimap_sprite = $Sprite

var piloted_ship = null
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var randClass = rng.randi_range(0,3)
	var randShip = rng.randi_range(0,1)
	var ship_to_pilot = Global.ship_hangar[randClass][randShip].duplicate()[0]
	print_debug("ship_to_pilot: ", ship_to_pilot)
	pilot_ship_from_pack(ship_to_pilot.duplicate(true))
	var ship_sprite = piloted_ship.get_node_or_null("ShipSprite")
	if ship_sprite:
		minimap_sprite.texture = ship_sprite.texture
	pass # Replace with function body.

func _process(_delta):
	pass



func pilot_ship_from_pack(ship):
	var hull_colliders =  self.get_tree().get_nodes_in_group("HullCollider")
	if piloted_ship:
		piloted_ship.queue_free()
	if hull_colliders:
		for Collider in hull_colliders:
			Collider.queue_free()	
	piloted_ship = ship
	#Global.reparent(piloted_ship, ship_node)
	ship_node.add_child(piloted_ship)	
	# TODO: Retool this to load multiple Hull Colliders from Ship	
	Global.reparent(piloted_ship.get_node_or_null("HullCollision"), self)	

