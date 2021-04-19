tool
extends Control

var newItem = preload("res://addons/vam_inventory/ItemSmithItem.tscn")
var ItemSmithFileDialog = preload("res://addons/vam_inventory/ItemSmithFileDialog.tscn")
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


export (bool) var regenerate = false setget _regen

onready var itemsNode
var cur_scene
var Itemdb



func _ready() -> void:
#	if get_tree().get_root().has_node("Database"):
#		print("Got a Database")
	Database.connect("item_selected", self, "set_selected_item")
	

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()

func set_selected_item(item):
	print_debug(item," is selected.")
	
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

func _regen(val):
	regenerate = !regenerate	
	_load_items()
	
func _load_items() -> void:
	_clear()
	var Items = Database.table.Items
#	print(_items_grid)
#	if _items_grid.get_child_count() > 0:		
#		for grid_item in _items_grid.get_children():
#			_items_grid.remove_child(grid_item)
	for item in Items:
#		print("item: ", item)
#		print(Items[item])
		var itemName = Items[item].itemName
		var itemType = Items[item].itemType
		var asteroids = Items[item].asteroids
		var itemTexture = Items[item].itemTexture
#		print(itemName," ", itemType," ", asteroids," ",itemTexture)
#		print(_items_grid)
#		print("Testing how up to date the plugin stays")
		var treeItem = newItem.instance()
		treeItem.itemName = itemName
		treeItem.itemType = itemType
		treeItem.asteroids = asteroids
		treeItem.itemTexture = load(itemTexture)
		#get_tree().get_node_or_null("CanvasLayer").get_node_or_null("BG").get_node_or_null("Items").add_child(treeItem)		
		treeItem.texture = load(itemTexture)
		treeItem.set_editor(_editor)
		if _items_grid:
			_items_grid.add_child(treeItem)
		#print(treeItem.itemName)

func _clear() -> void:
	if _items_grid && _items_grid.get_child_count() > 0:
		for item in _items_grid.get_children():
			_items_grid.remove_child(item)

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

