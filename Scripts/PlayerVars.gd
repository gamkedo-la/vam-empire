extends Node
# File saving/loading methodology adapted from https://gdscript.com/solutions/how-to-save-and-load-godot-game-data/
var FILE_NAME  = "user://game-data.json"

var player = {
	"name": "Player",
	"cash": 10000,
	"current_ship": "res://Ships/StarterShip.tscn"	
}

var player_node = null

# For instantiating a new player file
var player_defaults = {
	"name": " ",
	"cash": 10000,
	"current_ship": "res://Ships/StarterShip.tscn"
	
}

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
