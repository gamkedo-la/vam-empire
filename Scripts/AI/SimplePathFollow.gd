extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	tween.interpolate_property(
		self, "unit_offset",
		0, 1, 120,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT	)
	tween.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
