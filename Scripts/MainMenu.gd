extends Node2D

var plax_scroll_widths = 3
var plax_scroll_heights = 3

onready var dimensions = get_viewport_rect().size

onready var background = $MainMenuParallax
onready var vam_logo = $MainMenuVBox/LogoBox/VamLogo
onready var empire_logo = $MainMenuVBox/LogoBox/VamLogo/EmpireLogo

onready var main_menu = $MainMenuVBox
onready var options = $OptionsContainer
onready var tween = $Tween
onready var target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)
onready var orig_target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)


func _ready():
	tween_to_target_x(target)
	tween_to_target_y(target)
	options.visible = false
	main_menu.visible = true
	
func _process(delta):
	#animate_background()
	
	if Input.is_action_pressed("ui_esc"):
		#TODO: Do something smarter here, in case 'unsaved' settings
		options.visible = false
		main_menu.visible = true		
	

func tween_to_target_x(targ):
	tween.interpolate_property(background, "scroll_offset:x", background.scroll_offset.x, targ.x, 16, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func tween_to_target_y(targ):
	tween.interpolate_property(background, "scroll_offset:y", background.scroll_offset.y, targ.y, 12, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func _on_Tween_tween_completed(object, key):
	print("Target: ", target)
	print("Key: ", key)
	if key == ":scroll_offset:x":
		target.x *= -1.1
		tween_to_target_x(target)
		if abs(target.x) > abs(orig_target.x * 2):
			target.x = orig_target.x
	if key == ":scroll_offset:y":
		target.y *= -1.1
		tween_to_target_y(target)
		if abs(target.y) > abs(orig_target.y * 2):
			target.y = orig_target.y



func _on_New_pressed():
	print("Loading new Scene...")
	tween.stop_all()
	Global.goto_scene("res://World_Proto.tscn")


func _on_Options_pressed():
	main_menu.visible = false
	options.visible = true
	


func _on_mast_volume_slider_value_changed(value):
	print("Master Volume: ", value)

func _on_music_volume_slider_value_changed(value):
	print("Music Volume: ", value)


func _on_sound_effect_volume_slider_value_changed(value):
	print("Sound Effect Volume:", value)

func _on_ambience_slider_value_changed(value):
	print("Ambience Volume", value)
