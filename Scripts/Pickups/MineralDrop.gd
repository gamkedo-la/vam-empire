class_name MineralDrop
extends RigidBody2D
signal removed
signal mineral_spawned

onready var sprite: Sprite = $Sprite
onready var mineral_dust: Particles2D = $MineralDust
onready var pickup_trigger: Area2D = $PickupTrigger
var item_uuid: String = "4efd8d66-b38f-4b94-8326-2bc21799f888"

var despawn_timer
var particle_color: Color
var assigned_droid: bool = false

var count: int = 1

func _ready() -> void:
	despawn_timer = Timer.new()
	add_child(despawn_timer)
	despawn_timer.wait_time = 12
	despawn_timer.connect("timeout", self, "_release_item")
	if item_uuid != "":
		init_mineral(item_uuid)
	init_mining_pirate_encounter()

func init_mineral(uuid:String) -> void:
	load_item_from_db(uuid)
	_generate_particles()
	_set_particle_color()

func init_mining_pirate_encounter():
	var mining_pirate_encounters = get_tree().get_nodes_in_group("mining_pirate_encounter")
	for encounter in mining_pirate_encounters:
		connect("mineral_spawned", encounter, "_try_increase_attraction")
	emit_signal("mineral_spawned")

func pickup() -> void:
	PlayerVars.pickup_item(item_uuid, count)
	sprite.visible = false
	emit_signal("removed", self)
	set_as_toplevel(true)
	pickup_trigger.set_deferred("monitorable", false)
	pickup_trigger.set_deferred("monitoring", false)
	mineral_dust.set_emitting(false)
	despawn_timer.start()
	

func load_item_from_db(uuid: String) -> void:	
	var item_data = Database.itemByUuid[uuid]
	#print_debug(item_data)
	var img = Image.new()
	item_uuid = item_data.itemUuid
	#print_debug(item_data.itemIcon)
	sprite.texture = load(item_data.itemIcon)
	img = sprite.texture.get_data()
	img.lock()
	particle_color = img.get_pixel(16,16)
	img.unlock()
#	print_debug("Color: ", particle_color, "Image: ", item_data.itemIcon)

func _generate_particles() -> void:
	var proc_mat = mineral_dust.process_material.duplicate(true)
	mineral_dust.process_material = proc_mat
	
func _set_particle_color() -> void:
	mineral_dust.process_material.color = particle_color

func _release_item() -> void:
	call_deferred("queue_free")
