extends CanvasModulate


var tod = false
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	tod = Global.day
	adjust_for_tod()

func _process(_delta):
	if tod != Global.day:
		print("Toggling ToD:", tod, Global.day)
		tod = Global.day
		adjust_for_tod()

func adjust_for_tod():
	var cur_color = self.color
	if tod:
		print("It's daytime!")
		tween.interpolate_property(self, "color", cur_color, Color8(186,189,159,255), 20, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		#color = Color8(186, 189, 159, 255)
	else:
		tween.interpolate_property(self, "color", cur_color, Color8(33, 33, 33,255), 20, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		#color = Color8(33, 33, 33, 255)
