class_name EndScreen
extends Control

onready var item_box = preload("res://UI/Menu/EndMissionScreen/ItemDisplayHB.tscn")
onready var ship_scroll = $MarginContainer/MainHB/ShipInventory/ItemScrollBox
onready var master_scroll = $MarginContainer/MainHB/MasterInventory/ItemScrollBox
onready var main_tween: Tween = $MainTween
onready var tally_sound = $TallySound
onready var tally_sound_file = "res://Sounds/EndMission/item_tally.wav"
var tally_sfx:AudioStreamRandomPitch  = null


onready var return_button = $MarginContainer/MainHB/KillStats/VBoxContainer/ReturnButton

var ship_boxes = {}
var master_boxes = {}
onready var timer = Timer.new()
onready var return_timer = Timer.new()
var interval = 2
var return_timeout = 15
var current_uuid = null
var tween_scale = Vector2(0.05, 0.05)

func _ready() -> void:
	# Sfx 
	tally_sfx = AudioStreamRandomPitch.new()
	tally_sfx.audio_stream = load(tally_sound_file)
	tally_sfx.random_pitch = 1.0	
	tally_sound.stream = tally_sfx
			
	return_button.visible = false
	PlayerVars.load_save()
	Global.pause_game(true)
	populate_item_fields()
	self.visible = true
	self.add_child(timer)
	self.add_child(return_timer)
	return_timer.wait_time = return_timeout
	return_timer.connect("timeout", self, "_return_to_home_base")
	
	timer.wait_time = interval
	timer.connect("timeout", self, "_transfer_items")
	timer.start()
	
	main_tween.interpolate_property(self, "rect_rotation", self.rect_rotation, 1, 5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	main_tween.interpolate_property(self, "rect_position:x", self.rect_position.x, self.rect_position.x + 5, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	main_tween.interpolate_property(self, "rect_position:y", self.rect_position.y, self.rect_position.y - 5, 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	main_tween.interpolate_property(self, "rect_scale", self.rect_scale, self.rect_scale + tween_scale, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	main_tween.start()
	
	
	
	

func _process(_delta: float) -> void:
	if !return_timer.is_stopped():
		return_button.text = str("Return %.1f" % (return_timer.time_left))

func populate_item_fields() -> void:
	for inv_uuid in PlayerVars.ship_inventory.keys():
		var item_data = Database.itemByUuid[inv_uuid]
#		print_debug(item_data)
		var newBox: EndScreenItemBox = item_box.instance()
		var mastBox: EndScreenItemBox = item_box.instance()
		var icon_texture = load(item_data.itemIcon)
		ship_scroll.add_child(newBox)
		ship_boxes[inv_uuid] = newBox
		master_scroll.add_child(mastBox)
		master_boxes[inv_uuid] = mastBox
		newBox.initialize(icon_texture, item_data.itemName, PlayerVars.ship_inventory[inv_uuid])
		PlayerVars.increment_master_inventory(inv_uuid, 0)
		mastBox.initialize(icon_texture, item_data.itemName, PlayerVars.master_inventory[inv_uuid])
		

func _transfer_items() -> void:
	timer.stop()
	var count_speed: float
	var trans_cnt: int
	for uuid in PlayerVars.ship_inventory.keys():
		current_uuid = uuid
		count_speed = 0.1		
		tally_sound.pitch_scale = 0.3
		while PlayerVars.ship_inventory[uuid] > 0:
			if count_speed > 0.00001:
				yield(get_tree().create_timer(count_speed), "timeout")
				_transfer_item(1)
			else:
				_transfer_item(PlayerVars.ship_inventory[uuid])
			count_speed *= 0.95
			tally_sound.pitch_scale = clamp(tally_sound.pitch_scale + .01, 0.1, 5.0)
	PlayerVars.save()
	_start_home_base_countdown()
	
func _transfer_item(val) -> void:
	PlayerVars.increment_ship_inventory(current_uuid,-val)
	PlayerVars.increment_master_inventory(current_uuid,val)
	ship_boxes[current_uuid].decrement(val)
	master_boxes[current_uuid].increment(val)
	tally_sound.play()

func _start_home_base_countdown() -> void:
	return_timer.start()
	return_button.visible = true

func _stop_home_base_countdown() -> void:
	return_timer.stop()
	return_button.text = "Return to Home Base"

func _return_to_home_base() -> void:
	Global.pause_game(false)
	Global.goto_scene(Global.home_base)
	
func _on_ReturnButton_pressed() -> void:
	_return_to_home_base()

func _on_ReturnButton_focus_entered():
	_stop_home_base_countdown()

func _on_ReturnButton_mouse_entered():
	_stop_home_base_countdown()


func _on_MainTween_tween_completed(object, key):
	print_debug(key)
	if key == ":rect_rotation":
		main_tween.interpolate_property(self, "rect_rotation", self.rect_rotation, -self.rect_rotation, 5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	if key == ":rect_scale":
		tween_scale = -tween_scale
		main_tween.interpolate_property(self, "rect_scale", self.rect_scale, self.rect_scale + tween_scale, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	if key == ":rect_position:x":
		main_tween.interpolate_property(self, "rect_position:x", self.rect_position.x, -self.rect_position.x, 3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	if key == ":rect_position:y":
		main_tween.interpolate_property(self, "rect_position:y", self.rect_position.y, -self.rect_position.y, 3.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	main_tween.start()
