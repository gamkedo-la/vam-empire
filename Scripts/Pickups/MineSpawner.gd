extends Node2D

onready var dust = $DustParticles
onready var mineral_drop = preload("res://Pickups/Minerals/MineralDrop.tscn")
onready var rng = RandomNumberGenerator.new()
var laser = null
var despawn_timer
var spawn_timer
func _ready() -> void:
	rng.randomize()
	despawn_timer = Timer.new()
	despawn_timer.wait_time = 10
	despawn_timer.connect("timeout", self, "_despawn")
	add_child(despawn_timer)
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2
	spawn_timer.connect("timeout", self, "_spawn_mineral_chance")
	add_child(spawn_timer)
	spawn_timer.start()

func _remove_mine_spawner(miner) -> void:	
	if miner == laser:
		dust.emitting = false
		spawn_timer.stop()
		despawn_timer.start()
		
func _despawn() -> void:
		call_deferred("queue_free")

func _spawn_mineral_chance() -> void:
	var chance = rng.randi() % 200
	if chance > 150:
		var newMineral = mineral_drop.instance()
		get_tree().get_root().add_child(newMineral)
		newMineral.global_position = self.global_position
		var vecx = rng.randf_range(-1,1)
		var vecy = rng.randf_range(-1,1)
		newMineral.apply_central_impulse(Vector2(vecx,vecy) * (Vector2.ONE*10))
		newMineral.angular_velocity = rng.randf_range(-2,2)