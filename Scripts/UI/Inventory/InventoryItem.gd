extends TextureButton

var current_stack_size: int = 0
var current_item_count : int = 0 setget set_count
var current_item_uuid = null
onready var count_label = $ItemCountLabel

func set_count(val):
	current_item_count = val
	count_label.text = str(val)
