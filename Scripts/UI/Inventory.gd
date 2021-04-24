extends Control

onready var cargo_slot = preload("res://UI/Menu/Inventory/Slot.tscn")

onready var cargo_grid = $Background/FrameVBox/MasterInv/GridContainer

export (int, 0, 161) var cargo_slots = 32

var master_slots = []

func _ready(): 
	for slot in cargo_slots:
		var newSlot = cargo_slot.instance()
		cargo_grid.add_child(newSlot)
		
		master_slots.append(newSlot)
	
	insert_item("ae14dca8-35d6-4a30-ab35-266c415a5ce9")
	pass


func insert_item(itemuuid):
	var item_data = Database.itemByUuid[itemuuid]
	#print(item_data)
	var newItem = TextureButton.new()
	newItem.texture_normal = load(item_data.itemIcon)
	master_slots[15].add_child(newItem)


func _on_ExitInventory_pressed():
	if self.visible:
		self.visible = false
		Global.pause_game(false)
	else:
		self.visible = true
		Global.pause_game(true)

