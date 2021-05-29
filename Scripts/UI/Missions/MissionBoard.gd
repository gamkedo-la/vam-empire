tool
class_name MissionBoard
extends MarginContainer

onready var mission_list: VBoxContainer = $Panel/HBMain/VBLeft/MissionsScroll/VBMissions

var missions = {}

var selected_mission: Mission = null

onready var name_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName/Name
onready var status_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBStatus/Status
onready var summary_label: Label = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBName3/Summary
onready var accept_button: Button = $Panel/HBMain/VBRight/ScrollContainer/VBInfo/HBButtons/Accept


func _ready() -> void:
	for mission in mission_list.get_children():
		if mission is Mission:
			mission.connect("mission_selected", self, "_mission_selected")
			pass
	pass
	

func _mission_selected(miss_id:String) -> void:
	selected_mission = mission_list.get_node_or_null(miss_id)
	name_label.text = str(selected_mission.mission_name)
	status_label.text = str(selected_mission.mission_status)
	summary_label.text = str(selected_mission.mission_summary)
	print(miss_id)
