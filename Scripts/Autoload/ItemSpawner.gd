extends Node

# depends on Database autoload
# TODO: make into own Autoload?

const Item = preload("res://Database/Item.tscn")

# uses AsteroidType enum from "res://Scripts/Autoload/Database.gd"
func get_item_for_asteroid_type(_asteroid_type:int):
	# for now, getting random item
	var items = Database.table.Items
	return items[randi() % items.size()]

func spawn_items_for_asteroid_type(asteroid_type:int):
	var num_items = 1
	var items = []
	for i in num_items:
		var item = Item.instance()
		var data = get_item_for_asteroid_type(asteroid_type)
		item.init_item(data.itemName, data.itemType, data.itemIcon)
		items.append(item)
	return items
