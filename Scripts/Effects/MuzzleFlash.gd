extends Node2D

# Script to make a light go blink-blink ;)

export var start_delay = 0.0
export var off_duration = 0.5
export var min_value_inset = 0.0
export var max_value_inset = 5.0
export var min_value_glow = 0.0
export var max_value_glow = 3.0

onready var inset = $InsetLight
onready var glow = $GlowLight
onready var tween = $Tween

var is_on = false

func on():
	tween.stop_all()
	tween.interpolate_property(inset, "energy", max_value_inset, min_value_inset, off_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(glow, "energy", max_value_glow, min_value_glow, off_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	is_on = true

func off():
	inset.energy = min_value_inset
	glow.energy = min_value_glow
	is_on = false

func _on_Tween_tween_all_completed():
	if is_on:
		off()
