extends Node2D

var plax_scroll_widths = 3
var plax_scroll_heights = 3

onready var dimensions = get_viewport_rect().size

onready var background = $MainMenuParallax
onready var tween = $Tween

onready var target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)
onready var orig_target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)


func _ready():
	tween_to_target_x(target)
	tween_to_target_y(target)

func tween_to_target_x(targ):
	tween.interpolate_property(background, "scroll_offset:x", background.scroll_offset.x, targ.x, 16, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func tween_to_target_y(targ):
	tween.interpolate_property(background, "scroll_offset:y", background.scroll_offset.y, targ.y, 12, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func _on_Tween_tween_completed(_object, key):
	if key == ":scroll_offset:x":
		target.x *= -1.1
		tween_to_target_x(target)
		if abs(target.x) > abs(orig_target.x * 2):
			target.x = orig_target.x
	if key == ":scroll_offset:y":
		target.y *= -1.1
		tween_to_target_y(target)
		if abs(target.y) > abs(orig_target.y * 2):
			target.y = orig_target.y
