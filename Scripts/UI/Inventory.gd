extends Control

onready var cargo_slot = preload("res://UI/Menu/Inventory/Slot.tscn")
onready var inv_item = preload("res://UI/Menu/Inventory/InventoryItem.tscn")

onready var cargo_grid = $Background/FrameVBox/MasterInv/GridContainer
onready var ship_mount: Control = $Background/FrameVBox/Ship/ShipHB/ShipVB/BackDrop/ShipMount

onready var hardpoint_grid = $Background/FrameVBox/Ship/InventorySlots/HardPoints

var ship_copy: Ship = null
export (int, 0, 161) var cargo_slots = 32

var master_slots = []
var hardpoint_slots = []

func _ready():
	initialize_slots()
	if PlayerVars.ship_inventory:
		_reload_inventory()
	initialize_hardpoints()
	

func _process(_delta):
	if Input.is_action_just_pressed("ui_inventory"):
		_toggle_inventory()		

func insert_item(itemuuid):
	var item_data = Database.itemByUuid[itemuuid]
	#print(item_data)
	var newItem = inv_item.instance()
	if !item_data.has("stackSize"):
		item_data.stackSize = 1
	newItem.texture_normal = load(item_data.itemIcon)
	#print("master_slots: ", master_slots)
	for slot in master_slots.size():
		#print("slot: ", slot)
		# Does a slot with this item type already exist?
		if master_slots[slot].current_item_uuid == item_data.itemUuid:			
			if master_slots[slot].current_item_count < item_data.stackSize:
				_increment_item(master_slots[slot])
				return
		elif master_slots[slot].current_item_count <= 0:
			_add_to_slot(master_slots[slot], item_data, newItem)
			return
		else:
			pass			


func initialize_slots():
	for child in cargo_grid.get_children():
		cargo_grid.remove_child(child)
	for slot in cargo_slots:
		var newSlot = cargo_slot.instance()
		cargo_grid.add_child(newSlot)
		master_slots.append(newSlot)
		newSlot.slot_type = newSlot.SlotType.CARGO
		newSlot.current_item = null
		newSlot.current_item_count = 0
		newSlot.current_item_uuid = null

func clear_inventory():
	for slot in master_slots:
		slot.remove_item()
		slot.current_item = null
		slot.current_item_uuid = null
		slot.current_item_count = 0
	PlayerVars.clear_ship_inventory()

func initialize_hardpoints() -> void:
	if ship_copy:
		if hardpoint_slots.size() > 0:
			for child in hardpoint_grid.get_children():
				hardpoint_grid.remove_child(child)
			hardpoint_slots.clear()
		for hp_slot in ship_copy.hardpoints.get_children():
			var newSlot = cargo_slot.instance()
			hardpoint_grid.add_child(newSlot)
			hardpoint_slots.append(newSlot)
			newSlot.slot_type = newSlot.SlotType.WEAPON
			newSlot.current_item = null
			if hp_slot.get_child_count() > 0:
				var mountedWeapon: Weapon = hp_slot.get_child(0)
				var newWeapon:InventoryItem = inv_item.instance()
				newWeapon.item_type = newWeapon.ItemType.WEAPON
				newWeapon.texture_normal = mountedWeapon.weapon_sprite.texture
				newWeapon.show_label = false
				newWeapon.rect_min_size = Vector2(32,32)
				newWeapon.expand = true
				#newWeapon.hardpoint_slot = hp_slot????
				newSlot.add_child(newWeapon)
				

func _add_to_slot(slot, data, item):
	slot.add_child(item)
	slot.current_item = item
	slot.current_item_count += 1
	slot.current_item_uuid = data.itemUuid
	PlayerVars.increment_ship_inventory(slot.current_item_uuid, 1)
	

func _reload_inventory():
	# Offload inventory to a temp dict
	var temp_inv = PlayerVars.ship_inventory.duplicate()
	# Wipe ship inventory
	PlayerVars.clear_ship_inventory()
	# Reload it
	for item in temp_inv:
		for count in temp_inv[item]:
			insert_item(item)


func _increment_item(slot):
	slot.current_item_count += 1
	PlayerVars.increment_ship_inventory(slot.current_item_uuid, 1)

func _on_ExitInventory_pressed():
	_toggle_inventory()


func _toggle_inventory():
	if self.visible:
		self.visible = false
		Global.pause_game(false)
	else:
		self.visible = true
		Global.pause_game(true)
		if ship_mount.get_child_count() > 0:
			for child in ship_mount.get_children():
				ship_mount.remove_child(child)
		if PlayerVars.player_node:
			if PlayerVars.player_node.piloted_ship != null:
				ship_copy = PlayerVars.player_node.piloted_ship.duplicate()
				ship_mount.add_child(ship_copy)
				initialize_hardpoints()
		else:
			var new_ship = Global.ship_hangar[0][0].duplicate(true)
			ship_copy = new_ship[0].duplicate()
			ship_mount.add_child(ship_copy)
			


func _on_TestAdd_pressed():
	var items = Database.table.Items
	var rand_add = items[randi() % items.size()]
	#insert_item(rand_add.itemUuid)
	PlayerVars.pickup_item(rand_add.itemUuid)

func _on_TestClear_pressed():
	clear_inventory()
