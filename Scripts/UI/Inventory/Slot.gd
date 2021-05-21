class_name InventorySlot
extends TextureButton


enum SlotType {
	CARGO,
	WEAPON,
	SHIP,
	THRUSTER
}

var slot_type: int = 0

var inventory = null
var occupied: bool = false
var current_item = null
var current_item_uuid = null
var current_item_count : int = 0 setget _set_item_count
var stack_size = 1


func init_slot(_inv, _type: int) -> void:
	inventory = _inv
	slot_type = _type
	current_item = null
	current_item_uuid = null
	current_item_count = 0
	occupied = false
	_init_connections()

func insert_item(_item: InventoryItem) -> bool:
	if !occupied:
		current_item = _item
		Global.reparent(current_item, self)
		current_item.rect_position = Vector2.ZERO
		current_item.initialize_item(inventory, self)
		occupied = true
		return true
	elif _item.item_data["itemUuid"] == current_item.item_data["itemUuid"]:
		print_debug("Item Matched on slot: ", self)
		var remainder = current_item.increment(_item.count)
		if remainder > 0:
			# Return item decremented by what ever fit into the stack
			_item.count = remainder
			return false
		else:
			# No remainder, so can clear this item knowing we've added it's value to the 'stack'
			_item.queue_free()
			return true
	return false		
	




func _set_item_count(val):
	current_item_count = val
	if current_item:
		current_item.set_count(val)

func _clear_slot() -> void:
	occupied = false

# Harsh Clear, Only to WIPE Inventory
func remove_item():
	for child in get_children():
		child.queue_free()
	init_slot(inventory, slot_type)

	
func _init_connections() -> void:
	if not self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		assert(self.connect("mouse_entered", self, "_on_mouse_entered") == OK)
	if not self.is_connected("mouse_exited", self, "_on_mouse_exited"):
		assert(self.connect("mouse_exited", self, "_on_mouse_exited") == OK)
	if not self.is_connected("pressed", self, "_on_slot_pressed"):
		assert(self.connect("pressed", self, "_on_slot_pressed") == OK)
	
func _on_mouse_entered() -> void:
	if current_item:
		current_item.highlight_item()

func _on_mouse_exited() -> void:
	if current_item:
		current_item.unhighlight_item()

func _on_slot_pressed() -> void:
	if occupied:
		inventory.hold_item(current_item, self)
		_clear_slot()
		
	if inventory.held_item && !occupied:
		insert_item(inventory.held_item)

