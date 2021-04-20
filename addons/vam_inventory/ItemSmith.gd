tool
extends Control

var newItem = preload("res://addons/vam_inventory/ItemSmithItem.tscn")
var ItemSmithFileDialog = preload("res://addons/vam_inventory/ItemSmithFileDialog.tscn")
var newProp = preload("res://addons/vam_inventory/NewProp.tscn")

var default_icon = preload("res://icon.png")

var _editor: EditorPlugin


onready var _items_grid = $BG/MainVB/MainHB/ItemsVB/Items as GridContainer
onready var _load_db = $BG/MainVB/MainHB/ButtonVB/LoadDB as Button
onready var _clear = $BG/MainVB/MainHB/ButtonVB/Clear as Button

onready var _scene_file_load = $BG/MainVB/MainHB/InspectVB/SceneHB/SceneFileButton as Button
onready var _scene_file_edit = $BG/MainVB/MainHB/InspectVB/SceneHB/SceneFileLineEdit as LineEdit
onready var _scene_file_clr = $BG/MainVB/MainHB/InspectVB/SceneHB/SceneLineClr as Button
onready var _icon_file_load = $BG/MainVB/MainHB/InspectVB/IconHB/IconFileButton as Button
onready var _icon_file_edit = $BG/MainVB/MainHB/InspectVB/IconHB/IconFileLineEdit as LineEdit
onready var _icon_file_clr = $BG/MainVB/MainHB/InspectVB/IconHB/IconLineClr as Button

onready var _item_name_lbl = $BG/MainVB/MainHB/InspectVB/ItemIconHB/ItemNameLbl as Label
onready var _item_icon_rect = $BG/MainVB/MainHB/InspectVB/ItemIconHB/ItemIconRect as TextureRect

onready var _type_option = $BG/MainVB/MainHB/InspectVB/TypeHB/TypeOption as OptionButton

onready var _props_vbox = $BG/MainVB/MainHB/InspectVB/PropsVB as VBoxContainer
onready var _add_prop_button = $BG/MainVB/MainHB/InspectVB/AddPropHB/AddPropButton as Button


export (bool) var regenerate = false setget _regen

onready var itemsNode
var cur_scene
var Itemdb



func _ready() -> void:
#	if get_tree().get_root().has_node("Database"):
#		print("Got a Database")
	Database.connect("item_selected", self, "set_selected_item")
	Database.connect("clear_selected_item", self, "clear_selected_item")
	for item_type in Database.ItemType:
		_type_option.add_item(item_type)
	

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()

func set_selected_item(item):
	clear_properties()
	print_debug(item," is selected.")
	var sel_item = Database.table.Items[item.get_index()]
	print(sel_item)
	if _icon_file_edit:
		_icon_file_edit.text = var2str(sel_item.itemIcon)
	if _item_name_lbl:
		_item_name_lbl.text = sel_item.itemName
	if _item_icon_rect:
		_item_icon_rect.texture = load(sel_item.itemIcon)
	if _type_option:
		_type_option.select(sel_item.itemType)	
	if sel_item.has("properties"):
		print("HAS PROPERTIES")
		for props in sel_item.properties:
			print(var2str(props))			
			add_property(props.type, var2str(props.name), var2str(props.value))

func clear_selected_item() -> void:
	clear_properties()
	
func add_property(p_type, property, value) -> void:
	if _props_vbox:
		var new_prop = newProp.instance()
		_props_vbox.add_child(new_prop)
		new_prop.set_editor(_editor)
		new_prop.set_prop(p_type, property, value)
		
		#test that it was set!
		print(var2str(new_prop.get_prop()))
	
		

func clear_properties() -> void:
	if _props_vbox:
		if _props_vbox.get_child_count() > 0:
			for prop_child in _props_vbox.get_children():
				_props_vbox.remove_child(prop_child)
	if _icon_file_edit:
		_icon_file_edit.text = ""
	if _item_name_lbl:
		_item_name_lbl.text = ""
	if _item_icon_rect:
		_item_icon_rect.texture = default_icon

func _init_connections() -> void:
	if not _load_db.is_connected("pressed", self, "_load_items"):
		assert(_load_db.connect("pressed", self, "_load_items") == OK)
	if not _clear.is_connected("pressed", self, "_clear"):
		assert(_clear.connect("pressed", self, "_clear") == OK)
	if not _scene_file_load.is_connected("pressed", self, "_scene_file_load"):
		assert(_scene_file_load.connect("pressed", self, "_scene_file_load") == OK)
#	if not _scene_file_edit.is_connected("gui_input", self, "_scene_gui_input"):
#		assert(_scene_file_edit.connect("gui_input", self, "_scene_gui_input"))
	if not _scene_file_clr.is_connected("pressed", self, "_scene_file_clear"):
		assert(_scene_file_clr.connect("pressed", self, "_scene_file_clear") == OK)
	if not _icon_file_load.is_connected("pressed", self, "_icon_file_load"):
		assert(_icon_file_load.connect("pressed", self, "_icon_file_load") == OK)
	if not _icon_file_clr.is_connected("pressed", self, "_icon_file_clear"):
		assert(_icon_file_clr.connect("pressed", self, "_icon_file_clear") == OK)
	if not _add_prop_button.is_connected("pressed", self, "_on_AddPropButton_pressed"):
		assert(_add_prop_button.connect("pressed", self, "_on_AddPropButton_pressed") == OK)

func _regen(val):
	regenerate = !regenerate	
	_load_items()
	
func _load_items() -> void:
	_clear()
	Database.load_db()
	var Items = Database.table.Items	
#	print(_items_grid)
#	if _items_grid.get_child_count() > 0:		
#		for grid_item in _items_grid.get_children():
#			_items_grid.remove_child(grid_item)
	for item in Items:
		var treeItem = newItem.instance()
		if typeof(item) == TYPE_DICTIONARY:
			# "Required" Item Fields
			treeItem.set_index(Items.find(item))
			treeItem.itemName = var2str(item.itemName)
			treeItem.itemType = var2str(int(item.itemType))
			treeItem.itemIcon = var2str(item.itemIcon)
			treeItem.itemTexture = load(item.itemIcon)
			treeItem.texture_normal = load(item.itemIcon)
			treeItem.set_editor(_editor)
			if _items_grid:
				_items_grid.add_child(treeItem)
			

func _clear() -> void:
	if _items_grid && _items_grid.get_child_count() > 0:
		for item in _items_grid.get_children():
			_items_grid.remove_child(item)
	Database.emit_clear_selected_item()
	

func _generate_items():
	pass

func _scene_file_load() -> void:
	#grab_focus()
	var file_dialog = ItemSmithFileDialog.instance()
	file_dialog.add_filter("*.tscn")
	var root = get_tree().get_root()
	root.add_child(file_dialog)
	assert(file_dialog.connect("file_selected", self, "_scene_path_value_changed") == OK)
	assert(file_dialog.connect("popup_hide", self, "_on_popup_hide", [root, file_dialog]) == OK)
	if _scene_file_edit.text:
		file_dialog.current_path = str2var(_scene_file_edit.text)
	file_dialog.popup_centered()	

func _scene_path_value_changed(path_value) -> void:
	_scene_file_edit.text = path_value	

func _scene_file_clear() -> void:
	_scene_file_edit.text = ""

func _icon_file_load() -> void:
	var file_dialog = ItemSmithFileDialog.instance()
	file_dialog.add_filter("*.png")
	var root = get_tree().get_root()
	root.add_child(file_dialog)
	assert(file_dialog.connect("file_selected", self, "_icon_path_value_changed") == OK)
	assert(file_dialog.connect("popup_hide", self, "_on_popup_hide", [root, file_dialog]) == OK)
	if _icon_file_edit.text:
		file_dialog.current_path = str2var(_icon_file_edit.text)
	file_dialog.popup_centered()	
	
func _icon_path_value_changed(path_value) -> void:
	_icon_file_edit.text = path_value
	
func _icon_file_clear() -> void:
	_icon_file_edit.text = ""	

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()
	


func _on_Button_pressed():	
	_load_items()



func _on_AddPropButton_pressed():
	add_property("String","","")
	
