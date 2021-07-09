extends Node

#var normal = load("res://Cursors/normal.png")
#var overUI = load("res://Cursors/overUI.png")
#var target = load("res://Cursors/target.png")

func _ready():
	set_default()

func set_default():
	Input.set_custom_mouse_cursor(normal)

func set_over_active_ui_element():
	Input.set_custom_mouse_cursor(overUI)

func set_target():
	Input.set_custom_mouse_cursor(target)
