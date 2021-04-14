extends Node
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

var target = null

func _ready():
	pass # Replace with function body.

func new(name: String):
	player = player_defaults.duplicate()
	player.name = name
	save()

func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(player))
	file.close()
	
func load_save():
	var file = File.new()	
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			# Does the save file have all of the 'high level' dictionaries/keys i.e. Sound, Graphics, Difficulty?
			if data.has_all(player_defaults.keys()):
				for key in player_defaults.keys():
					# Is this key a nested dictionary? i.e Sound, Graphics, Difficulty
					if typeof(player_defaults[key]) == TYPE_DICTIONARY:
						if !data.has_all(player_defaults[key].keys()):
							for subkey in player_defaults[key].keys():
								# If the Save File was missing any sub-keys, i.e. UserSettings.sound.music_volume, replace 
								# that single setting with the user_default to avoid regenerating the entire config file from scratch
								if !data[key].has(subkey):
									print_debug("Setting [", subkey,"] from System Defaults.")
									data[key][subkey] = player_defaults[key][subkey]
					else:
						if !data.has(key):
							print_debug("Setting [", key,"] from System Defaults.")							
							data[key] = key

				player = data
				save()
				return true
		else:
			printerr("Corrupted [Player Save] Save Data!")			
	else:
		printerr("No saved [Player Save] data to load")
	# No save data, version didn't match, or corrupted save file all lead to making a new() config file
	return false



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
