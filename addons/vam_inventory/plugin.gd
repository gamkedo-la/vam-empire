tool
extends EditorPlugin
#********************************************************************************************************************************
# Pieces and parts taken from studying other Godot Plugins to learn the general construction, signaling methodology, and approaches.
# General concept and overview taken from InventoryEditor by Vladimir Petrenko (MIT License) @ https://godotengine.org/asset-library/asset/896
# VAM Item Smith was adapted to serve a smaller purpose targeting only a small JSON "database", so Vladimir's work served as a means of learning
# how to snap the pieces and parts of UI together to serve this smaller purpose.
# ********************************************************************************************************************************


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
