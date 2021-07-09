class_name MissionBoard
extends MarginContainer

signal mission_complete

onready var mission_list: VBoxContainer = $Panel/HBMain/VBLeft/MissionsScroll/VBMissions
onready var complete_star: StreamTexture = preload("res://UI/Menu/Missions/complete_star2.png")
var missions = {}
var status = ["Locked", "Unlocked", "Accepted", "Complete"]
var sel_miss: Mission = null
var is_home_base: bool = false
var mission_debug: bool = true

onready var name_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName/Name
onready var status_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBStatus/Status
onready var complete_icon: TextureRect = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBCompletion/CompleteIcon
onready var complete_text: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBCompletion/CompleteText
onready var summary_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName3/Summary
onready var accept_button: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBButtons/Accept
onready var complete_button: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBButtons/Complete
onready var debug_complete: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBDebug/DebugComplete
onready var reward_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBReward/Reward


func _ready() -> void:
	_init_board()
	if get_tree().get_root().get_node_or_null("HomeBase"):
		is_home_base = true
	else:
		is_home_base = false

func _init_board() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			if not mission.is_connected("mission_selected", self, "_mission_selected"):
				assert(mission.connect("mission_selected", self, "_mission_selected") == OK)
			mission.status = mission.initial_status
			if PlayerVars.mission_state.has(mission.mission_id):
				mission.status = PlayerVars.mission_state[mission.mission_id].status
				mission.completed = PlayerVars.mission_state[mission.mission_id].completed
			else:
				mission.status = mission.initial_status
				mission.completed = 0
			if mission.status == Mission.Status.LOCKED:
				mission.visible = false
			else:
				mission.visible = true
			pass
			if mission.status == Mission.Status.ACCEPTED:
				mission.set_triggers()
			if mission.status == Mission.Status.COMPLETE:
				mission.icon = complete_star
			else:
				mission.icon = null
			mission.check_completable()
	check_all_prereqs()
	_mission_selected(mission_list.get_child(0).mission_id)
	
	
	
func _process(_delta):
	if Input.is_action_just_pressed("mission_menu"):
		_toggle_viz()
	pass


	

func _mission_selected(miss_id:String) -> void:
	$Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBDebug.visible = false
	sel_miss = mission_list.get_node_or_null(miss_id)
	name_label.text = str(sel_miss.m_name)
	status_label.text = str(status[sel_miss.status])
	summary_label.text = str(sel_miss.summary)
	reward_label.text = str("$", sel_miss.cash_reward)
	if sel_miss.status == Mission.Status.UNLOCKED:
		accept_button.visible = true
	else:
		accept_button.visible = false
#	print_debug("completable: ", sel_miss.completable, " is_home_base")
	if sel_miss.completable && is_home_base:
		complete_button.visible = true
	else: 
		complete_button.visible = false
		
	if sel_miss.status >= Mission.Status.ACCEPTED:
		if mission_debug:
			$Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBDebug.visible = true
	if sel_miss.mission_type == Mission.MissionType.ITEM:
		complete_icon.texture = load(Database.itemByUuid[sel_miss.item_uuid].itemIcon)
		complete_text.text = str(sel_miss.completed,"/",sel_miss.item_goal)
	elif sel_miss.mission_type == Mission.MissionType.KILL:
		complete_icon.texture = null
		complete_text.text = str("Kills: ", sel_miss.completed,"/",sel_miss.kill_goal)
	elif sel_miss.mission_type == Mission.MissionType.CHECKPOINT:
		complete_icon.texture = null
		complete_text.text = str("Visited: ", sel_miss.completed,"/",sel_miss.chkp_goal)
	
	
#	print(miss_id)

func check_all_prereqs() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			mission.check_preqs()
			if mission.status != Mission.Status.LOCKED:
				mission.visible = true
			else:
				mission.visible = false


func _toggle_viz() -> void:
	_mission_selected(sel_miss.mission_id)
#	mission_list.get_node(sel_miss.mission_id).grab_focus()
	sel_miss.grab_focus()
	self.visible = !self.visible
	

func _on_DebugComplete_pressed():
	
	if sel_miss is Mission:
		if sel_miss.status == Mission.Status.ACCEPTED:
			complete_mission()


func _on_Accept_pressed():
	var success = false
	if sel_miss.status == Mission.Status.UNLOCKED:		
		sel_miss.status = Mission.Status.ACCEPTED
		success = PlayerVars.accept_mission(sel_miss)

	if success:
		sel_miss.set_triggers()
	else:
		print_debug("Something wrong with Aceepting Mission: [", sel_miss.mission_id,"] Make sure the mission has an objective!")
	_mission_selected(sel_miss.mission_id)


func _on_ResetAll_pressed() -> void:
	PlayerVars.mission_state = {}
	_init_board()
	


func _on_Complete_pressed() -> void:
	if sel_miss is Mission:
		if sel_miss.status == Mission.Status.ACCEPTED && sel_miss.completable:
			complete_mission()

func complete_mission() -> void:

#	print_debug(sel_miss.m_name)
	sel_miss.status = Mission.Status.COMPLETE
	sel_miss.completable = false
	PlayerVars.complete_mission(sel_miss)
	sel_miss.icon = complete_star
	if sel_miss.cash_reward > 0:
		PlayerVars.player.cash += sel_miss.cash_reward

	check_all_prereqs()
	_mission_selected(sel_miss.mission_id)
	PlayerVars.save()
