extends Node2D

var plax_scroll_widths = 3
var plax_scroll_heights = 3

onready var dimensions = get_viewport_rect().size

onready var background = $MenuCanvas/MainMenuParallax
onready var vam_logo = $MenuCanvas/MainMenuVBox/LogoBox/VamLogo
onready var empire_logo = $MenuCanvas/MainMenuVBox/LogoBox/VamLogo/EmpireLogo
onready var ani_player = $MenuCanvas/AnimationPlayer

onready var main_menu = $MenuCanvas/MainMenuVBox
onready var new_button = $MenuCanvas/MainMenuVBox/InteractVB/NewHB/New
onready var options = $MenuCanvas/OptionsContainer
onready var tween = $MenuCanvas/Tween

onready var tod_toggle = $MenuCanvas/OptionsContainer/VBoxContainer/TabContainer/Graphics/VBoxContainer/HBoxContainer/DayToggle

onready var music = $AudioStreamPlayer

onready var target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)
onready var orig_target = Vector2(plax_scroll_widths*1.1*dimensions.x, plax_scroll_heights*1.1*dimensions.y)

onready var mast_vol_slider = $MenuCanvas/OptionsContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer/mast_volume_slider
onready var music_vol_slider =  $MenuCanvas/OptionsContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer2/music_volume_slider
onready var sfx_vol_slider = $MenuCanvas/OptionsContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer3/sound_effect_volume_slider


func _ready():
	tween_to_target_x(target)
	tween_to_target_y(target)
	options.visible = false
	main_menu.visible = true
	Global.menu_open = true
	tod_toggle.pressed = Global.day
	
	#TODO: This is just a quick hack to get some placeholder menu music. Music should be handled in a persistent way to allow smooth transitions
	ani_player.play("Empire_Loop")
	
	update_volume()
	
	
func _process(delta):
	#animate_background()
	
	if Input.is_action_just_pressed("ui_esc"):
		#TODO: Do something smarter here, in case 'unsaved' settings
		if options.visible:
			options.visible = false
			main_menu.visible = true
		#TODO: (fix) There is no way this is the best way to handle pause/unpause
		elif get_tree().paused == true:	
			print("Unpausing")
			Global._display_menu()

			
	

func tween_to_target_x(targ):
	tween.interpolate_property(background, "scroll_offset:x", background.scroll_offset.x, targ.x, 16, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()

func tween_to_target_y(targ):
	tween.interpolate_property(background, "scroll_offset:y", background.scroll_offset.y, targ.y, 12, Tween.TRANS_BACK, Tween.EASE_IN_OUT)	
	tween.start()
	
func update_volume():
	mast_vol_slider.value = UserSettings.master_volume
	music_vol_slider.value = UserSettings.music_volume
	sfx_vol_slider.value = UserSettings.effects_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(UserSettings.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(UserSettings.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(UserSettings.effects_volume))
	
	

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
	Global.menu_open = true

func _disable_new():
	new_button.disabled = true

func _on_Options_pressed():
	main_menu.visible = false
	options.visible = true
	


func _on_mast_volume_slider_value_changed(value):
	print("Master Volume: ", value)
	UserSettings.master_volume = value
	update_volume()

func _on_music_volume_slider_value_changed(value):
	print("Music Volume: ", value)
	UserSettings.music_volume = value
	update_volume()
	print("Actual volume db: ", music.volume_db)


func _on_sound_effect_volume_slider_value_changed(value):
	print("Sound Effect Volume:", value)
	UserSettings.effects_volume = value
	update_volume()

func _on_ambience_slider_value_changed(value):
	print("Ambience Volume", value)


func _on_DayToggle_toggled(button_pressed):
	if button_pressed:
		Global.day = true
	else:
		Global.day = false
	


func _on_AudioStreamPlayer_finished():
	music.play()
	
