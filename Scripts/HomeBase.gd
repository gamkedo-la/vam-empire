extends Node2D

#Script to manage the Home Base scene where the player can:
#	- Upgrade weapons and parts
#	- Purchase or Sell Ships
#	- Craft new weapons or parts with materials gathered while mining
#	- Manage the information they've discovered about the world (zones, V.A.M. etc...)

onready var starfield = $ParallaxBackground2
onready var base_overlay = $CanvasLayer/BaseOverlay
onready var player_ship = $PlayerLeaveAnimation/PlayerPlaceholder
onready var takeoff_tween = $PlayerLeaveAnimation/TakeoffTween
onready var rear_pos = $PlayerLeaveAnimation/RearTakeoff
onready var front_pos = $PlayerLeaveAnimation/FrontTakeoff
var backing_up = true
var leaving_to = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	starfield.scroll_offset.x += 10
	starfield.scroll_offset.y += 3
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func take_off():
	if backing_up:
		takeoff_tween.interpolate_property(player_ship, "position", player_ship.position, rear_pos.position, 3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	else: 
		takeoff_tween.interpolate_property(player_ship, "position", player_ship.position, front_pos.position, 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	takeoff_tween.start()
	

func _on_GoMiningEasy_pressed():
	leaving_to = "res://World/game_zones/EasyZone_001.tscn"
	take_off()
	#Global.goto_scene("res://World/game_zones/EasyZone_001.tscn")

func _on_GoWorldProto_pressed():	
	leaving_to = "res://World_Proto.tscn"
	take_off()
	#Global.goto_scene("res://World_Proto.tscn")
	


func _on_TakeoffTween_tween_completed(object, key):
	if object == player_ship && backing_up:
		backing_up = false
		base_overlay.visible = false
		take_off()
	else:
		if leaving_to:
			Global.goto_scene(leaving_to)
	
