extends Node2D

var plax_scroll_widths = 1.5
var plax_scroll_heights = 1.5

onready var dimensions = get_viewport_rect().size

onready var background = $MainMenuParallax
onready var tween = $Tween
onready var target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)


func _ready():
	animate_background()
	
func _process(delta):
	#animate_background()
	pass
	
func animate_background():
	print("background.scroll_offset: ", background.scroll_offset)
	#if we've moved left or right far enough, set our target back to the other direction
	if background.scroll_offset.x > (dimensions.x * (plax_scroll_widths)) - 200:		
		target.x = dimensions.x* -plax_scroll_widths * 1.1
	elif background.scroll_offset.x < (-dimensions.x * (plax_scroll_widths)) + 200:
		target.x = dimensions.x * plax_scroll_widths * 1.1

	#if we've moved up or down enough, set our target to change direction
	if background.scroll_offset.y > (dimensions.y * (plax_scroll_heights)) - 200:		
		target.y = dimensions.y * -plax_scroll_heights * 1.1
	elif background.scroll_offset.y < (-dimensions.y * (plax_scroll_heights)) + 200:
		target.y = dimensions.y * plax_scroll_heights * 1.1
	
	print("Target before: ", target)
	if target.x != 0:
		tween_to_target_x(target)
		target.x = 0
	if target.y != 0:
		tween_to_target_y(target)
		target.y = 0
	print("Target after: ", target)


func tween_to_target_x(target):
	tween.interpolate_property(background, "scroll_offset:x", background.scroll_offset.x, target.x, 15, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	tween.start()

func tween_to_target_y(target):
	tween.interpolate_property(background, "scroll_offset:y", background.scroll_offset.y, target.y, 10, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	tween.start()

func _on_Tween_tween_completed(object, key):
	animate_background()
