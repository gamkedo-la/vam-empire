extends TextureButton
class_name InventorySlot

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
	_init_connections()

func insert_item(_item: InventoryItem) -> bool:
	if !occupied:
		current_item = _item
		Global.reparent(current_item, self)
		current_item.rect_position = Vector2.ZERO
		current_item.initialize_item(inventory, self)
		occupied = true
		return true
	return false		
	


func _increment_item(val) -> int:
	if current_item:
		if current_item_count + val <= stack_size:
			current_item_count += val
		else:
			var remainder = val - (stack_size - current_item_count)
			current_item_count = stack_size
			return remainder
	return 0

func _set_item_count(val):
	current_item_count = val
	if current_item:
		current_item.set_count(val)

func _clear_slot() -> void:
	occupied = false

# Harsh Clear, Only to WIPE Inventory
func remove_item():
	current_item = null
	current_item_uuid = null
	current_item_count = 0
	for child in get_children():
		child.queue_free()

	
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
	if current_item:
		inventory.hold_item(current_item, self)
		_clear_slot()
		
	if inventory.held_item && !occupied:
		insert_item(inventory.held_item)

