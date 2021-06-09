extends MarginContainer
class_name MerchantItem

const TWO_LINE_CHAR_LENGTH = 12
const modulate_can_afford = Color("#c8ffc1")
const modulate_cannot_afford = Color("#ffb2b2")
const modulate_no_hover = Color("#ffffff")


onready var item_image = $MarginContainer/VBoxContainer/ItemImage
onready var name_label = $MarginContainer/VBoxContainer/NameLabel
onready var price_label = $MarginContainer/VBoxContainer/PriceLabel

var inventory_item: MerchantInventoryItem

func init(_item: MerchantInventoryItem) -> void:
	var ship = Global.ship_hangar[_item.class_index][_item.ship_index][0]
	var name = ship.name
	
	item_image.texture = ship.get_sprite()
	price_label.text = str(_item.buy_price)
	
	if (name.length() > TWO_LINE_CHAR_LENGTH):
		var font: DynamicFont = name_label.get("custom_fonts/font")
		font.size = (float(TWO_LINE_CHAR_LENGTH) / float(name.length())) * font.size
		
	name_label.text = name
	inventory_item = _item


func _on_MerchantItem_mouse_entered():
	modulate = modulate_can_afford if PlayerVars.player.cash >= inventory_item.buy_price else modulate_cannot_afford


func _on_MerchantItem_mouse_exited():
	modulate = modulate_no_hover
