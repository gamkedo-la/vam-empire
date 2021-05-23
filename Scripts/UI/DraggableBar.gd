extends Panel


var drag = false
var offset = Vector2(0,0)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if drag:
			owner.rect_global_position = get_viewport().get_mouse_position() - offset

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = event.pressed		
		offset = get_viewport().get_mouse_position() - owner.rect_global_position
