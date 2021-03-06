extends Node2D

onready var dust = $DustParticles
onready var mineral_drop = preload("res://Pickups/Minerals/MineralDrop.tscn")
onready var rng = RandomNumberGenerator.new()
var laser = null
var despawn_timer
var spawn_timer
var mineral_uuid: String = "4efd8d66-b38f-4b94-8326-2bc21799f888"

var max_life

func _ready() -> void:
	rng.randomize()
	max_life = Timer.new()
	max_life.wait_time = 40
	max_life.connect("timeout", self, "_despawn")
	add_child(max_life)
	max_life.start()
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
	var modifier = 0
	if UserSettings.current.difficulty.difficulty_level == 1:
		modifier = 10
	if UserSettings.current.difficulty.difficulty_level == 0:
		modifier = 30
		
	if chance > 150:
		_spawn_mineral(mineral_uuid)

	# If chance is especially high, drop a random mineral of *any* kind. 
	# modifier increases chance for lower difficulty modes
	if chance >= 199 - modifier:
		rng.randomize()		
		var new_uuid = Database.table.Items[rng.randi_range(0,Database.table.Items.size() - 1)].itemUuid
		_spawn_mineral(new_uuid)

func _spawn_mineral(itemUuid: String) -> void:
	var newMineral: MineralDrop = mineral_drop.instance()
	newMineral.item_uuid = itemUuid
	get_tree().get_root().add_child(newMineral)
	newMineral.global_position = self.global_position
	var vecx = rng.randf_range(-1,1)
	var vecy = rng.randf_range(-1,1)
	newMineral.apply_central_impulse(Vector2(vecx,vecy) * (Vector2.ONE*10))
	newMineral.angular_velocity = rng.randf_range(-2,2)
