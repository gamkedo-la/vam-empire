tool
extends TextureButton

var item_dict_name
var index
var _editor: EditorPlugin
var _item_smith
var selected = false as bool 

var _index = null setget set_index, get_index
export (String) var itemName
export (Database.ItemType) var itemType
export (Array, int) var asteroids
export (Texture) var itemTexture
export (String) var itemIcon
onready var BG = $BG
onready var BG_hover = $BG_hover

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	if !BG:
		BG = get_node_or_null("BG")
	if !BG_hover:
		BG_hover = get_node_or_null("BG_hover")
	
func _init_connections():
	if not self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		assert(self.connect("mouse_entered", self, "_on_mouse_entered") == OK)
	if not self.is_connected("mouse_exited", self, "_on_mouse_exited"):
		assert(self.connect("mouse_exited", self, "_on_mouse_exited") == OK)
#	if not self.is_connected("gui_input", self, "_on_gui_input"):
#		assert(self.connect("gui_input", self, "_on_gui_input") == OK)
	if not self.is_connected("pressed", self, "_on_item_pressed"):
		assert(self.connect("pressed", self, "_on_item_pressed") == OK)
	
	Database.connect("item_selected", self, "_new_item_selected")
	


func _on_mouse_entered():
#	print("Working: ", self)
#	print(itemName," ",itemType," ",asteroids," ",itemTexture)
	if BG_hover && !selected:
		BG_hover.visible = true
		
func _on_mouse_exited():
	if BG_hover && !selected:
		BG_hover.visible = false
		
#func _on_gui_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT:
#			if event.pressed:
#				_select_item(self)

func _on_item_pressed() -> void:
	_select_item(self)

func _select_item(selec_item) -> void:
	if self == selec_item:
		Database.emit_item_selected(self)
		selected = true
		if BG:
			BG.visible = true
		if BG_hover:
			BG_hover.visible = false

func _new_item_selected(item) -> void:
	if item != self:
		selected = false
		if BG:
			BG.visible = false
		if BG_hover:
			BG_hover.visible = false 

func set_index(val):
	_index = val

func get_index():
	return _index
