extends Node

signal RCSLeft
signal RCSRight
signal RCSFront

var floating_text = load("res://UI/Effects/FloatingText.tscn")

func show_dmg_text(position, amount):
	   _show_floating_text(position, amount, Color(1,0.5,0.5), 1)

func show_player_dmg_text(position, amount):
	   _show_floating_text(position, amount, Color(1,0,0), 1)

func show_healing_text(position, amount):
	   _show_floating_text(position, amount, Color(0,1,0), 1)

func _show_floating_text(position, text, color, scale):
	var new_floating_text = floating_text.instance()
	var root_node = get_tree().get_root()
	new_floating_text.set_text(text, color, scale) 
	root_node.add_child(new_floating_text)
	new_floating_text.global_position = position
