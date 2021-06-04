class_name MissionBoard
extends MarginContainer

signal mission_complete

onready var mission_list: VBoxContainer = $Panel/HBMain/VBLeft/MissionsScroll/VBMissions

var missions = {}
var status = ["Locked", "Unlocked", "Accepted", "Complete"]
var sel_miss: Mission = null

var mission_debug: bool = true

onready var name_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName/Name
onready var status_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBStatus/Status
onready var complete_icon: TextureRect = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBCompletion/CompleteIcon
onready var complete_text: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBCompletion/CompleteText
onready var summary_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName3/Summary
onready var accept_button: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBButtons/Accept
onready var debug_complete: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBDebug/DebugComplete


func _ready() -> void:
	_init_board()

func _init_board() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			mission.connect("mission_selected", self, "_mission_selected")
			mission.status = mission.initial_status
			if PlayerVars.mission_state.has(mission.mission_id):
				mission.status = PlayerVars.mission_state[mission.mission_id].status
			if mission.status == Mission.Status.LOCKED:
				mission.visible = false
			else:
				mission.visible = true
			pass
			mission.set_triggers()			
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
	if sel_miss.status == Mission.Status.UNLOCKED:
		accept_button.visible = true
	else:
		accept_button.visible = false
	
	if sel_miss.status >= Mission.Status.ACCEPTED:
		if mission_debug:
			$Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBDebug.visible = true
		if sel_miss.mission_type == Mission.MissionType.ITEM:
			complete_icon.texture = load(Database.itemByUuid[sel_miss.item_uuid].itemIcon)
		elif sel_miss.mission_type == Mission.MissionType.KILL:
			complete_icon.texture = null
		complete_text.text = str(sel_miss.completed,"/",sel_miss.item_goal)
	print(miss_id)

func check_all_prereqs() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			mission.check_preqs()
			if mission.status != Mission.Status.LOCKED:
				mission.visible = true
			else:
				mission.visible = false


func _toggle_viz() -> void:
	self.visible = !self.visible

func _on_DebugComplete_pressed():
	
	if sel_miss is Mission:
		if sel_miss.status == Mission.Status.ACCEPTED:
			print_debug(sel_miss.m_name)
			sel_miss.status = Mission.Status.COMPLETE
			PlayerVars.complete_mission(sel_miss)
	check_all_prereqs()
	_mission_selected(sel_miss.mission_id)


func _on_Accept_pressed():
	var success = false
	if sel_miss.status == Mission.Status.UNLOCKED:		
		sel_miss.status = Mission.Status.ACCEPTED
		success = PlayerVars.accept_mission(sel_miss)

	if !success:
		print_debug("Something wrong with Aceepting Mission: [", sel_miss.mission_id,"] Make sure the mission has objectives!")
	_mission_selected(sel_miss.mission_id)


func _on_ResetAll_pressed():
	PlayerVars.mission_state = {}
	_init_board()
	
