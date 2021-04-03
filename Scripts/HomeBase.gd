extends Node2D

#Script to manage the Home Base scene where the player can:
#	- Upgrade weapons and parts
#	- Purchase or Sell Ships
#	- Craft new weapons or parts with materials gathered while mining
#	- Manage the information they've discovered about the world (zones, V.A.M. etc...)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_GoMiningEasy_pressed():
	Global.goto_scene("res://World/game_zones/EasyZone_001.tscn")

func _on_GoWorldProto_pressed():
	Global.goto_scene("res://World_Proto.tscn")
	
