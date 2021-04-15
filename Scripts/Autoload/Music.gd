extends Node


onready var ambient_explo_music = $Ambient_Exploration
onready var tween = $Tween

var easein_time = 4

func _ready():
	# Ease the music in to avoid 'startling' the player on game load
	#Option #1 For Easing options check out http://easings.net
	tween.interpolate_property(
		ambient_explo_music,
		"volume_db",
		ambient_explo_music.volume_db, 0, easein_time,Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.start()
	
	# Option #2 (uncomment and comment above block)
#	ambient_explo_music.volume_db = 0
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
