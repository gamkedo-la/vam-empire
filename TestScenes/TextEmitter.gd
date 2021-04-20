extends Node2D

var emitter_label = preload("res://TestScenes/TestEmitterLabel.tscn")
onready var timer = $Timer

var new_txt

func _ready():
	timer.wait_time = 2
	timer.start()

func _on_Timer_timeout():
	var new_txt = emitter_label.instance()
	add_child(new_txt)
