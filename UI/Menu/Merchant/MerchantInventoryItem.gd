tool
extends Resource
class_name MerchantInventoryItem

var packed_ships = load("res://Ships/PackedShips.tscn")

var reverse_lookup = {}
var ship_names = []

var ship_name
var class_index
var ship_index

var buy_price

func _init():
	ship_names = get_all_ship_names()
	ship_name = ship_names[0]
	class_index = reverse_lookup[ship_name][0]
	ship_index = reverse_lookup[ship_name][1]
	buy_price = 100


func get_all_ship_names() -> Array:
	var names = []
	var ships = packed_ships.instance()
	
	for _classIndex in ships.get_child_count():
		var _class = ships.get_child(_classIndex)
		if !_class.get_children():
			continue
		
		for _shipIndex in _class.get_child_count():
			var _ship = _class.get_child(_shipIndex)
			if !_ship.get_child(0):
				continue
				
			var _name = _class.name + "-" + _ship.get_child(0).name
			if (reverse_lookup.has(_name)):
				_name += "-" +  str(_shipIndex)
			
			names.append(_name)
			reverse_lookup[_name] = [_classIndex, _shipIndex]
	
	return names

func _get(property): # overridden
	if property == "ship":
		return ship_name
	if property == "buy_price":
		return buy_price

func _set(property, value): # overridden
	if property == "ship":
		ship_name = value
		class_index = reverse_lookup[ship_name][0]
		ship_index = reverse_lookup[ship_name][1]
	if property == "buy_price":
		buy_price = value
	return true

func _get_property_list():	# overridden function
	var property_list = []
	
	var ship_names_hint = ""
	for name in ship_names:
		ship_names_hint += name + ","
	
	ship_names_hint = ship_names_hint.trim_suffix(",")
	# List the weapon type choice no matter what. This is the 'primary driver and must be listed this way.
	# As an "export", weap_type can't trigger the property_list_change_notify(), that I have found yet! It would be nice if it *could*.
	property_list.append({
		"name": "ship",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ship_names_hint,
		"usage": 8199})
		
	property_list.append({
		"name": "buy_price",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
		"usage": 8199
	})

	return property_list
