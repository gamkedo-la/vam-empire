class_name EndScreenItemBox
extends HBoxContainer

onready var item_icon = $ItemIcon
onready var name_label = $ItemName
onready var count_label = $ItemCount

var item_name: String
var item_count: int = 0


func _ready():
	pass

func initialize(_icon: Texture, _name: String, _count: int):
	if item_icon:
		item_icon.texture = _icon
	item_name = _name
	if name_label:
		name_label.text = str(item_name)
	item_count = _count
	if count_label:
		count_label.text = str(item_count)
	
func increment(val):
	item_count += val
	_update()

func decrement(val):
	item_count -= val
	_update()
	
func _update():
	count_label.text = str(item_count)
