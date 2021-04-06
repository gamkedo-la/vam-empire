tool
extends Node2D

export (bool) var tween_togg = 0 setget tween_sprite
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var tween = $Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if Engine.editor_hint:		
		pass
	else:
		pass

func tween_sprite(_value):
	var tween = get_tree().get_root().get_node_or_null("Tween")
	if tween:
		tween.interpolate_propert(self, "position", self.position, Vector2(10,10), 2, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
