extends Camera2D

onready var player = get_node_or_null("/root/World/Player")
onready var tween = $Tween
onready var rcs_left = $RCSLeft
onready var rcs_right = $RCSRight
onready var rcs_front = $RCSFront
var rcs_left_timer
var rcs_right_timer
var rcs_front_timer


func _ready():
	
	Effects.connect("RCSLeft", self, "_rcs_left")
	Effects.connect("RCSRight", self, "_rcs_right")
	Effects.connect("RCSFront", self, "_rcs_front")
	

func _physics_process(_delta):
	position = player.position


# Spatial Ship Sounds
func _rcs_left(toggle: bool, strength: float) -> void:
	if toggle:
		rcs_left.volume_db = linear2db(clamp(strength, 0.0, 1.0))
		if !rcs_left.playing:
			rcs_left.play()
	else:
		rcs_left.stop()
	pass

func _rcs_right(toggle: bool, strength: float) -> void:
	if toggle:
		rcs_right.volume_db = linear2db(clamp(strength, 0.0, 1.0))
		if !rcs_right.playing:
			rcs_right.play()
	else:
		rcs_right.stop()
	pass

func _rcs_front(toggle: bool, strength: float) -> void:
	if toggle:
		rcs_front.volume_db = linear2db(clamp(strength, 0.0, 1.0))
		if !rcs_front.playing:
			rcs_front.play()
	else:
		rcs_front.stop()
	pass
	
	
