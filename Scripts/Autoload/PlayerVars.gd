extends Node

signal target_change

# File saving/loading methodology adapted from https://gdscript.com/solutions/how-to-save-and-load-godot-game-data/
var FILE_NAME  = "user://game-data.json"

var player_node = null

# For instantiating a new player file
var player_defaults = {
	"name": " ",
	"cash": 10000,
	"current_ship": "res://Ships/StarterShip.tscn"	
}

var player = player_defaults

var ship_inventory = {}

var target = null setget set_target, get_target

func _ready():
	pass # Replace with function body.

func set_target(val):
	target = val
	emit_signal("target_change", target)

func get_target():
	return target

func new(name: String):
	player = player_defaults.duplicate()
	player.name = name
	save()

func save():
	var file = File.new()
	var save = {}
	save["player"] = player
	save["ship_inventory"] = ship_inventory
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(save))
	file.close()
	
func load_save():
	var file = File.new()	
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			# Temporary to upconvert 'player' only saves
			if data.has_all(player_defaults.keys()):
				var temp_data = {}
				temp_data["player"] = data.duplicate(true)
				temp_data["ship_inventory"] = {}
				data.clear()
				data = temp_data.duplicate()
			# Does the save file have all of the 'high level' dictionaries/keys i.e. Sound, Graphics, Difficulty?
			if data.player.has_all(player_defaults.keys()):
				for key in player_defaults.keys():
					# Is this key a nested dictionary? i.e Sound, Graphics, Difficulty
					if typeof(player_defaults[key]) == TYPE_DICTIONARY:
						if !data.player.has_all(player_defaults[key].keys()):
							for subkey in player_defaults[key].keys():
								# If the Save File was missing any sub-keys, i.e. UserSettings.sound.music_volume, replace 
								# that single setting with the user_default to avoid regenerating the entire config file from scratch
								if !data.player[key].has(subkey):
									print_debug("Setting [", subkey,"] from System Defaults.")
									data.player[key][subkey] = player_defaults[key][subkey]
					else:
						if !data.player.has(key):
							print_debug("Setting [", key,"] from System Defaults.")							
							data.player[key] = key

				player = data.player
				ship_inventory = data.ship_inventory
				save()
				return true
		else:
			printerr("Corrupted [Player Save] Save Data!")			
	else:
		printerr("No saved [Player Save] data to load")
	# No save data, version didn't match, or corrupted save file all lead to making a new() config file
	return false

func pickup_item(uuid):
	var inventory = player_node.get_ship_inventory()
	inventory.insert_item(uuid)

func increment_ship_inventory(uuid, cnt:int):
	if ship_inventory.has(uuid):
		ship_inventory[uuid] += cnt		
	else:
		ship_inventory[uuid] = cnt
	#print_debug("PlayerVars.ship_inventory: ", ship_inventory)

func clear_ship_inventory():
	ship_inventory.clear()

func old_load_save():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			player = data
		else:
			printerr("Corrupted Player Save Data!")
	else:
		printerr("No saved data to load")

func save_exists():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		return true
	else:
		return false

