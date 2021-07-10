extends Node2D

#Script to manage the Home Base scene where the player can:
#	- Upgrade weapons and parts
#	- Purchase or Sell Ships
#	- Craft new weapons or parts with materials gathered while mining
#	- Manage the information they've discovered about the world (zones, V.A.M. etc...)

onready var starfield = $ParallaxBackground2
onready var base_overlay = $CanvasLayer/BaseOverlay
onready var airlock_overlay = $CanvasLayer/BaseOverlay/VBoxContainer
onready var animator = $CanvasLayer/BaseOverlay/VBoxContainer/AnimationPlayer
onready var player_ship = $PlayerLeaveAnimation/PlayerPlaceholder
onready var takeoff_tween = $PlayerLeaveAnimation/TakeoffTween
onready var rear_pos = $PlayerLeaveAnimation/RearTakeoff
onready var front_pos = $PlayerLeaveAnimation/FrontTakeoff

onready var camera_front: Position2D= $FrontBase
onready var camera_rear: Position2D = $RearBase

onready var mission_board = $CanvasLayer/MissionBoard
onready var merchant_menu = $CanvasLayer/MerchantMenu

onready var embark_button: Button = $CanvasLayer/BaseOverlay/BaseBottomMenu/Buttons/Embark

onready var base_camera = $Camera2D

onready var port_light = $SceneLighting/AirLock/PortLight
onready var starboard_light = $SceneLighting/AirLock/StarboardLight
onready var lighting_tween = $SceneLighting/LightingTween

onready var cam_tween = $CamTween

onready var transition = $Transition

var glow_up = 4
var glow_down = 0.5
var glow_time = 2

var backing_up = true
var leaving_to = null

func _ready():
	start_light_tweens()
	Global.game_live = false
	load_player_sprite()

func _process(_delta):
	starfield.scroll_offset.x += 10
	starfield.scroll_offset.y += 3
	
func start_light_tweens():
	lighting_tween.interpolate_property(port_light, "texture_scale", port_light.texture_scale, glow_up, glow_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	lighting_tween.interpolate_property(starboard_light, "texture_scale", starboard_light.texture_scale, glow_up, glow_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	lighting_tween.start()

func load_player_sprite() -> void:
	var newShip = Global.ship_hangar[PlayerVars.player.current_ship_class][PlayerVars.player.current_ship_idx]
#	player_node.pilot_ship_from_pack(newShip[0].duplicate())
	if newShip[0].get_node_or_null("ShipSprite"):
		player_ship.texture = newShip[0].get_sprite()
	
func take_off():
	if backing_up:
		takeoff_tween.interpolate_property(player_ship, "position", player_ship.position, rear_pos.position, 3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		animator.play("Start")
	else: 
		takeoff_tween.interpolate_property(player_ship, "position", player_ship.position, front_pos.position, 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	takeoff_tween.start()
	
func _hide_airlock_overlay() -> void:
	airlock_overlay.visible = false
	embark_button.visible = true
	
func _show_airlock_overlay() -> void:
	airlock_overlay.visible = true
	embark_button.visible = false

func _hide_menu_overlays() -> void:
	mission_board.visible = false
	merchant_menu.visible = false

func _show_mission_overlay() -> void:
	mission_board.visible = true

func _show_merchant_overlay() -> void:
	merchant_menu.reset()
	merchant_menu.visible = true

func _camera_pan(loc:Position2D) -> void:
	cam_tween.interpolate_property(base_camera, "position", base_camera.position, loc.position, 3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	cam_tween.start()
	
	

func _on_GoMiningEasy_pressed():
	leaving_to = "res://World/game_zones/EasyZone_001.tscn"
	take_off()
	#Global.goto_scene("res://World/game_zones/EasyZone_001.tscn")

func _on_GoWorldProto_pressed():	
	leaving_to = "res://World/game_zones/TAZ_ProtoLayout.tscn"
	take_off()
	#Global.goto_scene("res://World_Proto.tscn")
func _on_GoMiningMed_pressed():
	leaving_to = "res://World/game_zones/EasyZone_002.tscn"
	take_off()

func _on_GoFinalWorld_pressed():
	leaving_to = "res://World/game_zones/WorldZone_001.tscn"
	take_off()
	

func _on_TakeoffTween_tween_completed(object, _key):
	if object == player_ship && backing_up:
		backing_up = false		
		take_off()
	else:
		transition.transition_out()

func _on_LightingTween_tween_completed(object, _key):
	if object.texture_scale - glow_down < 1:
		lighting_tween.interpolate_property(object, "texture_scale", object.texture_scale, glow_up, glow_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	else:
		lighting_tween.interpolate_property(object, "texture_scale", object.texture_scale, glow_down, glow_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	lighting_tween.start()


func _on_Transition_can_exit():
	if leaving_to:
		Global.goto_scene(leaving_to)

func _on_Trello_pressed():
	var _open = OS.shell_open("https://trello.com/b/XcQmS3nu/vam-empire")

func _on_README_pressed():
	var _open = OS.shell_open("https://github.com/gamkedo-la/vam-empire#vam-empire-game-info")


func _on_Missions_pressed():
	_hide_menu_overlays()
	_hide_airlock_overlay()
	_show_mission_overlay()
#	_camera_pan(camera_rear)

func _on_Embark_pressed():
	_hide_menu_overlays()
	_show_airlock_overlay()
#	_camera_pan(camera_front)

func _on_Merchant_pressed():
	_hide_menu_overlays()
	_hide_airlock_overlay()
	_show_merchant_overlay()
#	_camera_pan(camera_rear)



