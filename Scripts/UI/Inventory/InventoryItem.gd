class_name InventoryItem
extends TextureRect


enum ItemType {
	CARGO,
	WEAPON,
	SHIP,
	THRUSTER	
}

var item_type: int = 0

var item_data = {}

var stack_size: int = 0
var count : int = 0 setget set_count
var item_uuid = null

var show_label: bool = true
var count_label: Label = null
var parent_inventory = null
var parent_slot = null
var picked: bool = false

func _ready():	
	if !show_label:
		disable_label()	

func initialize_item(_inv, _slot) -> void:
	parent_inventory = _inv
	parent_slot = _slot
	picked = false
	count_label = get_node_or_null("ItemCountLabel")
	count_label.text = str(count)
	print_debug("item data for item:", self, " ", item_data)
	if item_data.has("stackSize"):
		stack_size = item_data.stackSize
	else:
		stack_size = 1
	self.material.set_shader_param("textureName_size", self.texture.get_size())

func set_count(val):
	count = val
	if count_label:
		count_label.text = str(val)

func increment(val) -> int:
	if count + val <= stack_size:
		set_count(count + val)
	else:
		var remainder = val - (stack_size - count)
		set_count(stack_size)
		return remainder
	return 0


func disable_label():
	if count_label:
		count_label.visible = false

func enable_label():
	if count_label:
		count_label.visible = true

func highlight_item() -> void:
	self.material.set_shader_param("width", 1.0)
	pass
	
func unhighlight_item() -> void:
	self.material.set_shader_param("width", 0.0)
	pass

