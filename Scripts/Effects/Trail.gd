extends Line2D

export var amount = 50
var point

func _ready():
	set_as_toplevel(true)

func _physics_process(_delta):
	point = get_parent().global_position
	add_point(point)
	if points.size() > amount:
		remove_point(0)
