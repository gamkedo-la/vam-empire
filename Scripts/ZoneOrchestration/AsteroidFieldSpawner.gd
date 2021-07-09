class_name RoidSpawner
extends Node2D

signal despawn_roids

export (Array, PackedScene) var asteroids
export (Array, int) var asteroid_weight
export (Array, String) var mineral_contents
var spacing: float

var rng = RandomNumberGenerator.new()
var player_node

func _ready() -> void:
	player_node = PlayerVars.player_node
	spacing = 1500.0 * (1.0 - (clamp(global_position.y/-250000, 0.0, 0.25)))
	


func generate_asteroids() -> void:
	var y_coord: float = 2000
	var hat_pick = []
	
#	rng.randomize()
	for index in asteroids.size() - 1:
		var weight = asteroid_weight[index]
		for num in weight:
			hat_pick.append(index)
#	print_debug("hat_pick", hat_pick)
	while y_coord > -1000:
		var x_coord = -1000
		var x_max = 1000
		rng.randomize()
		y_coord -= rng.randf_range(spacing/2, spacing)
		while x_coord < x_max:
			var rand_idx = hat_pick[rng.randi_range(0, hat_pick.size() - 1)]
			var newRoid = asteroids[rand_idx].instance()
#			add_child(newRoid)
			newRoid.is_spinning = false
			newRoid.mineral_contents = mineral_contents
			newRoid.initialize_in_group(self)
			call_deferred("add_child", newRoid)
			newRoid.call_deferred("set", "position", 
				Vector2(x_coord + rng.randf_range(-spacing/2, spacing/2), y_coord + rng.randf_range(-100, 100)))
			newRoid.call_deferred("set", "rotation_degrees", rng.randi_range(0,359))
#			newRoid.position = Vector2(x_coord + rng.randf_range(-10, 10), y_coord + rng.randf_range(-10, 10))
			x_coord += spacing
	
	Global.emit_signal("update_minimap")

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		generate_asteroids()


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("despawn_roids")
