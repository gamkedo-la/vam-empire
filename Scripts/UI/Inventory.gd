class_name Inventory
extends Control


onready var cargo_slot = preload("res://UI/Menu/Inventory/Slot.tscn")
onready var inv_item = preload("res://UI/Menu/Inventory/InventoryItem.tscn")

onready var cargo_grid = $Background/FrameVBox/MasterInv/GridContainer
onready var ship_mount: Control = $Background/FrameVBox/Ship/ShipHB/ShipVB/BackDrop/ShipMount

onready var hardpoint_grid = $Background/FrameVBox/Ship/InventorySlots/HardPoints

onready var inv_efx = $InventoryEfx
var rocks_pickup: AudioStreamRandomPitch = null
var pickup_rocks_sfx = "res://Sounds/Inventory/set_rocks_in_inv.wav"

var ship_copy: Ship = null
export (int, 0, 161) var cargo_slots = 32

var master_slots = []
var hardpoint_slots = []

var inventory_open: bool = false
var held_item = null
var prev_slot = null

func _ready():
	initialize_slots()
	if PlayerVars.ship_inventory:
		_reload_inventory()
	initialize_hardpoints()
	rocks_pickup = AudioStreamRandomPitch.new()
	rocks_pickup.audio_stream = load(pickup_rocks_sfx)
	rocks_pickup.random_pitch = 1.3
	inv_efx.stream = rocks_pickup

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_inventory"):
		_toggle_inventory()

func _input(event):
	if inventory_open:
		if event is InputEventMouseMotion:
			if held_item != null && held_item.picked:
				held_item.rect_global_position = Vector2(event.position.x, event.position.y)


# This function mostly exists to spawn test items from the DB
func insert_item_by_uuid(itemuuid) -> void:
	var item_data = Database.itemByUuid[itemuuid]
	#print(item_data)
	var newItem = inv_item.instance()
	if !item_data.has("stackSize"):
		item_data.stackSize = 1	
	newItem.set_count(1)
	for key in item_data.keys():
		newItem.item_data[key] = item_data[key]
	
#	print_debug(newItem.item_data)
	newItem.texture = load(item_data.itemIcon)
	self.add_child(newItem)
	#print("master_slots: ", master_slots)
	for slot in master_slots.size():
		var inserted_item: bool = master_slots[slot].insert_item(newItem)
		if inserted_item == true:
			PlayerVars.increment_ship_inventory(newItem.item_data.itemUuid,1)
			PlayerVars.save()
			return


func hold_item(_item:InventoryItem, _prev_slot) -> void:
	_item.picked = true
	held_item = _item
	prev_slot = _prev_slot	
	Global.reparent(held_item, self)
	held_item.rect_global_position = get_global_mouse_position()

func initialize_slots():
	for child in cargo_grid.get_children():
		cargo_grid.remove_child(child)
	for slot in cargo_slots:
		var newSlot = cargo_slot.instance()
		newSlot.init_slot(self, 0)
		cargo_grid.add_child(newSlot)
		master_slots.append(newSlot)

func play_cargo_pickup(time = 0.0):
	inv_efx.play()

func clear_inventory():
	for slot in master_slots:
		slot.remove_item()
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
				var newWeapon = inv_item.instance()
				newWeapon.item_type = newWeapon.ItemType.WEAPON
				newWeapon.texture = mountedWeapon.weapon_sprite.texture
				newWeapon.show_label = false
				newWeapon.rect_min_size = Vector2(32,32)
				newWeapon.expand = true
				newWeapon.initialize_item(self, newSlot)
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
			insert_item_by_uuid(item)


func _increment_item(slot):
	slot.current_item_count += 1
	PlayerVars.increment_ship_inventory(slot.current_item_uuid, 1)

func _on_ExitInventory_pressed():
	_toggle_inventory()


func _toggle_inventory():
	if self.visible && inventory_open:
		if held_item:
			held_item.picked = false
			#held_item.parent_slot.add_child(held_item)
			prev_slot.insert_item(held_item)
			held_item = null
		self.visible = false
		Global.pause_game(false)
		inventory_open = false
	else:
		if !inventory_open:
			self.visible = true
			inventory_open = true
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
