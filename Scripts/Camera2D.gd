extends Camera2D

onready var player = get_node_or_null("/root/World/Player")
onready var tween = $Tween
onready var rcs_left = $RCSLeft
onready var rcs_right = $RCSRight
onready var rcs_front = $RCSFront
onready var rock_coll_sfx = $RockCollisionSfx

onready var shield_pivot = $ShieldChargePivot
onready var shield_tween = $ShieldChargePivot/ShieldTween
onready var shield_sfx = $ShieldChargePivot/ShieldChargeSfx

var rcs_left_timer
var rcs_right_timer
var rcs_front_timer

func _ready():
	
	var _connect = Effects.connect("RCSLeft", self, "_rcs_left")
	_connect = Effects.connect("RCSRight", self, "_rcs_right")
	_connect = Effects.connect("RCSFront", self, "_rcs_front")
	_connect = Effects.connect("PlayerRockCollision", self, "_player_rock_collision")
	_connect = Effects.connect("ChargeShield", self, "_charge_shield")
	shield_tween.interpolate_property(shield_pivot, "rotation_degrees", shield_pivot.rotation_degrees, 360, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shield_tween.start()

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

func _player_rock_collision(location: Vector2, strength: float) -> void:	
	rock_coll_sfx.global_position = location
	rock_coll_sfx.volume_db = linear2db(clamp(strength, 0.1, 1.2))	
	rock_coll_sfx.play()	

func _charge_shield(toggle: bool) -> void:
	if toggle:
		if !shield_sfx.playing:
			shield_sfx.play()
	else:
		if shield_sfx.playing:
			shield_sfx.stop()
	
		
	
