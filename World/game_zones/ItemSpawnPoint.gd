extends Position2D

const Item = preload("res://Database/Item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var test_mat = Database.table.Items[0]
	
	# instantiate Item based on that data
	var item = Item.instance()
	var root = get_tree().get_root()
	call_deferred("add_child", item)
	item.global_position = global_position
	
