extends TextureRect

var current_item = null
var current_item_uuid = null
var current_item_count : int = 0 setget _set_item_count


func _set_item_count(val):
	current_item_count = val
	if current_item:
		current_item.set_count(val)

func remove_item():
	current_item = null
	current_item_uuid = null
	current_item_count = 0
	for child in get_children():
		child.queue_free()

	
