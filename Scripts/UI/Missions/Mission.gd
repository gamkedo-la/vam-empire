tool
class_name Mission
extends Button

signal mission_selected

enum Status {
	LOCKED,
	UNLOCKED,
	ACCEPTED,
	COMPLETE
}

enum MissionType {
	ITEM,
	KILL,
	CHECKPOINT
}

export (String) var m_name = ""
# Unique Mission Identifier to be tracked in the Player Save as being In Progress or Complete
export (String) var mission_id = ""

export (String, MULTILINE) var summary = ""

export (Status) var status
export (Status) var initial_status

export (MissionType) var mission_type
export (int) var cash_reward

export (String) var item_uuid
export (int) var item_goal

export (Actor.Team) var kill_team
export (String) var mission_string = "ANY"
export (int) var kill_goal

export (int) var chkp_goal
export (int) var completed = 0

var completable: bool = false

export (Array, NodePath) var pre_req_missions

func _ready() -> void:
	self.text = m_name
	self.name = mission_id
	if pre_req_missions.size() <= 0 && status == Status.LOCKED:
		status = Status.UNLOCKED
	if status == Status.LOCKED:
		self.visible = false
	_init_connections()
	
func _init_connections() -> void:
	if not self.is_connected("pressed", self, "_mission_pressed"):
		assert(self.connect("pressed", self, "_mission_pressed") == OK)
		
func _mission_pressed() -> void:
#	print_debug("Mission ", mission_id, " pressed.")
	emit_signal("mission_selected", mission_id)
	
func set_triggers() -> void:
	if mission_type == MissionType.ITEM:		
		if not PlayerVars.is_connected("picked_up", self, "_check_item_mission"):
			assert(PlayerVars.connect("picked_up", self, "_check_item_mission") == OK)
	elif mission_type == MissionType.KILL:
		if not PlayerVars.is_connected("actor_killed", self, "_check_kill_mission"):
			assert(PlayerVars.connect("actor_killed", self, "_check_kill_mission") == OK)
		if not PlayerVars.is_connected("check_target", self, "_check_target_type"):
			assert(PlayerVars.connect("check_target", self, "_check_target_type") == OK)
	elif mission_type == MissionType.CHECKPOINT:
		if not PlayerVars.is_connected("checkpoint_reached", self, "_check_chkpoint_mission"):
			assert(PlayerVars.connect("checkpoint_reached", self, "_check_chkpoint_mission") == OK)

func check_preqs() -> void:
	var unlock = true
	if status == Status.LOCKED:
		for preq in pre_req_missions:
#			print_debug("preq: ",preq)
			var preq_mission = get_node_or_null(preq)
#			print_debug("preq_mission: ", preq_mission)
			if !preq_mission.status == Status.COMPLETE:
				unlock = false
		if unlock:
			status = Status.UNLOCKED
			
func check_completable() -> void:
	if status != Status.COMPLETE:
		if mission_type == MissionType.ITEM:
			if item_goal <= completed:
				completable = true
		elif mission_type == MissionType.KILL:
			if kill_goal <= completed:
				completable = true
		elif mission_type == MissionType.CHECKPOINT:
			if chkp_goal <= completed:
				completable = true

func _check_item_mission(uuid:String, cnt: int) -> void:
#	print_debug("item_uuid: [",item_uuid, "] uuid: [",uuid,"]")
	if item_uuid == uuid && completed < item_goal:
		if completed + cnt <= item_goal:
			completed += cnt
		else:
			completed = item_goal
		PlayerVars.mission_state[mission_id].completed = completed
		PlayerVars.save()
		PlayerVars.emit_signal("mission_updated")
		
func _check_kill_mission(_kill_team: int, _mission_string:String) -> void:
	if (mission_string == "ANY" && kill_team == _kill_team) || mission_string == _mission_string:
		if completed + 1 <= kill_goal:
			completed += 1
		else:
			completed = kill_goal
		PlayerVars.mission_state[mission_id].completed = completed
		PlayerVars.save()
		PlayerVars.emit_signal("mission_updated")

func _check_target_type(_kill_team: int, _mission_string:String, _actor: Actor) -> void:
#	print_debug("Checking target:", _kill_team, " ", _mission_string, " ", _actor)
	if _kill_team == Actor.Team.BOSS:
		print_debug("Is a Boss")
	if (mission_string == "ANY" && kill_team == _kill_team) || mission_string == _mission_string:
		PlayerVars.emit_signal("target_active", _actor)
		
func _check_chkpoint_mission(_mission_string:String) -> void:
	if mission_string == _mission_string:
		if completed + 1 <= chkp_goal:
			completed += 1
		else:
			completed = chkp_goal
		PlayerVars.mission_state[mission_id].completed = completed
		PlayerVars.save()
		PlayerVars.emit_signal("mission_updated")
