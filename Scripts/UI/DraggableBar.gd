extends Panel

var parent = null
var drag = false
var offset = Vector2(0,0)

func _ready():
	parent = get_parent()

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if parent && drag:
			parent.rect_global_position = get_viewport().get_mouse_position() - offset

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = event.pressed		
		offset = get_viewport().get_mouse_position() - parent.rect_global_position
