tool
extends Node

enum ItemType {
	MINERAL,
	AMMO,
	CONSUMABLE,
	WEAPON
}
var DATABASE = "res://Database/Database.json"

var table

func _init():
	load_db()
	print_debug("DATABASE:")
	print_debug(table)



func load_db():
	var file = File.new()
	if file.file_exists(DATABASE):
		file.open(DATABASE, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			table = data
		else:
			printerr("Corrupted Player Save Data!")
	else:
		printerr("No saved data to load")

