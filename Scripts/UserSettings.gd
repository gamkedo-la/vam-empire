extends Node

var FILE_NAME = "user://user-settings.json"

var current = {
"master_volume": 1,
"music_volume": 1,
"effects_volume": 1
}

var user_defaults = {
"master_volume": 1,
"music_volume": 1,
"effects_volume": 1
}

# Called when the node enters the scene tree for the first time.
func _ready():
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
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			current = data
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
