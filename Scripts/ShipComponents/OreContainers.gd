extends Node2D


var containers = []
onready var tween = Tween.new()
onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	add_child(tween)
	for container in self.get_children():
		if container is Sprite:
			containers.append(container)
			var anim_len = rng.randi_range(5, 30)
			tween.interpolate_property(container, "frame", container.frame, 8, anim_len, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			tween.repeat = true
			tween.start()
	
	

	
