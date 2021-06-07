extends Node

signal ui_refresh

var FILE_NAME = "user://user-settings.json"

var user_defaults = {
	sound = {
	"master_volume": .8,
	"music_volume": 1,
	"effects_volume": 1
	},
	ui = {	
	"master_hud_opacity": 1,
	"shipHUD_opacity": 1,	
	"mini_map_grid_opacity": 0.25,
	"mini_map_style": 0
	},
	difficulty = {
		"difficulty_level": 0
	},
	save = {
	"save_slots": 3,
	"current_slot": 1,
	"slot_1": "user://game-data.json",
	"slot_2": "user://game-data2.json",
	"slot_3": "user://game-data3.json"
	},
	system = {
		"show_context_steering": false
	}
}

var mini_map_textures = []

var current = user_defaults.duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	if save_exists():		
		load_save()
	else:
		new()	
	

func new():
	print_debug("Loading Factory Default [User Settings]")
	var temp_save
	if current.save:
		temp_save = current.save.duplicate(true)
	current.clear()	
	current = user_defaults.duplicate(true)
	if temp_save:
		current.save = temp_save
	save()

func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(JSON.print(current, "\t"))	
	file.close()

func load_save():
	var file = File.new()	
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
									print_debug("Setting [", subkey,"] from System Defaults.")
									data[key][subkey] = user_defaults[key][subkey]
					else:
						if !data.has(key):
							print_debug("Setting [", key,"] from System Defaults.")							
							data[key] = key

				current = data
				save()
				return
		else:
			printerr("Corrupted [User Settings] Save Data!")			
	else:
		printerr("No saved [User Settings] data to load")
	# No save data, version didn't match, or corrupted save file all lead to making a new() config file
	new()

func save_exists():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		return true
	else:
		return false

func set_current_slot(slot):
	current.save.current_slot = slot

func get_save_slot(slot_arg):
	var slot = int(slot_arg)
	if slot >= 1 && slot <= current.save.save_slots:
		var slot_name = "slot_" + str(slot)
		return current.save[slot_name]

func refresh_ui():
	emit_signal("ui_refresh")

