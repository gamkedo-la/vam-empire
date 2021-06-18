extends HBoxContainer

signal sell_quantity_changed(amount)

const int_regex = "[0-9]"

onready var icon = $HBoxContainer/SellItemIcon
onready var name_label = $HBoxContainer/SellItemName
onready var price_label = $HBoxContainer/SellItemPriceLabel
onready var profit_label = $HBoxContainer2/Profit

onready var max_sell_quantity_label = $HBoxContainer2/InventoryItemQuantity
onready var quantity_text_edit = $HBoxContainer2/SellQuantity

var max_sell_quantity
var sell_quantity = 0 setget set_sell_quantity
var current_text_edit_text = '0'
var sell_price = 0
var uuid

func init(item_uuid: String, item_count: int):
	uuid = item_uuid
	var item = Database.itemByUuid[item_uuid]
	icon.texture = load(item.itemIcon)
	name_label.text = item.itemName
	price_label.text = "$" + str(item.sellPrice)
	
	max_sell_quantity = item_count
	max_sell_quantity_label.text = str(item_count)
	sell_price = item.sellPrice

func set_sell_quantity(amount):
	sell_quantity = int(clamp(amount, 0, max_sell_quantity))
	
	profit_label.text = "$" + str(sell_quantity * sell_price)
	if (quantity_text_edit.text != str(sell_quantity)):
		var current_position = quantity_text_edit.caret_position
		quantity_text_edit.text = str(sell_quantity)
		quantity_text_edit.caret_position = current_position

	emit_signal("sell_quantity_changed", sell_quantity)

func _on_SellQuantity_text_changed(new_text: String):
	var regex = RegEx.new()
	regex.compile(int_regex)

	var cleaned_text = ''

	var regex_match = regex.search_all(new_text)
	if regex_match:
		for i in range(0,regex_match.size()):
			cleaned_text += regex_match[i].get_string()
	
	if cleaned_text != new_text:
		quantity_text_edit.text = cleaned_text
		return
	
	
	
	if new_text != null and new_text != '' and !new_text.is_valid_integer():
		quantity_text_edit.text = str(sell_quantity)
	elif new_text != null and new_text.is_valid_integer():
		var new_quantity = int(new_text)
		if new_quantity != sell_quantity:
			set_sell_quantity(new_quantity)
	elif (new_text == null || new_text == '') and sell_quantity != 0:
		set_sell_quantity(0)
		quantity_text_edit.text = ''
		
	quantity_text_edit.caret_position = new_text.length()


func _on_SellQuantity_focus_exited():
	if quantity_text_edit.text == '':
		quantity_text_edit.text = '0'

func _on_TenLess_pressed():
	self.sell_quantity -= 10

func _on_Less_pressed():
	self.sell_quantity -= 1

func _on_More_pressed():
	self.sell_quantity += 1

func _on_TenMore_pressed():
	self.sell_quantity += 10
