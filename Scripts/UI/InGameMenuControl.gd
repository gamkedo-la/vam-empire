extends Control

var parallax = null

func _ready():
	parallax = get_node_or_null("/root/MenuCanvas/MainMenuParallax")
	if parallax:
		for Layer in parallax.get_children():
			Layer.visible = false
