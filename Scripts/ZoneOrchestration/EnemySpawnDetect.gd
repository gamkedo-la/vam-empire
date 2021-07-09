extends Area2D

export (PackedScene) var enemy_spawn


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_SpawnDetect_body_entered(body):
	if body.is_in_group("player"):
		var newEnemy = enemy_spawn.instance()
		get_parent().call_deferred("add_child", newEnemy)
		Global.emit_signal("update_minimap")
		call_deferred("queue_free")
		
