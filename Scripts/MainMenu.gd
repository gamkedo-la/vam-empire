extends Node2D

var plax_scroll_widths = 1.5
var plax_scroll_heights = 1.5

onready var dimensions = get_viewport_rect().size

onready var background = $MainMenuParallax
onready var tween = $Tween
onready var target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)


func _ready():
	tween_to_target_x(target)
	tween_to_target_y(target)
	
func _process(delta):
	#animate_background()
	pass
	



func tween_to_target_x(target):
	tween.interpolate_property(background, "scroll_offset:x", background.scroll_offset.x, target.x, 16, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func tween_to_target_y(target):
	tween.interpolate_property(background, "scroll_offset:y", background.scroll_offset.y, target.y, 12, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func _on_Tween_tween_completed(object, key):
	print("Target: ", target)
	print("Key: ", key)
	if key == ":scroll_offset:x":
		target.x *= -1
		tween_to_target_x(target)
	if key == ":scroll_offset:y":
		target.y *= -1
		tween_to_target_y(target)

