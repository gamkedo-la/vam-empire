extends Area2D
# signal required to be a mininmap object. Emit this signal before freeing this object
signal removed


onready var tween = $Tween
onready var beacon_sign = $BeaconSign
onready var beacon_light = $BeaconSign/BeaconLight
onready var upper_pos = $UpperPos_Hover
onready var lower_pos = $LowerPos_Hover
onready var indicator = $Indicator
onready var timer_text = $BeaconSign/TimerBox/TimerText
onready var return_timer = $ReturnTimer
var return_time = 10
var remaining_time = return_time
var bounce_speed = 1
var small_ind = Vector2(.5, .5)
var big_ind = Vector2(1.5,1.5)
var going_up = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("always_on_map")
	tween.interpolate_property(beacon_sign, "position", beacon_sign.position, upper_pos.position, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.interpolate_property(indicator, "scale", indicator.scale, small_ind, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.interpolate_property(beacon_light, "energy", beacon_light.energy, 1, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()

func _process(_delta):
	if !return_timer.is_stopped():
		timer_text.text = str("%.1f" % (return_timer.time_left))
	Global.home_beacon_position = position

func begin_return_countdown():
	return_timer.start(return_time)
	timer_text.visible = true

func stop_return_countdown():
	return_timer.stop()
	timer_text.visible = false	

func _on_Tween_tween_all_completed():
	if going_up:
		going_up = false
		tween.interpolate_property(beacon_sign, "position", beacon_sign.position, lower_pos.position, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.interpolate_property(indicator, "scale", indicator.scale, big_ind, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.interpolate_property(beacon_light, "energy", beacon_light.energy, 3, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.start()
	else:
		going_up = true
		tween.interpolate_property(beacon_sign, "position", beacon_sign.position, upper_pos.position, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.interpolate_property(indicator, "scale", indicator.scale, small_ind, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.interpolate_property(beacon_light, "energy", beacon_light.energy, 1, bounce_speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		tween.start()

func _on_ReturnTimer_timeout():
#	PlayerVars.transfer_ship_to_base()
	self.visible = false
	PlayerVars.emit_signal("mission_complete")
#	Global.goto_scene(home_base)	

func _on_ReturnHomeBeacon_area_entered(_area):
	#var ar_parent = _area.get_parent()
	#print_debug(ar_parent)
	begin_return_countdown()

func _on_ReturnHomeBeacon_area_exited(_area):
	stop_return_countdown()
