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
var parent_inventory = null
var parent_slot = null
var picked: bool = false

func _ready():
	count_label = get_node_or_null("ItemCountLabel")
	if !show_label:
		disable_label()	
	pass

func initialize_item(_inv, _slot) -> void:
	parent_inventory = _inv
	parent_slot = _slot
	self.material.set_shader_param("textureName_size", self.texture_normal.get_size())
	_init_connections()

func _init_connections() -> void:
	if not self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		assert(self.connect("mouse_entered", self, "_on_mouse_entered") == OK)
	if not self.is_connected("mouse_exited", self, "_on_mouse_exited"):
		assert(self.connect("mouse_exited", self, "_on_mouse_exited") == OK)
	if not self.is_connected("pressed", self, "_on_item_pressed"):
		assert(self.connect("pressed", self, "_on_item_pressed") == OK)
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


func _on_mouse_entered() -> void:
	self.material.set_shader_param("width", 0.2)
	pass
	
func _on_mouse_exited() -> void:
	self.material.set_shader_param("width", 0.0)
	pass

func _on_item_pressed() -> void:
	parent_inventory.pickup_item(self)
	pass
