extends Camera2D

onready var tween = $Tween
onready var plax = $ParallaxBackground2

func _ready():
	tween.interpolate_property(plax,"scroll_offset",
								plax.scroll_offset, Vector2(100000,100000), 5,
								Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	tween.start()




func _on_Tween_tween_completed(object, key):
	print("key:", key)
	if key == ":scroll_offset":
		tween.interpolate_property(plax,"scroll_offset",
								plax.scroll_offset, -plax.scroll_offset, 5,
								Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
