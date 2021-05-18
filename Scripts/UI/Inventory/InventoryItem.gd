extends TextureButton
class_name InventoryItem

enum ItemType {
	CARGO,
	WEAPON,
	SHIP,
	THRUSTER	
}

var item_type: int = 0

var current_stack_size: int = 0
var current_item_count : int = 0 setget set_count
var current_item_uuid = null

var show_label: bool = true
var count_label: Label = null

func _ready():
	count_label = get_node_or_null("ItemCountLabel")
	if !show_label:
		disable_label()
	pass

func set_count(val):
	current_item_count = val
	count_label.text = str(val)


func disable_label():
	if count_label:
		count_label.visible = false

func enable_label():
	if count_label:
		count_label.visible = true
