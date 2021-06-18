extends LightOccluder2D

onready var tween = Tween.new()
onready var timer = Timer.new()

func _ready() -> void:
	add_child(tween)
	add_child(timer)
	timer.wait_time = rand_range(0, 2)
	timer.connect("timeout", self, "_start_tween")
	timer.start()

func _start_tween() -> void:
	timer.stop()
	timer.queue_free()
	tween.interpolate_property(self, "rotation_degrees", 0, 360, 5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.repeat = true
	tween.start()
	

