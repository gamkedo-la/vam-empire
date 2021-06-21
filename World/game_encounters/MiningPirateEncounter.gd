extends Node2D

#only increment the player's attraction if they're in the encounter's area.

onready var MiningPirate = preload("res://Enemies/Scenes/MiningPirate.tscn")
export(int, 1, 1000) var spawn_pirate_thresh = 10

func _ready():
	var _connect = PlayerVars.connect("attraction_changed", self, "_check_attraction")

func _check_attraction(attraction:int):
	print(attraction)
	if attraction > spawn_pirate_thresh:
		var new_pirate = MiningPirate.instance()
		add_child(new_pirate)
		if PlayerVars.player_node:
			new_pirate.global_position = PlayerVars.player_node.global_position+Vector2(400,0)
		PlayerVars.enemy_attraction = 0
	
func _on_Area2D_body_entered(body):
	PlayerVars.in_mining_pirate_encounter_area = true

func _on_Area2D_body_exited(body):
	PlayerVars.in_mining_pirate_encounter_area = false
