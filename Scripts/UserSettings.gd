extends Node

var FILE_NAME = "user://user-settings.json"

var user_defaults = {
	sound = {
	"master_volume": .8,
	"music_volume": 1,
	"effects_volume": 1
	},
	ui = {
	"master_hud_opacity": 1,
	"HUD_opacity": 1,
	"mini_map_opacity": 1,
	"mini_map_grid_opacity": 1
	}
}

var current = user_defaults.duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	if save_exists():		
		load_save()
	else:
		new()
	
	pass # Replace with function body.

func new():
	print_debug("Loading Factory Default Settings")
	current.clear()
	current = user_defaults.duplicate()	
	save()

func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(current))
	file.close()

func load_save():
	var file = File.new()
	var build_new_config = false
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			# Does the save file have all of the 'high level' dictionaries/keys i.e. Sound, Graphics, Difficulty?
			if data.has_all(user_defaults.keys()):
				for key in user_defaults.keys():
					# Is this key a nested dictionary? i.e Sound, Graphics, Difficulty
					if typeof(user_defaults[key]) == TYPE_DICTIONARY:
						if !data.has_all(user_defaults[key].keys()):
							for subkey in user_defaults[key].keys():
								# If the Save File was missing any sub-keys, i.e. UserSettings.sound.music_volume, replace 
								# that single setting with the user_default to avoid regenerating the entire config file from scratch
								if !data[key].has(subkey):
									print("Setting [", subkey,"] from System Defaults.")
									data[key][subkey] = user_defaults[key][subkey]
					else:
						if !data.has(key):
							print_debug("Setting [", key,"] from System Defaults.")							
							data[key] = key

				current = data
				save()
				return
		else:
			printerr("Corrupted Player Save Data!")			
	else:
		printerr("No saved data to load")
	# No save data, version didn't match, or corrupted save file all lead to making a new() config file
	new()

func save_exists():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		return true
	else:
		return false
