extends Node2D

onready var vam_logo = $MenuCanvas/Viz/MainMenuVBox/LogoBox/VamLogo
onready var empire_logo = $MenuCanvas/Viz/MainMenuVBox/LogoBox/VamLogo/Control/EmpireLogo
onready var ani_player = $MenuCanvas/Viz/AnimationPlayer

onready var main_menu = $MenuCanvas/Viz/MainMenuVBox
onready var main_menu_buttons = $MenuCanvas/Viz/MainMenuVBox/InteractVB
onready var new_button = $MenuCanvas/Viz/MainMenuVBox/InteractVB/NewHB/New
onready var load_button = $MenuCanvas/Viz/MainMenuVBox/InteractVB/LoadHB2/Load
onready var continue_button = $MenuCanvas/Viz/MainMenuVBox/InteractVB/ContinueHB/Continue
onready var load_accept_popup = $MenuCanvas/Viz/LoadAcceptDialog
onready var save_slots_menu = $MenuCanvas/Viz/MainMenuVBox/SaveSlots
onready var options = $MenuCanvas/Viz/OptionsContainer

# Save Slots
onready var load_slot_1 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot1/LoadSlot1
onready var start_slot_1 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot1/StartSlot1
onready var slot_details_1 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot1/SlotDetails1
onready var del_slot_1 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot1/DelSlot1
onready var confirm_del_label_1 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot1/ConfirmDelLabel1
onready var confirm_del_slot_1 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot1/ConfirmDelSlot1
onready var load_slot_2 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot2/LoadSlot2
onready var start_slot_2 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot2/StartSlot2
onready var slot_details_2 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot2/SlotDetails2
onready var del_slot_2 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot2/DelSlot2
onready var confirm_del_label_2 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot2/ConfirmDelLabel2
onready var confirm_del_slot_2 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot2/ConfirmDelSlot2
onready var load_slot_3 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot3/LoadSlot3	
onready var start_slot_3 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot3/StartSlot3
onready var slot_details_3 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot3/SlotDetails3
onready var del_slot_3 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot3/DelSlot3
onready var confirm_del_label_3 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot3/ConfirmDelLabel3
onready var confirm_del_slot_3 = $MenuCanvas/Viz/MainMenuVBox/SaveSlots/Slot3/ConfirmDelSlot3

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

# Difficulty Panel
onready var difficulty_option = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/Difficulty/VBoxContainer/HBoxContainer/DifficultyOptionButton

# System Panel
onready var contxt_steering_draw_toggle = $MenuCanvas/Viz/OptionsContainer/VBoxContainer/TabContainer/System/VBoxContainer/DebugModeHBox/ContextSteeringToggle

onready var transition = $Transition

onready var menu_viz = $MenuCanvas/Viz
var start_menu = false

func _ready():
#	options.visible = false
#	main_menu.visible = true
#	menu_open = true
	if get_parent().name == "StartMenu":
		self.visible = true
		start_menu = true
		save_slots_menu.visible = false
		main_menu_buttons.visible = true
	else:
		menu_viz.visible = false
		start_menu = false
				
	if PlayerVars.save_exists(UserSettings.current.save.current_slot):
		continue_button.visible = true
		load_button.disabled = false
	else:
		continue_button.visible = false
		load_button.disabled = true
	#TODO: This is just a quick hack to get some placeholder menu music. Music should be handled in a persistent way to allow smooth transitions
	ani_player.play("Empire_Loop")
	_setup_slot_buttons()
	update_ui_settings()
	update_volume()
	close_options()
	close_save_menu()
	
	
func _process(_delta):
	check_inputs()

func check_inputs():
	if !start_menu:
		if Input.is_action_just_pressed("ui_esc"):
			if PlayerVars.get_target():
				PlayerVars.set_target(null)
			elif menu_viz.visible && !options.visible && !save_slots_menu.visible:
				unpause_game()
			elif save_slots_menu.visible:
				close_save_menu()
			elif options.visible:
				close_options()
			else:
				pause_game()
	else:
		if Input.is_action_just_pressed("ui_esc"):
			if options.visible:
				close_options()
			elif save_slots_menu.visible:
				close_save_menu()

func unpause_game():
	menu_viz.visible = false
	main_menu.visible = false
	main_menu_buttons.visible = true
	Global.pause_game(false)

func pause_game():
	menu_viz.visible = true
	main_menu.visible = true
	main_menu_buttons.visible = true
	save_slots_menu.visible = false
	options.visible = false
	Global.pause_game(true)
	
func close_save_menu():
	save_slots_menu.visible = false
	main_menu.visible = false
	# quick toggle to reset transforms
	main_menu.visible = true
	main_menu_buttons.visible = true

func close_options():
	if options.visible:
		UserSettings.save()
		# options.visible = false
		var animation = get_node("MenuCanvas/Viz/OptionsContainer/AnimationPlayer")
		animation.play("Hide")
		main_menu.visible = true
		main_menu_buttons.visible = true	
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
	if UserSettings.current.difficulty.difficulty_level:
		difficulty_option.selected = UserSettings.current.difficulty.difficulty_level
	contxt_steering_draw_toggle.pressed = UserSettings.current.system.show_context_steering	
	UserSettings.refresh_ui()
	
	
func load_into_homebase():
	Global.goto_scene("res://World/game_zones/home_base.tscn")	

func _setup_slot_buttons():
	load_slot_1.disabled = true
	load_slot_2.disabled = true
	load_slot_3.disabled = true
	del_slot_1.disabled = true
	confirm_del_slot_1.disabled = true
	confirm_del_label_1.visible = false
	confirm_del_slot_1.visible = false
	del_slot_2.disabled = true
	del_slot_2.disabled = true
	confirm_del_slot_2.disabled = true
	confirm_del_label_2.visible = false
	confirm_del_slot_2.visible = false
	del_slot_3.disabled = true
	confirm_del_slot_3.disabled = true
	confirm_del_label_3.visible = false
	confirm_del_slot_3.visible = false
	
	start_slot_1.disabled = false
	slot_details_1.bbcode_text = ""
	start_slot_2.disabled = false
	slot_details_2.bbcode_text = ""
	start_slot_3.disabled = false
	slot_details_3.bbcode_text = ""
	
	if PlayerVars.save_exists(1):
		load_slot_1.disabled = false
		start_slot_1.disabled = true
		del_slot_1.disabled = false
		slot_details_1.bbcode_text = PlayerVars.get_save_summary(1)
	if PlayerVars.save_exists(2):
		load_slot_2.disabled = false
		start_slot_2.disabled = true
		del_slot_2.disabled = false
		slot_details_2.bbcode_text = PlayerVars.get_save_summary(2)
	if PlayerVars.save_exists(3):
		load_slot_3.disabled = false
		start_slot_3.disabled = true
		del_slot_3.disabled = false
		slot_details_3.bbcode_text = PlayerVars.get_save_summary(3)

func _on_New_pressed():
	main_menu_buttons.visible = false
	save_slots_menu.visible = true
	#print("Loading new Scene...")
	
	#name_popup.popup_centered()

func _disable_new():
	new_button.disabled = true

func _on_Options_pressed():
	main_menu.visible = false
	options.visible = true
	var animation = get_node("MenuCanvas/Viz/OptionsContainer/AnimationPlayer")
	animation.play("Show")
	


func _on_mast_volume_slider_value_changed(value):
	#print("Master Volume: ", value)
	UserSettings.current.sound.master_volume = value
	update_volume()

func _on_music_volume_slider_value_changed(value):
	#print("Music Volume: ", value)
	UserSettings.current.sound.music_volume = value
	update_volume()	


func _on_sound_effect_volume_slider_value_changed(value):
	#print("Sound Effect Volume:", value)
	UserSettings.current.sound.effects_volume = value
	update_volume()

func _on_ambience_slider_value_changed(value):
	#print("Ambience Volume", value)
	pass


func _on_DayToggle_toggled(button_pressed):
	if button_pressed:
		Global.day = true
	else:
		Global.day = false

func _on_PNameStartButton_pressed():
	PlayerVars.new(name_entry.text)
	Global.pause_game(false)
	#load_into_homebase()
	transition.transition_out()

func _on_Continue_pressed():
	load_accept_popup.popup_centered()

func _on_Load_pressed():
	main_menu_buttons.visible = false
	save_slots_menu.visible = true


func _on_LoadAcceptDialog_confirmed():
	PlayerVars.load_save()
	Global.pause_game(false)
	#load_into_homebase()
	transition.transition_out()

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


func _on_DifficultyOptionButton_item_selected(index):
	UserSettings.current.difficulty.difficulty_level = index
	UserSettings.refresh_ui()


func _on_FastLoad_pressed():
	if PlayerVars.save_exists(UserSettings.current.save.current_slot):
		PlayerVars.load_save()
	update_settings()
	Global.pause_game(false)
	Global.goto_scene("res://World/game_zones/EasyZone_001.tscn")

func _on_NewPlayerPop_about_to_show():
	var animation = get_node("MenuCanvas/Viz/NewPlayerPop/AnimationPlayer")
	animation.play("Show")



func _on_NewPlayerPop_popup_hide():
	#var animation = get_node("MenuCanvas/Viz/NewPlayerPop/AnimationPlayer")
	#animation.play("Hide")
	pass


func _on_LoadAcceptDialog_about_to_show():
	var animation = get_node("MenuCanvas/Viz/LoadAcceptDialog/AnimationPlayer")
	animation.play("Show")


func _on_LoadAcceptDialog_popup_hide():
	#var animation = get_node("MenuCanvas/Viz/LoadAcceptDialog/AnimationPlayer")
	#animation.play("Hide")
	pass


func _on_Transition_can_exit():
	main_menu_buttons.visible = true
	save_slots_menu.visible = false
	load_into_homebase()


func _on_Return_pressed():
	close_save_menu()

func _on_LoadSlot1_pressed():
	PlayerVars.set_save_slot(1)
	PlayerVars.load_save()
	Global.pause_game(false)	
	transition.transition_out()

func _on_LoadSlot2_pressed():
	PlayerVars.set_save_slot(2)
	PlayerVars.load_save()
	Global.pause_game(false)	
	transition.transition_out()

func _on_LoadSlot3_pressed():
	PlayerVars.set_save_slot(3)
	PlayerVars.load_save()
	Global.pause_game(false)	
	transition.transition_out()

func _new_character():
	name_popup.popup_centered()

func _on_StartSlot1_pressed():
	PlayerVars.set_save_slot(1)
	_new_character()

func _on_StartSlot2_pressed():
	PlayerVars.set_save_slot(2)
	_new_character()

func _on_StartSlot3_pressed():
	PlayerVars.set_save_slot(3)
	_new_character()

func _on_DelSlot1_pressed():
	load_slot_1.visible = false
	start_slot_1.visible = false
	slot_details_1.visible = false
	del_slot_1.visible = false
	confirm_del_label_1.visible = true
	confirm_del_slot_1.visible = true
	confirm_del_slot_1.disabled = false

func _on_DelSlot2_pressed():
	load_slot_2.visible = false
	start_slot_2.visible = false
	slot_details_2.visible = false
	del_slot_2.visible = false
	confirm_del_label_2.visible = true
	confirm_del_slot_2.visible = true
	confirm_del_slot_2.disabled = false

func _on_DelSlot3_pressed():
	load_slot_3.visible = false
	start_slot_3.visible = false
	slot_details_3.visible = false
	del_slot_3.visible = false
	confirm_del_label_3.visible = true
	confirm_del_slot_3.visible = true
	confirm_del_slot_3.disabled = false
	
func _on_ConfirmDelSlot1_pressed():
	PlayerVars.delete_save(1)
	load_slot_1.visible = true
	start_slot_1.visible = true
	slot_details_1.visible = true
	del_slot_1.visible = true
	confirm_del_label_1.visible = false
	confirm_del_slot_1.visible = false
	_setup_slot_buttons()
	
func _on_ConfirmDelSlot2_pressed():
	PlayerVars.delete_save(2)
	load_slot_2.visible = true
	start_slot_2.visible = true
	slot_details_2.visible = true
	del_slot_2.visible = true
	confirm_del_label_2.visible = false
	confirm_del_slot_2.visible = false
	_setup_slot_buttons()

func _on_ConfirmDelSlot3_pressed():
	PlayerVars.delete_save(3)
	load_slot_3.visible = true
	start_slot_3.visible = true
	slot_details_3.visible = true
	del_slot_3.visible = true
	confirm_del_label_3.visible = false
	confirm_del_slot_3.visible = false
	_setup_slot_buttons()

func _on_ContextSteeringToggle_toggled(button_pressed):
	UserSettings.current.system.show_context_steering = button_pressed

func _on_PlayerNameEdit_text_entered(new_text):
	if new_text != "":
		PlayerVars.new(name_entry.text)
		Global.pause_game(false)
		#load_into_homebase()
		transition.transition_out()

func _on_PlayerNameEdit_text_changed(new_text):
	if new_text == "":
		name_start_button.disabled = true
	else:
		name_start_button.disabled = false

