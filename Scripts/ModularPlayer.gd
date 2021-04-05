extends KinematicBody2D

# Script to replace Player.gd 
# The player and the ship will be 2 separte scenes combined modularly

# Node to mount an instanced ship scene
onready var ship_node = $PilotedShip
var hull_hitbox = null
var piloted_ship = null


func _ready():
	var ship_load = load(PlayerVars.player.current_ship)
	piloted_ship = ship_load.instance()
	ship_node.add_child(piloted_ship)
	hull_hitbox = piloted_ship.get_node_or_null("HullCollision")
	piloted_ship.remove_child(hull_hitbox)
	self.add_child(hull_hitbox)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
