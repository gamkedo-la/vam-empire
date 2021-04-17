extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var tween = $Tween
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var random_time = rand_range(30,280)
	tween.interpolate_property(
		self, "unit_offset",
		0, 1, random_time,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT	)
	tween.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	pass
