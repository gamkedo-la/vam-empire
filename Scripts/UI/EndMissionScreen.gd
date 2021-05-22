class_name EndScreen
extends Control

onready var item_box = preload("res://UI/Menu/EndMissionScreen/ItemDisplayHB.tscn")
onready var ship_scroll = $MarginContainer/MainHB/ShipInventory/ItemScrollBox
onready var master_scroll = $MarginContainer/MainHB/MasterInventory/ItemScrollBox

var ship_boxes = {}
var master_boxes = {}
onready var timer = Timer.new()
var interval = 2
var current_uuid = null

func _ready() -> void:
	PlayerVars.load_save()
	populate_item_fields()
	self.add_child(timer)
	timer.wait_time = interval
	timer.connect("timeout", self, "_transfer_items")
	timer.start()
	
	

func populate_item_fields() -> void:
	for inv_uuid in PlayerVars.ship_inventory.keys():
		var item_data = Database.itemByUuid[inv_uuid]
		print_debug(item_data)
		var newBox: EndScreenItemBox = item_box.instance()
		var mastBox: EndScreenItemBox = item_box.instance()
		var icon_texture = load(item_data.itemIcon)
		ship_scroll.add_child(newBox)
		ship_boxes[inv_uuid] = newBox
		master_scroll.add_child(mastBox)
		master_boxes[inv_uuid] = mastBox
		newBox.initialize(icon_texture, item_data.itemName, PlayerVars.ship_inventory[inv_uuid])
		PlayerVars.increment_master_inventory(inv_uuid, 0)
		mastBox.initialize(icon_texture, item_data.itemName, PlayerVars.master_inventory[inv_uuid])
		

func _transfer_items() -> void:
	timer.stop()
	var count_speed: float
	var trans_cnt: int
	for uuid in PlayerVars.ship_inventory.keys():
		current_uuid = uuid
		count_speed = 0.1		
		while PlayerVars.ship_inventory[uuid] > 0:
			if count_speed > 0.0001:
				yield(get_tree().create_timer(count_speed), "timeout")
				_transfer_item(1)
			else:
				_transfer_item(PlayerVars.ship_inventory[uuid])
			count_speed *= 0.9
			
	

func _transfer_item(val) -> void:
	PlayerVars.increment_ship_inventory(current_uuid,-val)
	PlayerVars.increment_master_inventory(current_uuid,val)
	ship_boxes[current_uuid].decrement(val)
	master_boxes[current_uuid].increment(val)

