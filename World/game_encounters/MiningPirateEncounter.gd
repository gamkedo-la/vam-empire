extends Node2D

onready var MiningPirate = preload("res://Enemies/Scenes/MiningPirate.tscn")
export(int, 1, 1000) var spawn_pirate_thresh = 10

func _ready():
	PlayerVars.connect("attraction_changed", self, "_check_attraction")

func _check_attraction(attraction:int):
	if attraction > spawn_pirate_thresh:
		var new_pirate = MiningPirate.instance()
		add_child(new_pirate)
		if PlayerVars.player_node:
			new_pirate.global_position = PlayerVars.player_node.global_position+Vector2(100,0)
		PlayerVars.enemy_attraction = 0
