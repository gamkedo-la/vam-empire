tool
extends HBoxContainer

onready var _prop_name = $PropName as LineEdit
onready var _prop_val = $PropVal as LineEdit
onready var _prop_del = $PropDelete as Button

var _editor

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()	

func set_prop(property, value):
	_prop_name.text = property
	_prop_val.text = value

func _init_connections():
	if not _prop_del.is_connected("pressed", self, "_on_PropDelete_pressed"):
		assert(_prop_del.connect("pressed", self, "_on_PropDelete_pressed") == OK)


func _on_PropDelete_pressed():
	# TODO: emit this property is deleted for the current selected property
	queue_free()
