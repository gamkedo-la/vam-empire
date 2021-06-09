extends TabContainer

const MerchantItem = preload("res://UI/Menu/Merchant/MerchantItem.tscn")
const SellRow = preload("res://UI/Menu/Merchant/SellRow.tscn")

var inventory_data: MerchantInventory = load("res://UI/Menu/Merchant/DefaultMerchantInventory.tres")

onready var ship_row = $Buy/Buy/Row1
onready var sell_box = $Sell/VBoxContainer/SellVbox

var sell_amounts := {}

class CustomSellRowSorter:
	static func sort(uuid_a, uuid_b):
		var price_a = Database.itemByUuid[uuid_a].sellPrice
		var price_b = Database.itemByUuid[uuid_b].sellPrice
		return price_a < price_b


func _ready():
	reset()
	
func reset():
	_init_buy_screen()
	_init_sell_screen()
	
	current_tab = 0 # buy screen

func _init_buy_screen():
		# delete the default data
	for child in ship_row.get_children():
		child.queue_free()
	
	for merchant_inventory_item in inventory_data.ship_inventory:
		var item = MerchantItem.instance()
		ship_row.add_child(item)
		item.init(merchant_inventory_item)
		item.connect("gui_input", self, "_on_MerchantItem_gui_input", [item])

func _init_sell_screen():
	sell_amounts = {}
	
	for child in sell_box.get_children():
		child.queue_free()
	
	var sorted_and_filtered_keys = []
	
	# Insert only mineral types!! Because idk what we're doing with weapons / ships :)
	for uuid in PlayerVars.master_inventory.keys():
		if Database.itemByUuid[uuid].itemType == Database.ItemType.MINERAL:
			sorted_and_filtered_keys.append(uuid)
	
	sorted_and_filtered_keys.sort_custom(CustomSellRowSorter, "sort")
	
	for item_uuid in sorted_and_filtered_keys:
		var sell_row = SellRow.instance()
		sell_box.add_child(sell_row)
		sell_row.init(item_uuid, PlayerVars.master_inventory[item_uuid])
		sell_row.connect("sell_quantity_changed", self, "_onSellRow_sell_quantity_changed", [item_uuid])


func _on_MerchantItem_gui_input(event: InputEvent, item: MerchantItem):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("pressed")

# Reset the sell amounts when tab changes
func _on_MerchantUI_tab_changed(tab):
	if tab != current_tab and tab == 1:
		_init_sell_screen()

# Sell button
func _on_Button_pressed():
	sell_selected()

func sell_selected():
	for item_uuid in sell_amounts.keys():
		var amount = sell_amounts[item_uuid]
		var item_price = Database.itemByUuid[item_uuid].sellPrice
		PlayerVars.player.cash += (amount * item_price)
		PlayerVars.increment_master_inventory(item_uuid, -amount)
	
	# make these changes permanent
	PlayerVars.save()
	_init_sell_screen()

func _onSellRow_sell_quantity_changed(value, item_uuid):
	if value <= 0:
		sell_amounts.erase(item_uuid)
	else:
		sell_amounts[item_uuid] = value


func _on_SellAllButton_pressed():
	sell_amounts.clear()
	for sell_row in sell_box.get_children():
		sell_amounts[sell_row.uuid] = PlayerVars.master_inventory[sell_row.uuid]
	
	sell_selected()
