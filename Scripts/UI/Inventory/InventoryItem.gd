extends TextureRect
class_name InventoryItem

enum ItemType {
	CARGO,
	WEAPON,
	SHIP,
	THRUSTER	
}

var item_type: int = 0

var item_data = {}

var current_stack_size: int = 0
var current_item_count : int = 0 setget set_count
var current_item_uuid = null

var show_label: bool = true
var count_label: Label = null
var parent_inventory = null
var parent_slot = null
var picked: bool = false

func _ready():
	item_data = {}
	count_label = get_node_or_null("ItemCountLabel")
	if !show_label:
		disable_label()	
	pass

func initialize_item(_inv, _slot) -> void:
	parent_inventory = _inv
	parent_slot = _slot
	picked = false
	self.material.set_shader_param("textureName_size", self.texture.get_size())

func set_count(val):
	current_item_count = val
	count_label.text = str(val)


func disable_label():
	if count_label:
		count_label.visible = false

func enable_label():
	if count_label:
		count_label.visible = true

func highlight_item() -> void:
	self.material.set_shader_param("width", 0.2)
	pass
	
func unhighlight_item() -> void:
	self.material.set_shader_param("width", 0.0)
	pass

