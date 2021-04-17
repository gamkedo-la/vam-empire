tool
extends EditorPlugin

const ItemSmith = preload("res://addons/vam_inventory/ItemSmith.tscn")
const IconTexture = preload("res://addons/vam_inventory/icons/gold-icon.png")

var _item_smith

func _enter_tree() -> void:
	_item_smith = ItemSmith.instance()
	get_editor_interface().get_editor_viewport().add_child(_item_smith)
	_item_smith.set_editor(self)
	make_visible(false)
	
func _exit_tree():
	if _item_smith:
		_item_smith.queue_free()

func has_main_screen():
	return true
		
func get_plugin_name():
	return "VAM Item Smith"
	
func get_plugin_icon():
	return IconTexture

func make_visible(visible):
	if _item_smith:
		_item_smith.visible = visible
