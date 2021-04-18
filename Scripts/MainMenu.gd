extends Node2D

onready var vam_logo = $MenuCanvas/Viz/MainMenuVBox/LogoBox/VamLogo
onready var empire_logo = $MenuCanvas/Viz/MainMenuVBox/LogoBox/VamLogo/EmpireLogo
onready var ani_player = $MenuCanvas/Viz/AnimationPlayer

onready var main_menu = $MenuCanvas/Viz/MainMenuVBox
onready var new_button = $MenuCanvas/Viz/MainMenuVBox/InteractVB/NewHB/New
onready var load_button = $MenuCanvas/Viz/MainMenuVBox/InteractVB/LoadHB2/Load
onready var load_accept_popup = $MenuCanvas/Viz/LoadAcceptDialog
onready var options = $MenuCanvas/Viz/OptionsContainer

# New Player Popup
onready var name_popup = $MenuCanvas/Viz/NewPlayerPop
onready var name_entry = $MenuCanvas/Viz/NewPlayerPop/NewPlayerVB/EntryHB/PlayerNameEdit
onready var name_start_button = $MenuCanvas/Viz/NewPlayerPop/NewPlayerVB/StartHB/PNameStartButton

# Sound Panel 
onready var mast_vol_slider = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer/mast_volume_slider
onready var music_vol_slider =  $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer2/music_volume_slider
onready var sfx_vol_slider = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer3/sound_effect_volume_slider

# HUD Panel
onready var mast_hud_opac_slider = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/HUD/VBoxContainer/MastHUDOpacHBox/hud_opacity_slider
onready var status_bars_opac_slider = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/HUD/VBoxContainer/StatusBarsOpacHBox/status_bars_opac_slider
onready var mini_map_opac_slider = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/HUD/VBoxContainer/MiniMapOpacHBox/mini_map_opac_slider
onready var mini_map_style_option = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/HUD/VBoxContainer/MiniMapStyleHBox/mini_map_style_optionbutton

onready var menu_viz = $MenuCanvas/Viz
var start_menu = false

func _ready():
#	options.visible = false
#	main_menu.visible = true
#	menu_open = true
	if get_parent().name == "StartMenu":
		self.visible = true
		start_menu = true
	else:
		menu_viz.visible = false
		start_menu = false
				
	if PlayerVars.save_exists():
		load_button.disabled = false
	else:
		load_button.disabled = true
	#TODO: This is just a quick hack to get some placeholder menu music. Music should be handled in a persistent way to allow smooth transitions
	ani_player.play("Empire_Loop")
	
	update_ui_settings()
	update_volume()
	
	
func _process(_delta):
	if !start_menu:
		if Input.is_action_just_pressed("ui_esc"):
			if PlayerVars.get_target():
				PlayerVars.set_target(null)
			elif menu_viz.visible && !options.visible:
				menu_viz.visible = false
				main_menu.visible = false
				Global.pause_game(false)
			elif options.visible:
				UserSettings.save()
				options.visible = false
				main_menu.visible = true
			else:
				menu_viz.visible = true
				main_menu.visible = true
				options.visible = false
				Global.pause_game(true)
	else:
		if Input.is_action_just_pressed("ui_esc"):
			if options.visible:
				UserSettings.save()
				options.visible = false
			
			
		

func close_options():
		if options.visible:
			UserSettings.save()
			options.visible = false
			main_menu.visible = true		
		elif get_tree().paused == true:
			UserSettings.save()
			

func update_settings():
	# Used to pick up fresh settings from UserSettings, like in instances where they've been set back to defaults
	update_volume()
	update_ui_settings()

func update_volume():
	mast_vol_slider.value = UserSettings.current.sound.master_volume
	music_vol_slider.value = UserSettings.current.sound.music_volume
	sfx_vol_slider.value = UserSettings.current.sound.effects_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(UserSettings.current.sound.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(UserSettings.current.sound.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(UserSettings.current.sound.effects_volume))

func update_ui_settings():
	mast_hud_opac_slider.value = UserSettings.current.ui.master_hud_opacity
	status_bars_opac_slider.value = UserSettings.current.ui.shipHUD_opacity
	mini_map_opac_slider.value = UserSettings.current.ui.mini_map_grid_opacity
	if UserSettings.current.ui.mini_map_style:
		mini_map_style_option.selected = UserSettings.current.ui.mini_map_style
	for textOpt in mini_map_style_option.get_item_count():
		UserSettings.mini_map_textures.push_back(mini_map_style_option.get_item_icon(textOpt))
	UserSettings.refresh_ui()
	
	
func load_into_homebase():
	Global.goto_scene("res://World/game_zones/home_base.tscn")	

func _on_New_pressed():
	#print("Loading new Scene...")
	name_popup.popup()

func _disable_new():
	new_button.disabled = true

func _on_Options_pressed():
	main_menu.visible = false
	options.visible = true
	


func _on_mast_volume_slider_value_changed(value):
	print("Master Volume: ", value)
	UserSettings.current.sound.master_volume = value
	update_volume()

func _on_music_volume_slider_value_changed(value):
	print("Music Volume: ", value)
	UserSettings.current.sound.music_volume = value
	update_volume()	


func _on_sound_effect_volume_slider_value_changed(value):
	print("Sound Effect Volume:", value)
	UserSettings.current.sound.effects_volume = value
	update_volume()

func _on_ambience_slider_value_changed(value):
	print("Ambience Volume", value)


func _on_DayToggle_toggled(button_pressed):
	if button_pressed:
		Global.day = true
	else:
		Global.day = false

func _on_TextEdit_text_changed():
	name_start_button.disabled = false


func _on_PNameStartButton_pressed():
	PlayerVars.new(name_entry.text)
	Global.pause_game(false)
	load_into_homebase()

func _on_Load_pressed():
	load_accept_popup.popup()

func _on_LoadAcceptDialog_confirmed():
	PlayerVars.load_save()
	Global.pause_game(false)
	load_into_homebase()


func _on_ResetSettings_pressed():
	print("RESETTING SETTINGS")
	UserSettings.new()
	update_settings()

func _on_ReturnFromOptions_pressed():
	close_options()


func _on_mini_map_style_optionbutton_item_selected(index):
	UserSettings.current.ui.mini_map_style = index
	UserSettings.refresh_ui()
	pass


func _on_hud_opacity_slider_value_changed(value):
	UserSettings.current.ui.master_hud_opacity = value
	UserSettings.refresh_ui()


func _on_status_bars_opac_slider_value_changed(value):
	UserSettings.current.ui.shipHUD_opacity = value
	UserSettings.refresh_ui()


func _on_mini_map_opac_slider_value_changed(value):
	UserSettings.current.ui.mini_map_grid_opacity = value
	UserSettings.refresh_ui()


func _on_FastLoad_pressed():
	if PlayerVars.save_exists():
		PlayerVars.load_save()
	update_settings()
	Global.pause_game(false)
	Global.goto_scene("res://World/game_zones/EasyZone_001.tscn")


func _on_CheckBox_toggled(button_pressed):
	Global.debug_mode = button_pressed
