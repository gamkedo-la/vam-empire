tool
extends HBoxContainer

onready var _prop_type = $PropType as OptionButton
onready var _prop_name = $PropName as LineEdit
onready var _prop_val = $PropVal as LineEdit
onready var _prop_del = $PropDelete as Button

var _editor

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_populate_type()
	_init_connections()	

func set_prop(type, property, value):
	match type:
		"String":
			_prop_type.select(0)
			_prop_val.text = str(value)
		"int":
			_prop_type.select(1)
			_prop_val.text = var2str(int(value))
		"float":
			_prop_type.select(2)
			_prop_val.text = var2str(float(value))
		"bool":
			_prop_type.select(3)
			_prop_val.text = var2str(bool(value))
	_prop_name.text = property	

func get_prop() -> Dictionary:
	var prop_dict : Dictionary
	prop_dict.type = _prop_type.get_item_text(_prop_type.get_selected_id())
	prop_dict.name = _prop_name.text
	prop_dict.value = str(_prop_val.text)
	return prop_dict

func _init_connections():
	if not _prop_del.is_connected("pressed", self, "_on_PropDelete_pressed"):
		assert(_prop_del.connect("pressed", self, "_on_PropDelete_pressed") == OK)
	if not _prop_type.is_connected("item_selected", self, "_on_PropType_item_selected"):
		assert(_prop_type.connect("item_selected", self, "_on_PropType_item_selected") == OK)


func _on_PropDelete_pressed():
	# TODO: emit this property is deleted for the current selected property
	queue_free()


func _populate_type():
	_prop_type.add_item("String")
	_prop_type.add_item("int")
	_prop_type.add_item("float")
	_prop_type.add_item("bool")


func _on_PropType_item_selected(index):
	print("Index: ", index)
	pass # Replace with function body.
