extends DirectionalLight

func _ready() -> void:
	var newTween = Tween.new()
	add_child(newTween)
	newTween.interpolate_property(self, "rotation_degrees:y", self.rotation_degrees.y, self.rotation_degrees.y + 360, 90, Tween.TRANS_SINE, Tween.EASE_IN)
	newTween.repeat = true
	newTween.start()
	print_debug(newTween, "newTween started")
