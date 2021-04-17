extends Node2D

# Script to make a light go blink-blink ;)

export var index = 1
export var start_delay = 0.3
export var repeat_delay = 4.0
export var on_duration = 0.2
export var off_duration = 2.0
export var min_value_inset = 1.0
export var max_value_inset = 2.0
export var min_value_glow = 0.5
export var max_value_glow = 1.25

onready var inset = $InsetLight
onready var glow = $GlowLight
onready var tween = $Tween

var is_on = false

func _ready():
	inset.energy = min_value_inset
	glow.energy = min_value_glow
	tween.interpolate_property(inset, "energy", min_value_inset, max_value_inset, on_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, start_delay * index)
	tween.interpolate_property(glow, "energy", min_value_glow, max_value_glow, on_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, start_delay * index)
	tween.start()
	is_on = true

func on():
	tween.interpolate_property(inset, "energy", min_value_inset, max_value_inset, on_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, repeat_delay)
	tween.interpolate_property(glow, "energy", min_value_glow, max_value_glow, on_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, repeat_delay)
	tween.start()
	is_on = true

func off():
	tween.interpolate_property(inset, "energy", max_value_inset, min_value_inset, off_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(glow, "energy", max_value_glow, min_value_glow, off_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	is_on = false

func _on_Tween_tween_all_completed():
	if is_on:
		off()
	else:
		on()
