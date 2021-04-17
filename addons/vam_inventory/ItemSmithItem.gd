tool
extends TextureRect

var item_dict_name
var index
var _editor: EditorPlugin

export (String) var itemName
export (Database.ItemType) var itemType
export (Array, int) var asteroids
export (Texture) var itemTexture

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	
func _init_connections():
	if not self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		assert(self.connect("mouse_entered", self, "_on_mouse_entered") == OK)


func _on_mouse_entered():
	print("Working: ", self)
	print(itemName," ",itemType," ",asteroids," ",itemTexture)
	
