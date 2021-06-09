tool
extends Resource
class_name MerchantInventory

export(Array, Resource) var ship_inventory setget set_ship_inventory

func set_ship_inventory(value) -> void:
	ship_inventory.resize(value.size())
	ship_inventory = value
	for i in ship_inventory.size():
		if not ship_inventory[i]:
			ship_inventory[i] = MerchantInventoryItem.new()
			ship_inventory[i].resource_name = "Ship" + str(i)
