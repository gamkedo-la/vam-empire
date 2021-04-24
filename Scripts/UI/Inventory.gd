extends Control

onready var cargo_slot = preload("res://UI/Menu/Inventory/Slot.tscn")
onready var inv_item = preload("res://UI/Menu/Inventory/InventoryItem.tscn")

onready var cargo_grid = $Background/FrameVBox/MasterInv/GridContainer

export (int, 0, 161) var cargo_slots = 32

var master_slots = []

func _ready(): 	
	initialize_slots()
	


func insert_item(itemuuid):
	var item_data = Database.itemByUuid[itemuuid]
	#print(item_data)
	var newItem = inv_item.instance()
	if !item_data.has("stackSize"):
		item_data.stackSize = 1
	newItem.texture_normal = load(item_data.itemIcon)
	print("master_slots: ", master_slots)
	for slot in master_slots.size():
		print("slot: ", slot)
		# Does a slot with this item type already exist?
		if master_slots[slot].current_item_uuid == item_data.itemUuid:			
			if master_slots[slot].current_item_count < item_data.stackSize:
				_increment_item(master_slots[slot], item_data)
				return
		elif master_slots[slot].current_item_count <= 0:
			_add_to_slot(master_slots[slot], item_data, newItem)
			return
		else:
			pass			


func initialize_slots():
	for slot in cargo_slots:
		var newSlot = cargo_slot.instance()
		cargo_grid.add_child(newSlot)
		master_slots.append(newSlot)
		newSlot.current_item = null
		newSlot.current_item_count = 0
		newSlot.current_item_uuid = null

func clear_inventory():
	for slot in master_slots:
		slot.remove_item()
		slot.current_item = null
		slot.current_item_uuid = null
		slot.current_item_count = 0
		

func _add_to_slot(slot, data, item):
	slot.add_child(item)
	slot.current_item = item
	slot.current_item_count += 1
	slot.current_item_uuid = data.itemUuid
	

func _increment_item(slot, data):
	slot.current_item_count += 1

func _on_ExitInventory_pressed():
	if self.visible:
		self.visible = false
		Global.pause_game(false)
	else:
		self.visible = true
		Global.pause_game(true)



func _on_TestAdd_pressed():
	var items = Database.table.Items
	var rand_add = items[randi() % items.size()]
	insert_item(rand_add.itemUuid)
	



func _on_TestClear_pressed():
	clear_inventory()
