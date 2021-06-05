extends MarginContainer

onready var missions_mount:VBoxContainer = $Missions
onready var miss_stat = preload("res://UI/HUD/Scenes/MissStatSingle.tscn")

func _ready():
	for mission in PlayerVars.mission_state:
		if PlayerVars.mission_state[mission].status < Mission.Status.COMPLETE:
			var newMiss = miss_stat.instance()
			newMiss.miss_id = mission
			missions_mount.add_child(newMiss)
			
	
