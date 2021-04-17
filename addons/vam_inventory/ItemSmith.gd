tool
extends Control

var newItem = preload("res://addons/vam_inventory/ItemSmithItem.tscn")
var _editor: EditorPlugin


onready var _items_grid = $BG/MainVB/MainHB/ItemsVB/Items as GridContainer
onready var _load_db = $BG/MainVB/MainHB/ButtonVB/LoadDB as Button
onready var _clear = $BG/MainVB/MainHB/ButtonVB/Clear as Button


export (bool) var regenerate = false setget _regen

onready var itemsNode
var cur_scene
var Itemdb



func _ready() -> void:
#	if get_tree().get_root().has_node("Database"):
#		print("Got a Database")
	pass

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	
func _init_connections() -> void:
	if not _load_db.is_connected("pressed", self, "_load_items"):
		assert(_load_db.connect("pressed", self, "_load_items") == OK)
	if not _clear.is_connected("pressed", self, "_clear"):
		assert(_clear.connect("pressed", self, "_clear") == OK)

func _regen(val):
	regenerate = !regenerate	
	_load_items()
	
func _load_items():
	_clear()
	var Items = Database.table.Items
	print(_items_grid)
#	if _items_grid.get_child_count() > 0:		
#		for grid_item in _items_grid.get_children():
#			_items_grid.remove_child(grid_item)
	for item in Items:
		print("item: ", item)
		print(Items[item])
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

func _clear():
	for item in _items_grid.get_children():
		_items_grid.remove_child(item)

func _generate_items():
	pass


func _on_Button_pressed():	
	_load_items()

