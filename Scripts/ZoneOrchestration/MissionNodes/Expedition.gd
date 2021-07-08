extends Node2D

signal removed

export (String) var mission_string = null
onready var miner_detect: Area2D = $Checkpoint/CheckpointDetect
var visited = false

func _ready():
	visited = false
	if not miner_detect.is_connected("body_entered", self, "_check_player_visited"):
		assert(miner_detect.connect("body_entered", self, "_check_player_visited") == OK)

func _check_player_visited(_body: Node) -> void:
	print_debug(_body)
	if _body.is_in_group("player"):
		if mission_string && !visited:
			print_debug("mission_string exists ", mission_string)
			PlayerVars.emit_signal("checkpoint_reached", mission_string)
			emit_signal("removed", self)
			visited = true
