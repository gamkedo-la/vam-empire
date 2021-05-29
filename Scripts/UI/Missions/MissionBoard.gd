tool
class_name MissionBoard
extends MarginContainer

signal mission_complete

onready var mission_list: VBoxContainer = $Panel/HBMain/VBLeft/MissionsScroll/VBMissions

var missions = {}
var status = ["Locked", "Unlocked", "Incomplete", "Complete"]
var selected_mission: Mission = null

onready var name_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName/Name
onready var status_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBStatus/Status
onready var summary_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName3/Summary
onready var accept_button: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBButtons/Accept
onready var debug_complete: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBDebug/DebugComplete


func _ready() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			mission.connect("mission_selected", self, "_mission_selected")
			if mission.mission_status == Mission.Status.LOCKED:
				mission.visible = false
			pass
	pass
	

func _mission_selected(miss_id:String) -> void:
	selected_mission = mission_list.get_node_or_null(miss_id)
	name_label.text = str(selected_mission.mission_name)
	status_label.text = str(status[selected_mission.mission_status])
	summary_label.text = str(selected_mission.mission_summary)
	print(miss_id)

func check_all_prereqs() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			mission.check_preqs()
			if mission.mission_status != Mission.Status.LOCKED:
				mission.visible = true
			else:
				mission.visible = false

func _on_DebugComplete_pressed():
	
	if selected_mission is Mission:
		print_debug(selected_mission.mission_name)
		selected_mission.mission_status = Mission.Status.COMPLETE
	check_all_prereqs()
