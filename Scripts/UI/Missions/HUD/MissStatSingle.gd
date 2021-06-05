extends VBoxContainer

onready var mission_label = $MissTitle/Label
onready var mission_complete = $MissStatus/Completed

var miss_id: String = ""

func _ready() -> void:
	_init_fields()
	PlayerVars.connect("mission_updated", self, "_init_fields")
	
func _init_fields() -> void:
	if PlayerVars.mission_state.has(miss_id):
		var miss_data = PlayerVars.mission_state[miss_id]
		print_debug(miss_data)
		mission_label.text = str(miss_data.name)
		if miss_data.has("goal"):
			mission_complete.text = str(miss_data.completed,"/",miss_data.goal)

