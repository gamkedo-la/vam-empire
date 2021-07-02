extends Node2D

# MissionCheck.gd is a helper script for Zone segments that should only spawn if a particular mission is active.
# This allows a lightweight (empty) node to sit in the world until the player picks up the mission at base.

export (String) var mission_id = null
export (PackedScene) var mission_scene = null


func _ready():
	if mission_id:
		if PlayerVars.check_mission_active(mission_id):
			if mission_scene:
#				var miss_instance = load(mission_scene)
				var miss_subscene = mission_scene.instance()
				self.call_deferred("add_child", miss_subscene)	
	pass
