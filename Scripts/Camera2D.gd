extends Camera2D

onready var player = get_node_or_null("/root/World/Player")
onready var tween = $Tween

func _process(_delta):
	
	tween.interpolate_property(self, "position", position, player.position, .5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	
	tween.start()

