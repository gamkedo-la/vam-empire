extends Node2D

#only increment the player's attraction if they're in the encounter's area.

onready var MiningPirate = preload("res://Enemies/Scenes/MiningPirate.tscn")
export(int, 1, 1000) var spawn_pirate_thresh = 2

# Enemy Attraction when mining
var in_mining_pirate_encounter_area:bool = false
var enemy_attraction:int = 0

func _on_Area2D_body_entered(body):
	in_mining_pirate_encounter_area = true

func _on_Area2D_body_exited(body):
	in_mining_pirate_encounter_area = false

func _try_increase_attraction():
	if in_mining_pirate_encounter_area:
		print(enemy_attraction)
		enemy_attraction += 1
		if enemy_attraction > spawn_pirate_thresh:
			var new_pirate = MiningPirate.instance()
			add_child(new_pirate)
			if PlayerVars.player_node:
				new_pirate.global_position = PlayerVars.player_node.global_position+Vector2(400,0)
			enemy_attraction = 0
