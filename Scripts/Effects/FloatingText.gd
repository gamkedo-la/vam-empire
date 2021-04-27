extends Node

func set_text(text, color, scale):
	var label = get_node("Node2D/Label")
	var container = get_node("Node2D")
	
	label.modulate = color
	label.text = str(text)
	container.scale.x = scale
	container.scale.y = scale

func _on_Timer_timeout():
	queue_free()
