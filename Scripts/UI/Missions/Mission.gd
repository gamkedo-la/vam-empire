tool
class_name Mission
extends Button

signal mission_selected

enum Status {
	LOCKED,
	UNLOCKED,
	INPROGRESS,
	COMPLETE
}

export (String) var mission_name = ""
# Unique Mission Identifier to be tracked in the Player Save as being In Progress or Complete
export (String) var mission_id = ""

export (String) var mission_summary = ""

export (Status) var mission_status

export (Array, NodePath) var pre_req_missions

func _ready() -> void:
	self.text = mission_name
	self.name = mission_id
	if pre_req_missions.size() <= 0 && mission_status == Status.LOCKED:
		mission_status = Status.UNLOCKED
	if mission_status == Status.LOCKED:
		self.visible = false
	_init_connections()
	
func _init_connections() -> void:
	if not self.is_connected("pressed", self, "_mission_pressed"):
		assert(self.connect("pressed", self, "_mission_pressed") == OK)
		
func _mission_pressed() -> void:
	print_debug("Mission ", mission_id, " pressed.")
	emit_signal("mission_selected", mission_id)

func check_preqs() -> void:
	var unlock = true
	if mission_status == Status.LOCKED:
		for preq in pre_req_missions:
			print_debug("preq: ",preq)
			var preq_mission = get_node_or_null(preq)
			print_debug("preq_mission: ", preq_mission)
			if !preq_mission.mission_status == Status.COMPLETE:
				unlock = false
		if unlock:
			mission_status = Status.UNLOCKED
		
