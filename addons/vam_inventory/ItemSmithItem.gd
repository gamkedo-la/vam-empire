tool
extends TextureRect

var item_dict_name
var index
var _editor: EditorPlugin
var _item_smith

export (String) var itemName
export (Database.ItemType) var itemType
export (Array, int) var asteroids
export (Texture) var itemTexture
var BG

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	BG = get_node_or_null("BG")
	
func _init_connections():
	if not self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		assert(self.connect("mouse_entered", self, "_on_mouse_entered") == OK)
	if not self.is_connected("mouse_exited", self, "_on_mouse_exited"):
		assert(self.connect("mouse_exited", self, "_on_mouse_exited") == OK)
	if not self.is_connected("gui_input", self, "_on_gui_input"):
		assert(self.connect("gui_input", self, "_on_gui_input") == OK)
	


func _on_mouse_entered():
#	print("Working: ", self)
#	print(itemName," ",itemType," ",asteroids," ",itemTexture)
	if BG:
		BG.visible = true
		
func _on_mouse_exited():
	if BG:
		BG.visible = false
		
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				print_debug(event.button_index, " BUTTON_LEFT Pressed.")
				Database.emit_item_selected(self)
	
