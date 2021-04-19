tool
extends Node

# ItemSmith UI Signals
signal item_selected
signal clear_selected_item

enum ItemType {
	MINERAL,
	AMMO,
	CONSUMABLE,
	WEAPON
}
var DATABASE = "res://Database/Database.json"

var table

var selected_item setget emit_item_selected, get_selected_item

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
			printerr("Corrupted Database Data!")
	else:
		printerr("No saved Database to load")

func emit_item_selected(item):
	selected_item = item
	emit_signal("item_selected", item)

func get_selected_item():
	return selected_item

func emit_clear_selected_item():
	selected_item = null
	emit_signal("clear_selected_item")
